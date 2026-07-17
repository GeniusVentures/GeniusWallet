---
phase: 03-gw-component-library
plan: 09
subsystem: ui
tags: [flutter, gw-components, design-gallery, ds-03, drawer, qr, error-state, appearance-toggle, shadow-classes, light-mode]

# Dependency graph
requires:
  - phase: 03-07
    provides: "lib/dev/design_gallery_screen.dart -- the 18-section gallery (15 originally-ported sections + canvas background + mesh background + closure canary, verified by direct grep of the pre-this-plan commit -- 03-07-SUMMARY.md's own stated '17 sections' undercounts by one), the _Section(title:, child:) extension pattern, GWCanvasBackground's first instantiation"
provides:
  - "lib/dev/design_gallery_screen.dart extended to 30 sections -- every primitive ROADMAP criterion 1 names now has a section, plus the appearance toggle and the three finding-bound demos (drawer, QR, error state with retry)"
  - "The gallery's first live appearance toggle (GWAppearance.instance + ValueListenableBuilder, Phase 2's exact mechanism) -- every section is now inspectable in both modes without restarting the app"
  - "The Loading and Splash shadow classes' first (and only permitted) instantiation anywhere in the repo -- tool/shadow-baseline.txt's allowlist is non-empty for the first time, and the guard still passes"
  - "Findings 13/15/16/25/26 staged as observable demos (drawer, error-state-with-retry, QR) rather than paper assertions -- the actual human walk that OBSERVES them is still outstanding (see Outstanding below)"
affects: [03-10]

tech-stack:
  added: []
  patterns:
    - "MediaQuery override for a demo box: Splash's build() sizes its inner content off MediaQuery.sizeOf(context) rather than its own BoxConstraints (it expects to be the full-screen boot route). Wrapping it in MediaQuery(data: MediaQuery.of(context).copyWith(size: const Size(320, 220)), child: const Splash()) makes it fit the gallery's constrained demo box without touching splash.dart itself."
    - "GWIcon.svg/.png default to package: 'genius_wallet' (this app's own package name) -- the physical assets live under lib/assets/images/, which pubspec.yaml exposes at the packages/genius_wallet/... namespace via its 'packages/genius_wallet/assets/images/*.{png,svg}' entries. Referencing a path NOT in that declared list (e.g. a plain assets/images/crypto/*.png with the default package still set) resolves to a nonexistent packages/genius_wallet/assets/images/crypto/*.png and fails to load -- verified by checking pubspec.yaml's asset list against the requested path before writing the demo, not after seeing an error."

key-files:
  created: []
  modified:
    - lib/dev/design_gallery_screen.dart

key-decisions:
  - "Both tasks landed in the same file (as the plan's own files_modified declares) but as two separate atomic commits, split by re-deriving the diff rather than relying on the single edit pass's line ranges -- dart format reformatted the whole file on each pass (long lines re-wrapped), so the commits were built by writing each task's intended end-state directly rather than trying to isolate hunks after the fact."
  - "GWIcon.material's demo instance could not be const: GeniusWalletColors.textPrimary is a non-const getter (isLight ? _inkLight : Colors.white), so 'const GWIcon.material(..., color: GeniusWalletColors.textPrimary)' is an invalid_constant compile error flutter analyze DOES catch (this is a normal .dart file, not a .g.dart exclusion). Fixed by dropping the const keyword on that one instance -- caught before commit, not a deviation worth its own entry since it never compiled in the first place."
  - "GWIcon.svg/.png demo assets chosen by checking pubspec.yaml's packages/genius_wallet/assets/images/* declarations first (shape.svg, mask2.png), not by picking an arbitrary existing asset and hoping the default package: 'genius_wallet' parameter resolved it -- assets/images/crypto/eth.png is declared WITHOUT the packages/ prefix, so it is used only where GWTokenRow/CryptoAddressQR's own Image.asset call (which passes no package) needs it."
  - "CryptoAddressQR's iconPath was supplied as a real bundled asset (assets/images/crypto/eth.png) rather than left null -- the file's own build() unconditionally sets embeddedImage: AssetImage(iconPath ?? \"\"), so a null iconPath at this call site would deliberately trigger the file's own pre-existing empty-string-asset quirk. Not our bug to fix (crypto_address_qr.dart is a zero-diff-protected collision file), but noisy for the human walker who is also checking noise.png's console cleanliness elsewhere -- avoided by supplying a real path instead of demonstrating that quirk unprompted."
  - "GWWalletCard's walletIcon left null in both demo instances (CircleAvatar fallback) rather than wired to a real asset -- the plan's must_have only requires demonstrating with/without the trailing arrow, not the icon path; wiring an icon here would have needed the same packages/genius_wallet/ asset-namespace check as GWIcon and added scope not asked for."

requirements-completed: [DS-03]

coverage:
  - id: D1
    description: "Every primitive ROADMAP criterion 1 names now has a _Section: GWIcon (.material/.svg/.png), GWTokenRow (with fallback-dot demo), GWWalletCard (with/without arrow), GWSwapFab, GWEmptyState/GWErrorState/GWErrorBanner/GWLoadingState, GWMeshBackground (already present from 03-07), AppScreenView (with a GWScreen-overlap comment per UI-SPEC §2.5), GWDialog/GWBottomSheet (labeled orphaned/non-canonical), plus the Loading and Splash shadow duplicates. 30 sections total (18 inherited from 03-07 + 12 new: 9 from Task 1, 3 from Task 2)."
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep gate: all 11 primitive names present; 0 raw Color(0x...) literals; flutter analyze lib 0 errors (2 pre-existing unnecessary_const info lints, unchanged baseline); tool/verify_additive_boundary.sh PASSED after both commits"
        status: pass
    human_judgment: false
  - id: D2
    description: "Appearance toggle uses Phase 2's exact mechanism: GWAppearance.instance.load() in initState, ValueListenableBuilder<GWAppearanceMode> wrapping the whole Scaffold, an AppBar IconButton calling setMode(). No second toggle mechanism invented."
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep gate: ValueListenableBuilder + GWAppearance both present; code review confirms builder wraps Scaffold (not just a sub-widget), matching token_probe_screen.dart's pattern line-for-line in structure"
        status: pass
    human_judgment: false
  - id: D3
    description: "The Loading and Splash shadow classes are instantiated for the first time anywhere in the repo, exclusively in this gallery file (their only allowlisted importer per 03-SHADOW-NAMES.md). tool/verify_additive_boundary.sh's Check 1 allowlist for both pairs is now non-empty (the gallery is the sole importer of each shadow path) and Check 1/2/3 all still PASS."
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "grep gate: both shadow import paths present with SHADOW-NAMES.md-naming comments; bash tool/verify_additive_boundary.sh PASSED (Check 1: both shadow paths show 'no un-allowlisted importers'; Check 2: duplicate-class census unchanged at 8 names, still subset of baseline; Check 3: no WIRE- markers)"
        status: pass
    human_judgment: false
  - id: D4
    description: "responsive_drawer.dart, breakpoints.dart and crypto_address_qr.dart remain byte-identical to develop -- the Drawer demo calls develop's existing, unmodified ResponsiveDrawer.show(context:, child: BottomDrawer(...)) with title/actions omitted (UI-SPEC §4.1), never Alex's regressed responsive_drawer.dart. The QR demo renders develop's untouched CryptoAddressQR. The Error-state-with-retry demo supplies both message and onRetry to GWErrorState so the Retry button's presence alongside custom content is wired for observation (finding 15)."
    requirement: "DS-03"
    verification:
      - kind: other
        ref: "git diff --name-only develop..HEAD -- lib/components/bottom_drawer/responsive_drawer.dart lib/utils/breakpoints.dart lib/components/qr/crypto_address_qr.dart -- empty (zero diff); grep -c 'bottom_drawer/responsive_drawer' lib/dev/design_gallery_screen.dart == 1 (single import, no second copy); grep gates for ResponsiveDrawer.show/BottomDrawer/CryptoAddressQR/onRetry all present"
        status: pass
    human_judgment: false
  - id: D5
    description: "The human walk against the Release exe, in both appearance modes, covering: criterion 1 (every section renders and matches, nothing blank/red/missing-asset), criterion 3 (light/dark walk + dark-only COUNT + the QR quiet-zone-stays-light observation + the H1/H2 mesh-geometry discriminator), criterion 4 (drawer mounts over the whole app, swipes to dismiss, flips at exactly 768px), and finding 15 (Retry renders alongside custom message)."
    requirement: "DS-03"
    verification:
      - kind: human
        ref: "PERFORMED 2026-07-17. Criterion 4 (drawer: root-navigator mount, swipe-dismiss, 768 boundary) and the mesh H1/H2 discriminator: VERIFIED by the human. Criterion 1/3 (both-modes render): 8 findings reported -- see 'Walk result' below. ZERO are port defects (every implicated component cmp-verified byte-identical to the reference). 5 of 8 trace to ONE cause: develop's theme.dart is `ThemeData(brightness: Brightness.dark)` hardcoded with no textTheme wiring, so GeniusWalletTypography.* styles (which carry NO color) inherit white unconditionally. That is Phase 2's documented deferral to Phase 4, not a design gap."
        status: partial
      - kind: human
        ref: "DARK-ONLY COUNT: **NOT DERIVABLE** at this phase, and deliberately NOT recorded. The walk cannot measure whether Alex's components have light-mode treatments while develop's theme.dart is hardcoded dark and un-wired -- his components correctly delegate color to a theme we have not ported yet. Any count taken now measures the missing theme, not the design. Re-derive after Phase 4 wires the appearance-aware theme. Recorded as an accepted gap, NOT a pass."
        status: outstanding
    human_judgment: true
    rationale: "This project's standing rule (02-VERIFICATION.md's precedent, reaffirmed by 03-07-SUMMARY.md and this plan's own <human_check_handling>): an unearned PASS on a human-observation criterion is the exact BLD-02 failure mode (37 regressions shipped analyze-clean). Every mechanical gate this plan can run (analyze, the guard, the zero-diff checks) has run and passed, but none of them can observe a rendered pixel, a swipe gesture, or a resize-through-768px breakpoint flip. Recording PASS here would be inventing an observation nobody made."

# Metrics
duration: ~35min
completed: 2026-07-17
status: complete
---

# Phase 3 Plan 09: Design Gallery Extension -- Light/Dark Toggle, Drawer, QR, Error State Summary

**Extended the design gallery from 18 to 30 sections -- every primitive ROADMAP criterion 1 names now has a section, a live appearance toggle uses Phase 2's exact `GWAppearance` + `ValueListenableBuilder` mechanism, the `Loading` and `Splash` shadow classes get their first (and only permitted) instantiation anywhere in the repo, and findings 13/15/16/25/26 are staged as concrete, inspectable demos (drawer, QR, error-state-with-retry) rather than paper assertions. The actual human walk that observes them — including the light-mode dark-only COUNT this plan exists to produce — is still outstanding; nothing in this plan's own reach can perform it.**

## Performance

- **Duration:** ~35 min
- **Tasks:** 2/2 (mechanical portion complete; verification's human-check portion outstanding)
- **Files modified:** 1 (`lib/dev/design_gallery_screen.dart`)

## Accomplishments

- **Task 1 — missing primitive sections + appearance toggle** (`302a68c`): Added 8 new `_Section`s (`Icons`, `Token row`, `Wallet card`, `Swap FAB`, `Empty / Error / Loading states`, `Screen wrappers`, `Dialog / Bottom sheet`, `Loading (duplicate)`, `Splash (duplicate)` — 9 sections, not 8; see Files below) covering every primitive ROADMAP criterion 1 names that had no gallery section after 03-07. Wrapped the gallery's `Scaffold` in `ValueListenableBuilder<GWAppearanceMode>` on `GWAppearance.instance`, added `GWAppearance.instance.load()` to `initState`, and added an `IconButton` toggle in the `AppBar` — Phase 2's `token_probe_screen.dart` mechanism, copied exactly, not reinvented. The `Loading` and `Splash` shadow imports each carry a comment naming `03-SHADOW-NAMES.md`, stating this file is their sole permitted call site, and explaining why the duplicate is a different widget from develop's canonical class at the other path.
- **Task 2 — the three finding-bound demos** (`6686be2`): Added `Drawer` (opens develop's existing, unmodified `ResponsiveDrawer.show(context:, child: BottomDrawer(...))`, `title`/`actions` omitted per UI-SPEC §4.1 so `BottomDrawer`'s own header doesn't compete with a second `AppBar`), `QR` (renders develop's untouched `CryptoAddressQR` with a sample address and a real bundled icon asset), and `Error state with retry` (a `GWErrorState` with both a custom `message` and `onRetry` supplied, so Retry's presence alongside custom content is directly observable — finding 15).
- **Zero new token values, zero raw color literals** in either commit — every addition uses `GeniusWalletConsts`/`GeniusWalletTypography`/`GeniusWalletColors`/`GWDecorations` exclusively. Confirmed by `grep -cE 'Color\(0x' lib/dev/design_gallery_screen.dart` == 0 after both commits.
- **`flutter analyze lib`: 0 errors, 62 total info/warning issues — identical to the 03-07 baseline.** The gallery file itself carries only the same 2 pre-existing `unnecessary_const` info lints from 03-07's port (inherited verbatim from the reference gallery source, at shifted line numbers).
- **`bash tool/verify_additive_boundary.sh`: PASSED after both commits.** Check 1's allowlist for the `Loading` and `Splash` shadow pairs is non-empty for the first time in the phase (the gallery is now each pair's sole importer, and the guard confirms "no un-allowlisted importers" rather than "zero importers"). Check 2's duplicate-class census is unchanged at 8 names, still a subset of the captured baseline — this plan added new *importers* of already-declared shadow classes, not new duplicate class *declarations*, so Check 2's baseline was correctly never touched (per blocking constraint 2).
- **`responsive_drawer.dart`, `breakpoints.dart`, `crypto_address_qr.dart` all show zero diff against `develop`** — verified by `git diff --name-only develop..HEAD` against all three paths returning empty, both after Task 2's commit.

## Task Commits

1. **Task 1: Add the missing primitive sections and the appearance toggle** — `302a68c` (feat)
2. **Task 2: Stage the three finding-bound demos** — `6686be2` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Modified

- `lib/dev/design_gallery_screen.dart` — 30 `_Section`s total (18 inherited from 03-07 + 12 new: `Icons`, `Token row`, `Wallet card`, `Swap FAB`, `Empty / Error / Loading states`, `Screen wrappers`, `Dialog / Bottom sheet`, `Loading (duplicate)`, `Splash (duplicate)` from Task 1; `Drawer`, `QR`, `Error state with retry` from Task 2)

## Decisions Made

See `key-decisions` in frontmatter. The two load-bearing ones:

1. **Both tasks touch the same single file, as the plan's own `files_modified` declares — split into two atomic commits by writing each task's intended end-state directly**, rather than trying to isolate `git add -p` hunks after a single combined edit pass. `dart format` reformats long lines across the whole file on every pass (not just the touched region), which made hunk-level splitting unreliable; re-deriving each task's exact end-state and committing that was the more honest approach.
2. **`GWIcon.svg`/`.png` demo assets were chosen by reading `pubspec.yaml`'s actual `packages/genius_wallet/assets/images/*` declarations first** (landing on `shape.svg` and `mask2.png`), rather than picking an arbitrary bundled asset and assuming `GWIcon`'s default `package: 'genius_wallet'` parameter would resolve it. `assets/images/crypto/eth.png` exists but is declared in `pubspec.yaml` *without* the `packages/` prefix — it is only reachable via a call site with no `package:` argument (which is how `GWTokenRow` and `CryptoAddressQR` use it in this file), not via `GWIcon.png`'s default-`package` constructor.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `GWIcon.material` demo instance could not be `const`**

- **Found during:** Task 1, first `flutter analyze` pass after writing the `Icons` section
- **Issue:** `error - Invalid constant value - invalid_constant` on `const GWIcon.material(Icons.account_balance_wallet_outlined, color: GeniusWalletColors.textPrimary)`. Root cause: `GeniusWalletColors.textPrimary` is `static Color get textPrimary => _isLight ? _inkLight : Colors.white;` — a non-const getter (it reads live appearance state), so it cannot appear inside a `const` constructor invocation.
- **Fix:** Dropped the `const` keyword on that one `GWIcon.material` instance (the other two `Icons` demo instances, `GWIcon.svg`/`GWIcon.png`, use no color argument and stayed `const`).
- **Files modified:** `lib/dev/design_gallery_screen.dart`
- **Verification:** `flutter analyze lib/dev/design_gallery_screen.dart` — the `invalid_constant` error gone, 0 errors remaining (2 pre-existing info lints unaffected)
- **Committed in:** `302a68c` (Task 1 commit) — fixed before commit, not a follow-up

**Total deviations:** 1 auto-fixed (Rule 1, caught by `flutter analyze` before the commit was made — this is an ordinary `.dart` file, not one of the `.g.dart` files `analysis_options.yaml` excludes, so the analyzer caught it exactly as designed).
**Impact on plan:** None beyond the fix itself — no section's demonstrated behavior changed, only whether one `GWIcon.material` instance could be a compile-time constant.

## Issues Encountered

None beyond the deviation above. No `flutter build windows` run was performed this plan (no `.g.dart` files were touched, and 03-07's canary import already established that the 9 generated widgets compile; this plan's own additions are all ordinary `.dart` files, fully covered by `flutter analyze`'s error-level gate).

## Stub Tracking

No stubs. Every new section wires a real component to real (if synthetic) data — sample addresses, sample balances, a deliberately-broken asset path used specifically to demonstrate `GWTokenRow`'s documented fallback-dot behavior (not a stub; this is the fallback path working as designed). `GWWalletCard`'s two demo instances leave `walletIcon` unset by design, exercising its own documented `CircleAvatar` fallback — same category, not a stub.

## Threat Flags

None. No new network endpoints, auth paths, or trust-boundary-crossing file access. The two shadow-class instantiations (`Loading`, `Splash`) are exactly the demonstration this phase's threat model (T-03-32) anticipated and the guard (`tool/verify_additive_boundary.sh` Check 1) is built to bound — both pass with the gallery as their sole importer, as designed.

## Light-mode reconnaissance (mechanical, NOT a substitute for the human walk)

Before writing this summary, a mechanical grep was run across every ported component and theme file for direct appearance-awareness:

```
$ grep -rl "isLight\|GWAppearance" lib/components/ lib/theme/
lib/theme/genius_wallet_colors.dart
lib/theme/genius_wallet_decorations.dart
lib/theme/gw_appearance.dart
```

**No individual `gw_*` component file references `isLight` or `GWAppearance` directly.** Every component that appears to flip between modes does so *indirectly*, through `GeniusWalletColors`'s getters (e.g. `textPrimary`, `surfaceBase`) resolving differently at read time — the components themselves carry no appearance logic. The two files that DO reference it directly are `genius_wallet_colors.dart` (the token layer itself) and `genius_wallet_decorations.dart` (home to `GWCanvasBackground`'s `if (!isLight)` grain gate, already established as dark-only by the 03-07 walk).

**This tells us WHERE appearance logic lives, not WHICH components look wrong in light mode.** A component can consume flipping tokens correctly and still look poor in light mode for reasons no grep can find (contrast, a hardcoded-looking gradient that happens to use tokens, an icon color that reads fine on `surfaceBase` dark but not light). The dark-only **count** the todo needs can only come from the visual walk below — this reconnaissance is offered purely to orient whoever performs it, not to pre-empt it.

## Walk result (2026-07-17)

**Performed by the human. VERIFIED:** criterion 4 (drawer — root-navigator mount, swipe-to-dismiss,
768 boundary) and the mesh H1/H2 discriminator. **8 findings reported on criteria 1/3.**

**ZERO are port defects.** Every implicated component was `cmp`-verified byte-identical to the
reference before any conclusion was drawn: `gw_switch.dart`, `gw_checkbox.dart`, `gw_token_row.dart`,
`app_screen_view.dart` — all IDENTICAL. Consistent with all 50 files this phase.

### Bucket 1 — the theme confound (5 of 8). ONE root cause. Phase 4's debt.

**Evidence:**
- `GeniusWalletTypography.titleMd` (and every sibling) = `_inter(fontSize:, height:, fontWeight:)` —
  **carries NO color.** Only 2 `color:` mentions in the entire typography file.
- develop's `theme.dart` = `ThemeData(brightness: Brightness.dark, ...)` — **hardcoded dark, no
  `textTheme:`, no `toMaterialTextTheme()`.**
- `toMaterialTextTheme()` is referenced **nowhere** in `lib/` except its own definition
  (`genius_wallet_typography.dart:133`).

Therefore every `Text` styled with `GeniusWalletTypography.*` and no explicit color inherits its
color from the ambient `DefaultTextStyle` → develop's dark `ThemeData` → **white, unconditionally.**
Alex's components correctly delegate color to the theme; **we have not ported a theme that flips.**
His `theme.dart` does (`brightness: isLight ? Brightness.light : Brightness.dark`).

| Finding | Cause |
|---|---|
| Token row value text not changing color | inherits dark theme's white |
| Wallet card text not changing color | same |
| Empty/Error state text not changing color | same |
| Gradient + primary button text font not changing | `toMaterialTextTheme()` never wired |
| Icons white / not flipping / washed light-gray on dark | `iconTheme` inherits `brightness: dark` |

**Not design gaps. Not port defects. The predictable consequence of Phase 2's deferral**
(UI-SPEC §1.1 excludes `theme.dart` wholesale; wiring is Phase 4's). Expect most of this bucket to
evaporate when Phase 4 lands the appearance-aware theme. **Re-walk then; do not "fix" any of it here.**

### Bucket 2 — Alex's own design behavior (byte-identical, real, for Phase 4/6 to weigh)

- **`GWSwitch` disabled is visually identical to off.** `gw_switch.dart:27` computes
  `final disabled = !enabled || onChanged == null;` — **and never uses it for color.** Lines 32–37 set
  `activeColor`/`activeTrackColor`/`inactiveThumbColor`/`inactiveTrackColor` unconditionally, and
  those explicit colors **override Flutter's built-in disabled rendering**. So a disabled switch and
  an off switch are indistinguishable. Byte-identical to Alex — his behavior, not ours.
- **`GWSwitch` off-thumb reads near-black in light.** `inactiveThumbColor:
  GeniusWalletColors.textPrimary` → `_isLight ? _inkLight (0xFF10131A) : Colors.white`. The token is
  behaving exactly as designed; the *design choice* is what reads poorly.
- **`btnDisabled` = `Color.fromRGBO(188, 188, 188, 1)` — a `const`, NOT appearance-aware.** Flagged;
  its role in the invisible-disabled-checkbox report is NOT yet confirmed (see Bucket 3).

### Bucket 3 — UNEXPLAINED. Needs a real repro; no root cause established.

- **`Screen wrappers` renders nothing in EITHER mode.** Partially explained in light
  (`GeniusWalletTypography.bodySm` has no color → white text on the now-light `surfaceBase`), but
  **dark-mode blankness is NOT explained** — white text on a dark surface should be visible.
  `app_screen_view.dart` is byte-identical to Alex's, so this is not a port defect.
  **No hypothesis is recorded as fact here.** Investigate with an actual repro, not by reading.
- **Disabled checkbox invisible in dark.** `gw_checkbox.dart:30` computes `disabled` but the grep did
  not confirm where/whether `btnDisabled` is consumed. Root cause NOT established.

> **Method note.** Bucket 1 is why the dark-only COUNT was NOT recorded. Counting now would measure
> our missing theme, not Alex's design — and would have pointed at "his design system is broken" when
> the truth is "we haven't finished porting it." An earlier claim in this project's own todo
> ("design system may have no complete light mode") was falsified the same day by reading his
> `theme.dart`. Same failure mode: concluding from symptoms before tracing the cause.

## Outstanding: the human walk

**This is the load-bearing gap in this plan's execution.** Every mechanical gate (`flutter analyze`, `tool/verify_additive_boundary.sh`, the zero-diff checks) has run and passed. None of them can observe a rendered pixel, a swipe gesture, or a window resize through a breakpoint. Per this plan's own `<human_check_handling>` and the project's standing precedent (`02-VERIFICATION.md`; reaffirmed by `03-07-SUMMARY.md`'s coverage item D5), an unearned PASS on a human-observation criterion is the exact BLD-02 failure mode this project exists to avoid. **Coverage item D5 above is recorded as `status: outstanding`, not `pass`.**

**Before starting:** close the reference Release exe if it is running (`GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`) — it and the develop debug build share a Hive data directory and deadlock on file locks if both run at once (`02-VERIFICATION.md`, standing environment fact 1). Close one before starting the other, every time you switch.

Run:

```
export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true
```

`CMAKE_BUILD_TYPE=Release` is deliberate — do not "fix" it. Open `Dev` → `Gallery`.

### Criterion 1 — every primitive renders and matches

Walk all 30 sections top to bottom. Nothing blank, no red error box, no missing-asset placeholder. Then open the reference Release exe (close the develop build first) and compare section by section: colors, spacing, radius, typography, elevation. Pay particular attention to the 12 sections new this plan (`Icons`, `Token row`, `Wallet card`, `Swap FAB`, `Empty / Error / Loading states`, `Screen wrappers`, `Dialog / Bottom sheet`, `Loading (duplicate)`, `Splash (duplicate)`, `Drawer`, `QR`, `Error state with retry`) — 03-07's 18 sections already passed a walk once.

### Criterion 3 — light and dark, and the dark-only COUNT

Toggle appearance using the new `AppBar` icon button (sun/moon icon, top-right). Walk **every** section in both modes and **record** each light-mode result.

**Do NOT treat a dark-only component as a failure.** The 03-07 walk established that Alex's design system has components with no light-mode treatment (`GWCanvasBackground`'s grain gated `if (!isLight)`; `GWMeshBackground`'s blobs are invariant brand colors that wash out on the light `surfaceBase`) — both are byte-identical ports, not defects. **Count the dark-only components across all 30 sections and report the number.** That count is what unblocks the pending decision in `.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md`. A section that *errors*, renders a red box, or shows a missing-asset placeholder in light mode IS still a failure — the distinction is "designed dark" vs "broken", not "looks different".

**While here, settle the open H1/H2 question on the mesh:** in light mode, is `GWMeshBackground` a flat blue-gray **wash**, or genuinely **empty**/the same gray as the surrounding surface? And does it look **equally flat and motionless in DARK mode** inside its 180px demo box? If yes to the latter, the cause is demo geometry (blob radius is `0.95 × maxDim`, far larger than a 180px box) — not the design — and no light-mode treatment would fix anything. Report which (H1: dark-designed, low contrast on light / H2: demo-box geometry flattens both modes).

**The `QR` section's quiet zone must stay LIGHT in both modes.** The QR modules are black; if the background ever goes dark you get dark-on-dark and the code stops scanning (finding 16; finding 6 on Banxa, Phase 9, rides the same rule). `CryptoAddressQR`'s background is `Colors.white.withValues(alpha: 0.8)` — theme-invariant by construction — so this should pass by construction, but confirm it visually anyway.

### Criterion 4 — the drawer

Press the `Drawer` section's "Open drawer demo" button, then confirm all three:
- It mounts **over the whole app**, not clipped inside the gallery's own navigator (finding 13).
- At mobile width it can be **swiped down to dismiss** (finding 25).
- **Resize the window across 768px** and confirm it flips to the desktop side-dialog at **exactly 768, not 800** (finding 26). Drag slowly through the boundary.

### Finding 15 — error state with retry

In `Error state with retry`, confirm the **Retry button renders** alongside the custom message ("Could not load your balances...").

### Report format

For each of the four items above, report what was observed — including the exact dark-only count and the H1/H2 verdict on the mesh. If any section does not match the reference exe, describe the difference; do not judge whether it matters, that is the fidelity record's job (per this plan's own `<verification>` block).

## Next Phase Readiness

- **DS-03 closes on the mechanical side this plan.** The gallery now has a section for every primitive ROADMAP criterion 1 names (30 sections total), a live appearance toggle, and the three finding-bound demos are wired and ready to be walked. `flutter analyze` is clean, the shadow guard passes with its allowlist now proven non-empty, and the three protected collision files remain byte-identical to develop.
- **What this plan does NOT establish, for 03-10 to carry verbatim:** the human walk itself (criteria 1, 3, 4, and finding 15's actual observed outcomes) and the light-mode dark-only **count**. Both are prerequisites 03-10's own verification record needs, and neither can be produced by an executor without GUI access.
- **No blockers for 03-10 beyond the walk itself.** The gallery's structure, imports, and the `_Section(title:, child:)` pattern are stable and require no further code changes to be walked.

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-17*

## Self-Check: PASSED
