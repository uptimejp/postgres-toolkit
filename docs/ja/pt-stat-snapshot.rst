
pt-stat-snapshot
================

概要
----

統計情報のスナップショットを取得、保存、管理します。


実行方法
--------

.. code-block:: none

   pt-stat-snapshot [option...] install
   pt-stat-snapshot [option...] uninstall
   pt-stat-snapshot [option...] create [level]
   pt-stat-snapshot [option...] list
   pt-stat-snapshot [option...] delete [sid]
   pt-stat-snapshot [option...] export [file]
   pt-stat-snapshot [option...] import [file]

コマンド
--------

.. csv-table::

  ``install``, 動作に必要なスキーマ、テーブルや関数の作成などを行います。
  ``uninstall``, 関連するスキーマ、テーブルや関数などを削除します。
  ``create [level]``, スナップショットを取得します。レベルには ``1``, ``2``, ``4`` のいずれかを指定できます。
  ``list``, 保存されているスナップショットの一覧を表示します。
  ``delete [sid]``, 指定したスナップショットIDのスナップショットを削除します。 ``M:N`` のように記述することで範囲指定することが可能です。
  ``export [file]``, 指定したファイルにスナップショットデータをエクスポートします。
  ``import [file]``, 指定したファイルからスナップショットデータをインポートします。


オプション
----------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  --help

``-h``, ``--host`` オプションは、接続するPostgreSQLデータベースのサーバ名またはIPアドレスを指定します。オプションが指定されない場合は、PGHOST環境変数に設定された値が使われます。PGHOST環境変数が設定されていない場合には、デフォルトの値として ``localhost`` が使われます。

``-p``, ``--port`` オプションは、接続するPostgreSQLデータベースのポート番号を指定します。オプションが指定されない場合は、PGPORT環境変数に設定された値が使われます。PGPORT環境変数が設定されていない場合には、デフォルトの値として ``5432`` が使われます。

``-U``, ``--username`` オプションは、PostgreSQLデータベースに接続するユーザ名を指定します。オプションが指定されない場合は、PGUSER環境変数に設定された値が使われます。PGUSER環境変数が設定されていない場合には、USER環境変数に設定された値が使われます。

``-d``, ``--dbname`` オプションは、接続するデータベース名を指定します。オプションが指定されない場合は、PGDATABASE環境変数に設定された値が使われます。PGDATABASE環境変数が設定されていない場合には、データベースに接続するユーザ名と同じ名前のデータベースに接続します。


出力項目
--------

``list`` コマンドで表示される項目は以下の通りです。

.. csv-table::

   ``SID``, スナップショットID（スナップショットを取得するごとに単調増加する整数値）
   ``TIMESTAMP``, スナップショットを取得したタイムスタンプ
   ``LEVEL``, スナップショットレベル

実行例
------

動作に必要なスキーマ、テーブル、関数を ``testdb`` データベースにインストールします。

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb install
   [2015-03-31 17:21:37] INFO: Succeeded to install pgperf snapshot.
   $

スナップショットレベル4でスナップショットを取得します。

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb create 4
   [2015-03-31 17:21:47] INFO: Succeeded to take a snapshot.
   $

スナップショットの一覧を表示します。

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb list
   +-----+---------------------+-------+
   | SID |      TIMESTAMP      | LEVEL |
   +-----+---------------------+-------+
   |   0 | 2015-03-31 17:21:47 |     1 |
   +-----+---------------------+-------+
   $

関連するスキーマ、テーブル、関数を ``testdb`` データベースからアンインストールします。

.. code-block:: none

   $ pt-stat-snapshot -h 127.0.0.1 -U postgres -d testdb uninstall
   [2015-03-31 17:21:59] INFO: Succeeded to uninstall pgperf snapshot.
   $

pgperf-snapshotモジュールについて
---------------------------------

``pt-stat-snapshot`` コマンドは、その内部で旧 pgperf-snapshot モジュールを使っています。

pgperf-snapshotモジュールについての詳細は、以下のドキュメントを参照してください。

.. toctree::
   :maxdepth: 2

   pgperf_overview.rst
   pgperf_intro.rst
   pgperf_functions.rst
   pgperf_tables.rst
