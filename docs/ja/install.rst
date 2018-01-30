
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

* Gitレポジトリをクローンします。
* `verifychecksum` コマンドをビルドします。
* `pip install .` を実行してすべてのコマンドとライブラリをインストールします。

.. code-block:: none

   git clone https://github.com/uptimejp/postgres-toolkit.git
   cd postgres-toolkit/
   cd src/verifychecksum/
   make
   cd ../..
   sudo pip install .
