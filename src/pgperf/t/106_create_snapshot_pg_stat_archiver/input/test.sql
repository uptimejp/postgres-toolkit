SELECT pgperf.create_snapshot_pg_stat_archiver(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.create_snapshot_pg_stat_archiver(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.create_snapshot_pg_stat_archiver(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.delete_snapshot_pg_stat_archiver(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.delete_snapshot_pg_stat_archiver(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;

SELECT pgperf.delete_snapshot_pg_stat_archiver(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_bgwriter;
