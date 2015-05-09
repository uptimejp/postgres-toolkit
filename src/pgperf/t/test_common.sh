_PATH=$PATH

PATH=${PGHOME}/bin:$PATH
export PATH

LANG=C
export LANG

PGPORT=5433
export PGPORT

function _initdb()
{
    CONF=$1

    rm -rf $PGDATA
    mkdir $PGDATA
    initdb -D $PGDATA --no-locale -E utf-8 $_INITDB_OPTS

    if [ -f $CONF ]; then
	echo "Adding $CONF to postgresql.conf"
	cat $CONF >> ${PGDATA}/postgresql.conf
    fi
}

function _pgctl_start()
{
    pg_ctl -D ${PGDATA} -w start
}

function _pgctl_stop()
{
    pg_ctl -D ${PGDATA} -w stop
}

function _install_pg_stat_statements()
{
    DBNAME=$1

    if [ -d $PGHOME/share/contrib ]; then
	psql -f $PGHOME/share/contrib/pg_stat_statements.sql $DBNAME
	if [ $? -ne 0 ]; then
	    echo "Failed to install pg_stat_statements."
	    exit 1
	fi
    else
	psql -c 'create extension pg_stat_statements' $DBNAME
	if [ $? -ne 0 ]; then
	    echo "Failed to install pg_stat_statements."
	    exit 1
	fi
    fi
}

function _install_pgstattuple()
{
    DBNAME=$1

    if [ -d $PGHOME/share/contrib ]; then
	psql -f $PGHOME/share/contrib/pgstattuple.sql $DBNAME
	if [ $? -ne 0 ]; then
	    echo "Failed to install pgstattuple."
	    exit 1
	fi
    else
	psql -c 'create extension pgstattuple' $DBNAME
	if [ $? -ne 0 ]; then
	    echo "Failed to install pgstattuple."
	    exit 1
	fi
    fi
}

function _get_version()
{
    _MAJORVERSION=`pg_config --version | perl -e 's/.* (\d+\.\d+).*/\1/;' -p`
    export _MAJORVERSION

    _MAJOR_STR=`echo $_MAJORVERSION | sed 's/\.//'`
    export _MAJOR_STR
}

function load_file()
{
    DBNAME=$1;
    FILENAME=$2;

    if [ -f $FILENAME ]; then
	echo "Loading ${FILENAME} ..."
	psql -f $FILENAME $DBNAME
	if [ $? -ne 0 ]; then
	    echo "Failed to run $FILENAME on $DBNAME.".
	    exit 1
	fi
    else
	echo "ERROR: $FILENAME not found."
	exit 1
    fi
}

