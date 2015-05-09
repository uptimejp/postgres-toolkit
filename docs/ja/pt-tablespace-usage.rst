
pt-tablespace-usage
===================

概要
----

各データベースごとのテーブルスペースの使用状況を表示します。

各テーブルスペースについて、どのデータベースがどれくらい容量を使っているかを確認することができます。


実行方法
--------

.. code-block:: none

   pt-tablespace-usage [option...]

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

.. csv-table::

   ``TABLESPACE``, テーブルスペース名
   ``DBNAME``, データベース名（pg_globalテーブルスペースの場合は空欄）
   ``SIZE (MB)``, テーブルスペース内でデータベースのオブジェクトが使っている容量（MB単位）

実行例
------

ローカルホストのポート ``5432`` で動作するPostgreSQLインスタンスの ``postgres`` データベースに接続し、各テーブルスペースのうち、各データベースの使用している容量を表示します。

.. code-block:: none

   $ pt-tablespace-usage -d postgres
   +------------+-----------+-----------+
   | TABLESPACE |   DBNAME  | SIZE (MB) |
   +------------+-----------+-----------+
   | pg_default | postgres  |         8 |
   | pg_default | template1 |         6 |
   | pg_default | testdb    |         8 |
   | pg_global  |           |         1 |
   | spc1       | postgres  |        16 |
   +------------+-----------+-----------+
