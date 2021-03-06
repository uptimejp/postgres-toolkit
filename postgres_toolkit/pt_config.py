#!/usr/bin/env python
# coding: UTF-8

# pt-config
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

from stat import *
import getopt
import os
import re
import sys

import log


class PostgressqlConf():
    fp = None

    def __init__(self, conffile):
        self.conffile = conffile
        log.info("Reading: " + self.conffile)

    def open(self):
        try:
            self.fp = open(self.conffile)
        except OSError, err:
            log.error(err.strerror + " (" + self.conffile + ")")
            sys.exit(1)
        except IOError, err:
            log.error(err.strerror + " (" + self.conffile + ")")
            sys.exit(1)

    def find(self, line, key):
        m = re.search(key + " *=", line[0:len(key) + 10])
        if m is not None:
            return True

        return False

    def is_disabled(self, line, key):
        m = re.search("#.*" + key + " *=", line[0:len(key) + 10])
        if m is not None:
            return True

        return False

    def parse(self, line):
        m = re.search("(.*=[ ]*')([^']+)('.*)", line)
        if m is None:
            m = re.search("(.*=[ ]*)([^ \t]+)(.*)", line)

        return [m.groups(0)[0], m.groups(0)[1], m.groups(0)[2]]

    def get(self, key):
        self.open()

        val = []
        for l in self.fp.readlines():
            l = l.rstrip('\r\n')

#            log.debug("readlines: " + l)

            if self.find(l, key) is True:
                log.debug("find: " + l)

                if self.is_disabled(l, key) is True:
                    log.debug("disabled: " + l)
                    a = self.parse(l)

                    # value and is_disabled?
                    val.append([a[1], True])

                else:
                    log.debug(l)
                    a = self.parse(l)

                    log.debug(a[1])

                    val.append([a[1], False])

        self.fp.close()

        # not found
        if len(val) == 0:
            return None

        return val

    def set(self, key, value, dryrun=True):
        self.open()

        lines = ""

        oldline = None
        newline = None
        for l in self.fp.readlines():
            l = l.rstrip('\r\n')

            if self.find(l, key) is True:
                oldline = l

                a = self.parse(l)
                l = a[0].replace('#', '') + value + a[2]

                newline = l

                log.debug("set: " + l)

            lines = lines + l + "\n"

        if oldline is None and newline is None:
            log.error("Parameter %s not found." % args[1])
            return False

        self.fp.close()

        if dryrun is True:
            log.info("Dry-run mode:")
            log.info("  Old: " + oldline)
            log.info("  New: " + newline)
            return True
        else:
            log.info("Applying:")
            log.info("  Old: " + oldline)
            log.info("  New: " + newline)

        return self.update_conf(lines)

    def disable(self, key, dryrun=True):
        self.open()

        lines = ""

        oldline = None
        newline = None
        for l in self.fp.readlines():
            l = l.rstrip('\r\n')

            if self.find(l, key) is True:
                oldline = l

                a = self.parse(l)
                l = '#' + a[0].replace('#', '') + a[1] + a[2]

                newline = l

                log.debug("set: " + l)

            lines = lines + l + "\n"

        self.fp.close()

        if oldline is None and newline is None:
            log.error("Parameter %s not found." % args[1])
            return False

        if dryrun is True:
            log.info("Dry-run mode:")
            log.info("  Old: " + oldline)
            log.info("  New: " + newline)
            return True
        else:
            log.info("Applying:")
            log.info("  Old: " + oldline)
            log.info("  New: " + newline)

        return self.update_conf(lines)

    def update_conf(self, conf):
        st = os.stat(self.conffile)
        log.debug(st)

        try:
            os.rename(self.conffile, self.conffile + ".bak")
        except OSError, err:
            log.error(err.strerror + " (" + self.conffile + ")")
            sys.exit(1)
        except IOError, err:
            log.error(err.strerror + " (" + self.conffile + ")")
            sys.exit(1)

        f = open(self.conffile, "w")
        f.write(conf)
        f.close()

        os.chmod(self.conffile, st[ST_MODE])

        # if running with superuser, the file owner/group need to be changed.
        if os.getuid() == 0:
            os.chown(self.conffile, st[ST_UID], st[ST_GID])

        log.info("Updated: " + self.conffile)

        return True


def usage():
    print '''
Usage: {0} [option...] [command] [param [value]]

Commands:
    get [PARAM]                Get a current value of a parameter.
    set [PARAM] [VALUE]        Set a new value for a parameter.
    disable [PARAM]            Comment a parameter out.

Options:
    -D, --pgdata=PGDATA        Specify a PostgreSQL database cluster.
    --apply                    Apply change(s).

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "D:",
                                   ["help", "debug", "pgdata=",
                                    "apply", "disable"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    pgdata = None
    if os.environ.get("PGDATA") is not None:
        pgdata = os.environ.get("PGDATA")

    dryrun = True
    debug = False

    for o, a in opts:
        if o in ("-D", "--pgdata"):
            pgdata = a
        elif o in ("--debug"):
            debug = True
            log.setLevel(log.DEBUG)
        elif o in ("--apply"):
            dryrun = False
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(1)

    if pgdata is None:
        log.info("Specify PGDATA directory.")
        usage()
        sys.exit(0)

    log.debug(args)
    if len(args) != 2 and len(args) != 3:
        usage()
        sys.exit(1)

    p = PostgressqlConf(pgdata + '/postgresql.conf')

    exit_code = 0

    if args[0] == 'get':
        v = p.get(args[1])
        if v is not None:
            for vv in v:
                if vv[1] is True:
                    print(vv[0] + " (disabled)")
                else:
                    print(vv[0])
            exit_code = 0
        else:
            log.error("Parameter %s not found." % args[1])
            exit_code = 1

    elif args[0] == 'set':
        if len(args) < 3:
            usage()
            sys.exit(1)

        r = p.set(args[1], args[2], dryrun)
        if r is True:
            exit_code = 0
        else:
            exit_code = 1

    elif args[0] == 'disable':
        r = p.disable(args[1], dryrun)
        if r is True:
            exit_code = 0
        else:
            exit_code = 1

    sys.exit(exit_code)
