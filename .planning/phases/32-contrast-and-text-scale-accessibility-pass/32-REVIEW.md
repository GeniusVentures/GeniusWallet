---
phase: 32-contrast-and-text-scale-accessibility-pass
reviewed: 2026-09-25T14:32:54Z
depth: standard
files_reviewed: 38
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/account/sdk_account_manager.dart
  - lib/chart/crypto_live_chart.dart
  - lib/chart/crypto_simple_chart.dart
  - lib/components/coins/assets_total_band.dart
  - lib/components/coins/view/coin_card_row.dart
  - lib/components/feedback/gw_error_state.dart
  - lib/components/inputs/gw_select.dart
  - lib/components/inputs/gw_switch.dart
  - lib/components/inputs/gw_text_field.dart
  - lib/components/overlay/responsive_overlay.dart
  - lib/components/qr/crypto_address_qr.dart
  - lib/components/wallet_information.dart
  - lib/components/wallets_overview.dart
  - lib/dashboard/bridge/bridge_screen.dart
  - lib/dashboard/chart/markets_cards.dart
  - lib/dashboard/chart/markets_hero_card.dart
  - lib/dashboard/chart/markets_table.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/dashboard/news/view/crypto_news_screen.dart
  - lib/logs/submit_logs_screen.dart
  - lib/reown/reown_connect_button.dart
  - lib/screens/banxa_buy_screen.dart
  - lib/screens/pin_screen.dart
  - lib/settings/settings_screen.dart
  - lib/squid_router/route_details_card.dart
  - lib/squid_router/swap_screen.dart
  - lib/squid_router/swap_settings_drawer.dart
  - lib/theme/genius_wallet_colors.dart
  - lib/theme/genius_wallet_typography.dart
  - lib/theme/gw_colors.dart
  - lib/theme/theme.dart
  - lib/tokens/token_info_screen.dart
  - test/components/mobile_nav_destinations_test.dart
  - test/theme/enabled_control_contrast_test.dart
  - test/theme/gw_colors_parity_test.dart
  - test/theme/material_text_slots_test.dart
  - test/theme/status_text_color_invariant_test.dart
  - test/theme/status_text_contrast_test.dart
findings:
  critical: 0
  warning: 3
  info: 1
  total: 4
status: issues_found
---

# Phase 32: Code Review Report

**Reviewed:** 2026-09-25T14:32:54Z
**Depth:** standard
**Files Reviewed:** 38
**Status:** issues_found

## Summary

Reviewed all four plans of the contrast/text-scale pass against `git diff d35c2a7b..HEAD`. The
substance of the sweep is sound: every foreground swap I traced (price-change labels, PIN/account/
settings/logs/Banxa status text, form errors, banners, swap/bridge CTAs, WalletConnect states, the
route/receipt values) stayed a straight token rename at a `Text`/`Icon`-beside-`Text` site, and every
wash, border, sparkline, chart line and standalone icon I checked kept the raw fill-tuned token,
matching THE RULE stated in 32-02's plan context. I independently re-ran the census test's own scan
logic (strip `//`-only lines, count `\.status(Success|Error)\b`) against the current tree and it
matches `status_text_color_invariant_test.dart`'s hand-written census exactly — 25 files, no
unclassified reads, no stale entries, no count drift. The `MediaQuery.withClampedTextScaling` clamp
in `responsive_overlay.dart` wraps only `_MobileTabBar`'s own returned subtree, not an ancestor of
the page, so it cannot leak the clamp onto unrelated screens. `ThemeData(fontFamily:)` in `theme.dart`
only reaches Material's own unmapped defaults (the merge already gave every `GeniusWalletTypography`
style its own explicit `fontFamily: 'Inter'`, so no already-Inter style changes, and no non-Inter
style existed to protect).

Two real defects, both process/documentation rather than runtime bugs: a genuinely new AGENTS.md
violation (test-file name and phase/plan IDs baked into shipped source, worse than the 3-line doc
comment cap the same commit blows past), and one design decision — the swap/bridge CTA's loading
spinner now painting from the AA-text-tuned token rather than the wash-tuned raw token — that sits
outside THE RULE's stated scope (`Text`/`Icon`-beside-label) even though the plan named it explicitly.

## Warnings

### WR-01: `kMobileBarMaxTextScale`'s doc comment names a test file and runs 4 lines, violating both AGENTS.md rules it sits under

**File:** `lib/components/overlay/responsive_overlay.dart:107-111`
**Issue:** AGENTS.md is explicit on two points this one doc comment breaks at once: "Doc comment: 3
lines max" and "Do not name test files in source comments. The test finds the code; the code does
not announce the test." The comment is 4 lines and its last line is
`` /// `mobile_nav_destinations_test.dart`'s own slack arithmetic.`` — it names the test file by
filename.
```dart
/// The textScaler ceiling above which the bar's label line would eat past
/// the 3.15px of slack `kMobileBarHeight` leaves at 1.0x and overflow the
/// slot vertically. `17 / (10 * labelMd.height!)` -- see
/// `mobile_nav_destinations_test.dart`'s own slack arithmetic.
const double kMobileBarMaxTextScale = 221 / 180;
```
The underlying math checks out (`17 / (10 * labelMd.height!)` = `17 / 13.846` ≈ `1.2278` ≈ `221/180`,
consistent with the slack test's own arithmetic), so this is a documentation-hygiene finding, not a
logic bug.
**Fix:** Drop the test-file reference and trim to 3 lines, e.g.:
```dart
/// The textScaler ceiling above which the bar's label line would eat past
/// the bar's 3.15px of slack at 1.0x and overflow the slot vertically:
/// `17 / (10 * labelMd.height!)`.
const double kMobileBarMaxTextScale = 221 / 180;
```

### WR-02: New test file bakes phase/plan IDs into shipped source four times

**File:** `test/theme/status_text_color_invariant_test.dart:1, 17, 170` (and `test/theme/gw_colors_parity_test.dart:62`)
**Issue:** AGENTS.md: "Never cite plan, phase, sketch, spec or UAT numbers in source... Those
identifiers rot the moment a phase is renumbered and mean nothing to someone reading the file." This
brand-new file (not an extension of a pre-existing pattern) opens with `// Phase 32 gate (32-04): the
census this whole contrast sweep locks behind.`, repeats `32-04` in a doc comment
(`/// ... at the end of 32-04 -- NOT a glob.`), and again in a `group()` name:
`group('Raw status-token census (32-04)', ...)`. `gw_colors_parity_test.dart`'s edited test
description also appends `+ borderControlOnBrand from the 32-01 enabled-switch-outline AA fix`,
extending a pre-existing (already noncompliant) string with a fresh `32-01` citation rather than
describing the constraint without the phase number.
**Fix:** Replace each phase/plan citation with a description of the invariant itself, e.g. `// The
census this raw status-token gate locks behind.` and `group('Raw status-token census', ...)`. For
the parity test, describe what `borderControlOnBrand` is instead of which plan added it.

### WR-03: CTA loading spinner repaints from the AA-text-tuned token, outside THE RULE's stated text/icon scope

**File:** `lib/squid_router/swap_screen.dart:789,814` and `lib/dashboard/bridge/bridge_screen.dart:735,756`
**Issue:** THE RULE (32-02's plan context, reused verbatim by 32-03/32-04) is: "a foreground (`Text`,
`TextStyle`, `TextSpan`, a label-painting parameter, or an `Icon` sitting beside such a label) reads
`statusSuccessText`/`statusErrorText`. A wash, fill, border, dot, chart line or sparkline keeps the
raw token." A `CircularProgressIndicator` is none of the listed foreground categories — it is a
stroked arc, the same visual family as the "chart line" and "dot" cases the rule keeps raw. Here the
shared `foreground` local feeds both the CTA label text (a legitimate swap) and the spinner's
`valueColor`:
```dart
final foreground = isRefused ? gw.statusErrorText : gw.textPrimary38;
...
valueColor: AlwaysStoppedAnimation<Color>(foreground),   // graphic, not text
...
color: foreground,                                        // the label -- fine
```
In light mode this repaints the spinner from `#D92D2D` (`statusError`, the fill/graphic-tuned red,
4.8:1) to `#991B1B` (`statusErrorText`, the AA-text-tuned red) — a visible, if minor, color shift on
a non-text graphic. This was a named, deliberate call in 32-04's plan text (not an oversight), and it
doesn't fail any contrast floor (WCAG 1.4.11's 3:1 floor for graphics is still cleared by a wide
margin), so it is not incorrect — but it is an undocumented exception to THE RULE that the census test
cannot catch, because the census only gates *raw* token reads; a graphic that reads the wrong-but-
still-a-status-color token is invisible to it either way.
**Fix:** Either split the spinner onto its own raw-token local (`final spinnerColor = isRefused ? gw.statusError : gw.textPrimary38;`) to keep the graphic/text split the rule states, or — if the shared-color-with-label look is intentional — add a one-line comment at the `foreground` declaration saying the spinner is treated as label-adjacent on purpose, so a future reader doesn't "fix" it into a rule violation the wrong direction.

## Info

### IN-01: The raw-token census locks counts, not categories — a same-file swap between two "raw is fine" reasons goes undetected

**File:** `test/theme/status_text_color_invariant_test.dart`
**Issue:** The census (`_census`) pins an exact per-file *count* of raw `.statusSuccess`/`.statusError`
reads plus a free-text `reason` string. The three gating tests (unclassified/stale/count-drift) only
compare counts, never re-derive or check the `reason` against the code. If a future change in an
already-censused file moved one raw read from, say, a wash to a border while adding a matching
removal elsewhere in the *same file* (net count unchanged), the census would stay green with a now-
inaccurate reason string, and nothing would re-verify that the *specific* remaining raw reads are
still non-text sites. This is an inherent limit of a count-based gate, not a bug in the current
census (I independently re-ran the file's own scan logic against the current tree and it matches
exactly — 25 files, 0 mismatches), and the count-based test does close the actual attack surface this
phase cared about (a foreground silently starting to read the raw, non-AA token). Flagging only
because the review was asked whether this gate can go stale silently, and in this one narrow sense
(reason-string accuracy, not gate correctness) it can.
**Fix:** No action required to ship. If this class of drift matters later, the `reason` field could
be a closed enum (`wash`, `border`, `dot`, `line`, `icon`, `fill`) checked against a lightweight
per-site marker (e.g., a trailing `// raw: wash` comment at each read) rather than free text — but
that is more machinery than a v1 backlog phase needs.

---

_Reviewed: 2026-09-25T14:32:54Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_

## Disposition (orchestrator, 2026-09-25)

- **WR-01 fixed:** doc comment cut to 3 lines, test filename dropped.
- **WR-02 fixed:** plan ids removed from the census test header, doc and group name, and from the parity test's group name. The older `23-01`/`23-03` citations predate this phase and were left.
- **WR-03 accepted:** the CTA spinner shares the label's foreground on purpose. It is part of the label, and the darker text token still clears every floor.
- **IN-01 accepted:** a count-based census is the known ceiling, the same shape as the drawer padding invariant.
