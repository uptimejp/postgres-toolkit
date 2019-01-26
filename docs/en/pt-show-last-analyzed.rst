
pt-show-last-analyzed
=====================

Summary
-------

Shows last analyzed time of the tables.


Usage
-----

.. code-block:: none

   pt-show-last-analyzed [option...]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  --help

``-h``, ``--host`` Specifies the connecting the PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no other value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PostgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used If no other value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. Database name as database user name will be used if no other value has been defined in PGDATABASE.

Output Items
------------

.. csv-table::

   ``SCHEMA``, Schema name that exists in the table
   ``TABLE``, Table name
   ``LAST_ANALYZED``, Last analyzed time of the table

Examples
--------

Following example shows the last analyzed time of the tables in ``testdb`` database.

.. code-block:: none

   $ pt-show-last-analyzed -h localhost -U postgres -d testdb
   +--------+------------------+----------------------------------+
   | SCHEMA |      TABLE       |          LAST_ANALYZED           |
   +--------+------------------+----------------------------------+
   | public | pgbench_history  | 2019-01-26 07:24:38.558291+00:00 |
   | public | pgbench_tellers  | 2019-01-26 07:24:38.559029+00:00 |
   | public | pgbench_branches | 2019-01-26 07:24:38.561584+00:00 |
   | public | pgbench_accounts | 2019-01-26 07:24:38.679717+00:00 |
   +--------+------------------+----------------------------------+
   
   $
