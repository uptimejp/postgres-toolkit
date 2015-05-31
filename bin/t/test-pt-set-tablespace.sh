#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

export PGDATABASE=testdb

source ./test_common.sh

function setUp()
{
#    echo "PATH=$PATH"
#    echo "PGHOME=$PGHOME"
#    echo "PGDATA=$PGDATA"
    ps auxx > setUp.log

    rm -rf /tmp/spc1
    mkdir -p /tmp/spc1

    psql<<EOF >> setUp.log
CREATE SCHEMA nsp1;
CREATE TABLESPACE spc1 LOCATION '/tmp/spc1';
SELECT * FROM pg_tablespace;

CREATE TABLE t1 ( uid INTEGER PRIMARY KEY, uname TEXT NOT NULL );

SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF
}

function tearDown()
{
    psql<<EOF >> tearDown.log
DROP TABLE t1;
DROP TABLESPACE spc1;
DROP SCHEMA nsp1;
EOF
}

function testSetTablespace001()
{
    OUT=${_SHUNIT_TEST_}.out

    cat<<EOF >${_SHUNIT_TEST_}.expected

Usage: pt-set-tablespace [option...] [tablespace]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -U, --username=USERNAME    User name to connect
    -d, --dbname=DBNAME        Database name to connect

    -o, --owner=STRING         Owner name
    -n, --schema=STRING        Schema name
    -t, --table=STRING         Table name

    -l, --list                 List table spaces
    --apply                    Apply change(s)

    --help                     Print this help.

EOF

    pt-set-tablespace --help > $OUT 2>&1

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testSetTablespace002()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-set-tablespace --list > $OUT 2>&1

    grep spc1 $OUT | grep /tmp/spc1 > /dev/null
    assertEquals 0 $?
}

function testSetTablespace003()
{
    OUT=${_SHUNIT_TEST_}.out

    #_DEBUG="--debug"
    pt-set-tablespace $_DEBUG -t t1 spc1 > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains 'ALTER TABLE "public"."t1" SET TABLESPACE "spc1";' $OUT
    assertTrue $?
    contains 'ALTER INDEX "public"."t1_pkey" SET TABLESPACE "spc1";' $OUT
    assertTrue $?

    contains ' t1      | $' $OUT
    assertTrue $?
    contains ' t1_pkey | $' $OUT
    assertTrue $?
}

function testSetTablespace004()
{
    OUT=${_SHUNIT_TEST_}.out

    # move t1 to spc1
    pt-set-tablespace $_DEBUG -t t1 --apply spc1 > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains ' t1      | spc1$' $OUT
    assertTrue $?
    contains ' t1_pkey | spc1$' $OUT
    assertTrue $?
}

function testSetTablespace005()
{
    OUT=${_SHUNIT_TEST_}.out

    # move t1 back to pg_default
    pt-set-tablespace $_DEBUG --table t1 --apply pg_default > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains ' t1      | $' $OUT
    assertTrue $?
    contains ' t1_pkey | $' $OUT
    assertTrue $?
}

# ------------------------------------------
# regular expressions
# ------------------------------------------
function testSetTablespace006()
{
    OUT=${_SHUNIT_TEST_}.out

    #_DEBUG="--debug"
    pt-set-tablespace $_DEBUG -o /^$USER/ spc1 > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains 'ALTER TABLE "public"."t1" SET TABLESPACE "spc1";' $OUT
    assertTrue $?
    contains 'ALTER INDEX "public"."t1_pkey" SET TABLESPACE "spc1";' $OUT
    assertTrue $?

    contains ' t1      | $' $OUT
    assertTrue $?
    contains ' t1_pkey | $' $OUT
    assertTrue $?
}

function testSetTablespace007()
{
    OUT=${_SHUNIT_TEST_}.out

    #_DEBUG="--debug"
    pt-set-tablespace $_DEBUG -n /^public/ spc1 > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains 'ALTER TABLE "public"."t1" SET TABLESPACE "spc1";' $OUT
    assertTrue $?
    contains 'ALTER INDEX "public"."t1_pkey" SET TABLESPACE "spc1";' $OUT
    assertTrue $?

    contains ' t1      | $' $OUT
    assertTrue $?
    contains ' t1_pkey | $' $OUT
    assertTrue $?
}

function testSetTablespace008()
{
    OUT=${_SHUNIT_TEST_}.out

    #_DEBUG="--debug"
    pt-set-tablespace $_DEBUG -t /^t/ spc1 > $OUT 2>&1

    psql<<EOF >> $OUT
SELECT relname,spcname FROM pg_class c LEFT OUTER JOIN pg_tablespace t ON c.reltablespace = t.oid WHERE relname LIKE 't1%';
EOF

    contains 'ALTER TABLE "public"."t1" SET TABLESPACE "spc1";' $OUT
    assertTrue $?
    contains 'ALTER INDEX "public"."t1_pkey" SET TABLESPACE "spc1";' $OUT
    assertTrue $?

    contains ' t1      | $' $OUT
    assertTrue $?
    contains ' t1_pkey | $' $OUT
    assertTrue $?
}

. shunit2
