use Kamui;
use Hirobanex::Web::Handler;
use Hirobanex::Container;
use Plack::Builder;

my $app = Hirobanex::Web::Handler->new;

my $home = container('home');

builder {
   enable "Plack::Middleware::Static",
           path => qr{^/(images/|js/|css/|docs/|robots\.txt|favicon\.ico)},
           root => $home->file('assets/htdocs')->stringify;

   enable "Plack::Middleware::ReverseProxy";

   $app->handler;
};

