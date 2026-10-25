#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use ITM;

my @cases = (
  [ chr(0),          'ITM::Sync',            ITM_SYNC ],
  [ chr(112),        'ITM::Overflow',        ITM_OVERFLOW ],
  [ chr(1).chr(42),  'ITM::Instrumentation', ITM_INSTRUMENTATION ],
  [ chr(5).chr(42),  'ITM::HardwareSource',  ITM_HARDWARE_SOURCE ],
);

for my $case ( @cases ) {
  my ( $bytes, $class, $type ) = @{$case};
  my $itm = itm_parse($bytes);
  isa_ok( $itm, $class );
  is( eval { $itm->type }, $type, $class.'->type is the constant number' )
    or diag $@;
}

done_testing;
