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

from errors import ConnectionError, QueryError
import log


class Field():
    def __init__(self, value):
        self.value = value

    def is_number(self):
        try:
            float(self.value)
            return True
        except Exception as ex:
            pass
        return False

    def format(self, width, is_header=False):
        s = str(self.value)
        if is_header:
            return s.center(width)
        if self.is_number():
            return s.rjust(width)
        return s.ljust(width)


class ResultFormatter():
    def __init__(self, resultset):
        self.resultset = resultset
        self.get_column_widths()

    def get_column_widths(self):
        self.widths = None
        for row in self.resultset:
            if not self.widths:
                # Get initial widths.
                log.debug(row)
                self.widths = [len(col) for col in row]
                continue

            # Update with longer ones.
            for i, col in enumerate(row):
                log.debug(row)
                self.widths[i] = max(self.widths[i], len(col))

        return self.widths

    def format_separator(self):
        return '+-{0}-+'.format('-+-'.join(['-' * w for w in self.widths]))

    def format_row(self, row, is_header=False):
        if len(row) != len(self.widths):
            return None

        buf = []
        for c, w in zip(row, self.widths):
            f = Field(c)
            buf.append(f.format(w, is_header))
        return '| {0} |'.format(' | '.join(buf))


    def format_resultset(self):
        if not self.resultset:
            return '(nothing to be displayed)'

        sep = self.format_separator()

        lines = []
        for i, r in enumerate(self.resultset):
            assert len(r) == len(self.widths)

            if i == 0:
                lines.append(sep)
            lines.append(self.format_row(r, (i == 0)))
            if i == 0:
                lines.append(sep)
        lines.append(sep)
        return '\n'.join(lines) + '\n'


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

    # FIXME:
    # backward compatibility. needs to be eliminated.
    def get_version(self):
        return self.major_version

    @property
    def major_version(self):
        rs = self.execute_query('select version()')
        return PsqlWrapper.parse_major_version(rs[1][0])

    @staticmethod
    def parse_major_version(s):
        m = re.search('PostgreSQL (\d+\.\d+)', s)
        ver = float(m.group(1))
        if ver >= 10:
            return int(ver)
        return ver

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
        except psycopg2.ProgrammingError as ex:
            if ignore_error:
                return None
            raise QueryError(str(ex))

        rs = []
        rs.append([desc[0] for desc in cur.description])
        for r in cur.fetchall():
            rr = [str(v) if v else '' for v in r]
            rs.append(rr)

        self.disconnect()

        return rs

    def print_result(self, rs):
        formatter = ResultFormatter(rs)
        print(formatter.format_resultset())
