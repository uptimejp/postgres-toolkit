#!/usr/bin/env python
# coding: UTF-8

# testDirectoryTree
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import os
import sys
import unittest
sys.path.append('../postgres_toolkit')

import DirectoryTree


class TestDirectoryTree(unittest.TestCase):
    def setUp(self):
        os.system("rm -rf t1")
        os.system("mkdir -p t1/t2/t3")
        os.system("touch t1/a t1/t2/b t1/t2/t3/c")

    def testDirectoryTree001(self):
        d = DirectoryTree.DirectoryTree('t1', debug=False)

        l = d.get_file_list()

        self.assertIsNotNone(d)
        self.assertEquals(1, len(l))
        self.assertEquals('t1/a', l[0])

    def testDirectoryTree002(self):
        d = DirectoryTree.DirectoryTree('t1', recursive=True, debug=False)

        l = d.get_file_list()

        self.assertIsNotNone(d)
        self.assertEquals(3, len(l))
        self.assertEquals(['t1/a', 't1/t2/b', 't1/t2/t3/c'], sorted(l))

    def testDirectoryTree003(self):
        d = DirectoryTree.DirectoryTree('t1/a', recursive=False, debug=True)

        l = d.get_file_list()

        self.assertIsNotNone(d)
        self.assertEquals(1, len(l))
        self.assertEquals(['t1/a'], l)


if __name__ == '__main__':
    unittest.main()
