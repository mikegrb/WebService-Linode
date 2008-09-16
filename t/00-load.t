#!perl -T

use Test::More tests => 2;

BEGIN {
	use_ok( 'WebService::Linode' );
	use_ok( 'WebService::Linode::DNS' );
}

diag( "Testing WebService::Linode ::DNS $WebService::Linode::VERSION $WebService::Linode::DNS::VERSION, , Perl $], $^X" );
