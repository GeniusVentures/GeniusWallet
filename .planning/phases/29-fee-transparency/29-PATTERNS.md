# Phase 29: Fee transparency - Pattern Map

**Mapped:** 2026-09-18
**Files analyzed:** 4 (1 new domain type, 2 modified providers/widget, 1 modified test)
**Analogs found:** 3 / 4 (row widget has no correct-shape analog — see below)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/swap/swap_quote.dart` (new `FeeLine`-style type + `feeLines` field) | model | transform | `lib/swap/swap_quote.dart` itself (`SwapQuote`/`SwapQuoteRequest`) | exact (same file, same author conventions) |
| `lib/squid_router/squid_swap_provider.dart` (`squidQuote`/`squidQuoteFromJson` mapping, lines 187 & 246) | service (adapter) | transform | same file, existing `_swapToken`/`_sumUsd`/`_sumUsdRaw` mapping helpers | exact |
| `lib/squid_router/route_details_card.dart` (itemized fee rows) | component | request-response (render) | same file's own `_row(...)` — but it is the disallowed shape; see "No correct analog" below | partial (shape right, convention wrong) |
| `test/squid_router/route_details_card_test.dart` (new fee-row assertions) | test | request-response | same file, existing `_pumpCard`/`find.text` pattern | exact |
| fixture-driven adapter test for `feeLines` (new or extended) | test | transform | `test/squid_router/route_fixture.dart` + existing `squidQuote(loadRouteFixture(...))` calls | exact |

## Pattern Assignments

### 1. Domain type for one itemized fee — `lib/swap/swap_quote.dart`

**Analog:** `SwapQuoteRequest`/`SwapQuote` in the same file (lines 1-64).

Conventions to copy exactly:
- **`const` constructor, named-required params, no positional.** (`swap_quote.dart:4-13`, `:30-42`)
- **No Equatable anywhere in `lib/swap/`** — confirmed by grep, zero hits for `extends Equatable` under `lib/swap/`. `SwapQuote` itself is a plain class with no `==`/`hashCode` override. Do not add Equatable to the new fee type; match the file's plain-class convention.
- **Field ordering:** identifier/name fields first, then amounts, matching how `SwapQuote` orders `id, exchangeRate, priceImpact` before amounts.
- **Doc comment above the class, not above fields**, explaining a *design decision* (why strings vs BigInt, why a getter exists) — see `swap_quote.dart:25-28` and `:61-63`. Keep it ≤3 lines per the repo's doc-comment budget.
- **A derived getter belongs on the aggregate, not the line item** — `totalCostUsd` (`:63`) is the model: computed, not stored. If the new type needs a computed value, follow the same `double get x => ...` pattern.
- Suggested field set per D-03/D-05: `name` (String, as Squid sent it — no enum, since D-05 requires case-insensitive matching against unknown names) and `amountUsd` (double, via the same `double.tryParse(...) ?? 0.0` tolerance `_sumUsd` already uses). Do not carry `token`/`percentage`/`gasLimit` from `FeeCost` unless a decision asks for them — D-03 says "our own domain type," not a mirror of Squid's shape.
- **No secrets risk:** confirmed — `FeeCost` carries no key material, so no Equatable/secrets conflict applies here (that constraint is about wallet Cubit state, not this type).

### 2. Adapter mapping — `lib/squid_router/squid_swap_provider.dart`

**Analog:** the file's own `_sumUsd`/`_sumUsdRaw` (lines 258-269) and the two call sites at `:187` and `:246`.

**Current collapse pattern** (lines 187-188, 246-247):
```dart
feesUsd: _sumUsd(estimate.feeCosts.map((fee) => fee.amountUsd)),
gasUsd: _sumUsd(estimate.gasCosts.map((gas) => gas.amountUsd)),
```
and the raw-JSON twin (`:246-247`):
```dart
feesUsd: _sumUsdRaw(estimate['feeCosts']),
gasUsd: _sumUsdRaw(estimate['gasCosts']),
```

**What to copy:** the "tolerant parse, never throw" doc convention on `_sumUsd`/`_sumUsdRaw` (lines 256-263) — a fee cost Squid sends unparseable is worth nothing, not a crash mid-swap. The new `feeLines` mapper must apply the same `double.tryParse(...) ?? 0.0` tolerance per-line, and must not throw on an unrecognized `name` (D-05: "An unrecognised name still renders").

**What to differ on:** `_sumUsd`/`_sumUsdRaw` fold to one `double`; the new mapper must fold to `List<FeeLine>` (or whatever name is chosen), one entry per `feeCosts[]` item, preserving `name`. Per CONTEXT.md's carried-forward rule, `feesUsd` stays (D-03: "additive field... `feesUsd` can stay") — this is an addition, not a replacement of the existing sum. Both call sites (`:187` and `:246`) need the identical new field, exactly as they already duplicate `feesUsd`/`gasUsd` — "fix the shared shape once" per CONTEXT.md's Reusable Assets note, meaning: write one small private mapping function used by both, do not duplicate the fold logic twice.

### 3. Row-rendering widget — `lib/squid_router/route_details_card.dart`

**No correct analog exists in the codebase.** Findings:

- `RouteDetailsCard._row(...)` (lines 71-108) is the only label/value/divider row of this exact shape, and it is precisely the `_build`-style helper AGENTS.md forbids for new code ("Widgets, not helper methods... invisible to the DevTools inspector, can't be `const`").
- `lib/components/cards/gw_detail_grid.dart`'s `GWDetailGrid` (lines 40-77) is the container pattern (hairline-ruled rows, `surfaceSunken` fill, `borderSubtle` hairline) but it renders a `List<Widget> rows` — it does not itself define a row.
- `lib/components/data/gw_copy_row.dart`'s `GWCopyRow` (lines 46-139) is the only promoted `StatelessWidget` row in this shape family, but it is scoped to *tappable, copyable, mono-styled* values (addresses/hashes) per its own doc comment ("Scope constraint... public, non-secret on-chain identifiers only") — wrong shape for a static currency figure, and pulling it in would misuse a copy-affordance on a number nobody needs to copy.
- `lib/components/cards/gw_select_row.dart`'s `GWSelectRow` is a selectable list-item row (leading icon, title/subtitle, selection state) — different role (CRUD-list-item), not a label/value fact row.

**Recommendation for the planner:** this phase's own `_row` is the thing to extract into a proper `StatelessWidget` (e.g. `_FeeRow` or a small private class in the same file, or promoted to `lib/components/cards/` only if a third consumer appears — Rule of Three says two occurrences, even after this phase adds N fee rows to the same card, do not by themselves justify a shared component export). Keep the extraction local to `route_details_card.dart` unless CONTEXT.md's discretion note is read as inviting a promotion; nothing in the decisions requires cross-file reuse.

**Core pattern to copy verbatim** from the existing `_row` (lines 78-107): `Column` wrapping a `Padding` → `Row(mainAxisAlignment: spaceBetween)` with two `Text` children, then a conditional `Divider(height: 1, thickness: 1, color: gw.borderSubtle)`. Convert this into a `StatelessWidget` with `gw`, `label`, `value`, `showDivider`, `valueColor` as constructor fields instead of method parameters — a mechanical `Widget` → `class` conversion, not a redesign.

**D-06 (empty case):** when `feeLines` is empty, render nothing extra — same-chain swaps show no fee rows at all, only gas. Do not adapt `GWDetailGrid`'s empty-list `SizedBox.shrink()` convention (line 53-55) unless the whole card is restructured onto `GWDetailGrid`; simplest is the new rows list being empty inside the existing `Column`.

### 4. Test analogs

**Widget test — multiple figure rows inside one card:**
`test/squid_router/route_details_card_test.dart` (full file, 62 lines) is the direct analog for the new fee-row assertions, not an external one:
- Pump helper: `_host(child)` wraps in `MaterialApp(theme: ThemeData(extensions: [GWColors.dark()]))` + `Scaffold` (lines 13-16); `_pumpCard(tester, fixture)` builds the card from `squidQuote(loadRouteFixture(fixture))` (lines 18-31).
- Finder style: `find.text('exact literal')`, asserted `findsOneWidget` / `findsNothing` — never widget-type finders (lines 37-40, 46-51, 58-60).
- Matcher style: one `expect` per rendered string, comments explaining *why* a figure is what it is (e.g. line 49-51 "Gas only on a same-chain route"). Extend this file directly with fee-line assertions per fixture rather than creating a new test file — Rule of Three / fewest-files-possible.

**JSON-fixture-to-parsed-output test:**
`test/squid_router/route_fixture.dart` (full file, 30 lines) is the loader pattern: named `const` fixture filenames with a one-line doc each (lines 6-15), `rawRouteFixture(name)` reads raw bytes, `loadRouteFixture(name)` deserializes through `standardSerializers.deserializeWith(RouteResponseData.serializer, ...)`. The adapter tests for `feeLines` should call `squidQuote(loadRouteFixture(crossChainRoute))` exactly as `route_details_card_test.dart:22` already does, and assert on the new field directly (no new fixture file needed — `route_response_cross_chain.json` already contains one fee entry ("Gas receiver fee", $0.91) per CONTEXT.md's measured evidence table).

## Shared Patterns

### Theme tokens (adjacent rows, `route_details_card.dart:88-100`)
- **Label:** `GeniusWalletTypography.labelMd.copyWith(color: gw.textSecondary)`
- **Value:** `GeniusWalletTypography.labelMd.copyWith(color: valueColor ?? gw.textPrimary)`
- **Divider:** `Divider(height: 1, thickness: 1, color: gw.borderSubtle)`
- **Success-tinted value** (used for Price Impact today, line 63): `gw.statusSuccess` — do not reuse this for a fee amount; fees are a cost, not a success signal.
- **Known-marginal token:** `gw.textSecondary` and `gw.statusSuccess`/`gw.statusError` carry a `ponytail:` comment at `lib/theme/gw_colors.dart:129-135` — the *mode-invariant, non-appearance-aware* legacy source constants (`GeniusWalletColors._textSecondary/statusSuccess/statusError`) still fail WCAG AA in light mode for their non-migrated call sites. `RouteDetailsCard` already reads the migrated, appearance-aware `gw.textSecondary` via `Theme.of(context).extension<GWColors>()` (line 34), which is the AA-safe getter (light-mode value diverges to 6.3:1 per `gw_colors.dart:301-303`) — so continuing to read `gw.*` (never `GeniusWalletColors.*` directly) keeps the new fee rows on the safe side of this known gap. No new marginal-contrast risk is introduced as long as the new rows read tokens the same way the existing ones already do.

### Braced-if enforcement
`tool/check_brace_style.sh` — every `if` must brace its body on its own line; run via `bash tool/check_brace_style.sh` (or `--fix`). Applies to any new conditional in the fee-mapping function and the new row widget (e.g. the `if (showDivider)` that already exists at line 104 is compliant — note it's a single-line `if` *without* braces in the current file for a single-expression body; verify against the script before assuming that specific line is exempt, since a ternary/ternary-return single-statement `if` without braces may or may not be in-scope for the checker — treat any new `if` you write as brace-required regardless).

### Raw-colour ban
`tool/check_raw_colors.sh` — no `Colors.*` or `Color(0x...)` outside `lib/theme/`. Confirmed `route_details_card.dart` currently has zero raw colours; the new fee rows must read every colour via `gw.*` exactly as the file does today (line 34).

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| Standalone `StatelessWidget` for a non-tappable label/value/divider row | component | request-response | Only two shapes exist: a private non-widget helper (`_row`, disallowed for new code) and a tappable/copyable mono row (`GWCopyRow`, wrong scope). Planner should have the phase's own plan extract `_row` into a small private `StatelessWidget` rather than searching further — see Pattern Assignment 3 above. |

## Metadata

**Analog search scope:** `lib/swap/`, `lib/squid_router/`, `lib/components/cards/`, `lib/components/data/`, `lib/theme/`, `test/squid_router/`
**Files scanned:** `swap_quote.dart`, `squid_swap_provider.dart`, `route_details_card.dart`, `route_details_card_test.dart`, `route_fixture.dart`, `gw_detail_grid.dart`, `gw_copy_row.dart`, `gw_select_row.dart`, `gw_colors.dart`, `squidrouter/lib/src/model/fee_type.dart`, `squidrouter/doc/FeeCost.md`, `tool/check_brace_style.sh`
**Pattern extraction date:** 2026-09-18
