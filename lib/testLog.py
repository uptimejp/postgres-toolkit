#!/usr/bin/env python
# coding: UTF-8

# testLog
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import unittest
import os
import log

class TestLog(unittest.TestCase):
    def _setUp(self):
        print("setup")

    def testSetLevel001(self):
        log.setLevel(log.INFO)

    def testDebug001(self):
        log.debug("debug")

    def testError001(self):
        log.error("error")

    def _tearDown(self):
        print("teardown")

if __name__ == '__main__':
    unittest.main()
