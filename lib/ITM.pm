package ITM;
# ABSTRACT: Debug ITM/SWD stream deserializer

use strict;
use warnings;
use bytes;
use Carp qw( croak );
use Exporter 'import';
use List::Util qw( sum );

use ITM::Sync;
use ITM::Overflow;
use ITM::Instrumentation;
use ITM::HardwareSource;

sub ITM_SYNC            { 1 }
sub ITM_OVERFLOW        { 2 }
sub ITM_TIMESTAMP       { 3 }
sub ITM_EXTENSION       { 4 }
sub ITM_RESERVED        { 5 }
sub ITM_INSTRUMENTATION { 6 }
sub ITM_HARDWARE_SOURCE { 7 }

our @EXPORT = qw(

  ITM_SYNC ITM_OVERFLOW ITM_TIMESTAMP ITM_EXTENSION ITM_RESERVED ITM_INSTRUMENTATION ITM_HARDWARE_SOURCE

  itm_header itm_parse

);

sub itm_size {
  my ( $b0, $b1 ) = @_;
  return 1 if $b0 && !$b1;
  return 2 if !$b0 && $b1;
  return 4 if $b0 && $b1;
}

sub itm_header {
  my ( $byte ) = @_;
  my $bits = unpack('b8',$byte);
  my @b = reverse(split(//,$bits));
  if ($bits eq '00000000' || $bits eq '10000000') {
    return { type => ITM_SYNC, size => 0 };
  } elsif ($b[0] == 0 && $b[1] == 0) { # Not Instrument / Hardware Source
    return { type => ITM_OVERFLOW, size => 0 };
  } elsif ($b[2] == 0) {
    return { type => ITM_INSTRUMENTATION, size => itm_size(@b[0..1]), source => ord(pack('b*',join('',@b[3..7]))) };
  } elsif ($b[2] == 1) {
    return { type => ITM_HARDWARE_SOURCE, size => itm_size(@b[0..1]), source => ord(pack('b*',join('',@b[3..7]))) };
  }
  return undef;
}

sub itm_parse {
  my ( @args ) = @_;
  if (scalar @args == 1) {
    my ( $header_byte, @data ) = split(//,$args[0]);
    return _itm_parse(itm_header($header_byte), join("",@data));
  } elsif (scalar @args == 2) {
    return _itm_parse(@args);
  }
  croak(__PACKAGE__."::itm_parse Unknown parameter count");
}

sub _itm_parse {
  my ( $header, $payload ) = @_;
  if (length($payload) != $header->{size}) {
    croak(__PACKAGE__."::itm_parse given payload doesn't size required size");
  }
  delete $header->{size};
  if ( $header->{type} == ITM_SYNC ) {
    return ITM::Sync->new( %{$header} );
  } elsif ( $header->{type} == ITM_OVERFLOW ) {
    return ITM::Overflow->new( %{$header} );
  } elsif ( $header->{type} == ITM_INSTRUMENTATION ) {
    return ITM::Instrumentation->new( %{$header}, payload => $payload );
  } elsif ( $header->{type} == ITM_HARDWARE_SOURCE ) {
    return ITM::HardwareSource->new( %{$header}, payload => $payload );
  }
}

1;

=head1 SYNOPSIS

=head1 DESCRIPTION

=head1 SUPPORT

IRC

  Join #hardware on irc.perl.org. Highlight Getty for fast reaction :).

Repository

  http://github.com/Getty/p5-itm
  Pull request and additional contributors are welcome
 
Issue Tracker

  http://github.com/Getty/p5-itm/issues
