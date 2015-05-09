-- Create
SELECT pgperf.create_snapshot_pg_locks(0);
SELECT count(*) FROM pgperf.snapshot_pg_locks;

SELECT pgperf.create_snapshot_pg_locks(1);
SELECT count(*) FROM pgperf.snapshot_pg_locks;

SELECT pgperf.create_snapshot_pg_locks(2);
SELECT count(*) FROM pgperf.snapshot_pg_locks;

-- Delete
SELECT pgperf.delete_snapshot_pg_locks(1);
SELECT count(*) FROM pgperf.snapshot_pg_locks;

SELECT pgperf.delete_snapshot_pg_locks(2);
SELECT count(*) FROM pgperf.snapshot_pg_locks;

SELECT pgperf.delete_snapshot_pg_locks(0);
SELECT count(*) FROM pgperf.snapshot_pg_locks;
