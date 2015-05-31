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

    pgbench -i >> setUp.log 2>&1

    psql<<EOF >> setUp.log
CREATE SCHEMA nsp1;
CREATE TABLESPACE spc1 LOCATION '/tmp/spc1';
SELECT * FROM pg_tablespace;

ALTER INDEX pgbench_accounts_pkey SET TABLESPACE spc1;
EOF
}

function tearDown()
{
    psql<<EOF >> tearDown.log
ALTER INDEX pgbench_accounts_pkey SET TABLESPACE pg_default;

DROP TABLESPACE spc1;
DROP SCHEMA nsp1;
EOF

    rm -rf /tmp/spc1/*
}

function testIndexUsage001()
{
    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-index-usage [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name
    -i, --index=STRING         Index name

    --help                     Print this help.

EOF

    pt-index-usage --help > ${_SHUNIT_TEST_}.out

    diff -rc ${_SHUNIT_TEST_}.expected ${_SHUNIT_TEST_}.out
    assertEquals 0 $?
}

function testIndexUsage002()
{
    OUT=${_SHUNIT_TEST_}.out

    # To avoid following error.
    # ERROR:  index "pgbench_accounts_pkey" contains unexpected zero page at block 0
    # HINT:  Please REINDEX it.
    reindexdb > $OUT 2>&1

    pt-index-usage -h localhost > $OUT 2>&1

    COUNT=`grep -c pgbench_accounts_pkey $OUT`
    assertEquals 1 $COUNT

    COUNT=`grep -c pgbench_branches_pkey $OUT`
    assertEquals 1 $COUNT

    COUNT=`grep -c pgbench_tellers_pkey $OUT`
    assertEquals 1 $COUNT

    SCAN=`grep pgbench_accounts_pkey $OUT | awk '{ print $14 }'`
    T_READ=`grep pgbench_accounts_pkey $OUT | awk '{ print $16 }'`
    T_FTCH=`grep pgbench_accounts_pkey $OUT | awk '{ print $18 }'`

    psql -c 'select * from pgbench_accounts where aid = 1' > /dev/null
    sleep 1

    pt-index-usage --host localhost >> $OUT 2>&1

    SCAN2=`grep pgbench_accounts_pkey $OUT | tail -1 | awk '{ print $14 }'`
    T_READ2=`grep pgbench_accounts_pkey $OUT | tail -1 | awk '{ print $16 }'`
    T_FTCH2=`grep pgbench_accounts_pkey $OUT | tail -1 | awk '{ print $18 }'`

    assertTrue "[ $SCAN2 -gt $SCAN ]"
    assertTrue "[ $T_READ2 -gt $T_READ ]"
    assertTrue "[ $T_FTCH2 -gt $T_FTCH ]"
}


function testIndexUsage003()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -p $PGPORT > $OUT 2>&1
    pt-index-usage --port $PGPORT >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage004()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -U $USER > $OUT 2>&1
    pt-index-usage --username $USER >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage005()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -d testdb > $OUT 2>&1
    pt-index-usage --dbname testdb >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage006()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -o $USER > $OUT 2>&1
    pt-index-usage --owner $USER >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage007()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -n public > $OUT 2>&1
    pt-index-usage --schema public >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage008()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -t pgbench_accounts > $OUT 2>&1
    pt-index-usage --table pgbench_accounts >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

function testIndexUsage009()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -i pgbench_branches_pkey > $OUT 2>&1
    pt-index-usage --index pgbench_branches_pkey >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

function testIndexUsage010()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -u > $OUT 2>&1
    pt-index-usage --unused >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

# regular expressions
function testIndexUsage011()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -o /^$USER$/ > $OUT 2>&1
    pt-index-usage --owner /^$USER$/ >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage012()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -n /c$/ > $OUT 2>&1
    pt-index-usage --schema /c$/ >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 14 $COUNT
}

function testIndexUsage013()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -t /.*ch_a.*s$/ > $OUT 2>&1
    pt-index-usage --table /.*ch_a.*s$/ >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

function testIndexUsage014()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-index-usage -i /.*ch_a.*y$/ > $OUT 2>&1
    pt-index-usage --index /.*ch_a.*y$/ >> $OUT 2>&1

    COUNT=`wc -l $OUT | awk '{ print $1 }'`
    assertEquals 10 $COUNT
}

. shunit2
