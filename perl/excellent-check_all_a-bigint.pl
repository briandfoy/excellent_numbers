#!/Users/brian/bin/perls/perl5.20.0
use v5.20;

my $digits = $ARGV[0] // 2;
die "Number of digits must be even and non-zero! You said [$digits]\n"
	unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

my $k  = ( $digits / 2 );
my $start = 10**($k-1);

foreach my $n ( $start .. 10**($k) - 1 ) {
	say "[@{[time]}] Working on $n" unless $n % $start;
	my $front = $n*(10**$k + $n);
	my $root = int( sqrt( $front ) );

	foreach my $try ( $root - 2 .. $root + 2 ) {
		my $back = $try * ($try - 1);
		last if length($try) > $k;
		last if $back > $front;
		if( $back == $front ) {
			say "$n$try";
			last;
			}
		}
	}

