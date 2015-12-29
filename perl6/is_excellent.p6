#!perl6

Int.^add_method( 'is-even', method () returns Bool:D {
    return False if self % 2;
    return True;
    } );
Int.^compose;
Int.^publish_method_cache;

say Int.^methods;
	say 137.is-even;
	say 138.is-even;
	say "foo".is-even;
