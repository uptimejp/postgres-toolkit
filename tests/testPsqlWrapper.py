#!/usr/bin/env python
# coding: UTF-8

# testPsqlWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import os
import sys
import unittest
sys.path.append('../postgres_toolkit')

import PsqlWrapper


class TestPsqlWrapper(unittest.TestCase):
    def testPsqlWrapper001(self):
        p = PsqlWrapper.PsqlWrapper(None, None, None, None)

        self.assertIsNotNone(p)
        self.assertEqual('localhost', p.host)
        self.assertEqual(5432, p.port)
        self.assertEqual(os.environ['USER'], p.username)
        self.assertEqual(os.environ['USER'], p.dbname)

    def testPsqlWrapper002(self):
        p = PsqlWrapper.PsqlWrapper('localhost', '5432', 'postgres', 'postgres')

        self.assertIsNotNone(p)
        self.assertEqual('localhost', p.host)
        self.assertEqual(5432, p.port)
        self.assertEqual('postgres', p.username)
        self.assertEqual('postgres', p.dbname)

    def testPsqlWrapper003(self):
        os.environ['PGHOST'] = '127.0.0.1'
        os.environ['PGPORT'] = '5433'
        os.environ['PGUSER'] = 'username'
        os.environ['PGDATABASE'] = 'dbname'

        p = PsqlWrapper.PsqlWrapper(None, None, None, None)

        self.assertIsNotNone(p)
        self.assertEqual('127.0.0.1', p.host)
        self.assertEqual(5433, p.port)
        self.assertEqual('username', p.username)
        self.assertEqual('dbname', p.dbname)

    def testPsqlWrapper004(self):
        os.environ['PGHOST'] = '127.0.0.1'
        os.environ['PGPORT'] = '5433'
        os.environ['PGUSER'] = 'username'
        os.environ['PGDATABASE'] = 'dbname'

        p = PsqlWrapper.PsqlWrapper('localhost', '5432', 'postgres', 'postgres')

        self.assertIsNotNone(p)
        self.assertEqual('localhost', p.host)
        self.assertEqual(5432, p.port)
        self.assertEqual('postgres', p.username)
        self.assertEqual('postgres', p.dbname)


if __name__ == '__main__':
    unittest.main()
