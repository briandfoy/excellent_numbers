#!/Users/brian/bin/perls/perl5.22.0

use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);

use bigint;

foreach my $k ( 1 .. 25 ) {
	my $max_a = bisect(
		$k+1,
		sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) },
		my $threshold = 1
		);

	say sprintf "%2d -> %s", $k, $max_a;
	}

# This is really sloppy, but I only have to run it once
sub bisect ( $k, $sub, $threshold=1 ) {
	my $b = '9' x $k;  # the largest b

	# the limits for our bisection. These will close in on the middle
	# as we test the bounds
	my $maximum = $b;
	my $minimum = '1' . ( '0' x ($k-1) );

	# Let's start in the middle of the range
	my $try = int( ( $maximum - $minimum ) / 2 );

	my %Seen;
	while( 1 ) {
		my $result = $sub->( $try, $k );
		#say "Min: $minimum: Max: $maximum Try: $try Result: $result";

		my $last_try = $try;
		$try = do {
			if( abs($result - $b) < $threshold ) {
				#say "last block";
				last ;
				}
			elsif( $result > $b )    { # result is too big, make try smaller
				#say "too big";
				$maximum = $try;
				int( $minimum + ( $try - $minimum ) / 2 );
				}
			elsif( $result < $b ) { # result is too small, make try bigger
				#say "too small";
				$minimum = $try;
				int( ($try + ( $maximum - $try ) / 2) + 1 );
				}
			else { return $try }
			};
		last if int( $last_try ) == int( $try );
		last if $Seen{ $try }++; # stop cycles

		#say "next try $try";
		}

	# cheat a little
	return int( $try + $threshold );
	};
