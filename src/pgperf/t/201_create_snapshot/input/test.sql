CREATE FUNCTION f1() RETURNS BOOLEAN
 AS
'
BEGIN
   RETURN true;
END
' LANGUAGE 'plpgsql';

SELECT f1();

CREATE TABLE t1 ( uid INTEGER PRIMARY KEY, uname TEXT NOT NULL );
INSERT INTO t1 VALUES ( 101, 'Park Gyu-Ri' );
INSERT INTO t1 VALUES ( 102, 'Han Seung-Yeon' );
INSERT INTO t1 VALUES ( 103, 'Nicole' );
INSERT INTO t1 VALUES ( 104, 'Koo Ha-Ra' );
INSERT INTO t1 VALUES ( 105, 'Kang Ji-Young' );

CREATE SEQUENCE s1;
SELECT nextval('s1');

ANALYZE t1;
ANALYZE s1;

SELECT pg_sleep(1);

-- Snapshot Level 1
SELECT count(*) FROM pgperf.snapshot;
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_tables WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot(1);

SELECT count(*) FROM pgperf.snapshot;
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_tables WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_sequences WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pg_stat_user_functions WHERE schemaname <> 'pgperf';

-- Snapshot Level 2
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.create_snapshot(2);

SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

-- Snapshot Level 4
SELECT count(*) FROM pgperf.snapshot_pgstattuple WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pgstatindex WHERE schemaname <> 'pgperf';

SELECT pgperf.create_snapshot(4);

SELECT count(*) FROM pgperf.snapshot_pgstattuple WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pgstatindex WHERE schemaname <> 'pgperf';

SELECT count(*) FROM pgperf.snapshot;

SELECT sid,level FROM pgperf.snapshot order by ts;

-- Delete Snapshot Level 4
SELECT pgperf.delete_snapshot(2);

SELECT count(*) FROM pgperf.snapshot_pgstattuple WHERE schemaname <> 'pgperf';
SELECT count(*) FROM pgperf.snapshot_pgstatindex WHERE schemaname <> 'pgperf';

-- Delete Snapshot Level 2
SELECT pgperf.delete_snapshot(1);

SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

-- Delete Snapshot Level 1
SELECT pgperf.delete_snapshot(0);

SELECT count(*) FROM pgperf.snapshot;
SELECT count(*) FROM pgperf.snapshot_pg_statio_user_tables WHERE schemaname <> 'pgperf';

DROP TABLE t1;
DROP SEQUENCE s1;
DROP FUNCTION f1();

