
pt-replication-stat
===================

Summary
-------

The replication status is displayed by referring the master node statistical information of the replication. It is possible to display continuously on every specified interval.

PostgreSQL 9.1 or higher. PostgreSQL 9.0 doesn't work because it doesn't have no "pg_stat_replication" system view.

Usage
-----

.. code-block:: none

   pt-replication-stat [option...] [delay [count]]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME


Output Items
------------

.. csv-table::

   ``PID``, The process ID of WAL sender processes on the master node
   ``NAME``, The slave node name of the registered in the replication
   ``HOST``, The host name of slave node or IP address
   ``PORT``, The port number of the master node that connected to the slave node
   ``STATE``, The slave node status. It acquires the value of following ``startup`` or ``backup`` or ``catchup`` or ``streaming``
   ``SENT``, Position on the WAL which sent to slave
   ``WRITTTEN``, Position on the WAL which wrote to the WAL buffer on the slave
   ``FLUSHED``, Position on the WAL which synchronously wrote to the WAL file on the slave
   ``REPLAYED``, Position on WAL which applied to the data file on the slave
   ``PRI``, If the slave node is synchronously replication that the node priority is displayed.
   ``MODE``, The operation mode is displayed. ``sync`` is synchronous mode. ``async`` is asynchronous mode. ``potential`` is running in asynchronous mode. But there is a possibility to upgrade to the synchronous mode.


Examples
--------

Connect to the port ``5433`` of host ``127.0.0.1`` by ``postgres`` user, the statistical information is displayed every five seconds twice.

.. code-block:: none

   $ pt-replication-stat -h 127.0.0.1 -p 5433 -U postgres 5 2
   Sat Mar 28 21:45:23 JST 2015
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   | PID  |   NAME   |    HOST   |  PORT |   STATE   |    SENT   |  WRITTTEN |  FLUSHED  |  REPLAYED | PRI |  MODE  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   |      |          |           |       | local     | 0/5F30398 | 0/5F300B0 |           |           |     | master |
   | 3323 | replica1 | 127.0.0.1 | 55580 | streaming | 0/5F300B0 | 0/5F300B0 | 0/5F300B0 | 0/5F2FE48 |   0 | async  |
   | 3367 | replica2 | 127.0.0.1 | 55589 | streaming | 0/5F300B0 | 0/5F300B0 | 0/5F2FE48 | 0/5F2FE48 |   0 | async  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   
   Sat Mar 28 21:45:28 JST 2015
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   | PID  |   NAME   |    HOST   |  PORT |   STATE   |    SENT   |  WRITTTEN |  FLUSHED  |  REPLAYED | PRI |  MODE  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   |      |          |           |       | local     | 0/608CD68 | 0/608CAC0 |           |           |     | master |
   | 3323 | replica1 | 127.0.0.1 | 55580 | streaming | 0/608CAC0 | 0/608CAC0 | 0/608C7D8 | 0/608C7D8 |   0 | async  |
   | 3367 | replica2 | 127.0.0.1 | 55589 | streaming | 0/608CAC0 | 0/608CAC0 | 0/608C7D8 | 0/608C7D8 |   0 | async  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   
   $

Connect to the default port (``5432``) of ``localhost``, the statistical information is displayed every five seconds continuously. CTRL-C to end this.

.. code-block:: none

   $ pt-replication-stat -h localhost 5
   Sat Mar 28 21:45:23 JST 2015
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   | PID  |   NAME   |    HOST   |  PORT |   STATE   |    SENT   |  WRITTTEN |  FLUSHED  |  REPLAYED | PRI |  MODE  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   |      |          |           |       | local     | 0/5F30398 | 0/5F300B0 |           |           |     | master |
   | 3323 | replica1 | 127.0.0.1 | 55580 | streaming | 0/5F300B0 | 0/5F300B0 | 0/5F300B0 | 0/5F2FE48 |   0 | async  |
   | 3367 | replica2 | 127.0.0.1 | 55589 | streaming | 0/5F300B0 | 0/5F300B0 | 0/5F2FE48 | 0/5F2FE48 |   0 | async  |
   +------+----------+-----------+-------+-----------+-----------+-----------+-----------+-----------+-----+--------+
   
   ^C[2015-03-28 21:45:25] INFO: Terminated.
   $

