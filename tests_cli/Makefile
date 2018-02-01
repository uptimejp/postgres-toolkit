include ../../Makefile.global

all:
	@grep -c ^function.test test-*.sh

check:
	./regress.sh

clean:
	-killall postgres
	rm -rf data
	rm -rf *.out *.diff
	rm -rf *~
	rm -rf out?? data?? data??_slave
	rm -rf *.log _postgresql.conf
	rm -rf *.expected
	rm -f snapshot.exp
