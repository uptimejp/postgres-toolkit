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

function testArchiveXlog001()
{
    OUT=${_SHUNIT_TEST_}.out

    pt-archive-xlog --help > $OUT
    assertEquals 1 $?

    cat<<EOF >${_SHUNIT_TEST_}.expected
Usage: pt-archive-xlog [XLOGFILEPATH] [DESTDIR]
EOF

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testArchiveXlog002()
{
    OUT=${_SHUNIT_TEST_}.out

    rm -rf /tmp/arch
    mkdir -p /tmp/arch

    # copying for the first time. (success)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 0 $?
}

function testArchiveXlog003()
{
    OUT=${_SHUNIT_TEST_}.out

    # found the same file in the destination. (success)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 0 $?
}

function testArchiveXlog004()
{
    OUT=${_SHUNIT_TEST_}.out

    cat /dev/null > /tmp/arch/000000010000000000000001

    # found a broken file in the destination. (failure)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 1 $?
}

function testArchiveXlog005()
{
    OUT=${_SHUNIT_TEST_}.out

    # file not found. (failure)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000011 /tmp/arch > $OUT
    assertEquals 1 $?
}

function testArchiveXlog006()
{
    OUT=${_SHUNIT_TEST_}.out

    rm -f /tmp/arch/000000010000000000000001
    chmod 000 ${PGDATA}/pg_xlog/000000010000000000000001

    # (source) permission denied. (failure)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 1 $?

    chmod 644 ${PGDATA}/pg_xlog/000000010000000000000001
}

function testArchiveXlog007()
{
    OUT=${_SHUNIT_TEST_}.out

    rm -f /tmp/arch/000000010000000000000001
    chmod 555 /tmp/arch

    # (target) permission denied. (failure)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 1 $?

    chmod 755 /tmp/arch
}

function testArchiveXlog008()
{
    OUT=${_SHUNIT_TEST_}.out

    rm -rf /tmp/arch

    # directory not found. (failure)
    pt-archive-xlog ${PGDATA}/pg_xlog/000000010000000000000001 /tmp/arch > $OUT
    assertEquals 1 $?
}

. shunit2
