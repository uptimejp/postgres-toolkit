
pt-set-tablespace
=================

概要
----

指定したテーブルと関連するインデックスのテーブルスペースを一括して変更します。


実行方法
--------

.. code-block:: none

   pt-set-tablespace [option...] [tablespace]

オプション
----------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -U, --username=USERNAME
  -d, --dbname=DBNAME
  -o, --owner=STRING
  -n, --schema=STRING
  -t, --table=STRING
  -l, --list
  --apply
  --help

``-h``, ``--host`` オプションは、接続するPostgreSQLデータベースのサーバ名またはIPアドレスを指定します。オプションが指定されない場合は、PGHOST環境変数に設定された値が使われます。PGHOST環境変数が設定されていない場合には、デフォルトの値として ``localhost`` が使われます。

``-p``, ``--port`` オプションは、接続するPostgreSQLデータベースのポート番号を指定します。オプションが指定されない場合は、PGPORT環境変数に設定された値が使われます。PGPORT環境変数が設定されていない場合には、デフォルトの値として ``5432`` が使われます。

``-U``, ``--username`` オプションは、PostgreSQLデータベースに接続するユーザ名を指定します。オプションが指定されない場合は、PGUSER環境変数に設定された値が使われます。PGUSER環境変数が設定されていない場合には、USER環境変数に設定された値が使われます。

``-d``, ``--dbname`` オプションは、接続するデータベース名を指定します。オプションが指定されない場合は、PGDATABASE環境変数に設定された値が使われます。PGDATABASE環境変数が設定されていない場合には、データベースに接続するユーザ名と同じ名前のデータベースに接続します。

``-o``, ``--owner`` オプションは、指定した文字列に合致する名前のユーザが所有者となっているテーブルのみを対象とします。スラッシュで挟むことで正規表現を指定することもできます（例: ``/REGEXP/`` ）。

``-n``, ``--schema`` オプションは、指定した文字列に合致する名前のスキーマにあるテーブルのみを対象とします。スラッシュで挟むことで正規表現を指定することもできます（例: ``/REGEXP/`` ）。

``-t``, ``--table`` オプションは、指定した文字列に合致する名前のテーブルのみを対象とします。スラッシュで挟むことで正規表現を指定することもできます（例: ``/REGEXP/`` ）。

``--apply`` オプションは、テーブルスペースの変更を実際にデータベースに反映します。

``-l``, ``--list`` オプションは、テーブルスペースの情報を表示します。

``-o`` （または ``--owner`` ）,  ``-n`` （または ``--schema`` ）, ``-t`` （または ``--table`` ） を同時に指定した場合には、すべての条件に合致するテーブルのみが対象となります。

1つ以上のテーブルの移動に失敗した場合には終了コード ``1`` を返します。すべてのファイルの移動に成功した場合には ``0`` を返します。

出力項目
--------

``-l``, ``--list`` オプションで表示される項目は以下の通りです。

.. csv-table::

   ``OID``, テーブルスペースのオブジェクトID
   ``OWNER``, テーブルスペースの所有者のユーザ名
   ``TABLESPACE``, テーブルスペース名
   ``LOCATION``, テーブルスペースの配置されているディレクトリのパス
   ``USE%``, テーブルスペースの配置されているパーティションのディスク使用率
   ``AVAIL``, テーブルスペースの配置されているパーティションの空き容量

その他の表示項目は以下の通りです。

.. csv-table::

   ``Dry-run mode``, 発行するALTER TABLE/INDEX文を表示しますが、実際の移動は行いません。
   ``Applying ALTER TABLE/INDEX``, ALTER TABLE/INDEX文を実際に実行して、テーブル/インデックスのテーブルスペースを変更します。
   ``X tables/indexes moved. Y failed.``, ``X`` 個のテーブル/インデックスを移動に成功し、 ``Y`` 個の移動に失敗しました。


実行例
------

PostgreSQLインスタンスに存在するテーブルスペースの一覧を表示します。 各パーティションの使用領域を取得し、併せて一覧として表示します。

.. code-block:: none

   $ pt-set-tablespace --list
   +--------+----------+------------+---------------------------+------+-------+
   |  OID   |  OWNER   | TABLESPACE |          LOCATION         | USE% | AVAIL |
   +--------+----------+------------+---------------------------+------+-------+
   |   1663 | postgres | pg_default |                           |      |       |
   |   1664 | postgres | pg_global  |                           |      |       |
   | 121263 | postgres | hddspc2    | /disk/disk2/pgsql         | 85%  | 80G   |
   |  16818 | postgres | ssdspc1    | /disk/disk1/tblspc1       | 67%  | 127G  |
   | 305242 | postgres | ssdspc2    | /disk/disk3/pgsql/ssdspc2 | 98%  | 13G   |
   +--------+----------+------------+---------------------------+------+-------+
   $

``dbt3`` データベースにある ``orders`` テーブル、および ``orders`` テーブルに作成されたインデックスのすべてを、 ``ssdspc1`` テーブルスペースに移動するための ``ALTER TABLE`` 文および ``ALTER INDEX`` 文を表示します。（実際の移動は行いません）

.. code-block:: none

   $ pt-set-tablespace -d dbt3 --table orders ssdspc1
   [2015-04-29 17:35:24] INFO: Dry-run mode:
   [2015-04-29 17:35:24] INFO: ALTER TABLE "public"."orders" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."pk_orders" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."i_o_orderdate" SET TABLESPACE "ssdspc1";
   [2015-04-29 17:35:24] INFO: ALTER INDEX "public"."i_o_custkey" SET TABLESPACE "ssdspc1";
   $

``dbt3`` データベースにある ``orders`` テーブル、および ``orders`` テーブルに作成されたインデックスのすべてを、 ``ssdspc1`` テーブルスペースに移動します。

.. code-block:: none

   $ pt-set-tablespace -d dbt3 --table orders --apply ssdspc1
   [2015-04-29 17:37:06] INFO: Applying ALTER TABLE/INDEX...
   [2015-04-29 17:37:08] INFO: 4 tables/indexes moved. 0 failed.
   $

``dbt3`` スキーマ内にあるすべてのテーブル、およびすべてのインデックスを、 ``ssdspc1`` テーブルスペースに移動します。

.. code-block:: none

   $ pt-set-tablespace --schema dbt3 --apply ssdspc1
   [2015-04-29 17:38:39] INFO: Applying ALTER TABLE/INDEX...
   [2015-04-29 17:38:57] INFO: 31 tables/indexes moved. 0 failed.
   $
