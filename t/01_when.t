use strict;
use warnings;
use Test::More;

use Async::When;

subtest 'returns promise' => sub {
    my $promise = When(42);

    isa_ok $promise, 'Async::When::Promise';
    can_ok $promise, 'callback';
    can_ok $promise, 'errback';
};

subtest 'resolves promise with value' => sub {
    my $promise = When(42);
    my $called_back = 0;

    $promise->callback(sub {
        my ($value) = @_;
        is $value, 42, 'argument value';
        $called_back = 1;
    });

    ok $called_back, 'callback is called';
};

subtest 'returns resolved promise' => sub {
    my $called_back = 0;

    Async::When::resolve(42)->callback(sub {
        my $num = shift;
        is $num, 42, "argument value";
        $called_back = 1;
    });

    ok $called_back, 'callback is called';
};

subtest 'returns rejected promise' => sub {
    my $called_back = 0;

    Async::When::reject(42)->errback(sub {
        my $num = shift;
        is $num, 42, "argument value";
        $called_back = 1;
    });

    ok $called_back, 'error callback is called';
};

done_testing;
