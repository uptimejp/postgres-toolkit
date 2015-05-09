#!/bin/sh

source ./test_common.sh

function _setUp()
{
    PGHOME=$1
    PGDATA=$2
    INSTALLFILE=$3
    PATH=..:${PGHOME}/bin:$_PATH
    export PGHOME PGDATA PATH

    killall postgres

    _initdb _postgresql.conf
    _pgctl_start

    createdb testdb
    if [ $? -ne 0 ]; then
	echo "Failed to create a database."
	exit 1
    fi

    _install_pg_stat_statements testdb
    _install_pgstattuple testdb

    psql -f ${INSTALLFILE} testdb
    if [ $? -ne 0 ]; then
	echo "Failed to run ${INSTALLFILE}."
	exit 1
    fi

}

function _tearDown()
{
    PGHOME=$1
    PGDATA=$2
    PATH=..:${PGHOME}/bin:$_PATH
    export PGHOME PGDATA PATH

    _pgctl_stop
}


function _test()
{
    _t=$1
    echo "${_t}..."

    ./${_t}.sh
}

function testsuite()
{
    PGHOME=$1
    PGDATA=$2
    OUTDIR=$3
    PATH=..:${PGHOME}/bin:$_PATH
    export PGHOME PGDATA PATH

    _MAJORVERSION=`pg_config --version | perl -e 's/.* (\d+\.\d+).*/\1/;' -p`
    export _MAJORVERSION

    _MAJOR_STR=`echo $_MAJORVERSION | sed 's/\.//'`
    export _MAJOR_STR

    _setUp $PGHOME $PGDATA ../pgperf_snapshot_install${_MAJOR_STR}.sql > setup${_MAJOR_STR}.log 2>&1

    echo "=========================================="
    echo "PGHOME: $PGHOME"
    echo "PGDATA: $PGDATA"
    echo "PATH: $PATH"
    echo "MAJORVERSION: $_MAJORVERSION"
    echo "=========================================="

    ./regress2.sh
    if [ $? -ne 0 ]; then
	echo "ERROR: Regression test failed."
	exit 1
    fi
#    for t in $T; do
#	_test $t;
#    done;

    _tearDown $PGHOME $PGDATA > teardown${_MAJOR_STR}.log 2>&1

    rm -rf $OUTDIR
    mkdir -p $OUTDIR
    mv *.log $OUTDIR
}

rm -rf *.log *.out

# -------------------------------------------------------
# 9.0
# -------------------------------------------------------
cat /dev/null > _postgresql.conf
echo "track_functions = all" >> _postgresql.conf
echo "shared_preload_libraries = 'pg_stat_statements'" >> _postgresql.conf
testsuite /usr/pgsql-9.0 ./data90 ./out90

# -------------------------------------------------------
# 9.1
# -------------------------------------------------------
testsuite /usr/pgsql-9.1 ./data91 ./out91

# -------------------------------------------------------
# 9.2
# -------------------------------------------------------
echo "track_io_timing = on" >> _postgresql.conf
testsuite /usr/pgsql-9.2 ./data92 ./out92

# -------------------------------------------------------
# 9.3
# -------------------------------------------------------
# Checksum support
_INITDB_OPTS="-k"
testsuite /usr/pgsql-9.3 ./data93 ./out93

# -------------------------------------------------------
# 9.4
# -------------------------------------------------------
testsuite /usr/pgsql-9.4 ./data94 ./out94
