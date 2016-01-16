#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <unistd.h>

#include "excellent.h"

const excellent_half_t powers_of_10[] = {
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

const uint8_t MAX_NDIGITS = 2 * ((sizeof powers_of_10)/(sizeof powers_of_10[0]));

/*
   a has to end in 0, 4, or 6. Instead of incrementing by 2 and
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

volatile sig_atomic_t ALARM_RAISED = 0;
volatile sig_atomic_t INT_RAISED  = 0;
volatile sig_atomic_t USR1_RAISED = 0;

const uint16_t MAX_MINUTES_BETWEEN_PROGRESS_REPORTS = 43800; /* one month */
const uint8_t MAX_SECONDS_BETWEEN_SIGNAL_CHECKS = 10; /* some semblance of responsivness */

const excellent_half_t RATE_GUESS = 100000000LL;

int main(int argc, char **argv) {
    excellent_info_t info;
    excellent_opt_t opt;

    process_options(argc, argv, &opt);

    setup_alarm();
    setup_int();
    setup_usr1();

    alarm(opt.minutes_between_progress_reports * SECONDS_PER_MINUTE);

    search_excellent_numbers(&info, &opt);

    return 0;
}

void
search_excellent_numbers(
        excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    excellent_half_t a;
    excellent_half_t current_iter, iterations_per_signal_check;

    const excellent_half_t start_a = opt->start_a;
    const excellent_half_t end_a = opt->end_a;
    const excellent_half_t K = initialize_K( opt );

    info->last_a = opt->start_a;
    info->rate = RATE_GUESS;

    print_startup_report(info, opt);

    current_iter = 0;
    iterations_per_signal_check = info->rate * opt->seconds_between_signal_checks;

    for (a = start_a; a <= end_a; a += next_a[ a % 10 ]) {

        check_excellent(a, K);
        current_iter += 1;

        if (current_iter == iterations_per_signal_check) {
            if (ALARM_RAISED > 0) {
                handle_alarm(a, info, opt);
            }
            if (USR1_RAISED > 0) {
                handle_usr1(a, info, opt);
            }
            if (INT_RAISED > 0) {
                handle_int(a, info, opt);
                break;
            }
            current_iter = 0;
            iterations_per_signal_check = info->rate *
                opt->seconds_between_signal_checks;
        }
    }

    print_termination_report(start_a, a);
    return;
}

void
print_startup_report(excellent_info_t *info, const excellent_opt_t *opt) {
    time( & (info->last_time) );

    printf( "*** [%d] [%s] Starting up\n",              getpid(), timestamp(info->last_time) );
    printf( "*** [%d] start a is %" EXCELLENT_FMT "\n", getpid(), opt->start_a );
    printf( "*** [%d] end a is %" EXCELLENT_FMT "\n",   getpid(), opt->end_a );
    printf( "*** [%d] report interval is %u\n",         getpid(), opt->minutes_between_progress_reports );
    printf( "*** [%d] signal check interval is %u\n",   getpid(), opt->seconds_between_signal_checks );
    fflush( stdout );
    return;
}

void
print_termination_report(excellent_half_t start_a, excellent_half_t a) {
    printf(
        "+++ [%d] [%u] Checked [%" EXCELLENT_FMT "] to [%" EXCELLENT_FMT "]\n",
        getpid(),  (unsigned) time(NULL), start_a, a);
    fflush( stdout );
    return;
}

const char *
timestamp(const time_t timer) {
    static char buffer[26] = { 0 };
    struct tm* tm_info = gmtime(&timer);
    strftime(buffer, 26, "%Y-%m-%dT%H:%M:%S-00:00", tm_info);
    return buffer;
}

excellent_full_t
multiply_halves(
        const excellent_half_t x,
        const excellent_half_t y
        ) {
    excellent_full_t z = ((excellent_full_t) x) * ((excellent_full_t) y);
    return z;
}

void
print_excellent_number(
        const excellent_half_t a,
        const excellent_half_t b
        ) {
    printf("%" EXCELLENT_FMT "%" EXCELLENT_FMT " is excellent\n", a, b);
    fflush( stdout );
    return;
}

void
report_progress(
        const excellent_half_t a,
        excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    excellent_half_t numbers_done = a - info->last_a;
    time_t this_time = time( NULL );

    info->rate = ((excellent_float_t) numbers_done) / (this_time - info->last_time);

    printf( "+++ [%d] Checked [%" EXCELLENT_FMT "] to [%" EXCELLENT_FMT "]\n", getpid(), opt->start_a, a );
    printf( "*** [%d] [%s] working on: %" EXCELLENT_FMT " tried: %" EXCELLENT_FMT " rate: %" EXCELLENT_FMT " / sec\n",
            getpid(), timestamp( this_time ), a, numbers_done, info->rate );
    fflush( stdout );
    info->last_time = this_time;
    info->last_a = a;

    time_left(a, info, opt);

    return;
}

void
time_left(
        const excellent_half_t a,
        const excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    uint64_t seconds_left;
    uint8_t weeks, days, hours, minutes, seconds;

    excellent_half_t left_a = opt->end_a - a;
    seconds_left = 1 + ((double) left_a) / info->rate;

    weeks   = seconds_left / SECONDS_PER_WEEK;
    days    = ( seconds_left / SECONDS_PER_DAY ) % 7;
    hours   = ( seconds_left / SECONDS_PER_HOUR ) % 24;
    minutes = ( seconds_left / SECONDS_PER_MINUTE ) % 60;
    seconds = seconds_left - (
            weeks * SECONDS_PER_WEEK +
            days * SECONDS_PER_DAY +
            hours * SECONDS_PER_HOUR +
            minutes * SECONDS_PER_MINUTE
            );

    printf( "*** [%d] time left: %u wk %u d %u h %u m %u s\n",
            getpid(), weeks, days, hours, minutes, seconds );
    fflush( stdout );

    return;
}

void
process_options(int argc, char **argv, excellent_opt_t *opt) {
    int c;
    opterr = 0;

    opt->start_a = 0;
    opt->end_a = 0;
    opt->minutes_between_progress_reports = 15;
    opt->seconds_between_signal_checks = 2;
    opt->ndigits = 8;

    /*
     * -b : start_a
     * -e : end_a
     * -r : minutes between progress reports
     * -s : seconds between signal checks
     */

    while ((c = getopt(argc, argv, "+b:d:e:r:s:h")) != -1) {
        switch ( c ) {
            case 'b' :
                opt->start_a = strtoull(optarg, (char **) NULL, 10);
                break;
            case 'd' :
                opt->ndigits = atoi(optarg);
                break;
            case 'e' :
                opt->end_a = strtoull(optarg, (char **) NULL, 10);
                break;
            case 'r' :
                opt->minutes_between_progress_reports = atoi( optarg );
                break;
            case 's' :
                opt->seconds_between_signal_checks = atoi( optarg );
                break;
            case '?' :
            case 'h' :
            default  :
                print_usage_and_exit();
                break;
        }

    }

    if ( opt->ndigits > MAX_NDIGITS ) {
        opt->ndigits = MAX_NDIGITS;
    }

    if ( opt->start_a == 0) {
        opt->start_a = default_start_a( opt->ndigits );
    }

    if ( opt->end_a == 0) {
        opt->end_a = default_end_a (opt->ndigits );
    }

    if ( opt->minutes_between_progress_reports >
            MAX_MINUTES_BETWEEN_PROGRESS_REPORTS ) {
        opt->minutes_between_progress_reports =
            MAX_MINUTES_BETWEEN_PROGRESS_REPORTS;
    }

    if ( opt->seconds_between_signal_checks >
            MAX_SECONDS_BETWEEN_SIGNAL_CHECKS ) {
        opt->seconds_between_signal_checks =
            MAX_SECONDS_BETWEEN_SIGNAL_CHECKS;
    }

    return;
}

void
handle_alarm(
        const excellent_half_t a,
        excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    report_progress(a, info, opt);
    ALARM_RAISED = 0;
    alarm(opt->minutes_between_progress_reports * SECONDS_PER_MINUTE);
    return;
}

void
handle_int(
        const excellent_half_t a,
        excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    printf( "!!! [%d] [%u] Caught interrupt\n",
            getpid(),  (unsigned)time(NULL)
          );
    INT_RAISED = 0;
    return;
}

void
handle_usr1(
        const excellent_half_t a,
        excellent_info_t *info,
        const excellent_opt_t *opt
        ) {
    report_progress(a, info, opt);
    USR1_RAISED = 0;
    return;
}
void
alarm_raised( int signo ) {
    ALARM_RAISED += 1;
}

void
int_raised( int signo ) {
    INT_RAISED += 1;
}

void
usr1_raised( int signo ) {
    USR1_RAISED += 1;
}

void
setup_alarm( void ) {
    struct sigaction act;
    act.sa_handler = alarm_raised;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    if ( sigaction(SIGALRM, &act, NULL) == -1 ) {
        perror( "sigaction couldn't install SIGALRM" );
    }
}

void
setup_int( void ) {
    struct sigaction act;
    act.sa_handler = int_raised;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    if( sigaction(SIGINT, &act, NULL) == -1 ) {
        perror( "sigaction couldn't install SIGINT" );
    }
}

void
setup_usr1( void ) {
    struct sigaction act;
    act.sa_handler = usr1_raised;
    sigemptyset(&act.sa_mask);
    act.sa_flags = 0;
    if( sigaction(SIGUSR1, &act, NULL) == -1 ) {
        perror( "sigaction couldn't install SIGUSR1" );
    }
}

void
print_usage_and_exit( void ) {
    fputs(
            "Arguments:\n"
            "\t-d : number of digits\n"
            "\t-b : start_a\n"
            "\t-e : end_a\n"
            "\t-r : minutes between progress reports\n"
            "\t-s : seconds between signal checks\n"
            "\t-h : show this message\n",
            stderr
         );
    exit( EXIT_FAILURE );
}

excellent_half_t
default_start_a( uint8_t d ) {
    return powers_of_10[ (d / 2) - 1 ];
}

/*
 * given a, we have:
 * b = 0.5 + sqrt(.25 + a**2 + a10**K)
 * b < K must hold. Use this to find a(K)
 */

excellent_half_t
default_end_a( uint8_t d ) {
    excellent_float_t K = powers_of_10[ d / 2 ];
    excellent_half_t a = 1 + K * (sqrt(5 - 4/K) - 1);
    return a / 2;
}

uint8_t
get_next_a( excellent_half_t a ) {
    return next_a[ a % 10 ];
}

excellent_half_t
initialize_K(const excellent_opt_t *opt) {
    return powers_of_10[ opt->ndigits / 2 ];
}

void
check_excellent(excellent_half_t a, excellent_half_t K) {
    excellent_full_t rhs = multiply_halves(a, a) + multiply_halves(a, K);
    excellent_half_t b = 1 +
        EXCELLENT_SQRT((excellent_float_t) a) *
        EXCELLENT_SQRT((excellent_float_t) (a + K))
    ;

    if ( rhs == multiply_halves(b, b - 1) ) {
        print_excellent_number(a, b);
    }

    return;
}


