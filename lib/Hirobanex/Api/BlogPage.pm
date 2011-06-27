package Hirobanex::Api::BlogPage;
use strict;
use warnings;
use utf8;
use Hirobanex::Container qw/api/;
use Smart::Args;

sub new { bless {}, +shift }

sub fetch_single {
    args_pos my $self,
             my $where => { isa => 'HashRef', default => {}};

    container('db')->single('blog_page',$where);
}

sub fetch_list {
    args my $self,
         my $where => { isa => 'HashRef', default => {}},
         my $page  => { isa => 'Int',     default => 1 },
         my $limit => { isa => 'Int',     default => 5 };

    my ($itr, $pager) = container('db')->search_with_pager( 
        blog_page => $where,
        {
            select => [qw/
                id
                title description
                category_tag1 category_tag2
                created_at
                created_year created_month
                updated_at
            /],
            order_by    => {created_at => 'desc'},
            pager_logic => 'MySQLFoundRows',
            page        => $page,
            limit       => $limit,
        }
    );

    return (wantarray) 
        ? ($itr,__make_pager($limit,$pager)) 
        : $itr
    ;
}

sub __make_pager {
    my ($limit,$pager) = @_;

    return if($pager->total_entries < $limit);

    my $pager_obj = { current_page => $pager->current_page };
    if( ($pager->current_page * $limit) < $pager->total_entries){
        $pager_obj->{next_page} = $pager->current_page + 1;
    }else{
        $pager_obj->{next_page} = 'last';
    }

    if($pager->current_page == 1){
        $pager_obj->{prev_page} = 'first';
    }elsif($pager->current_page == 2){
        $pager_obj->{prev_page} = 'top';
    }elsif($pager->current_page > 2){
        $pager_obj->{prev_page} = $pager->current_page - 1;
    }

    return $pager_obj;
}

sub register {
    my ($self,$form) = @_;

    my %form_params = %{$form->params};
    my $tweet = delete $form_params{tweet};

    my $txn = container('db')->txn_scope;
        #my $row = $form->model->create( container('db') => 'blog_page' );
        my $row = container('db')->create('blog_page',\%form_params);

        for my $tag (qw/category_tag1 category_tag2/) {
            next unless($form->param($tag));#category_tag2が空のときがある

            api('BlogCategory')->modify_blog_category_blog_page_ids($form->param($tag),$row->id,'add');
        }

        api('BlogBy')->register_or_modify('blog_by_month',{ created_year => $row->created_year, created_month => $row->created_month });
        api('BlogBy')->register_or_modify('blog_by_year', { created_year => $row->created_year                                       });
        
        my $url = container('conf')->{site_url}.'/article/'.$row->created_year.'/'.$row->created_month.'/'.$row->id;


        if($tweet){
            my $msg = 'ブログ書きました'.'『'.$row->title.'』'.$url;

            container('twitter')->update($msg);
        }
    $txn->commit;
}

sub modify {
    my ($self,$form,$old_row) = @_;

    my $txn = container('db')->txn_scope;
        my $new_row = $form->model->update($old_row);

        for my $tag (qw/category_tag1 category_tag2/) {
            next unless($form->param($tag));#category_tag2が空のときがある

            api('BlogCategory')->modify_blog_category_blog_page_ids($old_row->$tag,$old_row->id,'delete');
            api('BlogCategory')->modify_blog_category_blog_page_ids($form->param($tag),$old_row->id,'add');
        }
    $txn->commit;
}

sub modify_tag {
    my ($self,$args,$old_row) = @_;

    for my $tag (qw/category_tag1 category_tag2/) {
        container('db')->update('blog_page',
            { $tag => $args->{tag} },
            { $tag => $old_row->tag }
        );
    }
}

1;

