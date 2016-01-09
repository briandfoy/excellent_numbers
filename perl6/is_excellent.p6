#!perl6

need ExcellentNumber;

for @*ARGS -> $candidate {
	my $rc = is_excellent( + $candidate );
	unless $rc {
		say "$candidate is not excellent";
		next;
		}

	say "$candidate is excellent";
	say "\tb = %rc->{b} => b² = %rc->{'b²'}";
	say "\ta = %rc->{a} => a² = %rc->{'a²'}";
	say "\tdiff is %rc->{diff}";
	}
