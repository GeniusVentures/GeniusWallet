---
phase: 32-contrast-and-text-scale-accessibility-pass
verified: 2026-09-25T00:00:00Z
status: passed
score: 3/4 must-haves verified
behavior_unverified: 1
overrides_applied: 0
behavior_unverified_items:
  - truth: "The phone bottom bar clamps textScaler at 221/180 so it never overflows vertically"
    test: "Pump the real MobileOverlay/_MobileTabBar tree (or run the debug app) with an OS/device text scale factor above 221/180 and at 221/180 exactly"
    expected: "No RenderFlex/vertical overflow in the 60px bar slot at or above the clamp; label visually stops growing past ~1.2278x"
    why_human: "No widget test mounts _MobileTabBar (it needs AppBloc, WalletDetailsCubit and a GoRouter — the plan explicitly declined to build that harness). The shipped test only checks the arithmetic (padding+icon+gap+labelLine*ceiling == barHeight to 1e-9) and that the ceiling constant equals 1.2278; it does not pump a widget tree at that scale and assert the absence of an overflow render exception."
human_verification:
  - test: "/settings in Light and Dark: check every switch, on and off, for a visible outline"
    expected: "The enabled switch outline is visibly distinguishable from both the ON and OFF track colors in both modes"
    why_human: "Visual/perceptual judgment; the numeric 3:1 floor is proven by test/theme/enabled_control_contrast_test.dart but 'looks right' is not"
  - test: "View onboarding recovery-phrase word chips and the Banxa disclaimer title in both modes"
    expected: "Both render in Inter, not a fallback font"
    why_human: "Visual font-rendering confirmation beyond the resolved-fontFamily string assertion already automated"
  - test: "Debug build, window narrower than 1024px, raise OS text size to 130% or more: watch the phone bottom bar"
    expected: "Bar labels stop growing at about 1.23x scale; no overflow stripe/exception appears in the 60px slot"
    why_human: "No widget-pump test exercises this at runtime (see behavior_unverified_items above); this is the actual runtime proof"
  - test: "Light mode: dashboard, Markets, a token's detail page and News — check every price-change/timestamp label"
    expected: "Darker, legible green or red text; dark mode looks pixel-identical to before the phase"
    why_human: "Color legibility and before/after visual parity are perceptual judgments"
  - test: "Light mode: receive drawer 'Copied' state, settings debug line, Feedback/logs screen status, a Banxa form error"
    expected: "Each reads as a darker, legible green or red"
    why_human: "Color legibility is a perceptual judgment"
  - test: "Light mode: a swap refusal CTA, a form error, a WalletConnect 'Retry Connect' state, and a route's Price Impact value"
    expected: "Each reads as a legible darker red or green; dark mode looks unchanged"
    why_human: "Color legibility and before/after visual parity are perceptual judgments"
---

# Phase 32: Contrast and text-scale accessibility pass Verification Report

**Phase Goal:** Close four known accessibility defects, in both appearance modes: (1) enabled `GWSwitch` track outline reaches 3:1 against ON/OFF tracks; (2) ~40 `statusSuccess`/`statusError` text call sites move to an AA-safe token, measured per real backdrop; (3) the phone bottom bar clamps `textScaler` at 221/180 (~1.23x) so it never overflows vertically; (4) the five unmapped Material text slots render in Inter.
**Verified:** 2026-09-25
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Enabled `GWSwitch` outline clears 3:1 against ON and OFF tracks, both modes | ✓ VERIFIED | `test/theme/enabled_control_contrast_test.dart` pumps a real `GWSwitch`, reads the Switch's own `trackColor`/`trackOutlineColor` `WidgetStateProperty` resolvers (not a static token read), two-stage alpha-composites over all 4 surfaces × 2 states × 2 modes, asserts ≥3.0. Ran: 2/2 tests pass (both modes). Source: `lib/components/inputs/gw_switch.dart:64-66` returns `gw.borderControlOnBrand` in the enabled branch; `grep -c "borderSubtle"` = 0, `grep -c "gw.borderControl;"` = 1 (disabled branch only), matching plan acceptance criteria exactly. `borderControlOnBrand` wired into `GWColors` constructor/field/both factories/asserts/copyWith and the parity probe (11 occurrences in `gw_colors.dart`). |
| 2 | ~40 `statusSuccess`/`statusError` text sites read an AA-safe token, measured per real backdrop | ✓ VERIFIED | `test/theme/status_text_contrast_test.dart` computes real contrast ratios (`contrastRatio`) of `statusSuccessText`/`statusErrorText` against 4 plain surfaces and 8 wash-composited backdrops (4 alphas × 2 surfaces), both modes and tones — all ≥4.5:1, ran and passed. `test/theme/status_text_color_invariant_test.dart` census-gates every remaining raw `statusSuccess`/`statusError` read in `lib/` outside `lib/theme/` to a reasoned, hand-written list. Independently re-scanned the whole `lib/` tree with the census's own method (strip `//`-only lines, count `\.status(Success|Error)\b`) and got an exact match: 25 files, 50 reads, identical to the census — no unclassified, stale, or drifted reads. Spot-checked wiring at `route_details_card.dart:69` (`valueColor: gw.statusSuccessText` on the "Price Impact" row), `transaction_displays.dart:381` (`gw.statusErrorText` on "Not charged"), `markets_hero_card.dart` (sibling `changeTextColor`/raw `changeColor` split feeds label vs. wash correctly) — all confirm THE RULE (foreground reads `*Text`, wash/border/line/dot stays raw) is followed, not just declared. |
| 3 | Phone bottom bar clamps `textScaler` at 221/180 so it never overflows vertically | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | Code present and wired: `lib/components/overlay/responsive_overlay.dart:110` defines `const double kMobileBarMaxTextScale = 221 / 180;`; `_MobileTabBar.build` (the method whose `Row` renders the labels) wraps its entire returned subtree in `MediaQuery.withClampedTextScaling(maxScaleFactor: kMobileBarMaxTextScale, child: ...)` (same helper AppBar uses). `test/components/mobile_nav_destinations_test.dart` pins the geometry to floating-point precision (`padding+icon+gap+labelLine*ceiling == kMobileBarHeight`, epsilon 1e-9; `kMobileBarMaxTextScale ≈ 1.2278`, epsilon 1e-4) — ran and passed. **No test pumps `_MobileTabBar`/`MobileOverlay` at a real text-scale factor and asserts the absence of a render overflow**; the plan explicitly declined to build that harness (needs `AppBloc`, `WalletDetailsCubit`, a `GoRouter`). The math proves the ceiling is calculated correctly; it does not prove the widget tree actually stops overflowing at runtime. Routed to human verification. |
| 4 | The five unmapped Material text slots (`displaySmall`, `headlineSmall`, `titleSmall`, `labelLarge`, `labelSmall`) render in Inter | ✓ VERIFIED | `test/theme/material_text_slots_test.dart` is genuinely behavioral: it pumps a real `ActionChip` and a real `AlertDialog`, reads the actual rendered `RichText.text.style.fontFamily` (not the style Flutter was asked for), and separately asserts all 15 `TextTheme` slots resolve `fontFamily == 'Inter'`, in both modes. Ran: 8 tests pass (both modes × 4 checks). Source: `lib/theme/genius_wallet_typography.dart:31` defines `sansFamily = 'Inter'`; `lib/theme/theme.dart:83` sets `fontFamily: GeniusWalletTypography.sansFamily` on `ThemeData` (which flows into Material's own unmapped defaults before merging with the app's explicit `textTheme:`); `toMaterialTextTheme()` carries a 3-line comment naming the 5 unmapped slots and why. Mapped-slot sizes unchanged per acceptance criteria. |

**Score:** 3/4 truths verified (1 present, behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/theme/genius_wallet_colors.dart` | `_borderControlOnBrand`: ink 52% light, white 58% dark | ✓ VERIFIED | Present at line 236, `_isLight`-branched |
| `lib/theme/gw_colors.dart` | `GWColors.borderControlOnBrand`, wired like `borderControl` | ✓ VERIFIED | 11 occurrences: constructor, field, both factories, both asserts, `copyWith` |
| `lib/theme/genius_wallet_typography.dart` | `GeniusWalletTypography.sansFamily` | ✓ VERIFIED | Line 31, `'Inter'` |
| `lib/components/overlay/responsive_overlay.dart` | `kMobileBarMaxTextScale` + clamp in `_MobileTabBar.build` | ✓ VERIFIED | Constant at line 110; `MediaQuery.withClampedTextScaling` wraps the build's returned subtree |
| `test/theme/status_text_contrast_test.dart` | the backdrop matrix the sweep relies on | ✓ VERIFIED | 4 plain + 8 wash backdrops × 2 tones × 2 modes, all pass |
| `test/theme/status_text_color_invariant_test.dart` | census of 25 files/50 reads with reasons | ✓ VERIFIED | Independently re-derived, exact match; `group('Raw status-token census', ...)` — no phase/plan IDs (WR-02 fixed) |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `lib/components/inputs/gw_switch.dart` | `GWColors.borderControlOnBrand` | `trackOutlineColor`, enabled branch | ✓ WIRED | Confirmed at gw_switch.dart:65 |
| `lib/theme/theme.dart` | `GeniusWalletTypography.sansFamily` | `ThemeData(fontFamily:)` | ✓ WIRED | Confirmed at theme.dart:83 |
| `_MobileTabBar.build` | `kMobileBarMaxTextScale` | `MediaQuery.withClampedTextScaling` | ✓ WIRED (code) / ⚠️ UNPROVEN (runtime) | Wraps the full label-rendering subtree; no widget-pump test exercises it at scale — see truth 3 |
| price-change/status `Text` widgets | `GWColors.statusSuccessText`/`statusErrorText` | sibling local next to `changeColor`/`tone`/`trend` | ✓ WIRED | Spot-checked across `coin_card_row`, `markets_hero_card`, `route_details_card`, `transaction_displays` |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Switch outline test suite | `flutter test test/theme/enabled_control_contrast_test.dart` | 2/2 pass | ✓ PASS |
| Material text slot test suite | `flutter test test/theme/material_text_slots_test.dart` | 8/8 pass | ✓ PASS |
| Bar clamp geometry test | `flutter test test/components/mobile_nav_destinations_test.dart` | all pass, clamp assertion 1.2278 confirmed | ✓ PASS (geometry only, see truth 3) |
| Status text matrix + census | `flutter test test/theme/status_text_contrast_test.dart test/theme/status_text_color_invariant_test.dart` | all pass | ✓ PASS |
| Independent census re-derivation | `grep`-based scan of `lib/` (excluding `lib/theme/`) for `.statusSuccess`/`.statusError`, non-comment lines | 25 files, 50 reads — exact match to hand-written census | ✓ PASS |
| Full suite regression | `flutter test` | 1787 passed, 5 skipped, 0 failed | ✓ PASS |
| Static analysis | `flutter analyze` | "No issues found!", exit 0 | ✓ PASS |
| Brace style | `bash tool/check_brace_style.sh` | exit 0 | ✓ PASS |

### Requirements Coverage

None — `requirements: []` on all four plans (backlog phase), consistent with the phase's ROADMAP.md entry (`**Requirements**: TBD`, no REQUIREMENTS.md entry for Phase 32). No orphaned requirements found.

### Anti-Patterns Found

None in the 32 files this phase touched. No `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER` debt markers in phase-modified source (one incidental match, `swap_settings_drawer.dart:204`, is prose recalling a pre-existing UI placeholder string, not a debt marker or TODO).

Code review (`32-REVIEW.md`, 38 files, 0 critical / 3 warning / 1 info) found two real process defects, both already remediated per the orchestrator's disposition note appended to that file:
- **WR-01** (doc comment named a test file, ran 4 lines) — fixed in commit `7fb6e2d6`; verified: `kMobileBarMaxTextScale`'s comment is now 3 lines with no test-file reference.
- **WR-02** (phase/plan IDs baked into new test source) — fixed in the same commit; verified: no `32-0\d` strings remain in `status_text_color_invariant_test.dart` or `gw_colors_parity_test.dart`.
- **WR-03** (CTA spinner repaints from the AA-text token rather than the raw fill token) — accepted by the orchestrator as an intentional shared-foreground design choice; still clears WCAG 1.4.11's 3:1 graphic floor by a wide margin. Not a gap.
- **IN-01** (count-based census can't detect a same-file reason-for-raw-read swap with a compensating change) — accepted; same known ceiling as the pre-existing `drawer_padding_invariant_test.dart` pattern. Not a gap.

### Human Verification Required

See frontmatter `human_verification` (6 items, harvested from the `<human-check>` blocks the four plans deliberately deferred to end-of-phase) and `behavior_unverified_items` (1 item — the bar clamp's actual runtime overflow behavior, which no widget test exercises).

### Gaps Summary

No gaps. All four goals have real, substantive, wired implementations with passing automated tests that measure the actual claimed property (contrast ratios via composited resolvers, resolved font families via rendered `RichText`, an exact census re-derived independently, and pinned clamp arithmetic) rather than asserting on hardcoded expectations. The one shortfall is that goal 3's runtime overflow-avoidance was never exercised by a widget-pump test — a known, explicitly-declared limitation (the harness cost was judged not worth it) — plus the phase's own visual walk across both appearance modes, which this project's tooling cannot perform. Both are routed to human verification rather than marked passed.

---

_Verified: 2026-09-25_
_Verifier: Claude (gsd-verifier)_
