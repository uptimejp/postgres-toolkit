TOPDIR=../../..

include $(TOPDIR)/Makefile.global

all:
	echo noting to be done.

check:
	./regress.sh

clean:
	find . -type f -name 'result.diff' | xargs rm -f
	find . -type d -name 'output' | xargs rm -rf
	rm -rf data90 data91 data92 data93 data94
	rm -rf out90 out91 out92 out93 out94
	rm -f catalog90.txt catalog91.txt catalog92.txt catalog93.txt catalog94.txt
	rm -f *.log _postgresql.conf
