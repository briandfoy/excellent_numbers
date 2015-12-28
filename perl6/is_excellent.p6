#!perl6

sub is-even(Int:D $number --> Bool:D) {
	return False if $number % 2;
	return True;
	}

say is-even( 137 );
say is-even( Int );
