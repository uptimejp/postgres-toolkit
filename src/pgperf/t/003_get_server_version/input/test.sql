-- 9.0 to 9.4 is supported.
SELECT pgperf._get_server_version() >= 90;
SELECT pgperf._get_server_version() <= 94;

SELECT pgperf._get_server_version() < 90;
SELECT pgperf._get_server_version() > 94;
