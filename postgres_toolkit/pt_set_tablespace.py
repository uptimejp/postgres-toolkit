#!/usr/bin/env python
# coding: UTF-8

# pt-set-tablespace
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import getopt
import os
import re
import subprocess
import sys

import PsqlWrapper
import log


class SetTablespace:
    alter_stmt = []

    def build_where_clause(self, where_clause, cond):
        if where_clause is None:
            where_clause = " where "
        else:
            where_clause = where_clause + " and "
        where_clause = where_clause + " " + cond
        return where_clause

    def __init__(self, psql, owner, schema, table, tablespace, debug=False):
        self.debug = debug

        self.psql = psql
        self.owner = owner
        self.schema = schema
        self.table = table

        self.tablespace = tablespace

    def build_where(self):
        where_clause = None

        if self.schema is not None:
            if self.schema.startswith('/') and self.schema.endswith('/'):
                # regexp
                cond = ("t.schemaname ~ '" +
                        self.schema[1:len(self.schema)-1] + "'")
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "t.schemaname = '" + self.schema + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if self.owner is not None:
            if self.owner.startswith('/') and self.owner.endswith('/'):
                # regexp
                cond = "u.usename ~ '" + self.owner[1:len(self.owner)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "u.usename = '" + self.owner + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if self.table is not None:
            if self.table.startswith('/') and self.table.endswith('/'):
                # regexp
                cond = "t.relname ~ '" + self.table[1:len(self.table)-1] + "'"
                where_clause = self.build_where_clause(where_clause, cond)
            else:
                # exact match
                cond = "t.relname = '" + self.table + "'"
                where_clause = self.build_where_clause(where_clause, cond)

        if where_clause is None:
            where_clause = ''

        return where_clause

    def alter_table(self):
        where_clause = self.build_where()

        self.query = '''
select
       t.relid,
       u.usename,
       t.schemaname,
       t.relname,
       s.spcname
  from
       pg_stat_user_tables t left outer join pg_class c
                on t.relid = c.oid
                             left outer join pg_tablespace s
                on c.reltablespace = s.oid
                             left outer join pg_user u
                on c.relowner = u.usesysid
{0}
 order by
    2,3,4
;'''.format(where_clause)

        log.debug(self.query)

        rs = self.psql.execute_query(self.query)

        row = 0
        for r in rs:
            if row > 0 and len(r) == 5:
                stmt = ('ALTER TABLE "%s"."%s" SET TABLESPACE "%s";' %
                        (r[2], r[3], self.tablespace))
                self.alter_stmt.append(stmt)
            row = row + 1

        if self.debug is True:
            self.psql.print_result(rs)

    def alter_index(self):
        where_clause = self.build_where()

        self.query = '''
select
       t.indexrelid,
       u.usename,
       t.schemaname,
       t.relname,
       t.indexrelname,
       s.spcname
  from
       pg_stat_user_indexes t left outer join pg_class c
                on t.indexrelid = c.oid
                             left outer join pg_tablespace s
                on c.reltablespace = s.oid
                             left outer join pg_user u
                on c.relowner = u.usesysid
{0}
;'''.format(where_clause)

        log.debug(self.query)

        rs = self.psql.execute_query(self.query)

        row = 0
        for r in rs:
            if row > 0 and len(r) == 6:
                stmt = ('ALTER INDEX "%s"."%s" SET TABLESPACE "%s";' %
                        (r[2], r[4], self.tablespace))
                self.alter_stmt.append(stmt)
            row = row + 1

        if self.debug is True:
            self.psql.print_result(rs)

    def apply(self, do_apply):
        self.alter_table()
        self.alter_index()

        if do_apply is True:
            log.info("Applying ALTER TABLE/INDEX...")
        else:
            log.info("Dry-run mode:")

        failed = 0
        succeeded = 0

        for s in self.alter_stmt:
            if do_apply is True:
                log.debug(s)

                rs = self.psql.execute_query(s)

                log.debug(str(rs))

                if rs is None or len(rs) == 0:
                    msg = str(self.psql.stderr_data)
                    log.error(msg.replace("ERROR: ", "").replace("\n", ""))
                    log.error("  " + s)
                    failed = failed + 1

                elif rs[0][0] != 'ALTER TABLE' and rs[0][0] != 'ALTER INDEX':
                    msg = str(self.psql.stderr_data)
                    log.error(msg.replace("ERROR: ", "").replace("\n", ""))
                    log.error("  " + s)
                    failed = failed + 1

                else:
                    succeeded = succeeded + 1
                    log.debug("Succeeded")

            else:
                log.info(s)

        if do_apply is True:
            log.info("%d tables/indexes moved. %d failed." %
                     (succeeded, failed))

        if failed > 0:
            return False

        return True


def tablespace_size(spcloc):
    log.debug("location: " + spcloc)

    if spcloc is None or len(spcloc) == 0:
        return ['', '']

    cmd = ("df -khPl " + re.sub('/[^/]+$', '', spcloc) +
           " | grep ^/ | awk '{ print $5 \" \" $4 }'")

    p = subprocess.Popen([cmd], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE, shell=True)
    p.wait()

    if p.returncode != 0:
        log.error("Cannot execute df command.")
        sys.exit(1)

    line = None
    for l in p.stdout.readlines():
        if line is None:
            line = l.replace('\n', '')
        break

    return str(line).split(' ')


def list_tablespace(psql):
    if psql.get_version() <= 9.1:
        query = '''
select s.oid as "OID",
       usename as "OWNER",
       spcname as "TABLESPACE",
       spclocation as "LOCATION",
       null as "USE%",
       null as "AVAIL"
  from pg_tablespace s left outer join pg_user u
           on s.spcowner = u.usesysid;
'''
    else:
        query = '''
select s.oid as "OID",
       usename as "OWNER",
       spcname as "TABLESPACE",
       pg_tablespace_location(s.oid) as "LOCATION",
       null as "USE%",
       null as "AVAIL"
  from pg_tablespace s left outer join pg_user u
           on s.spcowner = u.usesysid;
'''

    rs = psql.execute_query(query)

    for r in rs:
        if len(r) >= 3 and len(r[3]) > 0 and r[3] != 'LOCATION':
            a = tablespace_size(r[3])
            r[4] = a[0]
            r[5] = a[1]

    psql.print_result(rs)


def usage():
    print '''
Usage: {0} [option...] [tablespace]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name

    -l, --list                 List table spaces
    --apply                    Apply change(s)

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:U:d:o:n:lt:i:u",
                                   ["help", "debug", "host=", "port=",
                                    "username=", "dbname=",
                                    "owner=", "schema=", "table=", "list",
                                    "apply"])
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

    do_list = False
    do_apply = False

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
        elif o in ("-l", "--list"):
            do_list = True
        elif o in ("--apply"):
            do_apply = True
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

    # list tablespaces and exit.
    if do_list is True:
        list_tablespace(p)
        sys.exit(0)

    if len(args) == 1:
        tablespace = args[0]
    else:
        usage()
        sys.exit(0)

    cmd = SetTablespace(p, owner, schema, table, tablespace, debug=debug)

    if cmd.apply(do_apply) is False:
        sys.exit(1)

    sys.exit(0)
