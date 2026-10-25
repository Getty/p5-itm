package ITM::Instrumentation;
# ABSTRACT: ITM software instrumentation packet

use strict;
use warnings;
use Moo;
use ITM;

our $VERSION = '0.002';

with qw( ITM::Role );

sub type { ITM_INSTRUMENTATION() }

has source => (
  is => 'ro',
  required => 1,
);

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
