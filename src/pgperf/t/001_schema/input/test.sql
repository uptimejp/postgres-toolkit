select nspname from pg_namespace where nspname = 'pgperf';

set search_path to pgperf;

\a
\f ' | '

\d

\a
\f ' | '

\d pgperf.snapshot

