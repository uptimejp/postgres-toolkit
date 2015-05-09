Introduction to PgPerf package
==============================

This chapter is intended to give a brief introduction to the PgPerf snapshot package.

Installing PgPerf package
-------------------------

To install the PgPerf package, ``pgperf_snapshot_install.sql`` script needs to be executed on a database, where the DBA wants to take performance snapshots, to create ``pgperf`` schema, snapshot functions, and snapshot tables.

.. code-block:: none

   psql -f pgperf_snapshot_install<VERSION>.sql <DBNAME>

Uninstalling PgPerf package
---------------------------

To uninstall the PgPerf package, ``pgperf_snapshot_uninstall.sql`` script needs to be executed on the database where the PgPerf package has been installed.

.. code-block:: none

   psql -f pgperf_snapshot_uninstall.sql <DBNAME>

Once ``pgperf_snapshot_uninstall.sql`` is executed on a database, it would drops``pgperf`` schema, snapshot functions and snapshot tables installed in the database.

Taking a performance snapshot with using PgPerf package
-------------------------------------------------------

In order to take a performance snapshot, a SQL function ``pgperf.create_snapshot()`` needs to be called.

Once ``pgperf.create_snapshot()`` function is called with specifying a snapshot level, a snapshot of the several performance statistics would be taken, and a snapshot id associated with the performance snaphsot would be returned.

In the following example, a snapshot level is specified as ``4``, and then, ``1005`` is returned as the snapshot id.

::

 postgres=# SELECT pgperf.create_snapshot(4);
  create_snapshot
 -----------------
             1005
 (1 row)
 
 postgres=#


Showing a list for snapshots
----------------------------

``pgperf.snapshot`` table would hold a list of the snapshots.

By querying the table, snapshot ids and those timestamps can be obtained as following.

::

 postgres=# SELECT * FROM pgperf.snapshot;
  sid |             ts             | level
 -----+----------------------------+-------
    0 | 2015-04-11 19:11:24.04428  |     1
    1 | 2015-04-11 19:11:24.060965 |     2
    2 | 2015-04-11 19:11:24.110034 |     4
 (3 rows)
 
 postgres=#


Deleting a snapshot
-------------------

To delete a snapshot, ``pgperf.delete_snapshot()`` function with specifying a snapshot id can be used.

In the following example, a snapshot associated with snaphsot id ``2`` is going to be dropped.

::

 postgres=# SELECT pgperf.delete_snapshot(2);
  delete_snapshot
 -----------------
  t
 (1 row)
 
 postgres=# SELECT * FROM pgperf.snapshot;
  sid |             ts             | level
 -----+----------------------------+-------
    0 | 2015-04-11 19:11:24.04428  |     1
    1 | 2015-04-11 19:11:24.060965 |     2
 (2 rows)
 
 postgres=#


Taking snapshots as a routine
-----------------------------

To take a snapshot as a routine, ``pgperf.create_snapshot()`` function needs to be called with using a cron-like tool.

A shell script,``get_snapshot.sh``, which is contained in the package, executes ``pgperf.create_snapshot()`` function on the specified database or all databases, which can be connected by the script (and not a template database).

In the following example, the script is taking a snapshot for ``postgres`` database.

::

$ ./get_snapshot.sh postgres

On the other hand, the script is taking a snapshot for every database in the following example.

::

$ ./get_snapshot.sh

By setting a crontab, ``get_snapshot.sh`` can be called to take snapshots periodically.

A crontab shown in below is intended to take performance snapshots of all the databases with calling ``get_snapshot.sh`` script in every 10 minutes.

::

 0-59/10 * * * *       /path/to/get_snapshot.sh > /dev/null 2>&1


Purging snapshots
-----------------

``pgperf.purge_snapshots()`` function can be used to purge older snapshots at once.

In the following example, snapshots, which are older than 1 week or more, are going to be purged.

::

 postgres=# SELECT sid,ts FROM pgperf.snapshot ORDER BY ts LIMIT 1;
  sid |             ts
 -----+----------------------------
    2 | 2012-10-21 18:20:01.238885
 (1 row)
 
 postgres=# SELECT now(),pgperf.purge_snapshots('1 weeks');
               now              | purge_snapshots
 -------------------------------+-----------------
  2012-10-29 14:57:04.092243+09 |             121
 (1 row)
 
 postgres=# SELECT sid,ts FROM pgperf.snapshot ORDER BY ts LIMIT 1;
  sid |            ts
 -----+--------------------------
  123 | 2012-10-22 15:00:01.8397
 (1 row)
 
 postgres=#

