
pt-stat-snapshot
================

Summary
-------

Get a snapshot of statistical information, save, and manage.


Usage
-----

.. code-block:: none

   pt-stat-snapshot [option...] install
   pt-stat-snapshot [option...] uninstall
   pt-stat-snapshot [option...] create [level]
   pt-stat-snapshot [option...] list
   pt-stat-snapshot [option...] delete [sid]
   pt-stat-snapshot [option...] export [file]
   pt-stat-snapshot [option...] import [file]

Commands
--------

.. csv-table::

  ``install``, Creates a schema and tables and functions of the package.
  ``uninstall``, Drops a schema and tables and functions of the package.
  ``create [level]``, Takes a snapshot of the database statistics. ``[level]`` can be ``1`` or ``2`` or ``4``.
  ``list``, Shows a list of stored snapshots.
  ``delete [sid]``, Deletes a snapshot specified by snapshot id. Multiple snapshot ids can be specified by range as ``M:N``.
  ``export [file]``, Exports all snapshot data into the specified file.
  ``import [file]``, Imports snapshot data from the specified file.


Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  --help

``-h``, ``--host`` Specifies the connecting the PostgreSQL database server name or its IP address. or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no other value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the username of the PostgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used If no other value has been defined in PGUSER.

``-d``, ``--dbname``  Specifies the connecting database name. If not specified, to set the value of PGDATABASE. Database name as database username will be used if no other value has been defined in PGDATABASE.


Output Items
------------

``list`` command shows following items.

.. csv-table::

   ``SID``, Snapshot ID (Assigned to every snapshot. Monotonic increase.)
   ``TIMESTAMP``, Timestamp of the snapshot taken.
   ``LEVEL``, Snapshot level.

Examples
--------

It installs a schema, tables and functions of the package to ``testdb`` database.

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb install
   [2015-03-31 17:21:37] INFO: Succeeded to install pgperf snapshot.
   $

It takes a snapshot with the snapshot level 4.

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb create 4
   [2015-03-31 17:21:47] INFO: Succeeded to take a snapshot.
   $

It shows a list of the snapshots.

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb list
   +-----+---------------------+-------+
   | SID |      TIMESTAMP      | LEVEL |
   +-----+---------------------+-------+
   |   0 | 2015-03-31 17:21:47 |     1 |
   +-----+---------------------+-------+
   $

It uninstalls the schema, tables and functions of the package from ``testdb`` database.

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb uninstall
   [2015-03-31 17:21:59] INFO: Succeeded to uninstall pgperf snapshot.
   $

About pgperf-snapshot Module
----------------------------

``pt-stat-snapshot`` command depends on another module internally, previously known as the pgperf-snapshot.

For more details about the pgperf-snapshot module, please refer to the following documents.

.. toctree::
   :maxdepth: 2

   pgperf_overview.rst
   pgperf_intro.rst
   pgperf_functions.rst
   pgperf_tables.rst
