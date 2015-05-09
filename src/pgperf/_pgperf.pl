#!/usr/bin/perl

use strict;

my $table = shift;

sub read_sql_file {
	my $file = $_[0];
	
	open(F, "$file") || die($!);

	my $sql;
	while(<F>)
	{
		$sql .= $_;
	}

	close(F);

	$sql;
}

sub def_create_snapshot_table {
	my $tab = $_[0];
	my $sql = $_[1];
	
	$sql =~ s/;//;
	my $s =<<EOF;
--
-- CREATE TABLE pgperf.snapshot_${tab}
--
DROP TABLE IF EXISTS pgperf.snapshot_${tab};

CREATE TABLE pgperf.snapshot_${tab} AS
$sql
LIMIT 0;

ALTER TABLE pgperf.snapshot_${tab} ALTER COLUMN sid SET NOT NULL;
ALTER TABLE pgperf.snapshot_${tab} OWNER TO pgperf;

CREATE INDEX snapshot_${tab}_sid_idx ON pgperf.snapshot_${tab}(sid);

-- \\d pgperf.snapshot_${tab}

EOF

	$s;
}


sub def_create_snapshot_func {
	my $tab = $_[0];
	my $sql = $_[1];
	
	$sql =~ s/0::int as sid,/_sid,/i;
	$sql =~ s/;//i;

	my $s =<<EOF;
--
-- CREATE FUNCTION pgperf.create_snapshot_${tab} (INT)
--
CREATE OR REPLACE FUNCTION pgperf.create_snapshot_${tab} (INT)
  RETURNS boolean AS
\$\$
DECLARE
	_sid ALIAS FOR \$1;
BEGIN
  INSERT INTO pgperf.snapshot_${tab} (
	$sql
  );
  
  RETURN true;
END
\$\$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.create_snapshot_${tab}(INT) OWNER TO pgperf;

EOF

	$s;
}

sub def_delete_snapshot_func {
	my $tab = $_[0];
	my $sql = $_[1];
	
	my $s =<<EOF;
--
-- CREATE FUNCTION pgperf.delete_snapshot_${tab} (INT)
--
CREATE OR REPLACE FUNCTION pgperf.delete_snapshot_${tab} (INT)
  RETURNS boolean AS
\$\$
DECLARE
	_sid ALIAS FOR \$1;
BEGIN
  DELETE FROM pgperf.snapshot_${tab} WHERE sid = _sid;
  RETURN true;
END
\$\$
LANGUAGE 'plpgsql';

ALTER FUNCTION pgperf.delete_snapshot_${tab}(INT) OWNER TO pgperf;

EOF

	$s;
}

sub def_test_snapshot {
	my $tab = $_[0];
	my $sql = $_[1];

	my $s =<<EOF;
--
-- TEST pgperf.snapshot_${tab}
--
/*
SELECT pgperf.create_snapshot_${tab}(1);
SELECT count(*) FROM pgperf.snapshot_${tab};
SELECT * FROM pgperf.snapshot_${tab};
SELECT pgperf.delete_snapshot_${tab}(1);
SELECT count(*) FROM pgperf.snapshot_${tab};
SELECT * FROM pgperf.snapshot_${tab};
SELECT pgperf.create_snapshot_${tab}(1);
*/

EOF

	$s;
}

my $sql = &read_sql_file($table . ".sql");

my $sql2 = def_create_snapshot_table($table, $sql);
my $sql3 = def_create_snapshot_func($table, $sql);
my $sql4 = def_delete_snapshot_func($table, $sql);
#my $sql5 = def_test_snapshot($table, $sql);

#print $sql;

print $sql2;
print $sql3;
print $sql4;
#print $sql5;

