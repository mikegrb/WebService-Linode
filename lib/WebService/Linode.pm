package WebService::Linode;

require v5.6.0;

use warnings;
use strict;

use Carp;
use List::Util qw(first);
use WebService::Linode::Base;

our $VERSION = '0.04';
our @ISA     = ("WebService::Linode::Base");
our $AUTOLOAD;

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

Version 0.04

=head1 SYNOPSIS

    my $api = new WebService::Linode( apikey => 'your api key here');
    print Dumper($api->linode_list);
    $api->linode_reboot(linodeid=>242);

This module implements the Linode.com api methods.  Linode methods have had
dots replaced with underscores to generate the perl method name.  All keys
and parameters have been lower cased but returned data remains otherwise the
same.  For additional information see L<http://www.linode.com/api/autodoc.cfm>

=head1 Methods from the Linode API

=head3 avail_kernels

Optional Parameters:

=over 4

=item * kernelid

=item * isxen

=back

=head3 avail_linodeplans

Optional Parameters:

=over 4

=item * plainid

=back

=head3 avail_datacenters

=head3 avail_distributions

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

=item * description

=item * soa_email

=item * refresh_sec

=item * retry_sec

=item * expire_sec

=item * ttl_sec

=item * status

=item * master_ips

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

=item * domain

=item * description

=item * type

=item * soa_email

=item * refresh_sec

=item * retry_sec

=item * expire_sec

=item * ttl_sec

=item * status

=item * master_ips

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

=item * domainid

=item * type

=back

Optional Parameters:

=over 4

=item * name

=item * target

=item * priority

=item * weight

=item * port

=item * protocol

=item * ttl_sec

=back

=head3 domain_resource_delete

Required Parameters:

=over 4

=item * domainid

=item * resourceid

=back

Optional Parameters:

=over 4

=back

=head3 domain_resource_update

Required Parameters:

=over 4

=item * domainid

=item * resourceid

=back

Optional Parameters:

=over 4

=item * name

=item * target

=item * priority

=item * weight

=item * port

=item * protocol

=item * ttl_sec

=back

=head3 domain_resource_list

Required Parameters:

=over 4

=item * domainid

=back

Optional Parameters:

=over 4

=item * resouceid

=back

=head3 linode_create

Required Parameters:

=over 4

=item * datacenterid

=item * planid

=item * paymentterm

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

=back

=head3 linode_update

Required Parameters:

=over 4

=item * linodeid

=back

Optional Parameters:

=over 4

=item * label

=item * lpm_displaygroup

=item * alert_cpu_enabled

=item * alert_cpu_threshold

=item * alert_diskio_enabled

=item * alert_diskio_threshold

=item * alert_bwin_enabled

=item * alert_bwin_threshold

=item * alert_bwout_enabled

=item * alert_bwout_threshold

=item * alert_bwquota_enabled

=item * alert_bwquota_threshold

=item * backupwindow

=item * backupweeklyday

=item * watchdog

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

=item * linodeid

=item * kernelid

=item * label

=back

Optional Parameters:

=over 4

=item * comments

=item * ramlimit

=item * disklist

=item * runlevel

=item * rootdevicenum

=item * rootdevicecustom

=item * rootdevicero

=item * helper_disableupdatedb

=item * helper_xen

=item * helper_depmod

=back

=head3 linode_config_delete

Required Parameters:

=over 4

=item * linodeid

=item * configid

=back

Optional Parameters:

=over 4

=back

=head3 linode_config_update

Required Parameters:

=over 4

=item * linodeid

=item * configid

=back

Optional Parameters:

=over 4

=item * kernelid

=item * label

=item * comments

=item * ramlimit

=item * disklist

=item * runlevel

=item * rootdevicenum

=item * rootdevicecustom

=item * rootdevicero

=item * helper_xen

=item * helper_disableupdatedb

=item * helper_depmod

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

=item * type

=item * size

=back

Optional Parameters:

=over 4

=item * isreadonly

=back

=head3 linode_disk_resize

Required Parameters:

=over 4

=item * linodeid

=item * diskid

=item * size

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_createfromdistribution

Required Parameters:

=over 4

=item * linodeid

=item * distributionid

=item * label

=item * size

=item * rootpass

=back

Optional Parameters:

=over 4

=item * rootsshkey

=back

=head3 linode_disk_duplicate

Required Parameters:

=over 4

=item * linodeid

=item * diskid

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_delete

Required Parameters:

=over 4

=item * linodeid

=item * diskid

=back

Optional Parameters:

=over 4

=back

=head3 linode_disk_update

Required Parameters:

=over 4

=item * linodeid

=item * diskid

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

=item * jobid

=item * pendingonly

=back

=head1 Additional Helper Methods

=head3 getDomainIDbyName( domain => 'example.com' )

Returns the ID for a domain given the name.

=head3 getDomainResourceIDbyName( domainid => 242, name => 'www')

Takes a record name and domainid or domain and returns the resourceid.

=head1 AUTHORS

Michael Greb, C<< <mgreb@linode.com> >>, and Stan "The Intern Man" Schwertly

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

