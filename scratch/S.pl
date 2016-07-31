#!/Users/brian/bin/perls/perl5.24.0

use v5.24;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use List::Util qw(sum);
use bigint;

foreach my $n ( 0 .. 4 ) {
	my $s = S($n);
	say "n = $n";
	say "\t a = ", my $a = a($n);
	say "\t b = ", my $b = b($n);
	say "\tab = ", $a*(3*S($n)+1)**3 + $b;
	say "\t     ", 81 * (S($n)**5) * (3*S($n)+2);
	say '';
	}


sub S ( $n ) {
	3 * sum map { 10**$_ } 0 .. $n
	}

sub a ( $n ) {
	( S($n) - 1 ) * ( 3*S($n) + 1 )**2 + ( 3*S($n) + 1 ) + 2*S($n);
	}

sub b ( $n ) {
	( 2*S($n) - 1 ) * ( 3*S($n) + 1 )**2 + ( 3*S($n) + 1 ) + S($n);
	}
