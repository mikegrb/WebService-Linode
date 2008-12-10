use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	(MM->can('signature_target') ? (SIGN => 1) : ()),
	NAME				=> 'WebService::Linode',
	AUTHOR				=> 'Michael Greb <mgreb@linode.com>',
	VERSION_FROM		=> 'lib/WebService/Linode.pm',
	ABSTRACT_FROM		=> 'lib/WebService/Linode.pm',
	LICENSE				=> 'perl',
	PL_FILES			=> {},
	PREREQ_PM => {
		'Test::More'	=> 0,
		'JSON'			=> 2.00,
		'LWP::UserAgent'	=> 0,
		'Crypt::SSLeay'	=> 0,
	},
	dist				=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
	clean				=> { FILES => 'WebService-Linode-*' },
);
