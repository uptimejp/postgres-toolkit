#!/usr/bin/env python
# coding: UTF-8

# testDirectoryTree
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import unittest
import os
import DirectoryTree

class TestDirectoryTree(unittest.TestCase):
    def setUp(self):
        os.system("rm -rf t1")
        os.system("mkdir -p t1/t2/t3")
        os.system("touch t1/a t1/t2/b t1/t2/t3/c")

    def testDirectoryTree001(self):
        d = DirectoryTree.DirectoryTree('t1', debug=False)

        l = d.get_file_list()
#        print(l)

        self.assertTrue(d is not None)
        self.assertTrue(len(l) == 1)
        self.assertEqual(l[0], 't1/a')

    def testDirectoryTree002(self):
        d = DirectoryTree.DirectoryTree('t1', recursive=True, debug=False)

        l = d.get_file_list()
#        print(sorted(l))

        self.assertTrue(d is not None)
        self.assertTrue(len(l) == 3)
        self.assertEqual(sorted(l)[0], 't1/a')
        self.assertEqual(sorted(l)[1], 't1/t2/b')
        self.assertEqual(sorted(l)[2], 't1/t2/t3/c')

    def testDirectoryTree003(self):
        d = DirectoryTree.DirectoryTree('t1/a', recursive=False, debug=True)

        l = d.get_file_list()
#        print(sorted(l))

        self.assertTrue(d is not None)
        self.assertTrue(len(l) == 1)
        self.assertEqual(sorted(l)[0], 't1/a')

    def _tearDown(self):
        print("teardown")

if __name__ == '__main__':
    unittest.main()
