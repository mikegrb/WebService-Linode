#!/usr/bin/perl

use strict;
use warnings;

use WebService::Linode::DNS;
use LWP::Simple;

# yourname.com is a master zone with a resource record of type A named home
# that should point to home IP.

my $apikey = '';
my $domain = 'yourname.com';
my $record = 'home';

# get public ip
chomp(my $pubip = get('http://ip.thegrebs.com/'));

my $api = new WebService::Linode::DNS( apikey => $apikey );

my $resourceid =
	$api->getResourceIDbyName(domain => $domain, name => $record);

die "Couldn't find RR id" unless $resourceid;

$api->domainResourceUpdate(resourceid => $resourceid, target => $pubip);