package Hirobanex::Api::Form::FilterAlnumH;
use Any::Moose;
with 'HTML::Shakan::Role::Filter';
use Lingua::JA::Regular::Unicode qw(
    alnum_z2h
);

sub filter {
    my ($self, $val) = @_;
    alnum_z2h($val);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;

