#!/bin/bash

PATH=$PATH:..:../../deps/shunit2-2.1.6/src
export PATH

export PGDATABASE=testdb

source ./test_common.sh

function _version_check()
{
    if [ $_MAJORVERSION == "9.0" ]; then
	return 0
    elif [ $_MAJORVERSION == "9.1" ]; then
	return 0
    elif [ $_MAJORVERSION == "9.2" ]; then
	return 0
    fi

    return 1
}

function testVerifyChecksum001()
{
    OUT=${_SHUNIT_TEST_}.out

    _version_check
    if [ $? -eq 0 ]; then
	return ${SHUNIT_TRUE}
    fi

    cat<<EOF > ${_SHUNIT_TEST_}.expected

Usage: pt-verify-checksum [option...] [file]
       pt-verify-checksum [option...] [directory]

Options:
    -r, --recursive            Find files recursively.
    -v, --verbose              Enable verbose output.

    --help                     Print this help.

EOF

    pt-verify-checksum --help > $OUT

    diff -rc ${_SHUNIT_TEST_}.expected $OUT
    assertEquals 0 $?
}

function testVerifyChecksum002()
{
    OUT=${_SHUNIT_TEST_}.out

    _version_check
    if [ $? -eq 0 ]; then
	return ${SHUNIT_TRUE}
    fi

    psql -c 'checkpoint'
    pt-verify-checksum $PGDATA/base/1 > $OUT 2>&1

    if [ $_MAJORVERSION == "9.3" ]; then
	contains 'Verified 2[0-9][0-9] files. 0 files corrupted.' $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains 'Verified 2[0-9][0-9] files. 0 files corrupted.' $OUT
	assertTrue $?
    else
	fail
    fi
}

function testVerifyChecksum003()
{
    OUT=${_SHUNIT_TEST_}.out

    _version_check
    if [ $? -eq 0 ]; then
	return ${SHUNIT_TRUE}
    fi

    psql -c 'checkpoint'
    pt-verify-checksum -r $PGDATA/base > $OUT 2>&1

    if [ $_MAJORVERSION == "9.3" ]; then
	contains 'Verified 9[0-9][0-9] files. 0 files corrupted.' $OUT
	assertTrue $?
    elif [ $_MAJORVERSION == "9.4" ]; then
	contains 'Verified 9[0-9][0-9] files. 0 files corrupted.' $OUT
	assertTrue $?
    else
	fail
    fi
}

. shunit2
