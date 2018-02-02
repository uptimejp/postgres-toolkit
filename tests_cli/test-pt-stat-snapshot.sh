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

    install_pg_stat_statements >> setUp.log 2>&1
    install_pgstattuple >> setUp.log 2>&1

    ps auxx > setUp.log
}

function testStatSnapshot001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-stat-snapshot [option...] install
       pt-stat-snapshot [option...] create [level]
       pt-stat-snapshot [option...] list
       pt-stat-snapshot [option...] delete [sid]
       pt-stat-snapshot [option...] export [file]
       pt-stat-snapshot [option...] import [file]
       pt-stat-snapshot [option...] uninstall

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    --help                     Print this help.

EOF

    pt-stat-snapshot --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testStatSnapshot002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug install > $OUT 2>&1
    assertTrue $?
}

function testStatSnapshot003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug create > $OUT 2>&1
    assertFalse $?
    contains 'ERROR: Missing argument.' $OUT
    assertTrue $?

    sleep 1

    pt-stat-snapshot --debug create 1 > $OUT 2>&1
    contains 'INFO: Succeeded to take a snapshot.' $OUT
    assertTrue $?

    sleep 1

    pt-stat-snapshot --debug create 2 > $OUT 2>&1
    contains 'INFO: Succeeded to take a snapshot.' $OUT
    assertTrue $?

    sleep 1

    pt-stat-snapshot --debug create 4 > $OUT 2>&1
    contains 'INFO: Succeeded to take a snapshot.' $OUT
    assertTrue $?

    sleep 1

    psql -c 'select * from pgperf.snapshot order by sid' > $OUT
    contains '   0 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     1' $OUT
    assertTrue $?
    contains '   1 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     2' $OUT
    assertTrue $?
    contains '   2 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     4' $OUT
    assertTrue $?
}

function testStatSnapshot004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug list > $OUT 2>&1
    contains '| SID |      TIMESTAMP      | LEVEL |' $OUT
    assertTrue $?
    contains '|   0 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} |     1 |' $OUT
    assertTrue $?
    contains '|   1 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} |     2 |' $OUT
    assertTrue $?
    contains '|   2 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\} |     4 |' $OUT
    assertTrue $?
}

function testStatSnapshot005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug delete > $OUT 2>&1
    assertFalse $?
    contains 'ERROR: Missing argument.' $OUT
    assertTrue $?

    # delete sid 0
    pt-stat-snapshot --debug delete 0 > $OUT 2>&1
    assertTrue $?

    psql -c 'select * from pgperf.snapshot order by sid' >> $OUT
    contains '   0 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     1' $OUT
    assertFalse $?
    contains '   1 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     2' $OUT
    assertTrue $?
    contains '   2 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     4' $OUT
    assertTrue $?

    # delete sid 1 and later
    pt-stat-snapshot --debug delete 1: > $OUT 2>&1
    assertTrue $?
    psql -c 'select * from pgperf.snapshot order by sid' >> $OUT
    contains '   0 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     1' $OUT
    assertFalse $?
    contains '   1 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     2' $OUT
    assertFalse $?
    contains '   2 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     4' $OUT
    assertFalse $?
}

function testStatSnapshot006()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug create 4 > $OUT 2>&1
    assertTrue $?

    pt-stat-snapshot --debug export snapshot.exp > $OUT 2>&1
    assertTrue $?

    contains 'INFO: Exporting done.' $OUT
    assertTrue $?
}

function testStatSnapshot007()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug delete 0: > $OUT 2>&1
    assertTrue $?

    pt-stat-snapshot --debug import snapshot.exp > $OUT 2>&1
    assertTrue $?

    contains 'INFO: Succeeded to import snapshot(s).' $OUT
    assertTrue $?

    psql -c 'select * from pgperf.snapshot order by sid' >> $OUT
    contains '   0 | [0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}:[0-9]\{2\}.[0-9 ]\{1,6\} |     4' $OUT
    assertTrue $?
}

# dummy test to clean up.
function testStatSnapshot999()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-stat-snapshot --debug uninstall > $OUT 2>&1
    assertTrue $?
}

. shunit2
