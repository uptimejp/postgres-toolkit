
pt-verify-checksum
==================

概要
----

指定したPostgreSQLのファイルのチェックサムを検証します。

チェックサムを有効にしてデータベースクラスタを作成している必要があります。 （``initdb`` コマンドの ``-k`` オプション）

PostgreSQL 9.3以降のバージョンが対象です。

このスクリプトは内部で ``verifychecksum`` コマンドを呼び出します。Red Hat Enterprise Linux 6/CentOS 6以外のOSで動作させる場合は、``src/verifychecksum.c`` を別途ビルドして ``bin`` ディレクトリ以下に配置する必要があります。

実行方法
--------

.. code-block:: none

   pt-verify-checksum [option...] [segment file | directory]

引数としてファイル名を指定した場合には、そのファイルのチェックサムを検証します。

引数としてディレクトリ名を指定した場合には、そのディレクトリにあるファイルのうち、以下のファイルを対象としてチェックサムを検証します。

* ``global`` または ``base`` ディレクトリ以下にあり、かつ、
* ファイル名が数字で構成されるもの（例: ``1234``、``1234.1``）、および末尾に ``_vm`` または ``_fsm`` が付与されているファイル（例: ``1234_vm``、``1234_fsm``）

チェックサム検証で1つ以上のファイルにエラーが見つかった場合には終了コード ``1`` を返します。それ以外のエラーが発生した場合には終了コード ``2`` を返します。どのファイルにも問題がなかった場合には ``0`` を返します。

オプション
----------

.. code-block:: none

  -r, --recursive
  -v, --verbose
  --help

``-r``, ``--recursive`` オプションは、ディレクトリを指定した場合に、サブディレクトリ以下を再帰的にスキャンし、該当するファイルのチェックサムを検証します。

``-v``, ``--verbose`` オプションは、チェックサム検証中により多くのメッセージを出力します。


出力項目
--------

.. csv-table::

   ``blkno``, チェックサムエラーの見つかったブロック番号
   ``expected``, ブロックのデータから計算されたチェックサム
   ``found``, ページヘッダに記録されていたチェックサム
   ``Verified N files``, チェックサムの検証をしたファイル数
   ``N files corrupted``, チェックサムのエラーの見つかったファイル数

実行例
------

単一のファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/16386/16399
   [2015-03-28 15:50:03] INFO: Verified 1 files. 0 files corrupted.
   $

データベース内のすべてのファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/16386
   [2015-03-28 15:51:00] INFO: Verified 311 files. 0 files corrupted.
   $

データベースクラスタ内を再帰的に探索し、すべてのファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum -r /var/lib/pgsql/9.4/data
   [2015-03-28 15:55:16] INFO: /var/lib/pgsql/9.4/data/base/12144/11905: blkno 7, expected 2cf, found da97
   [2015-03-28 15:55:16] INFO: 1 blocks corrupted in /var/lib/pgsql/9.4/data/base/12144/11905.
   [2015-03-28 15:55:16] INFO: Verified 1046 files. 1 files corrupted.
   $
