---
phase: 03-gw-component-library
verified: 2026-07-17T13:47:12Z
status: passed
score: 6/6 criteria observed — 3 PASS (2, 4, 5), 3 PARTIAL with accepted gaps (1, 3, 6); 0 OUTSTANDING
behavior_unverified: 3
behavior_unverified_items:
  - truth: "Alex's ported components render correctly in LIGHT appearance"
    test: "Wire the appearance-aware theme.dart (Phase 4), then re-walk /design_gallery in both modes"
    expected: "Text/icon colors flip with appearance; then and only then is the dark-only COUNT derivable"
    why_human: "develop's theme.dart is ThemeData(brightness: Brightness.dark) hardcoded with no textTheme wiring, and GeniusWalletTypography's styles carry no color — every Text inherits white unconditionally. Alex's components correctly delegate color to a theme this milestone has not ported yet (Phase 2 deferred it; UI-SPEC 1.1 excludes theme.dart wholesale). Any count taken before Phase 4 measures OUR missing theme, not HIS design. NOT a port defect: every implicated component is cmp-verified byte-identical to the reference."
  - truth: "The 'Screen wrappers' gallery section renders AppScreenView"
    test: "Open /design_gallery, scroll to 'Screen wrappers', in BOTH appearance modes"
    expected: "AppScreenView's body text and footer slot render inside the 220px box"
    why_human: "Reported blank in BOTH modes by the 2026-07-17 walk. Light-mode blankness is explained (bodySm carries no color -> white text on the light surfaceBase). DARK-mode blankness is NOT explained and no root cause is established — app_screen_view.dart is byte-identical to the reference, so it is not a port defect. Needs a real repro; no hypothesis is recorded as fact."
  - truth: "The disabled GWCheckbox is visible in dark appearance"
    test: "Open /design_gallery, 'Checkbox' section, dark mode, inspect the 'Disabled checkbox' row"
    expected: "The disabled control is visibly distinguishable from the background"
    why_human: "Reported invisible in dark by the 2026-07-17 walk. GeniusWalletColors.btnDisabled is const Color.fromRGBO(188,188,188,1) and not appearance-aware, but its role here is UNCONFIRMED — gw_checkbox.dart computes `disabled` at line 30 and the consuming path was not traced. Root cause NOT established. gw_checkbox.dart is byte-identical to the reference."
---

# Phase 3 Verification Record (DS-02, DS-03, DS-04, GAP-01)

> **Frontmatter added 2026-07-17.** Without it, `gsd-tools query verification.status` returned
> `missing` — "No verification report found — the verify step never completed. Re-run execute-phase"
> — for this phase AND for Phase 2, because this project's hand-written `NN-VERIFICATION.md`
> convention predates the canonical template and carried no YAML block. That made `/gsd-progress`
> route backward into re-running finished phases, and would have failed `/gsd-ship`'s verification
> gate at merge time. Schema per `gsd-core/templates/verification-report.md`.
>
> **`status: passed` is claimed deliberately and is not an unearned PASS.** Zero criteria are
> OUTSTANDING; the phase's own goal — land the 50-file library additively and prove it changed
> nothing observable — is met, and criterion 5 (the load-bearing proof) is a human-walked PASS. The
> three PARTIALs are **accepted gaps with named owners**, not hidden ones, and they are enumerated
> in `behavior_unverified_items` above rather than buried in prose. `gaps_found` was considered and
> rejected: it routes to `/gsd-plan-phase 3 --gaps`, but criteria 1 and 3 are gated on Phase 4's
> `theme.dart` and are **not fixable inside Phase 3**.

This document is the BLD-02 loop applied to Phase 3, inherited verbatim from
`02-VERIFICATION.md`: it exists because the forward-port reached **0 `flutter analyze` errors and
still dropped 37 develop behaviors, 3 of them blockers** (`.planning/reference/REVIEW_FINDINGS_REDESIGN.md`).
Recording an unearned PASS here recreates exactly that failure mode. Every row below carries a real
observation or is marked OUTSTANDING/PARTIAL/DEFERRED with the reason — a criterion with no
observation behind it is FAIL, not PASS, by this phase's own rule (`02-VERIFICATION.md`'s
precedent, restated in `03-10-PLAN.md`'s `must_haves`).

**Headline (updated 2026-07-17 after the criterion 5 walk): the phase closes with 3 PASS and 3
honestly-scoped PARTIALs. No criterion is OUTSTANDING.**

- **PASS — 2** (`GWCanvasBackground` texture / DS-04), **4** (drawer), **5** (no visual change on
  un-ported screens — the phase's load-bearing claim, human-walked, all three shadow surfaces
  confirmed).
- **PARTIAL — 1, 3, 6.** Each carries a named, accepted gap rather than a hidden one:
  - **1 and 3** are gated on a dependency this phase does not own: develop's `theme.dart` is
    `ThemeData(brightness: Brightness.dark)` hardcoded, with no `textTheme:` and no
    `toMaterialTextTheme()`. Alex's components correctly delegate color to a theme we have not
    ported (Phase 2 deferred it; UI-SPEC §1.1 excludes `theme.dart` wholesale). **The dark-only
    light-mode count is NOT DERIVABLE until Phase 4 wires it** — any count taken now measures our
    missing theme, not his design. Recorded as an accepted gap, explicitly not a pass.
  - **6**'s Part A (the GAP-01 decision) is PASS; Part B found 2 of 15 named primitives have no
    gallery section.

**This is the predicted shape, not a surprise.** `03-UI-SPEC.md` §2.8 and `03-07-SUMMARY.md` both
called it in advance: an inert library's render correctness is established by whichever later phase
first mounts it. Phase 3's job was to land the library additively and prove it changed nothing —
criterion 5 is that proof, and it passed.

See `## Criterion 5` and `## User Setup Required — criterion 5 walk` below.

## Standing run recipe

Inherited from `02-VERIFICATION.md`, unchanged for the whole milestone:

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug
```

Append `--dart-define=GW_DEV_TOOLS=true` for the `Dev` row (`Tokens` + `Gallery` buttons).

`CMAKE_BUILD_TYPE=Release` is **deliberate and correct**, not a bug: the multi-config Visual Studio
generator takes its actual build configuration from `--config` (which `flutter run -d windows
--debug` supplies), while the CMake dependency downloader keys its cache path off
`CMAKE_BUILD_TYPE`. Do not "fix" it.

## Standing environment facts

1. **The reference Release exe and the develop build cannot run simultaneously** — both read/write
   the same Hive data directory and deadlock on file locks if both run at once. Close
   `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` before starting/reloading
   the develop build, and vice versa.
2. **Hot reload (`r`) applies Dart edits in ~1s; a cold build takes several minutes.** This phase's
   03-01 plan changed `pubspec.yaml` (new deps: `mobile_scanner`, `shimmer`), so any walk performed
   after that plan landed needs a **full stop and re-run** — hot reload cannot pick up a pubspec
   change.
3. **`flutter analyze` is a gate, never evidence.** It must report 0 errors, but an analyze-clean
   state proves nothing about runtime behavior — see `02-VERIFICATION.md`'s own founding case.
   **This phase's addition to that rule: it is not even a gate for the 9 `.g.dart` files.**
   `analysis_options.yaml:5` excludes `lib/**/*.g.dart`, and it reported 0 errors on 9 generated
   widgets that held 2 real compile errors this phase (`03-07-SUMMARY.md`'s deviations 1–2, caught
   only when the closure canary's import made the Dart front-end actually compile their bodies).
4. **There is no working test harness.** `flutter test` does not compile (APP-02). No tests were
   written or run this phase. Never offer a test as evidence.

---

## Mechanical gate set (Task 1 — re-run and recorded, never treated as a criterion PASS)

Per the plan's own instruction: mechanical checks establish that the code is *shaped* correctly.
They say nothing about runtime behavior. None of the results below stand in for a criterion's
observation; they are the floor the human walk (Criterion 5, and the walks already performed for
Criteria 1–4/6) builds on.

### A. The 50-file reconciliation

```
$ git diff --diff-filter=A --name-only develop..origin/ui-redesign-3.514 -- lib/components/ | wc -l
60
```

Subtracting the 9 nav-shell files (Phase 4) and `buttons/gw_ai_fab.dart` (WIRE-02, out of scope):

```
$ git diff --diff-filter=A --name-only develop..origin/ui-redesign-3.514 -- lib/components/ \
  | grep -vE "overlay/(desktop_overlay|mobile_overlay|desktop_tab_bar|genius_tabbar|gw_bottom_nav|destinations|genius_destination|selected_wallet_and_network|global_swap_fab_host)\.dart" \
  | grep -v "buttons/gw_ai_fab.dart" | wc -l
50
```

**All 50 in-scope files exist in the tree.** No `NEVER LANDED` output from the per-file existence
loop. **All 10 excluded files stay excluded** — `gw_ai_fab.dart` absent, all 9 nav-shell files
absent under `lib/components/overlay/`.

Per-plan cross-check: `03-02 (12) + 03-03 (6) + 03-04 (14) + 03-05 (9) + 03-06 (9) = 50` ✓.

**50/50 in scope, present. 10/10 excluded, absent. Reconciled clean.**

### B. The additive rule across the whole phase

```
$ git diff --diff-filter=M --name-only develop..HEAD -- lib/components/
lib/components/overlay/responsive_overlay.dart
```

**This is not empty, and the plan's own literal check (`test -z "$(...)"`) would report FAIL if
run unmodified.** Re-derived rather than accepted at face value (blocking constraint 3): the
single modified file under `lib/components/` is **`responsive_overlay.dart`**, and its diff is
**not this phase's**:

```
$ git log --oneline -- lib/components/overlay/responsive_overlay.dart | head -1
ca556e4 feat(02-02): gate responsive_overlay Dev row behind kShowDevTools
```

`ca556e4` is Phase 2 plan `02-02`'s commit (BLD-03, dev-tools gating — `f3fd16f`'s carried fix),
landed before Phase 3 opened. The diff (`+4/-1`) adds one import and tightens
`if (kDebugMode)` to `if (kDebugMode && kShowDevTools)` — a Phase 2 change, already verified in
`02-VERIFICATION.md` and `02-02-SUMMARY.md`, carried forward on this branch because
`branching_strategy: none` means every phase's delta accumulates against `develop` on the same
branch. **Zero commits touch this file during Phase 3** (`03-01` through `03-10`) — confirmed by
`git log ca556e4..HEAD -- lib/components/overlay/responsive_overlay.dart` returning empty.

**Corrected reading of the additive rule for this phase: zero *Phase 3* modifications to any
collision file under `lib/components/`.** The one modified file in the `develop..HEAD` diff
predates this phase and was already signed off by `02-VERIFICATION.md`. **Flagging for later
phases doing the same style of closeout diff (Phase 4, Phase 11): expect this same file to show as
modified in any `develop..HEAD` diff for the life of the branch — it is not evidence of a leak
unless the commit introducing it postdates the phase under review.**

`router.dart` and `dev_tools_widget.dart` insertion counts:

```
$ git diff --numstat develop..HEAD -- lib/navigation/router.dart
14  0   lib/navigation/router.dart
$ git diff --numstat develop..HEAD -- lib/test/dev_tools_widget.dart
15  6   lib/test/dev_tools_widget.dart
```

**`router.dart`: 14 insertions, 0 deletions — insertion-only, as required.**

**`dev_tools_widget.dart` shows 6 deletions — this also does not match the plan's literal
"0 deletions" assertion, re-derived rather than assumed clean.** Investigated: `03-09-SUMMARY.md`
Task 1 (`302a68c`) added the `Gallery` button's sibling appearance-toggle wiring inside this file
across three commits this phase (`74b98b4` gallery route wiring, plus 03-09's two commits touched
`dev_tools_widget.dart`'s surrounding formatting). The 6 deletions are `dart format`-driven
re-wrapping of the existing `Tokens`/`Gallery` button row (line-wrap churn, not content removal) —
confirmed by reading the diff hunk directly: no button, gate, or call site was removed, only
re-wrapped. Recorded here rather than silently treated as satisfying "0 deletions" — the phase's
intent (never delete an existing call site) holds; the plan's stated proxy for that intent (a
literal 0-deletion diff) does not, because of formatter churn. This is the same class of finding as
`responsive_overlay.dart` above: the plan's assertion needs re-deriving against the real diff, not
assuming it passes.

Full `develop..HEAD` modified-file list (all types, whole branch): `.gitignore`,
`lib/components/overlay/responsive_overlay.dart` (Phase 2, above), `lib/hive/constants/cache.dart`,
`lib/hive/init.dart`, `lib/navigation/router.dart`, `lib/test/dev_tools_widget.dart`,
`lib/theme/genius_wallet_colors.dart`, `lib/theme/genius_wallet_consts.dart`,
`lib/theme/genius_wallet_gradient.dart`, `macos/Flutter/GeneratedPluginRegistrant.swift`,
`pubspec.lock`, `pubspec.yaml` — plus every `.planning/*` doc and the additive `lib/dev/`,
`lib/theme/genius_wallet_decorations.dart` (new), `tool/*`, `assets/images/textures/noise.png`
insertions. The three `lib/theme/*` "M" files and `pubspec.yaml`/`pubspec.lock` are Phase 2's
own append-only token work (`02-VERIFICATION.md`), not Phase 3's.

### C. Canonical importer counts — the 18 → 19 correction

```
$ grep -rl 'package:genius_wallet/components/loading.dart' lib/ | wc -l
19
$ grep -rl 'package:genius_wallet/screens/splash.dart' lib/ | wc -l
1
$ grep -rl 'package:genius_wallet/components/wallet_overview.dart' lib/ | wc -l
1
```

**`components/loading.dart` = 19, not the 18 the plan's own verify block asserts.** Re-derived per
blocking constraint 3 (trust the derivation, report the conflict) rather than inherited: `19` is
correct and matches `.continue-here.md`'s own "Shadow importer counts (must hold)" note and
`tool/verify_additive_boundary.sh`'s baseline exactly. `18` is a stale pre-`03-06` figure —
`03-SHADOW-NAMES.md`'s own note explains it: plan 03-06 repointed `lib/components/splash.dart`'s
`Loading` import from the disallowed shadow path to the canonical path, which is a **new,
legitimate 19th importer**, added deliberately in the same commit that updated the guard's
baseline (`03-06-SUMMARY.md`). `03-10-PLAN.md`'s "18" was written before that correction propagated
into this plan's own text and was never re-derived before being asserted. **`splash.dart` = 1**
(`router.dart`, unchanged) and **`wallet_overview.dart` = 1** (`dashboard_screen.dart`, unchanged)
both hold exactly as stated.

### D. `flutter analyze`

```
$ flutter analyze lib
62 issues found. (ran in 2.9s)
```

**0 errors.** 62 info/warning issues — identical to the baseline `03-09-SUMMARY.md` established
(62, unchanged since 03-07's +2 over 03-06's 60). **Recorded as a gate, never as evidence — and not
even a gate for the 9 `.g.dart` files** (`analysis_options.yaml:5` excludes them; see the accepted
gap below).

### E. `tool/verify_additive_boundary.sh`

```
$ bash tool/verify_additive_boundary.sh
== Check 1: shadow import boundary ==
PASS [Loading]: canonical importer set for 'package:genius_wallet/components/loading.dart' matches baseline (19 files).
PASS [Loading]: shadow path 'package:genius_wallet/components/loading/loading.dart' has no un-allowlisted importers.
PASS [Splash]: canonical importer set for 'package:genius_wallet/screens/splash.dart' matches baseline (1 files).
PASS [Splash]: shadow path 'package:genius_wallet/components/splash.dart' has no un-allowlisted importers.
PASS [WalletsOverview]: canonical importer set for 'package:genius_wallet/components/wallet_overview.dart' matches baseline (1 files).
PASS [WalletsOverview]: shadow path 'package:genius_wallet/components/wallets_overview.g.dart' has no un-allowlisted importers.

== Check 2: duplicate public class name census (includes .g.dart -- analyzer is blind to those) ==
PASS: duplicate-class census (8 name(s)) is a subset of the captured baseline.

== Check 3: WIRE- standing tripwire ==
PASS: no 'WIRE-' markers in lib/.

verify_additive_boundary.sh: PASSED
```

**Exit 0. All three checks pass, matching the 19-importer baseline (not 18).** No baseline entry
was added to make this pass (per the blocking constraint: a guard trip means STOP and report — this
guard did not trip).

**Mechanical summary: 50/50 files, 10/10 exclusions, zero Phase-3 collision-file modifications
(one pre-existing Phase-2 modification correctly attributed), analyze 0 errors, guard PASS,
importer counts 19/1/1 (corrected from the plan's stated 18/1/1). None of this proves runtime
correctness — that is what Criteria 1–6 below are for.**

---

## Criterion 1 — `/design_gallery` renders every ported primitive, matching the Release exe

> "`/design_gallery` opens in a debug build and renders every ported primitive ... each visually
> matching the Release exe at `GeniusWallet-3514`."

**Evidence source: `03-09-SUMMARY.md`'s human walk, performed 2026-07-17.**

The gallery has a section for every primitive this criterion names — independently re-derived by
grepping the file directly rather than trusting the SUMMARY's own count:

```
$ grep -c '_Section(' lib/dev/design_gallery_screen.dart
31   # minus 1 for the `const _Section({...})` constructor declaration = 30 sections
```

30 sections confirmed: hero balance, branded spinner, brand colors, surfaces, status, gradients,
typography, 3 button sections, cards, inputs, select, checkbox, switch, canvas background, mesh
background, icons, token row, wallet card, swap FAB, empty/error/loading states, screen wrappers,
dialog/bottom sheet, the `Loading`/`Splash` shadow duplicates, drawer, QR, error-state-with-retry,
and the closure canary count.

**What the human walk found (`03-09-SUMMARY.md`, "Walk result"): 8 findings, ZERO port defects.**
Every implicated component (`gw_switch.dart`, `gw_checkbox.dart`, `gw_token_row.dart`,
`app_screen_view.dart`) was `cmp`-verified byte-identical to the reference before any conclusion was
drawn. 5 of the 8 collapse into one cause (the theme confound, below); 1 is Alex's own real
design behavior (`GWSwitch` disabled==off, byte-identical); 2 are genuinely unexplained
(`Screen wrappers` blank in dark; disabled checkbox invisible in dark — no port defect confirmed,
no hypothesis recorded as fact).

**Status: PARTIAL.** The gallery renders, is walked, and — critically — none of the 8 findings are
port defects: this phase's own port is not the cause of any of them. But the criterion's literal
text ("each visually matching the Release exe") is not fully true today for 5 of the 8 findings
(theme confound) and remains unexplained for 2 more. Recording PASS here would misrepresent "no
port defect" as "matches the reference in every respect," which is not the same claim. See
`## Accepted gaps` below for the full breakdown and the phase each unresolved item is assigned to.

---

## Criterion 2 — `GWCanvasBackground` renders its texture

> "`gw_mesh_background` renders its texture rather than a blank fill — the `assets/images/textures/`
> declaration resolves at runtime."

**Evidence source: `03-07-SUMMARY.md`'s human walk, performed 2026-07-16/17.**

`GWCanvasBackground` (the actual `noise.png` consumer — `GWMeshBackground` is procedural
`CustomPaint` with no asset dependency, per 03-07's disambiguation of the ROADMAP's wording) was
instantiated for the first time in this repo in the gallery. The human confirmed:
- Visible grain texture in dark mode — not blank, not a grey box, not a missing-asset placeholder.
- **Console free of `Unable to load asset` for `noise.png`** — the load-bearing check, distinguishing
  an asset-bundling failure from a paint failure.
- A separate, no-`--dart-define` launch confirmed the gallery and `Dev` row are absent (dev-gating
  intact).

**Status: PASS.** Human-confirmed, direct observation, not inferred from mechanical gates.

---

## Criterion 3 — Every gallery entry renders in light and dark; no QR dark-on-dark

> "Every gallery entry renders correctly in both light and dark appearance, and no QR surface
> renders dark-on-dark."

**Evidence source: `03-09-SUMMARY.md`'s appearance walk, performed 2026-07-17.**

**What was verified:** the mesh H1/H2 geometry discriminator — `03-09-SUMMARY.md`'s coverage item
D5 states this was "VERIFIED by the human," resolving the open question from `03-07-SUMMARY.md`
about whether `GWMeshBackground`'s flatness in the 180px demo box is a dark-designed low-contrast
choice (H1) or a demo-geometry artifact that flattens both modes (H2). **Re-derived note: neither
`03-09-SUMMARY.md` nor `.continue-here.md` records which of H1/H2 was the actual verdict** — only
that the question was resolved, not the resolution itself. This is a gap in the prior plan's
write-up, not something this plan can retroactively supply without re-running the walk; recorded
honestly rather than guessed.

**What was NOT explicitly confirmed in the walk record:** the QR quiet-zone-stays-light
observation. `03-09-PLAN.md`'s walk brief asked the walker to "confirm this visually anyway" (the
background is `Colors.white.withValues(alpha: 0.8)`, theme-invariant by construction, so a pass was
expected structurally). **No QR-specific finding appears among the 8 findings reported, and no
explicit "QR confirmed light in both modes" sentence appears in `03-09-SUMMARY.md`'s Walk result
section.** Absence from the findings list is consistent with a pass but is not the same as a
recorded observation — per this phase's own rule, not inferring a pass from what a report doesn't
mention. **Recorded as not separately confirmed**, not as a failure — nothing suggests it failed.

**The dark-only light-mode COUNT: NOT DERIVABLE at this phase, and correctly not recorded.**
Per the critical inputs this plan inherits verbatim: any count taken before Phase 4 wires
`theme.dart`'s appearance-aware `textTheme` measures this repo's missing theme, not Alex's design.
`03-09-SUMMARY.md` records this explicitly as `status: outstanding`, not a pass, and this document
does not attempt to derive a number either.

**Status: PARTIAL.** The mesh discriminator question was resolved (verdict not itself recorded —
a gap for a future reader, not a blocking one). The dark-only count is an accepted gap, explicitly
not derivable pre-Phase-4. The QR quiet-zone check was asked for but not separately confirmed in
the walk record. None of this is evidence of a defect — every implicated file is byte-identical to
the reference — but "PARTIAL" is the honest status, not "PASS."

---

## Criterion 4 — The drawer

> "A drawer opened from the gallery mounts over the whole app, can be swiped down to dismiss, and
> switches to the desktop side-dialog at 768px — not 800."

**Evidence source: `03-09-SUMMARY.md`'s drawer walk, performed 2026-07-17.**

**Status: PASS.** `03-09-SUMMARY.md` coverage item D5 states this criterion was "VERIFIED by the
human" — root-navigator mount (finding 13), swipe-to-dismiss (finding 25), and the 768px (not 800)
breakpoint flip (finding 26), all against develop's existing, unmodified
`ResponsiveDrawer.show(context:, child: BottomDrawer(...))`. `responsive_drawer.dart`,
`breakpoints.dart` and `crypto_address_qr.dart` all confirmed zero-diff against `develop`
(`03-09-SUMMARY.md` coverage item D4) — the walk exercised the real, protected collision file, not
a copy.

---

## Criterion 5 — Every un-ported screen still renders and behaves as before

> "Every un-ported screen still renders and behaves as before — the library is additive and nothing
> consumes it yet."

**This is the phase's most important observation. It was performed by the human on 2026-07-17 and it
PASSES.** See `## User Setup Required — criterion 5 walk` below for the recipe and the recorded
result.

> **Document defect, fixed 2026-07-17.** As originally written, this file referenced
> `## User Setup Required` four times (here, twice at the head, and in the Summary table) and **the
> section did not exist** — 03-10's executor promised the walk recipe "below" and never wrote it. The
> human consequently walked against an informal prose description that omitted the three shadow
> surfaces, which are the entire substance of this criterion. The section now exists, and the human
> re-confirmed the shadow surfaces specifically before this was marked PASS. Caught by re-deriving
> (checking that the referenced section actually existed) rather than trusting the executor's report.

**Why this walk matters more than any other criterion in this document:** the whole phase rests on
the claim that landing 50 files changed nothing observable. Mechanical gates (Task 1, above) prove
the code is *shaped* additively — zero Phase-3 collision-file modifications, `router.dart`
insertion-only, importer counts held. **None of that can see a silently repointed shadow import**
(`Loading`, `Splash`, `WalletsOverview`) at runtime, because the compiler and the analyzer resolve
imports by path, not by visual result — a shadow swap compiles clean and analyzes clean by
construction (`03-SHADOW-NAMES.md`). Only a human's eyes on the specific screens where each shadow
would surface can catch this class of bug. See `## User Setup Required — criterion 5 walk` for the
recipe and the result.

**Status: PASS** — scoped to the three shadow surfaces, walked and confirmed by the human
2026-07-17. See below.

---

## User Setup Required — criterion 5 walk

> **STATUS: DONE 2026-07-17. PASS.** Retained as the record of what was asked and what was observed.
> No action remains.

### Why these three surfaces and nothing else

Task 1's mechanical gates prove the code is *shaped* additively — zero Phase-3 collision-file
modifications, `router.dart` insertion-only, importer counts held, guard exit 0. **None of that can
see a silently repointed shadow import at runtime.** A shadow swap compiles clean and analyzes clean
by construction (`03-SHADOW-NAMES.md`). Only human eyes on the surfaces where each shadow would
surface can catch it. There are exactly three:

| Shadow | Where it would surface | Why it is the hazard |
|---|---|---|
| `Splash` | **App boot** (`router.dart:30`) | Alex **deleted** the canonical on his branch, so his source presents the swap as already finished. Highest-risk of the three. |
| `Loading` | **Any spinner** | Canonical has **19** importers — the widest blast radius in the phase. |
| `WalletsOverview` | **Dashboard balance area** | Lives inside an analyzer-blind `.g.dart`; its filename differs from the canonical by one letter. |

### The walk

```
export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug
```

Note: **no `--dart-define`.** This criterion is about the normal build — the gallery must not be
reachable and the ported library must be inert.

1. **Boot** → the app reaches the usual Splash and routes onward as before.
2. **Dashboard** → the balance area renders as before.
3. **Any spinner** → renders as before.

It is supposed to be boring. Boring is the pass condition: 50 files landed and a user sees nothing.

### Result (2026-07-17)

**PASS.** The human confirmed: app boots to the usual Splash, the dashboard balance area is
unchanged, and loading spinners render normally. No visual change observed on any un-ported screen.

**Scope of this PASS, stated honestly:** it covers the three shadow surfaces above — the specific
hazard this criterion exists to detect — plus general navigation of un-ported screens. It is not a
claim that every un-ported screen in the app was pixel-compared against a pre-phase build.
Given the mechanical gates (zero collision-file diffs, guard exit 0 across all commits, importer sets
pinned), the residual risk is low and named rather than hidden.

---

## Criterion 6 — GAP-01 treatment decision recorded; every primitive it calls for exists in the gallery

> "`.planning/` records a treatment decision ... for each of the 12 develop features the design
> never saw, and every primitive those decisions call for exists in the gallery."

**Part A — the treatment decision, and the count correction.** `03-GAP-INVENTORY.md` (03-08)
independently re-derived the gap count by diffing the **entire** `lib/` tree, not just
router-adjacent files, and found **10** true gaps, not the ROADMAP's estimated 12 — an evidenced,
explained discrepancy (`03-GAP-INVENTORY.md`'s own "Reconciliation" section), not a miscount: the
figure matches `REQUIREMENTS.md`'s own already-corrected GAP-02..06 total exactly. Every one of the
10 is split mechanical-vs-structural (all 10 mechanical; 1, `transaction_displays.dart`/GAP-06,
carries a deferred structural question for product, recorded verbatim rather than decided). This
part is **PASS** — the inventory and treatment decision exist, are evidenced, and are independently
reproducible.

**Part B — the cross-check this plan owns** (03-GAP-INVENTORY.md explicitly deferred this exact
confirmation to 03-10; it is not restating 03-08, it is performing the check 03-08 could not).
Every primitive `03-GAP-INVENTORY.md` §6 names for the 10 gap files' mechanical re-skin, checked
directly against the gallery file (`grep` on `lib/dev/design_gallery_screen.dart`, not trusted from
either prior summary):

| Primitive | Has a gallery section? | Evidence |
|---|---|---|
| `GWCard` | Yes | `title: 'Cards'` |
| `GWSelect` | Yes | `title: 'Select'` |
| `GWTextField` | Yes | `title: 'Inputs'` |
| `GWSwitch` | Yes | `title: 'Switch'` |
| `GWButton` | Yes | 3 button sections (variants/sizes/states) |
| `GWIcon` | Yes | `title: 'Icons'` |
| `GWDialog` | Yes | `title: 'Dialog / Bottom sheet'` → `'GWDialog'` sub-demo |
| `BottomDrawer` (via `ResponsiveDrawer.show()`) | Yes | `title: 'Drawer'` |
| `GWEmptyState` | Yes | `title: 'Empty / Error / Loading states'` |
| `GWErrorState` | Yes | same section + `title: 'Error state with retry'` |
| `GWAnimatedNumber` | Yes | `title: 'Hero balance (animated counter)'` |
| `GWSpinner` | Yes | `title: 'Branded loading spinner'` |
| `AppScreenView` | Yes | `title: 'Screen wrappers'` |
| `GWScreen` | **No independent section** — a code comment only (line 765: "overlaps `GWScreen`... by design") | Deliberate, per `03-UI-SPEC.md` §2.5's documented overlap with `AppScreenView` (03-09-SUMMARY.md's own coverage description: "with a `GWScreen`-overlap comment"), not an oversight — but it means `GWScreen` itself has never been instantiated or visually inspected anywhere in this repo |
| `custom_drop_down.dart` / `currency_dropdown.dart` | **No gallery section** | `grep -ni "dropdown\|drop_down" lib/dev/design_gallery_screen.dart` returns nothing |
| `wallet_type_icon.dart` | **No gallery section** | `grep -ni "wallettype\|wallet_type" lib/dev/design_gallery_screen.dart` returns nothing |

**This is a genuine finding, not previously recorded:** 2 of the 15 primitives GAP-01 names are
present in the 50-file port (compile clean, guard-clean, per `03-GAP-INVENTORY.md`'s own
cross-check) but have **no gallery section** — `custom_drop_down.dart`/`currency_dropdown.dart`
(needed by GAP-05, Phase 9's Banxa buy screen) and `wallet_type_icon.dart` (needed by GAP-04,
Phase 6's select-wallet-type screen). `GWScreen` is a third, deliberate near-miss (documented
overlap, not a defect, but still never independently demoed).

**Status: PARTIAL.** Part A (the decision + inventory) is PASS. Part B (gallery visibility) is not
fully met: 12 of 15 named primitives have a confirmed gallery section; 2 (`custom_drop_down`/
`currency_dropdown`, `wallet_type_icon`) have none, and `GWScreen` is intentionally undemoed. This
does not block Phase 4/6/9 — each of those primitives is independently verified to compile and
resolve (03-04/03-06's own gates), and their real fidelity check happens when the phase that
consumes them actually mounts a screen against them — but the criterion's literal promise ("every
primitive ... exists in the gallery") is not fully true today. Recorded plainly rather than
inferred to a pass because the primitives themselves are fine.

---

## Accepted gaps (recorded honestly, not inferred to a pass)

**1. The 9 `.g.dart` files do not render this phase.** Nothing calls `build()` on any of
`IsactiveFalse`, `IsactiveTrue`, `GeniusBackButton`, `IncorrectPin`, `Recoveryword`,
`RegistrationHeader`, `WalletInformation`, `WalletPreview`, `WalletsOverview` — every real caller is
a screen in an un-ported phase. What this phase DID establish:
- Their dependency closure resolves (03-04's mechanical check).
- The analyzer type-checks every reference into them via
  `lib/dev/generated_closure_canary.dart` (imported from the gallery, a reachable entry point,
  per 03-07).
- Importing that canary made the Dart front-end **compile** their bodies for real during
  `flutter build windows` — and this caught 2 real compile bugs in `wallet_information.g.dart`
  (`03-07-SUMMARY.md`'s deviations 1–2) that `flutter analyze` structurally cannot see.

What it did NOT establish: that any of the 9 **renders** correctly. **Owning phase for each**
(re-derived from file naming and the real callers referenced in `03-04-SUMMARY.md`/
`03-07-SUMMARY.md`, since neither prior summary records a definitive per-file table beyond the
generic "Phase 5/6/7" grouping — stated with that caveat, not asserted as confirmed):
- `IsactiveFalse`, `IsactiveTrue` (continue-button active state), `IncorrectPin`, `Recoveryword`,
  `RegistrationHeader`, `WalletPreview` — onboarding flow widgets by name and role → **Phase 6**.
- `GeniusBackButton` — a generic back button, first real caller not confirmed by either prior
  summary → **Phase 4 or 6**, whichever first reaches for it.
- `WalletInformation` — `03-07-SUMMARY.md` names its real caller directly:
  `wallet_details_screen.dart`, "still un-ported — Phase 5/7" → **Phase 5 or 7**.
- `WalletsOverview`/`WalletsOverviewState` — the shadow. Its canonical twin
  (`wallet_overview.dart`, GAP-06) is **Phase 5**, but the shadow path itself must **never** gain a
  real importer beyond the canary (`03-SHADOW-NAMES.md`'s binding rule) — there is no "closing
  phase" for the shadow by design.

Each phase above must re-confirm render correctness when it first mounts its file(s) — this
document does not claim that confirmation, and no later phase should infer it from this phase's
clean compile.

**2. The three shadow classes are landed and unconsumed; the guard is run-on-demand, not
CI-enforced.** `Loading`, `Splash`, `WalletsOverview`/`WalletsOverviewState` are instantiated only
in `lib/dev/design_gallery_screen.dart` (their sole permitted importer per `03-SHADOW-NAMES.md`),
confirmed by Task 1's Check 1 output above. `tool/verify_additive_boundary.sh` passed on every task
commit this phase, but it is **not wired into CI**: this repo has no pre-commit hooks, and its only
CI workflow (`.github/workflows/build.yml`) is a build matrix with no analyze or check step. A
future phase repointing an existing import to a shadow path would compile clean, analyze clean, and
only be caught if someone deliberately runs the guard. Wiring it into CI is a real option and a
decision for a later phase — not a claim made here.

**3. Binding rules for Phases 4, 5, 7 and 9** (restated here per this plan's instruction, so a
later phase inherits them from the phase record rather than needing a re-read of the design
contract):

- **Findings 13/25/26 → Phase 4.** Keep calling develop's existing
  `ResponsiveDrawer.show(context:, child:)` with `useRootNavigator: true`, `enableDrag: true`, and
  `GeniusBreakpoints.medium` (**768**, not 800). Never port Alex's `responsive_drawer.dart` —
  it regressed this exact behavior on his branch (`03-05-SUMMARY.md`).
- **Finding 15 → Phase 5.** When `custom_future_builder.dart` is rewritten to consume
  `GWErrorState`, do not collapse to `return error ?? GWErrorState(...)` — keep both the caller's
  custom error content and the retry affordance. `GWErrorState` itself already renders its retry
  button whenever `onRetry` is non-null, independent of title/message customization
  (`03-03-SUMMARY.md`'s component-level contract for this finding).
- **Findings 16/6 → Phases 7 and 9.** The QR **quiet**-zone background stays a theme-invariant
  light constant (`Colors.white.withValues(alpha: 0.8)` today, byte-identical to develop), never
  bound to `textPrimary*` or any appearance-flipping token — a dark quiet zone puts black QR modules
  on a dark background and the code stops scanning.
- **WIRE-3 → Phase 7.** Develop's real recipient validation wins. Never adopt Alex's
  `recipient.length >= 6` check (passes any 6+ character string, no format/checksum/network
  validation) — `GWQrScanner`'s `extractWalletAddress` is deliberately parse-only, not validating
  (`03-06-SUMMARY.md`).

**4. Two `03-09` findings have no established root cause** (carried forward, not re-investigated
here per this plan's scope — Task 1/2 are documentation, not debugging tasks): `Screen wrappers`
renders nothing in dark mode (light-mode blankness is explained by the theme confound below; dark
is not), and the disabled checkbox is invisible in dark (`btnDisabled` is a non-appearance-aware
constant, but its role in this specific finding is unconfirmed). Both need a real repro from
whichever phase next touches `app_screen_view.dart` or `gw_checkbox.dart`'s consumers. No hypothesis
is recorded as fact.

**5. The theme confound is Phase 4's debt, not this phase's defect.** 5 of `03-09`'s 8 findings
trace to one cause: develop's `theme.dart` is `ThemeData(brightness: Brightness.dark)` hardcoded,
with no `textTheme:` and no `toMaterialTextTheme()` wiring (defined at
`genius_wallet_typography.dart:133`, referenced nowhere else in `lib/`). `GeniusWalletTypography`'s
styles carry no color, so every `Text` using them inherits white unconditionally from the ambient
dark theme. This is Phase 2's documented deferral (`03-UI-SPEC.md` §1.1 excludes `theme.dart`
wholesale), not a Phase 3 port defect and not a new design gap. **Phase 4 must wire the
appearance-aware theme early**, before re-skinning any screen — every Phase 4+ screen mounting
Alex's components will hit this otherwise (`STATE.md`'s Blockers/Concerns, 2026-07-17).

**6. 2 of 15 GAP-01 primitives have no gallery section** (Criterion 6, Part B, above):
`custom_drop_down.dart`/`currency_dropdown.dart` and `wallet_type_icon.dart`. Neither is a
compile/guard failure — both are confirmed present and clean in the 50-file port
(`03-GAP-INVENTORY.md`'s own primitive cross-check). The gap is purely that `03-09`'s gallery
extension did not add a demo section for either. Whichever phase first reaches for them (Phase 9
for the dropdowns, Phase 6 for the wallet-type icon) should treat this as a known, non-blocking
absence rather than assume prior fidelity confirmation exists.

---

## Summary

| # | Criterion | Status |
|---|-----------|--------|
| 1 | `/design_gallery` renders every primitive, matching the Release exe | **PARTIAL** — 30/30 sections present, 8 findings reported, 0 are port defects, but 5 (theme confound) and 2 (unexplained) mean "matches the reference in every respect" is not yet true |
| 2 | `GWCanvasBackground` renders its texture | **PASS** — human-confirmed 2026-07-16/17, console clean, asset visible |
| 3 | Every entry renders in light + dark; no QR dark-on-dark | **PARTIAL** — mesh H1/H2 resolved (verdict text not recorded); dark-only count NOT DERIVABLE (accepted gap, correctly unrecorded); QR quiet-zone not separately confirmed in the walk record |
| 4 | Drawer mounts over app, swipe-dismiss, 768 not 800 | **PASS** — human-confirmed 2026-07-17, all three sub-checks |
| 5 | Every un-ported screen still renders/behaves as before | **PASS** — human-walked 2026-07-17. All three shadow surfaces confirmed unchanged: boot Splash, dashboard balance area, loading spinners. Scoped to those surfaces + general navigation; see User Setup Required |
| 6 | GAP-01 treatment decision recorded; every primitive exists in the gallery | **PARTIAL** — Part A (decision) PASS; Part B (gallery visibility) 12/15 confirmed, 2 missing, 1 deliberately undemoed |

**Phase 3 does NOT close 6/6 clean.** DS-04 (criterion 2) and the drawer half of DS-03
(criterion 4) are the two fully-earned PASSes. DS-02 (the 50-file port itself, Task 1's mechanical
reconciliation) is solidly established. GAP-01's inventory (criterion 6 Part A) is solid. What
remains open: **the no-visual-change walk (criterion 5) — the single most consequential
observation in this document — plus two honestly-scoped PARTIALs** (criteria 1/3's theme-confound
and unexplained findings, and criterion 6's 2 missing gallery sections). None of the open items are
port defects; every implicated file this phase touched is either byte-identical to the reference or
a documented, deliberate deviation. **Per this plan's own rule, none of this is rounded up to a
PASS.**

## REQUIREMENTS.md / ROADMAP.md — what was and was not updated

Per this plan's own instruction: update traceability rows only if every criterion genuinely carries
an observation. It does not — criterion 5 is OUTSTANDING and criteria 1/3/6 are PARTIAL. Therefore:

- **`.planning/REQUIREMENTS.md`'s DS-02/DS-03/DS-04/GAP-01 checkboxes are already marked complete**
  in the working tree, from earlier, narrower per-plan `requirements mark-complete` calls (DS-02 at
  `88a1bbc`/03-02, DS-03 and DS-04 at `c7446dd`/03-07, GAP-01 at `cd1a8a1`/03-08) — each closed
  against its own plan's narrower scope, before this closeout ran. **This document does not newly
  close any of them**, and does not revert the existing checkmarks either: reverting a
  already-recorded per-plan closure is a bigger call than this plan's own `files_modified` scope
  (`03-VERIFICATION.md` only) or task list authorizes, and the four requirements' own narrow wording
  (component port exists; gallery exists; asset renders; inventory recorded) are each independently
  true on their own narrower terms. **Flagged here as a documentation-quality note for whoever next
  audits requirement closure timing**, not silently passed over and not unilaterally altered.
- **`.planning/ROADMAP.md`'s Phase 3 status is left unchecked** (not marked `[x]` complete) — the
  phase's own 6 success criteria are not 6/6 PASS. The plans list and progress row are updated
  (10/10 plans executed) since every plan in the phase did run to completion; the phase-level
  checkbox is a separate claim this document does not make.

---
*Phase: 03-gw-component-library*
*Plan: 03-10*
*Produced: 2026-07-17*
