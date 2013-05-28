package CocktailFu::Schema::ResultSet::Beverage;

use Moose;
use namespace::autoclean;
BEGIN { extends 'DBIx::Class::ResultSet' }

=head2 find_by_ingredients

Find beverage with as many of the ingredients as possible.

=cut

sub find_by_ingredients {
    my ( $self, @ingredients ) = @_;

    my @join_set;
    push @join_set, { recipes => 'ingredient' } foreach @ingredients;

    my $rs = $self->search( {}, { join => \@join_set } );

    my $count = 1;
    foreach my $ingred_i_have (@ingredients) {
        my $ingredient_key = 'ingredient';
        $ingredient_key = join '_' => $ingredient_key, $count
          unless $count == 1;
        $ingredient_key = join '.' => $ingredient_key, 'description';

        $rs = $rs->search(
            {
                $ingredient_key => {
                    'ilike' => '%' . $ingred_i_have . '%'
                }
            },
            { distinct => 1, }
        );

        $count++;
    }
    return $rs;
}

=head2 mixed_opt_ingredients

Query using assortment of I<optional> and I<required> parameters. Sort
resultset by number of ingredients found with highest number of hits at the
top.

=cut

sub mixed_opt_ingredients {
    my ($self, $args) = @_;
    my $optionals = $args->{optionals};
    my $required  = $args->{required};
    my (@query_fields, @ingredient_joins, @or_param );

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
    foreach my $required_ingred ( @{$required} ) {
        my $field = join '_' => 'ingredient', $count;
        my $field_name = join '.' => $field, 'description';
        push @query_fields,
          { $field_name => { ilike => '%' . $required_ingred . '%' } };

        push @ingredient_joins, { recipes => 'ingredient' };
        $count++;
    }

    # Actual query
    my $rs = $self->search( {@or_param}, { join => [@ingredient_joins] } );

    $rs = $rs->search($_) foreach @query_fields;

    # Group search results.
    return $rs->search(
        {},
        {
            '+select' => [ { count => '*' } ],
            group_by  => [qw/me.id me.name/],
            order_by => { -desc => [qw/count/] }

        }
    );
}

1;

__END__
