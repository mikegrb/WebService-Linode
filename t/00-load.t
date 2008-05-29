#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WebService::Linode' );
}

diag( "Testing WebService::Linode $WebService::Linode::VERSION, Perl $], $^X" );
