package CocktailFu;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Time::HiRes qw/time/;

use CocktailFu::Schema;
use CocktailFu::SqlProfiler;

has schema => sub {
    my $self   = shift;
    my $config = $self->app->config;
    my $stats  = CocktailFu::SqlProfiler->new;
    ### config : $config
    my $schema_config = $config->{'CocktailFu::Schema'};
    my $connect_info  = $schema_config->{connect_info};
    ### connect info: $connect_info
    my ( $dsn, $user, ) = @{$connect_info}{qw/dsn user/};
    my $dbh = CocktailFu::Schema->connect( $dsn, $user, undef,
        {pg_enable_utf8 => 1}
    );

    $dbh->storage->debug(1);
    $dbh->storage->debugobj($stats);

    return $dbh;
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->home->parse( catdir( dirname(__FILE__), 'CocktailFu' ) );
    $self->static->paths->[0]   = $self->home->rel_dir('public');
    $self->renderer->paths->[0] = $self->home->rel_dir('templates');

    if ( $self->mode eq 'production' ) {
        $self->log->path('/home/cocktail_fu/log/cocktail_fu.log');
    }

    my $config = $self->plugin('Config');

    # Documentation browser under "/perldoc"
    $self->plugin('PODRenderer');
    $self->helper(
        db => sub {
            my $app = shift;
            $self->app->schema;
        }
    );

    # Router
    my $r = $self->routes;
    $r->route('/')->to('cocktails#index');
    $r->get( '/cocktails/:page', { page => 1 } )->name('bypage')->to(
        controller => 'cocktails',
        action     => 'alphabetical'
    );

    $r->get( '/cocktail/recipe/:beverage/:prefetch' => { prefetch => 0 } )
      ->name('recipe')->to(
        controller => 'cocktails',
        action     => 'recipe'
      );
}

"d'oh!";
