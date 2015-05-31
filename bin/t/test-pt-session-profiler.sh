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
}

function testSessionProfiler001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-session-profiler [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -i STRING                  Interface name to listen
    -T, --threshold=NUMBER     Threashold of query elapsed time (in millisecond)

    --help                     Print this help.

EOF

    pt-session-profiler --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testSessionProfiler002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-session-profiler -h 192.168.1.201 > $OUT 2>&1
    contains 'INFO: tcpdump -tttt -l -i any -s 0 -X -p tcp port 5432 and host 192.168.1.201' $OUT
    assertTrue $?
    
    pt-session-profiler --host 192.168.1.201 > $OUT 2>&1
    contains 'INFO: tcpdump -tttt -l -i any -s 0 -X -p tcp port 5432 and host 192.168.1.201' $OUT
    assertTrue $?
}

function testSessionProfiler003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-session-profiler -p 5433 > $OUT 2>&1
    contains 'INFO: tcpdump -tttt -l -i any -s 0 -X -p tcp port 5433' $OUT
    assertTrue $?

    pt-session-profiler --port 5433 > $OUT 2>&1
    contains 'INFO: tcpdump -tttt -l -i any -s 0 -X -p tcp port 5433' $OUT
    assertTrue $?

    assertEquals 0 $?
}

function testSessionProfiler004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-session-profiler -i lo > $OUT 2>&1
    contains 'INFO: tcpdump -tttt -l -i lo -s 0 -X -p tcp port 5432' $OUT
    assertTrue $?

    assertEquals 0 $?
}

function testSessionProfiler005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-session-profiler -T 2000 > $OUT 2>&1
    contains 'INFO: Threshold: 2000 ms' $OUT
    assertTrue $?

    pt-session-profiler --threshold 3000 > $OUT 2>&1
    contains 'INFO: Threshold: 3000 ms' $OUT
    assertTrue $?

    assertEquals 0 $?
}

. shunit2
