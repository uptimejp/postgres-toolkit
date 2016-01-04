#!/bin/env python
# coding: UTF-8

# PsqlWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import log
import os
import re
import subprocess
import sys


class PsqlWrapper:
    version = None

    def __init__(self, host, port, username, dbname, on_error_stop=False, debug=False):
        if debug is True:
            log.setLevel(log.DEBUG)

        self.host     = host     or os.getenv("PGHOST")     or "localhost"
        self.port     = int(port or os.getenv("PGPORT")     or 5432)
        self.username = username or os.getenv("PGUSER")     or os.getenv("USER")
        self.dbname   = dbname   or os.getenv("PGDATABASE") or self.username

        log.debug("host:   %r", self.host)
        log.debug("port:   %r", self.port)
        log.debug("user:   %r", self.username)
        log.debug("dbname: %r", self.dbname)

        self.on_error_stop = on_error_stop

    def get_version(self):
        if self.version is None:
            rs = self.execute_query('select version()')
#            print(rs[1])
            m = re.search('PostgreSQL (\d+\.\d+)', rs[1][0])

            self.version = float(m.group(1))

        return self.version

    def execute_query(self, query, ignore_error=False):
        cmd = "psql -A -h {h} -p {p} -U {U} -d {d}".format(
            h=self.host, p=self.port, U=self.username, d=self.dbname)
        if self.on_error_stop is True:
            cmd += " --set=ON_ERROR_STOP=on"

        log.debug(cmd)

        pipe = subprocess.PIPE
        p = subprocess.Popen(cmd, shell=True,
                             stdin=pipe, stdout=pipe, stderr=pipe)
        stdout_data, stderr_data = p.communicate(input=query)

        self.stderr_data = stderr_data

        if p.returncode != 0:
            if ignore_error is True:
                log.debug("return code: " + str(p.returncode))
                log.debug(stderr_data)
                return None
            else:
                log.debug("return code: " + str(p.returncode))
                log.error("Failed to execute psql. (" + cmd + ")")
                if stderr_data is not None:
                    log.error(stderr_data.replace('\n',''))
                sys.exit(1)

        lines = stdout_data.splitlines()
        rs = [ line.split('|') for line in lines ]

        return rs

    def print_result(self, rs):
        size = cols = None
        for r in rs:
            if size is None:
                assert cols is None
                size = [ len(c) for c in r ]
                cols = len(r)
            elif len(r) == cols:
                for i, c in enumerate(r):
                    size[i] = max(size[i], len(c))

#        print size

        header = True
        sep2 = None
        for r in rs:
            if len(r) != cols:
                continue

            buf = []
            for i, c in enumerate(r):
                s = str(c)
                if header:
                    s = s.center(size[i])
                elif re.match('^\d+$', s):   # integer
                    s = s.rjust(size[i])
                else:                        # string
                    s = s.ljust(size[i])
                buf.append(s)
            out = '| %s |' % (' | '.join(buf))

            if header:
                sep = '-+-'.join([ '-' * n for n in size ])
                sep = '+-%s-+' % sep

            if header:
                sep2 = sep
                print sep2

            print out

            if header:
                print sep2
                header = False

        print sep2
