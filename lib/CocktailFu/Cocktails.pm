package CocktailFu::Cocktails;

use Mojo::Base 'Mojolicious::Controller';

use Time::HiRes qw/time/;

sub index {
    my $self = shift;

}

sub alphabetical {
    my $self      = shift;
    my $page      = $self->param('page') // 1;
    my $beverages = $self->db->resultset('Beverage')->search(
        {},
        {
            rows     => 10,
            page     => $page,
            order_by => { '-asc' => [qw/name/] }
        }
    );

    # Add paged browsing links
    my $pager   = $beverages->pager;
    my $current = $pager->current_page;
    my $last    = $pager->last_page;
    my @pages;
    push @pages, $current;
    my $previous = $current - 1;
    my $next     = $current + 1;

    while ( scalar @pages < 20 ) {
        unshift @pages, $previous if $previous > 0;
        $previous--;
        push @pages, $next if $next <= $last;
        $next++;
    }
    $self->stash( beverages => $beverages, pages => \@pages );
}

sub recipe {
    my $self          = shift;
    my $beverage_name = $self->param('beverage');
    my $prefetch      = $self->param('prefetch');

    my $beverages = $self->db->resultset('Beverage');

    if ($prefetch) {
        $beverages = $beverages->search(
            {},
            {
                prefetch => [
                    'instructions', { recipes => [qw/ingredient measurement/] }
                ]
            }
        );
    }

    my $beverage = $beverages->find( { name => $beverage_name } );
    my $recipes = $beverage->recipes;
    $self->stash( beverage => $beverage, recipes => $recipes );
}

"d'oh";

__END__
