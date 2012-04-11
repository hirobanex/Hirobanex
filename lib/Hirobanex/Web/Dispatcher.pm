package Hirobanex::Web::Dispatcher;
use Kamui::Web::Dispatcher;

on '/' => run {
    'Root', 'index', FALSE, +{};
};

on '/search' => run {
    'Root', 'search', FALSE, +{};
};

on '/sitemap.xml' => run {
    'Root', 'sitemap', FALSE, +{};
};

on '/rss' => run {
    'Root', 'rss', FALSE, +{};
};

on '/category/(.+?)' => run {
    'Root', 'category', FALSE, +{ blog_category_tag => $1 };
};

on '/article/(\d{4})/' => run {
    'Root', 'by_year', FALSE, +{ created_year => $1 };
};

on '/article/(\d{4})/(\d{2})/' => run {
    'Root', 'by_month', FALSE, +{ created_year => $1, created_month => $2 };
};

on '/article/(\d{4})/(\d{2})/(.+)' => run {
    'Root', 'article', FALSE, +{ created_year => $1, created_month => $2, id => $3 };
};

on '/manage' => run {
    'Manage', 'index', TRUE, +{};
};

on '/manage/set_cookie' => run {
    'Manage', 'set_cookie', FALSE, +{};
};

on '/manage/(blog_category|blog_page)/?(.*)' => run {
    'Manage', $1, FALSE, +{ id => $2};
};


1;
