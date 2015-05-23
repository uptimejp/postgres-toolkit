
pt-index-usage
==============

Summary
-------

Displays the indexes usage.


Usage
-----

.. code-block:: none

   pt-index-usage [option...]

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
  -i, --index=STRING
  -u, --unused
  --help

``-h``, ``--host`` Specifies the connecting the PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no other value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PostgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used If no other value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. Database name as database user name will be used if no other value has been defined in PGDATABASE.

``-o``, ``--owner`` The index information is only displayed which matches to a string specified where is a name of the owner. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-n``, ``--schema`` The index information is only displayed which matches to a string specified where is in the schema. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-t``, ``--table`` The index information is only displayed which matches to a string specified where is in the table. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-i``, ``--index`` The index information is only displayed which matches to a string specified. Also accepts regular expression when starting and ending with slashes. (cf. ``/REGEXP/`` )

``-u``, ``--unused`` The index information is displayed which not use the index.

``-d`` (or ``--dbname`` ), ``-o`` (or ``--owner`` ),  ``-n`` (or ``--schema`` ), ``-t`` (or ``--table`` ), ``-i`` (or ``--index`` ), ``-u`` (or ``--unused`` ), if specified the options at the same time, the index is displayed which matches to it.


Output Items
------------

.. csv-table::

   ``OID``, Object ID of index
   ``OWNER``, Owner name of index
   ``SCHEMA``, Schema name on being indexed
   ``TABLE``, Table name on being indexed
   ``INDEX``, Index name
   ``BLKS``, Block (every 8kb) of index
   ``SCAN``, Index scan number of executions
   ``T_READ``, Number of index entries by index scan
   ``T_FTCH``, Number of tuple on table by index scan
   ``B_READ``, Number of index blocks read from disk
   ``B_HIT``, Number of index pages read from shared buffer
   ``STATUS``, Index status. It reads from pg_index system table.
   ``TABLESPACE``, The tablespace name that has index

Examples
--------

For the index of table in the ``public`` schema, displays the usage situation.

.. code-block:: none

   $ pt-index-usage -n public -d postgres
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   |  OID  | OWNER | SCHEMA |      TABLE       |         INDEX         | BLKS | SCAN | T_READ | T_FTCH | B_READ | B_HIT | STATUS | TABLESPACE |
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   | 26793 | snaga | public | pgbench_accounts | pgbench_accounts_pkey |  276 |    1 |      1 |      1 |      4 |     0 |        | spc1       |
   | 26789 | snaga | public | pgbench_branches | pgbench_branches_pkey |    2 |    1 |      1 |      0 |      2 |     0 |        | pg_default |
   | 26791 | snaga | public | pgbench_tellers  | pgbench_tellers_pkey  |    2 |    0 |      0 |      0 |      0 |     0 |        | pg_default |
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   $ 

For the index of ``pgbench_accounts`` table in the ``public`` schema, displays the usage situation.

.. code-block:: none

   $ pt-index-usage -n public -d postgres -t pgbench_accounts
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   |  OID  | OWNER | SCHEMA |      TABLE       |         INDEX         | BLKS | SCAN | T_READ | T_FTCH | B_READ | B_HIT | STATUS | TABLESPACE |
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   | 26793 | snaga | public | pgbench_accounts | pgbench_accounts_pkey |  276 |    1 |      1 |      1 |      4 |     0 |        | spc1       |
   +-------+-------+--------+------------------+-----------------------+------+------+--------+--------+--------+-------+--------+------------+
   $

For the index not used even once, in the ``public`` schema, displays the usage situation.

.. code-block:: none

   $ pt-index-usage -d postgres -n public -u
   +-------+-------+--------+-----------------+----------------------+------+------+--------+--------+--------+-------+--------+------------+
   |  OID  | OWNER | SCHEMA |      TABLE      |        INDEX         | BLKS | SCAN | T_READ | T_FTCH | B_READ | B_HIT | STATUS | TABLESPACE |
   +-------+-------+--------+-----------------+----------------------+------+------+--------+--------+--------+-------+--------+------------+
   | 26791 | snaga | public | pgbench_tellers | pgbench_tellers_pkey |    2 |    0 |      0 |      0 |      0 |     0 |        | pg_default |
   +-------+-------+--------+-----------------+----------------------+------+------+--------+--------+--------+-------+--------+------------+
   $
