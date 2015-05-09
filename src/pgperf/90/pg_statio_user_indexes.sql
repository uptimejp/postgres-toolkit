SELECT 0::int as sid,
       relid,
       indexrelid,
       schemaname,
       relname,
       indexrelname,
       idx_blks_read,
       idx_blks_hit
  FROM pg_statio_user_indexes
 WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
