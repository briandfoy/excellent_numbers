#ifndef EXCELLENT_H_INCLUDED

#include <inttypes.h>
#include <stdint.h>
#include <signal.h>
#include <time.h>

typedef uint64_t excellent_half_t;
typedef unsigned __int128 excellent_full_t;
typedef long double excellent_float_t;

#define EXCELLENT_SQRT sqrtl
#define EXCELLENT_FMT PRIu64

#define SECONDS_PER_MINUTE (60)
#define SECONDS_PER_HOUR   (60 * SECONDS_PER_MINUTE)
#define SECONDS_PER_DAY    (24 * SECONDS_PER_HOUR)
#define SECONDS_PER_WEEK   ( 7 * SECONDS_PER_DAY)

struct excellent_opt {
    excellent_half_t start_a;
    excellent_half_t end_a;
    uint16_t minutes_between_progress_reports;
    uint8_t seconds_between_signal_checks;
    uint8_t ndigits;
};

struct excellent_info {
    excellent_half_t last_a;
    excellent_half_t rate;
    time_t last_time;
};

typedef struct excellent_info excellent_info_t;
typedef struct excellent_opt excellent_opt_t;

/* global variables */

extern volatile sig_atomic_t ALARM_RAISED;
extern volatile sig_atomic_t INT_RAISED;
extern volatile sig_atomic_t USR1_RAISED;

extern const excellent_half_t RATE_GUESS;

extern const uint16_t MAX_MINUTES_BETWEEN_PROGRESS_REPORTS;
extern const uint8_t MAX_SECONDS_BETWEEN_SIGNAL_CHECKS;

extern const uint8_t MAX_NDIGITS;

/* function prototypes */

void print_usage_and_exit( void );
void process_options(int, char **, excellent_opt_t *);

void alarm_raised( int );
void int_raised( int );
void usr1_raised( int );

void setup_alarm( void );
void setup_int( void );
void setup_usr1( void );

void handle_alarm(
        const excellent_half_t,
        excellent_info_t *,
        const excellent_opt_t *
        );

void handle_int(
        const excellent_half_t,
        excellent_info_t *,
        const excellent_opt_t *
        );

void handle_usr1(
        const excellent_half_t,
        excellent_info_t *,
        const excellent_opt_t *
        );

void report_progress(
        const excellent_half_t,
        excellent_info_t *,
        const excellent_opt_t *
        );

void time_left(
        const excellent_half_t,
        const excellent_info_t *,
        const excellent_opt_t *
        );


void search_excellent_numbers(
        excellent_info_t *,
        const excellent_opt_t *
        );

excellent_half_t default_start_a( uint8_t );
excellent_half_t default_end_a( uint8_t );
excellent_half_t get_K( uint8_t );

excellent_full_t multiply_halves(
        const excellent_half_t,
        const excellent_half_t
        );

uint8_t get_next_a( excellent_half_t );

void check_excellent(
        const excellent_half_t,
        const excellent_half_t
        );

void print_excellent_number(
        const excellent_half_t,
        const excellent_half_t
        );

void print_startup_report(excellent_info_t *, const excellent_opt_t *);
void print_termination_report(excellent_half_t, excellent_half_t);

const char *timestamp(time_t);

#define EXCELLENT_H_INCLUDED
#endif
