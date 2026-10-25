package ITM::Overflow;
# ABSTRACT: ITM overflow packet

use strict;
use warnings;
use Moo;
use ITM;

our $VERSION = '0.002';

with qw( ITM::Role );

sub type { ITM_OVERFLOW() }

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
