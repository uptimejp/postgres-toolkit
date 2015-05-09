#!/bin/sh

source ./test_common.sh

function setUp()
{
    PGHOME=$1
    PGDATA=$2

    export PGHOME PGDATA

    source ./test_common.sh

    _pgctl_stop

    rm -rf $PGDATA
    _initdb /dev/null
    if [ $? -ne 0 ]; then
	exit 1
    fi
    
    _pgctl_start
    
    createdb testdb
    if [ $? -ne 0 ]; then
	exit 1
    fi
    
    _install_pg_stat_statements testdb
    if [ $? -ne 0 ]; then
	exit 1
    fi

    _install_pgstattuple testdb
    if [ $? -ne 0 ]; then
	exit 1
    fi

    _get_version
}

function tearDown()
{
    PGHOME=$1
    PGDATA=$2

    export PGHOME PGDATA

    _pgctl_stop
    if [ $? -ne 0 ]; then
	exit 1
    fi
}

function get_catalog()
{
    PGHOME=$1
    PGDATA=$2
    OUTFILE=$3

    rm -rf $PGDATA
    setUp $PGHOME $PGDATA
    if [ $? -ne 0 ]; then
	echo "ERROR: SetUp failed."
	exit 1
    fi

    ./catalog.pl | psql -A -t -F' ' testdb | grep -v SELECT > $OUTFILE

    tearDown $PGHOME $PGDATA
    if [ $? -ne 0 ]; then
	echo "ERROR: TearDown failed."
	exit 1
    fi
}

get_catalog /usr/pgsql-9.0 ./data90 catalog90.txt
get_catalog /usr/pgsql-9.1 ./data91 catalog91.txt
get_catalog /usr/pgsql-9.2 ./data92 catalog92.txt
get_catalog /usr/pgsql-9.3 ./data93 catalog93.txt
get_catalog /usr/pgsql-9.4 ./data94 catalog94.txt

exit 0
