CC=cc
LIBS=-lgmp
CFLAGS=-O2 -march=native
GRAND_CC=${CC} ${CFLAGS}

C_FILES=excellent-int-math.c
BASE=excellent-int-math

all:
	${GRAND_CC} -o ${BASE} ${C_FILES}

# make file target name?
try:
	${GRAND_CC} -o ${BASE}-try ${C_FILES}
	./${BASE}-try

debug:
	${GRAND_CC} -o ${BASE}-debug -DDEBUGGING=1 ${C_FILES}
	./excellent-gmp-try

valgrind:
	${GRAND_CC} -g -o ${BASE}-valgrind ${C_FILES}
	valgrind --leak-check=full --show-leak-kinds=all -v ${BASE}-valgrind 10

