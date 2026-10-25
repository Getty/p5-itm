# ITM House Rules

The shared house rules come from skilletor — bundle `getty-cpan-dist@getty`: engineering
discipline, the delegation lock, the publish gate, karr coordination, CPAN release. They load
as `.claude/rules/.local.*.md`; if they are missing, run `skilletor sync` and publish nothing
until they load. This file adds what is true only here, and wins where it differs.

## What this repo is

ITM/SWD deserializer — the decoder for the ITM instrumentation trace format.

## Agent team

| Task | Agent |
|---|---|
| Implement / refactor / debug behavior-relevant code | `itm-worker` (default) |
| Commits, `Changes`, card → done, pre-release audit | `itm-release-manager` |
| Read-only research, audit, gap analysis | `itm-worker` ("read-only, change nothing") |

Behavior-relevant = `lib/`, the tests, the parser. README and `Changes` wording are not.

## Hazards — the wire format is the product, don't regress it silently

- **The contract:** the 8-bit header layout, what `itm_header` returns, which byte maps to
  which packet type, the two call forms of `itm_parse`, the error behaviour on a mismatching
  payload length, and the shape of the returned packet objects. A change to any of them is
  visible to every caller: it needs a `Changes` entry and a test that pins it. Full contract
  table: skill `itm-core`.
- **The documented behaviour is the contract** — no fallbacks for features that do not exist.
- **`ITM_TIMESTAMP`, `ITM_EXTENSION` and `ITM_RESERVED` are exported but the decoder never
  produces them** — that gap is an open decision, not something to paper over quietly.

## Perl specifics — reference, don't restate

Perl conventions live in the force-loaded skills; the module map, the header layout and the
parse contract live in skill `itm-core`.
