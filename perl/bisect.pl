#!/Users/brian/bin/perls/perl5.22.0 -s

use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);
use vars qw($d);
use bigint;


say "const uint64_t stop_a[] = {\n\t0,";

foreach my $k ( 1 .. 18 ) {
	my $max_a = bisect(
		sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) },
		$k,
		my $threshold = 1
		);

	say "\t${max_a}LL,";
	}

say "};";

sub bisect ( $sub, $k, $threshold=1 ) {
	my $k = $k + 1;

	my $b = '9' x $k;  # the largest b

	# the limits for our bisection. These will close in on the middle
	# as we test the bounds
	my $maximum = $b;
	my $minimum = '1' . ( '0' x ($k-1) );

	say "\tmax is $maximum\nminimum is $minimum" if $d;

	# Let's start in the middle of the range
	my $try = int( ( $maximum - $minimum ) / 2 );
	say "\ttrial is $try" if $d;

	my %Seen;
	while( 1 ) {
		my $result = $sub->( $try, $k );
		#say "Min: $minimum: Max: $maximum Try: $try Result: $result";
		say "\tresult is $result" if $d;

		my $last_try = $try;
		$try = do {
			if( abs($result - $b) < $threshold ) {
				say "\tlast block" if $d;
				last ;
				}
			elsif( $result > $b )    { # result is too big, make try smaller
				say "\ttoo big" if $d;
				$maximum = $try;
				int( $minimum + ( $try - $minimum ) / 2 );
				}
			elsif( $result < $b ) { # result is too small, make try bigger
				say "\ttoo small" if $d;
				$minimum = $try;
				int( ($try + ( $maximum - $try ) / 2) + 1 );
				}
			else { return $try }
			};
		last if int( $last_try ) == int( $try );
		last if $Seen{ $try }++; # stop cycles

		say "\ttrial is $try" if $d;
		}

	# cheat a little
	return int( $try + $threshold );
	};
