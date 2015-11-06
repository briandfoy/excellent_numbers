#!perl
use v5.10;
use utf8;
use open qw(:std :utf8);

use warnings;
use strict;

use bigint;

use Test::More 0.98;

my $file = $ARGV[0] // 'excellent.txt';

open my $fh, '<:utf8', $file or die "Could not open $file: $!\n";

while( <$fh> ) {
	chomp;
	next unless /\A\d/;

	is_excellent( $_ );
	}

sub is_excellent {
	my( $number ) = @_;
	my $label = "$number is excellent";
	my $length = length $number;
	my $k      = $length - 1;

	if( $length % 2 ) {
		diag "odd number of digits ($length) disallowed [$number]!";
		fail( $label );
		return;
		}


	my( $a, $b ) = map { substr $number, $_->[0], $_->[1] } (
		[ 0, $length / 2 ],
		[ $length / 2, $length / 2 ]
		);

	my $a2 = $a ** 2;
	my $b2 = $b ** 2;

	my $diff = $b2 - $a2;

	diag "\tb = $b => b² = $b2";
	diag "\ta = $a => a² = $a2";
	diag "\tdiff is $diff";

	$number == $diff ?
		pass( $label )
			:
		fail( $label ) ;
	}

done_testing();
