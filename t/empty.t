#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use ITM;

my @warnings;
local $SIG{__WARN__} = sub { push @warnings, @_ };

my $itm = eval { itm_parse('') };
my $error = $@;
ok( !$itm, 'empty input yields no packet object' );
like( $error, qr/header byte/, 'empty input croaks and names the missing header byte' );

is_deeply( \@warnings, [], 'empty input raises no warning' );

done_testing;
