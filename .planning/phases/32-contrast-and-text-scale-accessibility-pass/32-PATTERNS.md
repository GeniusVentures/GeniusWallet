# Phase 32: Contrast and Text-Scale Accessibility Pass - Pattern Map

**Mapped:** 2026-09-25
**Files analyzed:** 4 goals -> ~7 modified files, 2-3 new test files
**Analogs found:** 6 / 6 (every file has an in-tree analog; no "no analog" section needed)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/theme/genius_wallet_colors.dart` (add `_borderControlOnBrand` getter) | config (design token) | transform (static colour resolution) | `_borderControl` getter, same file, lines 200-231 | exact |
| `lib/theme/gw_colors.dart` (add `borderControlOnBrand` field to `GWColors`, both `.light()`/`.dark()` factories, `copyWith`, `==`/`hashCode`) | config (design token) | transform | `borderControl` field wiring, same file (constructor ~61/145, `.light()` ~320, `.dark()` ~491, `copyWith` ~654/724) | exact |
| `lib/components/inputs/gw_switch.dart` (point enabled `trackOutlineColor` branch at new token) | component | request-response (build-time colour resolution) | same file's existing disabled-branch resolver, lines 59-64 | exact (same widget, same resolver) |
| ~19 call sites swapping `gw.statusSuccess`/`gw.statusError` -> `*Text` partner (e.g. `lib/chart/crypto_simple_chart.dart`, `lib/dashboard/chart/markets_table.dart`, `lib/screens/pin_screen.dart`, etc.) | component | transform (colour lookup on `Text`/`Icon`) | `lib/dashboard/home/widgets/transaction_displays.dart:83-100` (the already-shipped `fg`/`wash` split) | exact |
| `test/theme/enabled_control_contrast_test.dart` (new) | test | transform (contrast math) | `test/theme/disabled_control_contrast_test.dart:73-84` | exact |
| `test/theme/status_text_color_invariant_test.dart` (new, source-scan) | test | batch (static source scan) | `test/components/drawer_padding_invariant_test.dart` | exact |
| `lib/components/overlay/responsive_overlay.dart` (`_MobileTabBar.build`, add textScaler clamp) | component | request-response (layout/build) | in-tree comment precedent at `lib/components/overlay/mobile_header.dart:276-292` citing `AppBar`'s `_kMaxTitleTextScaleFactor`/`MediaQuery.withClampedTextScaling`; SDK's own `AppBar` (not in-tree, cited only) | role-match (mobile_header documents the pattern but delegates to AppBar; responsive_overlay must wrap MediaQuery itself since `_MobileTabBar` is not an AppBar) |
| `test/components/mobile_nav_destinations_test.dart` (extend existing group, 2 new tests) | test | transform (geometry math + widget pump) | same file, existing test "the slot stack fits the bar height", lines 283-314 | exact |
| `lib/theme/genius_wallet_typography.dart` (add `labelLg` getter, wire into `toMaterialTextTheme()`, comment the 4 deliberately-unmapped slots) | config (design token) | transform | same file's existing `labelMd`/`bodySm` getters (lines ~124-125) and `toMaterialTextTheme()` (150-161) | exact |
| `test/theme/action_chip_font_test.dart` (new, widget test) | test | request-response (widget pump + resolved style assertion) | none exact in-tree for "pump a bare Material widget, assert resolved TextStyle.fontFamily" — closest shape is any widget test pumping `getThemeData()` (see `theme_contrast_test.dart`'s `themeFor` helper) | role-match |

## Pattern Assignments

### `lib/theme/genius_wallet_colors.dart` + `lib/theme/gw_colors.dart` — new `borderControlOnBrand` token

**Analog:** `_borderControl` getter and its `GWColors` wiring, same two files.

**Doc-comment convention to copy** (`lib/theme/genius_wallet_colors.dart:200-231`):
```dart
/// The edge of a CONTROL whose fill cannot identify it -- ...
///
/// WHY a third border token rather than [_borderStrong]: WCAG 1.4.11 asks for
/// 3:1 from anything that identifies a UI component, ...
///
/// | edge | contrast |
/// |---|---|
/// | `_borderSubtle` white 12% | 1.36:1 |
/// ...
/// | **white 36%** | **3.30:1** ✓ |
///
/// 36 is not a round number chosen for looks -- it is the first step that
/// clears 3:1, ...
static Color get _borderControl => _isLight
    ? const Color.fromRGBO(16, 19, 26, 0.48)
    : const Color.fromRGBO(255, 255, 255, 0.36);
```
Follow this exact shape for the new getter: a computed-contrast table in the doc comment (values are already computed in RESEARCH.md Item 1: dark = white 56%/144, light = ink 52%/132), then the `_isLight ? ... : ...` ternary.

**GWColors wiring** (`lib/theme/gw_colors.dart`):
- Constructor param + field, mirroring `borderControl` (`required this.borderControl,` / `final Color borderControl;` near lines 61/145)
- `.light()` factory: `borderControlOnBrand: GeniusWalletColors._borderControlOnBrand,` alongside the existing `borderControl:` line (~320)
- `.dark()` factory: same line shape (~491)
- `copyWith`: `Color? borderControlOnBrand,` param + `borderControlOnBrand: borderControlOnBrand ?? this.borderControlOnBrand,` (~654/724)
- `==`/`hashCode`: add `instance.borderControlOnBrand == GeniusWalletColors._borderControlOnBrand &&` alongside the `borderControl` line (~397/565) — **must touch all 4 wiring points**, matching `borderControl`'s own 5-touch footprint exactly (constructor, field, both factories, copyWith, equality).

### `lib/components/inputs/gw_switch.dart` — enabled track outline swap

**Analog:** the file's own disabled-branch resolver, lines 59-64.

**Current code** (`lib/components/inputs/gw_switch.dart:59-64`):
```dart
trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.disabled)) {
    return gw.borderControl;
  }
  return gw.borderSubtle;
}),
```
**Target shape** (per RESEARCH.md's recommendation — one-line change, disabled branch untouched):
```dart
trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.disabled)) {
    return gw.borderControl;         // unchanged
  }
  return gw.borderControlOnBrand;    // clears 3:1 vs ON *and* OFF track, both modes
}),
```
No import changes needed — `gw` is already in scope (`final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` at line 30).

### Call-site swap: `gw.statusSuccess`/`gw.statusError` → `*Text` partner

**Analog:** `lib/dashboard/home/widgets/transaction_displays.dart:83-100` — the already-shipped, correct pattern.

```dart
// Source: lib/dashboard/home/widgets/transaction_displays.dart:83-100
TransactionStatus.completed => (
  fg: gw.statusSuccessText,
  wash: gw.statusSuccess.withValues(alpha: 0.14),
),
TransactionStatus.failed => (
  fg: gw.statusErrorText,
  wash: gw.statusError.withValues(alpha: 0.14),
),
```
Rule to apply at each in-scope call site (full inventory in `32-RESEARCH.md` Item 2): if the token paints a `Text`/`TextStyle`/`Icon` foreground on a plain surface, replace `gw.statusSuccess`→`gw.statusSuccessText`, `gw.statusError`→`gw.statusErrorText`. If it feeds a `wash:`/`bg:`/fill/border/dot, leave unchanged — mirror exactly the `fg`/`wash` split above, do not touch the `wash` line when editing a file that already has one.

### `test/theme/enabled_control_contrast_test.dart` (new)

**Analog:** `test/theme/disabled_control_contrast_test.dart:73-84`, imports `contrastRatio`/`themeFor` from `theme_contrast_test.dart` rather than redefining them.

```dart
// Source: test/theme/disabled_control_contrast_test.dart:1-9,73-84
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

test('disabled switch outline clears 3:1 against its track -- $mode', () {
  final gw = themeFor(mode).extension<GWColors>()!;
  final composited = Color.alphaBlend(gw.borderControl, gw.surfaceMenu);
  final ratio = contrastRatio(composited, gw.surfaceMenu);
  expect(ratio, greaterThanOrEqualTo(uiFloor), reason: '...');
});
```
New test must `Color.alphaBlend` the ON track fill itself first (`brandPrimaryStrong.withAlpha(140)` over each of `surfaceBase`/`surfaceElevated`/`surfaceMenu`), THEN alphaBlend `borderControlOnBrand` over that composited result, before calling `contrastRatio` — two-stage blend, not one. This is the exact trap RESEARCH.md's Pitfall 1 names.

### `test/theme/status_text_color_invariant_test.dart` (new, source-scan)

**Analog:** `test/components/drawer_padding_invariant_test.dart` (full pattern reused, not just cited).

Key structural elements to copy verbatim:
```dart
// Source: test/components/drawer_padding_invariant_test.dart:104-107
String _strippedSource(String path) {
  final lines = File(path).readAsStringSync().split('\n');
  return lines.where((line) => !line.trim().startsWith('//')).join('\n');
}
```
```dart
// Source: test/components/drawer_padding_invariant_test.dart:138-151
Set<String> _discoverCallSitePaths() {
  final discovered = <String>{};
  for (final entity in Directory('lib').listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) {
      continue;
    }
    final relativePath = entity.path.replaceAll('\\', '/');
    final content = _strippedSource(relativePath);
    if (_showCallPattern.hasMatch(content)) {
      discovered.add(relativePath);
    }
  }
  return discovered;
}
```
For this new test: swap `_showCallPattern` for a regex matching `gw\.status(Success|Error)\b` NOT already followed by `Text`, walk `lib/`, and diff against a hand-written `_census` (allowlist) map exactly like `_census` at lines 39-77 — one entry per file, classified `wash`/`fill`/`border`/`dot` (out of scope) vs a bare TEXT/Icon use that should have been swapped. Two tests minimum, mirroring the drawer file's "discovered not in census fails" / "census entry with no real match is stale" pair (lines 155-186).

### `lib/components/overlay/responsive_overlay.dart` — mobile bar textScaler clamp

**Analog:** in-tree precedent/citation only — `lib/components/overlay/mobile_header.dart:276-292` documents (but does not itself implement) `AppBar`'s clamp, because that header's lockup is mounted inside a real `AppBar.title` and inherits the clamp for free:
```dart
// Source: lib/components/overlay/mobile_header.dart:281-284 (comment, quoting the SDK)
//   app_bar.dart:1098  title = MediaQuery.withClampedTextScaling(
//                        maxScaleFactor: _kMaxTitleTextScaleFactor,
//   app_bar.dart:44    const _kMaxTitleTextScaleFactor = 1.34
```
`_MobileTabBar` is NOT an `AppBar`, so it must wrap its own subtree in a `MediaQuery` explicitly (no in-tree example of `MediaQuery.withClampedTextScaling`/`.clamp(maxScaleFactor:)` exists yet — this will be the first). RESEARCH.md already supplies the exact shape and constant (`221/180`); follow its comment style (explain the ceiling's derivation inline, citing the same constants `mobile_nav_destinations_test.dart` prints, exactly as `mobile_header.dart`'s comment cites `AppBar`'s).

**Test-side analog for asserting a clamp under a pumped `textScaler`:** `test/components/mobile_header_brand_and_pill_test.dart:103`:
```dart
).copyWith(textScaler: TextScaler.linear(textScale)),
```
Use this same `MediaQuery(...).copyWith(textScaler: TextScaler.linear(x))` wrap-and-pump shape for the two new tests in `mobile_nav_destinations_test.dart`.

### `test/components/mobile_nav_destinations_test.dart` — extend existing group

**Analog:** the file's own existing test, lines 283-314 (computed-from-constants pattern, not a literal).

```dart
// Source: test/components/mobile_nav_destinations_test.dart:283-296
test('the slot stack fits the bar height, with the slack printed', () {
  const double padding = 2 * GeniusWalletConsts.space4;
  final double labelLine = 10 * GeniusWalletTypography.labelMd.height!;
  final double total =
      padding + kMobileNavIconSize + GeniusWalletConsts.space2 + labelLine;
  final double slack = kMobileBarHeight - total;
  debugPrint(
    'BAR VERTICAL | padding=$padding icon=$kMobileNavIconSize '
    'gap=${GeniusWalletConsts.space2} label=$labelLine '
    'total=$total bar=$kMobileBarHeight slack=$slack',
  );
  expect(total, lessThanOrEqualTo(kMobileBarHeight));
  expect(slack, moreOrLessEquals(3.15, epsilon: 0.01));
});
```
Add two sibling tests in the same `group`: one pumping/computing at `TextScaler.linear(1.30)` (above the new `221/180` ceiling) asserting the rendered label line-box height still equals the unscaled value; one at `1.20` (below ceiling) asserting normal scaling still occurs. Keep the same `debugPrint` self-documentation habit — this file consistently prints its own arithmetic rather than asserting a bare number.

### `lib/theme/genius_wallet_typography.dart` — map `labelLarge`

**Analog:** same file's existing getters and `toMaterialTextTheme()`.

```dart
// Source: lib/theme/genius_wallet_typography.dart:150-161 (quoted verbatim in RESEARCH.md)
static TextTheme toMaterialTextTheme() => TextTheme(
  displayLarge: displayLg,
  displayMedium: displayMd,
  headlineLarge: headlineLg,
  headlineMedium: headlineMd,
  titleLarge: titleLg,
  titleMedium: titleMd,
  bodyLarge: bodyLg,
  bodyMedium: bodyMd,
  bodySmall: bodySm,
  labelMedium: labelMd,
);
```
Add a `labelLg` getter following the exact shape of the neighbouring `labelMd` getter (line ~124-125: `_inter(fontSize: ..., height: ..., ...)`), 14px/`w500` per RESEARCH.md, then add `labelLarge: labelLg,` to the map above. Add a comment above the four still-unmapped slots (`displaySmall`, `headlineSmall`, `titleSmall`, `labelSmall`) naming that each was audited this phase and has no live consumer — do not add getters for these four.

### `test/theme/action_chip_font_test.dart` (new)

**Analog:** no exact in-tree widget-pump-for-font-family test exists; nearest reusable piece is `theme_contrast_test.dart`'s `themeFor(mode)` helper for building `getThemeData()` under test, and the general `flutter_test` widget-pump shape used throughout `test/components/`.
```dart
// Reuse: test/theme/theme_contrast_test.dart:29-36
ThemeData themeFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return getThemeData();
}
```
Pump a bare `ActionChip` under `MaterialApp(theme: themeFor(mode), home: ...)`, then `tester.widget<DefaultTextStyle>(find.ancestor(of: find.text('word'), matching: find.byType(DefaultTextStyle)).first).style.fontFamily`, assert it equals `'Inter'` (or the concrete family constant `_inter` resolves to — check `genius_wallet_typography.dart`'s `_inter` helper for the exact family string before writing the assertion).

## Shared Patterns

### Contrast ratio math — single source of truth
**Source:** `test/theme/theme_contrast_test.dart:16-27` (`contrastRatio`) — do not reimplement.
```dart
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}
```
**Apply to:** `enabled_control_contrast_test.dart`, any spot-check in `status_text_color_invariant_test.dart`. Import via `show contrastRatio, themeFor` from `theme_contrast_test.dart`, never copy the function body.

### Alpha compositing before measuring translucent fills
**Source:** `test/theme/disabled_control_contrast_test.dart:29,47,75` — always `Color.alphaBlend(fg, backdrop)` before `contrastRatio`. Any translucent token (`borderControl`, `borderControlOnBrand`, `brandPrimaryStrong.withAlpha(140)`) must go through this before its luminance means anything — `Color.computeLuminance()` silently ignores alpha.

### Source-scan invariant test shape
**Source:** `test/components/drawer_padding_invariant_test.dart` (full file) — hand-written census + `Directory('lib').listSync(recursive: true)` discovery + "discovered not in census" / "census entry now stale" test pair. **Apply to:** `status_text_color_invariant_test.dart`.

### fg/wash colour-pair convention
**Source:** `lib/dashboard/home/widgets/transaction_displays.dart:83-100`. **Apply to:** every call site touched by Item 2's swap, and as the model for `gw_error_state.dart`/`bridge_screen.dart`/`swap_screen.dart`'s CTA banners per RESEARCH.md.

## No Analog Found

None — every file in scope has at least a role-match analog in-tree (see table above). The one partial gap is `action_chip_font_test.dart`'s exact widget-pump-for-font assertion, which composes two existing pieces (`themeFor` + standard widget pump) rather than copying a single existing test file.

## Metadata

**Analog search scope:** `lib/theme/`, `lib/components/inputs/`, `lib/components/overlay/`, `lib/dashboard/home/widgets/`, `test/theme/`, `test/components/`
**Files scanned:** `genius_wallet_colors.dart`, `gw_colors.dart`, `gw_switch.dart`, `transaction_displays.dart`, `theme_contrast_test.dart`, `disabled_control_contrast_test.dart`, `drawer_padding_invariant_test.dart`, `mobile_header.dart`, `mobile_nav_destinations_test.dart`, `mobile_header_brand_and_pill_test.dart`, `genius_wallet_typography.dart`
**Pattern extraction date:** 2026-09-25
