CREATE FUNCTION f1() RETURNS BOOLEAN
 AS
'
BEGIN
   RETURN true;
END
' LANGUAGE 'plpgsql';

SELECT f1();

SELECT pg_sleep(1);

SELECT pgperf.create_snapshot_pg_stat_user_functions(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot_pg_stat_user_functions(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot_pg_stat_user_functions(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_stat_user_functions(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_stat_user_functions(2);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.delete_snapshot_pg_stat_user_functions(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

DROP FUNCTION f1();

