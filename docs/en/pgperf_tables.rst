Snapshot Tables
===============

This chapter is intended to give detailed information about several snapshot tables, where the performance snapshot to be stored.

Snapshot Table List
-------------------

Performance snapshot is going to be stored in the following tables associated with each performance statistics available in PostgreSQL.

.. csv-table::
   :header-rows: 1

   Table Name, Description, Note
   pgperf.snapshot, Stores snapshot id and timestamp of the performance snapshot.
   pgperf.snapshot_pg_stat_database, Stores a snapshot of the pg_stat_database system view.
   pgperf.snapshot_pg_database_size, Stores a snapshot of the database size.
   pgperf.snapshot_pg_stat_user_tables, Stores a snapshot of the pg_stat_user_tables system view.
   pgperf.snapshot_pg_statio_user_tables, Stores a snapshot of the pg_statio_user_tables system view.
   pgperf.snapshot_pg_stat_user_indexes, Stores a snapshot of the pg_stat_user_indexes system view.
   pgperf.snapshot_pg_statio_user_indexes, Stores a snapshot of the pg_statio_user_indexes system view.
   pgperf.snapshot_pg_statio_user_sequences, Stores a snapshot of the pg_statio_user_sequences system view.
   pgperf.snapshot_pg_stat_user_functions, Stores a snapshot of the pg_stat_user_functions system view.
   pgperf.snapshot_pg_relation_size, Stores a snaphsot of the table and index size.
   pgperf.snapshot_pg_current_xlog, Stores a snapshot of the current xlog location and the current insert location.
   pgperf.snapshot_pg_stat_bgwriter, Stores a snapshot of the pg_stat_bgwriter system view.
   pgperf.snapshot_pg_stat_activity, Stores a snapshot of the pg_stat_activity system view.
   pgperf.snapshot_pg_locks, Stores a snapshot of the pg_locks system view.
   pgperf.snapshot_pg_statistic, Stores a snapshot of the pg_statistics system table.
   pgperf.snapshot_pg_stat_statements, Stores a snapshot of the pg_stat_statements view., 8.4 or later
   pgperf.snapshot_pgstattuple, Stores a snapshot of the result of pgstattuple function.
   pgperf.snapshot_pgstatindex, Stores a snapshot of the result of pgstatindex function.

pgperf.snapshot Table
---------------------

This table stores snapshot id and timestamp of each snapshot taken by the snapshot function.

===================== ================ ========================= ============
Column Name           Type             Source                    Note
===================== ================ ========================= ============
sid                   integer          Snapshot ID               Monotone increasing
ts                    timestamp        Timestamp of the snapshot
level                 integer          Snapshot level
===================== ================ ========================= ============



pgperf.snapshot_pg_stat_database Table
--------------------------------------

This table stores snapshots of the ``pg_stat_database`` system view which contains the database access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
datid                 oid              pg_stat_database.datid
datname               name             pg_stat_database.datname
numbackends           integer          pg_stat_database.numbackends
xact_commit           bigint           pg_stat_database.xact_commit
xact_rollback         bigint           pg_stat_database.xact_rollback
blks_read             bigint           pg_stat_database.blks_read
blks_hit              bigint           pg_stat_database.blks_hit
tup_returned          bigint           pg_stat_database.tup_returned
tup_fetched           bigint           pg_stat_database.tup_fetched
tup_inserted          bigint           pg_stat_database.tup_inserted
tup_updated           bigint           pg_stat_database.tup_updated
tup_deleted           bigint           pg_stat_database.tup_deleted
conflicts             bigint           pg_stat_database.conflicts             9.1 or later
stats_reset           timestampz       pg_stat_database.stats_reset           9.1 or later
===================== ================ ====================================== ===========


pgperf.snapshot_pg_database_size Table
--------------------------------------

This table stores snapshots of result of the ``pg_database_size()`` function which gets database size.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
datname               name             pg_database.datname
pg_database_size      bigint           pg_database_size()
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_user_tables Table
-----------------------------------------

This table stores snapshots of the ``pg_stat_user_tables`` system view which contains the table access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
relid                 oid              pg_stat_user_tables.relid
schemaname            name             pg_stat_user_tables.schemaname
relname               name             pg_stat_user_tables.relname
seq_scan              bigint           pg_stat_user_tables.seq_scan
seq_tup_read          bigint           pg_stat_user_tables.seq_tup_read
idx_scan              bigint           pg_stat_user_tables.idx_scan
idx_tup_fetch         bigint           pg_stat_user_tables.idx_tup_fetch
n_tup_ins             bigint           pg_stat_user_tables.n_tup_ins
n_tup_upd             bigint           pg_stat_user_tables.n_tup_upd
n_tup_del             bigint           pg_stat_user_tables.n_tup_del
n_tup_hot_upd         bigint           pg_stat_user_tables.n_tup_hot_upd
n_live_tup            bigint           pg_stat_user_tables.n_live_tup
n_dead_tup            bigint           pg_stat_user_tables.n_dead_tup
last_vacuum           timestampz       pg_stat_user_tables.last_vacuum
last_autovacuum       timestampz       pg_stat_user_tables.last_autovacuum
last_analyze          timestampz       pg_stat_user_tables.last_analyze
last_autoanalyze      timestampz       pg_stat_user_tables.last_autoanalyze
vacuum_count          bigint           pg_stat_user_tables.vacuum_count       9.1 or later
autovacuum_count      bigint           pg_stat_user_tables.autovacuum_count   9.1 or later
analyze_count         bigint           pg_stat_user_tables.analyze_count      9.1 or later
autoanalyze_count     bigint           pg_stat_user_tables.autoanalyze_count  9.1 or later
===================== ================ ====================================== ===========

pgperf.snapshot_pg_statio_user_tables Table
-------------------------------------------

This table stores snapshots of the ``pg_statio_user_tables`` system view which contains the table access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
relid                 oid              pg_statio_user_tables.relid
schemaname            name             pg_statio_user_tables.schemaname
relname               name             pg_statio_user_tables.relname
heap_blks_read        bigint           pg_statio_user_tables.heap_blks_read
heap_blks_hit         bigint           pg_statio_user_tables.heap_blks_hit
idx_blks_read         bigint           pg_statio_user_tables.idx_blks_read
idx_blks_hit          bigint           pg_statio_user_tables.idx_blks_hit
toast_blks_read       bigint           pg_statio_user_tables.toast_blks_read
toast_blks_hit        bigint           pg_statio_user_tables.toast_blks_hit
tidx_blks_read        bigint           pg_statio_user_tables.tidx_blks_read
tidx_blks_hit         bigint           pg_statio_user_tables.tidx_blks_hit
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_user_indexes Table
------------------------------------------

This table stores snapshots of the ``pg_stat_user_indexes`` system view which contains the index access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
relid                 oid              pg_stat_user_indexes.relid
indexrelid            oid              pg_stat_user_indexes.indexrelid
schemaname            name             pg_stat_user_indexes.schemaname
relname               name             pg_stat_user_indexes.relname
indexrelname          name             pg_stat_user_indexes.indexrelname
idx_scan              bigint           pg_stat_user_indexes.idx_scan
idx_tup_read          bigint           pg_stat_user_indexes.idx_tup_read
idx_tup_fetch         bigint           pg_stat_user_indexes.idx_tup_fetch
===================== ================ ====================================== ===========


pgperf.snapshot_pg_statio_user_indexes Table
--------------------------------------------

This table stores snapshots of the ``pg_statio_user_indexes`` system view which contains the index access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
relid                 oid              pg_statio_user_indexes.relid
indexrelid            oid              pg_statio_user_indexes.indexrelid
schemaname            name             pg_statio_user_indexes.schemaname
relname               name             pg_statio_user_indexes.relname
indexrelname          name             pg_statio_user_indexes.indexrelname
idx_blks_read         bigint           pg_statio_user_indexes.idx_blks_read
idx_blks_hit          bigint           pg_statio_user_indexes.idx_blks_hit
===================== ================ ====================================== ===========


pgperf.snapshot_pg_statio_user_sequences Table
----------------------------------------------

This table stores snapshots of the ``pg_statio_user_sequences`` system view which contains the sequence access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
relid                 oid              pg_statio_user_sequences.relid
schemaname            name             pg_statio_user_sequences.schemaname
relname               name             pg_statio_user_sequences.relname
blks_read             int8             pg_statio_user_sequences.blks_read
blks_hit              int8             pg_statio_user_sequences.blks_hit
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_user_functions Table
--------------------------------------------

This table stores snapshots of the ``pg_stat_user_functions`` system view which contains the function access statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
funcid                oid              pg_stat_user_functions.funcid
schemaname            name             pg_stat_user_functions.schemaname
funcname              name             pg_stat_user_functions.funcname
calls                 int8             pg_stat_user_functions.calls
total_time            int8             pg_stat_user_functions.total_time
self_time             int8             pg_stat_user_functions.self_time
===================== ================ ====================================== ===========


pgperf.snapshot_pg_relation_size Table
--------------------------------------

This table stores snapshots of the result of ``pg_relation_size()`` and ``pg_total_relation_size()`` function which gets table and/or index size.

====================== ================ ====================================== =============================
Column Name            Type             Source                                 Note
====================== ================ ====================================== =============================
sid                    integer          Snapshot ID
schemaname             name             pg_stat_user_tables.schemaname,
                                        pg_stat_user_indexes.schemaname
relid                  oid              pg_stat_user_tables.relid,
                                        pg_stat_user_indexes.indexrelid
relname                name             pg_class.relname
pg_relation_size       bigint           pg_relaion_size()
pg_total_relation_size bigint           pg_total_relaion_size()                Available only for tables
====================== ================ ====================================== =============================


pgperf.snapshot_pg_current_xlog Table
-------------------------------------

This table stores snapshots of the result of ``pg_current_xlog_location()`` and ``pg_current_xlog_insert_location()`` function which gets current WAL locations.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snaphsot ID
location              text             pg_current_xlog_location()
insert_location       text             pg_current_xlog_insert_location()
===================== ================ ====================================== ===========

pgperf.snapshot_pg_stat_bgwriter Table
--------------------------------------

This table stores snapshots of the ``pg_stat_bgwriter`` system view which contains the background writer statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
checkpoints_timed     bigint           pg_stat_bgwriter.checkpoints_timed
checkpoints_req       bigint           pg_stat_bgwriter.checkpoints_req
checkpoint_write_time double precision pg_stat_bgwriter.checkpoint_write_time 9.2 or later
checkpoint_sync_time  double precision pg_stat_bgwriter.checkpoint_sync_time  9.2 or later
buffers_checkpoint    bigint           pg_stat_bgwriter.buffers_checkpoint
buffers_clean         bigint           pg_stat_bgwriter.buffers_clean
maxwritten_clean      bigint           pg_stat_bgwriter.maxwritten_clean
buffers_backend       bigint           pg_stat_bgwriter.buffers_backend
buffers_backend_fsync bigint           pg_stat_bgwriter.buffers_backend_fsync 9.1 or later
buffers_alloc         bigint           pg_stat_bgwriter.buffers_alloc
stats_reset           timestampz       pg_stat_bgwriter.stats_reset           9.1 or later
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_activity Table
--------------------------------------

This table stores snapshots of the ``pg_stat_activity`` system view which contains the session information.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
datid                 oid              pg_stat_activity.datid
datname               name             pg_stat_activity.datname
procpid               int4             pg_stat_activity.procpid               9.1 or before
pid                   int4             pg_stat_activity.pid                   9.2 or later
usesysid              oid              pg_stat_activity.usesysid
usename               name             pg_stat_activity.usename
application_name      text             pg_stat_activity.application_name      9.0 or later
client_addr           inet             pg_stat_activity.client_addr
client_hostname       text             pg_stat_activity.client_hostname       9.1 or later
client_port           int4             pg_stat_activity.client_port
backend_start         timestamptz      pg_stat_activity.backend_start
xact_start            timestamptz      pg_stat_activity.xact_start
query_start           timestamptz      pg_stat_activity.query_start
state_change          timestamptz      pg_stat_activity.state_change          9.2 or later
waiting               bool             pg_stat_activity.waiting
state                 text             pg_stat_activity.state                 9.2 or later
current_query         text             pg_stat_activity.current_query         9.1 or before
query                 text             pg_stat_activity.query                 9.2 or later
===================== ================ ====================================== ===========

pgperf.snapshot_pg_locks Table
------------------------------

This table stores snapshots of the ``pg_locks`` system view which contains the lock information.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
locktype              text             pg_locks.locktype
database              oid              pg_locks.database
relation              oid              pg_locks.relation
page                  int4             pg_locks.page
tuple                 int2             pg_locks.tuple
virtualxid            text             pg_locks.virtualxid
transactionid         xid              pg_locks.transactionid
classid               oid              pg_locks.classid
objid                 oid              pg_locks.objid
objsubid              int2             pg_locks.objsubid
virtualtransaction    text             pg_locks.virtualtransaction
pid                   int4             pg_locks.pid
mode                  text             pg_locks.mode
granted               bool             pg_locks.granted
fastpath              bool             pg_locks.fastpath                      9.2 or later
===================== ================ ====================================== ===========

pgperf.snapshot_pg_statistic Table
----------------------------------

This table stores snapshots of the ``pg_statistic`` system table which contains the optimizer statistics.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
starelid              oid              pg_statistic.starelid
starelname            name             pg_class.relname
staattnum             smallint         pg_statistic.staattnum
staattname            name             pg_attribute.attname
stainherit            boolean          pg_statistic.stainherit                9.0 or later
stanullfrac           real             pg_statistic.stanullfrac
stawidth              integer          pg_statistic.stawidth
stadistinct           real             pg_statistic.stadistinct
stakind1              smallint         pg_statistic.stakind1
stakind2              smallint         pg_statistic.stakind2
stakind3              smallint         pg_statistic.stakind3
stakind4              smallint         pg_statistic.stakind4
stakind5              smallint         pg_statistic.stakind5                  9.2 or later
staop1                oid              pg_statistic.staop1
staop2                oid              pg_statistic.staop2
staop3                oid              pg_statistic.staop3
staop4                oid              pg_statistic.staop4
staop5                oid              pg_statistic.staop5                    9.2 or later
stanumbers1           real[]           pg_statistic.stanumbers1
stanumbers2           real[]           pg_statistic.stanumbers2
stanumbers3           real[]           pg_statistic.stanumbers3
stanumbers4           real[]           pg_statistic.stanumbers4
stanumbers5           real[]           pg_statistic.stanumbers5               9.2 or later
stavalues1            text             pg_statistic.stavalues1
stavalues2            text             pg_statistic.stavalues2
stavalues3            text             pg_statistic.stavalues3
stavalues4            text             pg_statistic.stavalues4
stavalues5            text             pg_statistic.stavalues5                9.2 or later
===================== ================ ====================================== ===========

pgperf.snapshot_pg_stat_statements Table
----------------------------------------

This table stores snapshots of the ``pg_stat_statements`` view which contains the session statistics. This table is available only when the ``pg_stat_statements`` module has been installed and enabled.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
userid                oid              pg_stat_statements.userid
dbid                  oid              pg_stat_statements.dbid
query                 text             pg_stat_statements.query
calls                 bigint           pg_stat_statements.calls
total_time            double precision pg_stat_statements.total_time
rows                  bigint           pg_stat_statements.rows
shared_blks_hit       bigint           pg_stat_statements.shared_blks_hit
shared_blks_read      bigint           pg_stat_statements.shared_blks_read
shared_blks_dirtied   bigint           pg_stat_statements.shared_blks_dirtied 9.2 or later
shared_blks_written   bigint           pg_stat_statements.shared_blks_written
local_blks_hit        bigint           pg_stat_statements.local_blks_hit
local_blks_read       bigint           pg_stat_statements.local_blks_read
local_blks_dirtied    bigint           pg_stat_statements.local_blks_dirtied  9.2 or later
local_blks_written    bigint           pg_stat_statements.local_blks_written
temp_blks_read        bigint           pg_stat_statements.temp_blks_read
temp_blks_written     bigint           pg_stat_statements.temp_blks_written
blk_read_time         double precision pg_stat_statements.blk_read_time       9.2 or later
blk_write_time        double precision pg_stat_statements.blk_write_time      9.2 or later
===================== ================ ====================================== ===========

pgperf.snapshot_pgstattuple Table
---------------------------------

This table stores snapshots of the result of the ``pgstattuple()`` function which gets the table fragmentation statistics. This table is available only when the ``pgstattuple`` module has been installed.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
schemaname            name             pg_stat_user_tables.schemaname
relname               name             pg_stat_user_tables.relname
table_len             int8             pgstattuple().table_len
tuple_count           int8             pgstattuple().tuple_count
tuple_len             int8             pgstattuple().tuple_len
tuple_percent         float8           pgstattuple().tuple_percent
dead_tuple_count      int8             pgstattuple().dead_tuple_count
dead_tuple_len        int8             pgstattuple().dead_tuple_len
dead_tuple_percent    float8           pgstattuple().dead_tuple_percent
free_space            int8             pgstattuple().free_space
free_percent          float8           pgstattuple().free_percent
===================== ================ ====================================== ===========

pgperf.snapshot_pgstatindex Table
---------------------------------

This table stores snapshots of the result of the ``pgstatindex()`` function which gets the index fragmentation statistics. This table is available only when the ``pgstattuple`` module has been installed.

===================== ================ ====================================== ===========
Column Name           Type             Source                                 Note
===================== ================ ====================================== ===========
sid                   integer          Snapshot ID
schemaname            name             pg_stat_user_indexes.schemaname
relname               name             pg_stat_user_indexes.relname
indexrelname          name             pg_stat_user_indexes.indexrelname
version               int4             pgstatindex().version
tree_level            int4             pgstatindex().tree_level
index_size            int8             pgstatindex().index_size
root_block_no         int8             pgstatindex().root_block_no
internal_pages        int8             pgstatindex().internal_pages
leaf_pages            int8             pgstatindex().leaf_pages
empty_pages           int8             pgstatindex().empty_pages
deleted_pages         int8             pgstatindex().deleted_pages
avg_leaf_density      float8           pgstatindex().avg_leaf_density
leaf_fragmentation    float8           pgstatindex().leaf_fragmentation
===================== ================ ====================================== ===========

