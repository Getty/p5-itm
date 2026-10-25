#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

# Checks the source as written; the built dist carries generated POD.
plan skip_all => 'source tree only' unless -e '.git';

my @modules = qw(
  ITM
  ITM::Role
  ITM::Sync
  ITM::Overflow
  ITM::Instrumentation
  ITM::HardwareSource
);

for my $module ( @modules ) {
  ( my $file = 'lib/'.$module.'.pm' ) =~ s{::}{/}g;
  open my $fh, '<', $file or BAIL_OUT('cannot read '.$file);
  my $source = do { local $/; <$fh> };
  like( $source, qr/^our \$VERSION = '[\d.]+';$/m, $module.' carries its own $VERSION' );
  like( $source, qr/^use strict;$/m, $module.' uses strict' );
  like( $source, qr/^use warnings;$/m, $module.' uses warnings' );
  like( $source, qr/^# ABSTRACT: \S/m, $module.' has an ABSTRACT' );
  unlike( $source, qr/^=head1 SUPPORT/m, $module.' has no hand-written SUPPORT' );
}

done_testing;
