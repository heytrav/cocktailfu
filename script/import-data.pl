#!/usr/bin/env perl

use strict;
use warnings;

use 5.010;
use YAML qw/Load Dump/;

use Getopt::Long;

#use Encode;
use Regexp::Assemble;
use Smart::Comments;

use CocktailFu::Schema;
use CocktailFu::SqlProfiler;

my $dir;

GetOptions( 'directory=s' => \$dir );

my @alcohol_files = glob $dir . '*';
my $ra            = Regexp::Assemble->new();
my $measurements  = measurement_units();

map { $ra->add( $_ . '(?:\.)?' ); } @{$measurements};
my $re = $ra->re();

my $dbh =
  CocktailFu::Schema->connect( "dbi:Pg:database=cocktails",
    "cocktail", undef, { pg_enable_utf8 => 1 } );
my $stats = CocktailFu::SqlProfiler->new;
$dbh->storage->debug(1);
$dbh->storage->debugobj($stats);

my $beverage_rs = $dbh->resultset('Beverage');

my $count = 0;
foreach my $recipe_file (@alcohol_files) {    ### importing===[%]     done
    open my $bh, "<:encoding(utf8)", $recipe_file
      or die "Could not read from recipe";
    my $processed = do { local $/; <$bh> };
    close $bh;

    my $data = Load($processed);

    my $beverage_seen = {};
    foreach my $recipe ( @{$data} ) {
        my $title          = $recipe->{title};
        my $ingredients    = delete $recipe->{ingredients};
        my $ingredient_set = [];
        my $beverage_name  = cleanse_name($title);
        if ( $beverage_seen->{$beverage_name}++ ) {
            $title = join ' ' => $title, $beverage_seen->{$beverage_name};
            $beverage_name = cleanse_name($title);
            $beverage_seen->{$beverage_name}++;
        }

        # Create the beverage
        my $beverage_in_db = $beverage_rs->create(
            {
                name        => $beverage_name,
                description => $recipe->{title},
                instruction => { instruction => $recipe->{instructions} }
                #'instruction.instruction' => $recipe->{instructions}
            },
            {
                join => 'instruction'
            }
        );

        # Add instruction


        my $unique_beverage_ingredients;
        foreach my $ingredient_raw ( @{$ingredients} ) {
            my ( $quantity, $ingredient ) = $ingredient_raw =~ m{^
                (?:
                   (
                     (?: (?! $re).)*
                       $re
                     )\s+
                  )?
                (.*)$
                }x;

            if ( $quantity and $ingredient ) {

                my $ingredient_key = cleanse_name($ingredient);
                next if $unique_beverage_ingredients->{$ingredient_key}++;

                my ($raw_measure) = $quantity =~ /($re)/;
                $quantity =~ s/\s*$re\s*//g;
                my $measure = cleanse_name($raw_measure);

                # Insert all the things
                $beverage_in_db->add_to_recipes(
                    {
                        ingredient => {
                            name        => $ingredient_key,
                            description => $ingredient
                        },
                        measurement => {
                            name => $measure,
                            unit => $raw_measure
                        },
                        quantity => $quantity
                    },
                    {
                        join => { recipes => [qw/ingredient measurement/] }
                    }
                );
            }
        }
    $count++;
    }
}

say "Imported $count recipes.";

sub cleanse_name {
    my $word = shift;
    my $name = lc $word;
    $name =~ s/\#//g;
    $name =~ s/[\)\(]//g;
    $name =~ s/[\s\-\.\'\",]+/-/g;
    $name =~ s/[-\.\/]$//;
    return $name;
}

sub measurement_units {
    my $measurements = [
        qw/
          shots
          cans
          shot can
          twist
          twists
          dashes
          pint pints
          L
          gal
          splashes
          oz
          cup
          part
          parts
          cl
          ml
          dl
          dash
          pinch
          shot
          gram
          drop
          drops
          tsps
          tblsp
          tblsps
          tsp
          splash
          liter
          gallon
          cups
          bottle
          bottles
          /

    ];
}
