use lib qw{ ./t/lib };

use Test::Routine;
use Test::Routine::Util;

with 'Setup';

use Test::More;
use Test::Deep qw/superbagof cmp_deeply/;
use Test::Exception;

#use Smart::Comments;

test complicated_search_query =>
  { desc => 'Search for assorted optional/required ingredients' } => sub {
    my ( $self, $args ) = @_;
    my $optionals = $args->{optionals};
    my $required  = $args->{required};
    my ( @query_fields, @ingredient_joins, @or_param );

    my $rs;
    lives_ok {
        $rs = $self->dbic->resultset('Beverage')->search(
            {
                -or => [
                    { 'ingredient.description' => { ilike => '%vodka%' } },
                    { 'ingredient.description' => { ilike => '%gin%' } },
                    { 'ingredient.description' => { ilike => '%grenadine%' } },
                ],
                'ingredient_2.description' => { ilike => '%schnapps%' },
                'ingredient_3.description' => { ilike => '%orange juice%' }
            },
            {
                join => [
                    { recipes => 'ingredient' },
                    { recipes => 'ingredient' },
                    { recipes => 'ingredient' },
                ]
            }
        );

    }
    'No problems executing query.';

    my $chosen_beverage =
      $rs->search( { 'me.description' => 'Puerto Rican Punch' } )->first;
    my $name = $chosen_beverage->name;
    is( $name, 'puerto-rican-punch', 'Found my cocktail' );
  };

test dbic_search =>
  { desc => 'Test search for recipes using mixed join clauses.' } => sub {
    my $self      = shift;
    my @optionals = ( 'vodka', 'gin', 'grenadine' );
    my @required  = ( 'schnapps', 'orange juice' );
    my $grouped;
    lives_ok {
        $grouped = $self->dbic->resultset('Beverage')->mixed_opt_ingredients(
            {
                optionals => \@optionals,
                required  => \@required
            }
        );

    }
    'No problems executing query';
    my $first = $grouped->first;

    my $chosen_beverage =
      $grouped->search( { 'me.description' => 'Puerto Rican Punch' } )->first;
    my $name = $chosen_beverage->name;
    is( $name, 'puerto-rican-punch', 'Found my cocktail' );
  };

run_me;
done_testing;
