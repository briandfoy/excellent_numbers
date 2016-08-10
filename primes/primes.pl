#!/Users/brian/bin/perls/perl5.24.0
use v5.24;

use bignum;

use List::Util qw(reduce);
#use Mojo::UserAgent;

my $file  = 'Repunit100.txt';
my $url   = 'http://www.h4.dion.ne.jp/~rep/Repunit100.txt';
#my $lines = Mojo::UserAgent->new->get( $url )->res->body;

open my $fh, '<:utf8', $file or die "Could not open $file: $!\n";

my %factors;
my $last_k  = 2;

while( <$fh> ) {
	my $line = $_;
	state $this_k = 2;
	$line =~ s/\s+\R+//;
	my( $k, $factors ) = unpack "a9 a*";
	$k =~ s/\s+//g;

	$k = 0 unless $k;
	$k += 0;
	next if $k == 1;
	$this_k = $k || $this_k;

	# continued number
	if( $line =~ /\$\s*\z/ ) {
		my $next_line = <$fh>;
		$next_line =~ s/^\s+|\s+\R+//;
		$factors .= $next_line;
		}

	while( $factors =~ /\s(L|M)\s/ ) {
		my $letter = $1;
		say "Found $letter in $factors";
		my $next_line = <$fh>;
		$next_line =~ s/\A\s+//;
		my( $l, $rest ) = split /\s+/, $next_line, 2;
		# say "Got line >> $next_line";
		my( @f ) = $rest =~ m/(\S+)/g;
		my $f = "@f";
		say "replacing with $f";
		$factors =~ s/\s+$letter\s+/ $f /;
		my $key = "$this_k$letter";
		$factors{$key} = [ @f ];
		}

	$factors =~ s/\s*\$\s*//g;
	$factors =~ s/\s*\z//;

	say "$k => [$factors]";

	my @f = split /\s+/, $factors;

	push @{ $factors{$this_k} }, @f;
	}
#$Data::Dumper::Sortkeys = 1;

foreach my $i ( sort { $a <=> $b } keys %factors  ) {
	next if $i =~ /[LM]/;
#foreach my $i ( 60  ) {
#	say "Raw factors: ", join " ", $factors{$i}->@*;

	my @factors =
	#	sort { $a <=> $b }
			map {
				    /\A\d/
				    ?
					$_
					:
					map { grep /\A\d/, $factors{$_}->@* } /(\d+[LM]?)/g
				}
			$factors{$i}->@*;

	my $product = 1;
	$product *= $_ for @factors;
	warn "WRONG PRODUCT FOR $i!\n" if $product =~ /[^1]/;
	printf "%3s | %s\n",
		$i,
		join " ",sort { $a <=> $b } @factors;
	}

__END__
$lines =~ s/\R+/\n/g;
$lines =~ s/\$\R\s+//g;

say $lines;
