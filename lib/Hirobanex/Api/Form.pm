package Hirobanex::Api::Form;
use strict;
use warnings;
use utf8;
use Hirobanex::Container qw/api/;
use Encode;
use HTML::Shakan::Declare;
use HTML::Shakan::Model::DBIxSkinny;

sub new { bless {}, +shift }

sub get_form {
    my ($self,$form_name,$req) = @_;

    my $form = $self->get($form_name,
        request  => $req,
        model    => HTML::Shakan::Model::DBIxSkinny->new(),
        renderer => api('Form::Render'),
    );
    $form->load_function_message('ja');

    return $form;
}

form 'blog_category' => (
    TextField(
        name        => 'tag',
        label       => 'Tag:',
        required    => 1,
        filters     => [qw/WhiteSpace +Hirobanex::Api::Form::FilterAlnumH/],
        constraints => [
            [ 'LENGTH', 1, 15 ],
        ],
        custom_validation => sub {
            my $form = shift;

            if ($form->is_valid && container('db')->single('blog_category',{ tag => $form->param('tag')})) {
                $form->set_error('tag' => 'failed');
                $form->set_message('tag.failed' => 'すでに登録されています');
            }
        }
    ),
);

my $tag_choices = [map { ($_->tag) x 2 } @{api('BlogCategory')->fetch_list}];

form 'blog_page' => (
    TextField(
        name        => 'title',
        label       => 'Title:',
        required    => 1,
        filters     => [qw/WhiteSpace +Hirobanex::Api::Form::FilterAlnumH/],
        constraints => [
            [ 'LENGTH', 1, 60 ],
        ],
    ),
    TextField(
        name        => 'description',
        label       => 'Description:',
        widget      => 'textarea',
        required    => 1,
        filters     => [qw/WhiteSpace +Hirobanex::Api::Form::FilterAlnumH/],
        constraints => [
            [ 'LENGTH', 1, 250 ],
        ],
    ),
    TextField(
        name        => 'content',
        label       => 'Content:',
        widget      => 'textarea',
        required    => 1,
        filters     => [qw/WhiteSpace +Hirobanex::Api::Form::FilterAlnumH/],
    ),
    TextField(
        name        => 'id',
        label       => 'FileName:',
        constraints => [
            [ 'LENGTH', 1, 30 ],
        ],
    ),
    ChoiceField(
        name     => 'category_tag1',
        label    => 'Category_Tag1:',
        required => 1,
        choices  => $tag_choices,
    ),
    ChoiceField(
        name     => 'category_tag2',
        label    => 'Category_Tag2:',
        widget   => 'select',
        required => 0,
        choices  => ['','',@$tag_choices],
        custom_validation => sub {
            my $form = shift;
            if ($form->is_valid && ($form->param('category_tag2') eq $form->param('category_tag1'))) {
                $form->set_error('category_tag2' => 'failed');
                $form->set_message('category_tag2.failed' => 'category_tag2とcategory_tag1は別のもの選択する必要があります');
            }
        }
    ),
    ChoiceField(
        name     => 'tweet',
        label    => 'Tweet:',
        widget   => 'radio',
        choices  => [qw/1 update 0 none/],
    ),
);


1;

