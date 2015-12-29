#!perl6

@*ARGS = ( 0 ) unless @*ARGS.elems;

my $rc = is_excellent( + @*ARGS[0] );
say "RC is $rc";

if $rc {
	say "@*ARGS[0] is excellent";
	exit;
	}
else {
	say "@*ARGS[0] is not excellent";
	exit 1;
	}

sub is_excellent ( Int:D $number ) returns Bool:D {
	# It's a bit easier to count digits as a string
	# of decimal digits
	my $string = ~ $number;
	return False unless $string.chars %% 2;

	my $a = + $string.substr( 0, $string.chars/2 );
	my $b = + $string.substr( $string.chars/2 );

	return $b**2 - $a**2 == $number;
	}
