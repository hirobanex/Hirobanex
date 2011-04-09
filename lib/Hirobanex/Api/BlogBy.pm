package Hirobanex::Api::BlogBy;
use strict;
use warnings;
use Hirobanex::Container qw/api/;
use Smart::Args;

sub new { bless {}, +shift }

sub register_or_modify {
    my ($self,$table,$where) = @_;

    my $row = container('db')->find_or_create($table,$where);

    $row->update({ article_count => \'article_count + 1'});
}

sub fetch_list{
    my ($self,$table,$where) = @_;

    [container('db')->search($table,$where,{order_by => {id => 'desc'}})->all];
}



1;

