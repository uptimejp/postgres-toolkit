
pt-verify-checksum
==================

Summary
-------

Verifies the checksum of the specified PostgreSQL file

Make sure to have created a database cluster that enable the checksum. (``-k`` option of ``initdb`` command )

Version PosgreSQL 9.3 or higher

The script invoke ``verifychecksum`` command inside. If it run on other OS than  Hat Enterprise Linux 6/CentOS 6, you must separately build to  ``src/verifychecksum.c`` to be located in the following ``bin`` directory.

Usage
-----

.. code-block:: none

   pt-verify-checksum [option...] [segment file | directory]

If specified the file name as an argument, verify the checksum.

If specified a directory name as an argument, of the files in that directory, to verify the checksum as the subject of the following files.

* The files found in the ``global`` and ``base`` directories, and
* The file name is composed of a  number (ex. ``1234``,``1234.1``) , and it contained that ``_vm`` or ``_fsm`` are appended at the end of files.

If errors were found in one or more files in the checksum verification, return exit code ``1``.
If any other error occured, return exit code ``2``.
If there are no problems in any files, return ``0``.

Options
----------

.. code-block:: none

  -r, --recursive
  -v, --verbose
  --help

`-r``, ``--recursive`` If it options specified directory, recursively scan the sub-directory below, to verify the checksum of the applicable file.

``-v``, ``--verbose`` During the checksum verification, it will show output the more messages.

Output Items
------------

.. csv-table::

   ``blkno``, Block number that found the checksum error
   ``expected``, Checksum calculated from the data of the block
   ``found``, Checksum which had been recorded in the page header
   ``Verified N files``, Number of files that the checksum verification
   ``N files corrupted``, Number of files that found the checksum error

Examples
--------

Verifies the checksum of single file.

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/16386/16399
   [2015-03-28 15:50:03] INFO: Verified 1 files. 0 files corrupted.
   $

Verifies the checksum of all of files in the database.

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/16386
   [2015-03-28 15:51:00] INFO: Verified 311 files. 0 files corrupted.
   $

It recursively searched in the database cluster, and to verify the checksum of all of files.

.. code-block:: none

   $ pt-verify-checksum -r /var/lib/pgsql/9.4/data
   [2015-03-28 15:55:16] INFO: /var/lib/pgsql/9.4/data/base/12144/11905: blkno 7, expected 2cf, found da97
   [2015-03-28 15:55:16] INFO: 1 blocks corrupted in /var/lib/pgsql/9.4/data/base/12144/11905.
   [2015-03-28 15:55:16] INFO: Verified 1046 files. 1 files corrupted.
   $
