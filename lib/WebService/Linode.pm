package WebService::Linode;

require 5.006000;

use warnings;
use strict;

use Carp;
use List::Util qw(first);
use WebService::Linode::Base;

our $VERSION = '0.08';
our @ISA     = ("WebService::Linode::Base");
our $AUTOLOAD;

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

sub AUTOLOAD {
    (my $name = $AUTOLOAD) =~ s/.+:://;
    return if $name eq 'DESTROY';
    if ($name =~ m/^(.*?)_([^_]+)$/) {
        my ($thing, $action) = ($1, $2);
        if (exists $validation{$thing} && exists $validation{$thing}{$action}) {
            no strict 'refs';
            *{ $AUTOLOAD } = sub {
                my ($self, %args) = @_;
                for my $req ( @{ $validation{$thing}{$action}[0] } ) {
                    if ( !exists $args{$req} ) {
                        carp "Missing required argument $req for ${thing}_${action}";
                        return;
                    }
                }
                for my $given ( keys %args ) {
                    if (!first { $_ eq $given }
                        @{ $validation{$thing}{$action}[0] },
                        @{ $validation{$thing}{$action}[1] } )
                    {   carp "Unknown argument $given for ${thing}_${action}";
                        return;
                    }
                }
                (my $apiAction = "${thing}_${action}") =~ s/_/./g;
                my $data = $self->do_request( api_action => $apiAction, %args);
                return [ map { $self->_lc_keys($_) } @$data ] if ref $data eq 'ARRAY';
                return $self->_lc_keys($data) if ref $data eq 'HASH';
                return $data;
            };
            goto &{ $AUTOLOAD };
        }
        else {
            carp "Can't call ${thing}_${action}";
            return;
        }
        return;
    }
    croak "Undefined subroutine \&$AUTOLOAD called";
}

sub getDomainIDbyName {
    my ($self, $name) = @_;
    foreach my $domain (@{$self->domain_list()}) {
        return $domain->{domainid} if $domain->{domain} eq $name;
    }
    return;
}

sub getDomainResourceIDbyName {
    my ( $self, %args ) = @_;
    $self->_debug( 10, 'getResourceIDbyName called' );

    my $domainid = $args{domainid};
    if ( !exists( $args{domainid} ) && exists( $args{domain} ) ) {
        $domainid = $self->getDomainIDbyName( $args{domain} );
    }

    if ( !( defined($domainid) && exists( $args{name} ) ) ) {
        $self->_error( -1,
            'Must pass domain or domainid and (resource) name to getResourceIDbyName'
        );
        return;
    }

    for my $rr ( @{ $self->domain_resource_list( domainid => $domainid ) } ) {
        return $rr->{resourceid} if $rr->{name} eq $args{name};
    }
}

'mmm, cake';
__END__

=head1 NAME

WebService::Linode - Perl Interface to the Linode.com API.

=head1 VERSION

Version 0.08

=head1 SYNOPSIS

    my $api = WebService::Linode->new( apikey => 'your api key here');
    print Dumper($api->linode_list);
    $api->linode_reboot(linodeid=>242);

This module implements the Linode.com api methods.  Linode methods have had
dots replaced with underscores to generate the perl method name.  All keys
and parameters have been lower cased but returned data remains otherwise the
same.  For additional information see L<http://www.linode.com/api/autodoc.cfm>

=head1 Methods from the Linode API

=head3 avail_stackscripts

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * keywords

=item * distributionid

=item * distributionvendor

=back

=head3 avail_kernels

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * isxen

=item * kernelid

=back

=head3 avail_linodeplans

Required Parameters:

=over 4

=item * planid

=back

Optional Parameters:

=over 4

=back

=head3 avail_datacenters

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=back

=head3 avail_distributions

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * distributionid

=back

=head3 domain_create

Required Parameters:

=over 4

=item * domain

=item * type

=back

Optional Parameters:

=over 4

=item * status

=item * ttl_sec

=item * expire_sec

=item * refresh_sec

=item * master_ips

=item * soa_email

=item * retry_sec

=item * axfr_ips

=item * description

=back

=head3 domain_delete

Required Parameters:

=over 4

=item * domainid

=back

Optional Parameters:

=over 4

=back

=head3 domain_update

Required Parameters:

=over 4

=item * domainid

=back

Optional Parameters:

=over 4

=item * status

=item * domain

=item * ttl_sec

=item * expire_sec

=item * type

=item * refresh_sec

=item * master_ips

=item * soa_email

=item * axfr_ips

=item * retry_sec

=item * description

=back

=head3 domain_list

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * domainid

=back

=head3 domain_resource_create

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * target

=item * ttl_sec

=item * protocol

=item * priority

=item * port

=item * weight

=item * name

=back

=head3 domain_resource_delete

Required Parameters:

=over 4

=item * resourceid

=item * domainid

=back

Optional Parameters:

=over 4

=back

=head3 domain_resource_update

Required Parameters:

=over 4

=item * resourceid

=item * domainid

=back

Optional Parameters:

=over 4

=item * target

=item * ttl_sec

=item * port

=item * weight

=item * priority

=item * protocol

=item * name

=back

=head3 domain_resource_list

Required Parameters:

=over 4

=item * domainid

=back

Optional Parameters:

=over 4

=item * resourceid

=back

=head3 linode_create

Required Parameters:

=over 4

=item * planid

=item * label

=item * paymentterm

=item * datacenterid

=back

Optional Parameters:

=over 4

=item * alert_bwquota_threshold

=item * alert_bwin_threshold

=item * alert_cpu_threshold

=item * lpm_displaygroup

=item * alert_bwin_enabled

=item * backupwindow

=item * alert_cpu_enabled

=item * backupweeklyday

=item * alert_diskio_enabled

=item * alert_bwquota_enabled

=item * watchdog

=item * alert_bwout_enabled

=item * alert_bwout_threshold

=item * alert_diskio_threshold

=back

=head3 linode_resize

Required Parameters:

=over 4

=item * planid

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_reboot

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * configid

=back

=head3 linode_boot

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * configid

=back

=head3 linode_clone

Required Parameters:

=over 4

=item * planid

=item * paymentterm

=item * linodeid

=item * datacenterid

=back

Optional Parameters:

=over 4

=back

=head3 linode_shutdown

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_delete

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * skipchecks

=back

=head3 linode_update

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * alert_bwquota_threshold

=item * alert_bwin_threshold

=item * alert_cpu_threshold

=item * alert_cpu_enabled

=item * alert_diskio_enabled

=item * label

=item * backupweeklyday

=item * alert_bwquota_enabled

=item * watchdog

=item * lpm_displaygroup

=item * alert_bwin_enabled

=item * alert_bwout_enabled

=item * alert_bwout_threshold

=item * alert_diskio_threshold

=item * backupwindow

=back

=head3 linode_list

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * linodeid

=back

=head3 linode_config_create

Required Parameters:

=over 4

=item * label

=item * kernelid

=back

Optional Parameters:

=over 4

=item * comments

=item * helper_xen

=item * devtmpfs_automount

=item * rootdevicecustom

=item * rootdevicero

=item * helper_depmod

=item * helper_disableupdatedb

=item * disklist

=item * runlevel

=item * rootdevicenum

=item * ramlimit

=back

=head3 linode_config_delete

Required Parameters:

=over 4

=item * configid

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_config_update

Required Parameters:

=over 4

=item * configid

=item * linodeid

=back

Optional Parameters:

=over 4

=item * comments

=item * helper_xen

=item * devtmpfs_automount

=item * rootdevicecustom

=item * rootdevicero

=item * label

=item * helper_depmod

=item * helper_disableupdatedb

=item * rootdevicenum

=item * disklist

=item * runlevel

=item * kernelid

=item * ramlimit

=back

=head3 linode_config_list

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * configid

=back

=head3 linode_disk_create

Required Parameters:

=over 4

=item * linodeid

=item * label

=back

Optional Parameters:

=over 4

=item * isreadonly

=back

=head3 linode_disk_resize

Required Parameters:

=over 4

=item * diskid

=item * linodeid

=item * size

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_createfromdistribution

Required Parameters:

=over 4

=item * size

=item * linodeid

=item * rootpass

=item * distributionid

=item * label

=back

Optional Parameters:

=over 4

=item * rootsshkey

=back

=head3 linode_disk_duplicate

Required Parameters:

=over 4

=item * diskid

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_delete

Required Parameters:

=over 4

=item * diskid

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_update

Required Parameters:

=over 4

=item * diskid

=item * linodeid

=back

Optional Parameters:

=over 4

=item * label

=item * isreadonly

=back

=head3 linode_disk_list

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * diskid

=back

=head3 linode_disk_createfromstackscript

Required Parameters:

=over 4

=item * size

=item * linodeid

=item * rootpass

=item * distributionid

=item * stackscriptudfresponses

=item * stackscriptid

=item * label

=back

Optional Parameters:

=over 4

=back

=head3 linode_ip_addprivate

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=back

=head3 linode_ip_list

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * ipaddressid

=back

=head3 linode_job_list

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * pendingonly

=item * jobid

=back

=head3 stackscript_create

Required Parameters:

=over 4

=item * script

=item * label

=item * distributionidlist

=back

Optional Parameters:

=over 4

=item * rev_note

=item * ispublic

=item * description

=back

=head3 stackscript_delete

Required Parameters:

=over 4

=item * stackscriptid

=back

Optional Parameters:

=over 4

=back

=head3 stackscript_update

Required Parameters:

=over 4

=item * stackscriptid

=back

Optional Parameters:

=over 4

=item * script

=item * rev_note

=item * ispublic

=item * label

=item * description

=item * distributionidlist

=back

=head3 stackscript_list

Required Parameters:

=over 4

=back

Optional Parameters:

=over 4

=item * stackscriptid

=back

=head1 Additional Helper Methods

=head3 getDomainIDbyName( domain => 'example.com' )

Returns the ID for a domain given the name.

=head3 getDomainResourceIDbyName( domainid => 242, name => 'www')

Takes a record name and domainid or domain and returns the resourceid.

=head1 AUTHORS

=over

=item * Michael Greb, C<< <mgreb@linode.com> >>

=item * Stan "The Man" Schwertly C<< <stan@linode.com> >>

=back

=head1 BUGS

This module does not yet support the Linode API batch method, patches welcome.

Please report any bugs or feature requests to C<bug-webservice-linode
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Linode>.  I will
be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Linode


You can also look for information at:

=over 4

=item * Module Repo

L<http://git.thegrebs.com/?p=WebService-Linode;a=summary>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Linode>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Linode>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Linode>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Linode>

=back

=head1 COPYRIGHT & LICENSE

Copyright 2008-2009 Linode, LLC, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

