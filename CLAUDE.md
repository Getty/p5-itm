# CLAUDE.md

## Project Overview

ITM is a **deserializer** for the ITM/SWD instrumentation trace format — the byte
stream an ARM Cortex-M core emits over its single-wire debug port. It reads bytes and
returns small value objects. It does not talk to hardware and ships no binary.

## Modules

- **ITM** — the type constants, `itm_header`, `itm_parse`; the wire format lives here
- **ITM::Role** — the shared contract of the packet classes: a required `type` method
  and the `payload` attribute with its predicate
- **ITM::Sync** — the sync marker, no payload
- **ITM::Overflow** — the overflow marker, no payload
- **ITM::Instrumentation** — software instrumentation packet: payload plus source port
- **ITM::HardwareSource** — hardware source packet: payload plus source port

## The format

Every packet starts with one header byte: b0/b1 give the payload size (0, 1, 2 or 4
bytes), b2 says software or hardware source, b3..b7 are the source port. `itm_parse`
accepts the whole packet as a string, or a header hashref plus the payload, and
returns a packet object.

## Testing

```bash
prove -lr t/
```

Four files: `header.t` (header decoding), `load.t` (the modules load), `parse.t`
(the packets become the right class), `simple.t` (the three basic packets). There is
no `xt/` — no perlcritic, no pod coverage.

## Code Style

- Moo classes with `is => 'ro'`, `croak` instead of `die`
- every file under `lib/` carries its own `our $VERSION`
- the release bundle generates the SUPPORT section — never write it by hand

The conventions above are the short list; the binding ones live in the skills and are
force-loaded into the agents below. Do not restate them here.

## Delegation

Delegate behavior-relevant code to the right agent instead of touching it yourself —
principle in the shared rule `getty-agent-delegation` (skilletor bundle
`getty-cpan-dist@getty`), lanes and hazards in `.claude/rules/itm-rules.md`.

| Task | Agent |
|---|---|
| Implement / refactor / debug behavior-relevant code | `itm-worker` (default) |
| Commits, `Changes`, card → done, pre-release audit | `itm-release-manager` |

Only the release-manager commits; a worker leaves a commit-ready tree and a report.

The agents carry their skills via `briefing.skills` (see `.claude/agents/`); the main
agent delegates rather than loading them. The shared skills under `.claude/skills/`
are **installed** from the Getty library by skilletor — they are not edited here.
`itm-core` is the one skill this repo owns: module map, the header layout, the parse
contract, the vocabulary and the known rough edges.

## State of the code

- The suite is green — `prove -lr t/` runs four files — but it calls neither `->type`
  nor the error paths.
- `->type` dies on **all four** packet classes: the classes call the constants as
  functions, but `ITM.pm` loads them before the constants exist.
- `itm_parse("")` returns an overflow packet instead of failing, with three
  uninitialized-value warnings.
- `itm_parse($header, $payload)` deletes `size` from the caller's header hashref.
- No module carries `our $VERSION`; five lack `use strict; use warnings;` and
  `# ABSTRACT:`; all six carry a hand-written SUPPORT block.
- There is no `Changes`, no `LICENSE` (so `dzil build` aborts), no `README.md`, no CI.
