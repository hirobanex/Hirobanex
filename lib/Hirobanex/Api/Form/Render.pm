package Hirobanex::Api::Form::Render;
use Any::Moose;
use HTML::Shakan::Utils;

has 'id_tmpl' => (
    is => 'ro',
    isa => 'Str',
    default => 'id_%s',
);

sub render {
    my ($self, $form) = @_;

    my @res;
    for my $field ($form->fields) {
        my @row;
        unless ($field->id) {
            $field->id(sprintf($self->id_tmpl(), $field->{name}));
        }
        if ($field->label) {
            push @row, sprintf( q{<label for="%s">%s</label><br />},
                $field->{id}, encode_entities( $field->{label} ) );
        }
        push @row, $form->widgets->render( $form, $field );

        if($field->id =~ /id_(id|title)/){
            @row = ('<div class="form_wide">',@row,'</div>');
        }elsif($field->id eq 'id_description'){
            @row = ('<div class="description">',@row,'</div>');
        }elsif($field->id eq 'id_content'){
            @row = ('<div class="content">',@row,'</div>');
        }
        
        push @res, join '', @row;
    }

    '<p>' . (join '</p><p>', @res) . '</p>';
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;
