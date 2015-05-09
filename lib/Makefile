include ../Makefile.global

all:

check:
	./testDirectoryTree.py
	./testLog.py
	./testPsqlWrapper.py
	./testTcpdumpWrapper.py

install:
	mkdir -p $(PREFIX)/lib
	install -m 644 PsqlWrapper.py $(PREFIX)/lib
	install -m 644 log.py $(PREFIX)/lib
	install -m 644 DirectoryTree.py $(PREFIX)/lib
	install -m 644 TcpdumpWrapper.py $(PREFIX)/lib

clean:
	rm -f *~ *.pyc
	rm -rf t1

