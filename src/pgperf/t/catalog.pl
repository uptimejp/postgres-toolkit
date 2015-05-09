#!/usr/bin/perl

use strict;

print <<EOF;
SELECT relname FROM pg_class WHERE relkind IN ('r', 'v') AND relname LIKE E'pg\\_stat%' ORDER BY 1;

CREATE TABLE pgstattuple AS SELECT * FROM pgstattuple('pg_database') LIMIT 0;
CREATE TABLE pgstatindex AS SELECT * FROM pgstatindex('pg_database_datname_index') LIMIT 0;

EOF

my @syscat = (
    "pg_stat_activity",
    "pg_stat_all_indexes",
    "pg_stat_all_tables",
    "pg_stat_archiver",
    "pg_stat_bgwriter",
    "pg_stat_database",
    "pg_stat_database_conflicts",
    "pg_stat_replication",
    "pg_stat_sys_indexes",
    "pg_stat_sys_tables",
    "pg_stat_user_functions",
    "pg_stat_user_indexes",
    "pg_stat_user_tables",
    "pg_stat_xact_all_tables",
    "pg_stat_xact_sys_tables",
    "pg_stat_xact_user_functions",
    "pg_stat_xact_user_tables",
    "pg_statio_all_indexes",
    "pg_statio_all_sequences",
    "pg_statio_all_tables",
    "pg_statio_sys_indexes",
    "pg_statio_sys_sequences",
    "pg_statio_sys_tables",
    "pg_statio_user_indexes",
    "pg_statio_user_sequences",
    "pg_statio_user_tables",
    "pg_locks",
    "pg_statistic",
    "pg_stats",
# contrib views
    "pg_stat_statements",
# contrib functions
    "pgstattuple",
    "pgstatindex"
    );

foreach my $t (@syscat)
{
    print <<EOF;
--
-- $t
--
SELECT c.relname, a.attname, t.typname
  FROM pg_class c, pg_attribute a, pg_type t
 WHERE c.oid=a.attrelid
   AND a.atttypid=t.oid
   AND a.attnum>0
   AND c.relname='$t'
 ORDER BY c.relname,a.attnum;

EOF
}
