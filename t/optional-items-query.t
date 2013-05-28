use lib qw{ ./t/lib };

use Test::Routine;
use Test::Routine::Util;

with 'Setup';

use Test::More;
use Test::Deep qw/superbagof cmp_deeply/;
use Test::Exception;

#use Smart::Comments;

sub optional_query_param {
    my ( $self, $args ) = @_;
    my $optionals = $args->{optionals};
    my $required  = $args->{required};
    my ( @ingredient_joins, @or_param );

    # Setup fields
    if ( @{$optionals} ) {
        push @ingredient_joins, { recipes => 'ingredient' };
        my @or_list;
        foreach my $optional ( @{$optionals} ) {
            push @or_list,
              {
                'ingredient.description' => {
                    ilike => '%' . $optional . '%'
                }
              };
        }
        push @or_param, '-or' => \@or_list;
    }
    my $count = 2;
    my @query_fields;
    foreach my $required_ingred ( @{$required} ) {
        my $field = join '_' => 'ingredient', $count;
        my $field_name = join '.' => $field, 'description';
        push @query_fields,
          { $field_name => { ilike => '%' . $required_ingred . '%' } };

        push @ingredient_joins, { recipes => 'ingredient' };
        $count++;
    }

    # Actual query
    my $rs = $self->dbic->resultset('Beverage')
      ->search( {@or_param}, { join => [@ingredient_joins] } );

    foreach my $required_query (@query_fields) {
        $rs = $rs->search($required_query);
    }
    return $rs->search(
        {},
        {
            '+select' => [ { count => '*' } ],
            '+as'     => ['beverage_count'],
            group_by  => [qw/me.id me.name me.description/],
            order_by => { -desc => [qw/count/] }

        }
    );
}

test dbic_search =>
  { desc => 'Test search for recipes using mixed join clauses.' } => sub {
    my $self      = shift;
    my @optionals = ( 'vodka', 'gin', 'grenadine' );
    my @required  = ( 'schnapps', 'orange juice' );
    my $grouped   = $self->optional_query_param(
        {
            optionals => \@optionals,
            required  => \@required
        }
    );
    my $first = $grouped->first;

    my $after_supper =
      $grouped->search( { 'me.description' => 'Puerto Rican Punch' } )->first;
    my $name = $after_supper->name;
    like( $name, qr/puerto\-rican\-punch/, 'Found my cocktail' );
  };

run_me;
done_testing;
