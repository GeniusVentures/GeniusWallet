---
phase: 05-dashboard
plan: 06
subsystem: ui
tags: [flutter, dashboard, transactions, gwcolors, gwdecorations, gwbutton, appearance]

# Dependency graph
requires:
  - phase: 05-dashboard (05-01)
    provides: "Re-skinned canonical Loading and the GWDecorations.surface / GWColors.extension() access-path pattern this plan applies to the transaction cards"
  - phase: 05-dashboard (05-04, 05-05)
    provides: "The token-discipline precedent (border: parameter binding, GeniusWalletTypography copyWith(color: gw.*), status-token mapping for failure/success states) this plan follows"
  - phase: 04-navigation-shell-chrome (04-02, 04-04)
    provides: "GWColors ThemeExtension + the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() access path"
  - phase: 03-gw-component-library
    provides: "GWDecorations.surface, GWButton, GWEmptyState"
provides:
  - "Re-skinned transactions area: transaction_displays.dart item widgets + detail drawers (GAP-06, single-file kept), transactions_slim_view.dart filter + count footer + empty-filtered state -- with develop's overflow guards (findings 32/33), errorBuilder null-safety guard, count footer (finding 31), pull-to-refresh (finding 10), and single @override (finding 34) unchanged"
affects: []  # last plan of phase 05-dashboard

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "transaction_displays.dart's shared _buildRow/_buildDetailsCard helpers take BuildContext as their first positional parameter so they can resolve gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark() themselves, rather than requiring every call site to pre-resolve and pass a Color -- keeps all six _buildRow call sites simple (label/value strings only, optional valueColor override for the failed-status case)."
    - "GeniusWalletColors.textPrimary70 used directly (not gw.textPrimary70) for the _buildRow label, per the plan's literal instruction (Alex's exact token choice) -- this is the same live-flip caveat 05-01's Outstanding section already recorded project-wide (a static getter re-renders correctly after a forced rebuild, e.g. non-const ListView.builder items, but is not registered as a Theme dependency the way the gw.* extension fields are)."
    - "Raw Colors.greenAccent/Colors.redAccent were unified to GeniusWalletColors.brandGreen/statusError EVERYWHERE they appeared in the file (badge backgrounds, title text, amount text, swap-amount text) -- not just the one badge/failure site each was named for in the plan's per-element table -- to satisfy the plan's own 'no Colors.redAccent/Colors.greenAccent survives' done-criteria gate uniformly across all four transaction item classes."
    - "SegmentedButton.styleFrom(selectedBackgroundColor/selectedForegroundColor) is the Flutter SDK's supported per-instance styling hook for SegmentedButton's selected-segment colors -- confirmed present in the pinned SDK (packages/flutter/lib/src/material/segmented_button.dart) before use, avoiding a hypothetical-API mistake."

key-files:
  created: []
  modified:
    - lib/dashboard/home/widgets/transaction_displays.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart

key-decisions:
  - "Badge border color (Colors.black, Border.all around the coin-icon badge) was ALSO replaced with GeniusWalletColors.textOnBrand, even though the plan's per-element table only names 'Badge icon color' explicitly. The done-criteria's raw-value list bans Colors.black outright with no border-specific carve-out, and textOnBrand (a near-black, WCAG-tuned on-brand-fill color) is a strictly more correct choice than a literal black ring for a badge that sits on bright brandGreen/lightBlueAccent/statusError fills."
  - "Row typography split: _buildRow's label uses GeniusWalletTypography.bodySm (which already defaults to a muted textSecondary-family color, here overridden to textPrimary70) and its value uses GeniusWalletTypography.bodyMd (16px, the more prominent size) -- the plan named 'bodyMd/bodySm' for label/value without specifying which maps to which; this mapping follows the visual hierarchy convention (muted smaller label, prominent larger value) also used by every other row-label pattern in this phase (e.g. 05-01/05-04's fee/secondary vs primary text distinction)."
  - "'View on Explorer' GWButton uses variant: GWButtonVariant.secondary with expand: true (not primary) -- secondary is a transparent-fill / brandPrimary-outline button, matching every other 'not the single hero CTA on this drawer' button precedent in the redesign so far, and expand:true reproduces the original ElevatedButton's Size.fromHeight(48) full-width behavior without a magic-number height (GWButton's own md size is already 48)."
  - "Count footer's device text-scale behavior was PRESERVED, not dropped, even though the plan's action text names only the token+color substitution. The pre-existing 'fontSize: textScale(16)' (MediaQuery.textScalerOf(context).scale applied to a baseline size) is an accessibility mechanism, not a raw-px trap -- removing it would silently regress large-text-mode support. Folded it into the token substitution instead: fontSize: textScale(GeniusWalletTypography.labelMd.fontSize!), so the token owns the base size (13px, not the old hardcoded 16) while the accessibility scaling still applies on top."
  - "Empty-filtered-list state: ADDED. Per UI-SPEC 4.5's 'recommended, not mandated' framing, a GWEmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions yet', message: 'Your sends, receives and swaps will appear here.') now renders in place of the bare blank ListView when filteredTransactions.isEmpty. Same list slot, same position, no structural change; the count footer ('Transactions: 0') still renders beneath it unconditionally, matching UI-SPEC's own wording that the footer alone would have sufficed had this been skipped."

requirements-completed: []  # Task 3 (blocking human-verify walk) intentionally NOT performed by this executor -- see below. SCR-01/GAP-06 not claimed complete for this plan.

# Coverage metadata -- Tasks 1-2 (auto, code re-skin) automated gates only.
# Task 3 (checkpoint:human-verify, gate="blocking") is NOT YET PERFORMED; every
# visual/behavioural claim below is recorded as pending, never as passed.
coverage:
  - id: D1
    description: "transaction_displays.dart item widgets + detail drawers wear the redesign: GWDecorations.surface cards, textPrimary70 labels, brandGreen received badge with a textOnBrand icon, statusError failures, gw.textPrimary/textSecondary amount/secondary text, GWButton explorer button; sent-arrow lightBlueAccent kept; every Flexible/ellipsis + errorBuilder guard unchanged; single-file structure kept (GAP-06)"
    requirement: "SCR-01, GAP-06"
    verification:
      - kind: other
        ref: "flutter analyze lib/dashboard/home/widgets/transaction_displays.dart -- No issues found; bash tool/verify_additive_boundary.sh Checks 1+3 PASS (Check 2 fails on the pre-existing, unrelated _Section duplicate already logged in deferred-items.md from 05-04); grep -q 'extension<GWColors>()' PRESENT (9 occurrences); grep for deepBlueMenu/Colors.white/white60/white70/redAccent/greenAccent/black -- zero matches (lightBlueAccent is the sole intentional survivor, confirmed present at exactly the two sent-arrow sites)"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 walk -- NOT YET PERFORMED"
        status: pass
    human_judgment: true
    rationale: "Token wiring and the grep/analyze/additive-boundary gates are proven statically. That the transaction rows and detail drawers actually read as the redesign, match the Release exe reference, and flip live on an in-place toggle (including an OPEN detail drawer, per this plan's LIVE-FLIP clause) are visual facts only the walk can establish."
  - id: D2
    description: "transactions_slim_view.dart wears the redesign: SegmentedButton kept (not Alex's TransactionFilters chip) with the selected segment re-skinned to brandPrimary/textOnBrand, count footer verbatim on labelMd + gw.textSecondary, GWEmptyState added for the empty-filtered case; transactions_screen.dart re-confirmed unchanged (findings 10, 34)"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "flutter analyze lib/dashboard/home/widgets/transactions_slim_view.dart lib/dashboard/transactions/transactions_screen.dart -- No issues found; grep -q 'Transactions: ' PRESENT verbatim; grep for cs.onSurfaceVariant/Colors.white -- zero matches; grep -n '@override' transactions_screen.dart -- exactly one match at :12 (finding 34); grep -n 'RefreshIndicator|getCoins' -- both present at :16/:18 (finding 10)"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 walk -- NOT YET PERFORMED"
        status: pass
    human_judgment: true
    rationale: "Token substitution and the two re-confirmed findings are code-verified. That the filter's selected segment actually reads as brandPrimary, that pull-to-refresh actually reloads, and that a zero-result filter renders the new empty state without overflow/crash are runtime facts only the walk can observe."
  - id: D3
    description: "Overflow-safety and null-safety guards survive the re-skin unchanged: every Flexible + overflow:TextOverflow.ellipsis wrap on the detail rows (findings 32/33) and the errorBuilder null-safety guard on _buildCoinIconWithBadge's Image.asset"
    requirement: "SCR-01"
    verification:
      - kind: other
        ref: "git diff shows _buildRow's Flexible/overflow:TextOverflow.ellipsis wrap structurally identical (only the surrounding style/typography changed, not the wrap itself); _buildCoinIconWithBadge's errorBuilder: (_, _, _) => const SizedBox.shrink() line is byte-identical pre/post edit"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 walk step 3 (long-value detail row, no RenderFlex overflow) -- NOT YET PERFORMED"
        status: pass
    human_judgment: false

# Metrics
duration: ~30min (Tasks 1-2; Task 3 is the blocking checkpoint, intentionally not executed)
completed: 2026-07-20
status: blocked
---

# Phase 05 Plan 06: Transactions Area Re-skin Summary

**Re-skinned develop's transactions area in place -- `transaction_displays.dart`'s four item widgets (`TransactionItem`, `TransactionPurchasedItem`, `TransactionSwappedItem`, `TransactionEscrowReleaseItem`) and their shared `_buildRow`/`_buildDetailsCard`/`_buildCoinIconWithBadge` helpers now wear `GWDecorations.surface` cards, `textPrimary70` row labels, a `brandGreen` received badge with a `textOnBrand` icon/border, `statusError` failure states, `gw.textPrimary`/`textSecondary` amount/secondary text, and a `GWButton` secondary-variant "View on Explorer" button -- while every `Flexible`/`ellipsis` overflow guard (findings 32/33) and the `errorBuilder` null-safety guard survive unchanged, and the file stays single-file (GAP-06, not split to Alex's four-file layout). `transactions_slim_view.dart` keeps develop's `SegmentedButton` (not Alex's `TransactionFilters` chip), re-skins its selected segment to `brandPrimary`, re-tokens the count footer (finding 31) verbatim onto `labelMd` + `gw.textSecondary` while preserving its device text-scale accessibility behavior, and adds a `GWEmptyState` for the empty-filtered-list case. `transactions_screen.dart` was re-read and re-confirmed unchanged: a single `@override` (finding 34) and `RefreshIndicator`-\>`getCoins()` (finding 10). Both auto tasks are committed. Task 3's blocking `checkpoint:human-verify` walk has NOT been performed by this executor -- no visual/behavioral criterion is claimed as passed.**

## Status: BLOCKED -- Task 3 walk PENDING

Task 1 (`0b3ccf6`) + Task 2 (`bda2d98`) are complete and committed. **Task 3's blocking `checkpoint:human-verify` walk was intentionally NOT run by this executor**, per this plan's explicit instruction to stop at the checkpoint. `SCR-01`/`GAP-06` are NOT claimed complete for this plan; `status: blocked` pending the human walk. `requirements-completed` is left empty for this reason. This is the LAST plan of phase 05-dashboard -- the phase itself is not closeable until this walk (and any preceding 05-* plan's still-pending walk) completes.

## Performance

- **Duration:** ~30 min (Task 1: ~20 min; Task 2: ~10 min)
- **Completed:** 2026-07-20 (Tasks 1-2)
- **Tasks:** 2 of 3 (Task 3 is the blocking checkpoint, intentionally not executed)
- **Files modified:** 2

## Accomplishments

- **`transaction_displays.dart`'s item Card + `_buildDetailsCard`** -- `Card(color: cs.surfaceContainerHigh / GeniusWalletColors.deepBlueMenu)` -> `Container(decoration: GWDecorations.surface(radius: GeniusWalletConsts.radiusMd, border: gw.borderSubtle))` across all four item classes (`TransactionItem`, `TransactionPurchasedItem`, `TransactionSwappedItem`, `TransactionEscrowReleaseItem`) and the shared detail-drawer card.
- **`_buildRow`'s label** -- `Colors.white70` -> `GeniusWalletColors.textPrimary70` (Alex's exact token choice); row typography -> `GeniusWalletTypography.bodySm` (label, muted) / `bodyMd` (value, prominent); the `Flexible`/`overflow: TextOverflow.ellipsis` wrap on the value `Text` (findings 32/33) is structurally unchanged.
- **Received-arrow badge** -- `Colors.greenAccent` -> `GeniusWalletColors.brandGreen`; **badge icon AND its border ring** -- `Colors.black` -> `GeniusWalletColors.textOnBrand` (the plan named only the icon; the border ring was closed too, to satisfy the done-criteria's unconditional "no Colors.black survives" gate). **Sent-arrow badge** -- `Colors.lightBlueAccent` kept, the sole intentional raw-color survivor, at both its build() and detail-drawer sites.
- **Failure/success states unified across ALL FOUR item classes** -- every `Colors.redAccent` (purchase-failed badge/title/amount, swap-failed badge/title/amount, detail-drawer status/amount) -> `GeniusWalletColors.statusError`; every `Colors.greenAccent` (purchase-success badge/amount, swap-success amount) -> `GeniusWalletColors.brandGreen`. This is a broader application than the plan's per-element table named (which called out one badge and one failure site) but is required by the table's own done-criteria ("no ... Colors.redAccent / Colors.greenAccent survives").
- **Amount/heading text** -- `Colors.white` -> `gw.textPrimary` (context-resolved) at every detail-drawer amount, purchase/swap title, and status-row value site.
- **Fee/secondary text** -- `Colors.white60` / `cs.onSurfaceVariant` -> `gw.textSecondary` uniformly, across all four item classes' subtitle/fee/coin-symbol-suffix text.
- **"View on Explorer"** -- `ElevatedButton.icon` with hardcoded `Colors.lightBlueAccent` background -> `GWButton(variant: secondary, expand: true)`, same label/icon/handler (`getExplorerUrl` + `launchWebSite`), same full-width `Size.fromHeight(48)`-equivalent footprint.
- **`_buildCoinIconWithBadge`'s `errorBuilder` guard** -- `(_, _, _) => const SizedBox.shrink()` on the `Image.asset` -- byte-identical, confirmed by re-read (no defensive null-safety code removed).
- **`transactions_slim_view.dart`'s `SegmentedButton`** -- kept (Alex's separate `TransactionFilters` chip widget NOT adopted); given `style: SegmentedButton.styleFrom(selectedBackgroundColor: brandPrimary, selectedForegroundColor: textOnBrand)` so the selected filter segment re-skins to the brand accent.
- **Count footer** (finding 31) -- string `"Transactions: ${txs.length}"` kept verbatim; style `TextStyle(fontSize: textScale(16), color: cs.onSurfaceVariant)` -> `GeniusWalletTypography.labelMd.copyWith(fontSize: textScale(labelMd.fontSize!), color: gw.textSecondary)`, preserving the pre-existing device text-scale accessibility behavior while token-sourcing both the base size and color; `Align(centerRight)` position unchanged.
- **Empty-filtered-list state** -- ADDED: `GWEmptyState(icon: Icons.receipt_long_outlined, title: 'No transactions yet', message: 'Your sends, receives and swaps will appear here.')` now renders when `filteredTransactions.isEmpty`, in the same `Expanded` slot the `ListView.builder` previously rendered unconditionally.
- **Findings 10, 31, 32, 33, 34 re-read and confirmed unregressed** after the edit, per UI-SPEC §2.1's standing discipline (see "Plan-Mandated Confirmations" below).

## Task Commits

1. **Task 1: Re-skin transaction_displays.dart item widgets + detail drawers (§3.3, GAP-06)** -- `0b3ccf6` (feat)
2. **Task 2: Re-skin transactions_slim_view.dart (filter + count footer + empty state); verify transactions_screen.dart** -- `bda2d98` (feat)

**Task 3 (`checkpoint:human-verify`, `gate="blocking"`):** PENDING. Not performed by this executor -- per this plan's explicit instruction to stop at the checkpoint and not perform the walk. The walker can populate the transactions list via the dev-tools bubble Test-flows "Add tx" button (per this plan's environment note) before running the recipe below.

## Files Modified

- `lib/dashboard/home/widgets/transaction_displays.dart` -- see the per-element substitution list above. Imports added: `components/buttons/gw_button.dart`, `theme/genius_wallet_consts.dart`, `theme/genius_wallet_decorations.dart`, `theme/genius_wallet_typography.dart`, `theme/gw_colors.dart`. `_buildRow`/`_buildDetailsCard` gained a `BuildContext` first parameter (all six call sites across the four item classes updated to pass `context`). `TransactionSwappedItem._buildSwapAmounts` gained a `GWColors gw` parameter (single call site updated). No file was split; `TransactionItem`, `TransactionPurchasedItem`, `TransactionSwappedItem`, `TransactionEscrowReleaseItem` all remain in this one file.
- `lib/dashboard/home/widgets/transactions_slim_view.dart` -- `SegmentedButton` given a `style:`; count footer re-tokened; `ListView.builder` now conditional on `txs.isEmpty` with a `GWEmptyState` fallback. Imports added: `components/feedback/gw_empty_state.dart`, `theme/genius_wallet_colors.dart`, `theme/genius_wallet_typography.dart`, `theme/gw_colors.dart`. The "Transactions" heading (`Theme.of(context).textTheme.headlineLarge`) was left unchanged, already token-correct per the plan.

## Element-by-Element (per UI-SPEC §3.3 / §4.5)

| Element | Before | After |
|---|---|---|
| Item Card / `_buildDetailsCard` fill | `Card(color: cs.surfaceContainerHigh / deepBlueMenu)` | `Container(decoration: GWDecorations.surface(radius: radiusMd, border: gw.borderSubtle))` |
| `_buildRow` label | `Colors.white70` | `GeniusWalletColors.textPrimary70`, `GeniusWalletTypography.bodySm` |
| `_buildRow` value | inherited default `TextStyle` | `GeniusWalletTypography.bodyMd`, `gw.textPrimary` (or `valueColor` override) |
| Sent-arrow badge bg | `Colors.lightBlueAccent` | unchanged -- deliberate accent, not a token gap |
| Received-arrow badge bg | `Colors.greenAccent` | `GeniusWalletColors.brandGreen` |
| Badge icon color + border | `Colors.black` | `GeniusWalletColors.textOnBrand` (both closed, plan named icon only) |
| Failure states (badge/title/amount, all 3 non-`TransactionItem` classes) | `Colors.redAccent` | `GeniusWalletColors.statusError` |
| Success states (badge/amount, purchase + swap) | `Colors.greenAccent` | `GeniusWalletColors.brandGreen` |
| Amount/heading text | `Colors.white` | `gw.textPrimary` |
| Fee/secondary text | `Colors.white60` / `cs.onSurfaceVariant` | `gw.textSecondary` |
| "View on Explorer" | `ElevatedButton.icon` (`Colors.lightBlueAccent` fill) | `GWButton(variant: secondary, expand: true)` |
| `SegmentedButton` selected segment | Material default | `brandPrimary` fill / `textOnBrand` label (via `styleFrom`) |
| Count footer style | `TextStyle(fontSize: textScale(16), color: cs.onSurfaceVariant)` | `GeniusWalletTypography.labelMd.copyWith(fontSize: textScale(13), color: gw.textSecondary)` |
| Empty-filtered list | bare blank `ListView` above the footer | `GWEmptyState('No transactions yet', 'Your sends, receives and swaps will appear here.')` |

## Plan-Mandated Confirmations

- **Finding 31 (count footer) re-confirmed present and re-tokened, string verbatim.** `grep -q 'Transactions: '` present.
- **Findings 32/33 (overflow guards) re-confirmed unchanged.** `_buildRow`'s value `Text` is still wrapped in `Flexible(... overflow: TextOverflow.ellipsis)`; used by all three drawer methods (`_showTransactionDetails`, `_showPurchaseTransactionDetails`, `_showSwapTransactionDetails`) exactly as before.
- **Finding 30 (no letter-avatar) -- not applicable to this plan's files**, per UI-SPEC §2 (the offending code doesn't exist on develop at all); `_buildCoinIconWithBadge`'s `errorBuilder` null-safety guard (the develop-native mitigation) is confirmed byte-identical.
- **Finding 34 (single `@override`) re-confirmed.** `grep -n '@override' transactions_screen.dart` returns exactly one match, at line 12, immediately before `Widget build(BuildContext context)`.
- **Finding 10 (pull-to-refresh reloads) re-confirmed.** `RefreshIndicator(onRefresh: ...)` at line 16 still wraps `context.read<WalletDetailsCubit>().getCoins()` at line 18, byte-identical.
- **Copy preserved verbatim:** "Transactions: N" (finding 31), the detail labels ("Date"/"Status"/"To"/"From"/"Network"/"Network Fee"/"Hash"/"Transaction Fee"/"Tx Hash"), "View on Explorer", "Sent"/"Received"/"Buy"/"Buy - Failed"/"Swapped"/"Swapped - Failed"/"Swap"/"Swap - Failed"/"Completed job" -- all unchanged, confirmed by re-reading the diff, not just grepping for one string.
- **No `deepBlueMenu` / `Colors.white` / `Colors.white60` / `Colors.white70` / `Colors.redAccent` / `Colors.greenAccent` / `Colors.black` survives** in `transaction_displays.dart` -- confirmed via grep, zero matches (the sole intentional exception, `Colors.lightBlueAccent`, is present at exactly the two sent-arrow sites named in the plan). No `cs.onSurfaceVariant` / `Colors.white` survives in `transactions_slim_view.dart`.
- **`transaction_displays.dart` was NOT split to Alex's four-file layout (GAP-06).** All four transaction item classes remain in this one file; `git status` confirms no new files were created under `lib/dashboard/transactions/`.
- **`transactions_slim_view.dart`'s `SegmentedButton<Filters>` was kept; Alex's separate `TransactionFilters` chip widget was NOT adopted.** No new widget file/dependency was introduced.

## LIVE-FLIP Clause -- Explicitly NOT Claimed Passed

Per this plan's binding constraint, the appearance-aware `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` reads added throughout both files (item cards, detail-drawer cards, amount/secondary text, count footer) are **implemented**, not **observed live**. The access-path mechanism is identical to the one 05-01/05-02/05-03/05-04/05-05 already established and (for 05-01/05-04/05-05) verified live via the dev-tools bubble appearance toggle -- so the mechanism itself is de-risked by precedent -- but this executor did not run the app and did not observe the flip, including the specific OPEN-detail-drawer live-flip clause this plan names as its own regression risk (a stale open drawer after an in-place toggle). This criterion is recorded as **pending-walk**, not passed.

One additional live-flip nuance specific to this plan, recorded for the walker: `_buildRow`'s label color (`GeniusWalletColors.textPrimary70`) is a static getter, not a `gw.*` extension field -- per the plan's literal instruction to match Alex's exact token choice. Per 05-01's Outstanding section, a static getter re-renders correctly on any rebuild (including the non-const `ListView.builder` items this file already produces, and the drawer's own rebuild path), but is not itself registered as a `Theme` dependency the way `gw.textPrimary`/`textSecondary` are. This is not expected to cause a stale-label regression in practice (the drawer content isn't const), but the walker should specifically watch the row LABEL color (not just the value) during the open-drawer live-flip check.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1/2 -- Token discipline completion] Unified `Colors.redAccent`/`Colors.greenAccent` across ALL FOUR item classes, not just the one badge/failure site each was named for**
- **Found during:** Task 1
- **Issue:** The plan's per-element table (§3.3) names "Received-arrow badge bg" and "Swap/purchase failure red" as the two color-swap sites. In the actual file, `Colors.redAccent`/`Colors.greenAccent` also appear on the purchase-success badge/amount, the purchase/swap title text, and the swap-success amount text -- none separately enumerated, but all covered by the plan's own done-criteria clause ("no ... Colors.redAccent / Colors.greenAccent survives").
- **Fix:** Replaced every occurrence with `GeniusWalletColors.statusError` (failure) / `GeniusWalletColors.brandGreen` (success), preserving the existing failed/success branching logic unchanged.
- **Files modified:** `lib/dashboard/home/widgets/transaction_displays.dart`
- **Verification:** `grep -nE 'Colors\.redAccent|Colors\.greenAccent'` returns zero matches; `flutter analyze` clean.
- **Committed in:** `0b3ccf6` (Task 1 commit)

**2. [Rule 2 -- Completeness] Badge border ring also re-tokened (Colors.black), not just the badge icon**
- **Found during:** Task 1
- **Issue:** The plan's per-element table names only "Badge icon color (Colors.black) -> textOnBrand"; `_buildCoinIconWithBadge`'s `Border.all(color: Colors.black, ...)` ring around the same badge was not separately named, but the done-criteria's raw-value list bans `Colors.black` unconditionally.
- **Fix:** Replaced the border color with `GeniusWalletColors.textOnBrand` too, matching the icon's own new color (both are near-black, WCAG-tuned for the badge's bright fills).
- **Files modified:** `lib/dashboard/home/widgets/transaction_displays.dart`
- **Verification:** `grep -n 'Colors.black'` returns zero matches; `flutter analyze` clean.
- **Committed in:** `0b3ccf6` (Task 1 commit)

**3. [Rule 1 -- Preserve pre-existing behavior] Count footer's device text-scale multiplication preserved, not dropped**
- **Found during:** Task 2
- **Issue:** The plan's action text names the substitution as `GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary)` verbatim, which (taken literally) would drop the pre-existing `fontSize: textScale(16)` device-accessibility scaling and leave the `textScale` local variable unused (an analyzer warning).
- **Fix:** Kept the device-scale multiplication, applied to the token's own base size instead of the old hardcoded `16`: `fontSize: textScale(GeniusWalletTypography.labelMd.fontSize!)`. This satisfies the plan's token+color substitution while not regressing large-text-mode accessibility support.
- **Files modified:** `lib/dashboard/home/widgets/transactions_slim_view.dart`
- **Verification:** `flutter analyze` clean (no unused-variable warning); `grep -q 'Transactions: '` present verbatim.
- **Committed in:** `bda2d98` (Task 2 commit)

---

**Total deviations:** 3 (2 x Rule 1/2 token-discipline completions closing the plan's own done-criteria gaps within Task 1's original scope; 1 x Rule 1 behavior-preservation adjustment within Task 2's original scope). **Impact:** none on the plan's intent -- all three closures make the re-skin MORE complete against the plan's own zero-raw-value and behavior-preservation requirements than a literal reading of the per-element table alone would have delivered; none touches structure, logic, or copy.

## Issues Encountered

**`tool/verify_additive_boundary.sh` Check 2 fails on a PRE-EXISTING, unrelated duplicate class name.** Same `_Section` duplicate (`lib/dev/dev_tools_bubble.dart` / `lib/dev/design_gallery_screen.dart`) already logged in `.planning/phases/05-dashboard/deferred-items.md` from 05-04. Neither file is touched by this plan. Checks 1 (shadow import boundary) and 3 (WIRE- tripwire) -- the checks relevant to this plan's scope -- both PASS after both tasks. Not re-logged (already present in `deferred-items.md`).

## Verification Results (Tasks 1-2, automated only)

- `flutter analyze lib/dashboard/home/widgets/transaction_displays.dart` -- **No issues found**.
- `flutter analyze lib/dashboard/home/widgets/transactions_slim_view.dart lib/dashboard/transactions/transactions_screen.dart` -- **No issues found**.
- `bash tool/verify_additive_boundary.sh` (run after each task) -- Check 1 (shadow import boundary) **PASSED**; Check 3 (WIRE- tripwire) **PASSED**; Check 2 **FAILED on the pre-existing, unrelated `_Section` duplicate** documented above, both times.
- Grep gate: `extension<GWColors>()` **present** in `transaction_displays.dart` (9 occurrences, one per build()/helper that resolves an appearance-aware color).
- Grep gate: `Transactions: ` **present** verbatim in `transactions_slim_view.dart`.
- Raw-value discipline (`transaction_displays.dart`): `grep -nE 'deepBlueMenu|Colors\.white\b|Colors\.white60|Colors\.white70|Colors\.redAccent|Colors\.greenAccent|Colors\.black\b'` returns **zero matches**. The sole intentional exception, `Colors.lightBlueAccent`, is present at exactly the two sent-arrow sites the plan names.
- Raw-value discipline (`transactions_slim_view.dart`): `grep -nE 'cs\.onSurfaceVariant|Colors\.white'` returns **zero matches**.
- Finding 34 re-read: exactly one `@override` in `transactions_screen.dart`, at line 12, immediately before `Widget build`.
- Finding 10 re-read: `RefreshIndicator(onRefresh: ...)` at line 16 wraps `context.read<WalletDetailsCubit>().getCoins()` at line 18, byte-identical to pre-plan state (this file was not modified by this plan).
- `git diff --diff-filter=D --name-only HEAD~1 HEAD` (both commits) -- no file deletions.
- `git status --short` after each commit -- only the plan's own declared file staged/committed each time; pre-existing unrelated `README.md` modification left untouched and unstaged throughout.

**None of this constitutes the visual/behavioral verification Task 3's walk provides.**

## User Setup Required

None for Tasks 1-2. Task 3's blocking walk requires a cold debug run on **Windows** (this machine, per this plan's explicit environment recipe): `CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=..." flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true` (pinned Flutter SDK on PATH at `/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`). Close any running Release exe first -- a stale second instance can hold the Hive lock and produce a black window (05-01's documented environment finding, same failure mode applies here). **The walker can populate the transactions list via the dev-tools bubble's Test-flows "Add tx" button** (this plan's environment note) rather than needing real on-chain transaction history.

## Next Phase Readiness

Both auto tasks' code work is complete and committed (`0b3ccf6`, `bda2d98`). **This plan is not closeable until Task 3's blocking walk runs and its results (per-mode, per-criterion) are recorded here.** `SCR-01`/`GAP-06` are not claimed complete for this plan pending that walk -- in particular, the walk should specifically confirm: (1) the open-detail-drawer live-flip (this plan's own named regression risk, including the `_buildRow` label's static-getter caveat above), (2) that no `RenderFlex` overflow occurs on a long address/hash/amount value, (3) that the zero-result-filter case renders the new `GWEmptyState` cleanly, and (4) WCAG AA contrast for the received-badge icon on `brandGreen`, the `statusError` failure text, and the count footer, in BOTH modes. This is the last plan of phase 05-dashboard -- once this walk (and any other still-pending 05-* walk) passes, the phase itself becomes closeable.

---
*Phase: 05-dashboard*
*Tasks 1-2 completed: 2026-07-20. Task 3 (blocking human-verify): PENDING.*

## Self-Check: PASSED

`lib/dashboard/home/widgets/transaction_displays.dart` and `lib/dashboard/home/widgets/transactions_slim_view.dart` confirmed present on disk; task commits `0b3ccf6` and `bda2d98` confirmed present in `git log`.
