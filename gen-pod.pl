#!/usr/bin/perl

use strict;
use warnings;

my %validation = (
    account => { info => [ [], [] ], },
    api => { spec => [ [], [] ], },
    avail => {
        datacenters => [ [], [] ],
        distributions => [ [], [ 'distributionid' ] ],
        kernels => [ [], [ 'isxen', 'kernelid' ] ],
        linodeplans => [ [ 'planid' ], [] ],
        stackscripts => [ [], [qw( keywords distributionid distributionvendor )] ],
    },
    domain => {
        create => [ [ 'domain', 'type' ], [qw( status ttl_sec expire_sec refresh_sec master_ips soa_email retry_sec axfr_ips description )] ],
        delete => [ [ 'domainid' ], [] ],
        list => [ [], [ 'domainid' ] ],
        update => [ [ 'domainid' ], [qw( status domain ttl_sec expire_sec type refresh_sec master_ips soa_email axfr_ips retry_sec description )] ],
    },
    domain_resource => {
        create => [ [], [qw( target ttl_sec protocol priority port weight name )] ],
        delete => [ [ 'resourceid', 'domainid' ], [] ],
        list => [ [ 'domainid' ], [ 'resourceid' ] ],
        update => [ [ 'resourceid', 'domainid' ], [qw( target ttl_sec port weight priority protocol name )] ],
    },
    linode => {
        boot => [ [ 'linodeid' ], [ 'configid' ] ],
        clone => [ [qw( planid paymentterm linodeid datacenterid )], [] ],
        create => [ [qw( planid label paymentterm datacenterid )], [qw( alert_bwquota_threshold alert_bwin_threshold alert_cpu_threshold lpm_displaygroup alert_bwin_enabled backupwindow alert_cpu_enabled backupweeklyday alert_diskio_enabled alert_bwquota_enabled watchdog alert_bwout_enabled alert_bwout_threshold alert_diskio_threshold )] ],
        delete => [ [ 'linodeid' ], [ 'skipchecks' ] ],
        list => [ [], [ 'linodeid' ] ],
        reboot => [ [ 'linodeid' ], [ 'configid' ] ],
        resize => [ [ 'planid', 'linodeid' ], [] ],
        shutdown => [ [ 'linodeid' ], [] ],
        update => [ [ 'linodeid' ], [qw( alert_bwquota_threshold alert_bwin_threshold alert_cpu_threshold alert_cpu_enabled alert_diskio_enabled label backupweeklyday alert_bwquota_enabled watchdog lpm_displaygroup alert_bwin_enabled alert_bwout_enabled alert_bwout_threshold alert_diskio_threshold backupwindow )] ],
    },
    linode_config => {
        create => [ [ 'label', 'kernelid' ], [qw( comments helper_xen devtmpfs_automount rootdevicecustom rootdevicero helper_depmod helper_disableupdatedb disklist runlevel rootdevicenum ramlimit )] ],
        delete => [ [ 'configid', 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'configid' ] ],
        update => [ [ 'configid', 'linodeid' ], [qw( comments helper_xen devtmpfs_automount rootdevicecustom rootdevicero label helper_depmod helper_disableupdatedb rootdevicenum disklist runlevel kernelid ramlimit )] ],
    },
    linode_disk => {
        create => [ [ 'linodeid', 'label' ], [ 'isreadonly' ] ],
        createfromdistribution => [ [qw( size linodeid rootpass distributionid label )], [ 'rootsshkey' ] ],
        createfromstackscript => [ [qw( size linodeid rootpass distributionid stackscriptudfresponses stackscriptid label )], [] ],
        delete => [ [ 'diskid', 'linodeid' ], [] ],
        duplicate => [ [ 'diskid', 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'diskid' ] ],
        resize => [ [qw( diskid linodeid size )], [] ],
        update => [ [ 'diskid', 'linodeid' ], [ 'label', 'isreadonly' ] ],
    },
    linode_ip => {
        addprivate => [ [ 'linodeid' ], [] ],
        list => [ [ 'linodeid' ], [ 'ipaddressid' ] ],
    },
    linode_job => { list => [ [ 'linodeid' ], [ 'pendingonly', 'jobid' ] ], },
    nodebalancer => {
        create => [ [ 'paymentterm', 'datacenterid' ], [ 'label', 'clientconnthrottle' ] ],
        delete => [ [ 'nodebalancerid' ], [] ],
        list => [ [], [ 'nodebalancerid' ] ],
        update => [ [ 'nodebalancerid' ], [ 'label', 'clientconnthrottle' ] ],
    },
    nodebalancer_config => {
        create => [ [], [qw( check_path check_body stickiness port check check_timeout check_attempts check_interval protocol algorithm )] ],
        delete => [ [ 'configid' ], [] ],
        list => [ [ 'nodebalancerid' ], [ 'configid' ] ],
        update => [ [ 'configid' ], [qw( check_path check_body stickiness port check check_timeout check_attempts check_interval protocol algorithm )] ],
    },
    nodebalancer_node => {
        create => [ [ 'address', 'label' ], [ 'mode', 'weight' ] ],
        delete => [ [ 'nodeid' ], [] ],
        list => [ [ 'configid' ], [ 'nodeid' ] ],
        update => [ [ 'nodeid' ], [qw( address mode label weight )] ],
    },
    stackscript => {
        create => [ [qw( script label distributionidlist )], [qw( rev_note ispublic description )] ],
        delete => [ [ 'stackscriptid' ], [] ],
        list => [ [], [ 'stackscriptid' ] ],
        update => [ [ 'stackscriptid' ], [qw( script rev_note ispublic label description distributionidlist )] ],
    },
    test => { echo => [ [], [] ], },
    user => { getapikey => [ [ 'password', 'username' ], [] ], },
);

foreach my $group (qw{avail domain domain_resource linode linode_config linode_disk linode_ip linode_job stackscript}) {
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