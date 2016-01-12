#include <errno.h>
#include <inttypes.h>
#include <math.h>
#include <signal.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

const uint64_t powers_of_10[] = {
    1,
    10,
    100,
    1000,
    10000,
    100000,
    1000000,
    10000000,
    100000000,
    1000000000,
    10000000000LL,
    100000000000LL,
    1000000000000LL,
    10000000000000LL,
    100000000000000LL,
    1000000000000000LL,
    10000000000000000LL,
    100000000000000000LL,
    1000000000000000000LL,
};

/* This was created by perl/bisect.pl. Take the maximum b (all 9s)
and compute the largest a from that.

Each position represents a value of k (half digits), with 0 as a placeholder
for k=0 */
const uint64_t stop_a[] = {
    0,
    6,
    63,
    619,
    6181,
    61805,
    618034,
    6180340,
    61803400,
    618033989,
    6180339888LL,
    61803398875LL,
    618033988751LL,
    6180339887499LL,
    61803398874990LL,
    618033988749895LL,
    6180339887498949LL,
    61803398874989485LL,
    618033988749894849LL,
    6180339887498948483LL,
};

/* a has to end in 0, 4, or 6. Instead of incrementing by 2 and
checking the last decimal digit, use the last decimal digit to choose
the increment value. 0->4, 4->6, 6->0

Increment by 1 for any other ending and eventually we'll be back in sync.
*/
const uint8_t next_a[] = {
    4,         /* previous a ends in 0 */
    1, 1, 1,
    2,         /* previous a ends in 4 */
    1,
    4,         /* previous a ends in 6 */
    1, 1, 1
};

const uint8_t  seconds_per_minute = 60;
const uint16_t seconds_per_hour = seconds_per_minute * 60;
const uint32_t seconds_per_day = seconds_per_hour * 24;
const uint32_t seconds_per_week = seconds_per_day * 7;

const uint64_t iterations_per_signal_check = 300000000;

const uint8_t alarm_minutes = 1;

struct excellent_progress_info {
    uint64_t last_a;
    uint64_t numbers_done;
    uint64_t rate;
    uint32_t last_time;
};

volatile sig_atomic_t alarm_flag = 0;
volatile sig_atomic_t int_flag  = 0;
volatile sig_atomic_t usr1_flag = 0;

static unsigned __int128 umult64x64_128(uint64_t, uint64_t);
static uint64_t default_start_a( uint8_t );
static uint64_t default_end_a( uint8_t );
static void time_left ( uint64_t, uint64_t, uint64_t );
static void alarm_handler( int signo );
static void int_handler(  int signo );
static void usr1_handler( int signo );

static void
report_progress(
        struct excellent_progress_info *pinfo,
        uint64_t start_a,
        uint64_t a
        )
{
    pinfo->numbers_done = a - pinfo->last_a;
    unsigned this_time = time(NULL);
    pinfo->rate = pinfo->numbers_done / (this_time - pinfo->last_time);

    printf( "+++ [%d] Checked [%" PRIu64 "] to [%" PRIu64 "]\n",
            getpid(), start_a, a );
    printf( "*** [%d] [%u] working on: %" PRIu64 " tried: %" PRIu64 " rate: %" PRIu64 " / sec\n",
            getpid(), this_time, a, pinfo->numbers_done, pinfo->rate );
	fflush( stdout );
    pinfo->last_time = this_time;
    pinfo->last_a = a;

    return;
}

static void
alarm_handler( int signo ) {
    alarm_flag += 1;
    /* Reset the alarm so we get output more than once */
    alarm( alarm_minutes * seconds_per_minute);
}

static void
int_handler(  int signo ) {
    int_flag += 1;
}

static void
usr1_handler( int signo ) {
    usr1_flag += 1;
}

static void
setup_interrupt( void ) {
    struct sigaction act;
    act.sa_handler = int_handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    if( sigaction(SIGINT, &act, 0) == -1 ) {
        perror( "sigaction couldn't install SIGINT" );
    }
}

static void
setup_usr1( void ) {
    struct sigaction act;
    act.sa_handler = usr1_handler;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    if( sigaction(SIGUSR1, &act, 0) == -1 ) {
        perror( "sigaction couldn't install SIGUSR1" );
    }
}

static void
setup_alarm( void ) {
    struct sigaction act;
    act.sa_handler = alarm_handler;
    sigemptyset(&act.sa_mask);
    if ( sigaction(SIGALRM, &act, NULL) == -1 ) {
        perror( "sigaction couldn't install SIGALRM" );
    }
    alarm(alarm_minutes * seconds_per_minute);
}

static void
time_left ( uint64_t rate, uint64_t this_a, uint64_t end_a ) {
    uint64_t left_a, seconds_left;
    uint8_t weeks, days, hours, minutes, seconds;

    left_a = end_a - this_a;

    seconds_left = (uint64_t) (1 + ((double) left_a) / rate);

    weeks   = seconds_left / seconds_per_week;
    days    = ( seconds_left / seconds_per_day ) % 7;
    hours   = ( seconds_left / seconds_per_hour ) % 24;
    minutes = ( seconds_left / seconds_per_minute ) % 60;
    seconds = seconds_left - (
            weeks * seconds_per_week +
            days * seconds_per_day +
            hours * seconds_per_hour +
            minutes * seconds_per_minute
            );

    printf( "*** [%d] time left: %u wk %u d %u h %u m %u s\n",
            getpid(), weeks, days, hours, minutes, seconds );
	fflush( stdout );

    return;
}

static uint64_t
default_start_a( uint8_t k ) {
    return powers_of_10[ k - 1 ];
}

static uint64_t
default_end_a( uint8_t k ) {
    return stop_a[ k ];
}

static unsigned __int128
umult64x64_128(uint64_t x, uint64_t y)
{
    unsigned __int128 z = ((unsigned __int128) x) * ((unsigned __int128) y);
    return z;
}

static void
check_excellent(uint64_t a, uint64_t K) {
    unsigned __int128 lhs, rhs;
    uint64_t b = (uint64_t) (1.0 + a * sqrt(1 + ((double) K)/ a));

    lhs = umult64x64_128(b, b - 1);
    rhs = umult64x64_128(a, K) + umult64x64_128(a, a);

    if ( lhs == rhs ) {
        printf("%" PRIu64 "%" PRIu64 " is excellent\n", a, b );
        fflush( stdout );
    }

    return;
}


int main( int argc, char *argv[] ) {
    setup_interrupt();
    setup_usr1();
    setup_alarm();

    uint64_t a, start_a, end_a;
    uint64_t current_iter, K;
    uint8_t digits, k;
    struct excellent_progress_info pinfo = { 0 };

    if ( (argc < 2) || (argc > 4)) {
        fprintf( stderr, "Usage: %s DIGITS START END\n", argv[0] );
        exit( EXIT_FAILURE );
    }

    digits = strtoul(argv[1], (char **)NULL, 10);
    k = ( digits / 2 );

    if( argc == 2 ) {
        start_a = default_start_a( k );
        end_a = default_end_a( k );
    }
    else if( argc == 3 ) {
        start_a = strtoull(argv[2], (char **) NULL, 10);
        end_a = default_end_a( k );
    }
    else {
        start_a = strtoull(argv[2], (char **) NULL, 10);
        end_a = strtoull(argv[3], (char **) NULL, 10);
    }

    /* odd numbers cannot be candidates for a. Start with an even
       number and add two to check the next candidate */
    if ( start_a % 2 ) {
        start_a += 1;
    }

	printf( "*** [%d] [%u] Starting up\n", getpid(), (unsigned)time(NULL) );
	printf( "*** [%d] start a is %" PRIu64 "\n", getpid(), start_a );
    printf( "*** [%d] end a is %" PRIu64 "\n",   getpid(), end_a   );
    fflush( stdout );

    pinfo.last_a = start_a;
    pinfo.last_time = (unsigned) time(NULL);

    K = powers_of_10[ k ];

    current_iter = 0;

    for (a = start_a; a <= end_a; a += next_a[ a % 10 ]) {
        check_excellent(a, K);
        current_iter += 1;

        if ((current_iter % (iterations_per_signal_check)) == 0) {
            if( int_flag > 0 ) {
                printf( "!!! [%d] Caught interrupt\n", getpid() );
                break;
            }

            if ( usr1_flag > 0 ) {
                report_progress( &pinfo, start_a, a );
                time_left( pinfo.rate, a, end_a );
                usr1_flag = 0;
            }

            if ( alarm_flag > 0 ) {
                report_progress( &pinfo, start_a, a );
                time_left( pinfo.rate, a, end_a );
                alarm_flag = 0;
            }
        }
    }

    printf( "+++ [%d] Checked [%" PRIu64 "] to [%" PRIu64 "]\n", getpid(), start_a, a );
    fflush( stdout );

    return( 0 );
}

