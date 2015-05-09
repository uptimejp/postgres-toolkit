SELECT pgperf.create_snapshot_pg_stat_replication(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;

SELECT pgperf.create_snapshot_pg_stat_replication(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;

SELECT pgperf.create_snapshot_pg_stat_replication(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;

SELECT pgperf.delete_snapshot_pg_stat_replication(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;

SELECT pgperf.delete_snapshot_pg_stat_replication(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;

SELECT pgperf.delete_snapshot_pg_stat_replication(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_replication;
