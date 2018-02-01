#!/usr/bin/env python2.7

import os
import time
import unittest
import re

from test_utils import execute, wc, grep

class TestPtIndexUsage(unittest.TestCase):
    def setUp(self):
        os.environ['PGHOST'] = 'localhost'
        os.environ['PGPORT'] = '5432'
        os.environ['PGUSER'] = 'postgres'
        os.environ['PGDATABASE'] = 'testdb'

        t = execute("pgbench -i")
        self.assertEquals(0, t[0])

    def tearDown(self):
        pass

    def test_index_usage_001(self):
        expected = '''
Usage: pt-index-usage [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name
    -i, --index=STRING         Index name

    --help                     Print this help.

'''
        t = execute("pt-index-usage --help")
        self.assertEquals(0, t[0])
        self.assertEquals(expected.split('\n'), t[1].split('\n'))

    def test_index_usage_002(self):
        t = execute("reindexdb")
        self.assertEquals(0, t[0])

        t = execute("pt-index-usage")
#        print(t[1])
        self.assertEquals(0, t[0])

        c = re.split(' +', grep(t[1], 'pgbench_accounts_pkey')[0])
        self.assertEquals('0', c[13])  # SCAN
        self.assertEquals('0', c[15])  # T_READ
        self.assertEquals('0', c[17])  # T_FTCH

        t = execute("psql", 'select * from pgbench_accounts where aid = 1')
#        print(t[1])
        self.assertEquals(0, t[0])

        time.sleep(1)

        t = execute("pt-index-usage")
#        print(t[1])
        self.assertEquals(0, t[0])

        c = re.split(' +', grep(t[1], 'pgbench_accounts_pkey')[0])
        self.assertEquals('1', c[13])  # SCAN
        self.assertEquals('1', c[15])  # T_READ
        self.assertEquals('1', c[17])  # T_FTCH

    def test_index_usage_003(self):
        t = execute("pt-index-usage -p %s" % os.environ['PGPORT'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --port %s" % os.environ['PGPORT'])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_004(self):
        t = execute("pt-index-usage -U %s" % os.environ['PGUSER'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --username %s" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_005(self):
        t = execute("pt-index-usage -d testdb")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --dbname testdb")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_006(self):
        t = execute("pt-index-usage -o %s" % os.environ['PGUSER'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --owner %s" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_007(self):
        t = execute("pt-index-usage -n public")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --schema public")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_008(self):
        t = execute("pt-index-usage -t pgbench_accounts")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-index-usage --table pgbench_accounts")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

    def test_index_usage_009(self):
        t = execute("pt-index-usage -i pgbench_branches_pkey")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-index-usage --index pgbench_branches_pkey")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

    def test_index_usage_010(self):
        t = execute("pt-index-usage -u")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --unused")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_011(self):
        t = execute("pt-index-usage -o /^%s$/" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --owner /^%s$/" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_012(self):
        t = execute("pt-index-usage -n /c$/")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

        t = execute("pt-index-usage --schema /c$/")
        self.assertEquals(0, t[0])
        self.assertEquals(8, wc(t[1]))

    def test_index_usage_013(self):
        t = execute("pt-index-usage -t /.*ch_a.*s$/")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-index-usage --table /.*ch_a.*s$/")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

    def test_index_usage_014(self):
        t = execute("pt-index-usage -i /.*ch_a.*y$/")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-index-usage --index /.*ch_a.*y$/")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))


if __name__ == '__main__':
    unittest.main()
