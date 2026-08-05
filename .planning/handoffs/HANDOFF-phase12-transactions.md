> ✅ RESOLVED 2026-07-23 — this handoff is HISTORICAL. The work it describes as uncommitted/next shipped in 8cb4222. Do NOT resume from it. Kept for history.

# HANDOFF — Phase 12 (Transactions redesign), session A

**Written:** 2026-07-22 ~06:30 · **Branch:** `ui-redesign-port` · **HEAD:** `ea33561`
**Status:** implementation complete (5 of 6 plans), **everything uncommitted, by the user's choice**

> Two Claude sessions are working in this same tree at the same time. This file is session A's
> half. Session B owns the boot-sequence / compute-panel work (phases 13-14, sketches 015-018).

---

## THE ONE RULE THAT MATTERS

**Never `git add -A`, `git add .`, or `git commit -a` in this repo.** The working tree holds four
independent sets of changes that must not be mixed:

1. Session A's Phase 12 work (listed below)
2. Session B's phase 13/14 work
3. `cmake/CommonBuildParameters.cmake` + `cmake/DownloadDependencies.cmake` — **the user's
   local-only build patches**, deliberately never committed
4. Six `skip-worktree` files carrying the user's Apple signing (`git ls-files -v | grep '^S'`)

The user has said commits happen only when they say so, per `./CLAUDE.md` ("Do not create commits").

---

## Files session A owns — do not edit, revert, or stage these

**Modified**
- `lib/dashboard/home/widgets/transaction_displays.dart` — 625 → ~400 lines; four row widgets
  collapsed into one `TransactionRow`
- `lib/dashboard/home/widgets/transactions_slim_view.dart` — `Filters` enum 5 → 10, the filter bar,
  day grouping, both empty states
- `lib/dashboard/home/widgets/transaction_utils.dart` — `txRowContent`, `formatTxAmount`,
  `formatFiat`, `livePricesBySymbol`, day grouping
- `lib/theme/genius_wallet_colors.dart` — **additive only**: `statusNeutral = #64748B`
- `lib/dev/dev_mock_transactions.dart` — 8 → 11 fixtures covering all 7 types and all 4 statuses
- `.planning/ROADMAP.md` — the Phase 12 entry (carries the full design contract)
- `.planning/STATE.md` — Roadmap Evolution entry
- `.planning/sketches/MANIFEST.md` — **shared file, both sessions append to it.** Session A owns the
  rows for sketches 009-014 and 019. Please append rather than rewrite.

**New**
- `lib/dashboard/home/widgets/transaction_badge.dart`
- `assets/images/pickaxe.svg`
- `test/dashboard/` (4 files, 156 tests)
- `.planning/phases/12-transactions-redesign/` (6 plans, 5 summaries)
- `.planning/sketches/009-014`, `.planning/sketches/019-dashboard-separators`

**Uncertain ownership — please check before touching:**
`lib/services/coin_gecko/coin_gecko_api.dart`, `lib/wallets/cubit/wallet_details_cubit.dart`,
`packages/genius_api/lib/src/genius_api.dart` appeared modified during the session and may belong to
session B.

---

## Sketch numbering — resolved

Session A originally created `016-dashboard-separators`, colliding with session B's
`016-compute-panel-anatomy`. **Session A renumbered to 019**; B's 016-018 series is intact and
untouched. Code comments in `transactions_slim_view.dart` and `transaction_filters_test.dart` now
say "sketch 019 variant B".

---

## Test baseline

`flutter test` → **187 passing, 1 failing.**

The one failure is `test/local_wallet_storage_test.dart` → *"Missing definition of `main` method"*.
It is **pre-existing**: the file is entirely commented out. It fails at load, so the `-1` is carried
through the whole run without any individual test reporting a failure. **Do not "fix" it as a side
effect and do not report it as a regression.** Restoring it is a known outstanding task (it is the
only PIN/secure-storage coverage in the repo).

---

## The freeze precedent — binding for anyone touching dashboard layout

Commit `37639d5` (already on the branch) fixed a **permanent app freeze**: `crypto_live_chart.dart`
derived its price font size as `maxHeight * 0.45`, so a drag-resize produced a distinct `TextStyle`
every frame. That thrashed skia's fixed-size `ParagraphCache` — 1953/2092 stack samples inside
`SkLRUCache::remove` — so layout never settled, the frame was never committed, and the macOS
embedder blocked forever in `ResizeSynchronizer.beginResize` (100% of one core, isolate past any
safepoint, window dead until killed).

**Rule: any value that varies with layout must come from a bounded set.** `AutoSizeText`,
`FittedBox(scaleDown)` and `MediaQuery.textScalerOf(...).scale(...)` feeding a `fontSize` are all
instances of the bad pattern; they were removed from the transactions area for this reason. Its
regression guard is `test/chart/compact_price_font_size_test.dart` (624 distinct sizes without the
fix, ≤29 with).

---

## What is DONE in Phase 12

Design contract decided interactively with the user and recorded in `ROADMAP.md` → Phase 12, with
the reasoning in `.planning/sketches/010-014/README.md`.

- **Row:** token-first; one anatomy for all seven `TransactionType` values. Time leads the row
  (left of the token icon). Amounts clamped (2 dp ≥1000, else 6) with the exact value on hover.
  Fiat on every row, sourced from the already-cached Hive `marketDataBox` — an unpriced coin gets
  **no** fiat line, never a fabricated `$0.00`. `Fee:` removed from the resting row.
- **Badges** (18px filled circle, knocked-out glyph, colour computed for AA in both appearances):
  Sent slate `#64748B`, Received `statusSuccess`, **Mint `brandTertiary #C28FFF` + pickaxe**,
  **Computing `brandPrimaryStrong #0AAEE6` + server**, Escrow slate, Pending `statusWarning`,
  Failed `statusError`.
- **Filters:** title row **Sent · Received · Mint · Computing**; `⋯` overflow holds Escrow, Swapped,
  Purchased, Pending, Failed with live counts. Active = `brandCta` gradient, never flat blue; the
  `⋯` trigger takes the gradient when the active filter is inside it; active menu item is gradient
  text **on the label only** (the glyph never changes with selection); chips are **icon-only in
  every state** (no expand-to-label — the tooltip names them).
- **Filter correctness fix:** `sent`/`received` used to match on direction alone, so purchases,
  swaps, escrows and jobs all leaked into "Sent" (7 of 11 fixtures instead of 3). They now match
  **plain transfers only**, so every transaction belongs to exactly one type filter. Guarded by a
  test that walks every fixture and requires exactly one type-filter hit.
- **Separators (sketch 019, variant B):** the header rule was REMOVED — this panel goes straight
  from `GWSectionTitle` to its list, like Assets and Markets. Row dividers stay. Spacing measured,
  not eyeballed: title → first day label 24px (matching Assets/Markets), above later day labels
  32px (double the 16px between rows inside a day).
- **Consistency with the chart:** the filter bar now uses `_TimeframeSegment`'s exact geometry —
  3px track padding, hairline border, `radiusPill`, 2px between chips, 120ms, and the
  design-system "lift chip" hover (sketch 008 D). Bar is 40px tall, the height the navbar
  normalizes every interactive control to.

---

## What is NOT done

1. **`12-06` — the human-verify walk. Never attempted.** Three blocking checkpoints: dark rows and
   badges, filters and empty states, and recording the light-mode deferral. The app has been run
   and hot-restarted many times and the user eyeballed dark mode informally, but the structured
   walk has not happened.
   **Walk it in DARK ONLY.** The user confirmed on 2026-07-22 that light mode is backlog and must
   not gate a phase — see `.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md`,
   which collects every known light-mode item (including #2 below) for one dedicated pass later.
   A light-mode finding is a note in that file, never a blocker.
2. **A design call the executor deliberately did not make:** the active filter chip's gradient FILL
   measures **1.65:1 / 2.28:1 against the light bar surface** (WCAG 1.4.11 wants 3:1 for UI
   components). It was left alone because "active = brandCta gradient" is a locked user decision and
   the ink glyph carries the state at 10.66:1. **This is the user's call, not an executor's.**
3. **Last separator inconsistency:** Markets draws its row line with `Container(height: 1)`
   (`dashboard_markets.dart:73`) while Assets and Transactions use `Divider`. Same pixel, two
   widgets. One-line change, not made.
4. **Pre-existing, unrelated:** `responsive_overlay.dart:199` overflows by 82px on the right. Present
   before Phase 12; last touched in `0bcf3df`. Not investigated.
5. Sketch 014's mockup strings `Job #4192` and `Banxa · card` are **fiction** — the model has no job
   id, no purchase provider and no failure reason. The implementation derives from real fields
   (truncated hash, status name). A walker should not report those as wrong data.

---

## Running the app (macOS)

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```
Kill any running instance first — a stale one holds the Hive container lock at
`~/Library/Containers/ai.gnus.GeniusWallet.jakub/` and the next launch is a silent black window.
Never launch it as a backgrounded harness task; it dies when the shell is reaped.
**Transactions render empty until the mock injector is used** — the bug icon in the dev panel,
"Mock txns" (11 fixtures covering all 7 types and all 4 statuses).
