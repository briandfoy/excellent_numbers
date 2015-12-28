#!perl6

sub is-even(Int $number) {
	return False if $number % 2;
	return 1;
	}

say is-even( 137 );

say is-even( 2 );
