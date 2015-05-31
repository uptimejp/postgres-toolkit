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

function testXactStat001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-xact-stat [option...] [delay [count]]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -H, --host-list=HOSTLIST   List of pairs of hostname and port number
                               (c.f. host1:port1,host2:port2)
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.

EOF

    pt-xact-stat --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testXactStat002()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat -h localhost 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       2 |         0 |' $OUT
    assertTrue $?

    # wait for stat update
    sleep 1

    pt-xact-stat --host localhost 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       4 |         0 |' $OUT
    assertTrue $?
}

function testXactStat003()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat -p 5433 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       2 |         0 |' $OUT
    assertTrue $?

    # wait for stat update
    sleep 1

    pt-xact-stat --port 5433 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       4 |         0 |' $OUT
    assertTrue $?
}

function testXactStat004()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat -U $USER 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       2 |         0 |' $OUT
    assertTrue $?

    # wait for stat update
    sleep 1

    pt-xact-stat --username $USER 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       4 |         0 |' $OUT
    assertTrue $?
}

function testXactStat005()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat -d testdb 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       2 |         0 |' $OUT
    assertTrue $?

    # wait for stat update
    sleep 1

    pt-xact-stat --dbname testdb 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       4 |         0 |' $OUT
    assertTrue $?
}

function testXactStat006()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       2 |         0 |' $OUT
    assertTrue $?

    # wait for stat update
    sleep 1

    pt-xact-stat 1 1 > $OUT 2>&1
    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS |' $OUT
    assertTrue $?
    contains '| localhost | 5433 | testdb |    1 |       4 |         0 |' $OUT
    assertTrue $?
}

function testXactStat007()
{
    OUT=${_SHUNIT_TEST_}.out

    psql -c 'select pg_stat_reset()' > $OUT
    sleep 1

    pt-xact-stat -H 127.0.0.1:5433,127.0.0.1:5434 1 1 > $OUT 2>&1

    contains '|    HOST   | PORT | DBNAME | CONN | COMMITS | ROLLBACKS | B_READ | B_HIT |' $OUT
    assertTrue $?
    contains '| 127.0.0.1 | 5433 | testdb |    1 | ' $OUT
    assertTrue $?
    contains '| 127.0.0.1 | 5434 | testdb |    1 | ' $OUT
    assertTrue $?
}

. shunit2
