package CocktailFu::Forms::Mixer;

use HTML::FormHandler::Moose;
extends 'HTML::FormHandler';

has '+widget_wrapper' => (default => 'Bootstrap');

has_field ingredient1 => ( type => 'Text',  label => 'Ingredient 1' );
has_field required1   => ( type => 'Checkbox', label => undef );
has_field ingredient2 => ( type => 'Text',  label => 'Ingredient 2' );
has_field required2   => ( type => 'Checkbox', label => undef );
has_field ingredient3 => ( type => 'Text',  label => 'Ingredient 3' );
has_field required3   => ( type => 'Checkbox', label => undef );
has_field ingredient4 => ( type => 'Text',  label => 'Ingredient 4' );
has_field required4   => ( type => 'Checkbox', label => undef );
has_field ingredient5 => ( type => 'Text',  label => 'Ingredient 5' );
has_field required5   => ( type => 'Checkbox', label => undef );
has_field ingredient6 => ( type => 'Text',  label => 'Ingredient 6' );
has_field required6   => ( type => 'Checkbox', label => undef );

has_field submit => ( type => 'Submit', value => 'Search' );
has_field reset  => ( type => 'Reset' );
has_block ingred1 => (tag => 'div',render_list => [qw/required1 ingredient1/]);
has_block ingred2 => (tag => 'div',  render_list => [qw/required2 ingredient2/]);
has_block ingred3 => (tag => 'div',  render_list => [qw/required3 ingredient3/]);
has_block ingred4 => (tag => 'div',  render_list => [qw/required4 ingredient4/]);
has_block ingred5 => (tag => 'div',  render_list => [qw/required5 ingredient5/]);
has_block ingred6 => (tag => 'div',  render_list => [qw/required6 ingredient6/]);
has_block buttonset => (
    tag         => 'div',
    class       => ['form-actions'],
    render_list => [qw/submit reset/]
);

sub build_form_element_class {
    return [qw/well form-inline/];
}

sub build_update_subfields {
    return {
        reset => { do_wrapper => 0, element_class => [qw/btn/] },
        ingredient1 => { do_wrapper => 0,  }, required1 => { do_wrapper => 0,  },
        ingredient2 => { do_wrapper => 0,  }, required2 => { do_wrapper => 0,  },
        ingredient3 => { do_wrapper => 0,  }, required3 => { do_wrapper => 0,  },
        ingredient4 => { do_wrapper => 0,  }, required4 => { do_wrapper => 0,  },
        ingredient5 => { do_wrapper => 0,  }, required5 => { do_wrapper => 0,  },
        ingredient6 => { do_wrapper => 0,  }, required6 => { do_wrapper => 0,  },
        submit => { do_wrapper => 0, element_class => [qw/btn btn-primary/] }
    };
}

sub build_render_list {
    return [
        qw/ingred1 ingred2 ingred3 ingred4  ingred5 ingred6 buttonset/
    ];
}

no HTML::FormHandler::Moose;

1;

__END__
