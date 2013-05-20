package Async::When;
use 5.008005;
use strict;
use warnings;

use parent qw/Exporter/;

use Async::When::Deferred;

our $VERSION = "0.01";

our @EXPORT = qw/When/;

sub defer {
    my $cb = shift;
    my $deferred = Async::When::Deferred->new;

    $cb->($deferred) if defined $cb;

    $deferred;
}

sub resolve {
    my @args = @_;

    my $deferred = Async::When::Deferred->new;
    $deferred->resolve(@args);
    $deferred->promise;
}

sub reject {
    my @args = @_;

    my $deferred = Async::When::Deferred->new;
    $deferred->reject(@args);
    $deferred->promise;
}

sub all {
    my @promises = @_;

    my $is_resolved = 0;
    my @results;

    my $deferred = Async::When::Deferred->new;

    my $attempt_resolution = sub {
        my ($err, $res_ref) = @_;
        return if $deferred->is_resolved;

        if (! defined $err) {
            $deferred->resolve(@{$res_ref}) if scalar(@promises) == $is_resolved;
        } else {
            $deferred->reject($err);
        }
    };

    _wait_for_all(\@promises, sub {
        my ($err, $result, $index) = @_;
        $is_resolved++;

        $results[$index] = $result;
        $attempt_resolution->($err, \@results);
    });

    $attempt_resolution->(undef, \@results) if scalar(@promises) == 0;
    $deferred->promise;
}

sub _wait_for_all {
    my ($promises_ref, $cb) = @_;

    my $index = 0;
    for my $promise (@{$promises_ref}) {
        my $i = $index;
        $promise->callback(sub {
            my $result = shift;
            $cb->(undef, $result, $i);
        });

        $promise->errback(sub {
            my $err = shift;
            $cb->($err, undef, $i);
        });

        $index++;
    }
}

sub When {
    my @args = @_;
    Async::When::resolve(@args);
}

1;
__END__

=encoding utf-8

=head1 NAME

Async::When - It's new $module

=head1 SYNOPSIS

    use Async::When;

=head1 DESCRIPTION

Async::When is ...

=head1 LICENSE

Copyright (C) Syohei YOSHIDA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=cut
