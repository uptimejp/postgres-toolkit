
pt-session-profiler
===================

Summary
-------

Displays the query and performance information by detecting the PostgreSQL session from capturing the network traffic.

For executing tcpdump requires ``root`` privileges.


Usage
-----

.. code-block:: none

   pt-session-profiler [option...]

Options
-------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -i [INTERFACE]
  -T, --threshold=MILLISECONDS
  --help

``-h``, ``--host`` Specifies the IP address or PostgreSQL server name of the PostgreSQL session to parse. If not specified, to set the value of PGHOST. Every server name or IP address packet will be analyzed if no other value has been defined in PGHOST.

``-p``, ``--port`` Specifies the port number of the PostgreSQL session to parse. If not specified, to set the value of PGPORT. ``5432`` will be used if no value has been defined in PGPORT.

``-i`` Specifies the network interface to capture. All network interfaces (``any``) will be used if it is omitted.

``-T``, ``--threshold`` Specifies the threshold of execution time in the displayed query. The unit is milliseconds. The default value is ``1000``.

Output Items
------------

.. csv-table::

   ``sess``, Unique session strings. (Different values for each session. The source IP address and the port number and the destination IP address and the port number and use the 12 characters of the hash string MD5.)
   ``time``, Query execution time
   ``query``, Run the query string

Examples
--------

It monitors the ones destined to port 5432 of the TCP packet that passes through all of the network interface. CTRL-C to end this.

.. code-block:: none

   $ sudo pt-session-profiler -T 500
   [2015-03-29 15:07:22] INFO: Threshold: 500 ms
   [2015-03-29 15:07:22] INFO: tcpdump -l -i any -s 0 -X -p tcp port 5432
   [2015-03-29 15:07:36] INFO: sess:e27f20dae08f, time:0:00:00.557728, query:UPDATE pgbench_tellers SET tbalance = tbalance + 2084 WHERE tid = 23;
   [2015-03-29 15:07:36] INFO: sess:b3674d7bbea0, time:0:00:00.980950, query:INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (32, 5, 255511, 2695, CURRENT_TIMESTAMP);
   [2015-03-29 15:07:45] INFO: sess:1c32286cab7a, time:0:00:01.115904, query:SELECT abalance FROM pgbench_accounts WHERE aid = 161999;
   [2015-03-29 15:07:45] INFO: sess:33f8c268624c, time:0:00:00.526850, query:UPDATE pgbench_accounts SET abalance = abalance + 3877 WHERE aid = 326415;
   [2015-03-29 15:07:46] INFO: sess:b370afd07dcf, time:0:00:00.719780, query:SELECT abalance FROM pgbench_accounts WHERE aid = 852680;
   [2015-03-29 15:07:46] INFO: sess:0f04724051ad, time:0:00:00.543609, query:BEGIN;
   ^C[2015-03-29 15:07:51] INFO: Terminated.
   $
