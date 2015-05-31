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

function testTablespaceUsage001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-tablespace-usage --help > $OUT

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-tablespace-usage [option...]

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

function testTablespaceUsage002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-tablespace-usage -h localhost > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?

    pt-tablespace-usage --host localhost > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?
}

function testTablespaceUsage003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-tablespace-usage -p $PGPORT > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?

    pt-tablespace-usage --port $PGPORT > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?
}

function testTablespaceUsage004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-tablespace-usage -U $USER > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?

    pt-tablespace-usage --username $USER > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?
}

function testTablespaceUsage005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-tablespace-usage -d postgres > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?

    pt-tablespace-usage --dbname postgres > $OUT

    contains '| pg_default | postgres  |' $OUT
    assertTrue $?
    contains '| pg_default | template1 |' $OUT
    assertTrue $?
    contains '| pg_default | testdb    |' $OUT
    assertTrue $?
}

. shunit2
