package CocktailFu::Schema::Result::Beverage;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Core' }

__PACKAGE__->table('beverages');
__PACKAGE__->add_columns(qw/id name description/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->add_unique_constraint([qw/name/]);

__PACKAGE__->has_many(
    recipes => 'Recipe' => { 'foreign.beverage' => 'self.id' } );
__PACKAGE__->many_to_many( ingredients => recipes => 'ingredient' );
__PACKAGE__->has_many(
    instructions => Instruction => { 'foreign.beverage' => 'self.id' } );

1;

__END__
