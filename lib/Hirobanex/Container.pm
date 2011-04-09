package Hirobanex::Container;
use Kamui::Container -base;

register db => sub {
    my $self = shift;
    $self->load_class('Hirobanex::Model::DB');
    Hirobanex::Model::DB->new($self->get('conf')->{datasource});
};

register timezone => sub {
    my $self = shift;
    $self->load_class('DateTime::TimeZone');
    DateTime::TimeZone->new(name => 'Asia/Tokyo');
};

register twitter => sub {
    my $self = shift;
    $self->load_class('Net::Twitter');
    Net::Twitter->new(%{$self->get('conf')->{twitter_source}});
};


1;

