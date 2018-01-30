#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

. ./test_common.sh

function _setUp()
{
    echo "PATH=$PATH"
    echo "PGHOME=$PGHOME"
    echo "PGDATA=$PGDATA"
    ps auxx > setUp.log
}

function testConfig001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config --help > $OUT
    assertEquals 0 $?

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-config [option...] [command] [param [value]]

Commands:
    get [PARAM]                Get a current value of a parameter.
    set [PARAM] [VALUE]        Set a new value for a parameter.
    disable [PARAM]            Comment a parameter out.

Options:
    -D, --pgdata=PGDATA        Specify a PostgreSQL database cluster.
    --apply                    Apply change(s).

    --help                     Print this help.

EOF

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testConfig002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA get shared_buffers > $OUT

    if [ $_MAJORVERSION == "9.0" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.1" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.2" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.3" ]; then
	contains ^128MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains ^128MB $OUT
	assertTrue $?
    fi

    pt-config --pgdata $PGDATA get shared_buffers > $OUT

    if [ $_MAJORVERSION == "9.0" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.1" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.2" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.3" ]; then
	contains ^128MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains ^128MB $OUT
	assertTrue $?
    fi

    _PGDATA=$PGDATA
    export PGDATA
    pt-config get shared_buffers > $OUT

    if [ $_MAJORVERSION == "9.0" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.1" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.2" ]; then
	contains ^32MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.3" ]; then
	contains ^128MB $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains ^128MB $OUT
	assertTrue $?
    fi
}

function testConfig003()
{
    OUT=${_SHUNIT_TEST_}.out

    # not found
    pt-config -D $PGDATA get shared_buffer > $OUT
    assertEquals 1 $?

    # argument missing
    pt-config -D $PGDATA get > $OUT
    contains 'Usage: pt-config \[option...\] \[command\] \[param \[value\]\]' $OUT
    assertTrue $?

    # directory not found
    pt-config -D nosuchdir get shared_buffers > $OUT
    assertEquals 1 $?
}

function testConfig004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA set shared_buffers 256MB > $OUT
    assertEquals 0 $?

    if [ $_MAJORVERSION == "9.0" ]; then
	contains '^shared_buffers = 32MB' $PGDATA/postgresql.conf
	assertTrue $?
    elif [ $_MAJORVERSION == "9.1" ]; then
	contains '^shared_buffers = 32MB' $PGDATA/postgresql.conf
	assertTrue $?
    elif [ $_MAJORVERSION == "9.2" ]; then
	contains '^shared_buffers = 32MB' $PGDATA/postgresql.conf
	assertTrue $?
    elif [ $_MAJORVERSION == "9.3" ]; then
	contains '^shared_buffers = 128MB' $PGDATA/postgresql.conf
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains '^shared_buffers = 128MB' $PGDATA/postgresql.conf
	assertTrue $?
    fi
}

function testConfig005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA --apply set shared_buffers 256MB > $OUT
    assertEquals 0 $?

    contains '^shared_buffers = 256MB' $PGDATA/postgresql.conf
    assertTrue $?
}

function testConfig006()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA --apply set shared_buffer 128MB > $OUT
    assertEquals 1 $?

    contains '^shared_buffers = 256MB' $PGDATA/postgresql.conf
    assertTrue $?
}

function testConfig007()
{
    OUT=${_SHUNIT_TEST_}.out


    pt-config -D $PGDATA disable shared_buffers > $OUT
    assertEquals 0 $?

    contains '^shared_buffers = 256MB' $PGDATA/postgresql.conf
    assertTrue $?
}

function testConfig008()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA --apply disable shared_buffers > $OUT
    assertEquals 0 $?

    contains '^#shared_buffers = 256MB' $PGDATA/postgresql.conf
    assertTrue $?
}

function testConfig009()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA --apply disable shared_buffer > $OUT
    assertEquals 1 $?

    contains '^#shared_buffers = 256MB' $PGDATA/postgresql.conf
    assertTrue $?
}

function testConfig010()
{
    OUT=${_SHUNIT_TEST_}.out

    # missing argument
    pt-config -D $PGDATA set shared_buffers > $OUT 2>&1
    contains 'Usage: pt-config \[option...\] \[command\] \[param \[value\]\]' $OUT
    assertTrue $?
}

# test for multiple pairs.
function testConfig011()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-config -D $PGDATA set shared_buffers 32MB > $OUT 2>&1

    echo "shared_buffers = 64MB" >> $PGDATA/postgresql.conf

    pt-config -D $PGDATA get shared_buffers > $OUT 2>&1

    # set by testConfig009
    contains '^256MB (disabled)' $OUT
    assertTrue $?

    contains '^64MB$' $OUT
    assertTrue $?
}

. shunit2
