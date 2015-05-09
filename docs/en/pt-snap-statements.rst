
pt-snap-statements
==================

Summary
-------

Displays by calculating the difference between the statistics of two difference time of SQL statements.

If it has specified options value, it can be displayed to sort of each specific items.

Make sure you have ``pg_stat_statements`` of contrib module.

And also make sure to enable ``track_io_timing`` option.


Usage
-----

.. code-block:: none

   pt-snap-statements [option...] [interval]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  -s, --sort=KEY
  -l
  -t, --top=NUMBER
  -R, --reset
  --help

``-h``, ``--host`` Specifies the connecting the PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST.``localhost`` will be used if no other value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting the PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT. 

``-U``, ``--username`` Specifies the user name of the PostgreSQL database. If not specified, to set the value of PGUSER. Vars USER will be used if no other value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. Database name as database user name will be used if no other value has been defined in PGDATABASE.

``-s`` (not implemented) Specifies the sort item. ``KEY`` can take one of following values: ``CALLS``, ``T_TIME``, ``ROWS``, ``B_HIT``, ``B_READ``, ``B_DIRT``, ``B_WRTN``, ``R_TIME``, ``W_TIME``

``-l`` (not implemented) Displays with detailed every block classification (Shared buffer, Local buffer, Temporary buffer). If not specified, it is displayed the total number of shared buffer, local buffer and temporary buffer. 

``-t``, ``--top`` Specifies the number of displayed queries. If not specified, it is displayed the all queries.

``-R``, ``--reset`` It initializes the statistical information of``pg_stat_statements`` view.


Output Items
------------

.. csv-table::

   ``USER``, Username of query run
   ``DBNAME``, Database name of query run
   ``QUERYID``, Query ID of query run (Hexadecimal)
   ``QUERY``, Query performed (Display up to 30 characters)
   ``CALLS``, Number of times of query run
   ``T_TIME``, Total number of times of query run (Millisecond)
   ``ROWS``, Total number of rows that has received the obtain or influence
   ``B_HIT``, Total number of blocks read from the buffer at the time blocks read
   ``B_READ``, Total number of blocks read from the disk at the time blocks read
   ``B_DIRT``, Total number of pages that page has been updated by the query
   ``B_WRTN``, Total number of blocks that are written to disk by the query
   ``R_TIME``, Total time of block read from the disk  (Millisecond)  ( Make sure to enable ``track_io_timing`` parameter )
   ``W_TIME``, Total time of block write to the disk (Millisecond) ( Make sure to enable ``track_io_timing`` parameter )


Examples
--------

Connects to the ``postgres`` database, and the SQL statements executed in 5 seconds is sorted in descending order of total execution time (``T_TIME``), and displays all.

.. code-block:: none

   $ pt-snap-statements -d postgres 5
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   |  USER |  DBNAME  | QUERYID  |             QUERY              | CALLS | T_TIME | ROWS | B_HIT | B_READ | B_DIRT | B_WRTN | R_TIME | W_TIME |
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   | snaga | postgres | 80053daf | UPDATE pgbench_branches SET bb |   677 |  12007 |  677 |  9160 |      1 |      1 |      0 | 0.0    | 0.0    |
   | snaga | postgres | 1675159e | UPDATE pgbench_tellers SET tba |   681 |   7648 |  681 |  3403 |      0 |      0 |      0 | 0.0    | 0.0    |
   | snaga | postgres | ec088219 | UPDATE pgbench_accounts SET ab |   684 |    530 |  684 |  2289 |    585 |    568 |      0 | 125.9  | 0.0    |
   | snaga | postgres | 198383d  | SELECT abalance FROM pgbench_a |   682 |     73 |  682 |  2080 |      0 |      0 |      0 | 0.0    | 0.0    |
   | snaga | postgres | da8cc6f  | INSERT INTO pgbench_history (t |   676 |     34 |  676 |   704 |     12 |     10 |      0 | 0.0    | 0.0    |
   | snaga | postgres | d4e6bf94 | BEGIN;                         |   684 |      4 |    0 |     0 |      0 |      0 |      0 | 0.0    | 0.0    |
   | snaga | postgres | a81672e  | END;                           |   671 |      3 |    0 |     0 |      0 |      0 |      0 | 0.0    | 0.0    |
   | snaga | postgres | 8caa574  | select count(*) from pgbench_b |     1 |      0 |    1 |     4 |      0 |      0 |      0 | 0.0    | 0.0    |
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   $

User ``snaga`` connects to the ``postgres`` database of the PostgreSQL server running on the port ``5433`` of host ``192.168.1.101``, and the SQL statements executed in 5 seconds is sorted in descending order of total execution time (``T_TIME``), and the top 5 are displayed.

.. code-block:: none

   $ pt-snap-statements --host 192.168.1.101 -p 5433 -U snaga -d postgres -t 5 5
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   |  USER |  DBNAME  | QUERYID  |             QUERY              | CALLS | T_TIME | ROWS | B_HIT | B_READ | B_DIRT | B_WRTN | R_TIME | W_TIME |
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   | snaga | postgres | 80053daf | UPDATE pgbench_branches SET bb |   503 |   9953 |  503 |  8430 |     14 |      7 |      0 | 0.6    | 0.0    |
   | snaga | postgres | 1675159e | UPDATE pgbench_tellers SET tba |   508 |   6483 |  508 |  2551 |     10 |      9 |      0 | 0.3    | 0.0    |
   | snaga | postgres | ec088219 | UPDATE pgbench_accounts SET ab |   511 |    560 |  511 |  1424 |    698 |    477 |      7 | 91.0   | 12.1   |
   | snaga | postgres | 198383d  | SELECT abalance FROM pgbench_a |   511 |     93 |  511 |  1550 |      0 |      0 |      0 | 0.0    | 0.0    |
   | snaga | postgres | da8cc6f  | INSERT INTO pgbench_history (t |   503 |     20 |  503 |   530 |     13 |     11 |      0 | 0.1    | 0.0    |
   +-------+----------+----------+--------------------------------+-------+--------+------+-------+--------+--------+--------+--------+--------+
   $

