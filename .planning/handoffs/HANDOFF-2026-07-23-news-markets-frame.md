# HANDOFF — 2026-07-23 · News + Markets integration, page-frame unification

**Session role:** EXECUTOR. **Branch:** `redesign/transactions-tab-260722`.
**Window:** ~2026-07-23 morning → 13:40. Work committed at session close on Jakub's
explicit go (four code commits + this docs commit).

## What shipped this session (committed)

Four logical commits on `redesign/transactions-tab-260722`, `cmake/*` deliberately
left out, macOS signing files untouched, no `git add -A`:

| commit | scope |
|--------|-------|
| `651541c` | **feat(news): Phase 17** — B2 hero+Next up magazine, search→Results, freeze fix |
| `aa78eec` | **feat(markets): Phase 16** — native-token hero over a sortable All Markets table |
| `99a8913` | **feat(ui): unify content page frame** — Transactions/Markets/News titles at same X |
| `5ab34bd` | **feat(transactions): wide-row Status column** + flush-right amounts + amount honesty |

### News (Phase 17) — `651541c`
- Integrated from its worktree into the main tree (no rebuild). B2 photo-magazine:
  lead hero + "Next up" band + even photo grid; hover = shared `GWCard` lift.
- **Search reworked on Jakub's call:** searching no longer reshapes the hero band.
  Hero + "Next up" stay frozen on the latest stories; matches populate the bottom
  section, retitled **"More news" → "Results"**. A no-match shows an inline notice
  under Results instead of blanking the page.
- **Freeze fixed (root cause found by log analysis):** a 1-result search returned a
  bare wide hero `Row(stretch)` into the page's vertical scroll → "BoxConstraints
  forces an infinite height" → 1600+ cascading `LayoutBuilder slot==null` → frozen
  UI thread. Hero is now self-bounding (`IntrinsicHeight`) and a bare wide hero is
  never returned; the Results-in-grid design removes the trigger entirely.
- Timestamps → green relative "2h ago" (`statusSuccess`, AA both themes), clock icon
  dropped; search got the brand gradient focus ring, a 220ms debounce (fixes dropped
  keystrokes + half-typed queries matching nothing), a working ×, no scrollbar;
  header carries an always-visible "Updated Xm ago" stamp + refresh on its own 30s
  ticker (only the stamp re-renders, never the magazine).
- Dropped `flutter_staggered_grid_view` from pubspec.

### Markets (Phase 16) — `aa78eec`
- Integrated from its worktree. Native-token hero over a sortable "All Markets"
  table; same two chained fetches (coins → market data), each with error/retry.
- **Two blank-page bugs fixed:** non-data states returned a bare `Center` into an
  unbounded `Column` slot (no size → blank) — now `Expanded(FutureStateWidget(...))`
  at column level; and the hero `Row` needed `IntrinsicHeight` (fl_chart collapses
  with no bounded height).

### Page-frame unification — `99a8913`
- Titles across **Transactions / Markets / News** now land at the same X: **centered**
  content (`Alignment.topCenter`), symmetric L/R margins, shared **xxl (1536)** cap,
  64px navbar→title gap. An earlier left-aligned pass stripped the left padding on a
  wide window (title flush to the bezel) — Jakub flagged it, corrected to centered.
- Feedback (`submit_logs_screen`) and Swap (`swap_screen`) carry the shared header +
  gap. **Feedback is otherwise left alone — Jakub is redesigning it separately**, and
  explicitly said not to force its title to match (narrow 768 form vs the 1536 tabs).

### Transactions status/amount — `5ab34bd`
- Wide rows: right-aligned Status pill, right edges of pill+amount on one line
  (gap = the time↔coin gap), amount column fixed-width to the largest amount.
- Amounts flush-right (`Expanded`, was `Flexible`). Amount honesty on
  fee/failed/cancelled rows.

## Verification status
- `flutter analyze lib/ test/` clean of **errors**; info/warnings held at the prior
  baseline (removed the +2 warnings my test edits introduced).
- Added `test/news_article_short_time_test.dart` (shortTimeAgo boundaries) and
  `test/markets_sort_test.dart`; `test/components/gw_card_hover_test.dart` present.
- **Full `flutter test` suite NOT re-run this session** — no fresh baseline number to
  quote. Next executor should run it (`--concurrency=1`) and record the count.
- Visually tested live in a `GW_DEV_TOOLS=true` macOS run: News search (incl. the
  1-result "south" case that used to freeze), Results section, title alignment.

## Ops gotcha (cost real confusion — don't rediscover)
- The **dev-tools bubble** (loads mock transactions/holdings) is gated behind
  `--dart-define=GW_DEV_TOOLS=true` (`lib/dev/dev_flags.dart:15`,
  `bool.fromEnvironment('GW_DEV_TOOLS')`). A relaunch **without** the define compiles
  the control out — it looks "removed" but zero code changed. **Every `flutter run`
  this session must carry `--dart-define=GW_DEV_TOOLS=true`.**
- Two app instances fought the Hive lock (`historicalpricesbox.lock`,
  `~/Library/Containers/ai.gnus.GeniusWallet.jakub/`) after an incomplete kill — one
  executor, one `flutter run` only; verify no stray instance before relaunch.

## Parallel DESIGN sessions today (sketches + handoffs only — NOT wired into the app)
- Drawers redesign — sketches 030–034 + `drawers-final` (`HANDOFF-drawers-redesign.md`).
- Feedback tab — sketch 150 (`HANDOFF-feedback-tab.md`).
- Coin detail page — sketch 104 (`HANDOFF-coin-detail-page.md`).
- Markets exploration — sketch 103 (`HANDOFF-markets-hero.md` / `-2026-07-23-markets-session.md`).

## Next up
1. Run the full `flutter test` suite and record a real baseline.
2. Human walk of News + Markets in both modes (light AA still deferred — dark-first).
3. Sketch 007 transaction-filter variant still unpicked (rec **C · icon-only compact**).
4. `cmake/*` stays uncommitted (Jakub's local build patches) — leave it that way.
