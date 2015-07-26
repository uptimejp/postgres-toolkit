pt-archive-xlog
===============

概要
----

トランザクションログファイルを安全にアーカイブ処理します。

``archive_command`` パラメータから呼び出すコマンドとして利用します。

実行方法
--------

.. code-block:: none

   pt-archive-xlog <XLOGFILEPATH> <DESTDIR>

オプション
----------

特になし。

出力項目
--------

アーカイブ成功時には 0 を、失敗時には 1 を返却します。

実行例
------

``postgresql.conf`` の ``archive_command`` で以下のように設定します。

.. code-block:: none

   archive_command = '/path/to/pt-archive-xlog %p /path/to/archivedir'
