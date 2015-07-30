include ../Makefile.global

all:
	make -C ../src/verifychecksum all
	cp ../src/verifychecksum/verifychecksum.bin .

check:
	make -C t check

install:
	mkdir -p $(PREFIX)/bin
	install -m 755 pt-archive-xlog $(PREFIX)/bin
	install -m 755 pt-config $(PREFIX)/bin
	install -m 755 pt-index-usage $(PREFIX)/bin
	install -m 755 pt-kill $(PREFIX)/bin
	install -m 755 pt-privilege-autogen $(PREFIX)/bin
	install -m 755 pt-proc-stat $(PREFIX)/bin
	install -m 755 pt-session-profiler $(PREFIX)/bin
	install -m 755 pt-set-tablespace $(PREFIX)/bin
	install -m 755 pt-show-locks $(PREFIX)/bin
	install -m 755 pt-snap-statements $(PREFIX)/bin
	install -m 755 pt-replication-stat $(PREFIX)/bin
	install -m 755 pt-stat-snapshot $(PREFIX)/bin
	install -m 755 pt-table-usage $(PREFIX)/bin
	install -m 755 pt-tablespace-usage $(PREFIX)/bin
	install -m 755 pt-verify-checksum $(PREFIX)/bin
	install -m 755 pt-xact-stat $(PREFIX)/bin

clean:
	rm -f *~
	rm -f verifychecksum.bin
	make -C t clean
