---
phase: 12-transactions-redesign
verified: 2026-07-24T08:05:14Z
status: passed
score: 11/11 must-haves verified
behavior_unverified: 0
overrides_applied: 0
verdict: PASS
warnings:
  - id: W1
    concern: "ROADMAP design contract says 'Desktop keeps the animated expand-to-label; narrow/mobile is icon-only'. The dashboard filter bar (_FilterChip) is icon-only at ALL widths; the `compact` bool is threaded into _TransactionFilterBar but never read in its build(). Label display is instead delivered by the page rail (_FilterRail). The 12-06-SUMMARY B11 claim 'expand animation returns on widen' is NOT code-accurate for the panel bar."
    severity: warning
    reason: "Documented design evolution (sketch 023 / in-code comments). The phase GOAL (single anatomy, full filter coverage, two empty states) is unaffected. Non-blocking."
    evidence: "lib/dashboard/home/widgets/transactions_slim_view.dart:603 (dead `compact` field), :774-855 (_FilterChip: 'Icon-only in every state at every width')."
  - id: W2
    concern: "12-02 must-have wording 'A failed transaction shows an em dash and Not charged' is superseded. The current failed/cancelled row prints the REAL attempted amount (e.g. `− 0.75 ETH`) plus a 'Not charged' value line — not an em dash in the amount column."
    severity: info
    reason: "Superseded by phase 15-01 (TT-06: 'no row prints a dash where the number belongs', per sketch 022 — Jakub overruled sketch 021's unsigned amount). The honesty invariant the criterion protects (never a currency zero, stated once) still holds."
    evidence: "lib/dashboard/home/widgets/transaction_utils.dart:173-179, :432-457."
human_verification:
  - test: "Dark-mode walk of the transactions panel + page (badges, rows, filters, both empty states, narrow/wide)."
    expected: "All 11 criteria observed on a real screen in dark at both widths."
    why_human: "Visual legibility, in-situ badge contrast, and 'the two empty states read as different situations' cannot be verified statically."
    status: APPROVED 2026-07-24 (see .planning/STATE.md; 12-06-SUMMARY per-criterion table, all PASS dark)
deferred:
  - truth: "Light-mode legibility (badge glyphs, row text, filter bar, empty states) and live dark->light->dark re-skin."
    addressed_in: "Dedicated app-wide light pass"
    evidence: ".planning/todos/pending/2026-07-22-light-mode-verification-backlog.md; standing dark-first policy; 12-06-SUMMARY 'Light mode — DEFERRED' section. RECORDED, not silently skipped."
---

# Phase 12: Transactions redesign Verification Report

**Phase Goal:** The transactions surface reads as one system: every one of the seven `TransactionType` values renders through a single row anatomy, every type and status is reachable by a filter, and a wallet with no matching rows says which of the two "empty" situations it is in.

**Verified:** 2026-07-24T08:05:14Z
**Status:** passed (PASS)
**Re-verification:** No — initial verification
**Method:** Goal-backward, static inspection + `flutter analyze` on the 5 phase files (no `flutter run`, no full test suite — per the parallel-session Hive-lock rule).

## Goal Achievement

The goal decomposes into three load-bearing pillars. All three are true in the code, not just in the SUMMARY.

### Pillar 1 — One row anatomy for all seven types

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | All 7 `TransactionType` values render through ONE widget; the list no longer switches on type | ✓ VERIFIED | `TransactionRow` is the sole constructor in the list builder (`transactions_slim_view.dart:509`); `TransactionRow` has "deliberately no `switch (tx.type)`" and renders `txRowContent`'s record (`transaction_displays.dart:191-387`). The old four-branch itemBuilder switch and `_show*TransactionDetails` trio are deleted (`transaction_displays.dart:428-524` — one `showTransactionDetails` for all types). |
| 2 | A processing job and a swap now carry icon+title+meta+amount like every other row | ✓ VERIFIED | `txRowContent` produces a full record for `process` (fee as amount) and `swap` (`transaction_utils.dart:388-430`); both flow through the same `TransactionRow`. |
| 3 | A swap shows both tokens in one identity slot | ✓ VERIFIED | `_identity` overlaps two coin images when `iconSymbols.length > 1` (`transaction_displays.dart:130-189`); swap populates two symbols (`transaction_utils.dart:460-465`). |
| 4 | Resting row carries no `Fee:`; the fee lives in the drawer | ✓ VERIFIED | No `Fee:` in `TransactionRow`; drawer adds `Network Fee` once (`transaction_displays.dart:474`). `process` is the one type whose fee is its amount column (by design). |
| 5 | Rows sit on one surface separated by hairline dividers, not bordered cards | ✓ VERIFIED | `_body` interleaves `Divider(height:1, thickness:1, color: gw.borderSubtle)` between rows, full-bleed, no per-row card (`transactions_slim_view.dart:516-519`). Geometry matches `GWTokenRow` (40px slot, space6/space4) so Assets + Transactions read as one system. |

### Pillar 2 — Every type and status reachable by a filter (closes the coverage bug)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 6 | Every one of the 7 `TransactionType` values is reachable by at least one filter (swap/purchase/process no longer All-only) | ✓ VERIFIED | `Filters` enum extended to 10 values; `matches()` is an exhaustive switch expression mapping `swap`, `purchase`, `process`→jobs, `mint`, transfer→sent/received (`transactions_slim_view.dart:73-102`). Coverage pinned by `transaction_filters_test.dart:57-84`. |
| 7 | Escrow still matches BOTH `escrow` and `escrowRelease` | ✓ VERIFIED | `escrow => {escrow, escrowRelease}.contains(tx.type)` (`:88-91`); test `:87`. |
| 8 | Title row order is Sent · Received · Mint · Jobs; everything else behind `⋯` with a live count | ✓ VERIFIED | `Filters.primary = [sent, received, mint, jobs]` (`:105`); overflow types/statuses (`:108-111`); menu renders counts (`:760`). Order locked by test `:145`. |
| 9 | Active filter is the `brandCta` gradient, never flat blue | ✓ VERIFIED | `_FilterChip` decoration `gradient: active ? GeniusWalletGradient.brandCta : null` (`:836`). |
| 10 | When the active filter lives in the overflow menu, the `⋯` trigger itself carries the gradient | ✓ VERIFIED | `_overflowTrigger`: `filtered = Filters.isInOverflow(selected)`; `gradient: filtered ? brandCta : null` (`:656-695`). |
| 11 | Inside the menu only the LABEL takes the gradient; the glyph is unchanged whether active or not | ✓ VERIFIED | `_menuItem`: glyph is `badgeGlyph(..., color: gw.textSecondary)` always; `ShaderMask(srcIn, _activeLabelShader)` wraps the label only when active (`:718-771`). |

### Pillar 3 — Two distinct empty situations

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 12 | A never-transacted wallet and a filter that matched nothing say visibly different things | ✓ VERIFIED | `_body` branches: `scoped.isEmpty` → `Icons.sync_alt` + `emptyTransactionsTitle`/`Message` (dead end); `txs.isEmpty` → `Icons.filter_alt_outlined` + filter-named title (`transactions_slim_view.dart:433-459`). Distinctness pinned by test `:274`. |
| 13 | Filtered-empty names the filter, states how many transactions DO exist, and offers "Show all" (not Buy GNUS) | ✓ VERIFIED | `filteredEmptyTitle(f)` names the filter; `filteredEmptyMessage(scoped.length)` states the count; `actionLabel: 'Show all'` → resets to `Filters.all` (`:147-154`, `:451-458`). "does not tell the user to buy anything" pinned by test `:285`. |

### Supporting truths (design-contract fixes carried by the row rewrite)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 14 | Amount clamped (2 dp ≥1000, else up to 6) with exact value preserved on hover; tabular figures | ✓ VERIFIED | `formatTxAmount` (`transaction_utils.dart:80-90`), `exactTxAmount` → `Tooltip` only when clamp lost precision (`transaction_displays.dart:235-236`). |
| 15 | Fiat value line on every priced row; never a fabricated `$0.00` | ✓ VERIFIED | `_fiatLine` returns null (line dropped) when unpriced/unparseable (`transaction_utils.dart:485-494`); reads the already-populated Hive `marketDataBox`, no new network call (`:133-153`). |
| 16 | Status shown only when not the happy path; failed shows "Not charged", never a currency zero twice | ✓ VERIFIED | Subtitle appends `· Status` only when `status != completed` (`transaction_utils.dart:366-368`); dead-status override sets `valueLine='Not charged'`, tone none (`:454-457`). See W2 — real attempted amount, not an em dash (15-01). |
| 17 | Day separators (Today / Yesterday / real date) replace repeated relative time; real per-row timestamp | ✓ VERIFIED | `groupTransactionsByDay` + `txDayLabel` (calendar-day, DST-safe) (`transaction_utils.dart:506-573`); day headers emitted once per group (`transactions_slim_view.dart:466-503`); per-row 24h `txTimeLabel`. |
| 18 | 9-kind badge: 18px filled circle, knocked-out glyph, surface-coloured ring (never white), locked fills, pickaxe=Mint / server=Job | ✓ VERIFIED | `TransactionBadge` 18px circle, ring = `gw.surfaceElevated` not white (`transaction_badge.dart:160-187`); fills `Slate #64748B` / `brandTertiary #C28FFF` / `brandPrimaryStrong #0AAEE6` etc. match tokens (`genius_wallet_colors.dart:49,80,194`); pickaxe SVG on mint, `Icons.dns` on job. `badgeGlyphColor` computes white-or-ink for AA in both appearances. |
| 19 | Panel derives no font size / scale / fractional width from constraints (37639d5 freeze rule) | ✓ VERIFIED | Only layout-derived values are booleans (`compact`, `wide`, `hug`); all sizes are literals/4-pt tokens; no `AutoSizeText`/`FittedBox` (documented at `transactions_slim_view.dart:1-6`, `:274`, `:366`). |

**Score:** 11/11 phase criteria (TX-01..TX-11) verified in code; 19/19 decomposed truths VERIFIED. 0 behavior-unverified.

## Required Artifacts

| Artifact | Status | Details |
|----------|--------|---------|
| `lib/dashboard/home/widgets/transaction_badge.dart` (187 ln) | ✓ VERIFIED | 9-kind `badgeSpec` table + `badgeGlyphColor` + `TransactionBadge`. |
| `assets/images/pickaxe.svg` | ✓ VERIFIED | Valid single-path pickaxe, black stroke (recolored via `srcIn`). |
| `lib/dashboard/home/widgets/transaction_utils.dart` (573 ln) | ✓ VERIFIED | `formatTxAmount`, `exactTxAmount`, `txRowContent` (all 7 types), `groupTransactionsByDay`, `livePricesBySymbol`. |
| `lib/dashboard/home/widgets/transaction_displays.dart` (524 ln) | ✓ VERIFIED | Single `TransactionRow` + single `showTransactionDetails` drawer. |
| `lib/dashboard/home/widgets/transactions_slim_view.dart` (1118 ln) | ✓ VERIFIED | `Filters` (10, exhaustive), `_TransactionFilterBar`, `_FilterRail`, two empty states, day assembly. |
| `lib/dev/dev_mock_transactions.dart` (229 ln) | ✓ VERIFIED | 11-tx batch: all 7 types, all 4 statuses, both directions, swap, job, clamp stress, 3 calendar days. |
| `test/dashboard/transaction_badge_test.dart` (82 ln) | ✓ VERIFIED | Per-appearance AA loop over all kinds; locked fills; pickaxe/dns glyphs pinned. |
| `test/dashboard/transaction_utils_test.dart` (634 ln) | ✓ VERIFIED | Present, substantive (not executed — full-suite ban). |
| `test/dashboard/transaction_filters_test.dart` (622 ln) | ✓ VERIFIED | Coverage bug closure, escrow/failed spans, order lock, empty-state distinctness. |

## Key Link Verification

| From | To | Via | Status |
|------|----|----|--------|
| `TransactionRow` | `txRowContent()` | Widget renders record, no switch survives | ✓ WIRED (`transaction_displays.dart:211`) |
| `transactions_slim_view` itemBuilder | `TransactionRow` | Four-branch switch deleted | ✓ WIRED (`:509`) |
| `Filters.matches()` | all 7 `TransactionType` | Exhaustive switch expression | ✓ WIRED (`:73-102`) |
| `Filters` / row badge | `badgeSpec/badgeGlyph` | Chip + row draw the same mark | ✓ WIRED (`:745`, `:844`) |
| Overflow-menu active | `_activeLabelShader` → `brandCta` | `ShaderMask(srcIn)`, label-only | ✓ WIRED (`:753-757`) |
| scoped list (SGNUS-applied, filter-unapplied) | menu counts + filtered-empty "you have N" | Single `scopedTransactions` source | ✓ WIRED (`:186-190`, `:312`, `:394`) |
| dev-tools MOCK | `DevMockTransactions.batch` | Offline walk of all 7 types | ✓ WIRED |
| `TransactionsSlimView` | 3 real call sites | `transactions_stream`, `transactions_screen`, `sgnus_transactions_screen` | ✓ WIRED |

## Behavioral Spot-Checks

| Check | Command | Result | Status |
|-------|---------|--------|--------|
| Phase files compile clean | `flutter analyze` (5 files) | "No issues found! (ran in 2.7s)" | ✓ PASS |
| Full test suite | — | Not run (parallel-session Hive-lock + shared-baseline rule) | ? SKIP → covered by approved human walk |

## Requirements Coverage (TX-01..TX-11)

| Req | Description | Status | Evidence |
|-----|-------------|--------|----------|
| TX-01 | One row anatomy for all 7 types | ✓ SATISFIED | Pillar 1, truths 1-5 |
| TX-02 | Badge system, legible glyph, surface ring | ✓ SATISFIED | Truth 18 |
| TX-03 | Enum coverage — all 7 types reachable | ✓ SATISFIED | Truth 6, test `:57-72` |
| TX-04 | F1 two-tier filter, gradient-only active | ✓ SATISFIED (see W1) | Truths 8-11; expand-to-label deviation is non-goal |
| TX-05 | Clamped amount + exact-value hover | ✓ SATISFIED | Truth 14 |
| TX-06 | Fiat / value line, honest failed row | ✓ SATISFIED (see W2) | Truths 15-16 |
| TX-07 | `Fee:` off the resting row | ✓ SATISFIED | Truth 4 |
| TX-08 | Day grouping + per-row timestamp | ✓ SATISFIED | Truth 17 |
| TX-09 | Status only when not the happy path | ✓ SATISFIED | Truth 16, escrow/failed spans test `:87-101` |
| TX-10 | One surface, hairline dividers | ✓ SATISFIED | Truth 5 |
| TX-11 | Two visibly different empty states | ✓ SATISFIED | Truths 12-13 |

## Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `transactions_slim_view.dart` | 597-603 | `compact` param passed but never read in `_TransactionFilterBar.build()` | ℹ️ Info | Dead parameter; residue of the dropped expand-to-label (W1). `flutter analyze` does not flag it (constructor arg used at call site). No functional impact. |

No `TODO`/`FIXME`/`XXX`/`PLACEHOLDER` debt markers in the phase files. All `ponytail:` comments name a real ceiling + upgrade path (per CLAUDE.md). No stubs, no empty renders, no hardcoded empty data reaching the UI.

## Human Verification

**APPROVED — dark-mode walk, 2026-07-24** (`.planning/STATE.md`; `12-06-SUMMARY.md` per-criterion table records all of TX-01..TX-11 as observed PASS in dark at both panel widths). The walk's "can't type" wedge was a stale second app instance holding the Hive lock, not a Phase 12 defect. No walk-driven fixes were required.

## Deferred (recorded, not skipped)

**Light mode** is deferred to a dedicated app-wide pass, consistent with the standing dark-first policy and how phases 06-02..06-05 closed. Carried forward as explicit UNVERIFIED items: badge glyph legibility in light, row text contrast, filter bar in light, both empty states in light, and the live dark→light→dark re-skin (flagged as a real blocker to check first in that pass, not a light-only cosmetic). Does not affect this phase's status.

## Gaps Summary

None blocking. The phase goal is achieved in code: a single `TransactionRow` renders all seven `TransactionType` values, `Filters.matches()` makes every type and status reachable (closing the documented `{all,sent,received,escrow,mint}` coverage bug), and the panel distinguishes the never-transacted empty state from the filter-matched-nothing one. Two non-blocking notes: (W1) the ROADMAP's "desktop animated expand-to-label" filter detail was superseded by an icon-only panel + label-bearing page rail, leaving a dead `compact` param and making the 12-06 SUMMARY's "expand animation returns on widen" claim inaccurate; (W2) the failed-row now prints the real attempted amount + "Not charged" rather than the em dash the 12-02 wording described (15-01 decision). Neither touches the goal.

---

_Verified: 2026-07-24T08:05:14Z_
_Verifier: Claude (gsd-verifier)_
