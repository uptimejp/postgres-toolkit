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

    psql -c 'select pg_stat_statements_reset()' >> setUp.log 2>&1
}


function testSnapStatement001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-snap-statements [option...] [interval]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -t, --top=NUMBER           Number of queries to be listed
    -R, --reset                Reset statistics

    --help                     Print this help.

EOF

    pt-snap-statements --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected ${_SHUNIT_TEST_}.out
    assertEquals 0 $?
}

function wait_and_exec()
{
    WAIT=$1
    QUERY=$2

    sleep $WAIT
    psql -c "$QUERY" > /dev/null
}

function testSnapStatement002()
{
    OUT=${_SHUNIT_TEST_}.out

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements -h 127.0.0.1 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements --host 127.0.0.1 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi
}

function testSnapStatement003()
{
    OUT=${_SHUNIT_TEST_}.out

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements -p $PGPORT 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements --port $PGPORT 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi
}

function testSnapStatement004()
{
    OUT=${_SHUNIT_TEST_}.out

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements -U $USER 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements --username $USER 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi
}

function testSnapStatement005()
{
    OUT=${_SHUNIT_TEST_}.out

#    -t, --top=NUMBER           Number of queries to be listed
#    -R, --reset                Reset statistics

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements -d testdb 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    pt-snap-statements --dbname testdb 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
    fi
}

function testSnapStatement006()
{
    OUT=${_SHUNIT_TEST_}.out

#    -t, --top=NUMBER           Number of queries to be listed
#    -R, --reset                Reset statistics

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    wait_and_exec 1 "select count(*) from pgbench_branches" &
    wait_and_exec 1 "select count(*) from pgbench_history" &
    pt-snap-statements -t 1 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_b |     1 ' $OUT
	assertFalse $?
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_h |     1 ' $OUT
	assertFalse $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | select count(\*) from pgbench_b |     1 ' $OUT
	assertFalse $?
	contains ' | testdb | select count(\*) from pgbench_h |     1 ' $OUT
	assertFalse $?
    fi

    wait_and_exec 1 "select count(*) from pgbench_accounts" &
    wait_and_exec 1 "select count(*) from pgbench_branches" &
    wait_and_exec 1 "select count(*) from pgbench_history" &
    pt-snap-statements -t 2 2 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.4" ]; then
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_b |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | .\{7,8\} | select count(\*) from pgbench_h |     1 ' $OUT
	assertFalse $?
    else
	contains ' | testdb | select count(\*) from pgbench_a |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | select count(\*) from pgbench_b |     1 ' $OUT
	assertTrue $?
	contains ' | testdb | select count(\*) from pgbench_h |     1 ' $OUT
	assertFalse $?
    fi
}

function testSnapStatement007()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c "select count(*) from pgbench_accounts" > /dev/null
    psql -c "select count(*) from pgbench_branches" > /dev/null
    psql -c "select count(*) from pgbench_history" > /dev/null
    psql -A -t -q -c 'select count(*) from pg_stat_statements' > $OUT 2>&1

    pt-snap-statements --reset > $OUT 2>&1
    sleep 1

    psql -A -t -q -c 'select count(*) from pg_stat_statements' > $OUT 2>&1

    contains '^1$' $OUT
    assertTrue $?

    psql -c "select count(*) from pgbench_accounts" > /dev/null
    psql -c "select count(*) from pgbench_branches" > /dev/null
    psql -c "select count(*) from pgbench_history" > /dev/null
    psql -A -t -q -c 'select count(*) from pg_stat_statements' > $OUT 2>&1

    pt-snap-statements -R > $OUT 2>&1
    sleep 1

    psql -A -t -q -c 'select count(*) from pg_stat_statements' > $OUT 2>&1

    contains '^1$' $OUT
    assertTrue $?
}

. shunit2
