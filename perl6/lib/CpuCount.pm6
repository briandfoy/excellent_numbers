module CpuCount {
	sub run () is export {
		say get_cpu_count();
		}

	sub get_cpu_count () is export {
		state $dispatch = {
			freebsd  => &_freebsd,
			_default => &_posix,
			};

		my $key = $dispatch.{ $*DISTRO.name }:exists ?? $*DISTRO.name !! '_default';

		$dispatch.{ $key }.();
		}

	sub _freebsd () { _get_conf( 'NPROCESSORS_ONLN' ) }

	sub _posix ()   { _get_conf( '_NPROCESSORS_ONLN' ) }

	sub _get_conf ( $key ) {
		state $command = '/usr/bin/getconf';

		unless $key ~~ m/ ^^ <[_A..Z0..9]>+ $$ / {
			warn "Key $key doesn't look acceptable";
			return;
			};
		qq:x{$command $key 2>/dev/null}.chomp;
		}
	}

sub MAIN {
	import CpuCount;
	run;
	}
