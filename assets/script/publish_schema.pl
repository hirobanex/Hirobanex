#!/usr/bin/env perl
use strict;
use warnings;
use DBIx::Skinny::Schema::Loader qw/make_schema_at/;

my $before = << '...';
use Hirobanex::Container qw/api/;
use JSON::XS;
...

my $after = << '...';
install_utf8_columns qw/
    title
    description
    content
    category_tag1
    category_tag2
    tag
/;

install_table blog_page => schema {
    trigger pre_insert => sub {
        my ($class, $args) = @_;

        $args->{id}         ||= time;
        $args->{updated_at} ||= api('DateTime')->now;
        $args->{created_at} ||= api('DateTime')->now;

        $args->{created_at}   =~ /^(.+?)\-(.+?)\-.+/;

        $args->{created_year}  = $1;
        $args->{created_month} = $2;
    };
};

install_table blog_category => schema {
    trigger pre_insert => sub {
        my ($class, $args) = @_;
        $args->{blog_page_ids} ||= {};
        $args->{created_date}  ||= api('DateTime')->today;
    };
};

install_inflate_rule '^.+_date$' => callback {
    inflate {
        api('DateTime')->inflate_date(+shift);
    };
    deflate {
        api('DateTime')->deflate_date(+shift);
    };
};

install_inflate_rule '^.+_at$' => callback {
    inflate {
        api('DateTime')->inflate_datetime(+shift);
    };
    deflate {
        api('DateTime')->deflate_datetime(+shift);
    };
};

install_inflate_rule 'blog_page_ids' => callback {
    inflate {
        decode_json(+shift);
    };
    deflate {
        encode_json(+shift);
    };
};
...

print make_schema_at(
    'Hirobanex::Model::DB::Schema',
    {
        before_template => $before,
        after_template  => $after,
    },
  [ 'dbi:mysql:hirobanex', 'root', 'bane' ]
);

