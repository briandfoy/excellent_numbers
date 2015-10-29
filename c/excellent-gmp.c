#include "gmp.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>

/*


my $k  = ( $digits / 2 );
my $start = 10**($k-1);

foreach my $n ( $start .. 10**($k) - 1 ) {
	say "[@{[time]}] Working on $n" unless $n % $start;
	my $front = $n*(10**$k + $n);
	my $root = int( sqrt( $front ) );

	foreach my $try ( $root - 2 .. $root + 2 ) {
		my $back = $try * ($try - 1);
		last if length($try) > $k;
		last if $back > $front;
		if( $back == $front ) {
			say "$n$try";
			last;
			}
		}
	}

*/

int power( int, int );
void bisect( int, int, mpz_t );
void default_start_a( int, mpz_t );
void default_end_a(   int, mpz_t );

int main( int argc, char *argv[] ) {
	mpz_t i, m, one, result, root, root_less_one, start_a, end_a, front, back, ten_k, mod10, mod2;
	int base10_ui = 10;
	int digits, len, k, n;

	mpz_inits( i, one, start_a, end_a, root, result, front, back, ten_k, mod10, mod2, NULL );

	if( argc == 1 ) {
		digits = 4;
		}
	else {
		digits = strtol(argv[1], (char **)NULL, 10);
		}

	/* printf( "digits is %d\n",  digits ); */

	k = ( digits / 2 );
	/* printf( "k is %d\n",  k ); */

	if( argc == 2 ) {
		default_start_a( k, start_a );
		default_end_a(   k, end_a   );
		}
	else if( argc == 3 ) {
		mpz_init_set_str( start_a, argv[2], base10_ui );
		default_end_a(   k, end_a   );
		}
	else if( argc == 4 ) {
		mpz_init_set_str( start_a, argv[2], base10_ui );
		mpz_init_set_str( end_a,   argv[3], base10_ui );
		}
	else if( argc > 4 ) {
		fprintf( stderr, "Use: %s DIGITS START END\n", argv[0] );
		return( 1 );
		}

	/* gmp_printf( "start a is %Zd\n", start_a );  */
	gmp_printf( "end is %Zd\n",     end_a   );

	mpz_ui_pow_ui( ten_k, 10L, k );
	/* gmp_printf( "10^k is %Zd\n", ten_k );  */

	for( mpz_set( i, start_a ); mpz_cmp( i, end_a ) <= 0; mpz_add_ui(i, i, 1L) ) {
		/* gmp_printf( "%Zd\n", i );  */

		mpz_mod_ui( mod10, i, 10L );
		mpz_mod_ui( mod2, mod10, 2L );

		if( mpz_cmp_ui( mod2, 0L ) != 0 ) { /* skip the odd numbers */
			continue;
			}
		if( mpz_cmp_ui( mod10, 2L ) == 0 ) { /* cannot end in 2 */
			continue;
			}

		mpz_add( front, ten_k, i );
		mpz_mul( front, front, i );
		/* gmp_printf( "\tfront is %Zd\n", front ); */

		mpz_sqrt( root, front );
		/* gmp_printf( "\troot is %Zd\n", root ); */

		mpz_init( root_less_one );
		mpz_add_ui( root_less_one, root, 1L );
		/* gmp_printf( "\troot_less_one is %Zd\n", root_less_one ); */
		mpz_mul( back, root, root_less_one );
		/* gmp_printf( "\tback is %Zd\n", back ); */

		if( 0 == mpz_cmp( front, back ) ) {
			gmp_printf( "%Zd%Zd is excellent\n", i, root_less_one );
			}
		}

	/* len = mpz_sizeinbase(n, 16) + 2; */

	mpz_clears( start_a, end_a, i, ten_k, front, mod10, mod2, NULL );

	return( 0 );
	}

void default_start_a( int k, mpz_t start_a ) {
	mpz_set_ui(
		start_a,
		power( 10, k - 1 )
		);
	}

void default_end_a( int k, mpz_t end_a ) {
	bisect( k, 1, end_a );
	}

int power( int base, int exponent ) {
	int i;
	int result = 1;
	for( i = 1; i <= exponent; i++ ) {
		result *= base;
		}
	return result;
	}

void bisect ( int k, int threshold, mpz_t end_a ) {
	mpz_t b, minimum, maximum, try, last_try, result, result2;
	mpz_inits( b, minimum, maximum, try, last_try, result, result2, NULL );

	mpz_ui_pow_ui( b, 10, k );

	mpz_set( maximum, b );
	mpz_sub_ui( maximum, b, 1L );
	gmp_printf( "maximum is %Zd\n", maximum );
	mpz_ui_pow_ui( minimum, 10, k - 1 );
	gmp_printf( "minimum is %Zd\n", minimum );

	mpz_set( try, maximum );
	mpz_sub( try, try, minimum );
	mpz_tdiv_q_ui( try, try, 2 );

	gmp_printf( "first try is %Zd\n", try );

	while( 1 ) {
		/* sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) }, */
		mpz_mul( result, try, try );
		mpz_ui_pow_ui( result2, 10, k );
		mpz_mul( result2, result2, try );
		mpz_add( result, result, result2 );
		mpz_sqrt( result, result );

		mpz_set( last_try, try );
		mpz_sub( result2, result, b );
		mpz_abs( result2, result2 );

		if( mpz_cmp_ui( result2, threshold ) < 0 ) {
			break;
			}
		else if( mpz_cmp( result, b ) > 0 ) { /* result is too big, make try smaller */
			mpz_set( maximum, try );
			/* 				int( $minimum + ( $try - $minimum ) / 2 ); */
			mpz_sub( result2, try, minimum );
			mpz_tdiv_q_ui( result2, result2, 2 );
			mpz_add( try, minimum, result2 );
			}
		else if( mpz_cmp( result, b ) < 0 ) { /* result is too small, make try bigger */
			mpz_set( minimum, try );
			/* int( ($try + ( $maximum - $try ) / 2) + 1 ); */
			mpz_sub( result2, maximum, try );
			mpz_tdiv_q_ui( result2, result2, 2 );
			mpz_add( result2, result2, try );
			mpz_add_ui( result2, result2, 1L);
			mpz_set( try, result2 );
			}
		else {
			break;
			}

		if( 0 == mpz_cmp( last_try, try ) ) {
			break;
			};

		mpz_sub( result2, maximum, minimum );
		if( mpz_cmp_ui( result2, threshold ) <= 0 ) {
			mpz_set( try, minimum );
			break;
			}
		}

	mpz_add_ui( end_a, try, threshold ) /* cheat a little */;

	mpz_clears( b, minimum, maximum, try, last_try, result, result2, NULL );
	}


