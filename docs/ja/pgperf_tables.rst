スナップショットテーブル
========================

この章ではパフォーマンス統計情報のスナップショットを保存するテーブルについて解説します。

スナップショットテーブル一覧
----------------------------

パフォーマンス統計情報のスナップショットは、PostgreSQL内部の各種統計情報と対応する以下のテーブルに保存されます。

.. csv-table::
   :header-rows: 1

   テーブル名, 概要, 備考
   pgperf.snapshot, 取得したスナップショットのIDと取得時間を保存します
   pgperf.snapshot_pg_stat_database, pg_stat_databaseシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_database_size, データベースのサイズを保存します
   pgperf.snapshot_pg_stat_user_tables, pg_stat_user_tablesシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_statio_user_tables, pg_statio_user_tablesシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_stat_user_indexes, pg_stat_user_indexesシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_statio_user_indexes, pg_statio_user_indexesシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_statio_user_sequences, pg_statio_user_sequencesシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_stat_user_functions, pg_stat_user_functionsシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_relation_size, テーブルおよびインデックスのサイズを保存します
   pgperf.snapshot_pg_current_xlog, トランザクションログの挿入位置/書き込み位置を保存します
   pgperf.snapshot_pg_stat_bgwriter, pg_stat_bgwriterシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_stat_activity, pg_stat_activityシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_locks, pg_locksシステムビューのスナップショットを保存します
   pgperf.snapshot_pg_statistic, pg_statisticsシステムテーブルのスナップショットを保存します
   pgperf.snapshot_pg_stat_statements, pg_stat_statementsビューのスナップショットを保存します, 8.4以降のみ
   pgperf.snapshot_pgstattuple, pgstattuple関数の実行結果のスナップショットを保存します
   pgperf.snapshot_pgstatindex, pgstatindex関数の実行結果をスナップショットを保存します

pgperf.snapshotテーブル
-----------------------

スナップショット関数で取得したスナップショットのスナップショットIDおよび取得時間を保持するテーブルです。

===================== ================ ======================== ============
カラム名              データ型         取得元                   備考
===================== ================ ======================== ============
sid                   integer          スナップショットID       単調増加
ts                    timestamp        スナップショット取得時刻
level                 integer          スナップショットレベル
===================== ================ ======================== ============



pgperf.snapshot_pg_stat_databaseテーブル
----------------------------------------

アクセス統計情報を取得する ``pg_stat_database`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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
conflicts             bigint           pg_stat_database.conflicts             9.1以降のみ
stats_reset           timestampz       pg_stat_database.stats_reset           9.1以降のみ
===================== ================ ====================================== ===========


pgperf.snapshot_pg_database_sizeテーブル
----------------------------------------

データベースのサイズを取得する ``pg_database_size()`` 関数のスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
datname               name             pg_database.datname
pg_database_size      bigint           pg_database_size()
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_user_tablesテーブル
-------------------------------------------

アクセス統計情報を取得する ``pg_stat_user_tables`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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
vacuum_count          bigint           pg_stat_user_tables.vacuum_count       9.1以降のみ
autovacuum_count      bigint           pg_stat_user_tables.autovacuum_count   9.1以降のみ
analyze_count         bigint           pg_stat_user_tables.analyze_count      9.1以降のみ
autoanalyze_count     bigint           pg_stat_user_tables.autoanalyze_count  9.1以降のみ
===================== ================ ====================================== ===========

pgperf.snapshot_pg_statio_user_tablesテーブル
---------------------------------------------

アクセス統計情報を取得する ``pg_statio_user_tables`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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


pgperf.snapshot_pg_stat_user_indexesテーブル
--------------------------------------------

アクセス統計情報を取得する ``pg_stat_user_indexes`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
relid                 oid              pg_stat_user_indexes.relid
indexrelid            oid              pg_stat_user_indexes.indexrelid
schemaname            name             pg_stat_user_indexes.schemaname
relname               name             pg_stat_user_indexes.relname
indexrelname          name             pg_stat_user_indexes.indexrelname
idx_scan              bigint           pg_stat_user_indexes.idx_scan
idx_tup_read          bigint           pg_stat_user_indexes.idx_tup_read
idx_tup_fetch         bigint           pg_stat_user_indexes.idx_tup_fetch
===================== ================ ====================================== ===========


pgperf.snapshot_pg_statio_user_indexesテーブル
----------------------------------------------

アクセス統計情報を取得する ``pg_statio_user_indexes`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
relid                 oid              pg_statio_user_indexes.relid
indexrelid            oid              pg_statio_user_indexes.indexrelid
schemaname            name             pg_statio_user_indexes.schemaname
relname               name             pg_statio_user_indexes.relname
indexrelname          name             pg_statio_user_indexes.indexrelname
idx_blks_read         bigint           pg_statio_user_indexes.idx_blks_read
idx_blks_hit          bigint           pg_statio_user_indexes.idx_blks_hit
===================== ================ ====================================== ===========


pgperf.snapshot_pg_statio_user_sequencesテーブル
------------------------------------------------

アクセス統計情報を取得する ``pg_statio_user_sequences`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
relid                 oid              pg_statio_user_sequences.relid
schemaname            name             pg_statio_user_sequences.schemaname
relname               name             pg_statio_user_sequences.relname
blks_read             int8             pg_statio_user_sequences.blks_read
blks_hit              int8             pg_statio_user_sequences.blks_hit
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_user_functionsテーブル
----------------------------------------------

アクセス統計情報を取得する ``pg_stat_user_functions`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
funcid                oid              pg_stat_user_functions.funcid
schemaname            name             pg_stat_user_functions.schemaname
funcname              name             pg_stat_user_functions.funcname
calls                 int8             pg_stat_user_functions.calls
total_time            int8             pg_stat_user_functions.total_time
self_time             int8             pg_stat_user_functions.self_time
===================== ================ ====================================== ===========


pgperf.snapshot_pg_relation_sizeテーブル
----------------------------------------

テーブルおよびインデックスのサイズを取得する ``pg_relation_size()``, ``pg_total_relation_size()`` 関数のスナップショットを保存するテーブルです。

====================== ================ ====================================== =============================
カラム名               データ型         取得元                                 備考
====================== ================ ====================================== =============================
sid                    integer          スナップショットID
schemaname             name             pg_stat_user_tables.schemaname,
                                        pg_stat_user_indexes.schemaname
relid                  oid              pg_stat_user_tables.relid,
                                        pg_stat_user_indexes.indexrelid
relname                name             pg_class.relname
pg_relation_size       bigint           pg_relaion_size()
pg_total_relation_size bigint           pg_total_relaion_size()                対象がテーブルの場合のみ有効
====================== ================ ====================================== =============================


pgperf.snapshot_pg_current_xlogテーブル
---------------------------------------

トランザクションログの位置を取得する ``pg_current_xlog_location()``, ``pg_current_xlog_insert_location()`` 関数のスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
location              text             pg_current_xlog_location()
insert_location       text             pg_current_xlog_insert_location()
===================== ================ ====================================== ===========

pgperf.snapshot_pg_stat_bgwriterテーブル
----------------------------------------

バックグラウンドライタ統計情報を取得する ``pg_stat_bgwriter`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
checkpoints_timed     bigint           pg_stat_bgwriter.checkpoints_timed
checkpoints_req       bigint           pg_stat_bgwriter.checkpoints_req
checkpoint_write_time double precision pg_stat_bgwriter.checkpoint_write_time 9.2以降のみ
checkpoint_sync_time  double precision pg_stat_bgwriter.checkpoint_sync_time  9.2以降のみ
buffers_checkpoint    bigint           pg_stat_bgwriter.buffers_checkpoint
buffers_clean         bigint           pg_stat_bgwriter.buffers_clean
maxwritten_clean      bigint           pg_stat_bgwriter.maxwritten_clean
buffers_backend       bigint           pg_stat_bgwriter.buffers_backend
buffers_backend_fsync bigint           pg_stat_bgwriter.buffers_backend_fsync 9.1以降のみ
buffers_alloc         bigint           pg_stat_bgwriter.buffers_alloc
stats_reset           timestampz       pg_stat_bgwriter.stats_reset           9.1以降のみ
===================== ================ ====================================== ===========


pgperf.snapshot_pg_stat_activityテーブル
----------------------------------------

セッション情報を取得する ``pg_stat_activity`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
datid                 oid              pg_stat_activity.datid
datname               name             pg_stat_activity.datname
procpid               int4             pg_stat_activity.procpid               9.1以前
pid                   int4             pg_stat_activity.pid                   9.2以降
usesysid              oid              pg_stat_activity.usesysid
usename               name             pg_stat_activity.usename
application_name      text             pg_stat_activity.application_name      9.0以降
client_addr           inet             pg_stat_activity.client_addr
client_hostname       text             pg_stat_activity.client_hostname       9.1以降
client_port           int4             pg_stat_activity.client_port
backend_start         timestamptz      pg_stat_activity.backend_start
xact_start            timestamptz      pg_stat_activity.xact_start
query_start           timestamptz      pg_stat_activity.query_start
state_change          timestamptz      pg_stat_activity.state_change          9.2以降
waiting               bool             pg_stat_activity.waiting
state                 text             pg_stat_activity.state                 9.2以降
current_query         text             pg_stat_activity.current_query         9.1以前
query                 text             pg_stat_activity.query                 9.2以降
===================== ================ ====================================== ===========

pgperf.snapshot_pg_locksテーブル
--------------------------------

ロック情報を取得する ``pg_locks`` システムビューのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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
fastpath              bool             pg_locks.fastpath                      9.2以降
===================== ================ ====================================== ===========

pgperf.snapshot_pg_statisticテーブル
------------------------------------

オプティマイザ統計情報を保持する ``pg_statistic`` システムテーブルのスナップショットを保存するテーブルです。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
starelid              oid              pg_statistic.starelid
starelname            name             pg_class.relname
staattnum             smallint         pg_statistic.staattnum
staattname            name             pg_attribute.attname
stainherit            boolean          pg_statistic.stainherit                9.0以降
stanullfrac           real             pg_statistic.stanullfrac
stawidth              integer          pg_statistic.stawidth
stadistinct           real             pg_statistic.stadistinct
stakind1              smallint         pg_statistic.stakind1
stakind2              smallint         pg_statistic.stakind2
stakind3              smallint         pg_statistic.stakind3
stakind4              smallint         pg_statistic.stakind4
stakind5              smallint         pg_statistic.stakind5                  9.2以降
staop1                oid              pg_statistic.staop1
staop2                oid              pg_statistic.staop2
staop3                oid              pg_statistic.staop3
staop4                oid              pg_statistic.staop4
staop5                oid              pg_statistic.staop5                    9.2以降
stanumbers1           real[]           pg_statistic.stanumbers1
stanumbers2           real[]           pg_statistic.stanumbers2
stanumbers3           real[]           pg_statistic.stanumbers3
stanumbers4           real[]           pg_statistic.stanumbers4
stanumbers5           real[]           pg_statistic.stanumbers5               9.2以降
stavalues1            text             pg_statistic.stavalues1
stavalues2            text             pg_statistic.stavalues2
stavalues3            text             pg_statistic.stavalues3
stavalues4            text             pg_statistic.stavalues4
stavalues5            text             pg_statistic.stavalues5                9.2以降
===================== ================ ====================================== ===========

pgperf.snapshot_pg_stat_statementsテーブル
------------------------------------------

セッション統計情報を取得する ``pg_stat_statements`` システムビューのスナップショットを保存するテーブルです。アドオンモジュール ``pg_stat_statements`` をインストール、設定している場合のみ有効です。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
userid                oid              pg_stat_statements.userid
dbid                  oid              pg_stat_statements.dbid
query                 text             pg_stat_statements.query
calls                 bigint           pg_stat_statements.calls
total_time            double precision pg_stat_statements.total_time
rows                  bigint           pg_stat_statements.rows
shared_blks_hit       bigint           pg_stat_statements.shared_blks_hit
shared_blks_read      bigint           pg_stat_statements.shared_blks_read
shared_blks_dirtied   bigint           pg_stat_statements.shared_blks_dirtied 9.2以降
shared_blks_written   bigint           pg_stat_statements.shared_blks_written
local_blks_hit        bigint           pg_stat_statements.local_blks_hit
local_blks_read       bigint           pg_stat_statements.local_blks_read
local_blks_dirtied    bigint           pg_stat_statements.local_blks_dirtied  9.2以降
local_blks_written    bigint           pg_stat_statements.local_blks_written
temp_blks_read        bigint           pg_stat_statements.temp_blks_read
temp_blks_written     bigint           pg_stat_statements.temp_blks_written
blk_read_time         double precision pg_stat_statements.blk_read_time       9.2以降
blk_write_time        double precision pg_stat_statements.blk_write_time      9.2以降
===================== ================ ====================================== ===========

pgperf.snapshot_pgstattupleテーブル
-----------------------------------

テーブルのフラグメンテーション情報を取得する ``pgstattuple()`` 関数のスナップショットを保存するテーブルです。アドオンモジュール ``pgstattuple`` をインストール、設定している場合のみ有効です。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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

pgperf.snapshot_pgstatindexテーブル
-----------------------------------

インデックスのフラグメンテーション情報を取得する ``pgstatindex()`` 関数のスナップショットを保存するテーブルです。アドオンモジュール ``pgstattuple`` をインストール、設定している場合のみ有効です。

===================== ================ ====================================== ===========
カラム名              データ型         取得元                                 備考
===================== ================ ====================================== ===========
sid                   integer          スナップショットID
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

