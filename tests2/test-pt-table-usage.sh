#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

export PGDATABASE=testdb

function setUp()
{
#    echo "PATH=$PATH"
#    echo "PGHOME=$PGHOME"
#    echo "PGDATA=$PGDATA"
    ps auxx > setUp.log

    pgbench -i -n >> setUp.log 2>&1
}

function testTableUsage001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage --help > $OUT

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-table-usage [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name

    --help                     Print this help.

EOF

    diff -rc ${_SHUNIT_TEST_}.expected ${_SHUNIT_TEST_}.out
    assertEquals 0 $?
}

function testTableUsage002()
{
    OUT=${_SHUNIT_TEST_}.out

    sleep 1
    pt-table-usage -h localhost > $OUT

    COUNT=`grep -c pgbench_accounts $OUT`
    assertEquals 1 $COUNT

    COUNT=`grep -c pgbench_branches $OUT`
    assertEquals 1 $COUNT

    COUNT=`grep -c pgbench_history $OUT`
    assertEquals 1 $COUNT

    COUNT=`grep -c pgbench_tellers $OUT`
    assertEquals 1 $COUNT

    SCAN=`grep pgbench_accounts $OUT | awk '{ print $12 }'`
    T_READ=`grep pgbench_accounts $OUT | awk '{ print $14 }'`
    T_INS=`grep pgbench_accounts $OUT | awk '{ print $16 }'`
    T_UPD=`grep pgbench_accounts $OUT | awk '{ print $18 }'`
    assertEquals 1 $SCAN
    assertEquals 100000 $T_READ
    assertEquals 100000 $T_INS
    assertEquals 0 $T_UPD

    psql -c 'select * from pgbench_accounts' > /dev/null

    sleep 1
    pt-table-usage --host localhost >> $OUT

    SCAN2=`grep pgbench_accounts $OUT | tail -1 | awk '{ print $12 }'`
    T_READ2=`grep pgbench_accounts $OUT | tail -1 | awk '{ print $14 }'`
    T_INS2=`grep pgbench_accounts $OUT | tail -1 | awk '{ print $16 }'`
    T_UPD2=`grep pgbench_accounts $OUT | tail -1 | awk '{ print $18 }'`
    assertEquals 2 $SCAN2
    assertEquals 200000 $T_READ2
    assertEquals 100000 $T_INS2
    assertEquals 0 $T_UPD2

#    cat $OUT
}

function testTableUsage003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -p $PGPORT > $OUT
    pt-table-usage --port $PGPORT >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -U $USER > $OUT
    pt-table-usage --username $USER >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -d postgres > $OUT
    pt-table-usage --dbname postgres >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 8 $COUNT
}

function testTableUsage006()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -o $USER > $OUT
    pt-table-usage --owner $USER >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage007()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -n public > $OUT
    pt-table-usage --schema public >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage008()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -t pgbench_accounts > $OUT
    pt-table-usage --table pgbench_accounts >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

# regular expressions
function testTableUsage009()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -o /^$USER$/ > $OUT
    pt-table-usage --owner /^$USER$/ >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage010()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -n /c$/ > $OUT
    pt-table-usage --schema /c$/ >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 16 $COUNT
}

function testTableUsage011()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-table-usage -t /ts$/ > $OUT
    pt-table-usage --table /ts$/ >> $OUT

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

. shunit2
