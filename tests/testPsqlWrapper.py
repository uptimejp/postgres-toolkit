#!/usr/bin/env python
# coding: UTF-8

# testPsqlWrapper
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import os
import sys
import unittest
sys.path.append('../postgres_toolkit')

import psycopg2

import PsqlWrapper
from errors import ConnectionError, QueryError


class TestPsqlWrapper(unittest.TestCase):
    def setUp(self):
        os.environ['PGHOST'] = ''
        os.environ['PGPORT'] = ''
        os.environ['PGUSER'] = ''
        os.environ['PGDATABASE'] = ''
        del os.environ['PGHOST']
        del os.environ['PGPORT']
        del os.environ['PGUSER']
        del os.environ['PGDATABASE']

    def test_PsqlWrapper_001(self):
        # Use the arguments.
        p = PsqlWrapper.PsqlWrapper('a', 1, 'b', 'c')

        self.assertIsNotNone(p)
        self.assertEquals('a', p.host)
        self.assertEquals(1, p.port)
        self.assertEquals('b', p.username)
        self.assertEquals('c', p.dbname)

    def test_PsqlWrapper_002(self):
        # Use the default values.
        p = PsqlWrapper.PsqlWrapper(None, None, None, None)

        self.assertIsNotNone(p)
        self.assertIsNone(p.host)
        self.assertIsNone(p.port)
        self.assertIsNone(p.username)
        self.assertIsNone(p.dbname)

    def test_parse_major_version_001(self):
        s = 'PostgreSQL 9.6.6 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-16), 64-bit'
        self.assertEquals(9.6,  PsqlWrapper.PsqlWrapper.parse_major_version(s))

        s = 'PostgreSQL 10.1 on x86_64-pc-linux-gnu, compiled by gcc (GCC) 4.8.5 20150623 (Red Hat 4.8.5-16), 64-bit'
        self.assertEquals(10,  PsqlWrapper.PsqlWrapper.parse_major_version(s))

    def test_major_version_001(self):
        vers = [9.3, 9.4, 9.5, 9.6, 10]

        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')

        self.assertTrue(p.major_version in vers)

    def test_get_version_001(self):
        vers = [9.3, 9.4, 9.5, 9.6, 10]

        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')

        self.assertTrue(p.get_version() in vers)

    def test_connection_string(self):
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')

        self.assertEquals('host=localhost port=5432 dbname=postgres user=postgres',
                          p.connection_string)

    def test_connect(self):
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        self.assertTrue(p.connect())

        p = PsqlWrapper.PsqlWrapper('localhost', 5433, 'postgres', 'postgres')
        with self.assertRaises(ConnectionError) as cm:
            p.connect()
        self.assertEquals('Connection Error: could not connect to server: Connection refused',
                          str(cm.exception).split('\n')[0])

    def test_disconnect(self):
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        self.assertTrue(p.connect())

        self.assertTrue(p.disconnect())
        self.assertFalse(p.disconnect())

    def test_execute_query_001(self):
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        rs = p.execute_query('select 1 as c')
        self.assertEquals([['c'], ['1']], rs)

    def test_execute_query_002(self):
        # stop with query error
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        with self.assertRaises(QueryError) as cm:
            p.execute_query('a')
        self.assertEquals('Query Error: syntax error at or near "a"',
                          str(cm.exception).split('\n')[0])

        # empty result on query error with `ignore_error' option
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        self.assertIsNone(p.execute_query('a', ignore_error=True))

    def test_execute_query_003(self):
        # connection failed.
        p = PsqlWrapper.PsqlWrapper('localhost', 5444, 'postgres', 'postgres')
        with self.assertRaises(ConnectionError) as cm:
            p.execute_query('select 1 as c')
        self.assertEquals('Connection Error: could not connect to server: Connection refused',
                          str(cm.exception).split('\n')[0])

    def test_get_column_widths_001(self):
        rs = [['c', 'd'], ['111', '22222']]
        widths = PsqlWrapper.get_column_widths(rs)
        self.assertEquals([3, 5], widths)

    def test_is_number_001(self):
        self.assertTrue(PsqlWrapper.is_number('10001'))
        self.assertTrue(PsqlWrapper.is_number('1.001'))
        self.assertFalse(PsqlWrapper.is_number(''))
        self.assertFalse(PsqlWrapper.is_number('a'))
        self.assertFalse(PsqlWrapper.is_number(None))

    def test_format_row_001(self):
        widths = [3, 8]
        self.assertEquals('|  c  |    d     |',
                          PsqlWrapper.format_row(['c', 'd'], widths, is_header=True))

        self.assertEquals('| 111 |    22.22 |',
                          PsqlWrapper.format_row(['111', '22.22'], widths))

        self.assertEquals('| None | None     |',
                          PsqlWrapper.format_row([None, None], widths))

        self.assertIsNone(PsqlWrapper.format_row(['(1 row)'], widths))

    def test_format_resultset_001(self):
        rs = [['c', 'ddddddddd'],
              ['111', '22.22']]
        self.assertEquals('''+-----+-----------+
|  c  | ddddddddd |
+-----+-----------+
| 111 |     22.22 |
+-----+-----------+
''',
                          PsqlWrapper.format_resultset(rs))

        self.assertEquals('(nothing to be displayed)',
                          PsqlWrapper.format_resultset(None))

    def test_print_result_001(self):
        p = PsqlWrapper.PsqlWrapper('localhost', 5432, 'postgres', 'postgres')
        rs = [['c', 'ddddddddd'],
              ['111', '22.22']]
        p.print_result(rs)


if __name__ == '__main__':
    unittest.main()
