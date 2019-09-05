package WebService::Linode::Base;

use warnings;
use strict;

use Carp;
use JSON;
use LWP::UserAgent;

use Data::Dumper;

=head1 NAME

WebService::Linode::Base - Perl Interface to the Linode.com API.

=cut

our $VERSION = '0.29';
our $err;
our $errstr;

sub new {
    my ($package, %args) = @_;
    my $self;

    $self->{_apikey}  = $args{apikey} if $args{apikey};

    $self->{_nocache} = $args{nocache} || 0;
    $self->{_debug}   = $args{debug}   || 0;
    $self->{_fatal}   = $args{fatal}   || 0;
    $self->{_nowarn}  = $args{nowarn}  || 0;
    $self->{_apiurl}  = $args{apiurl}  || 'https://api.linode.com/api/';

    # env api url supercedes all
    $self->{_apiurl}  = $ENV{LINODE_API_URL} if $ENV{LINODE_API_URL};

    $self->{_ua} = LWP::UserAgent->new;
    $self->{_ua}->agent("WebService::Linode::Base/$WebService::Linode::Base::VERSION ");
    $self->{_ua}->agent($args{useragent}) if $args{useragent};

    # set up storage for queued requests
    $self->{_batch_queue} = [];

    bless $self, $package;
    return $self;
}

sub apikey {
    my $self = shift;
    $self->{_apikey} = shift if @_ == 1;
    return $self->{_apikey};
}

sub do_request {
    my ($self, %args) = @_;

    my $response = $self->send_request(%args);
    return $self->parse_response($response);
}

sub send_request {
    my ($self, %args) = @_;

    {
        local $SIG{__WARN__} = sub {};
        $self->_debug(10, "About to send request: " . join(' ' , %args));
    }

    $args{api_key} = $self->{_apikey} if $self->{_apikey};

    return $self->{_ua}->post( $self->{_apiurl}, content => { %args } );
}

sub queue_request {
    my ($self, %args) = @_;
    my $queue = $self->{_batch_queue};

    $self->_debug(10, "Queueing request for batch: " . join(' ' , %args));
    push @$queue, \%args;

    # return current number of items in the queue
    return scalar @$queue;
}

sub list_queue {
    my $self = shift;
    my $queue = $self->{_batch_queue};
    return @$queue;
}

sub clear_queue {
    my $self = shift;
    my $queue = $self->{_batch_queue};
    @$queue = ();
    return @$queue;
}

sub process_queue {
    my ($self,$maxitems) = @_;
    my $queue = $self->{_batch_queue};
    # Default to processing the entire queue, cap at queue length
    $maxitems = @$queue if not defined $maxitems or $maxitems > @$queue;

    my @todo = splice @$queue, 0, $maxitems;
    my $batch_json = to_json( \@todo );

    return $self->do_request( api_action=>'batch', api_requestArray=>$batch_json );
}

sub parse_response {
    my $self = shift;
    my $response = shift;

    if ( $response->content =~ m|ERRORARRAY|i ) {
        $self->_debug(10, "Received response: " . $response->content );
        my $json = from_json( $response->content );
        if ( ref $json eq 'ARRAY' ) {
            return map { $self->_parse_api_response_data( $_ ) } @$json;
        }
        else {
            return $self->_parse_api_response_data( $json );
        }
    }
    elsif ( $response->status_line ) {
        $self->_error( -1, $response->status_line );
        return;
    }
    else {
        $self->_error( -1, 'No JSON found' );
        return;
    }
}

sub _parse_api_response_data {
    my $self = shift;
    my $rdata = shift;

    my $errors = $rdata->{ERRORARRAY};
    if ( not $errors or ref $errors ne 'ARRAY' ) {
        $self->_error( -1, 'Invalid response: ERRORARRAY missing or invalid' );
        return;
    }

    return $rdata->{DATA} if @$errors == 0;
    return $rdata->{DATA} if @$errors == 1 and $errors->[0]{ERRORCODE} == 0;

    # If we've reached here, there's an error to report
    # TODO this only returns the first error from the API
    my $error = $rdata->{ERRORARRAY}->[0];
    my $msg = "API Error $error->{ERRORCODE}: $error->{ERRORMESSAGE}";
    $self->_error( $error->{ERRORCODE}, $msg );
    return;
}

sub _lc_keys {
    my ($self, $hashref) = @_;

    return { map { lc($_) => $hashref->{$_} } keys (%$hashref) };
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

    use WebService::Linode::Base;

    my $api = WebService::Linode::Base->new(apikey => 'mmmcake');
    my $data = $api->do_request( api_action => 'domains.list' );

=head1 METHODS

=head2 new

All methods take the same parameters as the Linode API itself does.  Field
names should be lower cased.  All caps fields from the Linode API will be
lower cased before returning the data.

Accepts a hash as an argument.  apikey is the only required parameter
specifying your Linode API key.

Errors mirror the perl DBI error handling method.
$WebService::Linode::Base::err and ::errstr will be populated with the last error
number and string that occurred.  All errors generated within the module
are currently error code -1.  By default, will warn on errors as well, pass
a true value for fatal to die instead, or nowarn to prevent the warnings.

verbose is 0-10 with 10 being the most and 0 being none

useragent if passed gets passed on to the LWP::UserAgent agent method to set
a custom user agent header on HTTP requests.

apiurl if passed overides the default URL for API requests.  You may also use
the environment variable LINODE_API_URL.  If set, the environment variable
supersedes any apiurl argument supplied to the constructor, useful for testing.

=head2 send_request

Sends a request to the API, takes a hash of name=>value pairs.  Returns an
HTTP::Response object.

=head2 parse_response

Takes an HTTP::Response object and parses the API
response returning just the DATA section.

=head2 do_request

Executes the send_request method, parses the response with the parse_response
method and returns the data.

=head2 queue_request

Takes same arguments as send_request, but queues the request to be handled by
a single batch request later.

=head2 list_queue

Returns list of queued requests.

=head2 clear_queue

Clears batch request queue.

=head2 process_queue

Sends queued items in a batch request.  Takes an optional number of items to
send in the batch request, defaulting to all queued requests.  Returns an api
reponse for each batch item.

=head2 apikey

Takes one optional argument, an apikey that if passed replaces the key
currently in use.  Returns the current (or new) apikey.

Returns the apikey

=head1 AUTHOR

Michael Greb, C<< <mgreb@linode.com> >>

=head1 BUGS

This module does not yet support the Linode API batch method, patches welcome.

Please report any bugs or feature requests to C<bug-webservice-linode
at rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=WebService-Linode>.  I will
be notified, and then you'll automatically be notified of progress on your
bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc WebService::Linode::Base


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


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2008-2014 Michael Greb, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

'urmom';
