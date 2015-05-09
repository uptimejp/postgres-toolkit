SELECT 0::int AS sid,
       schemaname,
       tablename,
       attname,
       inherited,
       null_frac,
       avg_width,
       n_distinct,
       most_common_vals::text,
       most_common_freqs,
       histogram_bounds::text,
       correlation
  FROM pg_stats;

