TOPDIR=..

include $(TOPDIR)/Makefile.global

all:
	make -C verifychecksum all
	make -C pgperf all

check:
	make -C pgperf check

install:
	make -C verifychecksum install
	make -C pgperf install

clean:
	make -C verifychecksum clean
	make -C pgperf clean


