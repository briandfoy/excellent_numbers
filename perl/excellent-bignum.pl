#!perl
package ExcellentNumbers;

use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);

# maybe we should conditionally load this based on the number's size
use bigint try => 'GMP';


__PACKAGE__->run( @ARGV ) unless caller;

sub new ( $class, @args ) {
	my( $digits, $start, $end ) = @args;

	die "Number of digits must be even and non-zero! You said [$digits]\n"
		unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

	my $self = bless {
		digits      => $digits,
		args        => [ @args ],
		}, $class;

	$self->setup_logging;
	$self->setup_twitter;
	$self->get_start( $start );
	$self->get_end( $end );

	$self;
	}

sub digits      ( $self ) { $self->{digits} }
sub start       ( $self ) { $self->{start} }
sub end         ( $self ) { $self->{end} }
sub half_digits ( $self ) { $self->{half_digits} //= $self->digits / 2 }
sub k           ( $self ) { $self->{k} //= $self->half_digits - 1 }

sub logger   ( $self, $message ) { $self->{logger}->( $message ) }
sub reporter ( $self, $message ) { $self->{reporter}->( $message ) }
sub twitter  ( $self  )          { $self->{twitter} }

sub get_start ( $self, $start ) {
	# if they specify a big number, that's a literal number we need
	# to break up to get the first half
	$self->{start} = do {
		if( defined $start ) {
			$start =~ s/_//g;

			die "$start doesn't look like a number!\n" if $start =~ /\D/;
			die "$start should be " . $self->half_digits . " digits but is " . length($start) . " digits\n"
				unless length $start eq $self->half_digits;
			$start;
			}
		# Otherwise we assume it's a number of digits in the final number
		else { 10**$self->k }
		};
	};

sub get_end ( $self, $end ) {
	# if they specify a third number, that's a literal number we need
	# to break up to get the first half
	$self->{end} = do {
		if( defined $end ) {
			$end =~ s/_//g;

			die "$end doesn't look like a number!\n" if $end =~ /\D/;
			die "$end should be " . $self->half_digits . " digits but is " . length($end) . " digits\n"
				unless length $end eq $self->half_digits;
			$end;
			}
		# Otherwise we find the maximum a in this range
		else {
			# find the $max_a by trying things until we get a good one
			my $max_a = $self->bisect(
				sub ( $a, $k ) { sqrt( $a * 10 **($k) + $a**2 ) },
				my $threshold = 1
				);
			$self->logger( "largest is $max_a" );
			$max_a;
			}
		};
	}

sub run ( $class, @args ) {
	my $thingy = $class->new( @args );

	$thingy->logger( "Starting run at " . localtime );
	$thingy->logger( "PID is $$" );
	$thingy->logger( "k is " . $thingy->k );

	$thingy->test_range;
	}

sub test_range ( $self, $Report_threshold=300 ) {
	$self->logger( $self->start . '..' . $self->end );

	our $N;
	local $SIG{TERM} = local $SIG{INT} = sub { $self->logger( "Ended at $N" ); exit };

	my $k2 = length $self->start;
	my $ten_k2 = 10**$k2;
	my $end = $self->end;

	foreach my $a ( $self->start .. $end ) {
		# see the modulo stuff. a can only end in these digits
		next unless $a =~ m/[0468]\z/;

		$N = $a;

		my $time = time;
		state $Reported = {};
		state $last_a = $a;
		unless( $time % $Report_threshold or $Reported->{$time}++ ) {
			my $rate = int( ( $a - $last_a ) / $Report_threshold );
			my $left = $end - $a;
			my $time_left = $left / $rate;
			my $compound_duration = $self->compound_duration( $time_left );

			$self->logger( "Working on $a => rate is $rate / s => time left $compound_duration" );
			$last_a = $a;
			}

		my $front = $a*( $ten_k2 + $a);

		my $root = int( sqrt( $front ) );

		my %Tried;
		while( 1 ) {
			last if $Tried{$root}++;
			#say "*** [$a] Trying root $root";
			my $back = $root * ( $root - 1 );
			   if( $back < $front       ) { $root++; redo }
			elsif( $back > $front       ) { $root--; redo }
			else                          {
				$self->reporter( "$a$root" );
				eval { $self->twitter->update( "$a$root is excellent" ) } if $self->twitter;
				last;
				}
			}

		}
	}

# This is really sloppy, but I only have to run it once
sub bisect ( $self, $sub, $threshold=1 ) {
	my $k = $self->k + 1;

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

# http://rosettacode.org/wiki/Convert_seconds_to_compound_duration#Perl
sub compound_duration ( $self, $sec ) {
    no warnings 'numeric';

    return join ', ', grep { $_ > 0 }
        int($sec/60/60/24/7)    . " wk",
        int($sec/60/60/24) % 7  . " d",
        int($sec/60/60)    % 24 . " hr",
        int($sec/60)       % 60 . " min",
        int($sec)          % 60 . " sec";
	}

sub setup_twitter ( $self ) {
	$self->{twitter} = eval {
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
		$self->logger( "Could not setup Net::Twitter, so I won't post there: $@" );
		();
		};
	}

sub setup_logging ( $self ) {
	require IO::Interactive;
	require IO::Tee;

	my $digits = $self->digits;

	my $filename = "excellent_numbers-$digits-$$-@{[time]}.txt";
	open my $file, '>>:utf8', $filename
		or die "Could not open [$filename]: $!\n";
	$file->autoflush(1);

	my $tee = IO::Tee->new( $file, IO::Interactive::interactive() );
	$self->{logger}   = sub ( $message ) { say { $tee } "*** $message" };
	$self->{reporter} = sub ( $number )  { say { $tee } $number };
	};

__END__

=encoding utf8

=pod

A number I<ab> is excellent if the difference I<b²> - I<a²> is the
number I<ab> again, where I<a> and I<b> have an equal number of
digits. For instance, 48 is 8² - 4².

I can rewrite I<ab> to separate the halves of numbers. Here, I<k> is
the order of magnitude of half the number (or, one less than the count
of digits, e.g. for 3648 I<k> is 2 because 36 is really 36*10^2):

	b² - a² = a 10**k + b            (1)

Rearranging to get the same letters on the same side:

	b² - b = a 10**k + a²            (2)

Or,

	b (b - 1) = a (10**k + a )       (3)

Now, for sufficiently large numbers, I<b (b - 1)> is almost I<b²>. In
that case, I<b> would be the I<√ a (10**k + a )>. Checking around that
root by a few numbers verifies the excellent number.

There's a maximum I<a> that I have to check since beyond that value
there's not a I<b> large enough to get back a number with the right
number of digits. I can find that by setting I<b> to its maximum value (all 9s)
and solving (2) for I<a>. The maximum I<a> starts right around the
numbers that start with 6. This cuts out roughly 40% of the range of
numbers of that length.

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
6 }. This means that I can skip all I<a> that are { 1, 2, 3, 5, 7,
9 }. That's 60% of the candidates!


=cut
