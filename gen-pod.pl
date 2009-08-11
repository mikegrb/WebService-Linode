#!/usr/bin/perl

use strict;
use warnings;

my %validation = (
    avail => {
        datacenters   => [ [], [                     ] ],
        kernels       => [ [], [ 'kernelid', 'isxen' ] ],
        linodeplans   => [ [], [ 'plainid'           ] ],
        distributions => [ [], [ 'distributionid'    ] ],
    },
    domain => {
        create => [ [ 'domain', 'type' ], [ qw( description soa_email refresh_sec retry_sec expire_sec ttl_sec status master_ips ) ]],
        list   => [ [], ['domainid'] ],
        update => [ ['domainid'], [ qw( domain description type soa_email refresh_sec retry_sec expire_sec ttl_sec  status master_ips) ]],
        delete => [ ['domainid'], [] ],
    },
    domain_resource => {
        create => [ ['domainid', 'type'], [ qw( name target priority weight port protocol ttl_sec )] ],
        list   => [ ['domainid'], ['resouceid'] ],
        update => [ [ 'domainid', 'resourceid' ], [ qw( name target priority weight port protocol ttl_sec )] ],
        delete => [ [ 'domainid', 'resourceid' ], [] ],
    },
    linode => {
        create   => [ [ qw( datacenterid planid paymentterm ) ], [] ],
        list     => [ [], ['linodeid'] ],
        update   => [ ['linodeid'], [ qw( label lpm_displaygroup alert_cpu_enabled alert_cpu_threshold alert_diskio_enabled alert_diskio_threshold alert_bwin_enabled alert_bwin_threshold alert_bwout_enabled alert_bwout_threshold alert_bwquota_enabled alert_bwquota_threshold backupwindow backupweeklyday watchdog ) ] ],
        delete   => [ ['linodeid'], [] ],
        shutdown => [ ['linodeid'], [] ],
        boot     => [ ['linodeid'], ['configid'] ],
        reboot   => [ ['linodeid'], ['configid'] ],
    },

    linode_config => {
        create => [ [ qw( linodeid kernelid label ) ], [ qw( comments ramlimit disklist runlevel rootdevicenum rootdevicecustom rootdevicero helper_disableupdatedb helper_xen helper_depmod ) ] ],
        list   => [ ['linodeid'], ['configid'] ],
        update => [ [ 'linodeid', 'configid' ],  [ qw( kernelid label comments ramlimit disklist runlevel rootdevicenum rootdevicecustom rootdevicero helper_xen helper_disableupdatedb helper_depmod ) ] ],
        delete => [ [ 'linodeid', 'configid' ], [] ],

    },

    linode_disk => {
        create    => [ [ 'linodeid', 'label', 'type', 'size' ], [ 'isreadonly' ] ],
        list      => [ [ 'linodeid' ], ['diskid' ] ],
        update    => [ [ 'linodeid', 'diskid' ], [ 'label', 'isreadonly' ] ],
        delete    => [ [ 'linodeid', 'diskid' ], [] ],
        createfromdistribution => [ [ qw( linodeid distributionid label size rootpass ) ], [ 'rootsshkey' ] ],
        duplicate => [ [ 'linodeid', 'diskid' ], [] ],
        resize    => [ [ 'linodeid', 'diskid', 'size' ], [] ],

    },
    linode_ip => {
        list  => [ [ 'linodeid' ], [ 'ipaddressid' ] ],
    },
    linode_job => {
        list => [ [ 'linodeid' ], [ 'jobid', 'pendingonly' ] ],
    },

);

foreach my $group (qw{avail domain domain_resource linode linode_config linode_disk linode_ip linode_job}) {
    # print "=head2 $group\n\n";
    foreach my $method (keys %{$validation{$group}}) {
        print "=head3 ${group}_${method}\n\n";
        print "Required Parameters:\n\n";
        print "=over 4\n\n";
        print "=item * $_\n\n" for @{$validation{$group}{$method}[0]};
        print "=back\n\n";
        print "Optional Parameters:\n\n";
        print "=over 4\n\n";
        print "=item * $_\n\n" for @{$validation{$group}{$method}[1]};
        print "=back\n\n";
    }
}