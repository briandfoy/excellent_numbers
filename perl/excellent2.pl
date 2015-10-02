#!/usr/bin/perl
use v5.20;
use feature qw(postderef);
no warnings qw(experimental::postderef);
use DBM::Deep;

my $file = 'excellent.db';
unlink $file;
my $pairs = DBM::Deep->new( $file );

my $digits = $ARGV[0] // 10;
die "Number of digits must be even and non-zero! You said [$digits]\n"
	unless( $digits > 0 and $digits % 2 == 0 and int($digits) eq $digits );

my $k  = ( $digits / 2 ) - 1;

foreach my $n ( 10**$k .. 10**($k+1) - 1 ) {
	my $k = length $n;
	my $front = $n*(10**$k + $n);
	my $back  = $n**2 - $n;

	push @{ $pairs->{ $front } }, $n;
	push @{ $pairs->{ $back } }, $n;
	}

while( my( $key, $value ) = each %$pairs ) {
	# skip everything that doesn't have a partner
	next unless @$value == 2;

	my( $front, $back ) = sort { $a <=> $b }  $value->@*;
	say "$front$back";
	}


