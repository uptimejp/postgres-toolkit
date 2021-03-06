#!/usr/bin/env python
# coding: UTF-8

# pt-proc-stat
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import copy
import getopt
import os
import re
import subprocess
import sys
import time

import log


class ProcInfo:
    pid = None
    ppid = None
    proc_stat = None
    proc_io = None
    proc_net = None
    debug = None

    def __init__(self, pid, pagesize=4096, debug=False):
        self.pid = pid
        self.pagesize = int(pagesize)
        self.debug = debug

        self.proc_stat = []
        self.proc_io = {}
        self.proc_net = {}

        if self.debug is True:
            log.setLevel(log.DEBUG)

    def read(self):
        base = "/proc/" + str(self.pid)

        # /proc/pid/cmdline
        try:
            f = open(base + "/cmdline")
        except IOError, err:
            log.debug(err)
            return False

        self.proc_cmdline = None

        for l in f.readlines():
            self.proc_cmdline = l.split('\0')
            self.name = self.proc_cmdline[0]

        f.close()

        if self.proc_cmdline is None:
            log.debug(base + "/cmdline is empty.")
            return False

        log.debug(base + "/cmdline ok.")

        self.name = self.name.replace('postgres:', '')
        self.name = self.name.replace('process', '')
        self.name = re.sub('.*/', '', self.name)
        self.name = re.sub('^ +', '', self.name)
        self.name = re.sub(' +$', '', self.name)
        self.name = re.sub('  +', ' ', self.name)

        log.debug("name = %s" % self.name)

        # /proc/pid/stat
        try:
            f = open(base + "/stat")
        except IOError, err:
            log.debug(err)
            return False

        log.debug(base + "/stat ok.")

        for l in f.readlines():
            self.proc_stat = l.split(' ')
            log.debug(self.proc_stat)

            self.ppid = int(self.proc_stat[3])
            break

        f.close()

        log.debug("ppid = %d" % self.ppid)

        # /proc/pid/io
        try:
            f = open(base + "/io")
        except IOError, err:
            log.debug(err)
            return False

        log.debug(base + "/io ok.")

        for l in f.readlines():
            key, value = l.rstrip('\r\n').split(': ')
            log.debug("key = %s, value = %s" % (key, value))

            self.proc_io[key] = int(value)

        f.close()

        return True

    def print_stat(self, prev=None):
        if prev is not None:
            # disk
            rbytes = (self.proc_io["read_bytes"] -
                      prev.proc_io["read_bytes"]) / 1024
            wbytes = (self.proc_io["write_bytes"] -
                      prev.proc_io["write_bytes"]) / 1024
            # net
            rchar = (self.proc_io["rchar"] -
                     prev.proc_io["rchar"]) / 1024 - rbytes
            wchar = (self.proc_io["wchar"] -
                     prev.proc_io["wchar"]) / 1024 - wbytes
            # cpu
            cpu_usr = int(self.proc_stat[13]) - int(prev.proc_stat[13])
            cpu_sys = int(self.proc_stat[14]) - int(prev.proc_stat[14])
            # mem
            vsz = int(self.proc_stat[22]) / 1024 / 1024
            rss = int(self.proc_stat[23]) * self.pagesize / 1024 / 1024
            print("%20s[%5d] %4s %4d %4d %4d %4d %6d %6d %6d %6d" % (
                self.name[:20], int(self.pid), self.proc_stat[2],
                cpu_usr, cpu_sys, vsz, rss,
                int(rbytes), int(wbytes), int(rchar), int(wchar)))
        else:
            # disk
            rbytes = (self.proc_io["read_bytes"]) / 1024
            wbytes = (self.proc_io["write_bytes"]) / 1024
            # net
            rchar = (self.proc_io["rchar"]) / 1024 - rbytes
            wchar = (self.proc_io["wchar"]) / 1024 - wbytes
            # cpu
            cpu_usr = int(self.proc_stat[13])
            cpu_sys = int(self.proc_stat[14])
            # mem
            vsz = int(self.proc_stat[22]) / 1024 / 1024
            rss = int(self.proc_stat[23]) * self.pagesize / 1024 / 1024
            print("%20s[%5d] %4s %4d %4d %4d %4d %6d %6d %6d %6d" % (
                self.name[:20], int(self.pid), self.proc_stat[2],
                cpu_usr, cpu_sys, vsz, rss,
                int(rbytes), int(wbytes), int(rchar), int(wchar)))


class PostgresProcessStat():
    pgdata = None
    postmaster_pid = None
    prev_stat = {}
    stat = {}
    update_count = 0
    debug = False

    def __init__(self, pgdata=None, pid=None, debug=False):
        self.pgdata = pgdata
        self.postmaster_pid = pid
        self.debug = debug
        return

    def get_postmaster_pid(self):
        if self.postmaster_pid is not None:
            return self.postmaster_pid

        # Get pid from postmaster.pid if available.
        if self.pgdata is not None:
            log.debug("reading " + self.pgdata +
                      "/postmaster.pid to to determine the postmaster pid.")
            try:
                f = open(self.pgdata + "/postmaster.pid")
                for l in f.readlines():
                    pid = int(l.replace('\n', ''))
                    break
                f.close()
            except IOError, err:
                log.error(err.strerror + " (" + self.pgdata +
                          "/postmaster.pid" + ")")
                sys.exit(1)

            if pid is not None:
                log.debug("found postmaster pid " + str(pid))
                return pid

        # Find postmaster pid from /proc/<pid> files.
        pid = None
        for p in self._get_pids():
            i = ProcInfo(p)
            if i.read() is False:
                continue

            log.debug("name: %s" % i.name)

            # Name of the process is "postmaster" or "postgres".
            if (re.search('postmaster', i.name) or
                    re.search('postgres', i.name)):
                pid = int(p)
                log.debug("found postmaster pid " + str(pid))

        if pid is None:
            log.error("Cannot find postmaster pid.")
            usage()
            sys.exit(1)

        self.postmaster_pid = pid

        return pid

    def get_postmaster_child_pids(self):
        child_pids = []

        for p in self._get_pids():
            i = ProcInfo(p)
            if i.read() is False:
                continue

            if i.ppid == self.get_postmaster_pid():
                child_pids.append(p)

        log.debug("child pids = " + str(child_pids))

        return child_pids

    def _get_pids(self):
        pids = []
        for p in os.listdir("/proc"):
            if re.search('^\d+$', p) is not None:
                pids.append(p)

        log.debug("_get_pids = " + str(pids))

        return pids

    def update_stat(self):
        pids = self.get_postmaster_child_pids()

        self.prev_stat = {}
        self.prev_stat = copy.deepcopy(self.stat)

        self.stat = {}

        # postmaster stat
        i = ProcInfo(self.get_postmaster_pid())
        if i.read() is False:
            log.error("Cannot get postmaster stat.")
            sys.exit(1)

        self.stat[self.get_postmaster_pid()] = i

        # child process stat
        for p in pids:
            i = ProcInfo(p)
            if i.read() is False:
                continue

            log.debug("update_stat: %s %s" % (i.name, i.pid))

            self.stat[p] = i

        self.update_count = self.update_count + 1
        log.debug("updae_stat: done count = %d" % self.update_count)

    def print_stat(self):
        os.system("date")
        print("%20s[%5s] %4s %4s %4s %4s %4s %6s %6s %6s %6s" %
              ('PROCESS NAME', 'PID', 'STAT', 'USR', 'SYS', 'VSZ', 'RSS',
               'READ', 'WRITE', 'READ2', 'WRITE2'))

        if self.prev_stat is None or len(self.prev_stat) == 0:
            log.debug("no prev records. printing the first records.")

            # print process stat.
            for i in sorted(self.stat):
                self.stat[i].print_stat()

            print("")
            return True

        log.debug("printing the diffs.")

        # print process stat.
        for i in sorted(self.stat):
            if i in self.prev_stat:
                self.stat[i].print_stat(self.prev_stat[i])
            else:
                self.stat[i].print_stat()

        print("")
        return True

if __name__ == "__main2__":
    #    p = ProcInfo('21185', debug=True)
    #    p.read()
    #    p.print_stat()

    #    log.setLevel(log.DEBUG)

    s = PostgresProcessStat(None)
    #    print(s._get_pids())

    #    print(s.get_postmaster_pid())
    #    print(s.get_postmaster_pid())

    #    print(s.get_postmaster_child_pids())

    s.update_stat()
    s.print_stat()

    time.sleep(1)

    s.update_stat()
    s.print_stat()


def usage():
    print '''
Usage: {0} [option...] [delay [count]]

Options:
    -D, --pgdata=DATADIR       Location of the database storage area
    -P, --pid=PID              Process ID of the postmaster

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "D:P:",
                                   ["help", "debug", "pgdata=", "pid="])
    except getopt.GetoptError, err:
        log.error(str(err))
        usage()
        sys.exit(2)

    postmaster_pid = None
    pgdata = None
    debug = None

    for o, a in opts:
        if o in ("-D", "--pgdata"):
            pgdata = a
        elif o in ("-P", "--pid"):
            postmaster_pid = int(a)
        elif o in ("--debug"):
            debug = True
            log.setLevel(log.DEBUG)
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            log.error("unknown option: " + o + "," + a)
            sys.exit(1)

    delay = None
    count = None

    if len(args) == 2:
        delay = int(args[0])
        count = int(args[1])
    elif len(args) == 1:
        delay = int(args[0])

    stat = PostgresProcessStat(pgdata=pgdata, pid=postmaster_pid, debug=debug)

    log.debug("postmaster pid = " + str(postmaster_pid))

    c = 0
    done = False
    while done is False:
        stat.update_stat()
        stat.print_stat()

        c = c + 1
        if count is not None and c >= count:
            break

        if delay is None:
            break

        try:
            time.sleep(delay)
        except KeyboardInterrupt, err:
            log.info("Terminated.")
            break

    sys.exit(0)
