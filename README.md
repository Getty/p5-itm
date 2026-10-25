# ITM

A deserializer for the ITM/SWD instrumentation trace format: the byte stream an
ARM Cortex-M core emits over its single-wire debug port. It reads bytes and
returns small value objects; it does not talk to hardware.

```perl
use ITM;

my $packet = itm_parse( chr(1).chr(42) );   # an ITM::Instrumentation
print $packet->type, ' ', ord( $packet->payload ), "\n";
```

`itm_header($byte)` decodes the header byte into a hashref (`type`, `size`
and, for software and hardware source packets, `source`). `itm_parse` takes
either the whole packet as a string or a header hashref plus the payload, and
returns an `ITM::Sync`, `ITM::Overflow`, `ITM::Instrumentation` or
`ITM::HardwareSource` object.

## Installation

    cpanm --installdeps .
    prove -lr t/

## Support

IRC: `#hardware` on irc.perl.org. Repository and issues:
<https://github.com/Getty/p5-itm>.

## License

This software is copyright (c) 2015 by Torsten Raudssus. It is free software;
you can redistribute it and/or modify it under the same terms as the Perl 5
programming language system itself.
