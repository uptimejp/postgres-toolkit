#!/usr/bin/env python
# coding: UTF-8

# pt-verify-checksum
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

from stat import *
import getopt
import os
import re
import subprocess
import sys

import DirectoryTree
import log


class VerifyChecksum():
    filelist = []
    verifychecksum_bin = None

    def __init__(self, path, recursive=False, verbose=False, debug=False):
        self.verifychecksum_bin = os.path.abspath(
            os.path.dirname(sys.argv[0]) + "/../bin/verifychecksum.bin")

        self.path = path
        self.recursive = recursive
        self.verbose = verbose

        log.debug("VerifyChecksum")
        log.debug("  path = %s" % (self.path))
        log.debug("  recursive = %s" % str(self.recursive))

    def get_fileinfo(self, filepath):
        # Excluding files not in 'base' and 'global' directories.
        if (not re.search('/base/', filepath) and
            not re.search('/global/', filepath)):
            return None

        # NNNNNNNN
        if re.search('/\/?\d+$', filepath):
            return (filepath, 0)
        # NNNNNNNN.N
        elif re.search('/\/?\d+\.(\d+)$', filepath):
            m = re.search('/\/?\d+\.(\d+)$', filepath)
            return (filepath, int(m.groups(0)[0]))
        # NNNNNNNN_fsm
        elif re.search('/\d+_fsm$', filepath):
            return (filepath, 0)
        # NNNNNNNN_vm
        elif re.search('/\d+_vm$', filepath):
            return (filepath, 0)

        return None

    def verify_one(self, path, segno):
        opt = ""
        if self.verbose is True:
            opt = "-v"

        cmd = "{0} {1} {2} {3}".format(self.verifychecksum_bin,
                                       opt, path, segno)

        log.debug("popen: %s" % cmd)

        p = subprocess.Popen([cmd], stdin=subprocess.PIPE,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, shell=True)
        p.wait()

        log.debug("verify_one: return code %d" % p.returncode)

        o = p.stdout.readlines()
        e = p.stderr.readlines()

        # corrupted file(s) found.
        if p.returncode == 1:
            # messages must come through stdout.
            for l in o:
                log.info(l.replace('\n', ''))
            return 0

        # other error
        elif p.returncode >= 2:
            for l in e:
                log.error(l.replace('\n', ''))
            return 2

        if len(o) > 0:
            log.info(o[0].replace('\n', ''))

        return 1

    def verify(self):
        count = 0
        corrupted = 0
        error = 0
        skipped = 0

        d = DirectoryTree.DirectoryTree(self.path, self.recursive)
        try:
            filelist = d.get_file_list()
        except OSError, err:
            log.error(err)
            sys.exit(2)

        for f in filelist:
            fileinfo = self.get_fileinfo(f)
            if fileinfo:
                count = count + 1
                log.debug("verifing %s" % f)
                rc = self.verify_one(fileinfo[0], fileinfo[1])
                if rc == 0:
                    corrupted = corrupted + 1
                elif rc == 2:
                    error = error + 1
            else:
                if self.verbose:
                    log.info("Skipped %s" % f)
                skipped = skipped + 1

        log.info(("%d verified (%d valid, %d corrupted, %d disabled/error). "
                  "%d skipped.") %
                 (count, count - error - corrupted, corrupted, error, skipped))

        if corrupted == 0:
            return True

        return False


def usage():
    print '''
Usage: {0} [option...] [file]
       {0} [option...] [directory]

Options:
    -r, --recursive            Find files recursively.
    -v, --verbose              Enable verbose output.

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "rv",
                                   ["help", "debug", "recursive", "verbose"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    recursive = False
    verbose = False
    debug = None

    for o, a in opts:
        if o in ("-r", "--recursive"):
            recursive = True
        elif o in ("-v", "--verbose"):
            verbose = True
        elif o in ("--debug"):
            log.setLevel(log.DEBUG)
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(2)

    if len(args) == 0:
        usage()
        sys.exit(0)

    log.debug("recursive = %s" % str(recursive))
    log.debug("verbose   = %s" % str(verbose))

    v = VerifyChecksum(args[0], recursive=recursive, verbose=verbose,
                       debug=debug)

    if v.verify() is False:
        sys.exit(1)

    sys.exit(0)
