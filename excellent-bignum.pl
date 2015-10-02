#!/usr/bin/perl
use v5.20;

use bigint;

use IO::Interactive qw(interactive);
use IO::Tee;

my $digits = $ARGV[0] // 10;
die "Number of digits must be even and non-zero! You said [$digits]\n"
	unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

my $k          = ( $digits / 2 ) - 1;

open my $file, '>>:utf8', "$k excellent_numbers.txt";

my $tee = IO::Tee->new( $file, interactive() );
select $tee;

say "*** Starting run at " . localtime;
say "*** k is $k";

our $N;
$SIG{TERM} = $SIG{INT} = sub {
	print $file "\nEnded at $N\n";
	};

foreach my $n ( 10**$k .. 10**($k+1) - 1 ) {
	$N = $n;
	state $count      = 0;
	state $this_count = 0;
	state $start_time = time;
	state $this_time  = time;
	state $interval   = 10**($k-2);

	$count++;
	$this_count++;

	unless( $this_time % 1800 ) { # every half hour
		say "*** Working on $n";
		}
	unless( $n % $interval ) {
		say "*** Working on $n";
		my $overall_rate = $count / ( time - $start_time );
		say "*** Overall rate: $overall_rate / sec";

		my $this_rate    = $this_count / ( time - $this_time );
		say "*** Previous interval rate: $this_rate / sec";

		$this_count = 0;
		$this_time  = time;
		}

	my $k = length $n;
	my $front = $n*(10**$k + $n);

	my $root = int( sqrt( $front ) );

	foreach my $try ( $root - 2 .. $root + 2 ) {
		my $back = $try * ($try - 1);
		last if length($try) > $k;
		last if $back > $front;
		#say "\tn: $n back: $back try: $try front: $front";
		if( $back == $front ) {
			say "$n$try";
			last;
			}
		}
	}

__END__
*** Working on 10000000000
*** Overall rate: inf / sec
*** Previous interval rate: inf / sec
*** Working on 10100000000
*** Overall rate: 855 / sec
*** Previous interval rate: 855 / sec
*** Working on 10200000000
*** Overall rate: 868 / sec
*** Previous interval rate: 881 / sec
*** Working on 10300000000
*** Overall rate: 870 / sec
*** Previous interval rate: 876 / sec
*** Working on 10400000000
*** Overall rate: 873 / sec
*** Previous interval rate: 879 / sec
*** Working on 10500000000
*** Overall rate: 875 / sec
*** Previous interval rate: 885 / sec
*** Working on 10600000000
*** Overall rate: 877 / sec
*** Previous interval rate: 884 / sec
*** Working on 10700000000
*** Overall rate: 876 / sec
*** Previous interval rate: 876 / sec
*** Working on 10800000000
*** Overall rate: 878 / sec
*** Previous interval rate: 887 / sec
*** Working on 10900000000
*** Overall rate: 878 / sec
*** Previous interval rate: 885 / sec
*** Working on 11000000000
*** Overall rate: 879 / sec
*** Previous interval rate: 884 / sec
*** Working on 11100000000
*** Overall rate: 881 / sec
*** Previous interval rate: 896 / sec
*** Working on 11200000000
*** Overall rate: 881 / sec
*** Previous interval rate: 885 / sec
*** Working on 11300000000
*** Overall rate: 881 / sec
*** Previous interval rate: 885 / sec
*** Working on 11400000000
*** Overall rate: 881 / sec
*** Previous interval rate: 883 / sec
*** Working on 11500000000
*** Overall rate: 881 / sec
*** Previous interval rate: 878 / sec
*** Working on 11600000000
*** Overall rate: 881 / sec
*** Previous interval rate: 876 / sec
*** Working on 11700000000
*** Overall rate: 882 / sec
*** Previous interval rate: 904 / sec
*** Working on 11800000000
*** Overall rate: 882 / sec
*** Previous interval rate: 883 / sec
*** Working on 11900000000
*** Overall rate: 882 / sec
*** Previous interval rate: 883 / sec
*** Working on 12000000000
*** Overall rate: 882 / sec
*** Previous interval rate: 883 / sec
*** Working on 12100000000
*** Overall rate: 882 / sec
*** Previous interval rate: 883 / sec
*** Working on 12200000000
*** Overall rate: 882 / sec
*** Previous interval rate: 882 / sec
*** Working on 12300000000
*** Overall rate: 883 / sec
*** Previous interval rate: 905 / sec
*** Working on 12400000000
*** Overall rate: 883 / sec
*** Previous interval rate: 883 / sec
*** Working on 12500000000
*** Overall rate: 883 / sec
*** Previous interval rate: 883 / sec
*** Working on 12600000000
*** Overall rate: 883 / sec
*** Previous interval rate: 881 / sec
*** Working on 12700000000
*** Overall rate: 883 / sec
*** Previous interval rate: 879 / sec
*** Working on 12800000000
*** Overall rate: 881 / sec
*** Previous interval rate: 827 / sec
1283162072038050132225
*** Working on 12900000000
*** Overall rate: 881 / sec
*** Previous interval rate: 891 / sec
*** Working on 13000000000
*** Overall rate: 881 / sec
*** Previous interval rate: 869 / sec
*** Working on 13100000000
*** Overall rate: 881 / sec
*** Previous interval rate: 881 / sec
*** Working on 13200000000
*** Overall rate: 881 / sec
*** Previous interval rate: 874 / sec
*** Working on 13300000000
*** Overall rate: 880 / sec
*** Previous interval rate: 862 / sec
*** Working on 13400000000
*** Overall rate: 880 / sec
*** Previous interval rate: 878 / sec
*** Working on 13500000000
*** Overall rate: 881 / sec
*** Previous interval rate: 907 / sec
*** Working on 13600000000
*** Overall rate: 881 / sec
*** Previous interval rate: 886 / sec
*** Working on 13700000000
*** Overall rate: 881 / sec
*** Previous interval rate: 884 / sec
*** Working on 13800000000
*** Overall rate: 881 / sec
*** Previous interval rate: 877 / sec
1382185301039663949900
*** Working on 13900000000
*** Overall rate: 881 / sec
*** Previous interval rate: 880 / sec
*** Working on 14000000000
*** Overall rate: 881 / sec
*** Previous interval rate: 870 / sec
1401308698439970930753
