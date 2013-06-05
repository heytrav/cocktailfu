package CocktailFu::Forms::EditCocktail;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler::Model::DBIC';

with 'HTML::FormHandler::Render::RepeatableJs';

has '+widget_wrapper' => ( default => 'Bootstrap' );
has '+item_class'     => ( default => 'CocktailFu::Schema::Result::Beverage' );

has_field description => (
    type  => 'Text',
    label => 'Drink name'
);
has_field recipes =>
  ( type => 'Repeatable', );

has_field 'recipes.quantity' => ( type => 'Text', required => 1 );
has_field 'recipes.measurement' => (
    type         => 'Select',
    empty_select => '-- Pick a Unit --',
    label_column => 'unit'
);
has_field 'recipes.ingredient' => (
    type         => 'Select',
    empty_select => '-- Pick an Ingredient --',
    label_column => 'description'
);
has_field instructions               => ( type => 'Repeatable' );
has_field 'instructions.instruction' => ( type => 'TextArea', );
has_field add_ingredient             => (
    type       => 'AddElement',
    repeatable => 'recipes',
    value      => 'Add another ingredient'
);

has_field submit => ( type => 'Submit', label => 'Save' );
has_field reset => ( type => 'Reset' );

has_block buttonset => (
    tag         => 'div',
    class       => [qw/btn/],
    render_list => [qw/submit reset/],
);

sub build_form_element_class {
    return [qw/well form-horizontal/];
}

sub build_update_subfields {
    return {
        'reset'        => { do_wrapper => 0, element_class => [qw/btn /] },
        add_ingredient => {
            do_wrapper    => 1,
            element_class => [
                qw/btn
                  btn-success/
            ]
        },
        recipes => { do_wrapper => 1 },
        submit  => {
            do_wrapper    => 0,
            element_class => [qw/btn btn-primary/]
        },
    };
}

sub build_render_list {
    return [qw/description recipes add_ingredient buttonset/];
}
no HTML::FormHandler::Moose;

1;

__END__
