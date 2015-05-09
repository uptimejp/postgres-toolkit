
How to add a new snapshot table
===============================

 - Determine a SQL statement to retreive a snapshot.
 - Create a SQL script file in 90~94 directories.
 - Modify _build.sh to generate snapshot table and functions.
 - Modify doc, pgperf_tables.rst.
 - Add a new dedicated unit test, and add it to regress2.sh.
 - Fix other tests.
 - Modify create_snapshot(), delete_snapshot() function to call
   the new functions.
 - Fix the tests.

EOF
