#!/usr/bin/env python
# coding: UTF-8

# DirectoryTree
#
# Copyright(c) 2015 Uptime Technologies, LLC.

import os
from stat import *

import log

class DirectoryTree():
    path = None
    filelist = []

    def __init__(self, path, recursive=False, debug=False):
        self.path      = path
        self.recursive = recursive
        self.filelist  = []

        if debug is True:
            log.setLevel(log.DEBUG)

        log.debug("path: %s" % (self.path))
        log.debug("recursive: %s" % (str(self.recursive)))

    def get_file_list(self):
        mode = os.stat(self.path)[ST_MODE]

        if S_ISDIR(mode):
            log.debug("%s is directory." % self.path)
            if self.recursive is True:
                log.debug("    going to recursive")
                self.walktree(self.path, self.visitfile)
            else:
                for f in os.listdir(self.path):
                    log.debug("  found %s" % f)
                    pathname = os.path.join(self.path, f)
                    mode = os.stat(pathname)[ST_MODE]

                    # found a regular file.
                    if S_ISREG(mode):
                        log.debug("    %s is a regular file" % f)
                        self.visitfile(pathname, f)

        elif S_ISREG(mode):
            self.filelist.append(self.path)

        return self.filelist

    def walktree(self, directory, callback):
        log.debug("walktree: %s" % directory)
        for f in os.listdir(directory):
            pathname = os.path.join(directory, f)
            mode = os.stat(pathname)[ST_MODE]
            if S_ISDIR(mode):
                self.walktree(pathname, callback)
            elif S_ISREG(mode):
                callback(pathname, f)

    def visitfile(self, filepath, filename):
        # filepath must be a regular file.
        log.debug("append %s to the list" % filepath)
        self.filelist.append(filepath)

        # Is the file in 'base' or 'global' directories?
#        if re.search('/base/', filepath) is None and re.search('/global/', filepath) is None:
#            return
#
#        if re.search('^\d+$', filename) is not None:
#            self.filelist.append(filepath)
#        elif re.search('^\d+\.\d+$', filename) is not None:
#            self.filelist.append(filepath)
#        elif re.search('^\d+_fsm$', filename) is not None:
#            self.filelist.append(filepath)
#        elif re.search('^\d+_vm$', filename) is not None:
#            self.filelist.append(filepath)
