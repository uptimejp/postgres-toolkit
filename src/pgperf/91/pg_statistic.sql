SELECT 0::int as sid,
       s.starelid,
       c.relname as starelname,
       s.staattnum,
       a.attname as staattname,
       s.stainherit,
       s.stanullfrac,
       s.stawidth,
       s.stadistinct,
       s.stakind1,
       s.stakind2,
       s.stakind3,
       s.stakind4,
       s.staop1,
       s.staop2,
       s.staop3,
       s.staop4,
       s.stanumbers1,
       s.stanumbers2,
       s.stanumbers3,
       s.stanumbers4,
       s.stavalues1::TEXT,
       s.stavalues2::TEXT,
       s.stavalues3::TEXT,
       s.stavalues4::TEXT
  FROM pg_statistic s, pg_class c, pg_namespace n, pg_attribute a
 WHERE n.nspname NOT IN ('pg_catalog', 'pg_toast', 'information_schema')
   AND n.oid = c.relnamespace
   AND c.oid = s.starelid
   AND a.attnum = s.staattnum
   AND a.attrelid = s.starelid;
