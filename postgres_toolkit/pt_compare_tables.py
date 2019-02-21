#!/usr/bin/env python
# coding: UTF-8

# pt-compare-tables
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import getopt
import os
import sys

from errors import QueryError
import PsqlWrapper


class CompareTables:
    def __init__(self, psql, debug=False):
        self.debug = debug
        self.psql = psql

    def get_column_names(self, table_name):
        if table_name.find('.') > 0:
            (s,t) = table_name.split('.', 1)
        else:
            s = 'public'
            t = table_name
        assert s
        assert t

        query = """
select
  relnamespace::regnamespace,
  relname::regclass,
  attname,
  attnum
from
  pg_attribute a,
  pg_class c
where
  relnamespace = '{0}'::regnamespace and
  attrelid = '{1}'::regclass and
  a.attrelid = c.oid and
  attnum > 0
order by
  attnum
""".format(s,t)

        try:
            rs = self.psql.execute_query(query)
        except QueryError as ex:
            print('ERROR: Could not get column names of the table.')
            print('HINT: ' + str(ex).split('\n')[0])
            return None
        column_names = []
        for i, row in enumerate(rs):
            if i == 0:
                continue
            column_names.append(row[2])
        return column_names

    def select_query(self, table_name):
        select_list = []
        for col in self.get_column_names(table_name):
            select_list.append('case when "{0}" is null then \'$$null$$\'::text else "{0}"::text end "{0}"'.format(col))
        query ="""
select
  {1}
from
  {0}
""".format(table_name, ',\n  '.join(select_list))
        return query

    def compare(self, table_name_1, table_name_2):
        select_query_1 = self.select_query(table_name_1)
        select_query_2 = self.select_query(table_name_2)

        rs = self.psql.execute_query(select_query_1 + '\n  EXCEPT\n' + select_query_2)
        for i, r in enumerate(rs):
            if i == 0:
                print(' ' + ','.join(r))
            else:
                print('-' + ','.join(r))

        rs = self.psql.execute_query(select_query_2 + '\n  EXCEPT\n' + select_query_1)
        for i, r in enumerate(rs):
            if i == 0:
                pass
            else:
                print('+' + ','.join(r))

    @staticmethod
    def main(argv):
        host = 'localhost'
        port = '5432'
        username = 'postgres'
        dbname = 'testdb'
        debug = False

        psql = PsqlWrapper.PsqlWrapper(host=host, port=port, username=username,
                                       dbname=dbname, debug=debug)
        cmd = CompareTables(psql, debug=debug)
        cmd.compare('public.temp1', 'public.temp2')

if __name__ == '__main__':
    CompareTables.main(sys.argv)
