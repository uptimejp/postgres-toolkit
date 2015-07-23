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
    pgbench -t 1 -c 1 -n >> setUp.log 2>&1
}

function testPrivilegeAutogen001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen --help > $OUT

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-privilege-autogen [option...] [ start | generate | stop ]

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

function testPrivilegeAutogen002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen -h localhost start > $OUT 2>&1
    assertEquals 0 $?
    pt-privilege-autogen --host localhost stop >> $OUT 2>&1
    assertEquals 0 $?

    contains 'INFO: Collecting access statistics started.' $OUT
    assertTrue $?
    contains 'INFO: Collecting access statistics stopped.' $OUT
    assertTrue $?
}

function testPrivilegeAutogen003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen -p $PGPORT start > $OUT 2>&1
    assertEquals 0 $?
    pt-privilege-autogen --port $PGPORT stop >> $OUT 2>&1
    assertEquals 0 $?

    contains 'INFO: Collecting access statistics started.' $OUT
    assertTrue $?
    contains 'INFO: Collecting access statistics stopped.' $OUT
    assertTrue $?
}

function testPrivilegeAutogen004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen -U $USER start > $OUT 2>&1
    assertEquals 0 $?
    pt-privilege-autogen --username $USER stop >> $OUT 2>&1
    assertEquals 0 $?

    contains 'INFO: Collecting access statistics started.' $OUT
    assertTrue $?
    contains 'INFO: Collecting access statistics stopped.' $OUT
    assertTrue $?
}

function testPrivilegeAutogen005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen -d postgres start > $OUT 2>&1
    assertEquals 0 $?
    pt-privilege-autogen --dbname postgres stop >> $OUT 2>&1
    assertEquals 0 $?

    contains 'INFO: Collecting access statistics started.' $OUT
    assertTrue $?
    contains 'INFO: Collecting access statistics stopped.' $OUT
    assertTrue $?
}

function testPrivilegeAutogen006()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen start >> $OUT 2>&1
    assertEquals 0 $?

    cat <<EOF > ${_SHUNIT_TEST_}.grant.expected

-- Database
REVOKE ALL ON DATABASE "testdb" FROM "public";
GRANT CONNECT,TEMP ON DATABASE "testdb" TO "$USER";

-- Schema
REVOKE ALL ON SCHEMA "public" FROM "public";
GRANT USAGE ON SCHEMA "public" TO "$USER";

-- Table
REVOKE ALL ON TABLE "public"."pgbench_accounts" FROM "$USER";
REVOKE ALL ON TABLE "public"."pgbench_branches" FROM "$USER";
REVOKE ALL ON TABLE "public"."pgbench_history" FROM "$USER";
REVOKE ALL ON TABLE "public"."pgbench_tellers" FROM "$USER";
GRANT SELECT,UPDATE ON TABLE "public"."pgbench_accounts" TO "$USER";
GRANT SELECT,UPDATE ON TABLE "public"."pgbench_branches" TO "$USER";
GRANT INSERT ON TABLE "public"."pgbench_history" TO "$USER";
GRANT SELECT,UPDATE ON TABLE "public"."pgbench_tellers" TO "$USER";


EOF

    pgbench -c 1 -t 1 >> $OUT 2>&1
    # wait for updating table access statistics.
    sleep 1

    pt-privilege-autogen generate > ${_SHUNIT_TEST_}.grant.out
    assertEquals 0 $?

    diff -rc ${_SHUNIT_TEST_}.grant.expected ${_SHUNIT_TEST_}.grant.out
    assertEquals 0 $?

    pt-privilege-autogen stop >> $OUT 2>&1
    assertEquals 0 $?
}

. shunit2
