#!/usr/bin/perl
use v5.20;
use utf8;
use open qw(:std :utf8);

use feature qw(signatures);
no warnings qw(experimental::signatures);
use bigint;

package ExcellentNumber {
	use Exporter qw( import );
	our @EXPORT_OK = qw( is_excellent );

	sub is_excellent ( $number ) {
		my $length = length $number;
		my $k      = $length - 1;

		if( $length % 2 ) {
			warn "odd number of digits ($length) is not excellent!\n";
			return;
			}

		my( $a, $b ) = map { substr $number, $_->[0], $_->[1] } (
			[ 0, $length / 2 ],
			[ $length / 2, $length / 2 ]
			);

		my $a2 = $a ** 2;
		my $b2 = $b ** 2;

		my $diff = $b2 - $a2;

		return unless $number == $diff;

		return {
			a => $a,
			b => $b,
			'a²' => $a2,
			'b²' => $b2,
			diff => $diff,
			};
		}


	}

1;
