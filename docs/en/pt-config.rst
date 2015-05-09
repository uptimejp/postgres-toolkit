pt-config
=========

Summary
-------

Refer the setting of the PosgreSQL configuration file ``postgresql.conf``, and then modify it.


Usage
-----

.. code-block:: none

   pt-config [options...] get [PARAM]
   pt-config [options...] set [PARAM] [VALUE]
   pt-config [options...] disable [PARAM]

Commands
--------

.. csv-table::

   ``get [PARAM]``, Displays the current value. If it is disabled(comment-out). ``(disabled)`` is displayed.
   ``set [PARAM] [VALUE]``, Sets the new value. The value will be enabled if it is disabled (comment-out).
   ``disable [PARAM]``, Disable the setting value.(comment-out)

Options
-------

.. code-block:: none

    -D, --pgdata=PGDATA        Specify a PostgreSQL database cluster.
    --apply                    Apply change(s).
    --help                     Print this help.

``-D``, ``--pgdata`` Specifies the PostgreSQL database cluster. If not specified, to set the value of PGDATA.

``--apply`` It will actually apply the changes to the postgresql.conf when it runs ``set`` / ``disable`` command.


Output Items
------------

.. csv-table::

   ``Reading:``, Loading the ``postgresql.conf`` file displays in the full path.
   ``Dry-run mode:``, The before and after values is only displayed. It does not provide the actual configuration changes.
   ``Applying:``, Doing the actual configuration changes.
   ``Old``, Displays the value of before change.
   ``New``, Displays the value of after change.
   ``Updating:``, Modifying the ``postgresql.conf`` file displays in the full path.


Examples
--------

Displays the current value of ``shared_buffers``

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data get shared_buffers
   [2015-04-16 17:08:12] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   256MB
   $

Sets the value ``512MB`` of ``shared_buffers``. (Does not do the actual configuration changes)

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data set shared_buffers 512MB
   [2015-04-16 17:08:44] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:08:44] INFO: Dry-run mode:
   [2015-04-16 17:08:44] INFO:   Old: shared_buffers = 256MB                       # min 128kB
   [2015-04-16 17:08:44] INFO:   New: shared_buffers = 512MB                       # min 128kB
   $

Sets the value ``512MB`` of ``shared_buffers``. (Doing the actual configuration change)

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data --apply set shared_buffers 512MB
   [2015-04-16 17:09:11] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:09:11] INFO: Applying:
   [2015-04-16 17:09:11] INFO:   Old: shared_buffers = 256MB                       # min 128kB
   [2015-04-16 17:09:11] INFO:   New: shared_buffers = 512MB                       # min 128kB
   [2015-04-16 17:09:11] INFO: Updated: /var/lib/pgsql/9.4/data/postgresql.conf
   $

Sets the disable(comment-out) of ``shared_buffers``. 

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data --apply disable shared_buffers
   [2015-04-16 17:09:52] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   [2015-04-16 17:09:52] INFO: Applying:
   [2015-04-16 17:09:52] INFO:   Old: shared_buffers = 512MB                       # min 128kB
   [2015-04-16 17:09:52] INFO:   New: #shared_buffers = 512MB                      # min 128kB
   [2015-04-16 17:09:52] INFO: Updated: /var/lib/pgsql/9.4/data/postgresql.conf
   $

Displays the value of ``shared_buffers`` (Disabled).

.. code-block:: none

   $ pt-config -D /var/lib/pgsql/9.4/data get shared_buffers
   [2015-04-16 17:10:00] INFO: Reading: /var/lib/pgsql/9.4/data/postgresql.conf
   512MB (disabled)
   $
