#!/Users/brian/bin/perls/perl5.20.0
use v5.20;

use Math::BigInt lib => 'Calc';

my $digits = $ARGV[0] // 2;
die "Number of digits must be even and non-zero! You said [$digits]\n"
	unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

my $k  = ( $digits / 2 );

my $base = Math::BigInt->new( 10 );

foreach my $a ( $base**($k-1) .. $base**($k) - 1 ) {
	my $front = $a*(10**$k + $a);
	my $root = int( sqrt( $front ) );

	foreach my $b ( $root - 2 .. $root + 2 ) {
		my $back = $b * ($b - 1);
		last if length($b) > $k;
		last if $back > $front;
		# say "\tn: $a back: $back try: $b front: $front";
		if( $back == $front ) {
			say "$a$b";
			last;
			}
		}
	}

