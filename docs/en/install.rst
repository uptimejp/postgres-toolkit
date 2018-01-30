
Install the Toolkit
===================


Supported OS
------------

For a list of Operating System supported.

* Red Hat Enterprise Linux 6 / CentOS 6
* Red Hat Enterprise Linux 7 / CentOS 7
* Ubuntu 14.04 LTS

Make sure you have Python2.6 or Python2.7 is installed.


PostgreSQL Version
------------------

For a list of PostgreSQL supported.

* PostgreSQL 9.0
* PostgreSQL 9.1
* PostgreSQL 9.2
* PostgreSQL 9.3
* PostgreSQL 9.4


Installation
------------

* Clone the git repository.
* Build the `verifychecksum` command.
* Run `pip install .` to install all commands and libraries.

.. code-block:: none

   git clone https://github.com/uptimejp/postgres-toolkit.git
   cd postgres-toolkit/
   cd src/verifychecksum/
   make
   cd ../..
   sudo pip install .
