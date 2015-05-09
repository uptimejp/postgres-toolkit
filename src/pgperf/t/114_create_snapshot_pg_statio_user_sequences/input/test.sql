CREATE SEQUENCE s1;
SELECT nextval('s1');

SELECT pgperf.create_snapshot_pg_statio_user_sequences(0);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot_pg_statio_user_sequences(1);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot_pg_statio_user_sequences(2);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_statio_user_sequences(1);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_statio_user_sequences(2);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_statio_user_sequences(0);
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';

DROP SEQUENCE s1;
