package ITM::Sync;
# ABSTRACT: ITM synchronisation packet

use strict;
use warnings;
use Moo;
use ITM;

our $VERSION = '0.002';

with qw( ITM::Role );

sub type { ITM_SYNC() }

1;

=head1 SYNOPSIS

=head1 DESCRIPTION
