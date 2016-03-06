#include "gmp.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <errno.h>
#include <signal.h>

volatile sig_atomic_t int_flag  = 0;
volatile sig_atomic_t usr1_flag = 0;

void bisect( int, int, mpz_t );
void default_start_a( int, mpz_t );
void default_end_a(   int, mpz_t );
void time_left ( const mpz_t, const mpz_t, const mpz_t );
void int_handler(  int signo );
void usr1_handler( int signo );

void int_handler(  int signo ) {
	++int_flag;
	}
void usr1_handler( int signo ) {
	++usr1_flag;
	}

void setup_interrupt() {
	struct sigaction act;
	act.sa_handler = int_handler;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	if( sigaction(SIGINT, &act, 0) == -1 ) {
		perror( "sigaction couldn't install SIGINT" );
		}
	}

void setup_usr1() {
	struct sigaction act;
	act.sa_handler = usr1_handler;
	sigemptyset(&act.sa_mask);
	act.sa_flags = 0;
	if( sigaction(SIGUSR1, &act, 0) == -1 ) {
		perror( "sigaction couldn't install SIGUSR1" );
		}
	}

int main( int argc, char *argv[] ) {
	setup_interrupt();
	setup_usr1();

	mpz_t start_a, end_a;
	int base10_ui = 10;
	int digits, k;

	mpz_inits( start_a, end_a, NULL );

	if( argc == 1 ) {
		digits = 4;
		k = 2;
		}
	else {
		digits = strtol(argv[1], (char **)NULL, 10);
		k = ( digits / 2 );
		}

	fprintf( stderr, "digits: %d \n", digits );
	fprintf( stderr, "k: %d \n", k );

	if( argc <= 2 ) {
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

	mpz_t zero, one, two, eight, ten, ten_k;
	mpz_inits( zero, one, two, eight, ten, ten_k, NULL );
	mpz_set_ui( zero,  0L );
	mpz_set_ui( one,   1L );
	mpz_set_ui( two,   2L );
	mpz_set_ui( eight, 8L );
	mpz_set_ui( ten,  10L );

	mpz_pow_ui( ten_k, ten, k );

	/* odd numbers cannot be candidates for a. Start with an even
	number and add two to check the next candidate */
	if( mpz_odd_p( start_a ) == 1 ) {
		mpz_add( start_a, start_a, one );
		}

	gmp_printf( "*** [%d] start a is %Zd\n", getpid(), start_a );
	gmp_printf( "*** [%d] end a is %Zd\n",   getpid(), end_a   );
	fflush( stdout );

	mpz_t      i, mod2, mod10, front, back, root, root_plus_one;
	mpz_inits( i, mod2, mod10, front, back, root, root_plus_one, NULL );

	int last_time, this_time, time_passed;
	unsigned int report_period;
	report_period = 60*15;

	mpz_t last_i, numbers_done, rate;
	mpz_inits( last_i, numbers_done, rate, NULL );
	mpz_set( last_i, start_a );
	mpz_set( numbers_done, zero );
	mpz_set( rate, zero );
	last_time = (unsigned)time(NULL);

	/* only check the even numbers, so increase by 2 each iteration */
	for( mpz_set( i, start_a ); mpz_cmp( i, end_a ) <= 0; mpz_add(i, i, two) ) {
		if( int_flag > 0 ) {
			printf( "!!! [%d] Caught interrupt\n", getpid() );
			break;
			}

		this_time = (unsigned)time(NULL);

		/* record some progress info */
		if( usr1_flag > 0 || ( ( (this_time % report_period) == 0) && (this_time != last_time) ) ) {
			usr1_flag = 0;
			time_passed = this_time - last_time;
			mpz_sub( numbers_done, i, last_i );
			mpz_tdiv_q_ui( rate, numbers_done, time_passed );
			gmp_printf( "+++ [%d] Checked [%Zd] to [%Zd]\n", getpid(), start_a, i );
			gmp_printf( "*** [%d] [%u] working on: %Zd tried: %Zd rate: %Zd / sec\n",
				getpid(), this_time, i, numbers_done, rate );
			time_left( rate, i, end_a );
			fflush( stdout );
			mpz_set( last_i, i );
			last_time = this_time;
			}

		/* skip those that end in 2 or 8 */
		mpz_mod( mod10, i, ten );
		if( (mpz_cmp( mod10, two ) == 0) || (mpz_cmp( mod10, eight ) == 0) ) {
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

	gmp_printf( "+++ [%d] Checked [%Zd] to [%Zd]\n", getpid(), start_a, i );
	fflush( stdout );

	mpz_clears( mod2, mod10, front, back, root, root_plus_one, NULL );
	mpz_clears( i, start_a, end_a, ten_k, one, two, ten, zero, NULL );

	return( 0 );
	}

void time_left ( const mpz_t rate, const mpz_t this_a, const mpz_t end_a ) {
	mpz_t left_a, seconds_left, weeks, days, hours, minutes, seconds;
	mpz_inits( left_a, seconds_left, weeks, days, hours, minutes, seconds, NULL );

	mpz_sub( left_a, end_a, this_a );

	mpz_tdiv_q( seconds_left, left_a, rate );
	mpz_tdiv_q_ui( weeks, seconds_left, 60*60*24*7 );

	mpz_tdiv_q_ui( days, seconds_left, 60*60*24 );
	mpz_mod_ui( days, days, 7 );

	mpz_tdiv_q_ui( hours, seconds_left, 60*60 );
	mpz_mod_ui( hours, hours, 24 );

	mpz_tdiv_q_ui( minutes, seconds_left, 60*60 );
	mpz_mod_ui( minutes, minutes, 60 );

	mpz_tdiv_q_ui( seconds, seconds_left, 60 );
	mpz_mod_ui( seconds, seconds, 60 );

	gmp_printf( "*** [%d] time left: %Zd wk %Zd d %Zd h %Zd m %Zd s\n",
		getpid(), weeks, days, hours, minutes, seconds );

	mpz_clears( left_a, seconds_left, weeks, days, hours, minutes, seconds, NULL );
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


