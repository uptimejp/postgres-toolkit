SELECT pgperf.create_snapshot_pg_stat_database_conflicts(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;

SELECT pgperf.create_snapshot_pg_stat_database_conflicts(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;

SELECT pgperf.create_snapshot_pg_stat_database_conflicts(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;

SELECT pgperf.delete_snapshot_pg_stat_database_conflicts(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;

SELECT pgperf.delete_snapshot_pg_stat_database_conflicts(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;

SELECT pgperf.delete_snapshot_pg_stat_database_conflicts(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database_conflicts;
