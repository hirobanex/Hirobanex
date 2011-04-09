package Hirobanex::Api::Stash;
use strict;
use warnings;
use utf8;
use Hirobanex::Container qw/api/;
use Smart::Args;

sub new { bless {}, +shift }

sub fetch_article {
    args_pos my $self,
             my $where => { isa => 'HashRef', default => {}};

    my $row = api('BlogPage')->fetch_single($where);

    return +{
        id            => $row->id,
        title         => $row->title,
        description   => $row->description,
        content       => $row->content,
        category_tag1 => $row->category_tag1,
        category_tag2 => $row->category_tag2,
        created_date  => $row->created_at->ymd,
        updated_at    => $row->updated_at,
        url           => container('conf')->{site_url}.'article/'.$row->created_year.'/'.$row->created_month.'/'.$row->id
    };
}

sub fetch_blog_by {
    my ($self,$table,$where) = @_;

    $where ||= {};

    [map {$_->get_columns} @{api('BlogBy')->fetch_list($table,$where)}];
}

sub fetch_list {
    my ($self,$where,$page) = @_;
    
    my ($itr,$pager) = api('BlogPage')->fetch_list(
        where => $where,
        limit => 10,
        page  => $page || 1,
    );
    
    return (__get_view_list_data($itr),$pager);
}

sub fetch_list_with_blog_category_tag {
    my ($self,$blog_category_tag,$page) = @_;

    my $blog_page_ids = [keys %{api('BlogCategory')->fetch_blog_page_ids($blog_category_tag)}];

    return unless($blog_page_ids);
    return unless(scalar(@$blog_page_ids));

    my $where = {id => { 'in' => $blog_page_ids } };

    $self->fetch_list($where,$page);
}

sub __get_view_list_data {
    [map {
        my $row = $_;

        {
            id            => $row->id,
            title         => $row->title,
            description   => $row->description,
            category_tag1 => $row->category_tag1,
            category_tag2 => $row->category_tag2,
            permalink     => '/article/'.$row->created_year.'/'.$row->created_month.'/'.$row->id,
            created_date  => $row->created_at->ymd,
            updated_at    => $row->updated_at,
        }
    } $_[0]->all];
}

sub fetch_categorys_has_article {
    my ($self) = @_;

    [grep { $_->{article_count} } @{$self->fetch_categorys}];
}

sub fetch_categorys {
    my ($self) = @_;

    [map {
        {
            id            => $_->id,
            tag           => $_->tag,
            article_count => scalar(keys %{$_->blog_page_ids}),
            created_date  => $_->created_date->ymd,
            updated_at    => $_->updated_at,
        }
    } @{api('BlogCategory')->fetch_list}];
}

use URI::Escape;
sub fetch_list_sitemap {
    my ($self) = @_;

    my @articles = map {
        {
            lastmod     => api('DateTime')->covert_w3c_format($_->updated_at),
            permalink   => container('conf')->{site_url}.'article/'.$_->created_year.'/'.$_->created_month.'/'.$_->id,
        }
    } container('db')->search('blog_page',{},{
        select => [qw/
            id
            created_year
            created_month
            updated_at
        /],
    })->all;

    
    
    my @categorys = map {
        {
            lastmod   => api('DateTime')->covert_w3c_format($_->{updated_at}),
            permalink => container('conf')->{site_url}.'category/'.uri_escape_utf8($_->{tag}),
        }
    } @{$self->fetch_categorys_has_article};

    my $path = container('conf')->{site_url}.'article/';

    [
        @categorys,
        @{__fetch_sitemap_archive_pages('blog_by_year', sub { $path.$_->created_year.'/'                      })},
        @{__fetch_sitemap_archive_pages('blog_by_month',sub { $path.$_->created_year.'/'.$_->created_month.'/'})},
        @articles
    ];
}

sub __fetch_sitemap_archive_pages {
    my ($table,$code) = @_;

    [map {
        {
            lastmod   => api('DateTime')->covert_w3c_format($_->updated_at),
            permalink => $code->($_),
        }
    } @{api('BlogBy')->fetch_list($table)}];
}

sub fetch_list_rss {
    my ($self) = @_;
 
    [ map {
        my $row = $_;        

        {
            title       => $row->title,
            description => $row->description,
            pubDate     => api('DateTime')->covert_rfc822_format($row->created_at),
            permalink   => container('conf')->{site_url}.'article/'.$row->created_year.'/'.$row->created_month.'/'.$row->id,
        }
    } api('BlogPage')->fetch_list(limit => 20)->all];
}


1;

