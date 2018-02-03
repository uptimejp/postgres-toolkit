
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
   ``page header``, ページヘッダに記録されていたチェックサム
   ``calculated``, ブロックのデータから計算されたチェックサム
   ``N verified``, チェックサムの検証をしたファイル数
   ``N valid``, チェックサムが正しかったファイル数
   ``N corrupted``, チェックサムのエラーの見つかったファイル数
   ``N disabled/error``, チェックサムが無効、またはI/Oエラーなどになったファイル数
   ``N skipped``, チェックサムの検証をしなかったファイル数

実行例
------

単一のファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/1/12772
   [2018-02-01 23:00:11] INFO: 1 verified (1 valid, 0 corrupted, 0 disabled/errors). 0 skipped.
   $

データベース内のすべてのファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.6/data/base/1
   [2018-02-01 22:59:46] INFO: 234 verified (234 valid, 0 corrupted, 0 disabled/errors). 3 skipped.
   $

データベースクラスタ内を再帰的に探索し、すべてのファイルのチェックサムを検証します。

.. code-block:: none

   $ pt-verify-checksum -r /var/lib/pgsql/9.6/data
   [2018-02-01 22:58:02] INFO: /var/lib/pgsql/9.6/data/base/1/2662: blkno 0, page header 2bf8, calculated e945
   [2018-02-01 22:58:02] INFO: 1 blocks corrupted in /var/lib/pgsql/9.6/data/base/1/2662.
   [2018-02-01 22:58:06] INFO: 739 verified (738 valid, 1 corrupted, 0 disabled/errors). 21 skipped.
   $
