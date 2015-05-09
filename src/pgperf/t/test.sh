#!/bin/sh

LANG=C
PGCLIENTENCODING=utf8
export LANG PGCLIENTENCODING

TESTNAME=$1
DBNAME=testdb
PSQL_OPTS=""

if [ "$TESTNAME" = "" ]; then
    echo "Usage: $0 <TESTNAME>"
    exit 1
fi

if [ ! -d $TESTNAME ]; then
    echo Test $TESTNAME does not exist. Aborted.
    echo $TESTNAME >> failed.log
    exit 2;
fi

if [ ! -d "$TESTNAME/output" ]; then
    mkdir -p $TESTNAME/output
fi

if [ -f "$TESTNAME/input/setup.sql" ]; then
    psql ${PSQL_OPTS} -f $TESTNAME/input/setup.sql $DBNAME \
	> $TESTNAME/output/setup.out 2> $TESTNAME/output/setup.err
fi

if [ -f "$TESTNAME/input/test${_MAJOR_STR}.sql" ]; then
    psql ${PSQL_OPTS} -e -f $TESTNAME/input/test${_MAJOR_STR}.sql $DBNAME \
	> $TESTNAME/output/test.out 2> $TESTNAME/output/test.err
elif [ -f "$TESTNAME/input/test.sql" ]; then
    psql ${PSQL_OPTS} -e -f $TESTNAME/input/test.sql $DBNAME \
	> $TESTNAME/output/test.out 2> $TESTNAME/output/test.err
else
    echo Test $TESTNAME/input/test.sql does not exist. Aborted.
    echo $TESTNAME >> failed.log
    exit 3
fi

if [ -f "$TESTNAME/expected/test${_MAJOR_STR}.out" ]; then
    diff --strip-trailing-cr -rc $TESTNAME/expected/test${_MAJOR_STR}.out $TESTNAME/output/test.out > $TESTNAME/result.diff
elif [ -f "$TESTNAME/expected/test.out" ]; then
    diff --strip-trailing-cr -rc $TESTNAME/expected/test.out $TESTNAME/output/test.out > $TESTNAME/result.diff
else
    diff --strip-trailing-cr -rc /dev/null $TESTNAME/output/test.out > $TESTNAME/result.diff
fi

if [ -s $TESTNAME/result.diff ]; then
    echo $TESTNAME: Failed.
    echo $TESTNAME >> failed.log
else
    echo $TESTNAME: OK.
    echo $TESTNAME >> ok.log
fi

cat $TESTNAME/result.diff >> result.diff

