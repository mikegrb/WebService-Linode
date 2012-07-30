#!/usr/bin/env perl

use strict;
use warnings;

use Mojo::UserAgent;

my $spec       = get_spec();
my $validation = parse_spec($spec);
dump_validation($validation);

sub get_spec {
    my $res = Mojo::UserAgent->new->get(
        "https://api.linode.com/?api_action=api.spec")->res;
    die $res->error if $res->error;
    return $res;
}

sub parse_spec {
    my $res     = shift;
    my $methods = $res->json->{DATA}->{METHODS};

    my $validation;
    for my $remote_method ( keys %$methods ) {
        unless ( $remote_method =~ m/^(\S+)\.([^\.\s]++)$/ ) {
            warn "UNMATCHED METHOD: $remote_method\n";
            next;
        }
        my ( $group, $method ) = ( lc($1), lc($2) );
        $group =~ tr/\./_/;

        my ( @required, @optional );
        for my $parameter ( keys %{ $methods->{$remote_method}{PARAMETERS} } ) {
            if ( $methods->{$remote_method}{PARAMETERS}{$parameter}{REQUIRED} )
            {   push @required, lc $parameter;
            }
            else {
                push @optional, lc $parameter;
            }
        }
        $validation->{$group}{$method} = [ \@required, \@optional ];
    }
    return $validation;
}

sub dump_validation {
    my $validation = shift;
    for my $group ( sort keys %$validation ) {
        print "    $group => {\n";
        for my $method ( sort keys %{ $validation->{$group} } ) {
            my $args = join ', ',
                map { dump_arrayref($_) } @{ $validation->{$group}{$method} };
            print "        $method => [ $args ],\n";
        }
        print "    },\n";
    }
}

sub dump_arrayref {
        my $ref = shift;
        if ( @$ref == 0 ) {
            return '[]';
        }
        elsif ( @$ref <= 2 ) {
            return '[ ' . join( ', ', map {"'$_'"} @$ref ) . ' ]';
        }
        return '[qw( ' . join( ' ', @$ref ) . ' )]';
}
