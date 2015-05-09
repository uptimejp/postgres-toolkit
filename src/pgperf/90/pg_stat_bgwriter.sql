SELECT 0::int as sid,
       checkpoints_timed,
       checkpoints_req,
       buffers_checkpoint,
       buffers_clean,
       maxwritten_clean,
       buffers_backend,
       buffers_alloc
  FROM pg_stat_bgwriter;
