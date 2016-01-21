module ExcellentNumber {
	sub is_excellent ( Int:D $number ) is export {
		# It's a bit easier to count digits as a string
		# of decimal digits
		my $string = ~ $number;
		return False unless $string.chars %% 2;

		my $a = + $string.substr( 0, $string.chars/2 );
		my $b = + $string.substr( $string.chars/2 );

		my $a2 = $a ** 2;
		my $b2 = $b ** 2;

		my $diff = $b2 - $a2;
		return False unless $number == $diff;

		return {
			a    => $a,
			b    => $b,
			'a²' => $a2,
			'b²' => $b2,
			diff => $diff,
			};
		}
	}
