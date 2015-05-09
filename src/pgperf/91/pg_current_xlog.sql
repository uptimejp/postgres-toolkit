SELECT 0::int as sid,
       pg_current_xlog_location() AS location,
       pg_current_xlog_insert_location() AS insert_location;
