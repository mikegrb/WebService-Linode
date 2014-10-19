# NAME

WebService::Linode - Perl Interface to the Linode.com API.

# SYNOPSIS

    my $api = WebService::Linode->new( apikey => 'your api key here');
    print Dumper($api->linode_list);
    $api->linode_reboot(linodeid=>242);

This module implements the Linode.com api methods.  Linode methods have had
dots replaced with underscores to generate the perl method name.  All keys
and parameters have been lower cased but returned data remains otherwise the
same.  For additional information see [http://www.linode.com/api/](http://www.linode.com/api/)

# Constructor

For documentation of possible arguments to the constructor, see
[WebService::Linode::Base](https://metacpan.org/pod/WebService::Linode::Base).

# Batch requests

Each of the Linode API methods below may optionally be prefixed with QUEUE\_
to add that request to a queue to be processed later in one or more batch
requests which can be processed by calling send\_queued\_requests.
For example:

    my @linode_ids = () # Get your linode ids through normal methods
    my @responses = map { $api->linode_ip_list( linodeid=>$_ ) } @linode_ids;

Can be reduced to a single request:

    my @linode_ids = () # Get your linode ids through normal methods
    $api->QUEUE_linode_ip_list( linodeid=>$_ ) for @linode_ids;
    my @responses = $api->send_queued_requests; # One api request

See [WebService::Linode::Base](https://metacpan.org/pod/WebService::Linode::Base) for additional queue management methods.

### send\_queued\_requests

Send queued batch requests, returns list of responses.

# Methods from the Linode API

### avail\_datacenters

### avail\_nodebalancers

### avail\_distributions

Optional Parameters:

- distributionid

### avail\_kernels

Optional Parameters:

- isxen
- kernelid

### avail\_linodeplans

Optional Parameters:

- planid

### avail\_stackscripts

Optional Parameters:

- distributionid
- distributionvendor
- keywords

### domain\_list

Optional Parameters:

- domainid

### domain\_update

Required Parameters:

- domainid

Optional Parameters:

- axfr\_ips
- description
- domain
- expire\_sec
- lpm\_displaygroup
- master\_ips
- refresh\_sec
- retry\_sec
- soa\_email
- status
- ttl\_sec
- type

### domain\_create

Required Parameters:

- domain
- type

Optional Parameters:

- axfr\_ips
- description
- expire\_sec
- lpm\_displaygroup
- master\_ips
- refresh\_sec
- retry\_sec
- soa\_email
- status
- ttl\_sec

### domain\_delete

Required Parameters:

- domainid

### domain\_resource\_update

Required Parameters:

- resourceid

Optional Parameters:

- domainid
- name
- port
- priority
- protocol
- target
- ttl\_sec
- weight

### domain\_resource\_list

Required Parameters:

- domainid

Optional Parameters:

- resourceid

### domain\_resource\_delete

Required Parameters:

- domainid
- resourceid

### domain\_resource\_create

Required Parameters:

- domainid
- type

Optional Parameters:

- name
- port
- priority
- protocol
- target
- ttl\_sec
- weight

### linode\_resize

Required Parameters:

- linodeid
- planid

### linode\_list

Optional Parameters:

- linodeid

### linode\_mutate

Required Parameters:

- linodeid

### linode\_boot

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_create

Required Parameters:

- datacenterid
- planid

Optional Parameters:

- paymentterm

### linode\_clone

Required Parameters:

- datacenterid
- linodeid
- planid

Optional Parameters:

- paymentterm

### linode\_update

Required Parameters:

- linodeid

Optional Parameters:

- alert\_bwin\_enabled
- alert\_bwin\_threshold
- alert\_bwout\_enabled
- alert\_bwout\_threshold
- alert\_bwquota\_enabled
- alert\_bwquota\_threshold
- alert\_cpu\_enabled
- alert\_cpu\_threshold
- alert\_diskio\_enabled
- alert\_diskio\_threshold
- backupweeklyday
- backupwindow
- label
- lpm\_displaygroup
- ms\_ssh\_disabled
- ms\_ssh\_ip
- ms\_ssh\_port
- ms\_ssh\_user
- watchdog

### linode\_webconsoletoken

Required Parameters:

- linodeid

### linode\_reboot

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_shutdown

Required Parameters:

- linodeid

### linode\_delete

Required Parameters:

- linodeid

Optional Parameters:

- skipchecks

### linode\_config\_delete

Required Parameters:

- configid
- linodeid

### linode\_config\_create

Required Parameters:

- kernelid
- label
- linodeid

Optional Parameters:

- comments
- devtmpfs\_automount
- disklist
- helper\_depmod
- helper\_disableupdatedb
- helper\_xen
- ramlimit
- rootdevicecustom
- rootdevicenum
- rootdevicero
- runlevel

### linode\_config\_update

Required Parameters:

- configid

Optional Parameters:

- comments
- devtmpfs\_automount
- disklist
- helper\_depmod
- helper\_disableupdatedb
- helper\_xen
- kernelid
- label
- linodeid
- ramlimit
- rootdevicecustom
- rootdevicenum
- rootdevicero
- runlevel

### linode\_config\_list

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_disk\_createfromimage

Required Parameters:

- imageid
- linodeid

Optional Parameters:

- rootpass
- rootsshkey
- size

### linode\_disk\_duplicate

Required Parameters:

- diskid
- linodeid

### linode\_disk\_update

Required Parameters:

- diskid

Optional Parameters:

- isreadonly
- label
- linodeid

### linode\_disk\_createfromstackscript

Required Parameters:

- distributionid
- label
- linodeid
- rootpass
- size
- stackscriptid
- stackscriptudfresponses

Optional Parameters:

- rootsshkey

### linode\_disk\_imagize

Required Parameters:

- diskid
- linodeid

Optional Parameters:

- description
- label

### linode\_disk\_delete

Required Parameters:

- diskid
- linodeid

### linode\_disk\_resize

Required Parameters:

- diskid
- linodeid
- size

### linode\_disk\_list

Required Parameters:

- linodeid

Optional Parameters:

- diskid

### linode\_disk\_createfromdistribution

Required Parameters:

- distributionid
- label
- linodeid
- rootpass
- size

Optional Parameters:

- rootsshkey

### linode\_disk\_create

Required Parameters:

- label
- linodeid
- size
- type

Optional Parameters:

- fromdistributionid
- isreadonly
- rootpass
- rootsshkey

### linode\_ip\_setrdns

Required Parameters:

- hostname
- ipaddressid

### linode\_ip\_swap

Required Parameters:

- ipaddressid

Optional Parameters:

- tolinodeid
- withipaddressid

### linode\_ip\_addprivate

Required Parameters:

- linodeid

### linode\_ip\_list

Required Parameters:

- linodeid

Optional Parameters:

- ipaddressid

### linode\_ip\_addpublic

Required Parameters:

- linodeid

### linode\_job\_list

Required Parameters:

- linodeid

Optional Parameters:

- jobid
- pendingonly

### stackscript\_list

Optional Parameters:

- stackscriptid

### stackscript\_update

Required Parameters:

- stackscriptid

Optional Parameters:

- description
- distributionidlist
- ispublic
- label
- rev\_note
- script

### stackscript\_create

Required Parameters:

- distributionidlist
- label
- script

Optional Parameters:

- description
- ispublic
- rev\_note

### stackscript\_delete

Required Parameters:

- stackscriptid

### nodebalancer\_config\_delete

Required Parameters:

- configid
- nodebalancerid

### nodebalancer\_config\_create

Required Parameters:

- nodebalancerid

Optional Parameters:

- algorithm
- check
- check\_attempts
- check\_body
- check\_interval
- check\_path
- check\_timeout
- port
- protocol
- ssl\_cert
- ssl\_key
- stickiness

### nodebalancer\_config\_update

Required Parameters:

- configid

Optional Parameters:

- algorithm
- check
- check\_attempts
- check\_body
- check\_interval
- check\_path
- check\_timeout
- port
- protocol
- ssl\_cert
- ssl\_key
- stickiness

### nodebalancer\_config\_list

Required Parameters:

- nodebalancerid

Optional Parameters:

- configid

### nodebalancer\_node\_create

Required Parameters:

- address
- configid
- label

Optional Parameters:

- mode
- weight

### nodebalancer\_node\_delete

Required Parameters:

- nodeid

### nodebalancer\_node\_list

Required Parameters:

- configid

Optional Parameters:

- nodeid

### nodebalancer\_node\_update

Required Parameters:

- nodeid

Optional Parameters:

- address
- label
- mode
- weight

### user\_getapikey

Required Parameters:

- password
- username

Optional Parameters:

- expires
- label
- token

# AUTHORS

- Michael Greb, `<michael@thegrebs.com>`
- Stan "The Man" Schwertly `<stan@schwertly.com>`

# COPYRIGHT & LICENSE

Copyright 2008-2014 Michael Greb, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
