#!/usr/bin/env python
# coding: UTF-8

# pt-kill
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

import getopt
import os
import signal
import sys

import log


def usage():
    print '''
Usage: {0} [option...] [command] [pid]

Commands:
    cancel                     Cancel a running query.
    terminate                  Terminate a backend with canceling query.

Options:
    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "",
                                   ["help", "debug"])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    debug = False

    for o, a in opts:
        if o in ("--debug"):
            debug = True
            log.setLevel(log.DEBUG)
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(1)

    log.debug(args)

    if len(args) < 2:
        log.info("Specify signal command with pid.")
        usage()
        sys.exit(0)

    command = args[0]
    pid = args[1]

    if command == 'cancel':
        sig = signal.SIGINT
    elif command == 'terminate':
        sig = signal.SIGTERM
    else:
        log.error("Unknown command %s" % command)
        sys.exit(1)

    try:
        os.kill(int(pid), sig)
    except OSError, err:
        log.error(err)
        sys.exit(1)

    sys.exit(0)
