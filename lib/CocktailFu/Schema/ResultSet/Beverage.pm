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

1;

__END__
