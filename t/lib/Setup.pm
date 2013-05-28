package Setup;

use Moose::Role;
use namespace::autoclean;


use Test::Mojo;

has setup_app => (
    is      => 'ro',
    isa     => 'Test::Mojo',
    lazy    => 1,
    clearer => 'reset_db',
    default => sub {
        my ($self) = @_;
        my $app = Test::Mojo->new('CocktailFu');
        return $app;
    },
);

has dbic => (
    is      => 'ro',
    lazy    => 1,
    isa     => 'DBIx::Class::Schema',
    default => sub {
        my $self = shift;
        return $self->setup_app->app->db;
    },
);

has dbi => (
    is      => 'ro',
    isa     => 'DBI::db',
    lazy    => 1,
    default => sub {
        my $self = shift;
        return $self->setup_app->app->dbi;
    },
);

has beverage => (
    is      => 'rw',
    lazy    => 1,
    default => sub {
        return;
    }
);

1;

__END__
