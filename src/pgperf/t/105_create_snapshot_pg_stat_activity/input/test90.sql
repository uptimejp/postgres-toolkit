-- create 1st snapshot
SELECT pgperf.create_snapshot_pg_stat_activity(0);
SELECT count(*) FROM pgperf.snapshot_pg_stat_activity;

-- \x
-- SELECT * FROM pgperf.snapshot_pg_stat_activity;
-- \x

SELECT count(*) = 1
  FROM pgperf.snapshot_pg_stat_activity
 WHERE sid = 0
   AND datid IS NOT NULL
   AND datname = 'testdb'
   AND procpid IS NOT NULL
   AND usesysid IS NOT NULL
   AND usename IS NOT NULL
   AND application_name = 'psql'
   AND client_port IS NOT NULL
   AND backend_start < now()
   AND xact_start < now()
   AND query_start < now()
   AND waiting = false
   AND current_query = 'SELECT pgperf.create_snapshot_pg_stat_activity(0);';

-- create 2nd snapshot
SELECT pgperf.create_snapshot_pg_stat_activity(1);
SELECT count(*) FROM pgperf.snapshot_pg_stat_activity;

SELECT b.sid - a.sid = 1,
       b.datid = a.datid,
       b.datname = a.datname,
       b.procpid = a.procpid,
       b.usesysid = a.usesysid,
       b.usename = a.usename,
       b.application_name = a.application_name,
       b.client_port = a.client_port,
       (b.backend_start - a.backend_start) = '0'::interval,
       (b.xact_start - a.xact_start) > '0'::interval,
       (b.query_start - a.query_start) > '0'::interval,
       b.waiting = a.waiting,
       b.current_query = 'SELECT pgperf.create_snapshot_pg_stat_activity(1);'
  FROM ( SELECT * FROM pgperf.snapshot_pg_stat_activity WHERE sid = 0 ) AS a,
       ( SELECT * FROM pgperf.snapshot_pg_stat_activity WHERE sid = 1 ) AS b
;

-- create 3rd snapshot
SELECT pgperf.create_snapshot_pg_stat_activity(2);
SELECT count(*) = 3 FROM pgperf.snapshot_pg_stat_activity;

-- delete 1st snapshot
SELECT pgperf.delete_snapshot_pg_stat_activity(1);
SELECT count(*) = 0 FROM pgperf.snapshot_pg_stat_activity WHERE sid = 1;
SELECT count(*) = 2 FROM pgperf.snapshot_pg_stat_activity;
