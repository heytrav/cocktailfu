package CocktailFu;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec::Functions 'catdir';
use Time::HiRes qw/time/;

use CocktailFu::Schema;

has schema => sub {
    my $self   = shift;
    my $config = $self->app->config;
    ### config : $config
    my $schema_config = $config->{'CocktailFu::Schema'};
    my $connect_info  = $schema_config->{connect_info};
    ### connect info: $connect_info
    my ( $dsn, $user, ) = @{$connect_info}{qw/dsn user/};
    my $dbh = CocktailFu::Schema->connect( $dsn, $user, );
    return $dbh;
};

# This method will run once at server start
sub startup {
    my $self = shift;

    $self->home->parse( catdir( dirname(__FILE__), 'CocktailFu' ) );
    $self->static->paths->[0]   = $self->home->rel_dir('public');
    $self->renderer->paths->[0] = $self->home->rel_dir('templates');

    #if ( $self->mode eq 'production' ) {
    #$self->log->path('/home/cocktail_fu/log/vindaloo.log');
    #}

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

}

"d'oh!";
