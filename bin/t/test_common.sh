function contains()
{
    STRING=$1
    FILE=$2

    grep "$STRING" $FILE >> contains.log
    # found
    if [ $? -eq 0 ]; then
	# 0
	return ${SHUNIT_TRUE}
    # not found
    elif [ $? -eq 1 ]; then
	# 1
	return ${SHUNIT_FALSE}
    # error
    else
	# 2
	return ${SHUNIT_ERROR}
    fi
}

function install_pg_stat_statements()
{
    _SHARE_DIR=`$PGHOME/bin/pg_config --sharedir`

    if [ -f $_SHARE_DIR/contrib/pg_stat_statements.sql ]; then
	psql -f $_SHARE_DIR/contrib/pg_stat_statements.sql
    else
	psql -c 'create extension pg_stat_statements'
    fi
}

function install_pgstattuple()
{
    _SHARE_DIR=`$PGHOME/bin/pg_config --sharedir`

    if [ -f $_SHARE_DIR/contrib/pgstattuple.sql ]; then
	psql -f $_SHARE_DIR/contrib/pgstattuple.sql
    else
	psql -c 'create extension pgstattuple'
    fi
}


