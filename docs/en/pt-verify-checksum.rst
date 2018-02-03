
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
   ``page header``, Checksum which had been recorded in the page header
   ``calculated``, Checksum calculated from the data of the block
   ``N verified``, Number of files that the checksum verification
   ``N valid``, Number of files that the checksums are correct.
   ``N corrupted``, Number of files that found the checksum error
   ``N disabled/error``, Number of files that those checksums could not be examined
   ``N skipped``, Number of files that ware not verified

Examples
--------

Verifies the checksum of single file.

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.4/data/base/1/12772
   [2018-02-01 23:00:11] INFO: 1 verified (1 valid, 0 corrupted, 0 disabled/errors). 0 skipped.
   $

Verifies the checksum of all of files in the database.

.. code-block:: none

   $ pt-verify-checksum /var/lib/pgsql/9.6/data/base/1
   [2018-02-01 22:59:46] INFO: 234 verified (234 valid, 0 corrupted, 0 disabled/errors). 3 skipped.
   $

It recursively searched in the database cluster, and to verify the checksum of all of files.

.. code-block:: none

   $ pt-verify-checksum -r /var/lib/pgsql/9.6/data
   [2018-02-01 22:58:02] INFO: /var/lib/pgsql/9.6/data/base/1/2662: blkno 0, page header 2bf8, calculated e945
   [2018-02-01 22:58:02] INFO: 1 blocks corrupted in /var/lib/pgsql/9.6/data/base/1/2662.
   [2018-02-01 22:58:06] INFO: 739 verified (738 valid, 1 corrupted, 0 disabled/errors). 21 skipped.
   $
