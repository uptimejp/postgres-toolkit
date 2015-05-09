SELECT pgperf.create_snapshot_pg_stat_database(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;

SELECT pgperf.create_snapshot_pg_stat_database(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;

SELECT pgperf.create_snapshot_pg_stat_database(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;

SELECT pgperf.delete_snapshot_pg_stat_database(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;

SELECT pgperf.delete_snapshot_pg_stat_database(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;

SELECT pgperf.delete_snapshot_pg_stat_database(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_database;
