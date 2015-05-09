SELECT pg_stat_statements_reset();

SELECT pgperf.create_snapshot_pg_stat_statements(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_statements;

SELECT pgperf.create_snapshot_pg_stat_statements(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_statements;

SELECT pgperf.delete_snapshot_pg_stat_statements(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_statements;

SELECT pgperf.delete_snapshot_pg_stat_statements(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_statements;
