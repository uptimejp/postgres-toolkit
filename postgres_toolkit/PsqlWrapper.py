#!/bin/env python
# coding: UTF-8

# PsqlWrapper
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import os
import re
import subprocess
import sys

import log


def parse_version(s):
    m = re.search('PostgreSQL (\d+\.\d+)', s)
    ver = float(m.group(1))
    if ver >= 10:
        return int(ver)
    return ver


def stdout2resultset(s):
    lines = s.splitlines()
    return [line.split('|') for line in lines]


def is_row_count_row(row):
    return (len(row) == 1 and
            ((row[0].startswith('(') and row[0].endswith(' row)')) or
             (row[0].startswith('(') and row[0].endswith(' rows)'))))


def get_column_widths(rs):
    widths = None
    for row in rs:
        if not widths:
            # Get initial widths.
            log.debug(row)
            widths = [len(col) for col in row]
            continue

        # ignore the '(? rows)' row.
        if is_row_count_row(row):
            continue

        # Update with longer ones.
        for i, col in enumerate(row):
            log.debug(row)
            widths[i] = max(widths[i], len(col))
    return widths


def is_number(s):
    try:
        float(s)
        return True
    except Exception as ex:
        pass
    return False


def format_row(row, widths, is_header=False):
    if len(row) != len(widths):
        return None

    buf = []
    for c, w in zip(row, widths):
        s = str(c)
        if is_header:
            s = s.center(w)
        elif is_number(s):
            s = s.rjust(w)
        else:
            s = s.ljust(w)
        buf.append(s)
    out = '| %s |' % (' | '.join(buf))
    return out


def format_resultset(rs):
    out_fmt = ''
    if rs is None:
        return '(nothing to be displayed)'

    widths = get_column_widths(rs)
    assert widths

    sep = '-+-'.join(['-' * w for w in widths])
    sep = '+-%s-+' % sep

    for i, r in enumerate(rs):
        if len(r) != len(widths):
            continue

        out = format_row(r, widths, (i == 0))

        if i == 0:
            out_fmt = out_fmt + sep + '\n'
            out_fmt = out_fmt + out + '\n'
            out_fmt = out_fmt + sep + '\n'
            continue

        out_fmt = out_fmt + out + '\n'
    out_fmt = out_fmt + sep + '\n'
    return out_fmt


class PsqlWrapper:
    version = None

    def __init__(self, host, port, username, dbname, on_error_stop=False,
                 debug=False):
        if debug:
            log.setLevel(log.DEBUG)

        self.host = host
        self.port = int(port) if port else None
        self.username = username
        self.dbname = dbname

        log.debug("host:   %r" % self.host)
        log.debug("port:   %r" % self.port)
        log.debug("user:   %r" % self.username)
        log.debug("dbname: %r" % self.dbname)

        self.on_error_stop = on_error_stop

        self.stdout_data = None
        self.stderr_data = None

    def get_version(self):
        if not self.version:
            rs = self.execute_query('select version()')
            self.version = parse_version(rs[1][0])
        return self.version

    def psql_cmd(self):
        # PsqlWrapper only cares about specified values by the user explicitly,
        # and other default values should be treated by psql properly.
        cmd = "psql -A"
        if self.host:
            cmd += " -h %s" % self.host
        if self.port:
            cmd += " -p %s" % self.port
        if self.username:
            cmd += " -U %s" % self.username
        if self.dbname:
            cmd += " -d %s" % self.dbname
        if self.on_error_stop:
            cmd += " --set=ON_ERROR_STOP=on"
        return cmd

    def execute_query(self, query, ignore_error=False):
        self.stdout_data = None
        self.stderr_data = None

        log.debug(self.psql_cmd())

        p = subprocess.Popen(self.psql_cmd(),
                             shell=True,
                             stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE)

        stdout_data, stderr_data = p.communicate(input=query)
        self.stdout_data = stdout_data
        self.stderr_data = stderr_data

        log.debug('stdout_data: ' + self.stdout_data)
        log.debug('stderr_data: ' + self.stderr_data)
        log.debug("return code: " + str(p.returncode))

        if ((self.stderr_data and self.stderr_data.startswith('ERROR: ')) or
                p.returncode != 0):
            if ignore_error:
                log.error(self.stderr_data.rstrip())
                return None
            else:
                # stop here.
                log.error(self.stderr_data.rstrip())
                sys.exit(1)

        return stdout2resultset(self.stdout_data)

    def print_result(self, rs):
        print format_resultset(rs)
