#!perl
use v5.10;

use ExcellentNumber qw(is_excellent);

while( <> ) {
	chomp;
	say "Candidate is $_";
	my $rc = is_excellent( $_ );
	unless( $rc ) {
		say "$_ is not excellent";
		push @errors, [ $_, $. ];
		next;
		}

	say "$_ is excellent";
	say "\tb = $rc.{'b'} => b² = $rc.{'b²'}";
	say "\ta = $rc.{'a'} => a² = $rc.{'a²'}";
	say "\tdiff is $rc.{'diff'}";
	}

say '-' x 30 if @errors;

foreach my $error ( @errors ) {
	say "$error->[1] : $error->[0] is not excellent";
	}
