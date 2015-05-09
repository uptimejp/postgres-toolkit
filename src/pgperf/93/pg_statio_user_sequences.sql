SELECT 0::int as sid,
       relid,
       schemaname,
       relname,
       blks_read,
       blks_hit
  FROM pg_statio_user_sequences
 WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema');
