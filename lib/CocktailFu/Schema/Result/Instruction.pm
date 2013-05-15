package CocktailFu::Schema::Result::Instruction;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::Core' }

__PACKAGE__->table('instructions');
__PACKAGE__->add_columns(qw/id beverage instruction/);
__PACKAGE__->set_primary_key('id');
__PACKAGE__->belongs_to(
    beverage => Beverage => { 'foreign.id' => 'self.beverage' } );

1;

__END__
