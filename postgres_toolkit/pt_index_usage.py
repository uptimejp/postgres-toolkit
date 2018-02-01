#!/usr/bin/env python
# coding: UTF-8

# pt-index-usage
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import getopt
import os
import sys

import PsqlWrapper


class IndexUsage:
    def build_where_clause(self, where_clause, cond):
        if where_clause is None:
            where_clause = " where "
        else:
            where_clause = where_clause + " and "
        where_clause = where_clause + " " + cond
        return where_clause

    def __init__(self, psql, owner, schema, table, index, unused, debug=False):
        self.debug = debug

        self.psql = psql

        where_clause = None

        if schema is not None:
            if schema.startswith('/') and schema.endswith('/'):
                # regexp
                cond = "s.schemaname ~ '" + schema[1:len(schema)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "s.schemaname = '" + schema + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if owner is not None:
            if owner.startswith('/') and owner.endswith('/'):
                # regexp
                cond = "u.usename ~ '" + owner[1:len(owner)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "u.usename = '" + owner + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if table is not None:
            if table.startswith('/') and table.endswith('/'):
                # regexp
                cond = "s.relname ~ '" + table[1:len(table)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "s.relname = '" + table + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if index is not None:
            if index.startswith('/') and index.endswith('/'):
                # regexp
                cond = "s.indexrelname ~ '" + index[1:len(index)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "s.indexrelname = '" + index + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if unused is True:
            where_clause = self.build_where_clause(where_clause,
                                                   "idx_scan = 0")

        if where_clause is None:
            where_clause = ''

        # indislive: 9.3 or later
        indislive = ''
        if self.psql.get_version() >= 9.3:
            indislive = " || case when indislive then ',' else 'NOTLIVE' end "

        self.query = '''
select
    s.indexrelid as "OID",
    u.usename as "OWNER",
    s.schemaname as "SCHEMA",
    s.relname as "TABLE",
    s.indexrelname as "INDEX",
    pg_relation_size(s.indexrelid)/8192 as "BLKS",
    idx_scan as "SCAN",
    idx_tup_read as "T_READ",
    idx_tup_fetch as "T_FTCH",
    idx_blks_read as "B_READ",
    idx_blks_hit as "B_HIT",
    regexp_replace(
       case when indisvalid then ',' else 'INVALID,' end ||
       case when indisready then ',' else 'NOTREADY,' end
       %s ,
         ',+$', '') as "STATUS",
    coalesce(spcname, (select spcname
                         from pg_database d left outer join pg_tablespace t
                                on dattablespace = t.oid
                        where datname = current_database()
                      )
            ) as "TABLESPACE"
  from
    pg_stat_user_indexes s left outer join pg_statio_user_indexes s2
                               on s.indexrelid = s2.indexrelid
                           left outer join pg_index i
                               on s.indexrelid = i.indexrelid
                           left outer join pg_class c
                               on s.indexrelid = c.oid
                           left outer join pg_user u
                               on c.relowner = u.usesysid
                           left outer join pg_tablespace t
                               on c.reltablespace = t.oid
%s
 order by
    2,3,4
;''' % (indislive, where_clause)

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

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name
    -i, --index=STRING         Index name

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:U:d:o:n:t:i:u",
                                   ["help", "debug", "host=", "port=",
                                    "username=", "dbname=",
                                    "owner=", "schema=", "table=",
                                    "index=", "unused"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    host = None
    port = None
    username = None
    dbname = None

    owner = None
    schema = None
    table = None
    index = None
    unused = False

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
        elif o in ("-o", "--owner"):
            owner = a
        elif o in ("-n", "--schema"):
            schema = a
        elif o in ("-t", "--table"):
            table = a
        elif o in ("-i", "--index"):
            index = a
        elif o in ("-u", "--unused"):
            unused = True
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

    iu = IndexUsage(p, owner, schema, table, index, unused, debug=debug)
    if iu.get() is False:
        sys.exit(1)

    sys.exit(0)
