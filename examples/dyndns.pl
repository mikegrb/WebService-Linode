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
my $ipfile = '/home/username/.lastip';	# file to store last IP between runs

# get public ip
my $pubip = get('http://ip.thegrebs.com/') or exit 1;
my $oldip = `cat  $ipfile`;

for ($pubip, $oldip) { chomp if $_ }

# exit if no change
exit 0 if $oldip eq $pubip;

# still running so update A record $record in $domain to point to current
# public ip
my $api = new WebService::Linode::DNS( apikey => $apikey );

my $resourceid =
	$api->getResourceIDbyName(domain => $domain, name => $record);
die "Couldn't find RR id" unless $resourceid;

$api->domainResourceUpdate(resourceid => $resourceid, target => $pubip);

system "echo '$pubip' > $ipfile";