use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('CocktailFu');
$t->get_ok('/')->status_is(200)->content_like(qr/All recipes/i);

done_testing();
