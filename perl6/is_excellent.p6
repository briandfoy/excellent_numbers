#!perl6

class Int {
	proto sub is-even($) is pure  {*}
	method is-even (Int:D $number ) returns Bool:D {
		return False if $number % 2;
		return True;
		}
	}

say 137.WHAT;
say 137.is-even;
