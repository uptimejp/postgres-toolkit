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

    if [ $_MAJORVERSION == "9.0" ]; then
	CREATEUSER_OPTS="--no-superuser --no-createdb --login --no-createrole"
    elif [ $_MAJORVERSION == "9.1" ]; then
	CREATEUSER_OPTS="--no-superuser --no-createdb --login --no-createrole"
    else
	CREATEUSER_OPTS="--no-superuser --no-createdb --login --no-createrole --no-replication"
    fi
}

function testPrivilegeAutogen001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen --help > $OUT

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-privilege-autogen [option...] [ start | stop ]
       pt-privilege-autogen [option...] generate <USERNAME>

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

    pt-privilege-autogen generate $USER > ${_SHUNIT_TEST_}.grant.out
    assertEquals 0 $?

    diff -rc ${_SHUNIT_TEST_}.grant.expected ${_SHUNIT_TEST_}.grant.out
    assertEquals 0 $?

    pt-privilege-autogen stop >> $OUT 2>&1
    assertEquals 0 $?
}

function testPrivilegeAutogen007()
{
    OUT=${_SHUNIT_TEST_}.out

    createuser $CREATEUSER_OPTS "user01"
    createuser $CREATEUSER_OPTS "user02"

    pt-privilege-autogen -U "user01" start > $OUT 2>&1
    assertEquals 0 $?

    pgbench -U $USER -c 1 -t 1 >> $OUT 2>&1
    # wait for updating table access statistics.
    sleep 1

    pt-privilege-autogen -U "user01" generate "user01" > ${_SHUNIT_TEST_}.grant.out
    assertEquals 0 $?

    # stoppping with different user.
    pt-privilege-autogen -U "user02" stop >> $OUT 2>&1
    assertEquals 1 $?

    contains 'ERROR: Could not drop the access statistics table.' $OUT
    assertTrue $?

    pt-privilege-autogen -U "user01" stop >> $OUT 2>&1
    assertEquals 0 $?

    dropuser "user01"
    dropuser "user02"
}

function testPrivilegeAutogen008()
{
    OUT=${_SHUNIT_TEST_}.out

    createuser $CREATEUSER_OPTS "user01"
    createuser $CREATEUSER_OPTS "user02"

    pt-privilege-autogen -U "user01" start >> $OUT 2>&1
    assertEquals 0 $?

    pgbench -U $USER -c 1 -t 1 >> $OUT 2>&1
    # wait for updating table access statistics.
    sleep 1

    pt-privilege-autogen -U "user02" generate "user02" > ${_SHUNIT_TEST_}.grant.out 2>&1
    assertEquals 1 $?

    contains 'ERROR: Could not get access statistics of the tables.' ${_SHUNIT_TEST_}.grant.out
    assertTrue $?

    # stoppping with different user.
    pt-privilege-autogen -U "user01" stop >> $OUT 2>&1
    assertEquals 0 $?

    dropuser "user01"
    dropuser "user02"
}

function testPrivilegeAutogen009()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-privilege-autogen start > $OUT 2>&1
    assertEquals 0 $?

    pt-privilege-autogen generate >> $OUT 2>&1
    assertEquals 1 $?

    contains 'ERROR: User name to be granted not specified.' $OUT
    assertTrue $?

    # stoppping with different user.
    pt-privilege-autogen stop >> $OUT 2>&1
    assertEquals 0 $?
}

. shunit2
