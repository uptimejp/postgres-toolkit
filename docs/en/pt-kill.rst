pt-kill
=======

Summary
-------

Interrupting the processing of PostgreSQL backend, or to exit it.


Usage
-----

.. code-block:: none

   pt-kill [options...] [command] [pid]


Commands
--------

.. code-block:: none

    cancel                     Cancel a running query.
    terminate                  Terminate a backend with canceling query.

Options
-------

.. code-block:: none

    --help                     Print this help.

Output Items
------------

None.


Examples
--------

Cancel the SQL running in the process ID 3289.

.. code-block:: none

   $ pt-kill cancel 3289


Exit the backend in the process ID 3219.

.. code-block:: none

   $ pt-kill terminate 3291

