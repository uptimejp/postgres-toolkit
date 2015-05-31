
ツールキットの導入
==================


サポートOS
----------

サポートされているOSとそのバージョンは以下の通りです。

* Red Hat Enterprise Linux 6 / CentOS 6
* Red Hat Enterprise Linux 7 / CentOS 7
* Ubuntu 14.04 LTS

なお、Python2.6またはPython2.7がインストールされている必要があります。


PostgreSQLバージョン
--------------------

サポートされているPostgreSQLのバージョンは以下の通りです。

* PostgreSQL 9.0
* PostgreSQL 9.1
* PostgreSQL 9.2
* PostgreSQL 9.3
* PostgreSQL 9.4


インストール方法
----------------

以下のコマンドを実行することで、インターネット経由でインストールすることができます。

.. code-block:: none

   curl -L http://dl.uptimeforce.com/postgres-toolkit/install.sh | sh

または

.. code-block:: none

   wget http://dl.uptimeforce.com/postgres-toolkit/install.sh
   sh install.sh

を実行してください。

インストールが完了すると、 ``/opt/uptime/postgres-toolkit-<VERSION>`` 以下に関連するファイルがインストールされます。



