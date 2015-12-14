use v5.22;
use feature qw(signatures);
no warnings qw(experimental::signatures);

package CpuCount;
use Exporter qw(import);

our @EXPORT_OK = qw(get_cpu_count);

__PACKAGE__->run unless caller;

sub run {
	say get_cpu_count();
	}

sub get_cpu_count () {

	state $dispatch = {
		freebsd => \&_freebsd,
		_default => \&_posix,
		};

	my $uname = $dispatch->{ $^O } // '_default';

	$dispatch->{ $uname }->();
	}

sub _freebsd () { _get_conf( 'NPROCESSORS_ONLN' ) }

sub _posix ()   { _get_conf( '_NPROCESSORS_ONLN' ) }

sub _get_conf ( $key ) {
	state $command = '/usr/bin/getconf';

	chomp( my $number = `$command $key 2>/dev/null` );

	$number;
	}
