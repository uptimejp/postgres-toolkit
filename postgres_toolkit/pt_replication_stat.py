#!/usr/bin/env python
# coding: UTF-8

# pt-replication-stat
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import copy
import getopt
import os
import sys
import time

import PsqlWrapper
import log


class ReplicationStatistics:
    def __init__(self, psql, debug=False):
        self.debug = debug
        self.psql = psql
        self.header = None

    def get(self):
        if self.psql.get_version() == 9.0:
            log.error("PostgreSQL 9.0 is not supported.")
            sys.exit(1)

        pidcol = "pid"

        if self.psql.get_version() == 9.1:
            pidcol = "procpid"

        query = ' \
select null as "PID", \
       null as "NAME", \
       null as "HOST", \
       null as "PORT", \
       \'local\' as "STATE", \
       pg_current_xlog_insert_location() as "SENT", \
       pg_current_xlog_location() as "WRITTTEN", \
       null as "FLUSHED", \
       null as "REPLAYED", \
       null as "PRI", \
       \'master\' as "MODE" \
union all \
select %s, \
       application_name as name, \
       client_addr as addr, \
       client_port as port, \
       state, \
       sent_location as sent, \
       write_location as write, \
       flush_location as flush, \
       replay_location as reply, \
       sync_priority as pri, \
       sync_state as mode \
  from pg_stat_replication \
;' % pidcol

        log.debug(query)

        rs = p.execute_query(query)
        if rs is None or len(rs) == 0:
            log.error("Cannot retreive statitics from the server. "
                      "Connecting to wrong server?")
            sys.exit(1)
        else:
            p.print_result(rs)

        print("")

        return True


def usage():
    print '''
Usage: {0} [option...] [delay [count]]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:U:d:",
                                   ["help", "debug", "host=", "port=",
                                    "username=", "dbname="])
    except getopt.GetoptError, err:
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
            log.setLevel(log.DEBUG)
            debug = True
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(1)

    delay = None
    count = None

    if len(args) >= 1:
        delay = int(args[0])
    if len(args) >= 2:
        count = int(args[1])

    p = PsqlWrapper.PsqlWrapper(host=host, port=port,
                                username=username,
                                dbname=dbname, debug=debug)

    i = 0
    while True:
        os.system("date")
        stat = ReplicationStatistics(p, debug=debug)
        stat.get()
        i = i + 1

        if delay is None:
            break

        if count is not None and i >= count:
            break

        try:
            time.sleep(delay)
        except KeyboardInterrupt, err:
            log.info("Terminated.")
            break

    sys.exit(0)
