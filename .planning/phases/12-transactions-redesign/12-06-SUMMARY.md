---
phase: 12-transactions-redesign
plan: 06
subsystem: dashboard/transactions
tags: [transactions, human-walk, dark-only, verification, no-unearned-pass]
type: checkpoint:human-verify
requires:
  - "12-01 (badge system)"
  - "12-02 (pure content derivation)"
  - "12-03 (TransactionRow anatomy)"
  - "12-04 (F1 two-tier filter UI)"
  - "12-05 (day grouping + two empty states + dev fixture)"
provides:
  - "observed dark-mode verdict for TX-01..TX-11 — the gate that closes Phase 12"
affects: []
key-files:
  modified: []
walk:
  date: 2026-07-24
  walker: Jakub
  build: flutter run -d macos --dart-define=GW_DEV_TOOLS=true (Flutter 3.41.9)
  mode: DARK ONLY (light deferred by standing policy — see below)
  fixture: dev-bubble MOCK "Mock txns" (11 txns, 7 types, 4 statuses, 3 calendar days)
decisions:
  - "Checkpoints A + B walked and APPROVED in dark with no defects — no Rule-1 walk-driven fix was needed."
  - "Checkpoint C (light) NOT walked — deferred whole to the dedicated app-wide light pass at Jakub's explicit call; recorded as a deferral, NOT a pass, per no-unearned-PASS."
status: complete
---

# Phase 12 Plan 06: Human walk of the redesigned transactions surface — Summary

The redesigned transactions panel was walked on a real macOS screen with the extended
mock batch loaded, in dark, at multi-column and narrow widths, and on both the dashboard
panel and the full-page `/transactions` route. **Checkpoints A and B were approved with
no defects.** Checkpoint C (light mode) was deferred whole to the dedicated light pass.

**No commits created.** `./CLAUDE.md` holds the commit gate; nothing was staged.

## Precondition gates (Task 1)

- `flutter analyze lib` → **61 issues, exactly at the STATE baseline (delta 0).**
- Scoped `flutter analyze lib/dashboard/home/widgets lib/dev lib/theme` → 2 `info`
  (`unnecessary_const` at `lib/dev/design_gallery_screen.dart:196,232`) — pre-existing
  dev-gallery nits, outside the transactions surface, not a regression from this phase.
  Filed as a note, not a blocker.
- `flutter test` was NOT run concurrently: the app instance holds the Hive container lock
  and a parallel test run fights it (the exact collision `./CLAUDE.md` warns about).
  Deferred to run with the app closed. **OUTSTANDING (non-blocking).**

## Console evidence (whole walk, dark)

Zero `RenderFlex overflowed`, zero exceptions, zero `setState after dispose`, zero
HardwareKeyboard assertions across the checkpoints. The only console noise was a CoinGecko
`429` rate-limit that falls back to cached market data (expected, unrelated to this panel).

> Session note: the walk was initially blocked by a "can't type in any field" wedge. Root
> cause was a **stale second app instance** holding the Hive lock and stealing key-ups
> (HardwareKeyboard Space desync), NOT this phase's code. Cleared by killing both instances
> (`Genius Wallet.app` — the binary name has a space) and relaunching one. Recorded in
> agent memory; not a Phase 12 defect.

## Per-criterion verdict (TX-01..TX-11)

| Req | What | Verdict | Evidence |
|-----|------|---------|----------|
| TX-01 | One row anatomy for all 7 types (content + presentation) | **PASS** (dark) | A3 — every row carries icon+badge, token headline, action chip, context line, amount col, time |
| TX-02 | Badge system, glyph legible, ring = panel surface (not white) | **PASS** (dark) | A2 — all 7 badges legible @18px; no white `k81` ring; pickaxe/server glyphs read |
| TX-03 | Enum coverage — all 7 types reachable | **PASS** (dark) | A3 + B7 — Processing/Swapped no longer bare; Swapped/Purchased/Jobs each return rows |
| TX-04 | F1 two-tier filter UI, gradient-only active treatment | **PASS** (dark) | B1–B6 — chip order correct, active = brandCta gradient (never flat blue), `⋯` gradients when overflow filter applied, menu label gradient / glyph unchanged |
| TX-05 | Clamped amount + exact value on hover | **PASS** (dark) | A3 — long ETH renders `123,456,789.12`, does not set panel width, hover tooltip shows full precision |
| TX-06 | Fiat / value line | **PASS** (dark) | A3/A4 — value line present; failed row reads one em-dash + "Not charged", no double zero |
| TX-07 | `Fee:` off the resting row | **PASS** (dark) | A5 — no resting row shows `Fee:`; drawer shows "Network Fee" once |
| TX-08 | Day grouping + per-row timestamp | **PASS** (dark) | A6 — TODAY/YESTERDAY/dated headers; real clock time per row; no repeated relative string |
| TX-09 | Status shown only when not successful | **PASS** (dark) | A4 + B8 — failed/cancelled carry status; Escrow matches escrow+release, Failed matches failed+cancelled |
| TX-10 | One surface, hairline dividers (not per-row cards) | **PASS** (dark) | A7 + A9 — full-bleed straight hairlines; reads as one system with the Assets panel |
| TX-11 | Two visibly different empty states | **PASS** (dark) | B9/B10 — filtered-empty (filter icon + "Show all") vs never-transacted (receipt + "No transactions yet") read as different situations |

All eleven criteria **observed** in dark. None marked PASS on analyze/unit-test strength alone.

Narrow layout (B11): chips collapse to icon-only under ~420px, nothing overflows, expand
animation returns on widen. Full-page route (B12): renders identically. Both PASS.

## Light mode — DEFERRED (recorded, not a pass)

Checkpoint C was **not walked.** Jakub's explicit call: light is handled as one dedicated
app-wide pass once dark is complete, per
`.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md` and the standing
dark-first policy. This is consistent with how 06-02..06-05 closed (dark-only, light
deferred). Carried into that pass, element by element, **unverified — NOT passed**:

- Badge glyph legibility in light (the `k81` / Gap-1 pairing that regressed once before).
- Row text contrast in light (headline, action chip, context, amount, value, timestamp, day header).
- Filter bar in light (rest glyphs, gradient active chip dark-foreground, overflow menu surface/border, gradient menu label).
- Both empty states in light.
- **Live re-skin (dark→light→dark in place).** The plan flags this as a real blocker, not
  a light-only deferral. It was NOT exercised this session (no light flip). Carried into the
  light pass as an explicit UNVERIFIED item to check first — a `const`-widget that fails to
  rebuild would be a genuine bug, not a deferral.

## Walk-driven fixes

None. Both dark checkpoints passed clean; no Rule-1 defect in this phase's own deliverable.

## Follow-ups / todos

- Run `flutter test` with the app closed to clear the deferred precondition (expected: only
  the commented-out `local_wallet_storage_test.dart` red).
- The two `unnecessary_const` info nits in `lib/dev/design_gallery_screen.dart` are a trivial
  cleanup for whoever next touches that dev file — not owned by this phase.
