package Hirobanex::Web::Handler;
use Kamui::Web::Handler;

use_container  'Hirobanex::Container';
use_context    'Hirobanex::Web::Context';
use_dispatcher 'Hirobanex::Web::Dispatcher';
use_plugins [qw/
    Encode
/];
use_view 'Kamui::View::TT';

1;

