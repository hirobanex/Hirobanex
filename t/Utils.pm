package t::Utils;
use strict;
use warnings;
use utf8;
use lib './t/';
use Test::Fixture::DBIxSkinny;
use Path::Class;
use Encode;
use Hirobanex::Container;
use Hirobanex::Model::DB;

sub import {
    my $caller = caller(0);

    for my $func (qw/
        init_db teardown_db fixture
    /) {
        no strict 'refs'; ## no critic.
        *{$caller.'::'.$func} = \&$func;
    }

    strict->import;
    warnings->import;
    utf8->import;
}

sub dbname { container('conf')->{datasource_t}->{db_name} }

my $fixture;
sub fixture { ## no critic. # construct_fixtureに渡すオプションを設定したいよ
    my $fixture_data = shift;

    return $fixture if $fixture && not $fixture_data;

    my $fixture = construct_fixture(
        db      => container('db'),
        fixture => ($fixture_data || 't/fixture.yaml'),
    );

    $fixture;
}

sub teardown_db() { ## no critic.

    container('conf')->{datasource} = +{
        dsn      => 'dbi:mysql:;mysql_multi_statements=1',
        username => container('conf')->{datasource_t}->{username},
        password => container('conf')->{datasource_t}->{password},
    };
    Hirobanex::Container->remove('db');

    container('db')->do('drop database if exists '.dbname());
}

sub init_db() { ## no critic.

    teardown_db;

    container('db')->do('create database '.dbname());

    my $sql = 'use '.dbname().";\n";
    $sql   .= "set names utf8;\n";
    $sql   .= file('./assets/db/schema.sql')->slurp;

    container('db')->do($sql);

    container('conf')->{datasource} = +{
        dsn      => 'dbi:mysql:'.dbname(),
        username => container('conf')->{datasource_t}->{username},
        password => container('conf')->{datasource_t}->{password},
    };
    Hirobanex::Container->remove('db');

    #sleep(1);
}


