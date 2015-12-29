#!perl6


sub Int::is-even (Int:D $number ) returns Bool:D {
		return False if $number % 2;
		return True;
		}

say 137.WHAT;
say 137.is-even;
