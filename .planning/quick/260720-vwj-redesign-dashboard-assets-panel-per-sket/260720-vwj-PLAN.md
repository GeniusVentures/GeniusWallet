---
phase: quick-260720-vwj
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/theme/gw_colors.dart
  - lib/components/coins/view/coin_card_row.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/components/coins/assets_totals.dart
  - test/assets_totals_test.dart
autonomous: true
requirements: [SKETCH-001]
must_haves:
  truths:
    - "Dashboard Assets panel has an 'Assets' header with a total-value / 24h-change cluster whose height is identical between the empty ($0.00) and funded states."
    - "Coin rows show market data (price + a filled 24h% chip) at full strength even at zero balance; holding numbers (fiat value + token amount) render as real 0.0000 / $0.00 and dim to ~38% only when balance is zero."
    - "Up/down is painted with the status tokens (green success / red error), never cyan."
    - "Secondary text, success, and error tokens meet WCAG AA in light mode via the appearance-aware GWColors extension."
    - "The whole-wallet-empty state (total value == 0) shows a Receive + Buy GNUS footer built from the existing GWButton."
  artifacts:
    - lib/theme/gw_colors.dart
    - lib/components/coins/view/coin_card_row.dart
    - lib/components/coins/view/coins_screen.dart
    - lib/components/coins/assets_totals.dart
    - test/assets_totals_test.dart
  key_links:
    - "coin_card_row reads gw.statusSuccess/gw.statusError/gw.textSecondary from Theme.of(context).extension<GWColors>()"
    - "coins_screen header + _calculateTotalValue both consume assets_totals.dart (single source for the balance*price math)"
    - "coins_screen passes filteredCoins[i].networkSymbol into CoinCardRow"
---

<objective>
Redesign the dashboard Assets panel to the APPROVED sketch 001 ("A2 · Market-forward + Stacked header + Center gap"): rename the section to "Assets", add a stacked total/24h-change header with reserved (state-invariant) height, rebuild the coin row so market data survives a zero balance, render real zero-balance holdings dimmed to ~38%, add a Receive / Buy GNUS footer while the wallet holds no value, and land the carried WCAG/color-correctness fixes (appearance-aware textSecondary/statusSuccess/statusError; up/down on the status tokens instead of cyan).

Purpose: The shipped panel repeats an italic zero-balance placeholder on every row and leaves the right column blank — four identical subtitles read as a broken fetch. The market-forward layout structurally fixes the empty state (price + % never depend on balance) and the token fixes clear three light-mode AA failures.
Output: A re-skinned Assets panel (header + rows + footer), three appearance-aware tokens on the GWColors extension, and a pure totals helper with a runnable self-check.
</objective>

<execution_context>
This is a quick task under the project's CLAUDE.md. You are a LAZY senior dev: reuse GWButton, GWTokenRow patterns, GWColors, existing typography tokens; add no dependencies; fewest files.

CRITICAL: The project CLAUDE.md says "Do not create commits." DO NOT run `git commit` at any point. Every task's verification is a build/analyze/test/grep check only. Leave the working tree modified; the human will review and commit.
</execution_context>

<context>
@.planning/STATE.md
@.planning/sketches/001-holdings-panel/README.md
@lib/theme/gw_colors.dart
@lib/theme/genius_wallet_colors.dart
@lib/theme/genius_wallet_typography.dart
@lib/components/coins/view/coin_card_row.dart
@lib/components/coins/view/coins_screen.dart
@lib/components/buttons/gw_button.dart
@packages/genius_api/lib/models/coin.dart
@lib/hive/models/coin_gecko_market_data.dart
</context>

<tasks>

<task type="auto">
  <name>Task 1: Make textSecondary / statusSuccess / statusError appearance-aware on the GWColors extension</name>
  <files>lib/theme/gw_colors.dart</files>
  <action>
Route the three carried WCAG fixes through the appearance-aware GWColors ThemeExtension (the row's access path) rather than flipping the mode-invariant constants in genius_wallet_colors.dart — this is the safe move the sketch README §Findings.1 blesses and avoids the 64-consumer / gray500 / const-context blast radius of migrating the source constants.

1. Add two new Color fields to GWColors: `statusSuccess` and `statusError`. Thread them through the constructor, both factories (light/dark), copyWith, and lerp exactly like the existing fields.
2. Values:
   - light(): statusSuccess = Color(0xFF07875F) (4.5:1), statusError = Color(0xFFD92D2D) (4.8:1), textSecondary = Color(0xFF5A606E) (6.3:1).
   - dark(): statusSuccess = Color(0xFF0AD89C), statusError = Color(0xFFFF4D4D), textSecondary keep GeniusWalletColors.textSecondary (0xFF8A8F9D, verbatim).
3. The machine value-preservation asserts in light()/dark() currently require `instance.textSecondary == GeniusWalletColors.textSecondary`. Since light-mode textSecondary now deliberately diverges from the invariant constant for AA, REMOVE the `textSecondary` comparison line from BOTH asserts and add a one-line comment above each assert noting the deliberate light-mode AA divergence for textSecondary. Do NOT add statusSuccess/statusError to the asserts (they are new appearance-aware fields sourced from literals, not mirrored from GeniusWalletColors).
4. Add a `ponytail:` comment near the new fields: the source constants GeniusWalletColors.textSecondary/statusSuccess/statusError stay mode-invariant for their ~56+ non-migrated consumers; ceiling = those call sites still fail AA in light mode; upgrade path = a dedicated token pass converting the source getters appearance-aware (or migrating those consumers to gw.*).

Do NOT touch genius_wallet_colors.dart, gray500, or bodySm in this task.
  </action>
  <verify>
    <automated>flutter analyze lib/theme/gw_colors.dart</automated>
    Expect "No issues found". Also: `grep -c '0xFF5A606E' lib/theme/gw_colors.dart` and `grep -c '0xFF07875F' lib/theme/gw_colors.dart` and `grep -c '0xFFD92D2D' lib/theme/gw_colors.dart` each return >=1; `grep -c 'statusSuccess' lib/theme/gw_colors.dart` returns >=5 (constructor, 2 factories, copyWith, lerp).
  </verify>
  <done>GWColors exposes statusSuccess/statusError/textSecondary that resolve to AA-passing values in light and the original values in dark; asserts no longer compare textSecondary; analyze is clean.</done>
</task>

<task type="auto">
  <name>Task 2: Rebuild CoinCardRow to the A2 market-forward layout with live zero-balance rows</name>
  <files>lib/components/coins/view/coin_card_row.dart</files>
  <action>
Rebuild the row body (keep the widget's public shape, add one optional field). Read gw = Theme.of(context).extension&lt;GWColors&gt;() ?? GWColors.dark() at the top of build() (preserve this appearance-aware discipline). Keep buildTokenIcon(iconPath: iconPath, size: 38) as leading, unchanged. Keep every AutoSizeText overflow guard (maxLines/minFontSize/overflow: TextOverflow.ellipsis) — do NOT regress finding 30 / summary D4.

Add an optional `final String? networkSymbol;` constructor field (nullable, not required — Task 3 passes it from coins_screen).

Compute:
- price = marketData?.currentPrice ?? 0.0
- pct = marketData?.priceChangePercentage24h ?? 0.0
- fiatValue = price * (balance ?? 0.0)
- final bool noBalance = (balance ?? 0.0) == 0.0
- Color changeColor = pct >= 0 ? gw.statusSuccess : gw.statusError  (standardize up/down on the status tokens — this REPLACES the old cs.primary / cs.error / cs.onSurfaceVariant branch at :39-41; delete the `cs` colorScheme read and the balance-gated color choice).

Layout (A2 · Market-forward):
- title: coin name, GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary).
- subtitle: a Row = price text (currencyFormatter.format(price), GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary)) + a small filled 24h% CHIP + optionally `· {networkSymbol}` (bodySm/textSecondary) when networkSymbol is non-null/non-empty. This whole subtitle is MARKET data → it renders at FULL strength regardless of balance (never dimmed).
  - The % chip: a small Container, padding EdgeInsets.symmetric(horizontal: 6, vertical: 2), borderRadius ~8, color: changeColor.withValues(alpha: 0.15) (tinted bg), child Text('${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%', GeniusWalletTypography.labelMd.copyWith(color: changeColor, fontWeight: FontWeight.w600)). (If withValues is unavailable on the pinned SDK, use withOpacity(0.15).)
- trailing: a Column (crossAxisAlignment.end, mainAxisSize.min) with TWO lines, ALWAYS rendered (the balance==0 skip at :65/:77 is DELETED so the right column is never blank):
  - line 1 fiatValue: currencyFormatter.format(fiatValue), GeniusWalletTypography.numericBody.copyWith(fontWeight: FontWeight.bold, color: noBalance ? gw.textPrimary38 : gw.textPrimary).
  - line 2 token amount: for a real balance use "${WalletUtils.truncateToDecimals(balance.toString())} $symbol"; for zero balance render a REAL "0.0000 $symbol" (four decimals). Style GeniusWalletTypography.bodySm.copyWith(color: noBalance ? gw.textPrimary38 : gw.textSecondary).
  - Dim ONLY these two holding numbers when noBalance (→ textPrimary38, ~38%). Price + chip stay full strength.

DELETE the italic zero-balance placeholder subtitle entirely (the literal currently rendered when balance==0 at coin_card_row.dart:50, and its FontStyle.italic). It must not survive anywhere in the file.

Keep ListTile as the row shell (onTap passthrough) OR adapt to the GWTokenRow structure — ListTile with the leading/title/subtitle/trailing built above is the lazy path; either is acceptable as long as the layout above holds. Do not add dependencies.
  </action>
  <verify>
    <automated>flutter analyze lib/components/coins/view/coin_card_row.dart</automated>
    Expect "No issues found". Negative gate — the deleted placeholder literal must be gone:
    <!-- planner-discipline-allow: No balance yet -->
    `grep -c 'No balance yet' lib/components/coins/view/coin_card_row.dart` returns 0.
    Positive gates: `grep -c 'gw.statusSuccess' lib/components/coins/view/coin_card_row.dart` >=1, `grep -c 'gw.statusError' ...` >=1, `grep -c 'textPrimary38' ...` >=1, `grep -c 'networkSymbol' ...` >=1. Cyan gate: `grep -c 'cs.primary' lib/components/coins/view/coin_card_row.dart` returns 0.
  </automated>
  </verify>
  <done>Row shows name + (price + % chip [+ · network]) subtitle at full strength, and an always-present fiat/amount right column that renders real 0.0000/$0.00 dimmed to 38% at zero balance; up/down uses the status tokens; the italic placeholder is deleted; analyze is clean.</done>
</task>

<task type="auto">
  <name>Task 3: Add the Assets header + empty-wallet footer + a pure totals helper with a runnable self-check</name>
  <files>lib/components/coins/assets_totals.dart, lib/components/coins/view/coins_screen.dart, test/assets_totals_test.dart</files>
  <action>
Three parts. Reuse everything; add no dependencies; do NOT run git commit.

PART A — pure totals helper (new file lib/components/coins/assets_totals.dart):
Define primitive, widget-free functions so the math is testable without constructing the huge CoinGeckoMarketData model:
- `double holdingValue(double balance, double price) => balance * price;`
- `double holdingDayChange(double balance, double price, double pct) => balance * price * pct / 100;`
- `double assetsTotal(Iterable<({double balance, double price})> holdings)` → folds holdingValue.
- `double assetsDayChange(Iterable<({double balance, double price, double pct})> holdings)` → folds holdingDayChange.
Keep it dependency-free (no Flutter import). This is the one non-trivial computation in the change, per CLAUDE.md.

PART B — coins_screen.dart:
1. Import assets_totals.dart and gw_button.dart. Build a `List<({double balance, double price})>` (and the pct-carrying variant) from state.coins + _marketData, keyed by `coin.symbol?.toLowerCase()` (same key the existing _fetchMarketData uses). Compute `total = assetsTotal(...)` and `dayChange = assetsDayChange(...)` in the BlocBuilder builder.
2. DRY: refactor the existing `_calculateTotalValue` loop to call `assetsTotal` instead of hand-rolling the balance*price sum (delete the duplicate inline loop; keep setSelectedWalletBalance(total.toStringAsFixed(2)) behavior identical).
3. Add the panel HEADER as the first child of the rows-branch Column (above the row loop), gated on `widget.onCoinSelected == null` so it only shows in dashboard mode (never in a future coin-picker reuse). Header = a Row, crossAxisAlignment.center:
   - left: Text('Assets', GeniusWalletTypography.titleLg.copyWith(color: gw.textPrimary)).
   - right: a ConstrainedBox(constraints: BoxConstraints(minHeight: 45)) wrapping a Column (mainAxisAlignment.center, crossAxisAlignment.end) — this RESERVES two-line height so the empty and funded states keep identical header height (sketch "Center gap"):
     - total line: Text(currencyFormatter.format(total), GeniusWalletTypography.numericBody.copyWith(fontSize: 20, fontWeight: FontWeight.w700, color: gw.textPrimary)) — amount-first, ~20px bold tabular (numericBody already carries tabular figures).
     - change subline: shown ONLY when total > 0. Text('${dayChange >= 0 ? '+' : ''}${currencyFormatter.format(dayChange)} · ${dayChange >= 0 ? '+' : ''}${pctOfTotal.toStringAsFixed(2)}%', GeniusWalletTypography.labelMd.copyWith(color: dayChange >= 0 ? gw.statusSuccess : gw.statusError)) — $ and % together, 13px. pctOfTotal = total == 0 ? 0 : dayChange / total * 100.
     - When total == 0: render only the $0.00 total line (no subline, no chip).
   No token count, no "funded" text beside the title.
4. Pass `networkSymbol: filteredCoins[i].networkSymbol` into each CoinCardRow.
5. Empty-wallet FOOTER: when `total == 0` (whole wallet holds no value) AND `widget.onCoinSelected == null`, render a footer strip after the row loop: a Row of two GWButton(expand: true) in a Padding —
   - Receive: GWButton(variant: GWButtonVariant.secondary, label: 'Receive', expand: true, onPressed: <wire to the app's existing receive flow; grep for an existing Receive route/handler and reuse it — if none is trivially reachable, leave onPressed navigating to the existing receive screen and add a ponytail note>).
   - Buy GNUS: GWButton(variant: GWButtonVariant.primary, label: 'Buy GNUS', expand: true, onPressed: () => context.push('/buy')) (route confirmed in router.dart).
   Reuse GWButton — do NOT hand-roll buttons.
Preserve: the Timer.periodic(const Duration(minutes: 1)) refresh (do not touch), buildTokenIcon fallback, the appearance-aware gw read discipline, the isUseDivider divider logic, and the existing state.coins.isEmpty → GWEmptyState branch (leave that truly-no-coins branch as-is; add a ponytail note that the value-empty footer lives in the rows branch keyed on total==0).

PART C — test (new file test/assets_totals_test.dart):
A flutter_test file (matches existing test/*_test.dart) asserting the helper math with a fixed example:
- holdings: (balance 0.5, price 60000, pct +2.0) and (balance 2, price 3000, pct -1.0), plus a zero-balance holding (balance 0, price 100, pct 5).
- expect(assetsTotal(...), 36000); expect(assetsDayChange(...), closeTo(540.0, 1e-9)); and expect the zero-balance holding contributes 0 (holdingValue(0, 100) == 0). No frameworks beyond flutter_test, no fixtures.
  </action>
  <verify>
    <automated>flutter test test/assets_totals_test.dart</automated>
    Expect all tests pass. Also: `flutter analyze lib/components/coins/assets_totals.dart lib/components/coins/view/coins_screen.dart` returns "No issues found"; `grep -c "Duration(minutes: 1)" lib/components/coins/view/coins_screen.dart` >=1 (refresh cadence preserved); `grep -c "'Assets'" lib/components/coins/view/coins_screen.dart` >=1; `grep -c "Buy GNUS" lib/components/coins/view/coins_screen.dart` >=1; `grep -c 'networkSymbol' lib/components/coins/view/coins_screen.dart` >=1.
  </automated>
  </verify>
  <done>The panel shows an "Assets" header whose height is identical between $0.00 (one line) and funded (two lines) states; header total/change derive from assets_totals; a Receive/Buy GNUS GWButton footer appears when total==0; the 1-minute refresh is untouched; the totals test passes.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| CoinGecko market data → UI | Already-fetched price/pct values are formatted for display. No new fetch, input, or parsing is introduced by this change. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-vwj-01 | Denial of Service | coin_card_row / header formatting of extreme balance/price values | low | mitigate | Every value goes through AutoSizeText overflow guards (preserved) and NumberFormat.currency; no unbounded layout. |
| T-vwj-02 | Tampering | dependencies | low | accept | No package installs — pure UI + a dependency-free helper. No Package Legitimacy Gate needed. |
</threat_model>

<verification>
- `flutter analyze lib/theme/gw_colors.dart lib/components/coins/view/coin_card_row.dart lib/components/coins/view/coins_screen.dart lib/components/coins/assets_totals.dart` → No issues found.
- `flutter test test/assets_totals_test.dart` → passes.
- Grep gates per task above (light AA hex values present; placeholder literal absent; cs.primary absent from the row; Duration(minutes: 1) preserved; 'Assets' and 'Buy GNUS' present).
- DO NOT run git commit (project CLAUDE.md).
</verification>

<success_criteria>
- Assets header renders with state-invariant height (empty $0.00 == funded two-line height).
- Rows show market data (price + filled % chip) at full strength at any balance; holdings render real 0.0000/$0.00 dimmed to ~38% only when balance is 0; right column never blank.
- Up/down uses gw.statusSuccess / gw.statusError (no cyan); the three tokens pass WCAG AA in light via the GWColors extension.
- Receive / Buy GNUS footer (GWButton) shows when the wallet holds no value.
- The italic zero-balance placeholder subtitle is deleted.
- assets_totals helper test passes; the 1-minute refresh, buildTokenIcon fallback, and appearance-aware access discipline are preserved.
- No commits created; no new dependencies added.
</success_criteria>

<output>
Create `.planning/quick/260720-vwj-redesign-dashboard-assets-panel-per-sket/260720-vwj-SUMMARY.md` when done (do NOT commit it).
</output>
