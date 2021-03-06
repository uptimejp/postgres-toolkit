#!/usr/bin/env python
# coding: UTF-8

# pt-session-profiler
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.

from datetime import datetime, timedelta, date, time
import copy
import getopt
import os
import re
import subprocess
import sys

import TcpdumpWrapper
import log


class SessionProfiler:
    def __init__(self, host=None, port=None, interface=None, inputfile=None,
                 threshold=1000, debug=None):
        self.host = host
        self.port = port
        self.interface = interface
        self.inputfile = inputfile
        self.threshold = threshold
        self.debug = debug

        self.query_starttime = {}
        self.query_endtime = {}
        self.query_string = {}

        log.info("Threshold: %d ms" % self.threshold)

    def run(self):
        dump = TcpdumpWrapper.TcpdumpWrapper(host=self.host, port=self.port,
                                             interface=self.interface,
                                             inputfile=self.inputfile,
                                             debug=self.debug)

        bindname_to_query = {}
        session_to_bindname = {}

        cont = True
        while cont:
            try:
                pkt = dump.get_packet()
            except KeyboardInterrupt, err:
                pkt = dump.get_last_packet()
                cont = False

            if pkt is None:
                break

            # messages available?
            log.debug("SessionProfiler#run: %s" % pkt.session_id)
            log.debug("SessionProfiler#run: %s" % str(pkt.ts))

            for m in pkt.get_messages():
                log.debug("SessionProfiler#run: %c, %s" % (m[0], m[1]))

                if m[0] == 'Q':
                    self.query_start(pkt.session_id, m[1], pkt.ts)

                elif m[0] == 'P':
                    bindname_to_query[m[1]] = m[2]
                    log.debug("[prep] name:%s, query:%s" % (m[1], m[2]))

                elif m[0] == 'B':
                    session_to_bindname[pkt.session_id] = m[2]
                    log.debug("[bind] name:%s" % (m[2]))

                elif m[0] == 'E':
                    if pkt.session_id not in session_to_bindname:
                        continue
                    prep_name = session_to_bindname[pkt.session_id]

                    if prep_name not in bindname_to_query:
                        continue

                    log.debug("[exec] name:%s, query:%s" %
                              (prep_name, bindname_to_query[prep_name]))
                    self.query_start(pkt.session_id,
                                     bindname_to_query[prep_name],
                                     pkt.ts)

                elif m[0] == 'C':
                    self.query_end(pkt.session_id, pkt.ts)

                    if self.over_threshold(pkt.session_id, self.threshold):
                        q = ""

                        if pkt.session_id in session_to_bindname:
                            bindname = session_to_bindname[pkt.session_id]
                            q = bindname_to_query[bindname]
                        else:
                            q = self.get_query_string(pkt.session_id)

                        log.info("sess:%s, time:%s, query:%s" %
                                 (pkt.session_id,
                                  self.elapsed_time(pkt.session_id), q))

        if cont is False:
            log.info("Terminated.")
            sys.exit(0)

    def over_threshold(self, session_id, threshold):
        if session_id not in self.query_starttime:
            log.warning("Session Id %s not found in the start timer." %
                        session_id)
            return None
        if session_id not in self.query_endtime:
            log.warning("Session Id %s not found in the end timer." %
                        session_id)
            return None

        return ((self.query_starttime[session_id] +
                 timedelta(microseconds=threshold*1000)) <
                self.query_endtime[session_id])

    def query_start(self, session_id, query, timestamp):
        log.debug("query_start: %s" % session_id)

        # clean up previous session info.
        if session_id in self.query_starttime:
            del self.query_starttime[session_id]
        if session_id in self.query_endtime:
            del self.query_endtime[session_id]
        if session_id in self.query_string:
            del self.query_string[session_id]

        self.query_string[session_id] = query
        self.query_starttime[session_id] = timestamp

    def query_end(self, session_id, timestamp):
        log.debug("query_end: %s" % session_id)
        self.query_endtime[session_id] = timestamp

    def elapsed_time(self, session_id):
        if session_id not in self.query_starttime is False:
            log.warning("Session Id %s not found in the start timer." %
                        session_id)
            return None
        if session_id not in self.query_endtime:
            log.warning("Session Id %s not found in the end timer." %
                        session_id)
            return None

        t = self.query_endtime[session_id] - self.query_starttime[session_id]
        return t

    def get_query_string(self, session_id):
        if session_id in self.query_string:
            return self.query_string[session_id]
        else:
            return None


def usage():
    print '''
Usage: {0} [option...]

Options:
    -h, --host=HOSTNAME        Host name of the postgres server
    -p, --port=PORT            Port number of the postgres server
    -i STRING                  Interface name to listen
    -T, --threshold=NUMBER     Threshold of query elapsed time (in millisecond)

    --help                     Print this help.
'''.format(os.path.basename(sys.argv[0]))


def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], "h:p:i:r:T:",
                                   ["help", "debug", "host=", "port=",
                                    "threshold="])
    except getopt.GetoptError, err:
        print str(err)
        usage()
        sys.exit(2)

    host = None
    port = '5432'
    interface = 'any'
    inputfile = None
    threshold = 1000
    debug = None

    for o, a in opts:
        if o in ("-h", "--host"):
            host = a
        elif o in ("-p", "--port"):
            port = int(a)
        elif o in ("-i"):
            interface = a
        elif o in ("-r"):
            inputfile = a
        elif o in ("-T", "--threshold"):
            threshold = int(a)
        elif o in ("--debug"):
            debug = True
            log.setLevel(log.DEBUG)
        elif o in ("--help"):
            usage()
            sys.exit(0)
        else:
            print "unknown option: " + o + "," + a
            sys.exit(1)

    p = SessionProfiler(host=host, port=port, interface=interface,
                        threshold=threshold, inputfile=inputfile,
                        debug=debug)
    p.run()

    sys.exit(0)
