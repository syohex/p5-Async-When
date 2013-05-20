use strict;
use warnings;
use Test::More;

use Async::When;

subtest 'creates deferred' => sub {
    my $deferred = Async::When::defer;

    isa_ok $deferred, 'Async::When::Deferred';

    can_ok $deferred, 'callback';
    can_ok $deferred, 'errback';
    can_ok $deferred, 'resolve';
    can_ok $deferred, 'reject';
};

subtest 'resolves promise through resolver' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->promise->callback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->resolver->resolve;
    ok $called_back, 'callback is called';
};

subtest 'aliases then to callback' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->promise->then(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->resolver->resolve;
    ok $called_back, 'callback is called';
};

subtest 'resolves promise through deferred' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->promise->callback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->resolve;
    ok $called_back, 'callback is called';
};

subtest 'resolves deferred through deferred' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->callback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->resolve;
    ok $called_back, 'callback is called';
};

subtest 'raises if already resolved' => sub {
    my $deferred = Async::When::defer;
    $deferred->resolve;

    eval {
        $deferred->resolve;
    };
    like $@, qr/Already resolved/, "call resolve multiple times";
};

subtest 'rejects promise through reject' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->promise->errback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->resolver->reject;
    ok $called_back, 'errcallback is called';
};

subtest 'rejects promise through deferred' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->promise->errback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->reject;
    ok $called_back, 'errcallback is called';
};

subtest 'rejects deferred through deferred' => sub {
    my $deferred = Async::When::defer;
    my $called_back = 0;

    $deferred->errback(sub {
        $called_back = 1;
    });

    ok !$called_back, 'callback is not called yet';
    $deferred->reject;
    ok $called_back, 'errcallback is called';
};

subtest 'raises if already resolved' => sub {
    my $deferred = Async::When::defer;
    $deferred->reject;

    eval {
        $deferred->reject;
    };
    like $@, qr/Already rejected/, "call reject multiple times";
};

done_testing;
