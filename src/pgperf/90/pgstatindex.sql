SELECT 0::int as sid,
       schemaname,
       relname,
       indexrelname,
       (pgstatindex).version,
       (pgstatindex).tree_level,
       (pgstatindex).index_size,
       (pgstatindex).root_block_no,
       (pgstatindex).internal_pages,
       (pgstatindex).leaf_pages,
       (pgstatindex).empty_pages,
       (pgstatindex).deleted_pages,
       (pgstatindex).avg_leaf_density,
       (pgstatindex).leaf_fragmentation
  FROM ( SELECT schemaname,
                relname,
                indexrelname,
                pgstatindex(schemaname || '.' || indexrelname)
           FROM pg_stat_user_indexes
          WHERE schemaname NOT IN ('pg_catalog', 'pg_toast', 'information_schema') ) AS p;
