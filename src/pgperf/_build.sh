#!/bin/bash

function build90()
{
    cat _pgperf_create_role.sql

    echo "BEGIN;"

    cat _pgperf_snapshot_install_common.sql
    
    cd 90
    ../_pgperf.pl pg_stat_bgwriter
    ../_pgperf.pl pg_database_size
    ../_pgperf.pl pg_stat_database
    ../_pgperf.pl pg_relation_size
    ../_pgperf.pl pg_stat_user_tables
    ../_pgperf.pl pg_statio_user_tables
    ../_pgperf.pl pg_stat_user_indexes
    ../_pgperf.pl pg_statio_user_indexes
    ../_pgperf.pl pg_stat_user_functions
    ../_pgperf.pl pg_statio_user_sequences
    ../_pgperf.pl pg_current_xlog
    ../_pgperf.pl pg_stat_activity
    ../_pgperf.pl pg_locks
    ../_pgperf.pl pg_stat_statements
#    ../_pgperf.pl pg_statistic
    ../_pgperf.pl pg_stats
    ../_pgperf.pl pgstattuple
    ../_pgperf.pl pgstatindex
    cd ..
    
    echo "COMMIT;"
}

function build91()
{
    cat _pgperf_create_role.sql

    echo "BEGIN;"

    cat _pgperf_snapshot_install_common.sql
    
    cd 91
    ../_pgperf.pl pg_stat_bgwriter
    ../_pgperf.pl pg_database_size
    ../_pgperf.pl pg_stat_database
    ../_pgperf.pl pg_relation_size
    ../_pgperf.pl pg_stat_user_tables
    ../_pgperf.pl pg_statio_user_tables
    ../_pgperf.pl pg_stat_user_indexes
    ../_pgperf.pl pg_statio_user_indexes
    ../_pgperf.pl pg_stat_user_functions
    ../_pgperf.pl pg_statio_user_sequences
    ../_pgperf.pl pg_current_xlog
    ../_pgperf.pl pg_stat_activity
    ../_pgperf.pl pg_locks
    ../_pgperf.pl pg_stat_replication
    ../_pgperf.pl pg_stat_database_conflicts
    ../_pgperf.pl pg_stat_statements
#    ../_pgperf.pl pg_statistic
    ../_pgperf.pl pg_stats
    ../_pgperf.pl pgstattuple
    ../_pgperf.pl pgstatindex
    cd ..
    
    echo "COMMIT;"
}

function build92()
{
    cat _pgperf_create_role.sql

    echo "BEGIN;"
    
    cat _pgperf_snapshot_install_common.sql
    
    cd 92
    ../_pgperf.pl pg_stat_bgwriter
    ../_pgperf.pl pg_database_size
    ../_pgperf.pl pg_stat_database
    ../_pgperf.pl pg_relation_size
    ../_pgperf.pl pg_stat_user_tables
    ../_pgperf.pl pg_statio_user_tables
    ../_pgperf.pl pg_stat_user_indexes
    ../_pgperf.pl pg_statio_user_indexes
    ../_pgperf.pl pg_stat_user_functions
    ../_pgperf.pl pg_statio_user_sequences
    ../_pgperf.pl pg_current_xlog
    ../_pgperf.pl pg_stat_activity
    ../_pgperf.pl pg_locks
    ../_pgperf.pl pg_stat_replication
    ../_pgperf.pl pg_stat_database_conflicts
    ../_pgperf.pl pg_stat_statements
#    ../_pgperf.pl pg_statistic
    ../_pgperf.pl pg_stats
    ../_pgperf.pl pgstattuple
    ../_pgperf.pl pgstatindex
    cd ..
    
    echo "COMMIT;"
}

function build93()
{
    cat _pgperf_create_role.sql

    echo "BEGIN;"
    
    cat _pgperf_snapshot_install_common.sql

    cd 93
    ../_pgperf.pl pg_stat_bgwriter
    ../_pgperf.pl pg_database_size
    ../_pgperf.pl pg_stat_database
    ../_pgperf.pl pg_relation_size
    ../_pgperf.pl pg_stat_user_tables
    ../_pgperf.pl pg_statio_user_tables
    ../_pgperf.pl pg_stat_user_indexes
    ../_pgperf.pl pg_statio_user_indexes
    ../_pgperf.pl pg_stat_user_functions
    ../_pgperf.pl pg_statio_user_sequences
    ../_pgperf.pl pg_current_xlog
    ../_pgperf.pl pg_stat_activity
    ../_pgperf.pl pg_locks
    ../_pgperf.pl pg_stat_replication
    ../_pgperf.pl pg_stat_database_conflicts
    ../_pgperf.pl pg_stat_statements
#    ../_pgperf.pl pg_statistic
    ../_pgperf.pl pg_stats
    ../_pgperf.pl pgstattuple
    ../_pgperf.pl pgstatindex
    cd ..
    
    echo "COMMIT;"
}

function build94()
{
    cat _pgperf_create_role.sql

    echo "BEGIN;"
    
    cat _pgperf_snapshot_install_common.sql
    
    cd 94
    ../_pgperf.pl pg_stat_archiver
    ../_pgperf.pl pg_stat_bgwriter
    ../_pgperf.pl pg_database_size
    ../_pgperf.pl pg_stat_database
    ../_pgperf.pl pg_relation_size
    ../_pgperf.pl pg_stat_user_tables
    ../_pgperf.pl pg_statio_user_tables
    ../_pgperf.pl pg_stat_user_indexes
    ../_pgperf.pl pg_statio_user_indexes
    ../_pgperf.pl pg_stat_user_functions
    ../_pgperf.pl pg_statio_user_sequences
    ../_pgperf.pl pg_current_xlog
    ../_pgperf.pl pg_stat_activity
    ../_pgperf.pl pg_locks
    ../_pgperf.pl pg_stat_replication
    ../_pgperf.pl pg_stat_database_conflicts
    ../_pgperf.pl pg_stat_statements
#    ../_pgperf.pl pg_statistic
    ../_pgperf.pl pg_stats
    ../_pgperf.pl pgstattuple
    ../_pgperf.pl pgstatindex
    cd ..
    
    echo "COMMIT;"
}

export LANG=C

echo pgperf_snapshot_install90.sql
build90 > pgperf_snapshot_install90.sql

echo pgperf_snapshot_install91.sql
build91 > pgperf_snapshot_install91.sql

echo pgperf_snapshot_install92.sql
build92 > pgperf_snapshot_install92.sql

echo pgperf_snapshot_install93.sql
build93 > pgperf_snapshot_install93.sql

echo pgperf_snapshot_install94.sql
build94 > pgperf_snapshot_install94.sql

