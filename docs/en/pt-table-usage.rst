
pt-table-usage
==============

Summary
-------

Displays status information about the table


Usage
-----

.. code-block:: none

   pt-table-usage [option...]

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
  --help

``-h``, ``--host`` Specifies the connecting PostgreSQL database server name or IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PosgtgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used if no value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. It connect to the database same as the database username if no value has been defined in PGDATABASE.

``-o``, ``--owner`` Displays only table that is the owner user that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-n``, ``--schema`` Displays only table that is schema that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-t``, ``--table`` Displays only table that matches the specified name. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-d`` (or ``--dbname`` ), ``-o`` (or ``--owner`` ),  ``-n`` (or ``--schema`` ), ``-t`` (or ``--table`` ), if specified the options at the same time, only table that matches the conditions.


Output Items
------------

.. csv-table::

   ``OID``, Table object ID
   ``OWNER``, Owner name of table
   ``SCHEMA``, Schema name that exists in the table
   ``TABLE``, Table name
   ``BLKS``, Number of the table block (every 8kb)
   ``SCAN``, Sequential scan number of executions
   ``T_READ``, Number of tuple by sequential scan
   ``T_INS``, Number of inserted tuple
   ``T_UPD``, Number of updated tuple(include HOT UPDATE)
   ``T_DEL``, Number of delated tuple
   ``B_READ``, Number of read table block from disk
   ``B_HIT``, Number of read table page by shared buffer
   ``VACUUMED``, Date and time that run VACUUM on the last (VACUUM command or automatic VACUUM)
   ``ANALYZED``, Date and time that run ANALYZE on the last (ANALYZE command or automatic ANALYZE)
   ``TABLESPACE``, The tablespace name where the table is placed.

Examples
--------

It connects to the PostgreSQL instance running on the port ``5432`` of ``localhost``, and to display all of the table usage of ``dbt3`` database.

.. code-block:: none

   $ pt-table-usage -d dbt3
   +---------+-------+--------+----------+--------+------+----------+---------+-------+-------+--------+---------+----------+---------------------+------------+
   |   OID   | OWNER | SCHEMA |  TABLE   |  BLKS  | SCAN |  T_READ  |  T_INS  | T_UPD | T_DEL | B_READ |  B_HIT  | VACUUMED |       ANALYZED      | TABLESPACE |
   +---------+-------+--------+----------+--------+------+----------+---------+-------+-------+--------+---------+----------+---------------------+------------+
   | 1273410 | snaga | public | customer |   3531 |    5 |   750000 |  150000 |     0 |     0 |   6499 |   29943 |          | 2015-03-08 18:31:41 | ssdspc1    |
   | 1273416 | snaga | public | lineitem | 106583 |   12 | 66656465 | 6001215 |     0 |     0 | 240547 | 1340871 |          | 2015-03-08 18:31:42 | ssdspc1    |
   | 1273419 | snaga | public | nation   |      1 |    4 |      100 |      25 |     0 |     0 |      1 |       5 |          | 2015-03-08 18:31:42 | ssdspc1    |
   | 1273413 | snaga | public | orders   |  25326 |    5 |  7500000 | 1500000 |     0 |     0 |  48612 |  208386 |          | 2015-03-08 18:31:41 | ssdspc1    |
   | 1273404 | snaga | public | part     |   4064 |    3 |   600000 |  200000 |     0 |     0 |   6082 |   26558 |          | 2015-03-08 18:31:40 | ssdspc1    |
   | 1273407 | snaga | public | partsupp |  17087 |    5 |  4000000 |  800000 |     0 |     0 |  32200 |  148518 |          | 2015-03-08 18:31:41 | ssdspc1    |
   | 1273422 | snaga | public | region   |      1 |    3 |       15 |       5 |     0 |     0 |      1 |       4 |          | 2015-03-08 18:31:42 | ssdspc1    |
   | 1273401 | snaga | public | supplier |    218 |    4 |    40000 |   10000 |     0 |     0 |    220 |    1802 |          | 2015-03-08 18:31:40 | ssdspc1    |
   +---------+-------+--------+----------+--------+------+----------+---------+-------+-------+--------+---------+----------+---------------------+------------+
   $ 

It connects to the PostgreSQL instance running on the port ``5432`` of ``localhost``, and to display the table usage of the tables which start with ``pa`` in the ``dbt3`` database.

.. code-block:: none

   $ pt-table-usage -d dbt3 -t /^pa/
   +---------+-------+--------+----------+-------+------+---------+--------+-------+-------+--------+--------+----------+---------------------+------------+
   |   OID   | OWNER | SCHEMA |  TABLE   |  BLKS | SCAN |  T_READ | T_INS  | T_UPD | T_DEL | B_READ | B_HIT  | VACUUMED |       ANALYZED      | TABLESPACE |
   +---------+-------+--------+----------+-------+------+---------+--------+-------+-------+--------+--------+----------+---------------------+------------+
   | 1273404 | snaga | public | part     |  4064 |    3 |  600000 | 200000 |     0 |     0 |   6082 |  26558 |          | 2015-03-08 18:31:40 | ssdspc1    |
   | 1273407 | snaga | public | partsupp | 17087 |    5 | 4000000 | 800000 |     0 |     0 |  32200 | 148518 |          | 2015-03-08 18:31:41 | ssdspc1    |
   +---------+-------+--------+----------+-------+------+---------+--------+-------+-------+--------+--------+----------+---------------------+------------+
   $
