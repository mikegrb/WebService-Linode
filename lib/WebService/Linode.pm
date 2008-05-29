package WebService::Linode;

use warnings;
use strict;

use Carp;
use JSON;
use LWP::UserAgent;

use Data::Dumper

=head1 NAME

WebService::Linode - Perl Interface to the Linode.com API.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

sub new {
	my ($package, %args) = @_;
	my $self;

	croak "Must specify API key." unless exists ($args{apikey});

	$self->{_apikey}	= $args{apikey};
	$self->{_nocache}	= $args{nocache}	|| 0;
	$self->{_debug}		= $args{debug}		|| 0;

	# this shouldn't need to be changed but who knows
	$self->{_apiurl} = 'http://lindev1.linlan/api/';

	$self->{_ua} = LWP::UserAgent->new;
	$self->{_ua}->agent("WebService::Linode/$WebService::Linode::VERSION ");

	bless $self, $package;
	return $self;
}

sub listDomains {
	my $self = shift;
	$self->_debug(10, 'listDomains called');

	my $data = $self->_do_request( action => 'listDomains' );
	if (defined($data)) {
		my @domains;
		for my $domain (@$data) {
			# lower case the keys (they come all caps)
			my $domain_data = _lc_keys($domain);
			# store zone id in $self->{_domains}{[name]}
			$self->{_domains}{$domain_data->{domain}} = $domain_data->{domainid} unless $self->{_nocache};
			push @domains, $domain_data;
		}
		return \@domains;
	}

	return;
}

sub getDomainIDbyName {
	my $self = shift;
	my $name = shift;
	$self->_debug(10, 'getDomainIDbyName called for: ' . $name);


	if ($self->{_nocache}) {
		$self->_debug(10, 'Cache disabled calling listDomains');
		my $domains = $self->listDomains();
		foreach my $domain (@$domains) {
			return $domain->{domainid} if $domain->{domain} eq $name;
		}
	}
	else {
		$self->listDomains unless exists($self->{_domains}{$name});
		return $self->{_domains}{$name} if exists($self->{_domains}{$name});
	}

	return;
}

sub getDomain {
	my ($self, %args) = @_;
	$self->_debug(10, 'getDomain called');
	my $domainid;

	if ($args{domain}) {
		$domainid = $self->getDomainIDbyName($args{domain});
		carp "$args{domain} does not exist." unless $domainid;
		return unless $domainid;
	}
	else {
		$domainid = $args{domainid}
	}

	unless (defined ($domainid)) {
		carp "Must pass domain id or name to getDomain.";
		return;
	}

	my $data = $self->_do_request( action => 'getDomain', domainid => $domainid );

	return _lc_keys($data);
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

	return $self->{_ua}->post(
		$self->{_apiurl}, content => {api_key => $self->{_apikey}, %args }
	);
}

sub _parse_response {
	my $self = shift;
	my $response = shift;

	if ($response->content =~ m|<json>(.*?)</json>|i) {
		my $json = from_json($1);
		if ($json->{REQUESTSTATUS} == 0) {
			return $json->{DATA};
		} else {
			warn "Crap!";
			return;
		}
	} else {
		warn "No JSON retruned, oh noes.";
		return;
	}
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

verbose 0-10, apikey, nocache

=head2 listDomains

Returns a reference to an array.  The array contains one entry per domain
containing a reference to a hash with the data for that domain.  Keys in the
hash use the same names returned by the Linode API though the names have been
converted to lower-case.

=head2 getDomain

Returns a reference to a hash.  The hash contains the data for the domain
returned by the Linode API with the keys lower cased.

=head2 getDomainIDbyName

Returns the ID for a domain given the name.

=head1 AUTHOR

Michael Greb, C<< <mgreb@linode.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-webservice-linode at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Linode>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

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
