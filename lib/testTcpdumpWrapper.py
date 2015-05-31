#!/usr/bin/env python
# coding: UTF-8

# testTcpdumpWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import unittest
import os

import TcpdumpWrapper
import log

class TestTcpdmpWrapper(unittest.TestCase):

    def testTcpdumpWrapper001(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap')
        self.assertTrue(dump is not None)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, '5432', 'lo', 'test.cap')
        self.assertTrue(dump is not None)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, None, 'lo', 'test.cap')
        self.assertTrue(dump is not None)

        dump = TcpdumpWrapper.TcpdumpWrapper(None, None, None, 'test.cap')
        self.assertTrue(dump is not None)

    def testTcpdumpWrapper002(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertTrue(dump is not None)

        p = dump.get_packet()

        self.assertTrue(str(p.ts) == '2015-04-30 21:48:12.366446')
        self.assertTrue(p.src == 'localhost.55060')
        self.assertTrue(p.dst == 'localhost.postgres' or p.dst == 'localhost.postgresql')

    def testTcpdumpWrapper003(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertTrue(dump is not None)

        prev = None
        while True:
            p = dump.get_packet()
            if p is None:
                break
            log.debug(p)
            prev = p

        self.assertTrue(str(prev.ts) == '2015-04-30 21:48:12.413238')
        self.assertTrue(prev.src == 'localhost.55061')
        self.assertTrue(prev.dst == 'localhost.postgres' or prev.dst == 'localhost.postgresql')

    def testTcpdumpWrapper004(self):
        dump = TcpdumpWrapper.TcpdumpWrapper('127.0.0.1', '5432', 'lo', 'test.cap', debug=False)
        self.assertTrue(dump is not None)

        p = dump.get_packet()

        self.assertTrue(p.get_session_id() == '74fbc116e01b')
        self.assertTrue(str(p.get_timestamp()) == '2015-04-30 21:48:12.366446')

if __name__ == '__main__':
    unittest.main()
