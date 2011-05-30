package Hirobanex::Web::Controller::Manage;
use Kamui::Web::Controller -base;
use Hirobanex::Container qw/api/;

__PACKAGE__->authorizer('+Hirobanex::Web::Authorizer::BasicAuth');

__PACKAGE__->add_trigger(
    'before_dispatch' => sub{
        my ($class, $c) = @_;

    },
);

sub do_index {
    my ($class, $c, $args) = @_;


}

#do_blog_pageとインターフェース同じにする
#一覧の閲覧ページは別で用意する
sub do_blog_category {
    my ($class, $c, $args) = @_;

    my $form = api('Form')->get_form('blog_category',$c->req);

    if (my $id = $args->{id}) {
        my $row = api('BlogCategory')->fetch_single($id);
    
        if($c->req->is_post_request && $form->submitted_and_valid){
            my $updates = $form->params;
            api('BlogCategory')->modify($row,$updates);

            $c->redirect('/manage/blog_category');
        }else{
            $form->model->fill($row);

            $c->stash->{blog_category_id} = $row->id;
        }
    }else{
        if($c->req->is_post_request && $form->submitted_and_valid){
            api('BlogCategory')->register($form);
            
            $c->redirect('/manage/blog_category');
        }else{
            $c->stash->{list_blog_category} = api('Stash')->fetch_categorys;
        }
    }

    $c->stash->{form_blog_category} = $form;
}

sub do_blog_page {
    my ($class, $c, $args) = @_;

    my $form = api('Form')->get_form('blog_page',$c->req);

    if (my $id = $args->{id}) {
        my $row = api('BlogPage')->fetch_single({id => $id});
    
        if($c->req->is_post_request && $form->submitted_and_valid){
            api('BlogPage')->modify($form,$row);

            $c->redirect('/manage/blog_page');
        }else{
            $form->model->fill($row);

            $c->stash->{blog_page_id} = $row->id;
        }
    }else{
        if($c->req->is_post_request && $form->submitted_and_valid){
            api('BlogPage')->register($form);
            
            $c->redirect('/manage/blog_page');
        }else{
            ($c->stash->{list_blog_page},undef) = api('Stash')->fetch_list({});
        }
    }

    $c->stash->{form_blog_page} = $form;
}

1;

