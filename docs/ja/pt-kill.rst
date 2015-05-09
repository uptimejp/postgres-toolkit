pt-kill
=======

概要
----

PostgreSQLバックエンドの処理を中断、またはバックエンドを終了させます。


実行方法
--------

.. code-block:: none

   pt-kill [options...] [command] [pid]


コマンド
--------

.. code-block:: none

    cancel                     Cancel a running query.
    terminate                  Terminate a backend with canceling query.

オプション
----------

.. code-block:: none

    --help                     Print this help.

出力項目
--------

特になし。

実行例
------

プロセスID 3289 で実行中のSQLをキャンセルします。

.. code-block:: none

   $ pt-kill cancel 3289


プロセスID 3291 で実行中のバックエンドを終了します。

.. code-block:: none

   $ pt-kill terminate 3291

