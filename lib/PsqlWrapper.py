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

def get_host(host=None):
    if host is None:
        if os.environ.get("PGHOST") is not None:
            h = os.environ.get("PGHOST")
        else:
            h = 'localhost'
    else:
        h = host

    return h

def get_port(port=None):
    if port is None:
        if os.environ.get("PGPORT") is not None:
            p = int(os.environ.get("PGPORT"))
        else:
            p = 5432
    else:
        p = int(port)

    return p

def get_username(username=None):
    if username is None:
        if os.environ.get("PGUSER") is not None:
            u = os.environ.get("PGUSER")
        else:
            u = os.environ.get("USER")
    else:
        u = username

    return u

def get_dbname(dbname=None, username=None):
    if dbname is None:
        if os.environ.get("PGDATABASE") is not None:
            d = os.environ.get("PGDATABASE")
        else:
            d = username
    else:
        d = dbname

    return d

class PsqlWrapper:
    version = None

    def __init__(self, host, port, username, dbname, on_error_stop=False, debug=False):
        if debug is True:
            log.setLevel(log.DEBUG)

        self.host     = get_host(host)
        self.port     = get_port(port)
        self.username = get_username(username)
        self.dbname   = get_dbname(dbname, self.username)

        log.debug("host: " + self.host)
        log.debug("port: " + str(self.port))
        log.debug("user: " + self.username)
        log.debug("dbname: " + self.dbname)

        self.on_error_stop = on_error_stop

    def get_version(self):
        if self.version is None:
            rs = self.execute_query('select version()')
#            print(rs[1])
            m = re.search('PostgreSQL (\d+\.\d+)', rs[1][0])

            self.version = float(m.group(1))

        return self.version

    def execute_query(self, query, ignore_error=False):
        cmd = "psql -A"
        cmd = cmd + " -h " + self.host
        cmd = cmd + " -p " + str(self.port)
        cmd = cmd + " -U " + self.username
        cmd = cmd + " -d " + self.dbname
        if self.on_error_stop is True:
            cmd = cmd + " --set=ON_ERROR_STOP=on "

        log.debug(cmd)

        p = subprocess.Popen(cmd, shell=True,
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)
        stdout_data, stderr_data = p.communicate(input=query)
        p.returncode, stdout_data, stderr_data

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

        rs = []
        lines = re.split('\n', stdout_data)[:-1]
        for line in lines:
            rs.append(re.split('\|', line))

        return rs

    def print_result(self, rs):
        cols = len(rs[0])
        size = []

        header = True
        for r in rs:
            if len(r) != cols:
                continue

            i = 0
            for c in r:
                if header is True:
                    size.append(len(c))
                elif len(c) > size[i]:
                    size[i] = len(c)

#                print '[' + str(i) + ']' + c
                i = i + 1
            header = False

#        print size

        header = True
        sep2 = None
        for r in rs:
            if len(r) != cols:
                continue

            i = 0
            out = '|'
            sep = '+'
            for c in r:
                if header is True:
                    out = out + ' ' + str(c).center(size[i]) + ' |'
                    sep = sep + '-' + '-' * size[i] + '-+'
                elif re.match('^\d+$', str(c)):
                    out = out + ' ' + str(c).rjust(size[i]) + ' |'
                else:
                    out = out + ' ' + str(c).ljust(size[i]) + ' |'
                i = i + 1

            if header is True:
                sep2 = sep
                print sep2

            print out

            if header is True:
                print sep2
                header = False

        print sep2
