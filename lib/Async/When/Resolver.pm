package Async::When::Resolver;
use Mouse;

has deferred => (
    is       => 'ro',
    isa      => 'Async::When::Deferred',
    required => 1,
);

no Mouse;

sub resolve {
    my ($self, @args) = @_;
    $self->deferred->resolve(@args);
}

sub reject {
    my ($self, @args) = @_;
    $self->deferred->reject(@args);
}

sub is_resolved {
    my $self = shift;
    $self->deferred->is_resolved;
}

1;

__END__
