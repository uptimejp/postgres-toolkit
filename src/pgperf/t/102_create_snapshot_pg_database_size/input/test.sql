SELECT pgperf.create_snapshot_pg_database_size(0);
SELECT pgperf.create_snapshot_pg_database_size(1);

SELECT count(*) FROM pgperf.snapshot_pg_database_size;

SELECT pgperf.delete_snapshot_pg_database_size(1);
SELECT count(*) FROM pgperf.snapshot_pg_database_size;

SELECT pgperf.delete_snapshot_pg_database_size(0);
SELECT count(*) FROM pgperf.snapshot_pg_database_size;

