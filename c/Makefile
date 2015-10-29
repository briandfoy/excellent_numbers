all:
	cc -lgmp -o excellent-gmp excellent-gmp.c

valgrind:
	cc -lgmp  -g-o excellent-gmp excellent-gmp.c
	valgrind --leak-check=full --show-leak-kinds=all -v ./excellent-gmp 10
