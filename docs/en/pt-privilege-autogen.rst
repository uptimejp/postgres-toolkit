
pt-privilege-autogen
====================

Summary
-------

Generates REVOKE/GRANT statements for giving minimum privileges to users and database objects. It uses PostgreSQL statistics to learn access policy of the application.

Usage
-----

.. code-block:: none

   pt-privilege-autogen [option...] [ start | generate | stop ]

Commands
--------

.. csv-table::

  ``start``, Starts collecting table access statistics of the database.
  ``generate``, Generates REVOKE/GRANT statements from collected access statistics of the tables.
  ``stop``, Stops collecting table access statistics of the database.

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  --help

``-h``, ``--host`` Specifies the connecting PostgreSQL database server name or IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-U``, ``--username`` Specifies the user name of the PosgtgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used if no value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. It connect to the database same as the database username if no value has been defined in PGDATABASE.

Output Items
------------

This command shows GRANT/REVOKE statements that can be applied to the PostgreSQL database.

Examples
--------

This example shows how to generate REVOKE/GRANT statements which allows to run pgbench transactions with minimum privileges.

First, prepare a database for pgbench with superuser, and make sure that a regular user can't access to the tables.

.. code-block:: none

   $ createdb -U postgres mydb
   $ pgbench -i mydb -U postgres
   NOTICE:  table "pgbench_history" does not exist, skipping
   NOTICE:  table "pgbench_tellers" does not exist, skipping
   NOTICE:  table "pgbench_accounts" does not exist, skipping
   NOTICE:  table "pgbench_branches" does not exist, skipping
   creating tables...
   100000 of 100000 tuples (100%) done (elapsed 0.68 s, remaining 0.00 s).
   vacuum...
   set primary keys...
   done.
   $ pgbench -c 1 -t 1 -U snaga -n mydb
   ERROR:  permission denied for relation pgbench_branches
   $

Second, start collecting table access statistics, and run pgbench transactions with superuser privilege.

.. code-block:: none

   $ pt-privilege-autogen -d mydb start
   [2015-07-30 05:57:21] INFO: Collecting access statistics started.
   $ pgbench -c 1 -t 1 -U postgres -n mydb
   transaction type: TPC-B (sort of)
   scaling factor: 1
   query mode: simple
   number of clients: 1
   number of threads: 1
   number of transactions per client: 1
   number of transactions actually processed: 1/1
   latency average: 0.000 ms
   tps = 15.284443 (including connections establishing)
   tps = 19.093079 (excluding connections establishing)
   $

Then, generate an access policy file, and apply it to the database. A regular user ``snaga`` is granted least privileges for four tables here.

.. code-block:: none

   $ pt-privilege-autogen -d mydb generate
   
   -- Database
   REVOKE ALL ON DATABASE "mydb" FROM "public";
   GRANT CONNECT,TEMP ON DATABASE "mydb" TO "snaga";
   
   -- Schema
   REVOKE ALL ON SCHEMA "public" FROM "public";
   GRANT USAGE ON SCHEMA "public" TO "snaga";
   
   -- Table
   REVOKE ALL ON TABLE "public"."temp_pg_stat_user_tables" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_tellers" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_branches" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_history" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_accounts" FROM "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_tellers" TO "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_branches" TO "snaga";
   GRANT INSERT ON TABLE "public"."pgbench_history" TO "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_accounts" TO "snaga";
   
   
   $ pt-privilege-autogen -d mydb generate  > grant.sql
   $ psql -f grant.sql -U postgres mydb
   REVOKE
   GRANT
   REVOKE
   GRANT
   REVOKE
   REVOKE
   REVOKE
   REVOKE
   REVOKE
   GRANT
   GRANT
   GRANT
   GRANT
   $

Finally, stop collecting access statistics, and make sure that the regular user can now run pgbench transaction on the database with the least privileges.

.. code-block:: none

   $ pt-privilege-autogen -d mydb stop
   [2015-07-30 05:58:38] INFO: Collecting access statistics stopped.
   $ pgbench -c 1 -t 1 -U snaga -n mydb
   transaction type: TPC-B (sort of)
   scaling factor: 1
   query mode: simple
   number of clients: 1
   number of threads: 1
   number of transactions per client: 1
   number of transactions actually processed: 1/1
   latency average: 0.000 ms
   tps = 11.191566 (including connections establishing)
   tps = 14.290001 (excluding connections establishing)
   $ 
