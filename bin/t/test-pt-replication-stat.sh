#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

export PGDATABASE=testdb

. ./test_common.sh

function setUp()
{
#    echo "PATH=$PATH"
#    echo "PGHOME=$PGHOME"
#    echo "PGDATA=$PGDATA"
    ps auxx > setUp.log

    pgbench -i >> setUp.log 2>&1

    install_pg_stat_statements >> setUp.log 2>&1
}

function testReplicationStat001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-replication-stat [option...] [delay [count]]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.

EOF

    pt-replication-stat --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testReplicationStat002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-replication-stat -h localhost 1 1 > $OUT 2>&1
# +-------+-------+-----------+-------+-----------+------------+------------+------------+-----------+-----+--------+
# |  PID  |  NAME |    HOST   |  PORT |   STATE   |    SENT    |  WRITTTEN  |  FLUSHED   |  REPLAYED | PRI |  MODE  |
# +-------+-------+-----------+-------+-----------+------------+------------+------------+-----------+-----+--------+
# |       |       |           |       | local     | 0/101D9D00 | 0/101D9D00 |            |           |     | master |
# | 28463 | slave | 127.0.0.1 | 59821 | streaming | 0/101D9D00 | 0/101D9D00 | 0/101D9D00 | 0/FFFFFD0 |   0 | async  |
# +-------+-------+-----------+-------+-----------+------------+------------+------------+-----------+-----+--------+
    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi

    pt-replication-stat --host localhost 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi
}

function testReplicationStat003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-replication-stat -p 5433 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi

    pt-replication-stat --port 5433 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi
}

function testReplicationStat004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-replication-stat -U $USER 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi

    pt-replication-stat --username $USER 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi
}

function testReplicationStat005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-replication-stat -d testdb 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi

    pt-replication-stat --dbname testdb 1 1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.0" ]; then
	contains 'ERROR: PostgreSQL 9.0 is not supported.' $OUT
	assertTrue $?
    else
	contains 'master' $OUT
	assertTrue $?
	contains 'slave | 127.0.0.1' $OUT
	assertTrue $?
	contains 'streaming' $OUT
	assertTrue $?
	contains 'async' $OUT
	assertTrue $?
    fi
}

. shunit2
