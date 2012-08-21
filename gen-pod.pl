#!/usr/bin/perl

use strict;
use warnings;

my %validation = (
    account => {
        info => [ [], [] ],
    },
    api => {
        spec => [ [], [] ],
    },
    avail => {
        datacenters => [ [], [] ],
        distributions => [ [], [ 'distributionid' ] ],
        kernels => [ [], [ 'isxen', 'kernelid' ] ],
        linodeplans => [ [ 'planid' ], [] ],
        stackscripts => [ [], [qw( keywords distributionid distributionvendor )] ],
    },
    domain => {
        create => [ [ 'domain', 'type' ], [qw( status ttl_sec expire_sec master_ips refresh_sec soa_email retry_sec axfr_ips description )] ],
        delete => [ [ 'domainid' ], [] ],
        list => [ [], [ 'domainid' ] ],
        update => [ [ 'domainid' ], [qw( status domain ttl_sec expire_sec type master_ips refresh_sec soa_email axfr_ips retry_sec description )] ],
    },
    domain_resource => {
        create => [ [qw( resourceid domainid type )], [qw( target ttl_sec port weight priority protocol name )] ],
        delete => [ [ 'resourceid', 'domainid' ], [] ],
        list => [ [ 'domainid' ], [ 'resourceid' ] ],
        update => [ [ 'resourceid' ], [qw( target domainid ttl_sec port weight priority protocol name )] ],
    },
    linode => {
        boot => [ [ 'linodeid' ], [ 'configid' ] ],
        clone => [ [qw( planid paymentterm linodeid datacenterid )], [] ],
        create => [ [qw( planid paymentterm datacenterid )], [] ],
        delete => [ [ 'linodeid' ], [ 'skipchecks' ] ],
        list => [ [], [ 'linodeid' ] ],
        reboot => [ [ 'linodeid' ], [ 'configid' ] ],
        resize => [ [ 'planid', 'linodeid' ], [] ],
        shutdown => [ [ 'linodeid' ], [] ],
        update => [ [ 'linodeid' ], [qw( alert_bwquota_threshold alert_bwin_threshold alert_cpu_threshold alert_cpu_enabled alert_diskio_enabled label backupweeklyday alert_bwquota_enabled watchdog lpm_displaygroup alert_bwin_enabled alert_bwout_enabled alert_bwout_threshold alert_diskio_threshold backupwindow )] ],
    },
    linode_config => {
        create => [ [qw( configid linodeid label kernelid )], [qw( comments helper_xen devtmpfs_automount rootdevicecustom rootdevicero helper_depmod helper_disableupdatedb rootdevicenum disklist runlevel ramlimit )] ],
        delete => [ [ 'configid', 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'configid' ] ],
        update => [ [ 'configid' ], [qw( comments helper_xen devtmpfs_automount rootdevicecustom linodeid rootdevicero label helper_depmod helper_disableupdatedb rootdevicenum disklist runlevel kernelid ramlimit )] ],
    },
    linode_disk => {
        create => [ [qw( type size linodeid label )], [] ],
        createfromdistribution => [ [qw( size rootpass linodeid distributionid label )], [ 'rootsshkey' ] ],
        createfromstackscript => [ [qw( size linodeid rootpass distributionid stackscriptudfresponses stackscriptid label )], [] ],
        delete => [ [ 'diskid', 'linodeid' ], [] ],
        duplicate => [ [ 'diskid', 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'diskid' ] ],
        resize => [ [qw( diskid linodeid size )], [] ],
        update => [ [ 'diskid' ], [qw( linodeid isreadonly label )] ],
    },
    linode_ip => {
        addprivate => [ [ 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'ipaddressid' ] ],
    },
    linode_job => {
        list => [ [ 'linodeid' ], [ 'pendingonly', 'jobid' ] ],
    },
    nodebalancer => {
        create => [ [ 'paymentterm', 'datacenterid' ], [ 'label', 'clientconnthrottle' ] ],
        delete => [ [ 'nodebalancerid' ], [] ],
        list => [ [], [ 'nodebalancerid' ] ],
        update => [ [ 'nodebalancerid' ], [ 'label', 'clientconnthrottle' ] ],
    },
    nodebalancer_config => {
        create => [ [ 'nodebalancerid' ], [qw( check_path check_body stickiness port check check_timeout check_attempts check_interval protocol algorithm )] ],
        delete => [ [ 'configid' ], [] ],
        list => [ [ 'nodebalancerid' ], [ 'configid' ] ],
        update => [ [ 'configid' ], [qw( check_path check_body stickiness port check_timeout check check_attempts check_interval protocol algorithm )] ],
    },
    nodebalancer_node => {
        create => [ [qw( configid address label )], [ 'mode', 'weight' ] ],
        delete => [ [ 'nodeid' ], [] ],
        list => [ [ 'configid' ], [ 'nodeid' ] ],
        update => [ [ 'nodeid' ], [qw( address mode weight label )] ],
    },
    stackscript => {
        create => [ [qw( script distributionidlist label )], [qw( rev_note description ispublic )] ],
        delete => [ [ 'stackscriptid' ], [] ],
        list => [ [], [ 'stackscriptid' ] ],
        update => [ [ 'stackscriptid' ], [qw( script rev_note ispublic label distributionidlist description )] ],
    },
    test => {
        echo => [ [], [] ],
    },
    user => {
        getapikey => [ [ 'password', 'username' ], [] ],
    },
);

foreach my $group (qw{avail domain domain_resource linode linode_config linode_disk linode_ip linode_job stackscript nodeblancer nodebalancer_config  nodebalancer_node  user}) {
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