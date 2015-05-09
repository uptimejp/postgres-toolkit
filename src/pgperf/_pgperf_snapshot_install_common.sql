--
-- pgperf snapshot package
--
-- Copyright(C) 2012-2015 Uptime Technologies, LLC.
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 of the License.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License along
-- with this program; if not, write to the Free Software Foundation, Inc.,
-- 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
--
CREATE SCHEMA pgperf;
ALTER SCHEMA pgperf OWNER TO pgperf;

-- 
-- pgperf stat tables
-- 
CREATE TABLE pgperf.snapshot (
    sid INTEGER PRIMARY KEY,
    ts TIMESTAMP NOT NULL,
    level INTEGER NOT NULL
);

CREATE INDEX snapshot_ts_idx on pgperf.snapshot(ts);

ALTER TABLE pgperf.snapshot OWNER TO pgperf;

--
-- Get a major version of the PostgreSQL server.
--
CREATE OR REPLACE FUNCTION pgperf._get_server_version (
) RETURNS INTEGER AS
$$
DECLARE
  _version INTEGER;
BEGIN
  SELECT substr(replace(setting, '.', ''), 1, 2)::integer INTO _version
    FROM pg_settings
   WHERE name = 'server_version';

  IF _version < 90 THEN
    RAISE EXCEPTION 'Unsupported PostgreSQL version: %', _version;
  END IF;

  RETURN _version;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf._get_server_version() OWNER TO pgperf;

--
-- Check if a function exists.
--
CREATE OR REPLACE FUNCTION pgperf._check_function (
  NAME
) RETURNS BOOLEAN AS
$$
DECLARE
  _name ALIAS FOR $1;
  _found BOOLEAN;
BEGIN
  SELECT CASE WHEN count(*)>0 THEN true ELSE false END INTO _found
    FROM pg_proc
   WHERE proname = _name;

  RETURN _found;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf._check_function(NAME) OWNER TO pgperf;

--
-- Check if a table or a view exists.
--
CREATE OR REPLACE FUNCTION pgperf._check_table_or_view (
  NAME
) RETURNS BOOLEAN AS
$$
DECLARE
  _name ALIAS FOR $1;
  _found BOOLEAN;
BEGIN
  SELECT CASE WHEN count(*)>0 THEN true ELSE false END INTO _found
    FROM pg_class
   WHERE relname = _name
     AND (relkind = 'r' OR relkind = 'v');

  RETURN _found;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf._check_table_or_view(NAME) OWNER TO pgperf;

--
-- _is_super()
--
CREATE OR REPLACE FUNCTION pgperf._is_super (
) RETURNS boolean AS
$$
DECLARE
  _is_super BOOLEAN;
BEGIN
  SELECT usesuper INTO _is_super FROM pg_user WHERE usename = CURRENT_USER;
  RETURN _is_super;
END
$$
LANGUAGE 'plpgsql';

--
-- Create a snapshot.
--
CREATE OR REPLACE FUNCTION pgperf.create_snapshot (
  INTEGER
) RETURNS integer AS
$$
DECLARE
  _level ALIAS FOR $1;
  _sid INTEGER;
  _version INTEGER;
  _is_super BOOLEAN;
  _has_pg_stat_statements BOOLEAN;
  _has_pgstattuple BOOLEAN;
BEGIN
  SELECT pgperf._is_super() INTO _is_super;
  SELECT pgperf._check_table_or_view('pg_stat_statements') INTO _has_pg_stat_statements;
  SELECT pgperf._check_function('pgstattuple') INTO _has_pgstattuple;
  SELECT pgperf._get_server_version() INTO _version;

  SELECT max(sid) INTO _sid FROM pgperf.snapshot;
  IF _sid IS NULL THEN
    _sid := 0;
  ELSE
    _sid = _sid + 1;
  END IF;

  INSERT INTO pgperf.snapshot (sid,ts,level) VALUES (_sid, now(), _level);

  PERFORM pgperf.create_snapshot_pg_database_size(_sid);
  PERFORM pgperf.create_snapshot_pg_relation_size(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_bgwriter(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_database(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_user_tables(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_user_indexes(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_user_functions(_sid);
  PERFORM pgperf.create_snapshot_pg_statio_user_tables(_sid);
  PERFORM pgperf.create_snapshot_pg_statio_user_indexes(_sid);
  PERFORM pgperf.create_snapshot_pg_statio_user_sequences(_sid);
  PERFORM pgperf.create_snapshot_pg_current_xlog(_sid);
  PERFORM pgperf.create_snapshot_pg_stat_activity(_sid);
  PERFORM pgperf.create_snapshot_pg_locks(_sid);
  IF _version >= 94 THEN
    PERFORM pgperf.create_snapshot_pg_stat_archiver(_sid);
  END IF;

  IF _has_pg_stat_statements = true THEN
    PERFORM pgperf.create_snapshot_pg_stat_statements(_sid);
  END IF;

  IF _level >= 2 THEN
    -- PERFORM pgperf.create_snapshot_pg_statistic(_sid);
    PERFORM pgperf.create_snapshot_pg_stats(_sid);
  END IF;

  IF _level >= 4 AND _has_pgstattuple THEN
    IF _is_super = true THEN
      PERFORM pgperf.create_snapshot_pgstattuple(_sid);
      PERFORM pgperf.create_snapshot_pgstatindex(_sid);
    ELSE
      RAISE WARNING 'pgperf.create_snapshot: Cannot take pgstattuple/pgstatindex snapshot without super-user permission.'
      USING HINT = 'Check the permission for user "' || current_user || '".';
    END IF;
  END IF;

  RETURN _sid;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.create_snapshot(INTEGER) OWNER TO pgperf;

--
-- Delete a snapshot.
--
CREATE OR REPLACE FUNCTION pgperf.delete_snapshot (
  INTEGER
) RETURNS boolean AS
$$
DECLARE
  _sid ALIAS FOR $1;
  _version INTEGER;
BEGIN
  SELECT pgperf._get_server_version() INTO _version;

  PERFORM pgperf.delete_snapshot_pg_database_size(_sid);
  PERFORM pgperf.delete_snapshot_pg_relation_size(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_bgwriter(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_database(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_user_tables(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_user_indexes(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_user_functions(_sid);
  PERFORM pgperf.delete_snapshot_pg_statio_user_tables(_sid);
  PERFORM pgperf.delete_snapshot_pg_statio_user_indexes(_sid);
  PERFORM pgperf.delete_snapshot_pg_statio_user_sequences(_sid);
  PERFORM pgperf.delete_snapshot_pg_current_xlog(_sid);
  PERFORM pgperf.delete_snapshot_pg_stat_activity(_sid);
  PERFORM pgperf.delete_snapshot_pg_locks(_sid);
  IF _version >= 94 THEN
    PERFORM pgperf.delete_snapshot_pg_stat_archiver(_sid);
  END IF;

  PERFORM pgperf.delete_snapshot_pg_stat_statements(_sid);
--  PERFORM pgperf.delete_snapshot_pg_statistic(_sid);
  PERFORM pgperf.delete_snapshot_pg_stats(_sid);
  PERFORM pgperf.delete_snapshot_pgstattuple(_sid);
  PERFORM pgperf.delete_snapshot_pgstatindex(_sid);

  DELETE FROM pgperf.snapshot WHERE sid = _sid;

  RETURN true;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.delete_snapshot(INTEGER) OWNER TO pgperf;

--
-- Purge old snapshots at once.
--
CREATE OR REPLACE FUNCTION pgperf.purge_snapshots (
  INTERVAL
) RETURNS INTEGER AS
$$
DECLARE
  _interval ALIAS FOR $1;
  _count INTEGER;
BEGIN
  SELECT count(*) INTO _count
    FROM pgperf.snapshot
   WHERE ts < now() - _interval::interval;

  PERFORM pgperf.delete_snapshot(sid)
     FROM pgperf.snapshot
    WHERE ts < now() - _interval::interval;

  RETURN _count;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.purge_snapshots(INTERVAL) OWNER TO pgperf;

--
-- Get an interval between snaphsots in seconds.
--
CREATE OR REPLACE FUNCTION pgperf.get_interval (
  INTEGER,
  INTEGER
) RETURNS INTEGER AS
$$
DECLARE
  _sid1 ALIAS FOR $1;
  _sid2 ALIAS FOR $2;
  _interval INTEGER;
BEGIN
  SELECT extract(EPOCH FROM (s2.ts - s1.ts))::INTEGER INTO _interval
    FROM (SELECT ts FROM pgperf.snapshot WHERE sid=_sid1 ) AS s1,
         (SELECT ts FROM pgperf.snapshot WHERE sid=_sid2 ) AS s2;

  RETURN _interval;
END
$$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.get_interval(INTEGER,INTEGER) OWNER TO pgperf;
