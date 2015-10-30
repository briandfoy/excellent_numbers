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

void bisect( int, int, mpz_t );
void default_start_a( int, mpz_t );
void default_end_a(   int, mpz_t );

int main( int argc, char *argv[] ) {
	mpz_t start_a, end_a;
	int base10_ui = 10;
	int digits, k;

	mpz_inits( start_a, end_a, NULL );

	if( argc == 1 ) {
		digits = 4;
		}
	else {
		digits = strtol(argv[1], (char **)NULL, 10);
		}

	k = ( digits / 2 );

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

	gmp_printf( "start a is %Zd\n", start_a );
	gmp_printf( "end is %Zd\n",     end_a   );
	fflush( stdout );

	mpz_t one, ten, two, zero, ten_k;
	mpz_inits( one, ten, two, zero, ten_k, NULL );
	mpz_set_ui( one, 1L );
	mpz_set_ui( ten, 10L );
	mpz_set_ui( two, 2L );
	mpz_set_ui( zero, 0L );

	mpz_pow_ui( ten_k, ten, k );

	mpz_t      i, mod2, mod10, front, back, root, root_plus_one;
	mpz_inits( i, mod2, mod10, front, back, root, root_plus_one, NULL );

	for( mpz_set( i, start_a ); mpz_cmp( i, end_a ) <= 0; mpz_add(i, i, one) ) {
		/* skip the odd numbers */
		mpz_mod( mod2, i, two );
		if( mpz_cmp( mod2, zero ) != 0 ) {
			continue;
			}

		/* skip those that end in 2 */
		mpz_mod( mod10, i, ten );
		if( mpz_cmp( mod10, two ) == 0 ) {
			continue;
			}

		/* the front part of the number */
		mpz_add( front, ten_k, i );
		mpz_mul( front, front, i );


		/* the back part of the number */
		mpz_sqrt( root, front );
		mpz_add( root_plus_one, root, one );
		mpz_mul( back, root, root_plus_one );

		if( 0 == mpz_cmp( front, back ) ) {
			gmp_printf( "%Zd%Zd is excellent\n", i, root_plus_one );
			fflush( stdout );
			}
		}

	mpz_clears( mod2, mod10, front, back, root, root_plus_one, NULL );
	mpz_clears( i, start_a, end_a, ten_k, one, two, ten, zero, NULL );

	return( 0 );
	}

void default_start_a( int k, mpz_t start_a ) {
	mpz_ui_pow_ui( start_a, 10, k - 1 );
	}

void default_end_a( int k, mpz_t end_a ) {
	bisect( k, 1, end_a );
	}

void bisect ( int k, int threshold, mpz_t end_a ) {
	mpz_t b, minimum, maximum, try, last_try, result, result2;
	mpz_inits( b, minimum, maximum, try, last_try, result, result2, NULL );

	mpz_ui_pow_ui( b, 10, k );

	mpz_set( maximum, b );
	mpz_sub_ui( maximum, b, 1L );
	mpz_ui_pow_ui( minimum, 10, k - 1 );

	mpz_set( try, maximum );
	mpz_sub( try, try, minimum );
	mpz_tdiv_q_ui( try, try, 2 );

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
			/* int( $minimum + ( $try - $minimum ) / 2 ); */
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

		if( 0 == mpz_cmp( last_try, try ) ) { /* stop if we're about to try the same number again */
			break;
			};

		mpz_sub( result2, maximum, minimum );
		/* avert a cycle with the min is very close to the max */
		if( mpz_cmp_ui( result2, threshold ) <= 0 ) {
			mpz_set( try, minimum );
			break;
			}
		}

	mpz_add_ui( end_a, try, threshold ) /* cheat a little by adding threshold */;

	mpz_clears( b, minimum, maximum, try, last_try, result, result2, NULL );
	}


