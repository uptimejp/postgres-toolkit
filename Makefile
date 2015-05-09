include Makefile.global

all:
	make -C docs all
	make -C src all
	make -C deps all
	make install.sh

install.sh: install.sh.in
	sed 's/__VERSION__/$(VERSION)/' ./install.sh.in > install.sh

check:
	make -C lib check
	make -C bin check
	make -C src check

install:
	mkdir -p $(PREFIX)
	install -m 644 LICENSE $(PREFIX)
	make -C bin install
	make -C lib install
	make -C src install
	make -C docs install

uninstall:
	rm -rf $(PREFIX)

dist: uninstall install installcheck
	tar zcvf postgres-toolkit-$(VERSION).tar.gz $(PREFIX)

installcheck:
	find $(PREFIX)/bin -name 'pt-*' -type f | sort | awk '{ print $$1 " --help" }' | sh > installcheck.out
	diff -rc installcheck.expected installcheck.out

clean:
	make -C bin clean
	make -C lib clean
	make -C docs clean
	make -C src clean
	make -C deps clean
	rm -rf postgres-toolkit-$(VERSION).tar.gz
	rm -f installcheck.out
	rm -f install.sh

