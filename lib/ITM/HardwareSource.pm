package ITM::HardwareSource;
# ABSTRACT: ITM hardware source packet

use strict;
use warnings;
use Moo;
use ITM;

our $VERSION = '0.003';

with qw( ITM::Role );

sub type { ITM_HARDWARE_SOURCE() }

has source => (
  is => 'ro',
  required => 1,
);

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
