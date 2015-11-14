#!/usr/bin/perl
use v5.20;
use utf8;

use FindBin;
use lib "$FindBin::Bin/../lib";

use ExcellentNumber qw(is_excellent);

my $rc = is_excellent( $ARGV[0] );

unless( $rc ) {
	say "$ARGV[0] is not excellent";
	exit;
	}

say "$ARGV[0] is excellent";

say "b = $rc->{b} => b² = $rc->{'b²'}";
say "a = $rc->{a} => a² = $rc->{'a²'}";
say "\ndiff is $rc->{diff}";
