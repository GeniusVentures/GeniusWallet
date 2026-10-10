---
quick_id: 261010-jzg
phase: quick-261010-jzg
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [JZG-01, JZG-02, JZG-03]
files_modified: [lib/components/overlay/responsive_overlay.dart, test/components/mobile_overlay_dock_gap_test.dart]
estimate:
  tokens: 45000
  raw_tokens: 45000
  tasks: 2
  confidence: low
must_haves:
  truths:
    - "JZG-01: on the phone shell the page ends at the bar's painted top edge (screen height - kMobileBarHeight - capped bottom inset); no empty surfaceBase strip the height of the dock overhang sits between page and bar."
    - "JZG-02: a tap on the transparent overhang strip beside the dock reaches the page; a tap on the dock's raised half still opens /swap."
    - "JZG-03: pages keep the body MediaQuery they have today (padding.bottom 0), so no SafeArea or list gains padding; with the keyboard up the page still ends at the keyboard top."
  artifacts: [test/components/mobile_overlay_dock_gap_test.dart]
  key_links:
    - "MobileOverlay Scaffold(extendBody: true) -> Scaffold sets body padding.bottom to the bar box height -> _MobileShellBody pads by that minus _kDockOverhang, then removes the padding"
    - "_MobileTabBar's SizedBox height stays the only place the bar height and inset cap are computed; the body derives from it"
---

<objective>
Remove the dead grey band between page content and the phone tab bar. `_MobileTabBar`'s box includes the
26px `_kDockOverhang`, and Scaffold ends the body at the top of that box. After the fix the body runs to
the bar's painted top edge and the Swap dock overlaps the content. Seen by Braian on Android 1080x2400.
</objective>

<context>
@AGENTS.md (braced ifs, widgets not helpers, no plan ids/dates/test names in source comments, doc comment <= 3 lines)
@lib/components/overlay/responsive_overlay.dart: constants 84-117, `_MobileTabBar` 141-241, `MobileOverlay` 636-686
@test/components/desktop_top_bar_text_scale_test.dart: the overlay harness to copy (lines 31-175)
Flutter: FL=/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin (not on PATH); use $FL/flutter and $FL/dart.

Facts checked in the pinned SDK (packages/flutter/lib/src/material/scaffold.dart):
- `extendBody: true` lays the body under the bar and wraps it in a MediaQuery whose padding.bottom is
  max(0, bottom widgets height) (`_BodyBuilder`, ~958-985; documented on `Scaffold.extendBody`). Here that
  height is the bar's box: `_kDockOverhang + kMobileBarHeight + capped inset`.
- When viewInsets.bottom exceeds that height (keyboard up), extendBody is dropped and the injected padding
  is 0 (~1096-1104). The body's own MediaQuery has viewInsets.bottom removed, so the body cannot see the
  keyboard directly.
- The bar slot is hit-tested before the body. The bar's Stack only hits its bottom Positioned and the
  64px dock (the dock's `Center` hits only its child), so taps in the transparent strip fall through.

Deviation from the brief, on purpose: the brief pads the body by `kMobileBarHeight + capped inset`
computed in MobileOverlay. That leaves a 60-80px empty band above the keyboard on /swap and /send, because
the pad stays when Scaffold switches extendBody off. Deriving the pad from Scaffold's injected padding minus
`_kDockOverhang` gives 0 in that case and needs no second copy of the inset cap.

Other consumers checked: only router.dart:160 mounts MobileOverlay; GlobalSwapFabHost is hidden on the phone
shell; the drawer footer shares `kMaxBottomSafeInset` but not the body edge; no test asserts the phone body
height; shell pages (SwapScreen, SendScreen) use SafeArea/SingleChildScrollView that read padding.bottom,
which stays 0. Nothing else changes.
</context>

<tasks>

<task type="tracer" tdd="true">
  <name>Task 1: The phone body runs to the bar's top edge, end to end</name>
  <files>test/components/mobile_overlay_dock_gap_test.dart, lib/components/overlay/responsive_overlay.dart</files>
  <behavior>
    One testWidgets at 390x844, devicePixelRatio 1, view padding and viewPadding bottom 34 (capped to 20):
    - The body probe's rect bottom equals 844 - kMobileBarHeight - kMaxBottomSafeInset = 764 (today 738).
    - tapAt(Offset(20, 754)) increments the probe's tap counter (today 0: that point is the bar's empty strip).
    - With viewInsets bottom 300 the probe's bottom equals 544 (keyboard top, no extra band).
    - With viewInsets reset, tapAt(Offset(195, 751)) (the dock's raised half, above the bar) lands on /swap.
  </behavior>
  <action>
RED. Create the test file. Copy the harness from desktop_top_bar_text_scale_test.dart: the noSuchMethod
fake GeniusApi, a plain AppBloc, WalletDetailsCubit, TransactionsCubit, NetworkProvider in a MultiProvider,
MaterialApp.router with getThemeData(), and its teardown (pump SizedBox.shrink, runAsync(appBloc.close),
close the cubits). Drop fonts, seeding and text scale. Keep the GoRouter in a local. Routes: /dashboard
builds MobileOverlay whose child is a GestureDetector (behavior opaque, onTap increments a counter) around
a keyed SizedBox.expand; /swap builds MobileOverlay around a SizedBox.shrink. Set tester.view physicalSize,
devicePixelRatio, padding and viewPadding (FakeViewPadding(bottom: 34)), viewInsets for the keyboard step,
with an addTearDown reset for each. Advance time with pump/pump(Duration) and keep the total under 3s:
AppBloc polls the fake api every 3s. Open in-memory Hive boxes (desktop test lines 180-185) only if the
pump fails on a missing box. Run it: the first two expectations must fail on today's code. Quote the failure.

GREEN, in responsive_overlay.dart only:
- MobileOverlay's Scaffold gets `extendBody: true` and `body: _MobileShellBody(child: child)`.
- Add a private StatelessWidget `_MobileShellBody` (widget, not a helper method). Its build computes
  pad = math.max(0.0, MediaQuery.paddingOf(context).bottom - _kDockOverhang) and returns
  MediaQuery.removePadding(context: context, removeBottom: true, child: Padding(bottom: pad, child:
  Stack(children: [child]))). Add `import 'dart:math' as math;`.
- Doc comment, 3 lines max, saying why: under extendBody Scaffold reports the bar's whole box (dock
  overhang included) as bottom padding, and 0 while the keyboard covers the bar; removing it keeps pages'
  SafeArea and list padding as before.
- Move the existing single-child-Stack comment into the new widget, shortened to its constraint, without
  the plan id it cites today.
- Leave `_MobileTabBar`, the constants, and the inset cap untouched. No new colours or literals.
  </action>
  <verify>
    <automated>$FL/flutter test test/components/mobile_overlay_dock_gap_test.dart (passes); grep -c "extendBody: true" lib/components/overlay/responsive_overlay.dart prints 1</automated>
  </verify>
  <done>The test failed on the old layout for the stated reason and passes now; the body ends at y=764,
  the strip tap reaches the page, the keyboard case ends at 544, and the dock still opens /swap.</done>
</task>

<task type="auto">
  <name>Task 2: Repo gates and the commit</name>
  <files>lib/components/overlay/responsive_overlay.dart, test/components/mobile_overlay_dock_gap_test.dart</files>
  <action>
Run, quoting real output: $FL/dart format on both files; $FL/flutter analyze, then echo $? and require 0
(it can exit 1 while the tail looks clean); the full $FL/flutter test suite, expecting 2549 passed / 6
skipped (baseline 2548/6 plus this test; any other change in counts gets explained, not assumed to be a
neighbour); bash tool/check_brace_style.sh; bash tool/check_raw_colors.sh. Stage both files and check
`git ls-files --eol` shows i/lf for each (a CRLF file fails the CI brace check). Confirm `git config
user.email` is braianwegmann@hotmail.com, matching this branch's earlier commits. Commit on
fix/mobile-dock-gap as "fix(nav): let phone pages run under the Swap dock". No Co-Authored-By trailer,
no footer. Do not push and do not open a PR.
  </action>
  <verify>
    <automated>$FL/flutter analyze; echo $? (0) and $FL/flutter test (2549 passed, 6 skipped) and bash tool/check_brace_style.sh and bash tool/check_raw_colors.sh</automated>
  </verify>
  <done>All gates pass with quoted output; one commit on fix/mobile-dock-gap with LF files and no attribution.</done>
</task>

</tasks>

<threat_model>
| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-jzg-01 | Spoofing (UI redress) | dock overhang over page content | low | accept | Layout only; no new input, data or trust boundary. The dock covers 64x26px of the page's bottom centre by design. |
</threat_model>

<verification>
Task 1 test green; Task 2 gates green. Walk note for Braian (Android 1080x2400): on /dashboard, /swap and
/send there is no grey band above the bar, the dock sits over the content, and no button's label hides
under the dock.
</verification>

<success_criteria>
JZG-01..03 hold, each asserted by the one new test; the suite is 2549/6; one commit, unpushed.
</success_criteria>

<output>
Create `.planning/quick/261010-jzg-mobile-swap-dock-leaves-a-grey-band-abov/261010-jzg-SUMMARY.md` (40 lines max).
</output>
