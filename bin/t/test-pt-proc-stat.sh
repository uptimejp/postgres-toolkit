#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

function _setUp()
{
    echo "PATH=$PATH"
    echo "PGHOME=$PGHOME"
    echo "PGDATA=$PGDATA"
    ps auxx > setUp.log
}

function testProcStat001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-proc-stat --help > $OUT

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-proc-stat [option...] [delay [count]]

Options:
    -D, --pgdata=DATADIR       Location of the database storage area
    -P, --pid=PID              Process ID of the postmaster

    --help                     Print this help.

EOF

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testProcStat002()
{
    OUT=${_SHUNIT_TEST_}.out

    sudo env PATH=$PATH pt-proc-stat > $OUT

    grep 'postmaster\|postgres' ${_SHUNIT_TEST_}.out > /dev/null
    assertEquals 0 $?

    grep stats.collector $OUT > /dev/null
    assertEquals 0 $?
}

function testProcStat003()
{
    OUT=${_SHUNIT_TEST_}.out

    sudo env PATH=$PATH pt-proc-stat -D $PGDATA > $OUT

    grep 'postmaster\|postgres' $OUT > /dev/null
    assertEquals 0 $?

    grep stats.collector ${_SHUNIT_TEST_}.out > /dev/null
    assertEquals 0 $?
}

function testProcStat004()
{
    OUT=${_SHUNIT_TEST_}.out
    PID=`ps auxx | grep bin/post | grep -v grep | sort | head -1 | awk '{ print $2 }'`

    sudo env PATH=$PATH pt-proc-stat -P $PID > $OUT

    grep 'postmaster\|postgres' $OUT > /dev/null
    assertEquals 0 $?

    grep stats.collector ${_SHUNIT_TEST_}.out > /dev/null
    assertEquals 0 $?

    sudo env PATH=$PATH pt-proc-stat --pid $PID > $OUT

    grep 'postmaster\|postgres' $OUT > /dev/null
    assertEquals 0 $?

    grep stats.collector ${_SHUNIT_TEST_}.out > /dev/null
    assertEquals 0 $?
}

function testProcStat005()
{
    OUT=${_SHUNIT_TEST_}.out

    sudo env PATH=$PATH pt-proc-stat -D nosuchdir > $OUT
    assertEquals 1 $?
}

. shunit2
