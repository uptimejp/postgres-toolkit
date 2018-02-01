#!/usr/bin/env python
# coding: UTF-8

# testTcpdumpWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import os
import sys
import unittest
sys.path.append('../postgres_toolkit')

import TcpdumpWrapper
import log


class TestTcpdmpWrapper(unittest.TestCase):
    def testTcpdumpWrapper001(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap')
        self.assertIsNotNone(dump)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, '5432', 'lo', 'test.cap')
        self.assertIsNotNone(dump)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, None, 'lo', 'test.cap')
        self.assertIsNotNone(dump)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, None, None, 'test.cap')
        self.assertIsNotNone(dump)

    def testTcpdumpWrapper002(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertIsNotNone(dump)

        p = dump.get_packet()

        self.assertEquals('2015-04-30 12:48:12.366446', str(p.ts))
        self.assertEquals('localhost.55060', p.src)
        self.assertTrue(p.dst.startswith('localhost.postgres'))  # postgres or postgresql

    def testTcpdumpWrapper003(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertIsNotNone(dump)

        prev = None
        while True:
            p = dump.get_packet()
            if p is None:
                break
            log.debug(p)
            prev = p

        self.assertEquals('2015-04-30 12:48:12.413238', str(prev.ts))
        self.assertEquals('localhost.55061', prev.src)
        self.assertTrue(prev.dst.startswith('localhost.postgres'))  # postgres or postgresql

    def testTcpdumpWrapper004(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertIsNotNone(dump)

        p = dump.get_packet()

        self.assertEquals('74fbc116e01b', p.get_session_id())
        self.assertEquals('2015-04-30 12:48:12.366446', str(p.get_timestamp()))


if __name__ == '__main__':
    unittest.main()
