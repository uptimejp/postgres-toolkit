SELECT 0::int as sid,
       relid,
       indexrelid,
       schemaname,
       relname,
       indexrelname,
       idx_scan,
       idx_tup_read,
       idx_tup_fetch
  FROM pg_stat_user_indexes
 WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
