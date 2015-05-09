SELECT 0::int as sid,
       schemaname,
       relname,
       (pgstattuple).table_len,
       (pgstattuple).tuple_count,
       (pgstattuple).tuple_len,
       (pgstattuple).tuple_percent,
       (pgstattuple).dead_tuple_count,
       (pgstattuple).dead_tuple_len,
       (pgstattuple).dead_tuple_percent,
       (pgstattuple).free_space,
       (pgstattuple).free_percent
  FROM ( SELECT schemaname,
                relname,
                pgstattuple(relid)
           FROM pg_stat_user_tables
          WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema') ) AS p;
