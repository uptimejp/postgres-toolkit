#!/bin/sh

rm -f result.diff

rm -rf ok.log failed.log

./test.sh 001_schema
./test.sh 002_procs
./test.sh 003_get_server_version
./test.sh 004_check_function
./test.sh 005_check_table_or_view

./test.sh 101_create_snapshot_pg_current_xlog
./test.sh 102_create_snapshot_pg_database_size
./test.sh 103_create_snapshot_pg_locks
./test.sh 104_create_snapshot_pg_relation_size
./test.sh 105_create_snapshot_pg_stat_activity
./test.sh 106_create_snapshot_pg_stat_archiver
./test.sh 107_create_snapshot_pg_stat_bgwriter
./test.sh 108_create_snapshot_pg_stat_database
./test.sh 109_create_snapshot_pg_stat_database_conflicts
./test.sh 110_create_snapshot_pg_stat_replication
./test.sh 111_create_snapshot_pg_stat_statements
./test.sh 111_create_snapshot_pg_stat_user_functions
./test.sh 112_create_snapshot_pg_stat_user_indexes
./test.sh 113_create_snapshot_pg_stat_user_tables
./test.sh 114_create_snapshot_pg_statio_user_indexes
./test.sh 114_create_snapshot_pg_statio_user_sequences
./test.sh 115_create_snapshot_pg_statio_user_tables
./test.sh 116_create_snapshot_pg_stats
./test.sh 117_create_snapshot_pgstatindex
./test.sh 118_create_snapshot_pgstattuple

./test.sh 201_create_snapshot

# if not exist, create them.
touch ok.log failed.log

REGRESS_SUCCESS=`wc -l <ok.log`
REGRESS_FAILED=`wc -l <failed.log`
REGRESS_TOTAL=`expr $REGRESS_SUCCESS + $REGRESS_FAILED`

echo -----------------------------------------
echo Passed:$REGRESS_SUCCESS  Failed:$REGRESS_FAILED  Total:$REGRESS_TOTAL
echo -----------------------------------------

rm -rf ok.log failed.log

if [ $REGRESS_FAILED -ne 0 ]; then
  exit 1
else
  exit 0
fi

