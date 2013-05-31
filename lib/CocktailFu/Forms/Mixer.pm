package CocktailFu::Forms::Mixer;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => (default => 'Bootstrap');

has_field ingredient1 => ( type => 'Text',  label => 'Ingredient 1' );
has_field required1   => ( type => 'Checkbox', label => 'Required' );
has_field ingredient2 => ( type => 'Text',  label => 'Ingredient 2' );
has_field required2   => ( type => 'Checkbox', label => 'Required' );
has_field ingredient3 => ( type => 'Text',  label => 'Ingredient 3' );
has_field required3   => ( type => 'Checkbox', label => 'Required' );
has_field ingredient4 => ( type => 'Text',  label => 'Ingredient 4' );
has_field required4   => ( type => 'Checkbox', label => 'Required' );
has_field ingredient5 => ( type => 'Text',  label => 'Ingredient 5' );
has_field required5   => ( type => 'Checkbox', label => 'Required' );
has_field ingredient6 => ( type => 'Text',  label => 'Ingredient 6' );
has_field required6   => ( type => 'Checkbox', label => 'Required' );

has_field submit => ( type => 'Submit', value => 'Search' );
has_field reset  => ( type => 'Reset' );
has_block buttonset => (
    tag         => 'div',
    class       => ['form-actions'],
    render_list => [qw/submit reset/]
);

sub build_form_element_class {
    return [qw/well form-horizontal/];
}

sub build_update_subfields {
    return {
        reset => { do_wrapper => 0, element_class => [qw/btn/] },
        submit => { do_wrapper => 0, element_class => [qw/btn btn-primary/] }
    };
}

sub build_render_list {
    return [
        qw/ingredient1 required1 ingredient2 required2 ingredient3
          required3 ingredient4 required4 ingredient5 required5 ingredient6
          required6 buttonset/
    ];
}

no HTML::FormHandler::Moose;

1;

__END__
