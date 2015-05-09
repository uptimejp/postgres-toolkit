SELECT 0::int as sid,
       archived_count,
       last_archived_wal,
       last_archived_time,
       failed_count,
       last_failed_wal,
       last_failed_time,
       stats_reset
  FROM pg_stat_archiver;
