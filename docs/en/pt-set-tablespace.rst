
pt-set-tablespace
=================

Summary
-------

Change at once the tablesapace of the index associated with the specified table.


Usage
-----

.. code-block:: none

   pt-set-tablespace [option...] [tablespace]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  -o, --owner=STRING
  -n, --schema=STRING
  -t, --table=STRING
  -l, --list
  --apply
  --help

``-h``, ``--host`` Specifies the connecting PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PosgtgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used if no value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. It connects to the database same as the database username if no value has been defined in PGDATABASE.

``-o``, ``--owner`` It applies only table that is owning user that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-n``, ``--schema`` It applies only table that is a schema that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-t``, ``--table`` It applies only table that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``--apply`` The change of tablespace, it is actually reflected in the database.

``-l``, ``--list`` Displays the tablespace information.

``-o`` (or ``--owner`` ),  ``-n`` (or ``--schema`` ), ``-t`` (or ``--table`` ), if specified the options at the same time, the only table that matches the conditions.

If it fails to move one or more tables, returned an exit code of ``1``. If it's successful the movement of all of the files, returned a "0".


Output Items
------------

``-l``, ``--list`` Items that are displayed in the options.

.. csv-table::

   ``OID``, Object ID of tablespace
   ``OWNER``, Owner name of tablespace
   ``TABLESPACE``, Tablespace name
   ``LOCATION``, Path of the directory for tablespace
   ``USE%``, Disk usage of the partition for tablespace
   ``AVAIL``, Free space of the partition for tablespace

Other output items are shown below.

.. csv-table::

   ``Dry-run mode``, Free space of the partition for tablespace.
   ``Applying ALTER TABLE/INDEX``, Acutually running the ALTER TABLE/INDEX statement, it will change tablespace of the index.
   ``X tables/indexes moved. Y failed.``, X of tables/indexes is moved successfully, Y failed to move.


Examples
--------

Displays list of tablespace that exist in the PostgreSQL instance. Gets the used area of the each partition, and displays as a list together.

.. code-block:: none

   $ pt-set-tablespace --list
   +--------+----------+------------+---------------------------+------+-------+
   |  OID   |  OWNER   | TABLESPACE |          LOCATION         | USE% | AVAIL |
   +--------+----------+------------+---------------------------+------+-------+
   |   1663 | postgres | pg_default |                           |      |       |
   |   1664 | postgres | pg_global  |                           |      |       |
   | 121263 | postgres | hddspc2    | /disk/disk2/pgsql         | 85%  | 80G   |
   |  16818 | postgres | ssdspc1    | /disk/disk1/tblspc1       | 67%  | 127G  |
   | 305242 | postgres | ssdspc2    | /disk/disk3/pgsql/ssdspc2 | 98%  | 13G   |
   +--------+----------+------------+---------------------------+------+-------+
   $

All ``orders`` tables and the indexes that was created on ``orders`` table in ``dbt3`` database, it displays ``ALTER TABLE`` and ``ALTER INDEX`` statement for to move the tablesapace. (Does not actually move)

.. code-block:: none

   $ pt-set-tablespace -d dbt3 --table orders ssdspc1
   [2015-04-29 17:35:24] INFO: Dry-run mode:
   [2015-04-29 17:35:24] INFO: ALTER TABLE "public"."orders" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."pk_orders" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."i_o_orderdate" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."i_o_custkey" SET TABLESPACE "ssdspc1";
   $

All ``orders``  tables and the indexes that were created on ``orders`` table in ``dbt3`` database, to move to the ``ssdspc1`` tablespace.

.. code-block:: none

   $ pt-set-tablespace -d dbt3 --table orders --apply ssdspc1
   [2015-04-29 17:37:06] INFO: Applying ALTER TABLE/INDEX...
   [2015-04-29 17:37:08] INFO: 4 tables/indexes moved. 0 failed.
   $

All tables in the ``dbt3`` schema and all indexes, to move to the ``ssdspc1`` tablespace.

.. code-block:: none

   $ pt-set-tablespace --schema dbt3 --apply ssdspc1
   [2015-04-29 17:38:39] INFO: Applying ALTER TABLE/INDEX...
   [2015-04-29 17:38:57] INFO: 31 tables/indexes moved. 0 failed.
   $
