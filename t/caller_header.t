#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use ITM;

my $header = itm_header(chr(1));
my %before = %{$header};

my $packet = itm_parse( $header, chr(42) );
isa_ok( $packet, 'ITM::Instrumentation' );
is( ord($packet->payload), 42, 'payload arrives' );
is_deeply( $header, \%before, 'itm_parse leaves the caller header unchanged' );

my $again = itm_parse( $header, chr(43) );
is( ord($again->payload), 43, 'the same header serves a second payload' );

done_testing;
