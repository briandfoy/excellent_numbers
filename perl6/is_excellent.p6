#!perl6

my &is-even = method (Int:D :) returns Bool:D { self %% 2 };
say 137.&is-even;
say 138.&is-even;
say "foo".&is-even;  # works, although inside is-even blow up
