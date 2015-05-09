SELECT 0::int as sid,
       schemaname,
       relid,
       relname,
       pg_relation_size(relid),
       pg_total_relation_size(relid)
  FROM pg_stat_user_tables
 WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
