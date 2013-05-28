
use lib qw{ ./t/lib };

use Test::Routine;
use Test::Routine::Util;
use Test::More;
use Test::Exception;

#use Smart::Comments;

with 'Setup';

test query_beverage => { desc => 'Check that we can get a beverage.' } => sub {
    my $self = shift;
    my $beverage;
    lives_ok {
        my $db = $self->dbic;
        $beverage = $db->resultset('Beverage')
          ->search( {}, { order_by => { -asc => ['random()'] } } )->first;
    }
    'get random beverage';

    cmp_ok( $beverage->name, 'ne', '', 'Beverage name is a string' );
    $self->beverage($beverage);
};

test beverage_ingredients => { desc => 'Follow relations to ingredients' } =>
  sub {
    my $self        = shift;
    my $beverage    = $self->beverage;
    my $ingredients = $beverage->ingredients;
    cmp_ok( $ingredients->count, '>=', 1, 'At least one ingredient exists' );
    while ( my $ingredient = $ingredients->next ) {
        isa_ok(
            $ingredient,
            'CocktailFu::Schema::Result::Ingredient',
            'Iterator returns Ingredient object'
        );
    }
  };

run_me;
done_testing;

