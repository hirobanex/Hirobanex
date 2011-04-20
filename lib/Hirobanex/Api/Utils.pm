package Hirobanex::Api::Utils;
use strict;
use warnings;
use Hirobanex::Container qw/api/;
use Encode;
use URI::Escape;
use Web::Scraper;

sub new { bless {}, +shift }

sub uri_decode {
    my ($self,$str) = @_;

    decode('utf8',uri_unescape($str));
}

1;

