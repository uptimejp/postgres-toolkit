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

    pgbench -i -n >> setUp.log 2>&1
}

function testShowLocks001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-show-locks --help > $OUT

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-show-locks [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.

EOF

    diff -rc ${_SHUNIT_TEST_}.expected ${_SHUNIT_TEST_}.out
    assertEquals 0 $?
}

function testShowLocks002()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'begin;lock table pgbench_accounts;select pg_sleep(2);' > /dev/null &
    sleep 1
    psql -c 'begin;select * from pgbench_accounts for update;' > /dev/null &

    pt-show-locks -h localhost > $OUT
#    cat $OUT

    contains '| BLOCKER | PID  | LOCKTYPE |         MODE        | GRANTED |                         QUERY                         |' $OUT
    assertTrue $?

    contains '|         | [0-9 ]\{1,5\} | relation | AccessExclusiveLock | t       | begin;lock table pgbench_accounts;select pg_sleep(2); |' $OUT
    assertTrue $?

    contains '|   [0-9 ]\{1,5\} | [0-9 ]\{1,5\} | relation | RowShareLock        | f       | begin;select \* from pgbench_accounts for update;      |' $OUT
    assertTrue $?
}

function testShowLocks003()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'begin;lock table pgbench_accounts;select pg_sleep(2);' > /dev/null &
    sleep 1
    psql -c 'begin;select * from pgbench_accounts for update;' > /dev/null &

    pt-show-locks -p $PGPORT > $OUT
    pt-show-locks --port $PGPORT >> $OUT
#    cat $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 12 $COUNT
}

function testShowLocks004()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'begin;lock table pgbench_accounts;select pg_sleep(2);' > /dev/null &
    sleep 1
    psql -c 'begin;select * from pgbench_accounts for update;' > /dev/null &

    pt-show-locks -U $USER > $OUT
    pt-show-locks --username $USER >> $OUT
#    cat $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 12 $COUNT
}

function testShowLocks005()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'begin;lock table pgbench_accounts;select pg_sleep(2);' > /dev/null &
    sleep 1
    psql -c 'begin;select * from pgbench_accounts for update;' > /dev/null &

    pt-show-locks -d postgres > $OUT
    pt-show-locks --dbname postgres >> $OUT
#    cat $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 12 $COUNT
}

. shunit2
