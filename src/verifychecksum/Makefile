# 
# verifychecksum Makefile
#
# Copyright(c) 2015 Uptime Technologies, LLC.
#
CFLAGS = -Wall -g -I/usr/pgsql-9.4/include/server
LIBS = 

TARGET = verifychecksum.bin

TOPDIR = ../..

include $(TOPDIR)/Makefile.global

all: $(TARGET)

verifychecksum.bin: verifychecksum.c
	$(CC) $(CFLAGS) -o $@ $< $(LIBS)

install:
	mkdir -p $(PREFIX)/bin
	install -m 755 $(TARGET) $(PREFIX)/bin
	mkdir -p $(PREFIX)/src
	install -m 755 *.c $(PREFIX)/src

clean:
	rm -rf $(TARGET) *~

