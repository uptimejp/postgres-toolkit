CREATE TABLE t1 ( uid INTEGER PRIMARY KEY, uname TEXT NOT NULL );
INSERT INTO t1 VALUES ( 101, 'Park Gyu-Ri' );
INSERT INTO t1 VALUES ( 102, 'Han Seung-Yeon' );
INSERT INTO t1 VALUES ( 103, 'Nicole' );
INSERT INTO t1 VALUES ( 104, 'Koo Ha-Ra' );
INSERT INTO t1 VALUES ( 105, 'Kang Ji-Young' );

ANALYZE t1;

SELECT pgperf.create_snapshot_pg_stats(0);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.create_snapshot_pg_stats(1);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.create_snapshot_pg_stats(2);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.delete_snapshot_pg_stats(1);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.delete_snapshot_pg_stats(0);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

SELECT pgperf.delete_snapshot_pg_stats(2);
SELECT count(*) FROM pgperf.snapshot_pg_stats WHERE schemaname = 'public';

DROP TABLE t1;
