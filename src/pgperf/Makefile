TOPDIR=../..

include $(TOPDIR)/Makefile.global

all:
	./_build.sh

check:
	make -C t check

clean:
	rm -f pgperf_snapshot_install90.sql
	rm -f pgperf_snapshot_install91.sql
	rm -f pgperf_snapshot_install92.sql
	rm -f pgperf_snapshot_install93.sql
	rm -f pgperf_snapshot_install94.sql
	rm -f *~
	make -C t clean

install:
	mkdir -p $(PREFIX)/share
	install -m 644 pgperf_snapshot_install90.sql $(PREFIX)/share
	install -m 644 pgperf_snapshot_install91.sql $(PREFIX)/share
	install -m 644 pgperf_snapshot_install92.sql $(PREFIX)/share
	install -m 644 pgperf_snapshot_install93.sql $(PREFIX)/share
	install -m 644 pgperf_snapshot_install94.sql $(PREFIX)/share
