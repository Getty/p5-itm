package ITM::Role;
# ABSTRACT: Shared contract of the ITM packet classes

use strict;
use warnings;
use Moo::Role;

our $VERSION = '0.002';

requires qw( type );

has payload => (
  is => 'ro',
  predicate => 1
);

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
