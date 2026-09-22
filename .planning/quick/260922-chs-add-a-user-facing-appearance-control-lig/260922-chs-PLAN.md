---
quick_id: 260922-chs
slug: add-a-user-facing-appearance-control
date: 2026-09-22
mode: quick
branch: appearance-toggle
files_modified:
  - lib/theme/gw_appearance.dart
  - lib/settings/settings_screen.dart
  - test/theme/gw_appearance_preference_test.dart
must_haves:
  truths:
    - A user on a non-dev build can pick Light / Dark / Follow system on /settings and the app re-skins in place.
    - With Follow system chosen, flipping the OS appearance mid-session re-skins the app without a relaunch.
    - An existing user who already persisted 'light' or 'dark' keeps that choice across this change.
  artifacts:
    - lib/theme/gw_appearance.dart carries GWAppearancePreference and setPreference
    - lib/settings/settings_screen.dart carries an Appearance section
    - test/theme/gw_appearance_preference_test.dart
  key_links:
    - GWAppearance stays a ValueNotifier<GWAppearanceMode> of the RESOLVED mode, so getThemeData/isLight and main.dart's ValueListenableBuilder are untouched.
---

# Quick task: a real Appearance control on /settings

`setMode` has only ever been called from two dev screens behind `kDebugMode && kShowDevTools`. On a
normal build a user cannot switch appearance at all. Three states are required: light, dark,
follow-system.

## The two design decisions

**1. Preference and resolved mode are different things.** `GWAppearanceMode` stays two-valued and
keeps meaning *what is painted right now*; a new `GWAppearancePreference { system, light, dark }`
models *what the user asked for*. `isLight`, `getThemeData()`, `main.dart`'s
`ValueListenableBuilder`, the 20 `isLight` readers in `lib/theme/` and both dev call sites then need
no edit. A third case on `GWAppearanceMode` would make all of them ask it an unanswerable question.

**2. The mid-session OS listener is a `WidgetsBindingObserver`, not a `PlatformDispatcher`
callback.** `PlatformDispatcher.onPlatformBrightnessChanged` is a single slot that
`WidgetsBinding` already owns — assigning it clobbers the framework's own handler and breaks
`MediaQuery.platformBrightnessOf` app-wide. `WidgetsBinding.instance.addObserver` is additive.

Rejected: `MaterialApp.themeMode: ThemeMode.system` + `darkTheme:`. The static-getter path
(`GeniusWalletColors`, `GWDecorations`, `GWGradient`, `GWElevation`) reads the singleton globally, so
it needs re-resolving on an OS flip anyway, and two live `ThemeData`s would desync the statics.

**Reuse, not a sixth segmented control.** The control is `GWSelect<GWAppearancePreference>`, already
used three rows down this same screen. It is a `DropdownButtonFormField`: focus-traversable,
Enter/Space operable, named for a screen reader by its `label`. Every token it paints (`textPrimary`
on `surfaceMenu` and on `surfaceElevated`, `textTertiary` disabled, `borderSubtle`,
`brandPrimaryStrong` focus ring) is already pinned at AA in both modes by
`test/theme/theme_contrast_test.dart` and `compute_contrast_test.dart` — so no new contrast test is
owed, which a hand-rolled chip track would have owed for 3 states x 2 modes x 3 interaction states.

<tasks>

<task type="tracer">
  <name>Task 1: pick Light / Dark / Follow system on /settings and the app flips</name>
  <files>lib/theme/gw_appearance.dart, lib/settings/settings_screen.dart</files>
  <action>
In `gw_appearance.dart`: add `enum GWAppearancePreference { system, light, dark }`. Swap the
`foundation.dart` import for `package:flutter/widgets.dart` (it re-exports foundation and brings
`WidgetsBinding`). Give `GWAppearance` a private `_preference` field defaulting to `system` with a
public getter, and a private `_resolve()` returning the concrete `GWAppearanceMode`: for `system`,
`PlatformDispatcher.instance.platformBrightness`; otherwise the matching mode.
Rewrite `load()` to map the saved string — `'light'`/`'dark'` to those preferences (legacy values
keep working unchanged), everything else including `'system'` and a missing key to `system`, which
reproduces today's no-key behaviour exactly — then set `value = _resolve()`.
Add `Future&lt;void&gt; setPreference(GWAppearancePreference pref)`: return early when unchanged,
store it, persist `pref.name` under the existing appearance key in the existing preferences box
constant (so light/dark round-trip to the same two strings as before), then
`final resolved = _resolve();` and — because a preference-only change must still reach listeners —
call `notifyListeners()` when `value` already equals `resolved`, else assign `value = resolved`.
Keep `setMode(GWAppearanceMode)` as a two-line delegation to `setPreference` so both dev call sites
compile untouched. Correct the stale class doc comment (it claims a Preferences sheet that has never
existed) to name the Settings screen, 3 lines max, no plan or phase identifiers.
In `settings_screen.dart`: add a private `_AppearanceControl extends StatelessWidget` at the bottom
of the file — a `ValueListenableBuilder&lt;GWAppearanceMode&gt;` on `GWAppearance.instance` (so a
dev-tools flip keeps it in sync) whose builder ignores the mode and renders
`GWSelect&lt;GWAppearancePreference&gt;` with `label: 'Appearance'`, `value:
GWAppearance.instance.preference`, three items labelled `Follow system`, `Light`, `Dark`, and an
`onChanged` that null-guards then calls `setPreference`. It reaches no further than the singleton.
Loosen `_buildSectionCard`'s `action` to `Widget?` and guard its trailing `Align` with a
collection-`if`, then add an Appearance card as the FIRST child of the screen's Column with
`Icons.brightness_6`, `status: null`, `loading: false`, `action: null`,
`child: const _AppearanceControl()`. Every statement-level `if` you write gets braces with the body
on its own line.
  </action>
  <verify>
    <automated>export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" &amp;&amp; dart format lib &amp;&amp; flutter analyze &amp;&amp; bash tool/check_brace_style.sh &amp;&amp; bash tool/check_raw_colors.sh &amp;&amp; grep -c "GWAppearancePreference" lib/settings/settings_screen.dart &amp;&amp; ! grep -n "Hive\.box" lib/settings/settings_screen.dart</automated>
  </verify>
  <done>`flutter analyze` prints `No issues found!` at exit 0, both shell gates pass, the settings screen names the preference enum and opens no box of its own, and `GWAppearance.isLight` still returns a concrete answer.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Follow system tracks the OS mid-session, with one check behind it</name>
  <files>lib/theme/gw_appearance.dart, test/theme/gw_appearance_preference_test.dart</files>
  <behavior>
    - A persisted `'light'` still loads as the light preference after this change.
    - No persisted key loads as `system` and resolves to the OS brightness.
    - `setPreference(dark)` writes `'dark'`; `setPreference(system)` writes `'system'`; a later `load()` reads each back.
    - Preference `system`: an OS brightness flip changes `value` with no reload.
    - Preference `light`: the same OS flip leaves `value` alone.
  </behavior>
  <action>
Mix `WidgetsBindingObserver` into `GWAppearance` and override `didChangePlatformBrightness()` to
return early unless the preference is `system`, then re-resolve into `value`. Register the observer
from `load()` behind a private `_observing` bool so the second `load()` (the dev token probe calls
it too) does not stack a duplicate; tear it down by overriding `dispose()` to remove the observer
before `super.dispose()` — the singleton is app-lifetime, so in practice only a test disposes it,
and the idempotence guard is what keeps a test shard from accumulating observers.
Write `test/theme/gw_appearance_preference_test.dart`, matching the harness discipline in
`test/account/account_drawer_network_section_test.dart`: `TestWidgetsFlutterBinding.ensureInitialized()`,
then a `setUp` opening the preferences box with `bytes: Uint8List(0)` (hive_ce's in-memory backend —
a disk-backed box hangs) and a `tearDown` that restores the dark default and closes the box.
Drive the OS flip with `binding.platformDispatcher.platformBrightnessTestValue`, cleared via
`clearPlatformBrightnessTestValue` in teardown; its setter fires the binding's own handler, which is
what reaches the observer. Cover all five behaviours above. The file must be LF, not CRLF.
  </action>
  <verify>
    <automated>export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" &amp;&amp; dart format lib test &amp;&amp; flutter analyze &amp;&amp; flutter test &amp;&amp; bash tool/check_brace_style.sh &amp;&amp; git ls-files --eol lib test | grep i/crlf</automated>
  </verify>
  <done>`flutter test` reports at least 1556 passing / 5 skipped / 0 failing (the 1551 baseline plus the new cases), `flutter analyze` is still `No issues found!`, and the CRLF listing still names only `test/components/gw_hoverable_test.dart` and `test/theme/theme_contrast_test.dart`.</done>
</task>

<task type="auto">
  <name>Task 3: close the todo this answers</name>
  <files>.planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md, .planning/todos/pending/2026-07-18-const-widgets-do-not-re-skin-on-live-appearance-toggle.md</files>
  <action>
Append a `## Closed 2026-09-22 (quick 260922-chs)` section to
`2026-07-18-no-user-facing-appearance-toggle.md` — the same shape as
`.planning/todos/completed/2026-07-24-unify-timeframe-segment-component.md` — naming the three
states, the preference-vs-resolved-mode split, and that the verification blocker it escalated to is
lifted: its recipe (stay on the surface under test, flip, confirm it re-skins in place) now runs
from /settings on any build. Then `git mv` the file to `.planning/todos/completed/`.
Leave `2026-07-18-const-widgets-do-not-re-skin-on-live-appearance-toggle.md` OPEN — it still tracks
the deferred GWColors readers — and append only a dated two-line note that its recipe no longer
needs the dev Gallery.
  </action>
  <verify>
    <automated>test -f .planning/todos/completed/2026-07-18-no-user-facing-appearance-toggle.md &amp;&amp; test ! -f .planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md &amp;&amp; test -f .planning/todos/pending/2026-07-18-const-widgets-do-not-re-skin-on-live-appearance-toggle.md</automated>
  </verify>
  <done>The toggle todo is in `completed/` with a dated closing section; the const-staleness todo is still in `pending/` with a dated note.</done>
</task>

</tasks>

## Out of scope

A shared `GWSegmentedControl`, the deferred GWColors readers, the dev sun/moon toggles.
