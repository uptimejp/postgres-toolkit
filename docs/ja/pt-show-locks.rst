
pt-show-locks
=============

概要
----

待機中のロックと、その待機の原因となっているロックを、依存関係および実行中のクエリとともに表示します。


実行方法
--------

.. code-block:: none

   pt-show-locks [option...]

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

   ``BLOCKER``, ロックを待機している場合には、対象のロックを獲得しているバックエンドのプロセスID
   ``PID``, バックエンドのプロセスID
   ``LOCKTYPE``, ロックの種別
   ``MODE``, ロックの取得モード
   ``GRANTED``, ロックが獲得されていれば ``t`` 、獲得待ちなら ``f``
   ``QUERY``, 実行中のクエリ文字列

実行例
------

``postgres`` ユーザで ``mydb`` データベースに接続して、ロックの状態を表示します。

.. code-block:: none

   $ pg-show-locks -d mydb -U postgres
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   | BLOCKER | PID  | LOCKTYPE |         MODE        | GRANTED |                   QUERY                    |
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   |         | 2076 | relation | AccessExclusiveLock | t       | lock TABLE pgbench_accounts;               |
   |    2076 | 2049 | relation | RowShareLock        | f       | select * from pgbench_accounts for update; |
   |    2076 | 2436 | relation | RowExclusiveLock    | f       | delete from pgbench_accounts;              |
   +---------+------+----------+---------------------+---------+--------------------------------------------+
   $
