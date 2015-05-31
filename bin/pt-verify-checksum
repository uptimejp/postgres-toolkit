#!/usr/bin/env python
# coding: UTF-8

# pt-verify-checksum
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import sys, os
libpath = os.path.abspath(os.path.dirname(sys.argv[0]) + "/../lib")
sys.path.append(libpath)

import getopt
import log
import re
import subprocess
from stat import *

import DirectoryTree

class VerifyChecksum():
    filelist = []
    verifychecksum_bin = None

    def __init__(self, path, recursive=False, verbose=False, debug=False):
        self.verifychecksum_bin = os.path.abspath(os.path.dirname(sys.argv[0]) + "/../bin/verifychecksum.bin")

        self.path      = path
        self.recursive = recursive
        self.verbose   = verbose

        log.debug("VerifyChecksum")
        log.debug("  path = %s" % (self.path))
        log.debug("  recursive = %s" % str(self.recursive))


    def check_filename(self, filepath):
        # Excluding files not in 'base' and 'global' directories.
        if re.search('/base/', filepath) is None and re.search('/global/', filepath) is None:
            return False

        # NNNNNNNN
        if re.search('/\d+$', filepath) is not None:
            return True
        # NNNNNNNN.N
        elif re.search('/\d+\.\d+$', filepath) is not None:
            return True
        # NNNNNNNN_fsm
        elif re.search('/\d+_fsm$', filepath) is not None:
            return True
        # NNNNNNNN_vm
        elif re.search('/\d+_vm$', filepath) is not None:
            return True

        return False

    def verify_one(self, path):
        opt = ""
        if self.verbose is True:
            opt = "-v"

        cmd = self.verifychecksum_bin + " " + opt + " " + path

        log.debug("popen: %s" % cmd)

        p = subprocess.Popen([cmd], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
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
            return False

        # other error
        elif p.returncode >= 2:
            for l in e:
                log.error(l.replace('\n', ''))
            return False

        if len(o) > 0:
            log.info(o[0].replace('\n', ''))

        return True

    def verify(self):
        count     = 0
        corrupted = 0

        d = DirectoryTree.DirectoryTree(self.path, self.recursive)
        try:
            filelist = d.get_file_list()
        except OSError, err:
            log.error(err)
            sys.exit(2)

        for f in filelist:
            if self.check_filename(f) is True:
                log.debug("verifing %s" % f)
                if self.verify_one(f) is False:
                    corrupted = corrupted + 1
            
            count = count + 1

        log.info("Verified %d files. %d files corrupted." % (count, corrupted))

        if corrupted == 0:
            return True

        return False

def usage():
    print ""
    print "Usage: " + os.path.basename(sys.argv[0]) + " [option...] [file]"
    print "       " + os.path.basename(sys.argv[0]) + " [option...] [directory]"
    print ""
    print "Options:"
    print "    -r, --recursive            Find files recursively."
    print "    -v, --verbose              Enable verbose output."
    print ""
    print "    --help                     Print this help."
    print ""

if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "rv",
                                   ["help", "debug", "recursive", "verbose"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    recursive = False
    verbose   = False
    debug     = None

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

    v = VerifyChecksum(args[0], recursive=recursive, verbose=verbose, debug=debug)

    if v.verify() is False:
        sys.exit(1)

    sys.exit(0)
