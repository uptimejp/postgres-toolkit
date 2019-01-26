
pt-show-last-analyzed
=====================

概要
----

各テーブルの最終ANALYZE時刻を表示します。


実行方法
--------

.. code-block:: none

   pt-show-last-analyzed [option...]

Options
-------

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

.. csv-table::

   ``SCHEMA``, テーブルの存在しているスキーマ名
   ``TABLE``, テーブル名
   ``LAST_ANALYZED``, 最終ANALYZE時刻

実行例
------

``testdb`` データベース内のテーブルの最終ANALYZE時刻を表示します。

.. code-block:: none

   $ pt-show-last-analyzed -h localhost -U postgres -d testdb
   +--------+------------------+----------------------------------+
   | SCHEMA |      TABLE       |          LAST_ANALYZED           |
   +--------+------------------+----------------------------------+
   | public | pgbench_history  | 2019-01-26 07:24:38.558291+00:00 |
   | public | pgbench_tellers  | 2019-01-26 07:24:38.559029+00:00 |
   | public | pgbench_branches | 2019-01-26 07:24:38.561584+00:00 |
   | public | pgbench_accounts | 2019-01-26 07:24:38.679717+00:00 |
   +--------+------------------+----------------------------------+
   
   $
