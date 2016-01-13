CC=cc
LIBS=-lgmp
CFLAGS=-O2 -march=native
GRAND_CC=${CC} ${CFLAGS}

C_FILES=excellent-128.c
BASE=excellent-128
ALARM_MINUTES ?= 3

all:
	${GRAND_CC} -o ${BASE} ${C_FILES}

short:
	@ echo 'ALARM_MINUTES is' ${ALARM_MINUTES}
	${GRAND_CC} -o ${BASE}-$@ -DALARM_MINUTES=${ALARM_MINUTES} ${C_FILES}

debug:
	${GRAND_CC} -o ${BASE}-debug -DDEBUGGING=1 ${C_FILES}

valgrind:
	${GRAND_CC} -g -o ${BASE}-valgrind ${C_FILES}
	valgrind --leak-check=full --show-leak-kinds=all -v ${BASE}-valgrind 10

