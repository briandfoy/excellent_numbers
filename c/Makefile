CC=cc
LIBS=-lm

OPTIMIZE=-O2 -march=native -ffinite-math-only -fno-math-errno
WARNINGS=-Wall

CFLAGS=${WARNINGS} ${OPTIMIZE}
GRAND_CC=${CC} ${CFLAGS} ${LIBS}

C_FILES=excellent-128.c
BASE=excellent-128

all:
	${GRAND_CC} -o ${BASE} ${C_FILES}

debug:
	${GRAND_CC} -o ${BASE}-debug -DDEBUGGING=1 ${C_FILES}

valgrind:
	${GRAND_CC} -g -o ${BASE}-valgrind ${C_FILES}
	valgrind --leak-check=full --show-leak-kinds=all -v ${BASE}-valgrind 10

