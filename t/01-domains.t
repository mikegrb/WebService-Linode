#!perl -T

use Test::More;
use Data::Dumper;

eval "use Test::MockObject";

if($@) {
	plan skip_all => "Test::MockObject required for these tests" if $@;
}
else {
	plan tests => 5
}

my $ua = Test::MockObject->new();
$ua->fake_module( 'LWP::UserAgent',
	agent => sub { return 1; } 
);
my $response = Test::MockObject->new();
$response->fake_module( 'LWP::Response',
	yippie => sub { return 1; },
);

$ua->fake_new( 'LWP::UserAgent' );
$ua->set_true( 'agent' );
$ua->mock('post',
	sub {
		return $response;
	}
);

use_ok( 'WebService::Linode::DNS' );

my $expected;
my $api = WebService::Linode::DNS->new(apikey => 123, nowarn=>1);

isa_ok($api, 'WebService::Linode::DNS');

$response->set_always( 'content', scalar(<DATA>));
$expected = eval scalar(<DATA>);
is_deeply($api->domainList(), $expected, 'domainList');

is ($api->getDomainIDbyName('apitest.com'), 5118, 'getDomainIDbyName');

$response->set_always( 'content', scalar(<DATA>));
$expected = eval scalar(<DATA>);
is_deeply($api->domainGet(domainid=>5117), $expected, 'domainGet(domainid=>5117)');

#TODO more tests!
#TODO check the requests, not just that returned data propperly handled

1;

__DATA__
{"ERRORARRAY":[],"DATA":[{"TTL_SEC":0,"REFRESH_SEC":0,"DOMAIN":"apitest.com","DOMAINID":5118,"TYPE":"master","RETRY_SEC":0,"SOA_EMAIL":"caker@linode.com","STATUS":1}],"HTTPRESULT":200.0,"REQUESTSTATUS":0.0}
[{'ttl_sec'=>0,'domain'=>'apitest.com','status'=>1,'retry_sec'=>0,'soa_email'=>'caker@linode.com','refresh_sec'=>0,'type'=>'master','domainid'=>5118}];
{"ERRORARRAY":[],"DATA":{"TTL_SEC":0,"REFRESH_SEC":0,"DOMAIN":"bar.com","DOMAINID":5117,"TYPE":"master","RETRY_SEC":0,"SOA_EMAIL":"caker@linode.com","STATUS":1},"HTTPRESULT":200.0,"REQUESTSTATUS":0.0}
{'ttl_sec'=>0,'domain'=>'bar.com','status'=>1,'retry_sec'=>0,'soa_email'=>'caker@linode.com','refresh_sec'=>0,'type'=>'master','domainid'=>5117};