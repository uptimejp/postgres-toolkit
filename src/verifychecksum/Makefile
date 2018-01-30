# 
# verifychecksum Makefile
#
# Copyright(c) 2015-2018 Uptime Technologies, LLC.
#

PGFILEDESC = "verifychecksum"

PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

OBJS	= verifychecksum.o

all: verifychecksum.bin

verifychecksum.bin: $(OBJS)
	$(CC) $^ -o $@

clean distclean maintainer-clean:
	rm -f verifychecksum.bin $(OBJS)
