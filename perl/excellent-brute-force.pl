#!/usr/bin/perl
use v5.10;
use strict;
use warnings;

use integer;

use Time::HiRes qw(gettimeofday tv_interval);

my $time0 = [gettimeofday];
my $old_length = 0;
my $num        = $ARGV[0] // 0; # starting point

$SIG{INT} = sub {
	say "Stopping at $num. Average ",
		eval { $num / tv_interval( $time0, [gettimeofday] ) } , " / second";
	exit;
	};

while( ++$num ) {
	my $length = length $num;

	if( $length > $old_length ) {
		say "[@{[time]}] Working on length $length => ",
			"average ",
			eval { $num / tv_interval( $time0, [gettimeofday] ) } , " / second";
		$old_length = $length;
		}

	if( $length % 2 ) {
		$num = '0' . $num;
		$length++;
		}

	my $half = $length / 2;
	my $front = substr $num, 0, $half;
	my $back  = substr $num, $half, $half;

	next if $front > $back;

	my $computed = $back**2 - $front**2;
	say "[@{[time]}] $num" if $computed == $num;
	}
