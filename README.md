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

## account Methods

### account\_estimateinvoice

Estimates the invoice for adding a new Linode or NodeBalancer as well as resizing a Linode. This returns two fields: PRICE which is the estimated cost of the invoice, and INVOICE\_TO which is the date invoice would be though with timezone set to America/New\_York

Required Parameters:

- mode

    This is one of the following options: 'linode\_new', 'linode\_resize', or 'nodebalancer\_new'.

Optional Parameters:

- paymentterm

    Subscription term in months. One of: 1, 12, or 24. This is required for modes 'linode\_new' and 'nodebalancer\_new'.

- planid

    The desired PlanID available from avail.LinodePlans(). This is required for modes 'linode\_new' and 'linode\_resize'.

- linodeid

    This is the LinodeID you want to resize and is required for mode 'linode\_resize'.

### account\_info

Shows information about your account such as the date your account was opened as well as your network utilization for the current month in gigabytes.

### account\_paybalance

Pays current balance on file, returning it in the response.

### account\_updatecard

Required Parameters:

- ccnumber
- ccexpyear
- ccexpmonth

## avail Methods

### avail\_datacenters

Returns a list of Linode data center facilities.

### avail\_distributions

Returns a list of available Linux Distributions.

Optional Parameters:

- distributionid

    Limits the results to the specified DistributionID

### avail\_kernels

List available kernels.

Optional Parameters:

- iskvm

    Show or hide KVM compatible kernels

- isxen

    Show or hide Xen compatible kernels

### avail\_linodeplans

Returns a structure of Linode PlanIDs containing the Plan label and the availability in each Datacenter.

Optional Parameters:

- planid

    Limits the list to the specified PlanID

### avail\_nodebalancers

Returns NodeBalancer pricing information.

### avail\_stackscripts

Returns a list of available public StackScripts.

Optional Parameters:

- keywords

    Search terms

- distributionvendor

    Debian, Ubuntu, Fedora, etc.

- distributionid

    Limit the results to StackScripts that can be applied to this DistributionID

## domain Methods

### domain\_create

Create a domain record.

Required Parameters:

- type

    master or slave

- domain

    The zone's name

Optional Parameters:

- lpm\_displaygroup

    Display group in the Domain list inside the Linode DNS Manager

- soa\_email

    Required when type=master

- description

    Currently undisplayed.

- retry\_sec
- status

    0, 1, or 2 (disabled, active, edit mode)

- axfr\_ips

    IP addresses allowed to AXFR the entire zone, semicolon separated

- refresh\_sec
- expire\_sec
- master\_ips

    When type=slave, the zone's master DNS servers list, semicolon separated

- ttl\_sec

### domain\_delete

Required Parameters:

- domainid

### domain\_list

Lists domains you have access to.

Optional Parameters:

- domainid

    Limits the list to the specified DomainID

### domain\_update

Update a domain record.

Required Parameters:

- domainid

Optional Parameters:

- ttl\_sec
- master\_ips

    When type=slave, the zone's master DNS servers list, semicolon separated

- expire\_sec
- refresh\_sec
- axfr\_ips

    IP addresses allowed to AXFR the entire zone, semicolon separated

- domain

    The zone's name

- status

    0, 1, or 2 (disabled, active, edit mode)

- retry\_sec
- soa\_email

    Required when type=master

- description

    Currently undisplayed.

- lpm\_displaygroup

    Display group in the Domain list inside the Linode DNS Manager

- type

    master or slave

## domain\_resource Methods

### domain\_resource\_create

Create a domain record.

Required Parameters:

- domainid
- type

    One of: NS, MX, A, AAAA, CNAME, TXT, SRV or CAA

Optional Parameters:

- ttl\_sec

    TTL.  Leave as 0 to accept our default.

- protocol

    The protocol to append to an SRV record.  Ignored on other record types.

- port
- name

    The hostname or FQDN.  When Type=MX the subdomain to delegate to the Target MX server.

- tag

    The tag attribute for a CAA record.  One of issue, issuewild, iodef.  Ignored on other record types.

- target

    When Type=MX the hostname.  When Type=CNAME the target of the alias.  When Type=TXT or CAA the value of the record. When Type=A or AAAA the token of '\[remote\_addr\]' will be substituted with the IP address of the request.

- priority

    Priority for MX and SRV records, 0-65535

- weight

### domain\_resource\_delete

Required Parameters:

- domainid
- resourceid

### domain\_resource\_list

Required Parameters:

- domainid

Optional Parameters:

- resourceid

### domain\_resource\_update

Update a domain record.

Required Parameters:

- resourceid

Optional Parameters:

- port
- tag

    The tag attribute for a CAA record.  One of issue, issuewild, iodef.  Ignored on other record types.

- target

    When Type=MX the hostname.  When Type=CNAME the target of the alias.  When Type=TXT or CAA the value of the record. When Type=A or AAAA the token of '\[remote\_addr\]' will be substituted with the IP address of the request.

- domainid
- name

    The hostname or FQDN.  When Type=MX the subdomain to delegate to the Target MX server.

- protocol

    The protocol to append to an SRV record.  Ignored on other record types.

- ttl\_sec

    TTL.  Leave as 0 to accept our default.

- priority

    Priority for MX and SRV records, 0-65535

- weight

## linode Methods

### linode\_boot

Issues a boot job for the provided ConfigID.  If no ConfigID is provided boots the last used configuration profile, or the first configuration profile if this Linode has never been booted.

Required Parameters:

- linodeid

Optional Parameters:

- configid

    The ConfigID to boot, available from linode.config.list().

### linode\_clone

Creates a new Linode, assigns you full privileges, and then clones the specified LinodeID to the new Linode. There is a limit of 5 active clone operations per source Linode.  It is recommended that the source Linode be powered down during the clone.

Required Parameters:

- linodeid

    The LinodeID that you want cloned

- planid

    The desired PlanID available from avail.LinodePlans()

- datacenterid

    The DatacenterID from avail.datacenters() where you wish to place this new Linode

Optional Parameters:

- paymentterm

    Subscription term in months for prepaid customers.  One of: 1, 12, or 24

### linode\_create

Creates a Linode and assigns you full privileges. There is a 250-linodes-per-hour limiter.

Required Parameters:

- datacenterid

    The DatacenterID from avail.datacenters() where you wish to place this new Linode

- planid

    The desired PlanID available from avail.LinodePlans()

Optional Parameters:

- paymentterm

    Subscription term in months for prepaid customers.  One of: 1, 12, or 24

### linode\_delete

Immediately removes a Linode from your account and issues a pro-rated credit back to your account, if applicable.  To prevent accidental deletes, this requires the Linode has no Disk images.  You must first delete its disk images."

Required Parameters:

- linodeid

    The LinodeID to delete

Optional Parameters:

- skipchecks

    Skips the safety checks and will always delete the Linode

### linode\_kvmify

Changes a Linode's hypervisor from Xen to KVM.

Required Parameters:

- linodeid

    The LinodeID to migrate to KVM.

### linode\_list

Returns a list of all Linodes user has access or delete to, including some properties.  Status values are -1: Being Created, 0: Brand New, 1: Running, and 2: Powered Off.

Optional Parameters:

- linodeid

    Limits the list to the specified LinodeID

### linode\_mutate

Upgrades a Linode to its next generation.

Required Parameters:

- linodeid

### linode\_reboot

Issues a shutdown, and then boot job for a given LinodeID.

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_resize

Resizes a Linode from one plan to another.  Immediately shuts the Linode down, charges/credits the account, and issue a migration to another host server.

Required Parameters:

- linodeid
- planid

    The desired PlanID available from avail.LinodePlans()

### linode\_shutdown

Issues a shutdown job for a given LinodeID.

Required Parameters:

- linodeid

### linode\_update

Updates a Linode's properties.

Required Parameters:

- linodeid

Optional Parameters:

- label

    This Linode's label

- alert\_bwquota\_enabled

    Enable the bw quote email alert

- ms\_ssh\_port
- ms\_ssh\_ip
- ms\_ssh\_disabled
- alert\_bwout\_threshold

    Mb/sec

- alert\_diskio\_threshold

    IO ops/sec

- backupweeklyday
- alert\_cpu\_enabled

    Enable the cpu usage email alert

- alert\_bwquota\_threshold

    Percentage of monthly bw quota

- backupwindow
- lpm\_displaygroup

    Display group in the Linode list inside the Linode Manager

- alert\_diskio\_enabled

    Enable the disk IO email alert

- alert\_cpu\_threshold

    CPU Alert threshold, percentage 0-800

- alert\_bwin\_threshold

    Mb/sec

- watchdog

    Enable the Lassie shutdown watchdog

- alert\_bwout\_enabled

    Enable the outgoing bandwidth email alert

- ms\_ssh\_user
- alert\_bwin\_enabled

    Enable the incoming bandwidth email alert

### linode\_webconsoletoken

Generates a console token starting a web console LISH session for the requesting IP

Required Parameters:

- linodeid

## linode\_config Methods

### linode\_config\_create

Creates a Linode Configuration Profile.

Required Parameters:

- kernelid

    The KernelID for this profile.  Found in avail.kernels()

- label

    The Label for this profile

- linodeid
- disklist

    A comma delimited list of DiskIDs; position reflects device node.  The 9th element for specifying the initrd.

Optional Parameters:

- helper\_depmod

    Creates an empty modprobe file for the kernel you're booting.

- helper\_network

    Automatically creates network configuration files for your distro and places them into your filesystem.

- runlevel

    One of 'default', 'single', 'binbash'

- rootdevicecustom

    A custom root device setting.

- rootdevicenum

    Which device number (1-8) that contains the root partition.  0 to utilize RootDeviceCustom.

- helper\_disableupdatedb

    Enable the disableUpdateDB filesystem helper

- helper\_distro

    Enable the Distro filesystem helper.  Corrects fstab and inittab/upstart entries depending on the kernel you're booting.  You want this.

- comments

    Comments you wish to save along with this profile

- virt\_mode

    Controls the virtualization mode. One of 'paravirt', 'fullvirt'

- ramlimit

    RAMLimit in MB.  0 for max.

- helper\_xen

    Deprecated - use helper\_distro.

- rootdevicero

    Enables the 'ro' kernel flag.  Modern distros want this.

- devtmpfs\_automount

    Controls if pv\_ops kernels should automount devtmpfs at boot.

### linode\_config\_delete

Deletes a Linode Configuration Profile.

Required Parameters:

- configid
- linodeid

### linode\_config\_list

Lists a Linode's Configuration Profiles.

Required Parameters:

- linodeid

Optional Parameters:

- configid

### linode\_config\_update

Updates a Linode Configuration Profile.

Required Parameters:

- configid

Optional Parameters:

- helper\_depmod

    Creates an empty modprobe file for the kernel you're booting.

- helper\_network

    Automatically creates network configuration files for your distro and places them into your filesystem.

- runlevel

    One of 'default', 'single', 'binbash'

- kernelid

    The KernelID for this profile.  Found in avail.kernels()

- label

    The Label for this profile

- helper\_distro

    Enable the Distro filesystem helper.  Corrects fstab and inittab/upstart entries depending on the kernel you're booting.  You want this.

- comments

    Comments you wish to save along with this profile

- rootdevicecustom

    A custom root device setting.

- rootdevicenum

    Which device number (1-8) that contains the root partition.  0 to utilize RootDeviceCustom.

- linodeid
- helper\_disableupdatedb

    Enable the disableUpdateDB filesystem helper

- disklist

    A comma delimited list of DiskIDs; position reflects device node.  The 9th element for specifying the initrd.

- virt\_mode

    Controls the virtualization mode. One of 'paravirt', 'fullvirt'

- ramlimit

    RAMLimit in MB.  0 for max.

- rootdevicero

    Enables the 'ro' kernel flag.  Modern distros want this.

- devtmpfs\_automount

    Controls if pv\_ops kernels should automount devtmpfs at boot.

- helper\_xen

    Deprecated - use helper\_distro.

## linode\_disk Methods

### linode\_disk\_create

Required Parameters:

- size

    The size in MB of this Disk.

- type

    The formatted type of this disk.  Valid types are: ext3, ext4, swap, raw

- label

    The display label for this Disk

- linodeid

Optional Parameters:

- isreadonly

    Enable forced read-only for this Disk

### linode\_disk\_createfromdistribution

Required Parameters:

- rootpass

    The root (or core) user's password

- size

    Size of this disk image in MB

- linodeid
- distributionid

    The DistributionID to create this disk from.  Found in avail.distributions()

- label

    The label of this new disk image

Optional Parameters:

- rootsshkey

    Optionally sets this string into /root/.ssh/authorized\_keys (or /home/core/.ssh/authorized\_keys) upon distribution configuration.

### linode\_disk\_createfromimage

Creates a new disk from a previously imagized disk.

Required Parameters:

- linodeid

    Specifies the Linode to deploy on to

- imageid

    The ID of the frozen image to deploy from

Optional Parameters:

- label

    The label of this new disk image

- size

    The size of the disk image to creates. Defaults to the minimum size required for the requested image

- rootsshkey

    Optionally sets this string into /root/.ssh/authorized\_keys upon image deployment

- rootpass

    Optionally sets the root password at deployment time. If a password is not provided the existing root password of the frozen image will not be modified

### linode\_disk\_createfromstackscript

Required Parameters:

- linodeid
- rootpass

    The root user's password

- size

    Size of this disk image in MB

- stackscriptudfresponses

    JSON encoded name/value pairs, answering this StackScript's User Defined Fields

- distributionid

    Which Distribution to apply this StackScript to.  Must be one from the script's DistributionIDList

- stackscriptid

    The StackScript to create this image from

- label

    The label of this new disk image

Optional Parameters:

- rootsshkey

    Optionally sets this string into /root/.ssh/authorized\_keys upon distribution configuration.

### linode\_disk\_delete

Required Parameters:

- diskid
- linodeid

### linode\_disk\_duplicate

Performs a bit-for-bit copy of a disk image.

Required Parameters:

- linodeid
- diskid

### linode\_disk\_imagize

Creates a gold-master image for future deployments

Required Parameters:

- linodeid

    Specifies the source Linode to create the image from

- diskid

    Specifies the source Disk to create the image from

Optional Parameters:

- label

    Sets the name of the image shown in the base image list, defaults to the source image label

- description

    An optional description of the created image

### linode\_disk\_list

Status values are 1: Ready and 2: Being Deleted.

Required Parameters:

- linodeid

Optional Parameters:

- diskid

### linode\_disk\_resize

Required Parameters:

- diskid
- linodeid
- size

    The requested new size of this Disk in MB

### linode\_disk\_update

Required Parameters:

- diskid

Optional Parameters:

- linodeid
- label

    The display label for this Disk

- isreadonly

    Enable forced read-only for this Disk

## linode\_ip Methods

### linode\_ip\_addprivate

Assigns a Private IP to a Linode.  Returns the IPAddressID that was added.

Required Parameters:

- linodeid

### linode\_ip\_addpublic

Assigns a Public IP to a Linode.  Returns the IPAddressID and IPAddress that was added.

Required Parameters:

- linodeid

    The LinodeID of the Linode that will be assigned an additional public IP address

### linode\_ip\_list

Returns the IP addresses of all Linodes you have access to.

Optional Parameters:

- linodeid

    If specified, limits the result to this LinodeID

- ipaddressid

    If specified, limits the result to this IPAddressID

### linode\_ip\_setrdns

Sets the rDNS name of a Public IP.  Returns the IPAddressID and IPAddress that were updated.

Required Parameters:

- hostname

    The hostname to set the reverse DNS to

- ipaddressid

    The IPAddressID of the address to update

### linode\_ip\_swap

Exchanges Public IP addresses between two Linodes within a Datacenter.  The destination of the IP Address can be designated by either the toLinodeID or withIPAddressID parameter.  Returns the resulting relationship of the Linode and IP Address parameters.  When performing a one directional swap, the source is represented by the first of the two resultant array members.

Required Parameters:

- ipaddressid

    The IPAddressID of an IP Address to transfer or swap

Optional Parameters:

- tolinodeid

    The LinodeID of the Linode where IPAddressID will be transfered

- withipaddressid

    The IP Address ID to swap

## linode\_job Methods

### linode\_job\_list

Required Parameters:

- linodeid

Optional Parameters:

- pendingonly
- jobid

    Limits the list to the specified JobID

## stackscript Methods

### stackscript\_create

Create a StackScript.

Required Parameters:

- distributionidlist

    Comma delimited list of DistributionIDs that this script works on

- script

    The actual script

- label

    The Label for this StackScript

Optional Parameters:

- description
- rev\_note
- ispublic

    Whether this StackScript is published in the Library, for everyone to use

### stackscript\_delete

Required Parameters:

- stackscriptid

### stackscript\_list

Lists StackScripts you have access to.

Optional Parameters:

- stackscriptid

    Limits the list to the specified StackScriptID

### stackscript\_update

Update a StackScript.

Required Parameters:

- stackscriptid

Optional Parameters:

- script

    The actual script

- label

    The Label for this StackScript

- rev\_note
- ispublic

    Whether this StackScript is published in the Library, for everyone to use

- description
- distributionidlist

    Comma delimited list of DistributionIDs that this script works on

## nodeblancer Methods

## nodebalancer\_config Methods

### nodebalancer\_config\_create

Required Parameters:

- nodebalancerid

    The parent NodeBalancer's ID

Optional Parameters:

- cipher\_suite

    SSL cipher suite to enforce. One of 'recommended', 'legacy'

- check\_interval

    Seconds between health check probes.  2-3600

- port

    Port to bind to on the public interfaces. 1-65534

- check

    Perform active health checks on the backend nodes.  One of 'connection', 'http', 'http\_body'

- check\_attempts

    Number of failed probes before taking a node out of rotation. 1-30

- stickiness

    Session persistence.  One of 'none', 'table', 'http\_cookie'

- protocol

    Either 'tcp', 'http', or 'https'

- check\_passive

    Enable passive checks based on observing communication with back-end nodes.

- check\_body

    When check=http, a regex to match within the first 16,384 bytes of the response body

- check\_timeout

    Seconds to wait before considering the probe a failure. 1-30.  Must be less than check\_interval.

- check\_path

    When check=http, the path to request

- ssl\_key

    Unpassphrased private key for the SSL certificate when protocol is 'https'

- algorithm

    Balancing algorithm.  One of 'roundrobin', 'leastconn', 'source'

- ssl\_cert

    SSL certificate served by the NodeBalancer when the protocol is 'https'

### nodebalancer\_config\_delete

Deletes a NodeBalancer's Config

Required Parameters:

- nodebalancerid
- configid

    The ConfigID to delete

### nodebalancer\_config\_list

Returns a list of NodeBalancers this user has access or delete to, including their properties

Required Parameters:

- nodebalancerid

Optional Parameters:

- configid

    Limits the list to the specified ConfigID

### nodebalancer\_config\_update

Updates a Config's properties

Required Parameters:

- configid

Optional Parameters:

- check\_timeout

    Seconds to wait before considering the probe a failure. 1-30.  Must be less than check\_interval.

- stickiness

    Session persistence.  One of 'none', 'table', 'http\_cookie'

- check\_attempts

    Number of failed probes before taking a node out of rotation. 1-30

- check\_body

    When check=http, a regex to match within the first 16,384 bytes of the response body

- protocol

    Either 'tcp', 'http', or 'https'

- check\_passive

    Enable passive checks based on observing communication with back-end nodes.

- check

    Perform active health checks on the backend nodes.  One of 'connection', 'http', 'http\_body'

- port

    Port to bind to on the public interfaces. 1-65534

- check\_interval

    Seconds between health check probes.  2-3600

- cipher\_suite

    SSL cipher suite to enforce. One of 'recommended', 'legacy'

- ssl\_cert

    SSL certificate served by the NodeBalancer when the protocol is 'https'

- algorithm

    Balancing algorithm.  One of 'roundrobin', 'leastconn', 'source'

- ssl\_key

    Unpassphrased private key for the SSL certificate when protocol is 'https'

- check\_path

    When check=http, the path to request

## nodebalancer\_node Methods

### nodebalancer\_node\_create

Required Parameters:

- address

    The address:port combination used to communicate with this Node

- configid

    The parent ConfigID to attach this Node to

- label

    This backend Node's label

Optional Parameters:

- weight

    Load balancing weight, 1-255. Higher means more connections.

- mode

    The connections mode for this node.  One of 'accept', 'reject', 'backup', or 'drain'

### nodebalancer\_node\_delete

Deletes a Node from a NodeBalancer Config

Required Parameters:

- nodeid

    The NodeID to delete

### nodebalancer\_node\_list

Returns a list of Nodes associated with a NodeBalancer Config

Required Parameters:

- configid

Optional Parameters:

- nodeid

    Limits the list to the specified NodeID

### nodebalancer\_node\_update

Updates a Node's properties

Required Parameters:

- nodeid

Optional Parameters:

- label

    This backend Node's label

- mode

    The connections mode for this node.  One of 'accept', 'reject', 'backup', or 'drain'

- address

    The address:port combination used to communicate with this Node

- weight

    Load balancing weight, 1-255. Higher means more connections.

## user Methods

### user\_getapikey

Authenticates a Linode Manager user against their username, password, and two-factor token (when enabled), and then returns a new API key, which can be used until it expires.  The number of active keys is limited to 20.  Batch requests will be rejected if they include this API action.

Required Parameters:

- password
- username

Optional Parameters:

- label

    An optional label for this key.

- token

    Required when two-factor authentication is enabled. Emergency scratch codes are not permitted.

- expires

    Number of hours the key will remain valid, between 0 and 8760. 0 means no expiration. Defaults to 168.

## image Methods

### image\_delete

Deletes a gold-master image

Required Parameters:

- imageid

    The ID of the gold-master image to delete

### image\_list

Lists available gold-master images

Optional Parameters:

- pending

    Show images currently being created.

- imageid

    Request information for a specific gold-master image

### image\_update

Update an Image record.

Required Parameters:

- imageid

    The ID of the Image to modify.

Optional Parameters:

- description

    An optional description of the Image.

- label

    The label of the Image.

## professionalservices\_scope Methods

# AUTHORS

- Michael Greb, `<michael@thegrebs.com>`
- Stan "The Man" Schwertly `<stan@schwertly.com>`

# COPYRIGHT & LICENSE

Copyright 2008-2014 Michael Greb, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.
