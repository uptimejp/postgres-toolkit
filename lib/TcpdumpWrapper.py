#!/usr/bin/env python
# coding: UTF-8

# TcpdumpWrapper
#
# Copyright(c) 2015 Uptime Technologies, LLC.

from datetime import datetime, timedelta, date, time
import hashlib
import os
import re
import subprocess
import sys

import log

class TcpdumpPacket:
    def __init__(self, ts, src, dst, bytes, debug=None):
        self.ts    = self.string2timestamp(ts)
        self.src   = src
        self.dst   = dst
        self.debug = debug

        self.bytes = bytes

        self.messages = []

        log.debug("+ " + ts + " " + src + " " + dst)

        self.end()

        self.session_id = self.get_session_id()

    def string2timestamp(self, ts):
        t = datetime.strptime(ts, '%Y-%m-%d %H:%M:%S.%f')
        log.debug("ts = " + str(t))
        return t

    def get_session_id(self):
        src_dst = [ self.iph_src + ":" + str(self.tcph_src), self.iph_dst + ":" + str(self.tcph_dst) ]
        ss = ""
        for s in sorted(src_dst):
            ss = ss + s + " "

        return hashlib.md5(ss).hexdigest()[0:12]

    def get_timestamp(self):
        log.debug("get_timestamp: %s" % str(self.ts))
        return self.ts

    def get_messages(self):
        return self.messages

    def parse_ip_header(self, data):
        self.iph_version    = (data[0] >> 4) & 0b1111
        self.iph_header_len = data[0] & 0b1111
        self.iph_tos        = data[1]
        self.iph_dgram_len  = (data[2] <<8) + data[3]
        self.iph_id         = (data[4] <<8) + data[5]
        self.iph_dst        = "%d.%d.%d.%d" % (data[12], data[13], data[14], data[15])
        self.iph_src        = "%d.%d.%d.%d" % (data[16], data[17], data[18], data[19])
        
        if self.debug is True:
            print("version  : %d" % self.iph_version)
            print("hd len   : %d (%d)" % (self.iph_header_len, self.iph_header_len * 4))
            print("tos      : %d" % self.iph_tos)
            print("dgram len: %d" % self.iph_dgram_len)
            print("data  len: %d" % (self.iph_dgram_len - self.iph_header_len*4))
            print("id       : %d" % self.iph_id)
            print("dst      : %s" % (self.iph_dst))
            print("src      : %s" % (self.iph_src))

        return self.iph_header_len * 4

    def parse_tcp_header(self, data):
        self.tcph_src       = (data[0] << 8) + data[1]
        self.tcph_dst       = (data[2] << 8) + data[3]
        self.tcph_seq       = (data[4] << 24) + (data[5] << 16) + (data[6] << 8) + data[7]
        self.tcph_offset    = (data[12] >> 4) & 0b1111

        if self.debug is True:
            print("src port : %d" % (self.tcph_src))
            print("dst port : %d" % (self.tcph_dst))
            print("seq      : %d" % (self.tcph_seq))
            print("offset   : %d (%d)" % (self.tcph_offset, self.tcph_offset * 4))

        return self.tcph_offset * 4

    def end(self):
        cur = 0
        iph_len = self.parse_ip_header(self.bytes[cur:])
        cur = cur + iph_len

        tcph_len = self.parse_tcp_header(self.bytes[cur:])
        cur = cur + tcph_len

        self.payload = self.bytes[cur:]

        s = ""
        for d in self.payload:
            s = s + "%02x " % (d)
        log.debug("payload: " + s)

        if len(self.payload) >= 5:
            pos = 0
            cont = True
            while cont:
                if len(self.payload[pos:]) < 5:
                    cont = False
                    break

                ch = self.read_char(self.payload[pos:])
#                if not(ch >= 48 and ch <= 122):
#                    break

                pos = pos + 1

                i  = self.read_int32(self.payload[pos:])
                pos = pos + 4
                
                log.debug("sess: " + self.get_session_id() + ": " + str(self.ts) + ": %c[%x] len=%d" % (ch, ch, i))

                # client to server
                if ch == ord('S'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    self.messages.append( [chr(ch), s] )
                    log.debug(s)

                elif ch == ord('Q'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    log.debug(s)
                    self.messages.append( [chr(ch), s] )

                elif ch == ord('P'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    s1 = s.split('\0')
                    log.debug("> " + s1[0] + "," + s1[1])
                    self.messages.append( [chr(ch), s1[0], s1[1]] )

                elif ch == ord('E'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    self.messages.append( [chr(ch), s] )

                elif ch == ord('B'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    s1 = s.split('\0')
                    log.debug("> " + s1[0] + "," + s1[1])
                    self.messages.append( [chr(ch), s1[0], s1[1]] )

                elif ch == ord('X'):
                    self.messages.append( [chr(ch), None] )
                    cont = False

                # server to client
                elif ch == ord('T'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    self.messages.append( [chr(ch), s] )
                    log.debug(s)

                elif ch == ord('D'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    self.messages.append( [chr(ch), s] )
                    log.debug(s)

                elif ch == ord('C'):
                    s = self.read_string(self.payload[pos:], i - 4)
                    self.messages.append( [chr(ch), s] )
                    log.debug(s)

                elif ch == ord('1'):
                    self.messages.append( [chr(ch), None] )

                elif ch == ord('2'):
                    self.messages.append( [chr(ch), None] )

                elif ch == ord('n'):
                    self.messages.append( [chr(ch), None] )

                elif ch == ord('Z'):
                    self.messages.append( [chr(ch), None] )
                    cont = False

                pos = pos + (i - 4)

    def parse(self):
        self.pos = 12
        while len(self.payload) > self.pos + 5:
            c = self.read_char()
            log.debug("%02x(%c)" % (c, c))
            l = self.read_int32()
            log.debug(l)
            self.pos = self.pos + l

    def read_char(self, data):
        ch = data[0]
        return ch

    def read_int32(self, data):
        i = (data[0] << 24) + (data[1] << 16) + (data[2] << 8) + (data[3])
        return i

    def read_string(self, data, size):
        s = ""
        i = 0
        while i < size:
            s = s + "%c" % data[i]
            i = i + 1
        return s

class TcpdumpWrapper:
    pkt     = None
    tcpdump = None
    process = None
    line    = None

    def __init__(self, host=None, port=None, interface=None, inputfile=None, debug=None):
        if debug is True:
            log.setLevel(log.DEBUG)

        self.host      = host
        self.port      = port
        self.iface     = interface
        self.inputfile = inputfile
        self.debug     = debug

        if self.port is None:
            self.port = "5432"

        if self.iface is None:
            self.iface = "any"

        self.tcpdump = "tcpdump -tttt"

        if self.inputfile is not None:
            self.tcpdump = self.tcpdump + " -r " + self.inputfile

        self.tcpdump = self.tcpdump + " -l -i " + self.iface + " -s 0 -X -p tcp port " + str(self.port)

        if self.host is not None:
            self.tcpdump = self.tcpdump + " and host " + self.host

        log.info(self.tcpdump)

        self.process = subprocess.Popen([self.tcpdump],
                                        stdout=subprocess.PIPE,
                                        stderr=subprocess.PIPE,
                                        shell=True,
                                        bufsize=0)

        # header
        self.p1 = re.compile('^([\d-]+) ([\d:\.]+) IP (.*) > (.*): Flags')
        # data
        self.p2 = re.compile('^\t+0x(.+):  (.+)  ')
        
    def get_packet(self):
        self.data = ""
        self.hdr  = None

        while True:
            if self.line is None:
                self.line = self.readline()

                if self.line is None:
                    if self.hdr is not None and self.data is not None:
                        # EOF found.
                        pkt = TcpdumpPacket(self.hdr[0], self.hdr[1], self.hdr[2], self.parse_data(self.data), self.debug)

                        self.data = ""
                        self.hdr  = None

                        return pkt
                    else:
                        return None

            if self.line[0] != '\t':
                if len(self.data) > 0:
                    pkt = TcpdumpPacket(self.hdr[0], self.hdr[1], self.hdr[2], self.parse_data(self.data), self.debug)
                    self.data = ""
                    self.hdr  = None
                    return pkt

                self.hdr = self.parse_header(self.line)
                # d: ts, src, dest
                log.debug("Header: ts=" + self.hdr[0] + ", src=" + self.hdr[1] + ", dest=" + self.hdr[2])

            else:
                #log.debug(">" + self.line[10:50] + "<")
                self.data = self.data + self.line[10:50]

            self.line = None

    def get_last_packet(self):
        pkt = None

        if self.hdr is not None and self.data is not None:
            pkt = TcpdumpPacket(self.hdr[0], self.hdr[1], self.hdr[2], self.parse_data(self.data), self.debug)

            self.data = ""
            self.hdr  = None

        return pkt

    def readline(self):
        self.process.stdout.flush()
        line = self.process.stdout.readline()

        if len(line) == 0:
            # EOF
            self.process.poll()
            if self.process.returncode != 0:
                log.error("%s" % self.process.stderr.readline())
                sys.exit(1)

            log.debug("readline: EOF")
            return None

        return line.rstrip()

    def parse_header(self, line):
        r1 = self.p1.match(line)

        if r1 is not None:
            # Header line may look like this:
            # 2015-04-30 13:33:27.579311 IP localhost.55641 > localhost.postgres: Flags [.], ack 66, win 664, options [nop,nop,TS val 265008484 ecr 265008484], length 0
            ts   = r1.group(1) + " " + r1.group(2)
            src  = r1.group(3)
            dest = r1.group(4)

            return [ts, src, dest]

        return None

    def parse_data(self, line):
        bytes = []
        # line:
        # 4500 0039 e080 4000 4006 5c3c 7f00 0001
        offset = 0
        length = len(line)

        log.debug("! " + line)
        cur = 0
        while cur < length:
            if line[cur] == ' ':
                cur = cur + 1
                continue
            # chr to hex
            h = int(line[cur:cur+2], 16)
            bytes.append(h)
#            print(payload[cur:cur+2] + ", " + str(h))
            cur = cur + 2

        return bytes

    def parse(self, line):
        # return true when messages avalable.
        msg_avail = False

        log.debug("parse: " + line)

        # packet header info
        r1 = self.p1.match(line)
        if r1 is not None:
            # Header line may look like this:
            # 13:33:27.579311 IP localhost.55641 > localhost.postgres: Flags [.], ack 66, win 664, options [nop,nop,TS val 265008484 ecr 265008484], length 0
            log.debug("Header: " + line)
            ts   = r1.group(1)
            src  = r1.group(2)
            dest = r1.group(3)

            # close the previous packet
            if self.pkt is not None:
                self.pkt.end()

                # retreive all info/messages in the previous packet.
                self.session_id = self.pkt.get_session_id()
                self.timestamp  = self.pkt.get_timestamp()
                self.messages   = copy.deepcopy(self.pkt.get_messages())
                msg_avail = True
                
                for m in self.pkt.get_messages():
                    log.debug("ts:%s cmd:%c msg:%s" % (str(self.pkt.get_timestamp()), m[0], m[1]))

            # new packet coming
            self.pkt = TcpdumpPacket(ts, src, dest, self.debug)
            self.packets.append(self.pkt)

        # packet bytes
        r2 = self.p2.match(line)
        if r2 is not None:
            log.debug("matched r2: " + line)

            if self.pkt is not None:
                log.debug("append_bytes: " + line)
                self.pkt.append_bytes(r2.group(2))

        return msg_avail

    def print_packets(self):
        print(self.packets)
