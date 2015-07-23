pt-archive-xlog
===============

Summary
-------

Archive a transaction log file in safe way.

This command can be used in the ``archive_command`` parameter.

Usage
-----

.. code-block:: none

   pt-archive-xlog <XLOGFILEPATH> <DESTDIR>

Options
-------

No option.

Output Items
------------

It returns with the exit code 0 on success, or 1 on failure.

Examples
--------

Following example shows how to configure ``archive_command`` in ``postgresql.conf``.

.. code-block:: none

   archive_command = '/path/to/pt-archive-xlog %p /path/to/archivedir'
