
pt-tablespace-usage
===================

Summary
-------

Displays the usage of table space for earch databases.

For each table space, it will be able to check which database is using how much the capacity.


Usage
-----

.. code-block:: none

   pt-tablespace-usage [option...]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  --help

``-h``, ``--host`` Specifies the connecting PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PosgtgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used if no value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. It connect to the database same as the database username if no value has been defined in PGDATABASE.


Output Items
------------

.. csv-table::

   ``TABLESPACE``, Tablespace name
   ``DBNAME``, Database name (The blank in case of pg_global table space)
   ``SIZE (MB)``, The capacity that is using the database object on the table space.(MB)

Examples
--------

It connects to the ``postgres`` database of PostgreSQL instance running on the port ``5432`` of localhost, and to display the capacity that they are using for each database in each tablespace.  

.. code-block:: none

   $ pt-tablespace-usage -d postgres
   +------------+-----------+-----------+
   | TABLESPACE |   DBNAME  | SIZE (MB) |
   +------------+-----------+-----------+
   | pg_default | postgres  |         8 |
   | pg_default | template1 |         6 |
   | pg_default | testdb    |         8 |
   | pg_global  |           |         1 |
   | spc1       | postgres  |        16 |
   +------------+-----------+-----------+
