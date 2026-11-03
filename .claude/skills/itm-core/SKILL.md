---
name: itm-core
description: "Load before editing ITM — the Moo-based deserializer for ITM/SWD instrumentation trace streams: module map, the 8-bit header layout and its type constants, the payload and size rules, the parse contract, and the rough edges of this repository."
---

# ITM — core

ITM is a **deserializer** for the ITM/SWD protocol — the trace stream an ARM
Cortex-M core emits over its single-wire debug port. The distribution reads a byte
stream and turns it into small value objects. It does not talk to hardware, it knows
nothing about SWD pins or probe drivers, and it ships no binary.

| File | Role |
|---|---|
| `lib/ITM.pm` | the module: the type constants, `itm_header`, `itm_parse`, the private `_itm_parse` |
| `lib/ITM/Role.pm` | the Moo role every packet class consumes: requires `type`, carries `payload` |
| `lib/ITM/Sync.pm` | the synchronisation packet — a marker, no payload |
| `lib/ITM/Overflow.pm` | the overflow packet — the core dropped data, no payload |
| `lib/ITM/Instrumentation.pm` | the software instrumentation packet — payload plus source port |
| `lib/ITM/HardwareSource.pm` | the hardware source packet — payload plus source port |

## The wire format

Every packet starts with one 8-bit header byte. Its bits:

| Bit | Meaning |
|---|---|
| b0, b1 | payload size: `01` → 1 byte, `10` → 2 bytes, `11` → 4 bytes, `00` → no payload |
| b2 | 0 → software instrumentation, 1 → hardware source |
| b3..b7 | the source port number (0..31) |

`itm_header($byte)` decodes that byte and returns a hashref: `{ type => …, size => … }`
and, for the two packet types that carry a source, `source => …`. The size is the
number of payload bytes that follow the header byte.

**The type constants.** `ITM_SYNC` 1, `ITM_OVERFLOW` 2, `ITM_TIMESTAMP` 3,
`ITM_EXTENSION` 4, `ITM_RESERVED` 5, `ITM_INSTRUMENTATION` 6, `ITM_HARDWARE_SOURCE` 7.
They are exported from `ITM` together with `itm_header` and `itm_parse`.

**Which byte decodes to what.** Two header bytes are sync packets: the all-zero byte
and the byte with only b7 set. A byte whose b0 and b1 are both zero is an overflow
packet. Every other byte is an instrumentation packet (b2 = 0) or a hardware source
packet (b2 = 1). `itm_header` therefore never returns a timestamp, extension or
reserved packet — constants 3, 4 and 5 are exported but never produced, and `itm_parse`
has no branch for them.

## The parse contract

`itm_parse` takes two forms:

- `itm_parse($string)` — the whole packet: the header byte plus the payload bytes.
- `itm_parse($header, $payload)` — the header hashref from `itm_header` and the
  payload separately.

Both end in `_itm_parse($header, $payload)`. It checks that the payload length
matches the size the header announced — a mismatch croaks
`ITM::itm_parse given payload doesn't fit required size`, before anything is built —
then it removes `size` from the header hash and hands the rest to the constructor of
the matching packet class: `ITM::Sync`, `ITM::Overflow`, `ITM::Instrumentation` or
`ITM::HardwareSource`. The two payload-carrying classes receive `payload` and
`source`; `source` is `required`, so a header without one croaks in the constructor.

The return value is the object — never a class name, never a plain hash.

## The packet classes

All four consume `ITM::Role`, which requires a `type` method and provides `payload` as
a read-only attribute with a `payload` predicate — so `has_payload` tells "this packet
has no payload" from "the payload is empty".

| Class | `type` | payload | source |
|---|---|---|---|
| `ITM::Sync` | `ITM_SYNC` | never | never |
| `ITM::Overflow` | `ITM_OVERFLOW` | never | never |
| `ITM::Instrumentation` | `ITM_INSTRUMENTATION` | always | required |
| `ITM::HardwareSource` | `ITM_HARDWARE_SOURCE` | always | required |

## Vocabulary

**Header byte** — the first byte of every packet.
**Payload** — the data bytes that follow the header; their number is encoded in b0/b1.
**Source port** — the 5-bit number in b3..b7 that says which software or hardware
source produced the packet.
**Sync packet** — the marker the core sends to align the stream; no payload.
**Overflow packet** — the core dropped data because the reader was too slow; no
payload.
**Instrumentation packet** — a software `printf` from the target; payload plus source
port.
**Hardware source packet** — the same shape, but from a hardware source.

## Rough edges

Real, in the tree:

1. **The croak `Unknown parameter count` is unreachable** — both branches of
   `itm_parse` return before it.
2. **`ITM_TIMESTAMP`, `ITM_EXTENSION` and `ITM_RESERVED` are unreachable** — they are
   exported, `itm_header` never returns them and `_itm_parse` has no branch for them.
3. **`itm_size` returns `undef`** for the combination b0 = 0 and b1 = 0. `itm_header`
   never reaches that combination, but the sub is public and undocumented.
4. **The croak messages carry a doubled package prefix** — `__PACKAGE__` inside
   package `ITM` yields `ITM::itm_parse …`.
5. **No `xt/`** — no perlcritic, no pod coverage.

## Tests

`prove -lr t/` runs the suite: `t/header.t` (header decodings), `t/load.t` (the
modules load), `t/parse.t` (packets become the right class with the right payload),
`t/simple.t` (the three basic packets), `t/type.t` (`->type` of every packet class),
`t/empty.t` (the empty input croaks), `t/caller_header.t` (the caller's header hashref
stays intact), `t/version.t` (every module carries its version).

A change to the contract, or a fix for any rough edge, comes with a test that fails
before it.
