package CocktailFu;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Time::HiRes qw/time/;

use CocktailFu::Schema;
use CocktailFu::SqlProfiler;
use DBI;

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
        { pg_enable_utf8 => 1 } );

    $dbh->storage->debug(1);
    $dbh->storage->debugobj($stats);

    return $dbh;
};

has dbi => sub {
    my $self          = shift;
    my $config        = $self->app->config;
    my $schema_config = $config->{'CocktailFu::Schema'};
    my $connect_info  = $schema_config->{connect_info};
    ### connect info: $connect_info
    my ( $dsn, $user, ) = @{$connect_info}{qw/dsn user/};
    my $dbh = DBI->connect( $dsn, $user, undef, { pg_enable_utf8 => 1 } );
    return $dbh;
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->home->parse( catdir( dirname(__FILE__), 'CocktailFu' ) );
    $self->static->paths->[0]   = $self->home->rel_dir('public');
    $self->renderer->paths->[0] = $self->home->rel_dir('templates');

    if ( $self->mode eq 'production' ) {
        $self->log->path('/home/nanobrewerco/log/cocktail_fu.log');
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
    $self->helper(
        dbi => sub {
             my $app = shift;
             $self->app->dbi;
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
    $r->any( '/cocktail/api/:prefetch/:beverage' => { prefetch => 0 } =>
          [ format => [qw(json)] ] )->name('jsonquery')
      ->to( controller => 'cocktails', action => 'api' );

    $r->any( '/cocktail/vanilla/:prefetch/:beverage' => { prefetch => 0 } =>
          [ format => [qw(json)] ] )->name('vanillajsonquery')
      ->to( controller => 'cocktails', action => 'vanilla' );

}

"d'oh!";
