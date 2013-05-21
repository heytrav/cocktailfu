#!/usr/bin/env perl

use strict;
use warnings;
use Time::HiRes 'time';
my $start = time;
use 5.010;
use DBI;
{

    my $import_time = time;
    say "Import time: " . ( $import_time - $start );

    my $db = DBI->connect( 'dbi:Pg:database=cocktails', 'cocktail' );
    my $load_time = time;
    say "Load library time: " . ( $load_time - $import_time );
    my $statement = $db->prepare(
        'SELECT me.id, me.name, me.description FROM
        beverages me WHERE ( me.name = ? )'
    );

    my $get_recipe = $db->prepare(
        'SELECT i.* from recipes r join ingredients
        i on i.id = r.ingredient where r.beverage = ?'
    );

    foreach my $beverage_name (@ARGV) {

        $statement->execute($beverage_name);
        my $result = $statement->fetchrow_hashref;
        say $result->{description};
        my $post_query = time;
        say "Beverage execution time: " . ( $post_query - $load_time );
        $get_recipe->execute( $result->{id} );
        my $elements = $get_recipe->fetchall_arrayref;
        foreach my $element ( @{$elements} ) {

            say $element->[2];
        }
        say "Querying ingredients took: ".(time - $post_query);
        say "============================";

    }

}

say "total time: " . ( time - $start );

