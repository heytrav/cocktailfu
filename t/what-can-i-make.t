use lib qw{ ./t/lib };

use Test::Routine;
use Test::Routine::Util;

with 'Setup';

use Test::More;
use Test::Deep qw/superbagof cmp_deeply/;
use Test::Exception;

#use Smart::Comments;

test dbi_search => { desc => 'Search filters using DBI' } => sub {
    my $self               = shift;
    my @ingredients_i_have = ( '%triple sec%', '%apricot brandy%' );
    my $db                 = $self->dbi;
    my @select_froms;
    my @wheres;
    my $count = 1;
    foreach my $count ( 1 .. @ingredients_i_have ) {
        my $recipes           = 'recipes';
        my $ingredients_table = 'ingredient';
        unless ( $count == 1 ) {
            $recipes           = join '_' => $recipes,           $count;
            $ingredients_table = join '_' => $ingredients_table, $count;
        }
        push @select_froms, qq/
            LEFT JOIN recipes ${recipes}
                ON ${recipes}.beverage = me.id
            LEFT JOIN ingredients ${ingredients_table}
                ON ${ingredients_table}.id = ${recipes}.ingredient /;
        push @wheres, qq/ ${ingredients_table}.description ILIKE ?  /;

        $count++;

    }
    my $select_froms = join ""      => @select_froms;
    my $where        = join " AND " => @wheres;
    my $query        = qq/
        SELECT
            me.id,
            me.name,
            me.description
        FROM
            beverages me
            ${select_froms}
        WHERE
            ( ( ${where} )  )
        GROUP BY
            me.id,
            me.name,
            me.description
     /;
    ### query : $query
    my $stmt = $db->prepare($query);
    $stmt->execute(@ingredients_i_have);
    my $result = $stmt->fetchall_arrayref;
    cmp_deeply( $result, superbagof( superbagof('after-supper-cocktail') ) );
};



run_me;
done_testing;
