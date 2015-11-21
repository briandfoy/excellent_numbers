CC=cc
LIBS=-lgmp

GRAND_CC=${CC} ${LIBS}

C_FILES=excellent-gmp.c
BASE=excellent-gmp

all:
	${GRAND_CC} -o ${BASE} ${C_FILES}

# make file target name?
try:
	${GRAND_CC} -o ${BASE}-try ${C_FILES}
	./excellent-gmp-try

debug:
	${GRAND_CC} -o ${BASE}-debug -DDEBUGGING=1 ${C_FILES}
	./excellent-gmp-try

valgrind:
	${GRAND_CC} -g -o ${BASE}-valgrind ${C_FILES}
	valgrind --leak-check=full --show-leak-kinds=all -v ${BASE}-valgrind 10

