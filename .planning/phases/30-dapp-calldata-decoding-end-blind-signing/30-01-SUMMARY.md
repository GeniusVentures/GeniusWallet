---
phase: 30-dapp-calldata-decoding-end-blind-signing
plan: 01
status: in-progress
---

# Phase 30 Plan 01: Tracer - one ERC-20 transfer decoded end to end

## Baseline

Measured on the untouched `phase-30-calldata-decoding` tree before any edit.

| Check | Result | Exit |
|---|---|---|
| `flutter analyze` | `No issues found! (ran in 4.1s)` — 0 issues | 0 |
| `flutter test` | `+1216 ~3: All tests passed!` — 1216 pass, 3 skip, 0 fail | 0 |
| `dart format --output=none --set-exit-if-changed lib test` (CI's scope) | `Formatted 399 files (0 changed)` | 0 |
| `dart format --output=none --set-exit-if-changed .` (whole tree) | `Formatted 931 files (365 changed)` — **already red at baseline** | 1 |
| `bash tool/check_brace_style.sh` | clean | 0 |
| `bash tool/check_raw_colors.sh` | clean | 0 |

The whole-tree `dart format` is red before this plan touches anything: the 365
changed files are in `squidrouter/` and `banxa/`, which AGENTS.md declares
auto-generated. CI checks `lib test` only (`build.yml:1396`); that is the gate
this plan holds to.
