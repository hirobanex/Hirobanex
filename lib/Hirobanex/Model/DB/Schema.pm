package Hirobanex::Model::DB::Schema;
use DBIx::Skinny::Schema;

use Hirobanex::Container qw/api/;
use JSON::XS;

install_table blog_by_month => schema {
    pk qw/id/;
    columns qw/id created_year created_month article_count updated_at/;
};

install_table blog_by_year => schema {
    pk qw/id/;
    columns qw/id created_year article_count updated_at/;
};

install_table blog_category => schema {
    pk qw/id/;
    columns qw/id tag blog_page_ids created_date updated_at/;
};

install_table blog_page => schema {
    pk qw/id/;
    columns qw/id title description content category_tag1 category_tag2 created_year created_month created_at updated_at/;
};

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

1;