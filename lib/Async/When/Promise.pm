package Async::When::Promise;
use Mouse;

has deferred => (
    is       => 'ro',
    isa      => 'Async::When::Deferred',
    required => 1,
);

no Mouse;

sub then {
    my ($self, $cb) = @_;
    $self->deferred->then($cb);
}

sub callback {
    my ($self, $cb) = @_;
    $self->deferred->callback($cb);
}

sub errback {
    my ($self, $cb) = @_;
    $self->deferred->errback($cb);
}

1;

__END__
