SELECT * FROM pgperf.snapshot_pg_current_xlog ORDER BY 1;

SELECT pgperf.create_snapshot_pg_current_xlog(0);
SELECT pgperf.create_snapshot_pg_current_xlog(1);

WITH s0 AS (
SELECT * FROM pgperf.snapshot_pg_current_xlog WHERE sid = 0
), s1 AS (
SELECT * FROM pgperf.snapshot_pg_current_xlog WHERE sid = 1
)
SELECT s0.location < s1.location, s0.insert_location < s1.insert_location
  FROM s0, s1
 WHERE s0.sid + 1 = s1.sid;

SELECT count(*) FROM pgperf.snapshot_pg_current_xlog;

SELECT pgperf.delete_snapshot_pg_current_xlog(1);

SELECT count(*) FROM pgperf.snapshot_pg_current_xlog;

SELECT pgperf.delete_snapshot_pg_current_xlog(0);

SELECT count(*) FROM pgperf.snapshot_pg_current_xlog;

