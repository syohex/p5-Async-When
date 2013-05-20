package Async::When::Deferred;
use Mouse;

use Carp;
use Async::When::Resolver;
use Async::When::Promise;

has resolution => (
    is  => 'rw',
    isa => 'ArrayRef',
);

has callbacks => (
    is  => 'rw',
    isa => 'HashRef',
);

has resolver => (
    is  => 'rw',
    isa => 'Async::When::Resolver',
);

has promise => (
    is => 'rw',
    isa => 'Async::When::Promise',
);

sub BUILD {
    my $self = shift;

    $self->resolution([]);
    $self->callbacks({ resolved => [], rejected => [] });
    $self->resolver( Async::When::Resolver->new(deferred => $self) );
    $self->promise( Async::When::Promise->new(deferred => $self) );
}

no Mouse;

sub resolve {
    my ($self, @args) = @_;
    $self->_mark_resolved('resolved', [@args]);
}

sub reject {
    my ($self, @args) = @_;
    $self->_mark_resolved('rejected', [@args]);
}

sub callback {
    my ($self, $cb) = @_;
    $self->_add_callback('resolved', $cb);
}

sub then {
    my ($self, $cb) = @_;
    $self->_add_callback('resolved', $cb);
}

sub errback {
    my ($self, $cb) = @_;
    $self->_add_callback('rejected', $cb);
}

sub is_resolved {
    my $self = shift;
    scalar(@{$self->resolution}) != 0;
}

sub _add_callback {
    my ($self, $type, $cb) = @_;
    return $self->_notify_callbacks({ $type => [ $cb ]}) if $self->is_resolved;
    push @{$self->callbacks->{$type}}, $cb;
}

sub _mark_resolved {
    my ($self, $state, $args) = @_;

    Carp::croak("Already $state") if $self->is_resolved;

    $self->resolution([$state, $args]);
    $self->_notify_callbacks($self->callbacks);
}

sub _notify_callbacks {
    my ($self, $callbacks) = @_;

    my ($state, $args) = @{$self->resolution};

    return unless exists $callbacks->{$state};

    my $cbs = $callbacks->{$state};

    return if scalar(@{$cbs}) == 0;

    for my $cb (@{$cbs}) {
        $cb->(@{$args});
    }
}

1;

__END__
