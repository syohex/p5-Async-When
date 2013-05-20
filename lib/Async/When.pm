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

Async::When - Perl Port of when.js

=head1 SYNOPSIS

    use Async::When;

=head1 DESCRIPTION

Async::When is Perl port of Javascript Library when.js.
The API is kept as close to the original as possible.

This is currently a minimal implementation.

=head1 INTERFACES

=head2 Funcional Interface

=head3 When(@values or $promise)

Returns a promise. If the argument is already a promise, it is returned. Otherwise,
a new promise is created and immediately resolved with the provided value.

=head2 Class Interfaces

=head3 Async::When::defer

Create a deferred object, equivalent to C<Async::When::Deferred->new>.
The deferred can be split in its resolver and promise parts for better encapsulation.

=head3 Async::When::resolve(@values)

Create a deferred and immediately resolves it with C<@values>, then returns the promise.

=head3 Async::When::reject(@values)

Create a deferred and immediately rejects it with C<@values>, then returns the promise.

=head3 Async::When::all(@promises)

Takes promises or deferreds and returns promise that will either reject when the
first promise rejects, or resolve when all promises have resolved.

=head1 SEE ALSO

L<https://github.com/cujojs/when>

L<https://github.com/cjohansen/when-rb>

=head1 LICENSE

Copyright (C) Syohei YOSHIDA.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

Syohei YOSHIDA E<lt>syohex@gmail.comE<gt>

=cut
