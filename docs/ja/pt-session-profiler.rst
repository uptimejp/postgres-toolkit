
pt-session-profiler
===================

概要
----

ネットワークトラフィックをキャプチャし、PostgreSQLのセッションを検出してクエリおよびパフォーマンス情報を表示します。

tcpdumpを実行するため、 ``root`` 権限が必要です。


実行方法
--------

.. code-block:: none

   pt-session-profiler [option...]

オプション
----------

.. code-block:: none

  -h, --host=HOSTNAME
  -p, --port=PORT
  -i [INTERFACE]
  -T, --threshold=MILLISECONDS
  --help

``-h``, ``--host`` オプションは、解析するPostgreSQLセッションのPostgreSQLサーバのサーバ名またはIPアドレスを指定します。オプションが指定されない場合は、PGHOST環境変数に設定された値が使われます。PGHOST環境変数が設定されていない場合には、すべてのサーバ名またはIPアドレスのパケットを解析対象とします。

``-p``, ``--port`` オプションは、解析するPostgreSQLセッションのポート番号を指定します。オプションが指定されない場合は、PGPORT環境変数に設定された値が使われます。PGPORT環境変数が設定されていない場合には、デフォルトの値として ``5432`` が使われます。

``-i`` オプションは、キャプチャするネットワークインターフェースを指定します。省略した場合にはすべてのネットワークインターフェース（``any``）が対象となります。

``-T``, ``--threshold`` オプションは、表示するクエリの実行時間の閾値を指定します。単位はミリ秒です。デフォルトは ``1000`` です。


出力項目
--------

.. csv-table::

   ``sess``, セッションを表す一意な文字列（セッションごとに異なる値。送信元のIPアドレスとポート番号、および宛先のIPアドレスとポート番号を、MD5でハッシュ化した文字列の先頭12文字を使用）
   ``time``, クエリの実行時間
   ``query``, 実行したクエリ文字列

実行例
------

すべてのネットワークインターフェースを通過するTCPパケットのうち、ポート 5432 宛のものを監視して、実行に500ミリ秒以上かかったクエリを表示します。CTRL-Cで終了します。

.. code-block:: none

   $ sudo pt-session-profiler -T 500
   [2015-03-29 15:07:22] INFO: Threshold: 500 ms
   [2015-03-29 15:07:22] INFO: tcpdump -l -i any -s 0 -X -p tcp port 5432
   [2015-03-29 15:07:36] INFO: sess:e27f20dae08f, time:0:00:00.557728, query:UPDATE pgbench_tellers SET tbalance = tbalance + 2084 WHERE tid = 23;
   [2015-03-29 15:07:36] INFO: sess:b3674d7bbea0, time:0:00:00.980950, query:INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (32, 5, 255511, 2695, CURRENT_TIMESTAMP);
   [2015-03-29 15:07:45] INFO: sess:1c32286cab7a, time:0:00:01.115904, query:SELECT abalance FROM pgbench_accounts WHERE aid = 161999;
   [2015-03-29 15:07:45] INFO: sess:33f8c268624c, time:0:00:00.526850, query:UPDATE pgbench_accounts SET abalance = abalance + 3877 WHERE aid = 326415;
   [2015-03-29 15:07:46] INFO: sess:b370afd07dcf, time:0:00:00.719780, query:SELECT abalance FROM pgbench_accounts WHERE aid = 852680;
   [2015-03-29 15:07:46] INFO: sess:0f04724051ad, time:0:00:00.543609, query:BEGIN;
   ^C[2015-03-29 15:07:51] INFO: Terminated.
   $
