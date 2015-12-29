#!perl6

	Int.^add_method( 'is-even', method () returns Bool:D {
		return False if self % 2;
		return True;
		} );

	say 137.is-even;

	say Int.methods;
