package CocktailFu::Schema::Result::Ingredient;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Core' }

__PACKAGE__->table('ingredients');
__PACKAGE__->add_columns(qw/id name description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw/name/]);



__PACKAGE__->has_many(
    recipes => Recipe => {
    'foreign.ingredient' => 'self.id' } );

__PACKAGE__->many_to_many( beverages => recipes => 'beverage' );

1;

__END__
