#!/usr/bin/env python
# coding: UTF-8

# pt-table-usage
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import os
import sys

import PsqlWrapper
import getopt


class TableUsage:
    def build_where_clause(self, where_clause, cond):
        if where_clause is None:
            where_clause = " where "
        else:
            where_clause = where_clause + " and "
        where_clause = where_clause + " " + cond
        return where_clause

    def __init__(self, psql, owner, schema, table, debug=False):
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

        if where_clause is None:
            where_clause = ''

        self.query = '''
select
       s.relid as "OID",
       u.usename as "OWNER",
       s.schemaname "SCHEMA",
       s.relname AS "TABLE",
       pg_relation_size(s.relid)/8192 AS "BLKS",
       seq_scan AS "SCAN",
       seq_tup_read AS "T_READ",
       n_tup_ins AS "T_INS",
       n_tup_upd AS "T_UPD",
       n_tup_del AS "T_DEL",
       heap_blks_read AS "B_READ",
       heap_blks_hit AS "B_HIT",
/* n_tup_hot_upd AS "T_HUPD",
 n_live_tup AS "T_LIVE",
 n_dead_tup AS "T_DEAD", */
 to_char(CASE WHEN last_vacuum IS NULL THEN last_autovacuum
      WHEN last_autovacuum IS NULL THEN last_vacuum
      WHEN last_vacuum > last_autovacuum THEN last_vacuum
      ELSE last_autovacuum END, \'YYYY-MM-DD HH24:MI:SS\') AS "VACUUMED",
 to_char(CASE WHEN last_analyze IS NULL THEN last_autoanalyze
      WHEN last_autoanalyze IS NULL THEN last_analyze
      WHEN last_analyze > last_autoanalyze THEN last_analyze
      ELSE last_autoanalyze END, \'YYYY-MM-DD HH24:MI:SS\') AS "ANALYZED",
      coalesce(spcname, (select spcname
                           from pg_database d left outer join pg_tablespace t
                                  on dattablespace = t.oid
                          where datname = current_database()
                        )
              ) as "TABLESPACE"
  from
       pg_stat_user_tables s left outer join pg_statio_user_tables s2
            on s.relid = s2.relid
                             left outer join pg_class c
            on s.relid = c.oid
                             left outer join pg_user u
            on c.relowner = u.usesysid
                             left outer join pg_tablespace t
            on c.reltablespace = t.oid
{0}
 order by
    2,3,4
;'''.format(where_clause)

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

    --help                     Print this help.

'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:U:d:o:n:t:i:u",
                                   ["help", "debug", "host=", "port=",
                                    "username=", "dbname=",
                                    "owner=", "schema=", "table="])
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

    iu = TableUsage(p, owner, schema, table, debug=debug)
    if iu.get() is False:
        sys.exit(1)

    sys.exit(0)
