#!/usr/bin/env python
# coding: UTF-8

# testLog
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import os
import sys
import unittest
sys.path.append('../postgres_toolkit')

import log


class TestLog(unittest.TestCase):
    def testSetLevel001(self):
        log.setLevel(log.INFO)

    def testDebug001(self):
        log.debug("debug")

    def testError001(self):
        log.error("error")


if __name__ == '__main__':
    unittest.main()
