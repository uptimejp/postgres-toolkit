
pt-privilege-autogen
====================

概要
----

ユーザおよびデータベースオブジェクトに対する最小の権限を付与するためのREVOKE/GRANT文を生成します。アプリケーションのアクセスポリシーを学習するためにPostgreSQLの統計情報を利用します。

実行方法
--------

.. code-block:: none

   pt-privilege-autogen [option...] [ start | stop ]
   pt-privilege-autogen [option...] generate <USERNAME>

コマンド
--------

.. csv-table::

  ``start``, データベース内のテーブルのアクセス統計情報の収集を開始します。
  ``generate``, 収集したテーブルのアクセス統計情報をもとにREVOKE/GRANT文を生成します。権限を設定したい対象のユーザ名を引数に取ります。
  ``stop``, データベース内のテーブルのアクセス統計情報の収集を停止します。

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

このコマンドは、PostgreSQLデータベースに対して実行可能なGRANT/REVOKE文を出力します。

実行例
------

以下の例では、``snaga`` ユーザに対してpgbenchのトランザクションを実行するために必要な、最小限の権限を実現するためのREVOKE/GRANT文を生成しています。

一連の作業は、すでに権限のあるユーザで行います。この例では管理者ユーザ ``postgres`` で実行しています。

まず最初に、pgbench用のデータベースを管理者権限で作成し、通常のユーザではテーブルにアクセスできないことを確認します。

.. code-block:: none

   $ createdb -U postgres mydb
   $ pgbench -i -U postgres mydb
   NOTICE:  table "pgbench_history" does not exist, skipping
   NOTICE:  table "pgbench_tellers" does not exist, skipping
   NOTICE:  table "pgbench_accounts" does not exist, skipping
   NOTICE:  table "pgbench_branches" does not exist, skipping
   creating tables...
   100000 of 100000 tuples (100%) done (elapsed 0.70 s, remaining 0.00 s).
   vacuum...
   set primary keys...
   done.
   $ pgbench -c 1 -t 1 -U snaga -n mydb
   ERROR:  permission denied for relation pgbench_branches
   $

次に、テーブルのアクセス統計情報の収集を開始し、pgbenchのトランザクションを実行します。

.. code-block:: none

   $ pt-privilege-autogen -U postgres -d mydb start
   [2015-08-04 04:40:45] INFO: Collecting access statistics started.
   $ pgbench -c 1 -t 1 -U postgres -n mydb
   transaction type: TPC-B (sort of)
   scaling factor: 1
   query mode: simple
   number of clients: 1
   number of threads: 1
   number of transactions per client: 1
   number of transactions actually processed: 1/1
   latency average: 0.000 ms
   tps = 14.402581 (including connections establishing)
   tps = 20.464964 (excluding connections establishing)
   $

そして、アクセスポリシーのファイルを作成して、データベースに適用します。ここでは ``snaga`` ユーザに対して、4つのテーブルの最小限のアクセス権限を付与しています。

.. code-block:: none

   $ pt-privilege-autogen -U postgres -d mydb generate snaga
   
   -- Database
   REVOKE ALL ON DATABASE "mydb" FROM "public";
   GRANT CONNECT,TEMP ON DATABASE "mydb" TO "snaga";
   
   -- Schema
   REVOKE ALL ON SCHEMA "public" FROM "public";
   GRANT USAGE ON SCHEMA "public" TO "snaga";
   
   -- Table
   REVOKE ALL ON TABLE "public"."pgbench_accounts" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_branches" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_history" FROM "snaga";
   REVOKE ALL ON TABLE "public"."pgbench_tellers" FROM "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_accounts" TO "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_branches" TO "snaga";
   GRANT INSERT ON TABLE "public"."pgbench_history" TO "snaga";
   GRANT SELECT,UPDATE ON TABLE "public"."pgbench_tellers" TO "snaga";
   
   
   $ pt-privilege-autogen -U postgres -d mydb generate snaga > grant.sql
   $ psql -f grant.sql -U postgres mydb
   REVOKE
   GRANT
   REVOKE
   GRANT
   REVOKE
   REVOKE
   REVOKE
   REVOKE
   GRANT
   GRANT
   GRANT
   GRANT
   $

最後に、アクセス統計情報の収集を終了し、一般ユーザの ``snaga`` でも最小権限の付与によってpgbenchトランザクションを実行可能になったことを確認します。

.. code-block:: none

   $ pt-privilege-autogen -U postgres -d mydb stop
   [2015-08-04 04:44:21] INFO: Collecting access statistics stopped.
   $ pgbench -c 1 -t 1 -U snaga -n mydb
   transaction type: TPC-B (sort of)
   scaling factor: 1
   query mode: simple
   number of clients: 1
   number of threads: 1
   number of transactions per client: 1
   number of transactions actually processed: 1/1
   latency average: 0.000 ms
   tps = 33.598764 (including connections establishing)
   tps = 82.182774 (excluding connections establishing)
   $
