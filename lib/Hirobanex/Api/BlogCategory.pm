package Hirobanex::Api::BlogCategory;
use strict;
use warnings;
use Hirobanex::Container qw/api/;
use Smart::Args;

sub new { bless {}, +shift }

sub fetch_single {
    args_pos my $self,
             my $id  => 'Int';

    container('db')->single('blog_category',{ id => $id });
}

sub fetch_list {
    my ($self) = @_;

    [container('db')->search('blog_category')->all];
}

sub fetch_blog_page_ids {
    args_pos my $self,
             my $tag,
             my $obj => {isa => 'Bool',default => 1};

    my $row = container('db')->single('blog_category',{ tag => $tag });

    return unless($row);

    return $row->blog_page_ids;
}

sub register {
    my ($self,$form) = @_;

    $form->model->create( container('db') => 'blog_category' );
}

sub modify {
    my ($self,$old_row,$args) = @_;

    my $txn = container('db')->txn_scope;
        my $new_row = container('db')->update('blog_category',$args,{ tag => $old_row->tag });  

        api('BlogPage')->modify_tag($args,$old_row);
    $txn->commit;
}

sub modify_blog_category_blog_page_ids {
    my ($self,$tag,$blog_page_id,$method) = @_;

    my %blog_page_ids = %{$self->fetch_blog_page_ids($tag)};

    if($method eq 'delete'){
        delete $blog_page_ids{$blog_page_id};
    }elsif($method eq 'add'){
        $blog_page_ids{$blog_page_id} = 1;
    }else{
        die $method.' is not defined.';
    }

    container('db')->update('blog_category',
        { blog_page_ids => \%blog_page_ids },
        { tag => $tag }
    );
}


1;

