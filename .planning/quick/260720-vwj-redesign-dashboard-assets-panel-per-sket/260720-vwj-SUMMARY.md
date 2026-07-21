---
task: quick-260720-vwj
plan: 260720-vwj-PLAN.md
status: complete
requirements: [SKETCH-001]
date: 2026-07-20
files_created:
  - lib/components/coins/assets_totals.dart
  - test/assets_totals_test.dart
files_modified:
  - lib/theme/gw_colors.dart
  - lib/components/coins/view/coin_card_row.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/components/buttons/gw_button.dart
  - lib/dev/dev_mock_holdings.dart
checks:
  - "flutter analyze (6 touched files: gw_button, coins_screen, coin_card_row, dev_mock_holdings, gw_colors, assets_totals): No issues found!"
  - "flutter test test/assets_totals_test.dart: All tests passed! (+1)"
committed: false
---

# Quick 260720-vwj: Redesign dashboard Assets panel per sketch 001 — Summary

Redesigned the dashboard Assets panel to the APPROVED sketch 001 ("A2 · Market-forward +
Stacked header + Center gap"): the section is titled **Assets** with a reserved-height,
stacked total / 24h-change header (total over a `$ · %` subline), rows show market data
(price + filled 24h% chip) at full strength regardless of balance, zero-balance holdings
render as real `0.0000`/`$0.00` with only the holding numbers dimmed, and an empty-wallet
Receive / Buy GNUS footer built from the brand gradient CTAs. The carried WCAG/colour fixes
landed (appearance-aware `textSecondary`/`statusSuccess`/`statusError`; up/down on the status
tokens, never cyan).

> **Record scope:** the original GSD pass covered the three PLAN tasks (tokens, row, header +
> footer + totals helper). Several details were then refined across dark-walk iterations
> **after** the plan was written. Those are captured verbatim in **§Walk deviations
> (post-plan)** below so this SUMMARY reflects the FULL delivered state, not just the initial
> pass. The final walk was APPROVED for dark; a light-mode gap is deferred (see §Deferred).

## What changed, by task

### Task 1 — appearance-aware status tokens on GWColors (`lib/theme/gw_colors.dart`)
- Added `statusSuccess` and `statusError` `Color` fields, threaded through the constructor,
  both factories, `copyWith`, and `lerp` (lerp stays the existing discrete flip).
- Values: `light()` → `statusSuccess 0xFF07875F` (4.5:1), `statusError 0xFFD92D2D` (4.8:1),
  `textSecondary 0xFF5A606E` (6.3:1); `dark()` → `statusSuccess 0xFF0AD89C`,
  `statusError 0xFFFF4D4D`, `textSecondary` kept verbatim as
  `GeniusWalletColors.textSecondary` (0xFF8A8F9D).
- Removed the `textSecondary` comparison line from BOTH value-preservation asserts (light-mode
  `textSecondary` now deliberately diverges from the mode-invariant constant for AA) with a
  comment above each explaining the omission. Status tokens NOT added to the asserts (sourced
  from literals, not mirrored from `GeniusWalletColors`).
- `ponytail:` comment near the new fields: source constants stay mode-invariant for their ~56+
  non-migrated consumers (ceiling: those call sites still fail AA in light; upgrade path: a
  dedicated token pass converting the source getters appearance-aware).
- Did NOT touch `genius_wallet_colors.dart`, `gray500`, or `bodySm`.

### Task 2 — A2 market-forward CoinCardRow (`lib/components/coins/view/coin_card_row.dart`)
- Reads `gw` via `Theme.of(context).extension<GWColors>() ?? GWColors.dark()`; deleted the
  `cs` colorScheme read and the balance-gated colour choice.
- `changeColor = pct >= 0 ? gw.statusSuccess : gw.statusError` (standardised on the status
  tokens; no cyan, no balance gate).
- Subtitle = price (`bodySm`/`textSecondary`) + a filled 24h% chip
  (`changeColor.withValues(alpha: 0.15)` tint, `labelMd`/`changeColor` w600) — MARKET data,
  full strength regardless of balance.
- Trailing `Column` (end, min) ALWAYS renders two lines: fiat value (`numericBody` bold) over
  token amount (`bodySm`); both dim to `gw.textPrimary38` only when `noBalance`. Zero balance
  renders a real `0.0000 $symbol` and `$0.00`, not a placeholder.
- Deleted the italic "No balance yet" placeholder subtitle entirely.
- Preserved: `buildTokenIcon(size: 38)` leading, every AutoSizeText overflow guard, the
  ListTile shell + onTap passthrough.

### Task 3 — Assets header + empty-wallet footer + pure totals helper
- **`lib/components/coins/assets_totals.dart` (new)**: dependency-free `holdingValue`,
  `holdingDayChange`, `assetsTotal`, `assetsDayChange` — the single source for the
  balance*price(*pct) math, testable without the heavy `CoinGeckoMarketData` model.
- **`test/assets_totals_test.dart` (new)**: asserts `assetsTotal == 36000`,
  `assetsDayChange ≈ 540` (`closeTo(540.0, 1e-9)`), and that a zero-balance holding
  contributes 0. `flutter_test` only, no fixtures.
- **`coins_screen.dart`**: `_calculateTotalValue` folds `assetsTotal(...)`; the **Assets**
  header is the first child of the rows-branch Column (dashboard-only via
  `widget.onCoinSelected == null`), with a `ConstrainedBox` reserving two-line height so the
  empty ($0.00) and funded (total + `$ · %` subline) states keep identical header height; the
  empty-wallet footer (Receive + Buy GNUS) appears after the loop, gated on
  `isDashboard && total == 0`. Preserved: the `Timer.periodic(minutes: 1)` refresh,
  `buildTokenIcon` fallback, the appearance-aware `gw` read, the `state.coins.isEmpty →
  GWEmptyState` branch.

## Walk deviations (post-plan)

Changes made during the dark-walk iterations that were NOT in the original PLAN. Each is now
part of the delivered, APPROVED (dark) state.

1. **Section renamed to "Assets" + stacked header.** Total over a 24h `$ · %` subline, with a
   reserved 2-line height so the empty and funded states share identical header height.
   *Rationale:* the funded/empty header must not jump when value appears (sketch "Center gap").
2. **Row = A2 market-forward; "No balance yet" deleted.** Zero rows show real `0.0000`/`$0.00`
   with only the holding numbers dimmed; up/down painted on the status tokens (not `cs.primary`).
   *Rationale:* four identical italic placeholders read as a broken fetch; market data never
   depends on balance.
3. **Light-mode AA token fixes on GWColors** (`textSecondary`/`statusSuccess`/`statusError`),
   appearance-aware via the extension. *Rationale:* three light-mode WCAG AA failures cleared
   without the 56+ consumer blast radius of flipping the source constants.
4. **Visible straight row separators** (`Divider` height/thickness 1, `gw.borderSubtle`) shown
   on the dashboard. *Rationale:* the rows needed a defined edge to read as a list, per sketch.
5. **Consistent 8px inset** (header + ListTile `contentPadding`) so "Assets"/total and all row
   values share the same left/right edges; header→first-row and last-row→CTA gaps both `space8`.
   *Rationale:* misaligned left/right edges made the panel look ragged.
6. **GNUS-first display sort** (`orderedCoins`) — real + mock both show GeniusAI/ETH/USDC/USDT.
   *Rationale:* GNUS is the hero asset and must lead the list.
7. **Removed the "· networkSymbol" (chain) from the row** (field, param, and render deleted).
   *Rationale:* the chain suffix added noise; the walk dropped it from the A2 subtitle.
8. **`dev_mock_holdings.loadPopulated` reordered to GNUS/ETH/USDC/USDT** (name "GeniusAI"),
   Bitcoin removed, USDT added. *Rationale:* DEV-ONLY fixture aligned to the GNUS-first sort and
   the sketch's asset set. (Dev fixture only — no production data path.)
9. **Empty-wallet CTA rebuilt on the brand gradient.** Receive = new
   `GWButtonVariant.gradientOutline` (gradient border + label via a srcIn ShaderMask); Buy GNUS
   = `GWButtonVariant.gradient` fill; both size `sm` (44px). Replaces the flat neon `#14C8FF`.
   *Rationale:* the pair now shares one gradient identity instead of a lone neon fill.
10. **CTA hover = brighten (option A) + pointer cursor** (this finalizing task; see below).
    *Rationale:* the bright gradient fill swallows the Material ripple, so filled CTAs had no
    visible hover feedback and no pointer cursor.

### Deviation 10 detail — CTA hover + cursor (`lib/components/buttons/gw_button.dart`)
- On the existing `InkWell`: `mouseCursor: disabled ? SystemMouseCursors.basic :
  SystemMouseCursors.click` (the "łapka" pointer on enabled CTAs; deferred to basic when
  disabled so it is never forced).
- `overlayColor: _overlay(disabled)` — a new `WidgetStateProperty.resolveWith` helper that
  paints a white brighten wash for the gradient variants and defers (returns `null`) for every
  other variant so secondary/ghost/etc. keep their default InkWell hover:
  - `gradient` (Buy GNUS, filled): `Colors.white.withValues(alpha: 0.12)` hovered / `0.18`
    pressed → brightens the gradient (primary target, matches sketch A `.buy` `.12`).
  - `gradientOutline` (Receive): kept very low (`0.04` hovered / `0.06` pressed) — its subtree
    is recolored by a srcIn ShaderMask, so the white overlay repaints as a faint brand tint,
    reading as a subtle paired reaction without breaking the gradient border/text.
- No Stateful conversion — `GWButton` stays `const`-instanced; the existing
  `AnimatedContainer` (`GeniusWalletMotion.fast`) supplies the motion feel. No scale/lift/glow
  (user chose A · Brighten only). Marked with a `ponytail:` comment (ceiling: the outline
  reaction is a tint, not a true brighten; upgrade path = lift the overlay outside the mask).

## Deviations from Plan (original pass)

**1. [Rule 3 — blocking issue resolved] Receive button has no `/receive` route to point at.**
- **Found during:** Task 3, Part B (footer wiring).
- **Issue:** No `/receive` route exists in `lib/navigation/router.dart`, and `WalletInformation`
  (the QR/address screen) is only constructed in the dev closure canary — not trivially reachable.
- **Resolution (minimal, lazy):** Reused the existing `CryptoAddressQR` component inside the
  existing `ResponsiveDrawer.show`, fed by `state.selectedWallet?.address` /
  `state.selectedNetwork` — the genuine receive UI (address QR + copy) with zero new
  screens/routes/deps. Early-returns when no wallet address is available. Documented with a
  `ponytail:` note (ceiling: no amount-request / deep-link; upgrade path: a dedicated
  `/receive` screen if receive grows).
- **Files:** `lib/components/coins/view/coins_screen.dart` (`_showReceive`).

No 05-03 decisions were regressed: the SCR-01 access path is preserved (rows/screen read
`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`), the 1-minute refresh Timer is
untouched, `buildTokenIcon` fallback kept, the GNUS-first sort and removed chain hold, the
gradient CTAs stand, and no `genius_wallet_colors.dart` source constant was flipped (const
re-skin safety intact).

## Deferred (light-mode pass)

The new `gradientOutline` Receive button paints its border + label with the brand CTA gradient
whose green stop is `#0AD89C`. On a white (light-mode) surface that green reads ~1.9:1 —
**below WCAG AA**. This is **deferred to the dedicated light-mode pass** per the project's
dark-first focus; **dark mode is fine** (the gradient reads well on the dark surface and was
the APPROVED walk target). Tracked here so the light-mode pass picks it up.

## Verification (runnable checks — NO commit used)

- `flutter analyze lib/components/buttons/gw_button.dart lib/components/coins/view/coins_screen.dart
  lib/components/coins/view/coin_card_row.dart lib/dev/dev_mock_holdings.dart lib/theme/gw_colors.dart
  lib/components/coins/assets_totals.dart` → **No issues found!** (6 items, ran in 2.6s)
- `flutter test test/assets_totals_test.dart` → **All tests passed! (+1)**

Note on the harness: the project's standing blocker is that `flutter test` does not compile
project-wide. `test/assets_totals_test.dart` targets the dependency-free helper (no Flutter
imports in `assets_totals.dart`), so it compiles and runs in isolation — it passed here.

## Git

No commits created and nothing staged, per the project CLAUDE.md hard rule ("Do not create
commits"). All edits left UNSTAGED in the working tree for the human to review.

## Self-Check: PASSED

- `lib/components/coins/assets_totals.dart` — FOUND
- `test/assets_totals_test.dart` — FOUND
- `lib/components/buttons/gw_button.dart`, `lib/components/coins/view/coin_card_row.dart`,
  `lib/components/coins/view/coins_screen.dart`, `lib/dev/dev_mock_holdings.dart`,
  `lib/theme/gw_colors.dart` — modified, analyze clean (6 items, No issues found)
- No commits created (changes present as unstaged working-tree modifications)
