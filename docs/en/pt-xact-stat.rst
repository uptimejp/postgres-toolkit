
pt-xact-stat
============

Summary
-------

Displays transaction statistical information of multiple node. It is possible to display each specified interval continuously.

Usage
-----

.. code-block:: none

   pt-xact-stat [option...] [delay [count]]

Options
----------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -H, --host-list=HOSTLIST
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  -H, --host-list=HOSTNAME:PORT,HOSTNAME:PORT[,...]

``-h``, ``--host`` Specifies the connecting PostgreSQL database server name or its IP address. If not specified, to set the value of PGHOST. ``localhost`` will be used if no value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the connecting PostgreSQL database. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-H``, ``--host-list`` If it is connected to multiple database servers, it specifies database server name or several combination IP address or port number. The form is ``192.168.1.101:5432,192.168.1.102:5433`` . A set of server and port number is linked with a colon. A set of several server is linked with a comma. This port number is optional and will be set for the default port number.

``-U``, ``--username`` Specifies the user name of the PosgtgreSQL database. If not specified, to set the value of PGUSER. The value of USER will be used if no value has been defined in PGUSER.

``-d``, ``--dbname`` Specifies the connecting database name. If not specified, to set the value of PGDATABASE. It connect to the database same as the database username if no value has been defined in PGDATABASE.


Output Items
------------

.. csv-table::

   ``HOST``, Host name of PostgreSQL server
   ``PORT``, Port number of PstgreSQL server
   ``DBNAME``, Database name
   ``CONN``, Number of sessions that are connected to the database
   ``COMMITS``, Total number of transactions that are committed
   ``ROLLBACKS``, Total number of transactions that are rollback
   ``B_READ``, Number of blocks in the table that read from disk
   ``B_HIT``, Number of pages that read from shared buffer


Examples
--------

It connects to the two PostgreSQL instance running on the port 5432 and port 5433 of the localhost, and to display the statistical information of transaction for each instance every 5 seconds twice.

.. code-block:: none

   $ pt-xact-stat --host-list 127.0.0.1:5432,127.0.0.1:5433,127.0.0.1:5434 -d postgres 5 2
   Sat Mar 28 20:47:50 JST 2015
   +-----------+------+----------+------+---------+-----------+--------+-------+
   |    HOST   | PORT |  DBNAME  | CONN | COMMITS | ROLLBACKS | B_READ | B_HIT |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   | 127.0.0.1 | 5432 | postgres |    1 |     137 |         1 |    104 | 10273 |
   | 127.0.0.1 | 5433 | postgres |    1 |       8 |         0 |    104 |  1350 |
   | 127.0.0.1 | 5434 | postgres |    1 |      76 |         0 |    104 |  7708 |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   
   Sat Mar 28 20:47:55 JST 2015
   +-----------+------+----------+------+---------+-----------+--------+-------+
   |    HOST   | PORT |  DBNAME  | CONN | COMMITS | ROLLBACKS | B_READ | B_HIT |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   | 127.0.0.1 | 5432 | postgres |    1 |     139 |         1 |    104 | 10460 |
   | 127.0.0.1 | 5433 | postgres |    1 |      10 |         0 |    104 |  1537 |
   | 127.0.0.1 | 5434 | postgres |    1 |      78 |         0 |    104 |  7895 |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   
   $

Connects to the three PostgreSQL instance running on the port 5432, port 5433 and port 5434 of the localhost, and to display once the statistical information of transaction for each instance, and exit.

.. code-block:: none

   $ pt-xact-stat --host-list 127.0.0.1:5432,127.0.0.1:5433,127.0.0.1:5434 -d postgres
   Sat Mar 28 21:05:48 JST 2015
   +-----------+------+----------+------+---------+-----------+--------+-------+
   |    HOST   | PORT |  DBNAME  | CONN | COMMITS | ROLLBACKS | B_READ | B_HIT |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   | 127.0.0.1 | 5432 | postgres |    1 |      12 |         0 |    104 |  1400 |
   | 127.0.0.1 | 5433 | postgres |    1 |       4 |         0 |    104 |   976 |
   | 127.0.0.1 | 5434 | postgres |    1 |       4 |         0 |    104 |   976 |
   +-----------+------+----------+------+---------+-----------+--------+-------+
   
   $
