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

function testKill001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-kill --help > $OUT
    assertEquals 0 $?

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-kill [option...] [command] [pid]

Commands:
    cancel                     Cancel a running query.
    terminate                  Terminate a backend with canceling query.

Options:
    --help                     Print this help.

EOF

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testKill002()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -e -c 'select pg_sleep(10)' postgres > $OUT 2>&1 &
    sleep 1

    if [ $_MAJORVERSION == "9.0" ]; then
	q="select procpid from pg_stat_activity where current_query like '%sleep%' and procpid <>  pg_backend_pid()"
    elif [ $_MAJORVERSION == "9.1" ]; then
	q="select procpid from pg_stat_activity where current_query like '%sleep%' and procpid <>  pg_backend_pid()"
    else
	q="select pid from pg_stat_activity where query like '%sleep%' and pid <>  pg_backend_pid()"
    fi

    _PID=`psql -A -t -c "$q" postgres`

    pt-kill cancel $_PID

    contains 'ERROR:  canceling statement due to user request' $OUT
    assertTrue $?
}

function testKill003()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -e -c 'select pg_sleep(10)' postgres > $OUT 2>&1 &
    sleep 1

    if [ $_MAJORVERSION == "9.0" ]; then
	q="select procpid from pg_stat_activity where current_query like '%sleep%' and procpid <>  pg_backend_pid()"
    elif [ $_MAJORVERSION == "9.1" ]; then
	q="select procpid from pg_stat_activity where current_query like '%sleep%' and procpid <>  pg_backend_pid()"
    else
	q="select pid from pg_stat_activity where query like '%sleep%' and pid <>  pg_backend_pid()"
    fi

    _PID=`psql -A -t -c "$q" postgres`

    pt-kill terminate $_PID

    contains 'FATAL:  terminating connection due to administrator command' $OUT
    assertTrue $?
}

function testKill004()
{
    OUT=${_SHUNIT_TEST_}.out

    # No such process error
    pt-kill terminate 32769
    assertFalse $?
}

function testKill005()
{
    OUT=${_SHUNIT_TEST_}.out

    _UID=`id -u`
    if [ $_UID -eq 0 ]; then
	echo "!!! CAUTION: DO NOT RUN TEST WITH SUPERUSER ACCOUNT !!!"
	fail
	return
    fi

    # Operation not permitted error
    pt-kill terminate 1
    assertFalse $?
}

. shunit2
