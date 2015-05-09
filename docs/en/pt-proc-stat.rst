
pt-proc-stat
============

Summary
-------

Displays statistics I/O for each process.

Usage
-----

.. code-block:: none

   pt-proc-stat [option...] [delay [count]]


``pt-proc-stat`` Referring to proc file system. Make sure you run by running PostgreSQL user or root user.

Options
-------

.. code-block:: none

  -D, --pgdata=DATADIR
  -P, --pid=PID
  --help

``-D``, ``--pgdata`` 
Specifies the directory of the database cluster.

``-P``, ``--pid`` 
Specifies the process ID of the postmaster process.

Output Items
------------

.. csv-table::

   ``PROCESS NAME``, Process name
   ``PID``, Process ID
   ``STAT``, Status of the process
   ``USR``, User CPU time (Difference)
   ``SYS``, System CPU time (Difference)
   ``VSZ``, Virtual memory size (MB)
   ``RSS``, Usage of a physical memory (MB)
   ``READ``, Reading I/O volume is displayed differently between both of the data(kB).
   ``WRITE``, Writing I/O volume is displayed differently between both of the data(kB).
   ``READ2``, Load I/O except the ``READ`` (KB / Difference)
   ``WRITE2``, Load I/O except the ``WRITE`` (KB / Difference)

Examples
--------

It looks for the postmaster process automatically. Statistics I/O of the postmaster and the child process is displayed every five seconds twice.

.. code-block:: none

   $ sudo ./pt-proc-stat 5 2
   Fri May  1 22:23:39 JST 2015
           PROCESS NAME[  PID] STAT  USR  SYS  VSZ  RSS   READ  WRITE  READ2 WRITE2
             postmaster[24026]    S    4   13  100    9  23752 1290092 1090800 155357
                 logger[24028]    S    0    1   85    1      4     76     30    -45
           checkpointer[24030]    S    4  117  100    8    176  56768   -176 -46965
                 writer[24031]    S  104   66  100    9      0 291080      0 130560
             wal writer[24032]    S    8   19  100    1      0   2928      0      0
    autovacuum launcher[24033]    S    3    3  101    2      8      8    288      0
        stats collector[24034]    S   13   32   85    1      0   2140     34   -649
   snaga postgres 127.0[25473]    R   32    9  101    7    296   1472   1264      0
   snaga postgres 127.0[25474]    R   33    9  101    7    424   1384   1120      0
   snaga postgres 127.0[25475]    R   33    9  101    7    424   1448   1016      0
   snaga postgres 127.0[25476]    S   32    9  101    7    580   1400    780      0
   snaga postgres 127.0[25477]    R   32    9  101    7    908   1368    492      0
   
   Fri May  1 22:23:44 JST 2015
           PROCESS NAME[  PID] STAT  USR  SYS  VSZ  RSS   READ  WRITE  READ2 WRITE2
             postmaster[24026]    S    0    0  100    9      0      0      0      0
                 logger[24028]    S    0    0   85    1      0      0      0      0
           checkpointer[24030]    S    0    0  100    8      0      0      0      0
                 writer[24031]    S    4    1  100    9      0  11928      0    392
             wal writer[24032]    S    0    0  100    1      0      0      0      0
    autovacuum launcher[24033]    S    0    0  101    2      0      0      0      0
        stats collector[24034]    S    0    0   85    1      0      0      0      0
   snaga postgres 127.0[25473]    R   72   18  101   10   1772   3608   1740      0
   snaga postgres 127.0[25474]    R   68   20  101   10   1436   3920   2020      0
   snaga postgres 127.0[25475]    D   70   18  101   10   1304   4216   2368      0
   snaga postgres 127.0[25476]    R   70   20  101   10   1252   3384   2212      0
   snaga postgres 127.0[25477]    R   73   16  101   10   1464   3224   2080      0
   
   $
