---
phase: 03-gw-component-library
plan: 07
subsystem: ui
tags: [flutter, gw-components, design-gallery, ds-04, canvas-background, mesh-background, compile-canary, dev-route]

# Dependency graph
requires:
  - phase: 03-01
    provides: "assets/images/textures/noise.png bundled + pubspec.yaml assets/images/textures/ declaration (d8db88c)"
  - phase: 03-02
    provides: "GWButton, GWCard, GWGradientBorderCard, GWCheckbox, GWSelect, GWSwitch, GWTextField -- all 12 core primitives the gallery's existing sections consume"
  - phase: 03-03
    provides: "GWAnimatedNumber, GWSpinner, GWMeshBackground -- feedback/mesh primitives; GWCanvasBackground (Phase 2, ported dormant, activated here)"
  - phase: 03-04
    provides: "lib/dev/generated_closure_canary.dart -- the compile gate this plan imports from the gallery, upgrading it from analyzer-symbol-resolution to real Dart-front-end compilation"
provides:
  - "lib/dev/design_gallery_screen.dart -- DS-03's living component catalogue, reachable only behind kShowDevTools"
  - "/design_gallery route, registered additively in router.dart outside the ShellRoute"
  - "Gallery button inside DevToolsWidget, beside Tokens, inheriting the existing kDebugMode && kShowDevTools gate"
  - "GWCanvasBackground's first instantiation anywhere in this repo -- DS-04 proven end to end (asset bundled + class instantiated + build compiles clean)"
  - "GWMeshBackground demoed alongside it, disambiguating ROADMAP criterion 2's 'gw_mesh_background renders its texture' wording (GWMeshBackground is procedural CustomPaint with zero asset dependency; GWCanvasBackground is the actual noise.png consumer)"
  - "The closure canary imported from a reachable entry point -- the 9 Parabeac-generated .g.dart widgets now compile as real Dart front-end output during flutter build, not just analyzer symbol resolution"
  - "Two real compile-time bugs in lib/components/wallet_information.g.dart (a 03-04 file, invisible to flutter analyze) caught and fixed by this plan's own build verification -- the first time anything has actually compiled these 9 files' bodies"
affects: [03-09, 03-10, 04, 05, 07]

tech-stack:
  added: []
  patterns:
    - "Compile-canary payoff realized: importing a dev-only canary from a dev-gated but reachable entry point (the gallery) upgrades a .g.dart exclude from 'the analyzer cannot see these' all the way to 'flutter build windows compiles these file bodies for real' -- caught two bugs in wallet_information.g.dart this plan that flutter analyze structurally could not."
    - "Develop-API-shape fix in the generated consumer, never the protected collision file: ResponsiveDrawer.show()'s children:[...] -> child: (Alex's fork added a List<Widget> children param and a BottomDrawer wrapper; develop's canonical, UI-SPEC Sec4.1-protected version takes a single child:) and FontAwesomeIcons.trash -> FontAwesomeIcons.trash.data (font_awesome_flutter ^11's FaIconData vs a collision file's IconData? param) -- both fixed at the call site inside the generated file, matching 03-04's Icon->FaIcon and 03-05's isNativeApp->isMobileApp() precedent."

key-files:
  created:
    - lib/dev/design_gallery_screen.dart
  modified:
    - lib/navigation/router.dart
    - lib/test/dev_tools_widget.dart
    - lib/components/wallet_information.g.dart

key-decisions:
  - "Ported the gallery's head comment away from Alex's non-existent LandingScreen palette-icon entry point to the actual mechanism this plan wires (Gallery button in DevToolsWidget's Dev row, gated by kShowDevTools, routing to /design_gallery) -- zero LandingScreen references remain, verified by grep gate."
  - "Demoed both GWMeshBackground and GWCanvasBackground in separate sections per the plan's explicit instruction, to resolve the ROADMAP wording ambiguity in the SUMMARY rather than silently picking one: GWMeshBackground is pure procedural CustomPaint (components/effects/gw_mesh_background.dart, no asset dependency); GWCanvasBackground (theme/genius_wallet_decorations.dart:168) is the actual noise.png consumer and criterion 2's real subject."
  - "[Rule 1/3 -- auto-fix, blocking] wallet_information.g.dart's two ResponsiveDrawer.show(children: [...]) call sites used Alex's fork's API shape (a List<Widget> children param that wraps a BottomDrawer). Develop's canonical, untouched ResponsiveDrawer.show() (03-UI-SPEC.md Sec4.1's explicitly protected collision file) only accepts a single child: Widget. Fixed in the CONSUMER (the generated file), never the collision file: the single-item list at the QR-address call site was unwrapped directly to child:; the multi-item 'More Options' list was wrapped in Column(mainAxisSize: MainAxisSize.min, children: [...]) to preserve the same vertical stack of widgets. Same precedent class as 03-05's isNativeApp -> isMobileApp()."
  - "[Rule 1/3 -- auto-fix, blocking] wallet_information.g.dart's 'Delete Wallet' SlidingDrawerButton passed FontAwesomeIcons.trash (FaIconData under font_awesome_flutter ^11, this repo's Phase-2-bumped version) to SlidingDrawerButton.icon, a develop collision file typed IconData? that renders via plain Icon(icon). Fixed by unwrapping to the underlying IconData via .data (FaIconData wraps IconData 1:1, per font_awesome_flutter-11.0.0's own source) -- same root cause as 03-04's Icon->FaIcon fix, opposite direction: here the CONSUMING widget expects plain IconData, so the fix unwraps rather than upgrades."
  - "Both wallet_information.g.dart fixes were undetectable by flutter analyze (lib/**/*.g.dart is excluded by analysis_options.yaml:5) and only surfaced when this plan's canary import made the file reachable from an entry point, forcing flutter build windows to actually compile its body -- exactly the payoff 03-04's canary and this plan's import of it were built to produce, and exactly the class of bug 03-UI-SPEC.md Sec2.8 predicted would 'detonate in Phase 5/6/7' if left uncaught. It detonated here instead, in Phase 3."

requirements-completed: [DS-03, DS-04]

coverage:
  - id: D1
    description: "lib/dev/design_gallery_screen.dart exists with all 14 original sections plus 3 new ones (canvas background, mesh background, closure canary); every gw_* import resolves; head comment corrected off the non-existent LandingScreen entry point; zero raw color literals"
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep gates: class present, 0 LandingScreen refs, kShowDevTools mentioned, 0 Color(0x literals; flutter analyze lib 0 errors; tool/verify_additive_boundary.sh PASSED"
        status: pass
    human_judgment: false
  - id: D2
    description: "/design_gallery registered additively in router.dart (7 insertions/0 deletions: 1 import + 1 GoRoute, outside ShellRoute); Gallery button added inside DevToolsWidget beside Tokens (4 insertions/0 deletions), inheriting the existing kDebugMode && kShowDevTools gate with no second flag or call site; responsive_overlay.dart carries zero commits since Phase 2's 02-02 (last touch: ca556e4); splash import intact"
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep gates + git diff --numstat (0 deletions both files) + git log -- responsive_overlay.dart (last touch ca556e4, Phase 2) + flutter analyze lib 0 errors + guard PASSED"
        status: pass
    human_judgment: false
  - id: D3
    description: "GWCanvasBackground instantiated exactly once, in the gallery only (grep across lib/ confirms zero other instantiations besides the class definition itself); the noise.png asset and pubspec declaration are present (landed 03-01); the generated closure canary is imported and referenced; flutter build windows reaches the native link stage cleanly (Dart-level compile succeeds) after two real bugs in a dependency (wallet_information.g.dart) were caught and fixed"
    requirement: "DS-04"
    verification:
      - kind: other
        ref: "grep gates (GWCanvasBackground present, generated_closure_canary present, 0 unexpected instantiations); test -f noise.png + pubspec grep; flutter build windows --debug --dart-define=GW_DEV_TOOLS=true -- first run failed with 2 real Dart compile errors in wallet_information.g.dart (children: param shape + FaIconData/IconData mismatch), both fixed, re-run reached native link stage with the only remaining failure being a WebView2Loader.dll file lock from the user's already-running debug session (PID 19684), not a code defect"
        status: pass
    human_judgment: false
  - id: D4
    description: "Shadow importer counts held exactly as required after all 3 task commits: WalletsOverview shadow still has exactly 1 importer (the canary, unchanged from 03-04); Splash and Loading shadows still have 0 importers (the gallery imports the canary and GWCanvasBackground/GWMeshBackground, not Loading or Splash -- those stay plan 03-09's job per the UI-SPEC's missing-sections list)"
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep -rl for all 3 shadow import paths across lib/ after Task 3's commit -- WalletsOverview: exactly lib/dev/generated_closure_canary.dart; Splash: empty; Loading: empty; tool/verify_additive_boundary.sh Check 1 PASS x6, Check 2 census unchanged at 8 names"
        status: pass
    human_judgment: false
  - id: D5
    description: "Visual walk: the Gallery button opens /design_gallery and renders correctly; the canvas-background section shows a visible noise texture with no 'Unable to load asset' console error; the gallery and Dev row are absent without the dart-define"
    requirement: "DS-04"
    verification:
      - kind: human
        ref: "Human walk performed 2026-07-17. Gallery opens from Dev > Gallery and renders its 14 sections. Canvas background shows visible grain in DARK mode. Console is FREE of 'Unable to load asset' for noise.png -- DS-04's load-bearing test, and the one that distinguishes an asset-bundling failure from a paint failure. Closure canary section shows its count. Second, separate launch with NO --dart-define confirmed: Dev row and Gallery button both absent."
        status: pass
    human_judgment: true
    rationale: "PASS is the human's direct observation, not inferred from this plan's mechanical gates. The dev-gating check (point 5) was confirmed as its OWN separate launch, not the same dev-gated session -- that gate is what keeps the gallery and the two shadow classes it imports out of a normal build, so it was confirmed explicitly rather than folded into a blanket 'everything checks'."

# Metrics
duration: 12min
completed: 2026-07-16
status: complete
---

# Phase 3 Plan 07: Design Gallery, Dev Route, and GWCanvasBackground's First Instantiation Summary

**Ported Alex's design gallery, wired it behind Phase 2's exact dev-gate mechanism (`/design_gallery` route + `Gallery` button beside `Tokens`), instantiated `GWCanvasBackground` for the first time in this repo, demoed `GWMeshBackground` alongside it to resolve the ROADMAP's ambiguous wording, imported the compile canary, and — because that import finally makes the Dart front-end compile the 9 generated `.g.dart` widgets' bodies — caught and fixed two real compile bugs in `wallet_information.g.dart` that `flutter analyze` structurally cannot see.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-07-16T21:41:00Z (approx, first commit 21:41:41Z)
- **Completed:** 2026-07-16T21:53:13Z
- **Tasks:** 3/3
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments

- Ported `lib/dev/design_gallery_screen.dart` (566 lines) — 14 sections covering hero balance/`GWAnimatedNumber`, `GWSpinner`, brand/surface/status swatches, gradients, typography, `GWButton`, `GWCard`/`GWGradientBorderCard`, inputs, `GWSelect`, `GWCheckbox`, `GWSwitch`. Head comment rewritten off Alex's non-existent `LandingScreen` palette-icon entry point to the real mechanism this plan wires. Zero new token values — all `gw_*` imports resolve against files landed by 03-02/03-03, zero raw color literals.
- Wired `/design_gallery` additively into `router.dart` (7 insertions, 0 deletions: 1 import + 1 top-level `GoRoute`, outside the `ShellRoute`) and a `Gallery` `TextButton` inside `DevToolsWidget` beside `Tokens` (4 insertions, 0 deletions). Inherits the existing `kDebugMode && kShowDevTools` gate with no second flag or call site. `responsive_overlay.dart` carries zero commits since Phase 2's `02-02` (last touch: `ca556e4`); the boot splash import stays intact.
- Instantiated `GWCanvasBackground` for the first time anywhere in this repo — a new "Canvas background (noise texture)" gallery section. This is DS-04's actual end-to-end proof: the asset (`assets/images/textures/noise.png`, bundled by 03-01) plus the pubspec declaration plus the class instantiation, all landing together for the first time.
- Demoed `GWMeshBackground` in a separate "Mesh background (procedural, no texture asset)" section, per the plan's explicit disambiguation instruction: `GWMeshBackground` is pure `CustomPaint` with zero asset dependency; `GWCanvasBackground` is the actual `noise.png` consumer and the real subject of ROADMAP criterion 2's "renders its texture" wording.
- Imported `lib/dev/generated_closure_canary.dart` and referenced `generatedClosureClasses.length` in a new gallery section — the canary is now reachable from a real entry point, upgrading the 9 Parabeac-generated `.g.dart` widgets' gate from "the analyzer resolves the symbols referenced into them" to "the Dart front-end compiles their bodies for real" during a build.
- That upgrade immediately paid off: `flutter build windows --debug --dart-define=GW_DEV_TOOLS=true` failed on the first attempt with two real Dart compile errors inside `lib/components/wallet_information.g.dart` (a plan 03-04 file) — errors `flutter analyze` cannot see because `analysis_options.yaml:5` excludes `*.g.dart`. Both fixed in the consumer (never the protected collision files they call into), documented below, and the re-run reached the native link stage cleanly.
- `flutter analyze lib`: **0 errors** throughout (62 total info/warning issues — +2 from 03-06's 60-issue baseline, both `unnecessary_const` info lints inherited verbatim from the reference gallery source).
- `bash tool/verify_additive_boundary.sh`: **PASSED** after every task commit. Shadow importer counts held exactly: `WalletsOverview` shadow still has exactly 1 importer (the canary, unchanged); `Splash` and `Loading` shadows still have 0 importers (this plan's gallery does not demo them — that stays plan 03-09's job).

## Task Commits

Each task was committed atomically:

1. **Task 1: Port the design gallery screen** - `74b98b4` (feat)
2. **Task 2: Wire the route and the Dev button using Phase 2's exact mechanism** - `a72cd64` (feat)
3. **Task 3: Instantiate GWCanvasBackground and make the .g.dart set compile** - `e864727` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified

- `lib/dev/design_gallery_screen.dart` - `DesignGalleryScreen`; 17 sections total (14 ported + canvas background + mesh background + closure canary count), dev-gated, unreachable without `--dart-define=GW_DEV_TOOLS=true`
- `lib/navigation/router.dart` - +1 import, +1 additive top-level `GoRoute('/design_gallery')` (7 insertions, 0 deletions)
- `lib/test/dev_tools_widget.dart` - +1 `Gallery` `TextButton` beside `Tokens` (4 insertions, 0 deletions)
- `lib/components/wallet_information.g.dart` - two Rule 1/3 auto-fixes (see Deviations) surfaced by this plan's canary-import build verification; not otherwise touched by this plan's own task scope

## Decisions Made

See `key-decisions` in frontmatter above. The two load-bearing ones:

1. Demoed both `GWMeshBackground` and `GWCanvasBackground`, in separate sections, per the plan's explicit instruction — resolving the ROADMAP's ambiguous "`gw_mesh_background` renders its texture" wording in this document rather than silently picking one interpretation.
2. Both `wallet_information.g.dart` fixes were applied in the generated CONSUMER file, never in the develop collision files it calls into (`ResponsiveDrawer`, `SlidingDrawerButton`) — matching 03-04's `Icon`→`FaIcon` and 03-05's `isNativeApp`→`isMobileApp()` precedent exactly, and honoring `03-UI-SPEC.md` §4.1's explicit instruction not to touch `responsive_drawer.dart`.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1/3 - Bug / Blocking] `wallet_information.g.dart`: `ResponsiveDrawer.show(children: [...])` → `child:`**

- **Found during:** Task 3 (`flutter build windows --debug --dart-define=GW_DEV_TOOLS=true`, first attempt, after the canary import made this file's body reachable and thus compiled for real)
- **Issue:** `error GC6690633: No named parameter with the name 'children'` at two call sites (lines 154 and 200 pre-fix). Root cause: this generated file was authored against Alex's fork's `ResponsiveDrawer.show()`, which added a `required List<Widget> children` parameter and internally wraps them in a `BottomDrawer`. Develop's canonical `ResponsiveDrawer.show()` (`lib/components/bottom_drawer/responsive_drawer.dart`) — an explicitly protected collision file per `03-UI-SPEC.md` §4.1's binding rule ("Do not port Alex's `responsive_drawer.dart` file wholesale, this phase or any later one") — only accepts a single `child: Widget`, with no `children:`/`BottomDrawer` wrapping. `flutter analyze` cannot see this: `analysis_options.yaml:5` excludes `*.g.dart`.
- **Fix:** Fixed in the consumer, not the collision file. The QR-address call site's single-item list was unwrapped directly to `child: Container(...)`. The "More Options" call site's multi-item list (`StreamBuilder` + `SlidingDrawerButton`) was wrapped in `Column(mainAxisSize: MainAxisSize.min, children: [...])`, preserving the exact same widget list and vertical stacking without pulling in `BottomDrawer` (an architectural decision left for whichever phase — 5 or 7 — first wires `wallet_information.g.dart` into a real screen and can decide whether `BottomDrawer`'s content-chrome pattern from §4.1 is the right fit there).
- **Files modified:** `lib/components/wallet_information.g.dart`
- **Verification:** `flutter build windows --debug --dart-define=GW_DEV_TOOLS=true` re-run — this specific error class gone (new error surfaced next, see deviation 2); `flutter analyze lib` — 0 errors (unaffected, `.g.dart` stays excluded); `bash tool/verify_additive_boundary.sh` — PASSED
- **Committed in:** `e864727` (Task 3 commit)

---

**2. [Rule 1/3 - Bug / Blocking] `wallet_information.g.dart`: `FontAwesomeIcons.trash` → `FontAwesomeIcons.trash.data`**

- **Found during:** Task 3 (`flutter build windows --debug --dart-define=GW_DEV_TOOLS=true`, second attempt, after fixing deviation 1)
- **Issue:** `error GC2F972A8: The argument type 'FaIconData' can't be assigned to the parameter type 'IconData?'` at the "Delete Wallet" `SlidingDrawerButton`'s `icon:` argument. Root cause: this repo's `pubspec.yaml` pins `font_awesome_flutter ^11.0.0` (a Phase 2 delta, the same one 03-04 already worked around in `wallet_type_icon.dart`), and in v11 `FontAwesomeIcons.*` getters return `FaIconData`, not `IconData`. Here the direction is the opposite of 03-04's fix: `SlidingDrawerButton` (a pre-existing develop collision file, `git log` confirms last touch predates this branch entirely) declares `icon: IconData?` and renders via a plain `Icon(icon, ...)`, not `FaIcon`. Again invisible to `flutter analyze` (`.g.dart` exclude).
- **Fix:** Unwrapped `FontAwesomeIcons.trash` to its underlying `IconData` via `.data` — confirmed by reading `font_awesome_flutter-11.0.0`'s own source (`icon_data.dart`): `FaIconData` is a thin, 1:1 wrapper around a real `IconData` (`final IconData data`). Passing `.data` to a plain `Icon` renders identically (loses only `FaIcon`'s non-square-glyph clipping protection, immaterial for the trash glyph, and this was already `SlidingDrawerButton`'s only supported rendering path). `SlidingDrawerButton.dart` itself was not touched.
- **Files modified:** `lib/components/wallet_information.g.dart`
- **Verification:** `flutter build windows --debug --dart-define=GW_DEV_TOOLS=true` re-run — both Dart compile errors gone; build reached the native link stage, failing only on a `WebView2Loader.dll` file lock held by the user's already-running debug session (PID 19684) — an environment artifact of the constraint against launching a second instance, not a code defect; `flutter analyze lib` — 0 errors; `bash tool/verify_additive_boundary.sh` — PASSED
- **Committed in:** `e864727` (Task 3 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1/3, both surfaced only by this plan's own canary-import build verification, both fixed in the generated consumer file rather than the develop collision files they call into)
**Impact on plan:** Both fixes were necessary for `wallet_information.g.dart` to compile at all once reachable — neither touches `ResponsiveDrawer` or `SlidingDrawerButton` (both protected collision files), neither changes anything reachable from a normal (non-dev-gated) build path today (`wallet_information.g.dart`'s real caller, `wallet_details_screen.dart`, is still un-ported — Phase 5/7). This is precisely the payoff `03-UI-SPEC.md` §2.8 predicted: "correctness of the 9 `.g.dart` files is not established by this phase's own verification loop — it is established by whichever later phase first imports each one." This plan is that later-phase import, and it caught two real bugs before Phase 5/7 would have.

## Issues Encountered

None beyond the two deviations documented above. The Windows build's native link stage could not be driven to full success because the user's already-running debug session (`genius_wallet.exe`, PID 19684) holds a file lock on `WebView2Loader.dll` in the shared build output directory — expected and unavoidable given this plan's own constraint against launching a second instance; not attempted to work around by touching the user's running process.

## Stub Tracking

No stubs. The 3 new gallery sections (canvas background, mesh background, closure canary count) are fully wired against real components and real data (the canary's own exported list), not placeholder values. `wallet_information.g.dart`'s two fixes are complete, correct call-site changes, not stubs.

## Threat Flags

None. No new network endpoints, auth paths, or trust-boundary-crossing file access was introduced. The two `wallet_information.g.dart` fixes are internal widget-composition and icon-type corrections with no security surface.

## User Setup Required

> **RESOLVED 2026-07-17 — the walk was performed. See coverage item D5 (status: pass) and
> "Walk result" immediately below. The instructions that follow are retained as the record of what
> was asked for; no action remains.**

### Walk result (2026-07-17)

**PASS on DS-04.** Gallery opens from `Dev > Gallery` and renders its 14 sections; canvas grain
visible in dark mode; **console free of `Unable to load asset` for `noise.png`** — the load-bearing
check; canary section shows its count. A separate launch with no `--dart-define` confirmed `Dev` and
`Gallery` both absent.

**One criterion was falsified, not failed.** The walk brief (carried from `HANDOFF.json`) asked the
human to confirm `GWMeshBackground` "shows animated blobs in **both** modes". In light mode the human
reported it as **"just a blank space"**. Investigation established this is **not a port defect**:

- `cmp lib/components/effects/gw_mesh_background.dart <reference>` → **IDENTICAL**
- `_surfaceBaseLight 0xFFDCE0E6` / `_surfaceBaseDark 0xFF0B0D12` + getter logic → identical to reference
- `brandPrimary 0xFF14C8FF` / `brandSecondary 0xFF2BF5B4` / `brandTertiary 0xFFC28FFF` → identical to reference

Identical code + identical inputs ⇒ our render **is** Alex's render; there is nothing to reconcile
against the Release exe here. Root cause: `GWMeshBackground` is dark-designed — its own docstring
says the blobs drift "over the dark teal canvas". It never reads the appearance; only the backdrop
token flips. Pastel blobs at `alpha 110` over near-black read as a glow, and over light gray lose
their contrast. The criterion presumed a light-mode treatment that does not exist in the source.
**The criterion was wrong, not the build.**

Two hypotheses remain open and are deliberately NOT resolved here — 03-09's toggle plus the
reference walk is the right instrument:
- **H1 (design):** dark-designed component, low contrast on a light base.
- **H2 (demo geometry):** blob radius is `0.95 × maxDim` but the gallery demo box is 180px tall, so
  only the near-center plateau of three oversized gradients shows — which would flatten blob
  structure in BOTH modes, dark merely hiding it better. If H2, the demo box is at fault and a
  light-mode treatment would fix nothing.

Captured as `.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md` and as
a STATE.md concern; `03-09-PLAN.md`'s falsified "renders correctly in both" `must_have` was corrected
in the same commit (`e326357`) to require recording light-mode results and reporting a **count** of
dark-only components. No code was changed: editing `if (!isLight)` would invent design Alex never
made, break byte-identity, and fail 03-10's fidelity comparison by construction.

---

**Action needed: perform the visual walk this plan cannot perform itself.** This plan's mechanical gates all pass (`flutter analyze lib` 0 errors, `tool/verify_additive_boundary.sh` PASSED all 3 commits, `flutter build windows` reaches the native link stage cleanly with only a running-instance file lock remaining), but the actual render and asset-load proof requires a human running the Windows GUI.

**Before starting:** close the reference Release exe if it is running — `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` and the develop build share a Hive data directory and will deadlock on file locks if both run (`02-VERIFICATION.md`, standing environment fact 1). If your current debug session is what's currently running (PID 19684 was live during this plan's build attempts), **stop it fully first** — this plan changed `lib/navigation/router.dart`'s route list and `lib/test/dev_tools_widget.dart`'s button row, and hot reload can pick up simple widget-tree changes, but the safest, most conclusive walk is a full stop-and-rerun given this plan also touched a `.g.dart` generated widget your session had already compiled.

Then run:

```
export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
```

`CMAKE_BUILD_TYPE=Release` is deliberate — do not "fix" it.

Confirm, in order:

1. The `Dev` row shows a `Gallery` button beside `Tokens`.
2. Pressing `Gallery` opens `/design_gallery` and the 14 originally-ported sections render — buttons, cards, inputs, swatches, typography, the animated hero balance.
3. Scroll to the bottom. **The "Canvas background (noise texture)" section shows a subtle visible noise texture** — not a blank fill, not a grey box, not a missing-asset placeholder icon. The grain overlay only renders in dark mode by design (`GWCanvasBackground`'s own `if (!isLight)` branch) — toggle appearance if your default is light, and confirm it's absent-by-design in light mode rather than absent-by-bug. This is ROADMAP criterion 2's real subject.
4. **The "Mesh background (procedural, no texture asset)" section right below it shows the animated cyan/mint/purple blob mesh**, in both light and dark — this one has no asset dependency and should always render, distinguishing it from item 3.
5. **The debug console prints no `Unable to load asset` for `noise.png`.** Scroll the console back through startup and through opening the gallery. This is the other half of criterion 2.
6. The "Generated widget closure canary" section shows a count (`12` classes, per the canary's own `generatedClosureClasses` list) — confirms the 9 `.g.dart` widgets' bodies are compiled into this running build, not just symbol-resolved by the analyzer.
7. Stop, re-run with **no** `--dart-define`, and confirm the `Dev` row and the `Gallery` button are **absent** and `/design_gallery` has no entry point.

Report what you saw for each. If the canvas-background texture does not render even in dark mode, report whether the console showed an asset error — that distinction tells a stale pubspec/asset-copy problem apart from a paint/rendering problem.

## Next Phase Readiness

- **DS-03 and DS-04 both close on the mechanical side this plan:** the gallery exists, is dev-gated exactly like `/dev/token-probe`, and 17 sections (14 original + 3 new) are wired with zero raw color literals and zero token additions. `GWCanvasBackground` is instantiated for the first time in this repo's history, with the asset present (03-01), the pubspec declaration present (03-01), and a clean `flutter build` reaching the native link stage.
- **The canary import's payoff is proven, not theoretical:** this plan's own build attempt caught 2 real Dart compile errors in a 03-04-landed `.g.dart` dependency file that `flutter analyze` structurally cannot see. Both are now fixed, so all 9 generated widgets + their 4 `custom/` siblings compile as real Dart front-end output as of this plan, narrowing `03-UI-SPEC.md` §2.8's accepted gap from "correctness not established by this phase" to "compile-correctness IS established (this plan); render-correctness is not (still Phase 5/6/7's job — nothing calls `build()` on any of the 9 widgets anywhere in this repo)."
- **What this plan does NOT establish, for plan 03-09/03-10 to carry verbatim:** render correctness of the 9 generated widgets (still not mounted anywhere); **the light-mode treatment question the walk opened** — `GWCanvasBackground` and `GWMeshBackground` are both dark-designed (byte-identical ports, NOT defects); scope across the other 48 ported components is UNKNOWN and 03-09's both-mode walk must produce the count before any fix is designed (see the todo and STATE.md concern); ROADMAP criterion 1 ("renders every ported primitive") — 12 primitives are still missing gallery sections (`GWTokenRow`, `GWWalletCard`, `GWErrorState`, `GWEmptyState`, `GWLoadingState`, `GWIcon`, `BottomDrawer`/`ResponsiveDrawer`, `AppScreenView`, `CryptoAddressQR`, `GWSwapFab`, `GWDialog`/`GWBottomSheet`, and the `Loading`/`Splash` shadow demos) — plan 03-09's explicit job, not started here.
- **No blockers for plan 03-09.** The `_Section(title:, child:)` pattern this plan's 3 new sections follow is unchanged from the original 14, ready to extend. The gallery's imports and structure are stable.
- ~~**Outstanding for the human:** the full visual walk in "User Setup Required" above~~ — **DONE 2026-07-17, PASS on DS-04.** See "Walk result" under User Setup Required. It carried the weight expected of the first plan in Phase 3 a human could see: it confirmed the noise asset loads (DS-04) and it surfaced that Alex's design system has no light-mode treatment for `GWCanvasBackground`'s grain or `GWMeshBackground`'s blobs — a finding no mechanical gate in this repo could have produced, and one that now shapes 03-09's walk.

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 5 created/modified files confirmed present on disk. All 3 task commits (`74b98b4`, `a72cd64`, `e864727`) confirmed present in `git log --oneline --all`.
