use Kamui;
use Hirobanex::Web::Handler;
use Hirobanex::Container;
use Plack::Builder;

my $app = Hirobanex::Web::Handler->new;

my $home = container('home');

builder {
   enable "Plack::Middleware::Static",
           path => qr{^/(images/|js/|css/|robots\.txt|favicon\.ico)},
           root => $home->file('assets/htdocs')->stringify;
=for /usr/sbin/cronolog
   my $log_file = $home->file('assets/log/access.log');
   open my $fh, "| /usr/sbin/cronolog ${home}/assets/log/%Y/%m/myapp-%Y%m%d.log"
   or die "cannot load log file: $!";
   select $fh; $|++; select STDOUT;
   enable 'Plack::Middleware::AccessLog',
   logger => sub { print {$fh} @_ };

   enable "Plack::Middleware::ReverseProxy";
=cut

   $app->handler;
};

