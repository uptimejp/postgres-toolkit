#!/usr/bin/env python
# coding: UTF-8

# pt-show-locks
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import getopt
import os
import sys

import PsqlWrapper


class ShowLastAnalyzed:
    def __init__(self, psql, debug=False):
        self.debug = debug

        self.psql = psql

        self.query = '''
select
  schemaname as "SCHEMA",
  relname as "TABLE",
  case
    when last_analyze is null then last_autoanalyze
    when last_autoanalyze is null then last_analyze
    when last_autoanalyze > last_analyze then last_autoanalyze
    else last_analyze
  end "LAST_ANALYZED"
from
  pg_stat_user_tables
order by
  3 nulls first;
'''

        if self.debug is True:
            print self.query

    def get(self):
        rs = self.psql.execute_query(self.query)

        self.psql.print_result(rs)

        return True


def usage():
    print '''
Usage: {0} [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:U:d:o:n:t:i:u",
                                   ["help", "debug", "host=", "port=",
                                    "username=", "dbname=",
                                    "owner=", "schema=", "table="])
    except getopt.GetoptError as ex:
        print str(err)
        usage()
        sys.exit(2)

    host = None
    port = None
    username = None
    dbname = None

    debug = None

    for o, a in opts:
        if o in ("-h", "--host"):
            host = a
        elif o in ("-p", "--port"):
            port = int(a)
        elif o in ("-U", "--username"):
            username = a
        elif o in ("-d", "--dbname"):
            dbname = a
        elif o in ("--debug"):
            debug = True
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(1)

    p = PsqlWrapper.PsqlWrapper(host=host, port=port, username=username,
                                dbname=dbname, debug=debug)

    last_analyzed = ShowLastAnalyzed(p, debug=debug)
    if not last_analyzed.get():
        sys.exit(1)

    sys.exit(0)
