#!/Users/brian/bin/perls/perl5.22.0

use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);


my $max_a = bisect(
	sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) },
	1,
	my $threshold = 1
	);

say "max is $max_a";

sub bisect ( $sub, $k, $threshold=1 ) {
	my $k = $k + 1;

	my $b = '9' x $k;  # the largest b

	# the limits for our bisection. These will close in on the middle
	# as we test the bounds
	my $maximum = $b;
	my $minimum = '1' . ( '0' x ($k-1) );

	say "max is $maximum\nminimum is $minimum";

	# Let's start in the middle of the range
	my $try = int( ( $maximum - $minimum ) / 2 );
	say "trial is $try";

	my %Seen;
	while( 1 ) {
		my $result = $sub->( $try, $k );
		#say "Min: $minimum: Max: $maximum Try: $try Result: $result";
		say "result is $result";

		my $last_try = $try;
		$try = do {
			if( abs($result - $b) < $threshold ) {
				say "last block";
				last ;
				}
			elsif( $result > $b )    { # result is too big, make try smaller
				say "too big";
				$maximum = $try;
				int( $minimum + ( $try - $minimum ) / 2 );
				}
			elsif( $result < $b ) { # result is too small, make try bigger
				say "too small";
				$minimum = $try;
				int( ($try + ( $maximum - $try ) / 2) + 1 );
				}
			else { return $try }
			};
		last if int( $last_try ) == int( $try );
		last if $Seen{ $try }++; # stop cycles

		say "trial is $try";
		}

	# cheat a little
	return int( $try + $threshold );
	};
