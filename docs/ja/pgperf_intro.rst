PgPerfパッケージの使い方
========================

この章ではPgPerfパッケージの導入から基本的な使い方を解説します。

PgPerfパッケージのインストール
------------------------------

PgPerfをインストールするには、スナップショットを取得するデータベースに対して ``pgperf_snapshot_install.sql`` スクリプトを実行して、該当データベース内に ``pgperf`` スキーマ、スナップショット関数、およびスナップショットテーブルを作成します。

.. code-block:: none

   psql -f pgperf_snapshot_install<VERSION>.sql <DBNAME>

PgPerfパッケージのアンインストール
----------------------------------

PgPerfパッケージをアンインストールする場合には、インストールしてあったデータベースに対して ``pgperf_snapshot_uninstall.sql`` スクリプトを実行します。

.. code-block:: none

   psql -f pgperf_snapshot_uninstall.sql <DBNAME>

``pgperf_snapshot_uninstall.sql`` を実行すると、該当データベース内の ``pgperf`` スキーマ、およびスキーマに含まれるスナップショット関数、スナップショットテーブルを一括して削除します。

スナップショットの取得
----------------------

スナップショットを取得するには、SQL関数 ``pgperf.create_snapshot()`` を実行します。

スナップショット取得レベルを指定して ``pgperf.create_snapshot()`` 関数を実行すると、各統計情報のスナップショットが取得され、取得されたスナップショットのスナップショットIDが返却されます。

以下の例では、スナップショット取得レベルを ``4`` としてスナップショットを取得し、そのスナップショットIDとして ``1005`` が返却されています。

::

 postgres=# SELECT pgperf.create_snapshot(4);
  create_snapshot
 -----------------
             1005
 (1 row)
 
 postgres=#


スナップショット一覧の取得
--------------------------

スナップショットの一覧を取得するには、 ``pgperf.snapshot`` テーブルの内容を表示します。

以下のように、スナップショットIDとスナップショットを取得した日時を取得することができます。

::

 postgres=# SELECT * FROM pgperf.snapshot;
  sid |             ts             | level
 -----+----------------------------+-------
    0 | 2015-04-11 19:11:24.04428  |     1
    1 | 2015-04-11 19:11:24.060965 |     2
    2 | 2015-04-11 19:11:24.110034 |     4
 (3 rows)
 
 postgres=#


スナップショットの削除
----------------------

スナップショットを削除するには、スナップショットIDを指定してSQL関数 ``pgperf.delete_snapshot()`` を実行します。

以下の例では、スナップショットIDが ``2`` のスナップショットを削除しています。

::

 postgres=# SELECT pgperf.delete_snapshot(2);
  delete_snapshot
 -----------------
  t
 (1 row)
 
 postgres=# SELECT * FROM pgperf.snapshot;
  sid |             ts             | level
 -----+----------------------------+-------
    0 | 2015-04-11 19:11:24.04428  |     1
    1 | 2015-04-11 19:11:24.060965 |     2
 (2 rows)
 
 postgres=#


定期的なスナップショットの取得
------------------------------

スナップショットを定期的に取得するには、cronなどを用いて定期的に ``pgperf.create_snapshot()`` を実行します。

パッケージに同梱されているシェルスクリプト ``get_snapshot.sh`` は指定したデータベース、または（テンプレート以外の接続が許可されている）すべてのデータベースに対して ``pgperf.create_snapshot()`` を実行します。

以下は ``postgres`` データベースのパフォーマンス統計情報のスナップショットを取得しています。

::

$ ./get_snapshot.sh postgres

以下はすべてのデータベースのパフォーマンス統計情報のスナップショットを取得しています。

::

$ ./get_snapshot.sh

crontabを設定することで、 ``get_snapshot.sh`` スクリプトを定期的に実行してスナップショットを取得することができます。

以下のcrontabの設定では10分おきに ``get_snapshot.sh`` スクリプトを実行して全データベースのパフォーマンス統計情報のスナップショットを取得しています。

::

 0-59/10 * * * *       /path/to/get_snapshot.sh > /dev/null 2>&1


古いスナップショットの消し込み
------------------------------

保存されている古いスナップショットを一括して削除するためには、SQL関数 ``pgperf.purge_snapshots()`` を実行します。

以下の例では、一週間以上前に作成されたスナップショットを削除しています。

::

 postgres=# SELECT sid,ts FROM pgperf.snapshot ORDER BY ts LIMIT 1;
  sid |             ts
 -----+----------------------------
    2 | 2012-10-21 18:20:01.238885
 (1 row)
 
 postgres=# SELECT now(),pgperf.purge_snapshots('1 weeks');
               now              | purge_snapshots
 -------------------------------+-----------------
  2012-10-29 14:57:04.092243+09 |             121
 (1 row)
 
 postgres=# SELECT sid,ts FROM pgperf.snapshot ORDER BY ts LIMIT 1;
  sid |            ts
 -----+--------------------------
  123 | 2012-10-22 15:00:01.8397
 (1 row)
 
 postgres=#

