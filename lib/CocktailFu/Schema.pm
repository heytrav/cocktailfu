package CocktailFu::Schema;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Schema' }

__PACKAGE__->load_namespaces();
__PACKAGE__->meta->make_immutable( inline_constructor => 0 );

1;

__END__
