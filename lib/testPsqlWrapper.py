#!/usr/bin/env python
# coding: UTF-8

# testPsqlWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import unittest
import os
import PsqlWrapper

class TestPsqlWrapper(unittest.TestCase):
    def _setUp(self):
        print("setup")

    def testPsqlWrapper001(self):
        p = PsqlWrapper.PsqlWrapper(None, None, None, None)

        self.assertTrue(p is not None)
        self.assertEqual(p.host, 'localhost')
        self.assertEqual(p.port, 5432)
        self.assertEqual(p.username, os.environ['USER'])
        self.assertEqual(p.dbname, p.username)

    def testPsqlWrapper002(self):
        p = PsqlWrapper.PsqlWrapper('localhost', '5432', 'postgres', 'postgres')

        self.assertTrue(p is not None)
        self.assertEqual(p.host, 'localhost')
        self.assertEqual(p.port, 5432)
        self.assertEqual(p.username, 'postgres')
        self.assertEqual(p.dbname, 'postgres')

    def testPsqlWrapper003(self):
        os.environ['PGHOST'] = '127.0.0.1'
        os.environ['PGPORT'] = '5433'
        os.environ['PGUSER'] = 'username'
        os.environ['PGDATABASE'] = 'dbname'

        p = PsqlWrapper.PsqlWrapper(None, None, None, None)

        self.assertTrue(p is not None)
        self.assertEqual(p.host, '127.0.0.1')
        self.assertEqual(p.port, 5433)
        self.assertEqual(p.username, 'username')
        self.assertEqual(p.dbname, 'dbname')

    def testPsqlWrapper004(self):
        os.environ['PGHOST'] = '127.0.0.1'
        os.environ['PGPORT'] = '5433'
        os.environ['PGUSER'] = 'username'
        os.environ['PGDATABASE'] = 'dbname'

        p = PsqlWrapper.PsqlWrapper('localhost', '5432', 'postgres', 'postgres')

        self.assertTrue(p is not None)
        self.assertEqual(p.host, 'localhost')
        self.assertEqual(p.port, 5432)
        self.assertEqual(p.username, 'postgres')
        self.assertEqual(p.dbname, 'postgres')

    def _tearDown(self):
        print("teardown")

if __name__ == '__main__':
    unittest.main()
