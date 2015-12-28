#!perl6

my $digits = @*ARGS[0];
my $start  = @*ARGS[1] // 1001;
my $end    = @*ARGS[2] // 6200;

say "Digits are $digits\nstart is $start\nend is $end";
