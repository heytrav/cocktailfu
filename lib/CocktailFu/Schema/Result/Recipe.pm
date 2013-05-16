package CocktailFu::Schema::Result::Recipe;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Core' }

__PACKAGE__->table('recipes');
__PACKAGE__->add_columns(qw/beverage ingredient measurement quantity/);
__PACKAGE__->add_unique_constraint([qw/beverage ingredient/]);

__PACKAGE__->set_primary_key(qw/beverage ingredient/);

__PACKAGE__->belongs_to(
    beverage => Beverage => { 'foreign.id' => 'self.beverage' } );
__PACKAGE__->belongs_to(
    ingredient => Ingredient => { 'foreign.id' => 'self.ingredient' } );
__PACKAGE__->belongs_to(
    measurement => Measurement => { 'foreign.id' => 'self.measurement' } );

1;

__END__
