#!/usr/bin/env python2.7

import os
import time
import unittest
import re

from test_utils import execute, wc, grep

class TestPtTableUsage(unittest.TestCase):
    def setUp(self):
        os.environ['PGHOST'] = 'localhost'
        os.environ['PGPORT'] = '5432'
        os.environ['PGUSER'] = 'postgres'
        os.environ['PGDATABASE'] = 'testdb'

        t = execute("pgbench -i")
        self.assertEquals(0, t[0])

    def tearDown(self):
        pass

    def test_table_usage_001(self):
        expected = '''
Usage: pt-table-usage [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name

    --help                     Print this help.

'''
        t = execute("pt-table-usage --help")
        self.assertEquals(0, t[0])
        self.assertEquals(expected.split('\n'), t[1].split('\n'))

    def test_table_usage_002(self):
        time.sleep(1)

        t = execute("pt-table-usage")
#        print(t[1])
        self.assertEquals(0, t[0])

        self.assertEquals(1, len(grep(t[1], 'pgbench_accounts')))
        self.assertEquals(1, len(grep(t[1], 'pgbench_branches')))
        self.assertEquals(1, len(grep(t[1], 'pgbench_history')))
        self.assertEquals(1, len(grep(t[1], 'pgbench_tellers')))

        c = re.split(' +', grep(t[1], 'pgbench_accounts')[0])
#        print(c)
        self.assertEquals('1', c[11])       # SCAN
        self.assertEquals('100000', c[13])  # T_READ
        self.assertEquals('100000', c[15])  # T_INS
        self.assertEquals('0', c[17])       # T_UPD

        t = execute('psql', 'select * from pgbench_accounts')
        self.assertEquals(0, t[0])

        time.sleep(1)

        t = execute("pt-table-usage")
#        print(t[1])
        self.assertEquals(0, t[0])

        c = re.split(' +', grep(t[1], 'pgbench_accounts')[0])
#        print(c)
        self.assertEquals('2', c[11])       # SCAN
        self.assertEquals('200000', c[13])  # T_READ
        self.assertEquals('100000', c[15])  # T_INS
        self.assertEquals('0', c[17])       # T_UPD

    def test_table_usage_003(self):
        t = execute("pt-table-usage -p %s" % os.environ['PGPORT'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --port %s" % os.environ['PGPORT'])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_004(self):
        t = execute("pt-table-usage -U %s" % os.environ['PGUSER'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --username %s" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_005(self):
        t = execute("pt-table-usage -d %s" % os.environ['PGDATABASE'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --dbname %s" % os.environ['PGDATABASE'])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_006(self):
        t = execute("pt-table-usage -o %s" % os.environ['PGUSER'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --owner %s" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_007(self):
        t = execute("pt-table-usage -n public")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --schema public")
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_008(self):
        t = execute("pt-table-usage -t pgbench_accounts")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-table-usage --table pgbench_accounts")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

    def test_table_usage_009(self):
        t = execute("pt-table-usage -o /^%s$/" % os.environ['PGUSER'])
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --owner /^%s$/" % os.environ['PGUSER'])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_010(self):
        t = execute("pt-table-usage -n /c$/")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

        t = execute("pt-table-usage --schema /c$/")
        self.assertEquals(0, t[0])
        self.assertEquals(9, wc(t[1]))

    def test_table_usage_011(self):
        t = execute("pt-table-usage -t /ts$/")
#        print(t[1])
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))

        t = execute("pt-table-usage --table /ts$/")
        self.assertEquals(0, t[0])
        self.assertEquals(6, wc(t[1]))


if __name__ == '__main__':
    unittest.main()
