Snapshot Functions
==================

This chapter is intended to give detailed information about several snapshot functions, provided in the PgPerf package, to deal with performance snaphsots.

Snapshot Function List
----------------------

===================================== ======================================
Function Name                         Description
===================================== ======================================
pgperf.create_snapshot(level)         Takes a new snapshot.
pgperf.delete_snapshot(snapid)        Drops a snapshot specified by the snapshot id.
pgperf.purge_snapshots(interval)      Drops snapshots older than the specified period.
pgperf.get_interval(snapid1, snapid2) Gets an interval (in second) between two snapshots.
===================================== ======================================


pgperf.create_snapshot() Function
---------------------------------

Description
^^^^^^^^^^^

``pgperf.create_snapshot()`` function takes a snapshot of the performance statistics, which can be obtained in the PostgreSQL database, and stores them in the snapshot tables.

Declaration
^^^^^^^^^^^

::

 integer pgperf.create_snapshot(integer level)

Parameters
^^^^^^^^^^

======== ======== ================================
Name     Type     Description
======== ======== ================================
level    integer  Snapshot level to be taken.
======== ======== ================================

Unfortunately, heavy performance impact could sometimes be generated while taking a snapshot for all the performance statistics available in the database.

To avoid that, ``pgperf.create_snapshot()`` function allows DBA to obtain a snapshot with less performance impact by specifying the snapshot level. Then, DBA can avoid taking a snapshot which generates heavy performance impact so frequently.

============== =====================================================================
Snapshot Level Snapshot Contents
============== =====================================================================
1              Obtains a snapshot of the basic access statistics and the session statistics.

               pg_stat_database, pg_database_size()

               pg_stat_user_tables, pg_statio_user_tables

               pg_stat_user_indexes, pg_statio_user_indexes

               pg_relation_size(), pg_total_relation_size()

               pg_current_xlog_location(), pg_current_xlog_insert_location()

               pg_stat_bgwriter

               pg_stat_activity, pg_locks, pg_stat_statements


2              In addition to the level 1, obtains a snapshot of the optimizer statistics.

               pg_statistic

3              Not used.
4              In addition to the level 2, obtains a snapshot of the table/index fragmentation statistics.

               pgstattuple(), pgstatindex()

5              Not used.
============== =====================================================================



pgperf.delete_snapshot() Function
---------------------------------

Description
^^^^^^^^^^^

``pgperf.delete_snapshot()`` function deletes a snapshot of the performance statistics specified by the snapshot id.

Declaration
^^^^^^^^^^^

::

 integer pgperf.delete_snapshot(integer snapid);

Parameters
^^^^^^^^^^

======== ======== ================================
Name     Type     Description
======== ======== ================================
snapid   integer  A snapshot id accociated with the snapshot to be deleted.
======== ======== ================================


pgperf.purge_snapshots() Function
---------------------------------

Description
^^^^^^^^^^^

``pgperf.purge_snapshots()`` function purges older performance snapshots at once.

Declaration
^^^^^^^^^^^
::

 integer pgperf.purge_snapshots(interval period);

Parameters
^^^^^^^^^^

======== ======== ================================
Name     Type     Description
======== ======== ================================
period   interval A period of the snapshots to be kept in the snapshot tables.
======== ======== ================================

This function drops snapshots older than the period (interval) specified by the parameter ``period`` .

See the PostgreSQL manual for more details about how to express an ``interval`` value.

* `PostgreSQL: Documentation: 9.0: Date/Time Types <http://www.postgresql.org/docs/9.0/static/datatype-datetime.html#DATATYPE-INTERVAL-INPUT>`_


pgperf.get_interval() Function
------------------------------

Description
^^^^^^^^^^^

``pgperf.get_interval()`` function obtains an interval between two snapshots.

This function is intended to give some convenience to convert an obtained value into a 'per-second' value, particularly in SQL scripts.


Declaration
^^^^^^^^^^^
::

 integer pgperf.get_interval(integer snapid1, integer snapid2)

Parameters
^^^^^^^^^^

======== ======== ================================
Name     Type     Description
======== ======== ================================
snapid1  integer  A snapshot id at the start point.
snapid2  integer  A snapshot id at the end point.
======== ======== ================================

