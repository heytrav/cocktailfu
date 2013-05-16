package CocktailFu::Schema::Result::Measurement;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Core' }

__PACKAGE__->table('measurements');
__PACKAGE__->add_columns(qw/id name unit/);
__PACKAGE__->add_unique_constraint([qw/name/]);

__PACKAGE__->set_primary_key('id');
__PACKAGE__->has_many(
    recipes => Recipe => { 'foreign.measurement' => 'self.id' } );

1;

__END__
