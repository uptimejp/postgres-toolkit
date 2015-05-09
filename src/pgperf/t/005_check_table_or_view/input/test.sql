-- table
SELECT pgperf._check_table_or_view('pg_database');
-- view
SELECT pgperf._check_table_or_view('pg_stat_activity');

SELECT pgperf._check_table_or_view('nosuchtableorview');
