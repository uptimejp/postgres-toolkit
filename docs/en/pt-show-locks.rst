
pt-show-locks
=============

Summary
-------

Shows waiting and blocking lock information and those dependencies with the associated queries.


Usage
-----

.. code-block:: none

   pt-show-locks [option...]

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

   ``BLOCKER``, Blocking process id when the lock is waiting.
   ``PID``, Backend process id.
   ``LOCKTYPE``, Lock type.
   ``MODE``, Lock mode.
   ``GRANTED``, ``t`` on granted, ``f`` on waiting.
   ``QUERY``, Query string being executed.

Examples
--------

Following example shows the lock status with connecting ``mydb`` database with ``postgres`` user.

.. code-block:: none

   $ pg-show-locks -d mydb -U postgres
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   | BLOCKER | PID  | LOCKTYPE |         MODE        | GRANTED |                   QUERY                    |
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   |         | 2076 | relation | AccessExclusiveLock | t       | lock TABLE pgbench_accounts;               |
   |    2076 | 2049 | relation | RowShareLock        | f       | select * from pgbench_accounts for update; |
   |    2076 | 2436 | relation | RowExclusiveLock    | f       | delete from pgbench_accounts;              |
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   $
