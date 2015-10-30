#!/usr/bin/perl
use v5.20;
use utf8;
use open qw(:std :utf8);

use bigint;

my $number = $ARGV[0];

my $length = length $number;
my $k      = $length - 1;

if( $length % 2 ) {
	die "odd number of digits ($length) disallowed!";
	}


my( $a, $b ) = map { substr $number, $_->[0], $_->[1] } (
	[ 0, $length / 2 ],
	[ $length / 2, $length / 2 ]
	);

my $a2 = $a ** 2;
my $b2 = $b ** 2;

my $diff = $b2 - $a2;

say "b = $b => b² = $b2";
say "a = $a => a² = $a2";
say "\ndiff is $diff";

my $insert = $number == $diff ? '' : 'not ';
say "\n$number is ${insert}excellent";
