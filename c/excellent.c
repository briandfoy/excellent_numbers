#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main( int argc, char *argv[] ) {
	long 
		k, digits,
		start, end,
		a, b,
		front, back,
		root
		;

	digits = atoi( argv[1] );

	k = digits / 2;
	
	start = (long) pow(10, k - 1);
	end   = (long) pow(10, k);

	for( a = start; a < end; a++ ) {
		front = (long) a * ( pow(10,k) + a );
		root  = (long) floor( sqrt( front ) );

		for( b = root - 1; b <= root + 1; b++ ) {
			back = (long) b * ( b - 1 );
			if( back > front )  { break; }
			if( log10(b) > k ) { continue; }
			if( front == back ) {
				printf( "%ld%ld\n", a, b );
				}
			}
		}
		
	return 0;
	}
