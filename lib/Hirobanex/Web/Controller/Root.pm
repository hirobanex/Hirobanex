package Hirobanex::Web::Controller::Root;
use Kamui::Web::Controller -base;
use Hirobanex::Container qw/api/;
use URI::Escape;

__PACKAGE__->add_trigger(
    'before_dispatch' => sub{
        my ($class, $c) = @_;

        if($c->req->param('page') && $c->req->param('page') == 1){
            $c->redirect($c->req->{env}->{PATH_INFO});
            $c->detach;
        }

        $c->stash->{category_list} = api('Stash')->fetch_categorys_has_article;
        $c->stash->{month_list}    = api('Stash')->fetch_blog_by('blog_by_month');
        $c->stash->{year_list}     = api('Stash')->fetch_blog_by('blog_by_year');
    },
);

sub do_index {
    my ($class, $c) = @_;

    my ($article_list,$pager) = api('Stash')->fetch_list({},$c->req->param('page'));

    unless(scalar(@$article_list)){
        $c->handle_404;
        $c->detach;
    }

    $c->stash->{title}            = container('conf')->{site_name};
    $c->stash->{meta_description} = container('conf')->{site_description};
    $c->stash->{article_list}     = $article_list;

    $c->load_template('root/list.html');
}

#handle_404の呼び出しがかっこわるい　handlerの流れをもう一度確認
sub do_article {
    my ($class, $c, $args) = @_;

    unless($args->{created_year} && $args->{created_month} && $args->{id}){
        $c->handle_404;
        $c->detach;
    }

    my $article = api('Stash')->fetch_article($args);

    unless($article){
        $c->handle_404;
        $c->detach;
    }

    $c->stash->{article}         = $article;
    $c->stash->{title}           = $c->stash->{article}->{title}.' | '.container('conf')->{site_name};
    $c->stash->{meta_desription} = $c->stash->{article}->{desription};

    $c->load_template('root/page.html');
}

sub do_by_month {
    my ($class, $c, $args) = @_;

    unless($args->{created_year} && $args->{created_month}){
        $c->handle_404;
        $c->detach;
    }

    my ($article_list,$pager) = api('Stash')->fetch_list($args,$c->req->param('page'));

    unless(scalar(@$article_list)){
        $c->handle_404;
        $c->detach;
    }

    $c->stash->{h1} = $args->{created_year}.'年'.$args->{created_month}.'月'.'に書いた記事のリスト';
    if($pager){
        $c->stash->{h1}    .= ' '.$pager->{current_page};
        $c->stash->{pager}  = $pager;
    }
    $c->stash->{title}        = $c->stash->{h1}.' | '.container('conf')->{site_name};
    $c->stash->{robots}       = 1;
    $c->stash->{article_list} = $article_list;
    
    $c->load_template('root/list.html');
}

sub do_by_year {
    my ($class, $c, $args) = @_;

    unless($args->{created_year}){
        $c->handle_404;
        $c->detach;
    }

    my $month_list_per_year = api('Stash')->fetch_blog_by('blog_by_month',$args);

    unless(scalar(@$month_list_per_year)){
        $c->handle_404;
        $c->detach;
    }

    $c->stash->{h1}                  = $args->{created_year}.'年';
    $c->stash->{title}               = $c->stash->{h1}.' | '.container('conf')->{site_name};
    $c->stash->{robots}       = 1;
    $c->stash->{month_list_per_year} = $month_list_per_year;
    
    $c->load_template('root/by_year.html');
}

sub do_category {
    my ($class, $c, $args) = @_;

    my $blog_category_tag = api('Utils')->uri_decode($args->{blog_category_tag});
   
    my ($article_list,$pager) = api('Stash')->fetch_list_with_blog_category_tag($blog_category_tag,$c->req->param('page'));

    unless(scalar(@$article_list)){
        $c->handle_404;
        $c->detach;
    }
    
    $c->stash->{h1} = 'カテゴリ「'.$blog_category_tag.'」の一覧';
    if($pager){
        $c->stash->{h1}    .= ' '.$pager->{current_page};
        $c->stash->{pager}  = $pager;
    }
    $c->stash->{title}        = $c->stash->{h1}.' | '.container('conf')->{site_name};
    $c->stash->{robots}       = 1;
    $c->stash->{article_list} = $article_list;

    $c->load_template('root/list.html');
}

sub do_rss {
    my ($class, $c, $args) = @_;

    $c->stash->{article_list} = api('Stash')->fetch_list_rss;

    $c->add_filter(sub {
        my ($context,$res) = @_;
        $res->headers([ 'Content-Type' => 'application/xml' ]);
        $res;
    });
    $c->load_template('rss');
}

sub do_sitemap {
    my ($class, $c, $args) = @_;

    $c->stash->{article_list} = api('Stash')->fetch_list_sitemap;
 
    $c->add_filter(sub {
        my ($context,$res) = @_;
        $res->headers([ 'Content-Type' => 'text/xml' ]);
        $res;
    });
    $c->load_template('sitemap.xml');
}
1;

