SELECT 0::int as sid,
       funcid,
       schemaname,
       funcname,
       calls,
       total_time,
       self_time
  FROM pg_stat_user_functions
 WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
