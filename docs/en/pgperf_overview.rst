PgPerf Package Overview
=======================

What is PgPerf package?
-----------------------

The PgPerf package is a collection of SQL functions and tables to take snapshots of the performance statistics in PostgreSQL, and store them into dedicated snapshot tables.

"Performance statistics" mentioned here is following statistics available in PostgreSQL:

 * Database object access statistics in system views. (c.f. pg_stat_database)
 * Optimizer statistics in pg_statistic system table.
 * Other system statistics which could by taken by system functions. (c.f. pg_current_xlog_location())
 * Fragmentation statistics which could be taken by system functions. (c.f. pgstattuple())

By taking those performance statistics and storing them, DBA can understand what's actually going on inside the PostgreSQL databases, and also it would help DBA predict the future trend in terms of the performance.


Advantages of PgPerf package
----------------------------

The PgPerf package has following advantages:

 * It does not depend the platform where PostgreSQL is running. Provided scripts (SQL, PL/pgSQL) should work whereever you want.
 * It's easy to take and store several performance metrics, and it's also easy to analyze them later whatever you want.
 * It's easy to deploy (and undeploy) without changing any configuration in the production environment.


Supported Platform
------------------

The PgPerf package would work with following platforms.

 * PostgreSQL 9.0, 9,1, 9.2, 9.3, 9.4

It does not depend on the operating system.


PgPerf Components
-----------------

The PgPerf package consists of following components:

 * Dedicated schema to be used by the package.
 * SQL functions to take performance snapshots.
 * Snapshot tables to store performace snapshots.
 * Some shell scripts for convenience.


