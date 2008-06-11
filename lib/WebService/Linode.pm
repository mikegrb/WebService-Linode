package WebService::Linode;

use warnings;
use strict;

use Carp;
use JSON;
use LWP::UserAgent;

use Data::Dumper;

=head1 NAME

WebService::Linode - Perl Interface to the Linode.com API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';
our $err;
our $errstr;

sub new {
	my ($package, %args) = @_;
	my $self;

	croak "Must specify API key." unless exists ($args{apikey});

	$self->{_apikey}	= $args{apikey};

	$self->{_nocache}	= $args{nocache}	|| 0;
	$self->{_debug}		= $args{debug}		|| 0;
	$self->{_fatal}		= $args{fatal}		|| 0;
	$self->{_nowarn}	= $args{nowarn}		|| 0;
	$self->{_apiurl}	= $args{apiurl}	|| 'https://www.linode.com/api/';

	$self->{_ua} = LWP::UserAgent->new;
	$self->{_ua}->agent("WebService::Linode/$WebService::Linode::VERSION ");

	bless $self, $package;
	return $self;
}

sub getDomainIDbyName {
	my $self = shift;
	my $name = shift;
	$self->_debug(10, 'getDomainIDbyName called for: ' . $name);

	if ($self->{_nocache}) {
		$self->_debug(10, 'Cache disabled calling domainList');
		my $domains = $self->domainList();
		foreach my $domain (@$domains) {
			return $domain->{domainid} if $domain->{domain} eq $name;
		}
	}
	else {
		$self->domainList unless exists($self->{_domains}{$name});
		return $self->{_domains}{$name} if exists($self->{_domains}{$name});
	}

	return;
}

sub domainList {
	my $self = shift;
	$self->_debug(10, 'domainList called');

	my $data = $self->_do_request( action => 'domainList' );
	if (defined($data)) {
		my @domains;
		for my $domain (@$data) {
			# lower case the keys (they come all caps)
			my $domain_data = _lc_keys($domain);
			# store zone id in $self->{_domains}{[name]}
			$self->{_domains}{$domain_data->{domain}} = 
				$domain_data->{domainid} unless $self->{_nocache};
			push @domains, $domain_data;
		}
		return \@domains;
	}
	return;
}

sub domainGet {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainGet called');
	my $domainid;

	if ($args{domain}) {
		$domainid = $self->getDomainIDbyName($args{domain});
		$self->_error(-1, "$args{domain} not found") unless $domainid;
		return unless $domainid;
	}
	else {
		$domainid = $args{domainid}
	}

	unless (defined ($domainid)) {
		$self->_error(-1, 'Must pass domainid or domain to domainGet');
		return;
	}

	my $data = $self->_do_request(
		action => 'domainGet', domainid => $domainid
	);

	return _lc_keys($data);
}

sub domainSave {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainSave called');

	if (!exists ($args{domainid})) {
		$self->_error(-1, "Must pass domainid to domainSave");
		return;
	}

	my $data = $self->_do_request( action => 'domainSave', %args);

	return unless exists ($data->{DomainID});
	return $data->{DomainID};
}

sub domainUpdate {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainUpdate called');

	if (!exists ($args{domainid})) {
		$self->_error(-1, "Must pass domainid to domainUpdate");
		return;
	}

	my %data = %{ $self->domainGet(domainid => $args{domainid}) };

	# overwrite changed items
	$data{$_} = $args{$_} for keys (%args);

	return $self->domainSave(%data);
}

sub domainDelete {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainDelete called');

	if (!exists ($args{domainid})) {
		$self->_error(-1, "Must pass domainid to domainDelete");
		return;
	}

	my $data = $self->_do_request( action => 'domainDelete', %args);

	return unless exists ($data->{DomainID});
	return $data->{DomainID};
}

sub domainResourceList {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainResourceList called');
	my $domainid;

	if ($args{domain}) {
		$domainid = $self->getDomainIDbyName($args{domain});
		$self->_error(-1, "$args{domain} not found") unless $domainid;
		return unless $domainid;
	}
	else {
		$domainid = $args{domainid}
	}

	unless (defined ($domainid)) {
		$self->_error(-1, 'Must pass domainid or domain to domainResourceList');
		return;
	}

	my $data = $self->_do_request(
		action => 'domainResourceList', domainid => $domainid
	);

	if (defined($data)) {
		my @RRs;
		push @RRs, _lc_keys($_) for (@$data);
		return \@RRs;
	}

	return;
}

sub domainResourceGet {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainResourceGet called');
	my $domainid;

	unless (exists ($args{resourceid})) {
		$self->_error(-1, 
			'Must pass domainid or domain and resourceid domainResourceGet');
		return;
	}

	my $data = $self->_do_request(
		action => 'domainResourceGet',
		domainid => $domainid,
		resourceid => $args{resourceid},
	);

	return unless defined ($data);

	return _lc_keys($data);
}

sub getResourceIDbyName {
	my ($self, %args) = @_;
	$self->_debug(10, 'getResourceIDbyName called');

	my $domainid = $args{domainid};
	if (!exists ($args{domainid}) && exists($args{domain}) ) {
		$domainid = $self->getDomainIDbyName($args{domain});
	}
	
	if (!(defined($domainid) && exists($args{name}))) {
		$self->_error(-1,
			'Must pass domain or domainid and (resource) name to getResourceIDbyName');
		return;
	}

	for my $rr ( @{ $self->domainResourceList(domainid => $domainid) } ) {
		return $rr->{resourceid} if $rr->{name} eq $args{name};
	}
}

sub domainResourceSave {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainResourceSave called');

	if (!exists ($args{resourceid})) {
		$self->_error(-1, "Must pass resourceid to domainResourceSave");
		return;
	}

	my $data = $self->_do_request( action => 'domainResourceSave', %args);

	return unless exists ($data->{ResourceID});
	return $data->{ResourceID};
}

sub domainResourceUpdate {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainResourceUpdate called');

	if (!exists ($args{resourceid})) {
		$self->_error(-1, "Must pass resourceid to domainResourceUpdate");
		return;
	}

	my %data = %{ $self->domainResourceGet(resourceid => $args{resourceid}) };

	# overwrite changed items
	$data{$_} = $args{$_} for keys (%args);

	return $self->domainResourceSave(%data);
}

sub domainResourceDelete {
	my ($self, %args) = @_;
	$self->_debug(10, 'domainResourceDelete called');

	if (!exists ($args{resourceid})) {
		$self->_error(-1, "Must pass resourceid to domainResourceDelete");
		return;
	}

	my $data = $self->_do_request( action => 'domainResourceDelete', %args);

	return unless exists ($data->{ResourceID});
	return $data->{ResourceID};
}

sub _lc_keys {
	my $hashref = shift;

	return { map { lc($_) => $hashref->{$_} } keys (%$hashref) };
}

sub _do_request {
	my ($self, %args) = @_;

	my $response = $self->_send_request(%args);
	return $self->_parse_response($response);
}

sub _send_request {
	my ($self, %args) = @_;

	{
		local $SIG{__WARN__} = sub {};
		$self->_debug(10, "About to send request: " . join(' ' , %args));	
	}

	return $self->{_ua}->post(
		$self->{_apiurl}, content => {api_key => $self->{_apikey}, %args }
	);
}

sub _parse_response {
	my $self = shift;
	my $response = shift;

	if ($response->content =~ m|ERRORARRAY|i) {
		my $json = from_json($response->content);
		if (scalar (@{$json->{ERRORARRAY}}) == 0) {
			return $json->{DATA};
		} else {
			# TODO this only returns the first error from the API
	
			my $msg = "API Error " . 
				$json->{ERRORARRAY}->[0]->{ERRORCODE} .  ": " .
				$json->{ERRORARRAY}->[0]->{ERRORMESSAGE};

			$self->_error(
				$json->{ERRORARRAY}->[0]->{ERRORCODE},
				$msg
			);
			return;
		}
	} else {
		$self->_error(-1, 'No JSON found');
		return;
	}
}

sub _error {
	my $self = shift;
	my $code = shift;
	my $msg  = shift;

	$err = $code;
	$errstr = $msg;

	croak $msg if $self->{_fatal};
	carp $msg unless $self->{_nowarn};
}

sub _debug {
	my $self  = shift;
	my $level = shift;
	my $msg   = shift;

	print STDERR $msg, "\n" if $self->{_debug} >= $level;
}

=head1 SYNOPSIS

This module provides a simple OOish interface to the Linode.com API.

Example usage:

	use WebService::Linode;

	my $api = new WebService::Linode(apikey => 'mmmcake');
	for my $domain (@{$api->listDomains}) {
		print $domain->{domainid}, "\n";
	}

=head1 METHODS

=head2 new

All methods take the same parameters as the Linode API itself does.  Field
names should be lower cased.  All caps fields from the Linode API will be
lower cased before returning the data.

TODO: actual docs
verbose 0-10, apikey, nocache, fatal, nowarn, apiurl

Errors mirror the perl DBI error handling method.
$WebService::Linode::err and ::errstr will be populated with the last error
number and string that occurred.  All errors generated within the module
are currently error code -1.  By default, will warn on errors as well, pass
a true value for fatal to die instead or nowarn to prevent the warnings.

verbose is 0-10 with 10 being the most and 0 being none

nocache disables some cacheing of domainname -> domainid

=head2 domainList

Returns a reference to an array.  The array contains one entry per domain
containing a reference to a hash with the data for that domain.  Keys in the
hash use the same names returned by the Linode API though the names have been
converted to lower-case.

=head2 domainGet

Requires domainid or domain passed in as args.  'domain' is the name of the
zone and will be mapped to domainid before executing the API method.
Returns a reference to a hash.  The hash contains the data for the domain
returned by the Linode API with the keys lower cased.

=head2 getDomainIDbyName

Returns the ID for a domain given the name.

=head2 domainSave

Requires domainid, use 0 to create a domain.

=head2 domainChange

Requires domainid, grabs current data, overwrites passed values then calls
domainSave for you.

=head2 domainDelete

Requires domainid, deletes the domain

=head2 domainResourceList

Requires domainid or domain passed in as args.  'domain' is the name of the
zone and will be mapped to domainid before executing the API method. 
Returns a reference to an array.  The array contains one entry per domain
containing a reference to a hash with the data for that domain.  Keys in the
hash use the same names returned by the Linode API though the names have been
converted to lower-case.

=head2 domainResourceGet

Requires domainid and resourceid.
Returns a reference to a hash.  The hash contains the data for the resource
record returned by the Linode API with the keys lower cased.

=head2 getResourceIDbyName

Takes a record name and domainid or domain and returns the resourceid

=head2 domainResourceSave

Requires domainid and resourceid.  Use 0 for resourceid to create.

=head2 domainResourceChange

Requires resourceid, grabs current data, overwrites passed values then calls
domainResourceSave for you.

=head2 domainResourceDelete

Requires resourceid, deletes the resource record.

=head1 AUTHOR

Michael Greb, C<< <mgreb@linode.com> >>

=head1 BUGS

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

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=WebService-Linode>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/WebService-Linode>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/WebService-Linode>

=item * Search CPAN

L<http://search.cpan.org/dist/WebService-Linode>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008 Linode, LLC, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1; # End of WebService::Linode
