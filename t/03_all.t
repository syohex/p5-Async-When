use strict;
use warnings;
use Test::More;

use Async::When;

subtest 'returns deferrable' => sub {
    my $deferred = Async::When::all(When(42));

    isa_ok $deferred, 'Async::When::Promise';
    can_ok $deferred, 'callback';
    can_ok $deferred, 'errback';
};

subtest 'resolves immediately if no promises' => sub {
    my $deferred = Async::When::all();
    my $called_back = 0;

    $deferred->callback(sub {
        my @results = @_;
        is scalar(@results), 0;
        $called_back = 1;
    });

    ok $called_back, 'callback is called';
};

subtest 'resolves when single deferrable resolves' => sub {
    my $deferred = Async::When::Deferred->new;
    my $d = Async::When::all($deferred->promise);

    my $resolved = 0;
    $d->callback(sub {
        my @results = @_;
        $resolved = 1;
    });

    ok !$resolved, "callback is not called yet";
    $deferred->resolve(42);
    ok $resolved, "callback is called";
};

subtest 'resolves when all deferrables are resolved' => sub {
    my @deferreds = (Async::When::Deferred->new, Async::When::Deferred->new,
                     Async::When::Deferred->new);

    my $d = Async::When::all(map { $_->promise } @deferreds);
    my $resolved = 0;

    $d->callback(sub {
        my @results = @_;
        $resolved = 1;
    });

    ok !$resolved, "callback is not called yet1";
    $deferreds[0]->resolve(42);
    ok !$resolved, "callback is not called yet2";
    $deferreds[1]->resolve(13);
    ok !$resolved, "callback is not called yet3";
    $deferreds[2]->resolve(3);
    ok $resolved, "callback is called";
};

subtest 'rejects when single deferrable rejects' => sub {
    my $deferred = Async::When::Deferred->new;
    my $d = Async::When::all($deferred->promise);
    my $rejected = 0;

    $d->errback(sub {
        my @results = @_;
        $rejected = 1;
    });

    ok !$rejected, 'callback is not called yet';
    $deferred->reject(1);
    ok $rejected, 'callback is called';
};

subtest 'rejects on first rejection' => sub {
    my @deferreds = (Async::When::Deferred->new, Async::When::Deferred->new,
                     Async::When::Deferred->new);

    my $d = Async::When::all(map { $_->promise } @deferreds);
    my $rejected = 0;

    $d->errback(sub {
        my @results = @_;
        $rejected = 1;
    });

    $deferreds[0]->resolve(42);
    $deferreds[2]->reject(1);
    $deferreds[1]->resolve(13);

    ok $rejected, 'reject callback is called';
};

subtest 'proxies resolution value in array' => sub {
    my $deferred = Async::When::Deferred->new;
    my $d = Async::When::all($deferred->promise);
    my @results;

    $d->callback(sub {
        my @res = @_;
        @results = @_;
    });

    $deferred->resolve(42);
    is_deeply \@results, [42];
};

subtest 'orders results like input' => sub {
    my $deferred1 = Async::When::Deferred->new;
    my $deferred2 = Async::When::Deferred->new;

    my $d = Async::When::all($deferred1->promise, $deferred2->promise);
    my @results;

    $d->callback(sub {
        @results = @_;
    });

    $deferred2->resolve(42);
    $deferred1->resolve(13);
    is_deeply \@results, [13, 42];
};

done_testing;
