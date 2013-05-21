#!/usr/bin/env perl

use Time::HiRes 'time';
my $start = time;
use 5.010;
use CocktailFu::Schema;
use CocktailFu::SqlProfiler;
{

    my $import_time = time;
    say "Import time: " . ( $import_time - $start );
    my $stats = CocktailFu::SqlProfiler->new;

    my $db =
      CocktailFu::Schema->connect( 'dbi:Pg:database=cocktails', 'cocktail' );
      $db->storage->debug(1);
      $db->storage->debugobj($stats);

    my $load_time = time;
    say "Load library time: " . ( $load_time - $import_time );

    my $beverage_rs = $db->resultset('Beverage');
    foreach my $beverage_name (@ARGV) {
        my $beverage = $beverage_rs->find( { name => $beverage_name } );

        say $beverage->description;
        my $post_query = time;
        say "Beverage execution time: " . ( $post_query - $load_time );
        my $recipes = $beverage->recipes;
        while ( my $recipe = $recipes->next ) {
            my $ingredient = $recipe->ingredient;
            my $measurement = $recipe->measurement;
            my $quantity = $recipe->quantity;
            say "Description: ".$ingredient->description;
            say $quantity." ".$measurement->unit;
        }
        say "Querying ingredients took: " . ( time - $post_query );
        say "============================";

    }

}

say "total time: " . ( time - $start );
