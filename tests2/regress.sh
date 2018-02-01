#!/bin/bash

_PATH=$PATH
LANG=C
export LANG

PGPORT=5433
export PGPORT

T="test-pt-archive-xlog \
   test-pt-config \
   test-pt-index-usage \
   test-pt-kill \
   test-pt-proc-stat \
   test-pt-replication-stat \
   test-pt-session-profiler \
   test-pt-set-tablespace \
   test-pt-show-locks \
   test-pt-snap-statements \
   test-pt-stat-snapshot \
   test-pt-table-usage \
   test-pt-tablespace-usage \
   test-pt-verify-checksum \
   test-pt-xact-stat"

function _setUp()
{
    PGHOME=$1
    PGDATA=$2
    PATH=..:${PGHOME}/bin:$_PATH
    export PGHOME PGDATA PATH

    killall postgres

    echo "Initializing a master..."
    rm -rf $PGDATA /tmp/spc1
    mkdir $PGDATA /tmp/spc1
    initdb -D $PGDATA --no-locale -E utf-8 $_INITDB_OPTS

    cat _postgresql.conf >> ${PGDATA}/postgresql.conf
    echo "host    replication     $USER        127.0.0.1/32            trust" >> ${PGDATA}/pg_hba.conf

    pg_ctl -D ${PGDATA} -w start -o "-p ${PGPORT}"
    createdb testdb

    # add a replica/slave
    echo "Adding a slave..."

    rm -rf ${PGDATA}_slave

    psql -c 'checkpoint' postgres

    if [ $_MAJORVERSION == "9.0" ]; then
	# pg_basebackup does not support 9.0
	psql -c "select pg_start_backup('regress')" postgres
	cp -rv ${PGDATA} ${PGDATA}_slave
	rm -f ${PGDATA}_slave/postmaster.pid
	psql -c "select pg_stop_backup()" postgres
    else
	pg_basebackup -h 127.0.0.1 -p ${PGPORT} -U $USER -D ${PGDATA}_slave --xlog --progress --verbose
    fi	

    echo "standby_mode = 'on'" > recovery.conf
    echo "primary_conninfo = 'host=127.0.0.1 port=${PGPORT} user=$USER application_name=slave'" >> recovery.conf

    cat recovery.conf
    mv -v recovery.conf ${PGDATA}_slave

    _PORT=`expr $PGPORT + 1`
    echo pg_ctl -w -D ${PGDATA}_slave start -o -p${_PORT}
    pg_ctl -w -D ${PGDATA}_slave start -o "-p ${_PORT}"
}


function _tearDown()
{
    PGHOME=$1
    PGDATA=$2
    PATH=..:${PGHOME}/bin:$_PATH
    export PGHOME PGDATA PATH

    pg_ctl -D ${PGDATA}_slave -w stop
    pg_ctl -D ${PGDATA} -w stop
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

    _setUp $PGHOME $PGDATA > setup.log 2>&1

    echo "=========================================="
    echo "PGHOME: $PGHOME"
    echo "PGDATA: $PGDATA"
    echo "PATH: $PATH"
    echo "=========================================="

    _SUCCEEDED=0
    _FAILED=0

    for t in $T; do
	./${t}.sh
	if [ $? -ne 0 ]; then
	    _FAILED=`expr $_FAILED + 1`
	else
	    _SUCCEEDED=`expr $_SUCCEEDED + 1`
	fi
    done;

    _tearDown $PGHOME $PGDATA > teardown.log 2>&1

    rm -rf $OUTDIR
    mkdir -p $OUTDIR
    cp setup.log teardown.log *.out $OUTDIR

    echo ==========================================
    echo Version: $_MAJORVERSION, Succeeded: $_SUCCEEDED, Failed: $_FAILED
    echo ==========================================
}

rm -rf *.out

# -------------------------------------------------------
# 9.0
# -------------------------------------------------------
cat /dev/null > _postgresql.conf
echo "shared_preload_libraries = 'pg_stat_statements'" >> _postgresql.conf
echo "wal_level = 'hot_standby'" >> _postgresql.conf
echo "wal_keep_segments = 8" >> _postgresql.conf
echo "max_wal_senders = 2" >> _postgresql.conf
echo "hot_standby = on" >> _postgresql.conf
if [ -d /usr/pgsql-9.0 ]; then
  # RHEL/CentOS
  testsuite /usr/pgsql-9.0 ./data90 ./out90
elif [ -d /usr/lib/postgresql/9.0 ]; then
  # Ubuntu
  testsuite /usr/lib/postgresql/9.0 ./data90 ./out90
else
  echo "passing the regression tests for 9.0"
fi

# -------------------------------------------------------
# 9.1
# -------------------------------------------------------
if [ -d /usr/pgsql-9.1 ]; then
  # RHEL/CentOS
  testsuite /usr/pgsql-9.1 ./data91 ./out91
elif [ -d /usr/lib/postgresql/9.1 ]; then
  # Ubuntu
  testsuite /usr/lib/postgresql/9.1 ./data91 ./out91
else
  echo "passing the regression tests for 9.1"
fi

# -------------------------------------------------------
# 9.2
# -------------------------------------------------------
echo "track_io_timing = on" >> _postgresql.conf
if [ -d /usr/pgsql-9.2 ]; then
  # RHEL/CentOS
  testsuite /usr/pgsql-9.2 ./data92 ./out92
elif [ -d /usr/lib/postgresql/9.2 ]; then
  # Ubuntu
  testsuite /usr/lib/postgresql/9.2 ./data92 ./out92
else
  echo "passing the regression tests for 9.2"
fi

# -------------------------------------------------------
# 9.3
# -------------------------------------------------------
# Checksum support
_INITDB_OPTS="-k"
if [ -d /usr/pgsql-9.3 ]; then
  # RHEL/CentOS
  testsuite /usr/pgsql-9.3 ./data93 ./out93
elif [ -d /usr/lib/postgresql/9.3 ]; then
  # Ubuntu
  testsuite /usr/lib/postgresql/9.3 ./data93 ./out93
else
  echo "passing the regression tests for 9.3"
fi

# -------------------------------------------------------
# 9.4
# -------------------------------------------------------
if [ -d /usr/pgsql-9.4 ]; then
  # RHEL/CentOS
  testsuite /usr/pgsql-9.4 ./data94 ./out94
elif [ -d /usr/lib/postgresql/9.4 ]; then
  # Ubuntu
  testsuite /usr/lib/postgresql/9.4 ./data94 ./out94
else
  echo "passing the regression tests for 9.4"
fi
