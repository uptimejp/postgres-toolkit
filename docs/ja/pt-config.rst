pt-config
=========

概要
----

PostgreSQLの設定ファイル ``postgresql.conf`` の設定値を参照、変更します。


実行方法
--------

.. code-block:: none

   pt-config [options...] get [PARAM]
   pt-config [options...] set [PARAM] [VALUE]
   pt-config [options...] disable [PARAM]

コマンド
--------

.. csv-table::

   ``get [PARAM]``, 現在の値を表示します。無効（コメントアウト）の場合、 ``(disabled)`` と表示されます。
   ``set [PARAM] [VALUE]``, 新しい値を設定します。無効（コメントアウト）な場合は、有効にします。
   ``disable [PARAM]``, 設定値を無効にします（コメントアウトします）。

オプション
----------

.. code-block:: none

    -D, --pgdata=PGDATA        Specify a PostgreSQL database cluster.
    --apply                    Apply change(s).
    --help                     Print this help.

``-D``, ``--pgdata`` オプションは、PostgreSQLデータベースクラスタを指定します。オプションが指定されない場合は、PGDATA環境変数に設定された値が使われます。

``--apply`` オプションは、 ``set`` / ``disable`` コマンドを実行する際に、実際に変更内容を postgresql.conf ファイルに適用します。

出力項目
--------

.. csv-table::

   ``Reading:``, 読み込んでいる ``postgresql.conf`` ファイルをフルパスで表示します。
   ``Dry-run mode:``, 設定する前後の値を表示するのみで、実際の設定変更は行いません。
   ``Applying:``, 実際の設定変更を行っています。
   ``Old``, 変更する前の値を表します。
   ``New``, 変更する前の値を表します。
   ``Updating:``, 変更を行っている ``postgresql.conf`` ファイルをフルパスで表示します。

実行例
------

現在の ``shared_buffers`` の値を表示します。

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data get shared_buffers
   [2015-04-16 17:08:12] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   256MB
   $

``shared_buffers`` の値を ``512MB`` に設定します（実際の設定ファイルの変更は行いません）。

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data set shared_buffers 512MB
   [2015-04-16 17:08:44] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:08:44] INFO: Dry-run mode:
   [2015-04-16 17:08:44] INFO:   Old: shared_buffers = 256MB                       # min 128kB
   [2015-04-16 17:08:44] INFO:   New: shared_buffers = 512MB                       # min 128kB
   $

``shared_buffers`` の値を ``512MB`` に設定します（実際に設定ファイルの変更を行います）。

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data --apply set shared_buffers 512MB
   [2015-04-16 17:09:11] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:09:11] INFO: Applying:
   [2015-04-16 17:09:11] INFO:   Old: shared_buffers = 256MB                       # min 128kB
   [2015-04-16 17:09:11] INFO:   New: shared_buffers = 512MB                       # min 128kB
   [2015-04-16 17:09:11] INFO: Updated: /var/lib/pgsql/9.4/data/postgresql.conf
   $

``shared_buffers`` の設定を無効化（コメントアウト）します。

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data --apply disable shared_buffers
   [2015-04-16 17:09:52] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:09:52] INFO: Applying:
   [2015-04-16 17:09:52] INFO:   Old: shared_buffers = 512MB                       # min 128kB
   [2015-04-16 17:09:52] INFO:   New: #shared_buffers = 512MB                      # min 128kB
   [2015-04-16 17:09:52] INFO: Updated: /var/lib/pgsql/9.4/data/postgresql.conf
   $

（無効化されている） ``shared_buffers`` の値を表示します。

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data get shared_buffers
   [2015-04-16 17:10:00] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   512MB (disabled)
   $
