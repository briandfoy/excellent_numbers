#!/usr/bin/perl
use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);

# maybe we should conditionally load this based on the number's size
use bigint;

use IO::Interactive qw(interactive);
use IO::Tee;

my $nt = eval {
	die 'NO_TWITTER set to true' if $ENV{NO_TWITTER};
	require Net::Twitter;
	my $nt = Net::Twitter->new(
		traits   => [qw/API::RESTv1_1/],
		consumer_key        => $ENV{TWITTER_CONSUMER_KEY},
		consumer_secret     => $ENV{TWITTER_CONSUMER_SECRET},
		access_token        => $ENV{TWITTER_TOKEN},
		access_token_secret => $ENV{TWITTER_TOKEN_SECRET},
		);
	} || do {
	say "*** Could not setup Net::Twitter, so I won't post there: $@";
	();
	};

my $digits = $ARGV[0] // 10;
die "Number of digits must be even and non-zero! You said [$digits]\n"
	unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

my $k          = ( $digits / 2 ) - 1;

open my $file, '>>:utf8', "excellent_numbers-k$k-$$-@{[time]}.txt";

my $tee = IO::Tee->new( $file, interactive() );
select $tee;

say "*** Starting run at " . localtime;
say "*** PID is $$";
say "*** k is $k";

our $N;
$SIG{TERM} = $SIG{INT} = sub {
	print $file "\nEnded at $N\n";
	exit;
	};

my $start = do {
	# if they specify a big number, that's a literal number we need
	# to break up to get the first half
	if( defined $ARGV[1] ) {
		$ARGV[1] =~ s/_//g;

		die "$ARGV[1] doesn't look like a number!\n" if $ARGV[1] =~ /\D/;
		die "$ARGV[1] should be $half_digits digits but is " . length($ARGV[1]) . " digits\n"
			unless length $ARGV[1] eq $half_digits;
		$ARGV[1];
		}
	# Otherwise we assume it's a number of digits in the final number
	else { 10**$k }
	};

my $end = do {
	# if they specify a third number, that's a literal number we need
	# to break up to get the first half
	if( defined $ARGV[2] ) {
		$ARGV[2] =~ s/_//g;

		die "$ARGV[2] doesn't look like a number!\n" if $ARGV[2] =~ /\D/;
		die "$ARGV[2] should be $half_digits digits but is " . length($ARGV[2]) . " digits\n"
			unless length $ARGV[2] eq $half_digits;
		$ARGV[2];
		}
	# Otherwise we find the maximum a in this range
	else {
		# find the $max_a by trying things until we get a good one
		my $max_a = bisect(
			$k+1,
			sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) },
			my $threshold = 1
			);
		say "*** largest is $max_a";
		$max_a;
		}
	};

=encoding utf8

=pod

A number I<ab> is excellent if I<b²> - I<a²> is the number I<ab>,
where I<a> and I<b> have an equal number of digits. For instance, 48
is 8² - 4².

I can rewrite I<ab> to separate the halves of numbers. Here, I<k> is
the order of magnitude of half the number (or, one less than the count
of digits, e.g. for 1,000 I<k> is 3):

	b² - a² = a 10**k + b            (1)

Rearranging to get the same letters on the same side:

	b² - b = a 10**k + a²            (2)

Or,

	b (b - 1) = a (10**k + a )       (3)

Now, for sufficiently large numbers, I<b (b - 1)> is almost I<b²>. In
that case, I<b> would be the I<√ a (10**k + a )>. Checking around that
root by a few numbers verifies the excellent number.

There's a maximum I<a> that we have to check since beyond that value
there's not enough left over to subtract from the maximum square of
I<b> to get back a number with the right number of digits. I can find
that by setting I<b> to its maximum value and solving (2) for I<a>.
The maximum I<a> starts right around the numbers that start with 6.
This cuts out roughly 40% of the range of numbers of that length.

=cut
There are other limitations on I<a> that Joe Zbiciak elucidated. It
only works with numbers that end with {0, 4, 6} as a quirk of squares.
If we only care about the last digit, then we take everything mod 10.
That means I lose the I<10**k> term because that's always evenly
divisible by 10:

	b*b - a*a = b (mod 10)           (4)

Rearranging as I did in (2), I get:

    b*b - b = a*a (mod 10)           (5)

But a square number (mod 10) can only end in { 0, 1, 4, 5, 6, 9 }, so
any I<a²> ending in { 2, 3, 7, 8 } is not a candidate.

But I<b*b – b> (mod 10) must also end in { 0, 1, 4, 5, 6, 9 } because
it's the same number. If we take some I<b> (mod 10) and compute
I<b*b – b> (mod 10), only values of I<b> ending in { 0, 6 } work:

	0*0 - 0 = 0  works
	1*1 - 1 = 0  works
	2*2 - 2 = 2  doesn't work
	3*3 - 3 = 6  works
	4*4 - 4 = 2  doesn't work
	5*5 - 5 = 0  works
	6*6 - 6 = 0  works
	7*7 - 7 = 2  doesn't work
	8*8 - 8 = 6  works
	9*9 - 9 = 2  doesn't work

The I<b> side will only produce values ending in { 0, 6 }, and the
only values of I<a> that will produce { 0, 6 } as a square are { 0, 4,
6, 8 }. This means that I can skip all I<a> that are { 1, 2, 3, 5, 7,
9 }. That's 60% of the candidates!



say "*** $start .. $end";

my $Report_threshold = 300;

my $k2 = length $start;
foreach my $a ( $start .. $end ) {
	$N = $a;
	# see the modulo stuff. a can only end in these digits;
	next unless $a =~ m/[0468]\z/;


	my $time = time;
	state $Reported = {};
	unless( $time % $Report_threshold or $Reported->{$time}++ ) {
		say "*** Working on $a";
		}

	my $front = $a*(10**$k2 + $a);

	my $root = int( sqrt( $front ) );

	my %Tried;
	while( 1 ) {
		last if $Tried{$root}++;
		#say "*** [$a] Trying root $root";
		my $back = $root * ( $root - 1 );
		   if( $back < $front       ) { $root++; redo }
		elsif( $back > $front       ) { $root--; redo }
		else                          {
			say "$a$root";
			eval { $nt->update( "$a$root is excellent" ) } if $nt;
			last;
			}
		}

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

__END__
