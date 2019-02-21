#!/bin/env python
# coding: UTF-8

# PsqlWrapper
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import os
import re
import subprocess
import sys

import psycopg2

from errors import ConnectionError
import log


def parse_version(s):
    m = re.search('PostgreSQL (\d+\.\d+)', s)
    ver = float(m.group(1))
    if ver >= 10:
        return int(ver)
    return ver


def get_column_widths(rs):
    widths = None
    for row in rs:
        if not widths:
            # Get initial widths.
            log.debug(row)
            widths = [len(col) for col in row]
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
        self.conn = None

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

    @property
    def connection_string(self):
        params = []
        if self.host:
            params.append('host=%s' % self.host)
        if self.port:
            params.append('port=%s' % self.port)
        if self.dbname:
            params.append('dbname=%s' % self.dbname)
        if self.username:
            params.append('user=%s' % self.username)
        return ' '.join(params)

    def connect(self):
        try:
            self.conn = psycopg2.connect(self.connection_string)
            return True
        except psycopg2.OperationalError as ex:
            raise ConnectionError(str(ex))
        except psycopg2.ProgrammingError as ex:
            raise ConnectionError(str(ex))
        assert False

    def disconnect(self):
        if not self.conn:
            return False

        try:
            self.conn.close()
            self.conn = None
            return True
        except psycopg2.OperationalError as ex:
            raise ConnectionError(str(ex))
        assert False

    def execute_query(self, query, ignore_error=False):
        log.debug(self.connection_string)

        self.connect()

        try:
            cur = self.conn.cursor()
            cur.execute(query)
        except Exception as ex:
            log.error(str(ex))
            if ignore_error:
                return None
            sys.exit(1)

        rs = []
        rs.append([desc[0] for desc in cur.description])
        for r in cur.fetchall():
            rr = [str(v) if v else '' for v in r]
            rs.append(rr)

        self.disconnect()

        return rs

    def print_result(self, rs):
        print format_resultset(rs)
