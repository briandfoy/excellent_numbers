#!perl6
use v5.22;

use feature qw(signatures);
no warnings qw(experimental::signatures);

use bigint;

my $end = $ARGV[0] // 6;

foreach my $n ( 0 .. $end ) {
	my $N = 6*($n+1);
	say "$N: $n -> ", make_number( $n );
	}

sub make_number ($n) {
	# this works around a bigint bug
	# string replication with 0 returns the empty string
	# but that empty string doesn't turn into 0
	my $n3 = +('3'x($n));
	$n3 = 0 if( $n3 eq 'NaN' or $n3 eq '');

	my $number =
		10**0        * ('3'x($n+1))   +
		10**($n+1)   * 1              +

		10**(2*$n+2) * 5              +
		10**(2*$n+3) * ('6'x(2*$n+1)) +
		10**(4*$n+4) * 1              +
		10**(5*$n+5) * 2              +
		10**(5*$n+6) * $n3            +
		0;
	}

__END__
320166650133
