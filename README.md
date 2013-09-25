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

# Methods from the Linode API

### avail\_stackscripts

Optional Parameters:

- distributionid
- keywords
- distributionvendor

### avail\_kernels

Optional Parameters:

- kernelid
- isxen

### avail\_linodeplans

Optional Parameters:

- planid

### avail\_datacenters

### avail\_distributions

Optional Parameters:

- distributionid

### domain\_create

Required Parameters:

- type
- domain

Optional Parameters:

- refresh\_sec
- retry\_sec
- master\_ips
- expire\_sec
- soa\_email
- axfr\_ips
- description
- ttl\_sec
- status

### domain\_delete

Required Parameters:

- domainid

### domain\_update

Required Parameters:

- domainid

Optional Parameters:

- refresh\_sec
- retry\_sec
- master\_ips
- type
- expire\_sec
- domain
- soa\_email
- axfr\_ips
- description
- ttl\_sec
- status

### domain\_list

Optional Parameters:

- domainid

### domain\_resource\_create

Required Parameters:

- type
- domainid

Optional Parameters:

- protocol
- name
- weight
- target
- priority
- ttl\_sec
- port

### domain\_resource\_delete

Required Parameters:

- resourceid
- domainid

### domain\_resource\_update

Required Parameters:

- resourceid

Optional Parameters:

- weight
- target
- priority
- ttl\_sec
- domainid
- port
- protocol
- name

### domain\_resource\_list

Required Parameters:

- domainid

Optional Parameters:

- resourceid

### linode\_mutate

Required Parameters:

- linodeid

### linode\_create

Required Parameters:

- datacenterid
- planid
- paymentterm

### linode\_reboot

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_webconsoletoken

Required Parameters:

- linodeid

### linode\_boot

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_resize

Required Parameters:

- linodeid
- planid

### linode\_clone

Required Parameters:

- linodeid
- paymentterm
- datacenterid
- planid

### linode\_shutdown

Required Parameters:

- linodeid

### linode\_delete

Required Parameters:

- linodeid

Optional Parameters:

- skipchecks

### linode\_update

Required Parameters:

- linodeid

Optional Parameters:

- alert\_diskio\_threshold
- lpm\_displaygroup
- watchdog
- alert\_bwout\_threshold
- ms\_ssh\_disabled
- ms\_ssh\_ip
- ms\_ssh\_user
- alert\_bwout\_enabled
- alert\_diskio\_enabled
- ms\_ssh\_port
- alert\_bwquota\_enabled
- alert\_bwin\_threshold
- backupweeklyday
- alert\_cpu\_enabled
- alert\_bwquota\_threshold
- backupwindow
- alert\_cpu\_threshold
- alert\_bwin\_enabled
- label

### linode\_list

Optional Parameters:

- linodeid

### linode\_config\_create

Required Parameters:

- kernelid
- linodeid
- label

Optional Parameters:

- rootdevicero
- helper\_disableupdatedb
- rootdevicenum
- comments
- rootdevicecustom
- devtmpfs\_automount
- ramlimit
- runlevel
- helper\_depmod
- helper\_xen
- disklist

### linode\_config\_delete

Required Parameters:

- linodeid
- configid

### linode\_config\_update

Required Parameters:

- configid

Optional Parameters:

- helper\_disableupdatedb
- rootdevicero
- comments
- rootdevicenum
- rootdevicecustom
- kernelid
- runlevel
- ramlimit
- devtmpfs\_automount
- helper\_depmod
- linodeid
- helper\_xen
- disklist
- label

### linode\_config\_list

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_disk\_create

Required Parameters:

- label
- size
- type
- linodeid

### linode\_disk\_resize

Required Parameters:

- diskid
- linodeid
- size

### linode\_disk\_createfromdistribution

Required Parameters:

- rootpass
- linodeid
- distributionid
- size
- label

Optional Parameters:

- rootsshkey

### linode\_disk\_duplicate

Required Parameters:

- diskid
- linodeid

### linode\_disk\_delete

Required Parameters:

- linodeid
- diskid

### linode\_disk\_update

Required Parameters:

- diskid

Optional Parameters:

- linodeid
- label
- isreadonly

### linode\_disk\_list

Required Parameters:

- linodeid

Optional Parameters:

- diskid

### linode\_disk\_createfromstackscript

Required Parameters:

- size
- label
- linodeid
- stackscriptid
- distributionid
- rootpass
- stackscriptudfresponses

### linode\_ip\_addprivate

Required Parameters:

- linodeid

### linode\_ip\_list

Required Parameters:

- linodeid

Optional Parameters:

- ipaddressid

### linode\_job\_list

Required Parameters:

- linodeid

Optional Parameters:

- pendingonly
- jobid

### stackscript\_create

Required Parameters:

- label
- distributionidlist
- script

Optional Parameters:

- rev\_note
- description
- ispublic

### stackscript\_delete

Required Parameters:

- stackscriptid

### stackscript\_update

Required Parameters:

- stackscriptid

Optional Parameters:

- distributionidlist
- description
- script
- ispublic
- rev\_note
- label

### stackscript\_list

Optional Parameters:

- stackscriptid

### nodebalancer\_config\_create

Required Parameters:

- nodebalancerid

Optional Parameters:

- protocol
- check
- check\_path
- check\_interval
- algorithm
- check\_attempts
- stickiness
- check\_timeout
- check\_body
- port

### nodebalancer\_config\_delete

Required Parameters:

- configid

### nodebalancer\_config\_update

Required Parameters:

- configid

Optional Parameters:

- check\_body
- stickiness
- check\_attempts
- check\_timeout
- algorithm
- port
- check
- protocol
- check\_path
- check\_interval

### nodebalancer\_config\_list

Required Parameters:

- nodebalancerid

Optional Parameters:

- configid

### nodebalancer\_node\_create

Required Parameters:

- label
- address
- configid

Optional Parameters:

- mode
- weight

### nodebalancer\_node\_delete

Required Parameters:

- nodeid

### nodebalancer\_node\_update

Required Parameters:

- nodeid

Optional Parameters:

- mode
- label
- address
- weight

### nodebalancer\_node\_list

Required Parameters:

- configid

Optional Parameters:

- nodeid

### user\_getapikey

Required Parameters:

- username
- password

# Additional Helper Methods

These methods are deprecated and will be going away.

### getDomainIDbyName( domain => 'example.com' )

Returns the ID for a domain given the name.

### getDomainResourceIDbyName( domainid => 242, name => 'www')

Takes a record name and domainid or domain and returns the resourceid.

# AUTHORS

- Michael Greb, `<mgreb@linode.com>`
- Stan "The Man" Schwertly `<stan@linode.com>`

# COPYRIGHT & LICENSE

Copyright 2008-2009 Linode, LLC, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
