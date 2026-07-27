---
phase: 08-swap-bridge
plan: 07
subsystem: verification
tags: [walk, verification, human-checkpoint, swap, bridge, wcag, defects]

requires:
  - phase: 08-01..08-06
    provides: "the finished swap and bridge surfaces this walk inspects"
provides:
  - ".planning/phases/08-swap-bridge/08-VERIFICATION.md — the walk record and SCR-04's gate, closed passed with two explicit overrides"
  - "nine defect fixes found by eye that the test suite could not catch"
  - "50 new tests (326 → 376) pinning what the walk exposed"
  - "two design decisions: sketch 065-C (chain grouping) and 066-B (big-number rendering)"
affects: [09-banxa, 10-dapp-connectivity, sketch-154, phase-10-reown]

tech-stack:
  added: []
  patterns:
    - "Debug-only FlutterError.resetErrorCount() so every error reports its own widget path — presentError otherwise prints the full block for the FIRST error only, and a boot-time overflow permanently consumes it"

key-files:
  created:
    - .planning/phases/08-swap-bridge/08-VERIFICATION.md
    - lib/squid_router/held_tokens.dart
    - lib/squid_router/swap_preselection.dart
    - test/squid_router/squid_balance_test.dart
    - test/squid_router/held_tokens_test.dart
    - test/squid_router/token_selector_empty_state_test.dart
    - test/squid_router/swap_preselection_test.dart
    - .planning/sketches/065-token-row-chain/
    - .planning/sketches/066-big-number-rendering/
  modified:
    - lib/squid_router/models/squid_balance.dart
    - lib/squid_router/swap_settings_drawer.dart
    - lib/squid_router/swap_screen.dart
    - lib/squid_router/token_selector_drawer.dart
    - lib/squid_router/swap_field.dart
    - lib/squid_router/squid_token_service.dart
    - lib/components/overlay/global_swap_fab_host.dart
    - lib/tokens/token_info_screen.dart
    - lib/navigation/router.dart
    - lib/main.dart

key-decisions:
  - "The plan was executed AGAINST its own DO-NOT-EXECUTE banner, deliberately. D-22 had descoped this walk on 2026-07-25; Braian reinstated it on 2026-07-27 when offered the choice. Both the descope and the reinstatement are recorded in the verification frontmatter."
  - "08-07 forbids source changes ('record it — fixes belong to a gap-closure plan'). That rule was crossed NINE times, each with Braian asked and answering first. It was NOT crossed for the two drawer-padding defects: those live in files fenced off by D-05 (reown, Phase 10) and 08-05 (showTransactionDetails), and he chose to respect both fences."
  - "Phase closed `passed` with two explicit overrides rather than `human_needed`: light mode declined, criterion 4 at dry-run depth. D-22 named exactly this route and forbade the alternative — fabricated walk evidence. None is fabricated; every PASS was earned in dark, by a person, at the running app."
---

# 08-07 — The Phase 8 Walk

## What this plan was, and what it became

Written as a pure verification plan: walk the finished surfaces, change no source, record verdicts.
It carried a `DO NOT EXECUTE` banner because **D-22** had descoped it two days earlier. Offered the
choice on 2026-07-27, Braian reinstated it — and the walk immediately started finding things, so it
became a find-and-fix session with a verification record attached.

**Nine defects, none catchable by the 376-test suite**, in the order they surfaced:

| Commit | Defect |
|--------|--------|
| `1445549` | `pow(10, decimals) as double` threw for **every** token with a balance — `pow` returns an int. `displayBalance` swallowed it and rendered `0`; `fromBalanceAmount` did not and threw during build. Dormant since 2025-05-12; 08-03 added the first unguarded caller. **Made walk item 5 testable at all.** |
| `e64bdf9` | Apply in Swap Settings popped the *swap route*, dropping the user on the dashboard — caller-context `Navigator.of` resolved to the shell's nested navigator while the drawer sat on the root. |
| `70f4282` | The "You Pay" picker offered tokens the wallet does not hold. *"a user can't simply swap a BNB he does not have."* |
| `651f371` | Magnitude stress fixtures — no mock balance had ever exercised a real token magnitude. |
| `10be9c3` | The swap FAB stayed visible on `/swap`. `push` never moves `currentConfiguration.uri`, so the host read the *previous* route. Every existing test used `go` — the one path that was never broken. |
| `faaa74b` | Fees-table→CTA gap halved (32 → 16px; the card's own margin made the real gap larger than the constant suggested). |
| `1c59010` | The token page's Swap button wired at last — 07 had deferred it here in writing: *"Swap is Phase 8's"*. |
| `1c84d61` | That button silently did nothing: `/token-info` is outside the `ShellRoute` and `/swap` inside it, so `push` duplicated the root navigator's GlobalKey. Plus coin preselection. |
| `d7ebd04` | Preselection was fed the *wallet's* selected coin instead of the coin on screen. |

## The two things that made the invisible visible

**`84c2105` — the diagnostic.** Three overflows (7.1px, 8.1px, 106px) could not be attributed to any
widget. Not bad luck: `presentError` prints the full report for the **first** error of a run only,
and the dashboard chart's boot overflow permanently consumes it. `resetErrorCount()` under
`kDebugMode` fixed that — and the very next error it printed in full was the GlobalKey collision
that explained why the token page's Swap button did nothing.

**The mock fixtures.** `651f371` put 1e-15 through 1e12 into the picker, which is what prompted
sketch 066 and exposed how little the middle-sized mock data had ever asked of the layout.

## What was recorded rather than fixed

- **Drawer body padding** — `reown/swap_result_drawer.dart` and `_buildDetailsCard` both render
  flush to the panel edge. Fenced off by D-05 and 08-05; routed to Phase 10 and sketch 154, which
  had already recorded the identical finding.
- **The flip control** can still seat a zero-balance token on the filtered pay side.
- **GNUS is absent from the swap catalogue** — the wiring is correct, the catalogue is mocked, and
  whether the live Squid list carries GNUS is unknown. If it does not, the GNUS page's Swap button
  should be gated the way `More` already is.
- **`crypto_live_chart.dart:372`** overflows 33px on every boot — outside this phase's surfaces.

## Design decisions taken

**065 · C — grouped by chain.** The picker never named which chain a token was on, so the same
symbol read as identical rows. Costs a `SliverPersistentHeader`/`CustomScrollView` swap.

**066 · B — grouped digits with the exact value beneath.** Never hide a digit in a balance you are
about to spend.

⚠ They compound: C adds a header per chain, B adds a line per row, in the same list. The mitigation
carried into both READMEs — render the second line only when the grouped form differs — must
survive implementation.

## What is NOT verified

- **Light mode, entirely.** Declined by Braian. D-15's rule names both modes, so half of it is
  untested, and the disabled CTA fills and red error tint are exactly what fails against a light
  surface.
- **Criterion 4's result path.** Dry-run depth, no `bridgeOut`. Whether "Minted" reads acceptably
  for a bridge, and whether staying on the bridge screen after the receipt is acceptable, both
  remain open.

Both are recorded as accepted overrides in `08-VERIFICATION.md`, not as passes.

## Self-Check: PASSED

- `flutter analyze lib` — 59 issues, against the 61 baseline. No new issues in any touched file.
- `flutter test` — 376 pass / 1 known pre-existing failure (`local_wallet_storage_test.dart`,
  "Missing definition of `main`", unrelated to this phase). 326 at the start of the walk.
- `08-VERIFICATION.md` exists, reads `passed` via `gsd-tools query verification.status`, and carries
  both overrides with `accepted_by`.
