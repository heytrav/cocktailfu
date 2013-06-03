package CocktailFu::Cocktails;

use Mojo::Base 'Mojolicious::Controller';

use Time::HiRes qw/time/;

use CocktailFu::Forms::Mixer;
use CocktailFu::Forms::EditCocktail;

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

    while ( scalar @pages < 10 ) {
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

sub dbic {
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
    my $recipes  = $beverage->recipes;
    my $hash     = {
        title       => $beverage->description,
        instruction => $beverage->instruction->instruction,

    };
    while ( my $recipe = $recipes->next ) {
        my $ingredient  = $recipe->ingredient;
        my $measurement = $recipe->measurement;
        push @{ $hash->{ingredients} },
          {
            quantity   => $recipe->quantity,
            unit       => $measurement->unit,
            ingredient => $ingredient->description,
          };
    }
    $self->render( json => $hash );
}

sub vanilla {
    my $self          = shift;
    my $beverage_name = $self->param('beverage');
    my $prefetch      = $self->param('prefetch');
    my $dbh           = $self->dbi;

    my $result_hash = {};

    if ($prefetch) {
        my $query = qq{
            SELECT
                me.id,
                me.name,
                me.description,
                instructions.id,
                instructions.beverage,
                instructions.instruction,
                recipes.beverage,
                recipes.ingredient,
                recipes.measurement,
                recipes.quantity,
                ingredient.id,
                ingredient.name,
                ingredient.description,
                measurement.id,
                measurement.name,
                measurement.unit
            FROM
                beverages me
                LEFT JOIN instructions instructions
                    ON instructions.beverage = me.id
                LEFT JOIN recipes recipes
                    ON recipes.beverage = me.id
                LEFT JOIN ingredients ingredient
                    ON ingredient.id = recipes.ingredient
                LEFT JOIN measurements measurement
                    ON measurement.id = recipes.measurement
            WHERE
                ( me.name = ? )
            ORDER BY
                me.id

        };
        my $stmt = $dbh->prepare($query);
        $self->app->log->debug($query);
        $stmt->execute($beverage_name);
        my $results = $stmt->fetchall_arrayref;
        foreach my $result ( @{$results} ) {
            my ( $beverage_name, $instruction, $quantity, $ingredient, $unit )
              = @{$result}[ 2, 5, 9, 12, 15 ];
            $result_hash->{title}         = $beverage_name,
              $result_hash->{instruction} = $instruction;
            push @{ $result_hash->{ingredients} },
              {
                quantity   => $quantity,
                ingredient => $ingredient,
                unit       => $unit
              };
        }
    }
    else {    # naive dbi
        my $select_beverages = qq{
            SELECT
                me.id,
                me.name,
                me.description
            FROM
                beverages me
            WHERE ( me.name = ? )
        };

        my $beverage_stmt  = $dbh->prepare($select_beverages);
        my $select_recipes = qq{
            SELECT
                me.beverage,
                me.ingredient,
                me.measurement,
                me.quantity
            FROM
                recipes me
            WHERE
                ( me.beverage = ? )
            };
        my $recipe_stmt        = $dbh->prepare($select_recipes);
        my $select_ingredients = qq{
            SELECT
                me.id,
                me.name,
                me.description
            FROM
                ingredients me
            WHERE
                ( me.id = ? )
            };
        my $ingredient_stmt = $dbh->prepare($select_ingredients);

        my $select_measurement = qq{
                SELECT
                    me.id,
                    me.name,
                    me.unit
                FROM
                    measurements me
                WHERE
                    ( me.id = ? )
            };
        my $measurement_stmt   = $dbh->prepare($select_measurement);
        my $select_instruction = qq{
                SELECT
                    me.id,
                    me.beverage,
                    me.instruction
                FROM
                    instructions me
                WHERE
                    ( me.beverage = ? )
           };
        my $instruction_stmt = $dbh->prepare($select_instruction);

        # Fetch beverage from db
        $beverage_stmt->execute($beverage_name);
        $self->app->log->debug($select_beverages);
        my $beverage_set = $beverage_stmt->fetchall_arrayref;

        if ($beverage_set) {

            my $first_beverage = shift @{$beverage_set};
            my ( $beverage_id, $beverage_description ) =
              @{$first_beverage}[ 0, 2 ];

            # fetch beverage instructions
            $self->app->log->debug($select_instruction);
            $instruction_stmt->execute($beverage_id);
            my $instruct_result = $instruction_stmt->fetchrow_arrayref;
            my $instruction     = $instruct_result->[2];
            $result_hash->{title}       = $beverage_description;
            $result_hash->{instruction} = $instruction;

            # Fetch related recipes
            $recipe_stmt->execute($beverage_id);
            $self->app->log->debug($select_recipes);
            my $recipe_set = $recipe_stmt->fetchall_arrayref;

            foreach my $recipe ( @{$recipe_set} ) {
                my ( $bev, $ingredient_id, $measurement_id, $quantity ) =
                  @{$recipe};

                # Fetch ingredient
                $self->app->log->debug($select_ingredients);
                $ingredient_stmt->execute($ingredient_id);
                my $ingred_result = $ingredient_stmt->fetchall_arrayref;
                my $ingredient_description = $ingred_result->[0]->[2];

                # Fetch measurement
                $self->app->log->debug($select_measurement);
                $measurement_stmt->execute($measurement_id);
                my $measurement_result = $measurement_stmt->fetchall_arrayref;
                my $measurement_unit   = $measurement_result->[0]->[2];
                push @{ $result_hash->{ingredients} },
                  {
                    ingredient => $ingredient_description,
                    quantity   => $quantity,
                    unit       => $measurement_unit
                  };
            }
        }
    }

    $self->render( json => $result_hash );

}

sub mixer {
    my $self       = shift;
    my $form       = CocktailFu::Forms::Mixer->new;
    my $action     = $self->url_for('mixer');
    my $req_params = $self->req->params->to_hash;

    $form->process(
        action => $action,
        params => $req_params
    );

    my $results;
    if ( $form->validated ) {
        my ( @optional, @required );
        foreach my $count ( 1 .. 6 ) {
            my $ingredient = $req_params->{ 'ingredient' . $count };
            next if not $ingredient or $ingredient =~ /^\s*$/;

            my $required = $req_params->{ 'required' . $count };

            if ($required) {
                push @required, $ingredient;
            }
            else {
                push @optional, $ingredient;
            }
        }
        $results = $self->db->resultset('Beverage')->mixed_opt_ingredients(
            {
                optionals => \@optional,
                required  => \@required
            }
        );
    }
    $self->stash( form => $form, cocktails => $results );
}

sub create {
    my $self = shift;
    my $form = CocktailFu::Forms::EditCocktail->new;
    my $action = $self->url_for('createcocktail');
    $form->process(
       params => $self->req->params->to_hash,
       schema => $self->db,
       action => $action
    );
    if ($form->validated) {
        $self->redirect_to('/');
    }
    $self->stash(form => $form);
}

"d'oh";

__END__
