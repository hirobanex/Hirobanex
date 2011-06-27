use Kamui;
use Hirobanex::Container;
use Path::Class;
use HTML::Entities qw//;

return +{
    view => {
        tt => +{
            path => container('home')->file('assets/tmpl')->stringify,
            filters => +{
                html_unescape => sub {
                    HTML::Entities::decode_entities(shift);
                },
            },
        },
    },

    site_name         => 'your site name title',
    site_url          => 'http://example.com',
    site_description  => 'your site description',

    users => +{
        user_id => 'your passwd',
    },
    
    datasource => +{
        dsn      => 'yours',
        username => 'yours',
        password => 'yours',
    },
    datasource_t => +{
        db_name  => 'yours',
        username => 'yours',
        password => 'yours',
    },

    twitter_source => {
        traits              => [qw/API::REST OAuth/],
        consumer_key        => 'yours',
        consumer_secret     => 'yours',
        access_token        => 'yours',
        access_token_secret => 'yours',
    },
};
