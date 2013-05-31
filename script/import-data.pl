#!/usr/bin/perl

use strict;
use warnings;

use 5.010;
use YAML qw/Load Dump/;

#use DB::CouchDB;
use Getopt::Long;
use Encode;
use Regexp::Assemble;
use Smart::Comments;

use CocktailFu::Schema;
my $dbh =
  CocktailFu::Schema->connect(
      "dbi:Pg:database=cocktails", "cocktail" );

my $dir;

GetOptions( 'directory=s' => \$dir );

#my $db            = DB::CouchDB->new( host => 'localhost', db => 'cocktails' );
my @alcohol_files = glob $dir . '*';
my @measurements  = qw/
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
  /;
my $ra = Regexp::Assemble->new();

map { $ra->add( $_ . '(?:\.)?' ); } @measurements;
my $re = $ra->re();

foreach my $recipe_file (@alcohol_files) {  ### Working===[%]     done
    open my $bh, "<:utf8", $recipe_file or die "Could not read from recipe";
    my $processed = do { local $/; <$bh> };
    close $bh;

    my $data = Load($processed);

    my $beverage_seen = {};
    foreach my $recipe ( @{$data} ) {
        my $title = $recipe->{title};
        my $ingredients    = delete $recipe->{ingredients};
        my $ingredient_set = [];
        my $beverage_name  = cleanse_name( $title );
        if ($beverage_seen->{$beverage_name}++) {
          $title = join ' '  => $title,$beverage_seen->{$beverage_name};
          $beverage_name = cleanse_name($title);
          $beverage_seen->{$beverage_name}++;
        }


        my $beverage_in_db = $dbh->resultset('Beverage')->create(
            {
                name        => $beverage_name,
                description => $recipe->{title}
            }
        ) ;

        my $unique_beverage_ingredients;
        foreach my $ingredient ( @{$ingredients} ) {
            my ( $quantity, $stuff ) = $ingredient =~ m{^
                (?:
                   (
                     (?:
                        (?! $re).)*
                       $re
                     )\s+
                  )?
                (.*)$
                }x;

            if ( $quantity and $stuff ) {

                my $clean_stuff = cleanse_name($stuff);
                next if $unique_beverage_ingredients->{$clean_stuff}++;

                my ($raw_measure) = $quantity =~ /($re)/;
                $quantity =~ s/\s*$re\s*//g;
                my $measure = cleanse_name($raw_measure);

                $beverage_in_db->add_to_recipes(
                    {
                        ingredient => {
                            name        => $clean_stuff,
                            description => $stuff
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
        $beverage_in_db->add_to_instructions(
            { instruction => $recipe->{instructions} } );

    }
}

sub cleanse_name {
    my $word = shift;
    my $name = lc $word;
    $name =~ s/\#//g;
    $name =~ s/[\)\(]//g;
    $name =~ s/[\s\-\.\'\",]+/-/g;
    $name =~ s/[-\.\/]$//;
    return $name;
}
