---
phase: 03-gw-component-library
plan: 06
subsystem: ui
tags: [flutter, gw-components, port, qr, dropdowns, sgnus, splash-shadow, finding-16]

# Dependency graph
requires:
  - phase: 03-02
    provides: "components/inputs/gw_select.dart -- consumed by currency_dropdown.dart, sgnus_connected_dropdown.dart"
  - phase: 03-04
    provides: "components/wallet_preview.g.dart -- consumed by sgnus/sgnus_wallet.dart"
provides:
  - "GWQrScanner + extractWalletAddress parser -- parse-only QR surface, unconsumed until Phase 7/10"
  - "currency_dropdown.dart, custom_drop_down.dart -- two dropdown primitives, both orphaned pending Banxa phase"
  - "SGNUS pair (sgnus_connected_dropdown.dart, sgnus_wallet.dart), coin_card_container.dart, number_pad.dart, toast/ticker_provider.dart -- specialist/misc primitives"
  - "The third and final shadow file: components/splash.dart (Splash), landed with zero importers, canonical lib/screens/splash.dart and router.dart untouched"
  - "The 50th file: DS-02's full 50-file port set is now on develop"
affects: [03-09, 03-10, 04, 05, 07, 09, 10]

tech-stack:
  added: []
  patterns:
    - "Missing token precedent (3rd occurrence, after brandGreen/btnDisabled): GeniusWalletColors.gray500 (alias for textSecondary) was absent from Phase 2's port -- verified zero prior references, ported verbatim from the reference worktree as a one-line alias next to textSecondary."
    - "Guard-boundary fix, new pattern for this phase: when a verbatim port's own import would cross a shadow's allowlist boundary (Splash importing the Loading shadow, disallowed), the fix is applied in the NEW file's import (repoint to canonical), and the guard's pinned exact-match importer list is updated in the same commit -- distinguished explicitly from Check 2's protected duplicate-class census, which must never be silently extended."

key-files:
  created:
    - lib/components/qr_scanner/gw_qr_scanner.dart
    - lib/components/currency_dropdown.dart
    - lib/components/custom_drop_down.dart
    - lib/components/sgnus/sgnus_connected_dropdown.dart
    - lib/components/sgnus/sgnus_wallet.dart
    - lib/components/coins/view/coin_card_container.dart
    - lib/components/number_pad.dart
    - lib/components/toast/ticker_provider.dart
    - lib/components/splash.dart
  modified:
    - lib/theme/genius_wallet_colors.dart
    - tool/verify_additive_boundary.sh
    - .planning/phases/03-gw-component-library/03-SHADOW-NAMES.md

key-decisions:
  - "[Rule 2 - missing token] GeniusWalletColors.gray500 was absent from develop -- the whole alias block the reference worktree carries around it (blue500, foundationWhite, foundationBlack, gray900, darkGreen, containerGray, gray600) is ALSO absent, but only gray500 is referenced by anything in this plan's 9 files (verified: grep for each sibling name across lib/ found zero usages), so only gray500 was ported -- not the whole block. Added as a one-line alias (`static const Color gray500 = textSecondary;`) next to textSecondary, matching the reference's own definition exactly."
  - "[Rule 3 - guard boundary] The reference's splash.dart imports the Loading SHADOW (components/loading/loading.dart), which 03-SHADOW-NAMES.md restricts to design_gallery_screen.dart only. Splash.dart is itself a shadow file and may not add a second un-allowlisted importer to another shadow. Repointed the import to develop's canonical lib/components/loading.dart instead -- both classes declare an identical `{String? text}` constructor, so the `const Loading()` call site is byte-for-byte unchanged; only the import line differs from the reference. This makes splash.dart the canonical Loading's 19th legitimate importer, so tool/verify_additive_boundary.sh's exact-match LOADING_CANONICAL_EXPECTED list and 03-SHADOW-NAMES.md's importer count/list were both updated in the same commit, with an inline comment explaining why. This is NOT a guard loosening: Check 1's canonical-importer list is designed to be an accurate, deliberately-updated inventory (it exists to catch silent swaps, not to freeze the codebase); Check 2's duplicate-class-name census (tool/shadow-baseline.txt) is the check that must never be silently extended, and it was not touched."

requirements-completed: [DS-02]

coverage:
  - id: D1
    description: "All 9 files exist at their verified paths; 7 of 9 byte-identical to the reference worktree, currency_dropdown.dart/custom_drop_down.dart/gw_qr_scanner.dart identical, sgnus pair/coin_card_container/number_pad/ticker_provider identical, splash.dart carries the required head comment plus the one documented import-repoint deviation"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "test -f for all 9 verified paths (all present); cmp -s against reference worktree for the 8 non-splash files -- all IDENTICAL; splash.dart diverges only at the head comment (added, required by plan) and the Loading import (repointed, documented deviation)"
        status: pass
    human_judgment: false
  - id: D2
    description: "GWQrScanner is parse-only (no validation added), currency_dropdown.dart binds genius_api's Currency with zero lib/preferences/ reference, no WIRE- marker landed"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "grep -q package:mobile_scanner in gw_qr_scanner.dart (pass); grep -c genius_wallet/preferences in currency_dropdown.dart == 0 (pass); grep -q genius_api in currency_dropdown.dart (pass); grep -rc WIRE- across the 3 task-1 files == all :0 (pass)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The Splash shadow lands with ZERO importers; lib/screens/splash.dart and lib/navigation/router.dart show zero diff and router still imports the canonical path; the collision siblings (string_button.dart, coin_card_row.dart, sgnus_connection_widget.dart) are untouched"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "git diff --name-only -- lib/screens/splash.dart lib/navigation/router.dart returned empty; grep -q package:genius_wallet/screens/splash.dart in router.dart matched; grep -rl package:genius_wallet/components/splash.dart lib/ | wc -l == 0; git diff --name-only -- lib/components/string_button.dart lib/components/coins/view/coin_card_row.dart lib/components/sgnus/sgnus_connection_widget.dart returned empty"
        status: pass
    human_judgment: false
  - id: D4
    description: "finding 16 not regressed -- crypto_address_qr.dart remains zero-diff and still uses a theme-invariant Colors.white.withValues(alpha: 0.8) background"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "git diff --name-only -- lib/components/qr/crypto_address_qr.dart returned empty; grep confirmed Colors.white.withValues(alpha: 0.8) still present at line 26"
        status: pass
    human_judgment: false
  - id: D5
    description: "flutter analyze lib reports 0 errors after both task commits (60 total info/warning issues -- net +6 from 03-05's 54-issue baseline: 2 new info lints on custom_drop_down.dart, plus 4 new use_super_parameters/info lints spread across coin_card_container.dart, number_pad.dart, sgnus_wallet.dart, splash.dart)"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "flutter analyze lib -- 0 errors, 60 issues (info/warning only), confirmed after both task commits and after the two deviation fixes"
        status: pass
    human_judgment: false
  - id: D6
    description: "tool/verify_additive_boundary.sh exits 0 after both task commits, including after the Loading canonical-importer-list update"
    requirement: "DS-02"
    verification:
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED (exit 0): Check 1 (shadow import boundary) PASS x6 including Loading's now-19-file canonical list, Check 2 (duplicate-class census, still 8 names -- Splash added the class name pair already tracked, subset of baseline) PASS, Check 3 (WIRE- tripwire) PASS"
        status: pass
    human_judgment: false
  - id: D7
    description: "Visual/render correctness of the 9 new files, and the cold-start boot-path proof that router.dart still resolves to develop's splash"
    human_judgment: true
    rationale: "Dart-only additions, nothing imports any of the 9 files yet -- no build() is called, nothing changes on screen. The one dynamic proof this plan's own verify block calls for -- a cold start showing develop's splash, reaching the dashboard -- is explicitly deferred to plan 03-10's phase walk per the plan's own <verify><human-check>, which this plan cannot perform (the user holds the running debug session and its Hive data dir; launching a second instance is prohibited by this plan's own constraints)."

# Metrics
duration: 13min
completed: 2026-07-16
status: complete
---

# Phase 3 Plan 06: QR, Dropdowns, SGNUS, and the Splash Shadow Summary

**Ported the last 9 in-scope files -- the QR scanner, two dropdowns, the SGNUS pair, and four misc helpers including the third and final shadow (`Splash`) -- completing DS-02's 50-file port set, with one missing-token deviation and one guard-boundary deviation, both mechanical and documented.**

## Performance

- **Duration:** 13 min
- **Started:** 2026-07-16T21:19:40Z (approx)
- **Completed:** 2026-07-16T21:32:49Z
- **Tasks:** 2/2
- **Files modified:** 12 (9 created, 3 modified: `genius_wallet_colors.dart`, `tool/verify_additive_boundary.sh`, `03-SHADOW-NAMES.md`)

## Accomplishments
- Ported `GWQrScanner` + `extractWalletAddress` (`qr_scanner/gw_qr_scanner.dart`) verbatim -- parse-only (plain/EIP-681/EIP-681-transfer/BIP-21 forms), no validation added, resolves `package:mobile_scanner` (landed 03-01)
- Ported `currency_dropdown.dart` verbatim -- confirmed it binds `genius_api`'s `Currency`, zero reference to `lib/preferences/` (WIRE-7/WIRE-02 out of scope)
- Ported `custom_drop_down.dart` (`AppDropdown<T>`) verbatim -- distinct from `GWSelect`, not consolidated
- Ported `sgnus/sgnus_connected_dropdown.dart` and `sgnus/sgnus_wallet.dart` verbatim -- their contract was not independently derived by the UI-SPEC; ported as-is per that document's own instruction
- Ported `coins/view/coin_card_container.dart` verbatim -- orphaned even on the source branch, landed for inventory completeness
- Ported `number_pad.dart` verbatim -- uses develop's existing (collision, untouched) `StringButton`
- Ported `toast/ticker_provider.dart` verbatim -- supporting class for the existing (collision, untouched) toast system
- Ported `components/splash.dart` (`Splash`, the third and final shadow) with the required `SHADOW-NAMES` head comment. Confirmed `lib/screens/splash.dart` and `lib/navigation/router.dart` remain zero-diff, router still imports the canonical path, and the shadow has zero importers.
- `flutter analyze lib`: 0 errors (60 total info/warning issues, +6 from 03-05's baseline)
- `bash tool/verify_additive_boundary.sh`: PASSED after both task commits (including after the Loading canonical-list update)
- **50/50 in-scope files landed. DS-02's port is complete.**

## Task Commits

Each task was committed atomically:

1. **Task 1: Port the QR scanner and the two dropdowns** - `af79e30` (feat)
2. **Task 2: Port the SGNUS pair, the misc helpers, and the Splash shadow** - `af34c50` (feat)

**Plan metadata:** committed separately after this summary via the standard final-commit step.

## Files Created/Modified
- `lib/components/qr_scanner/gw_qr_scanner.dart` - `GWQrScanner` + `extractWalletAddress`; full-screen QR scanner and payload parser, parse-only by design (validation is WIRE-3, Phase 7/10)
- `lib/components/currency_dropdown.dart` - `CurrencyDropdown`; thin `GWSelect<Currency>` wrapper over `genius_api`'s `Currency`
- `lib/components/custom_drop_down.dart` - `AppDropdown<T>`; generic dropdown, distinct from `GWSelect`, caller is a collision file (`banxa_buy_screen.dart`, Phase 9)
- `lib/components/sgnus/sgnus_connected_dropdown.dart` - `SGNUSConnectedDropdown`; SGNUS-specific `GWSelect` wrapper, contract not independently derived
- `lib/components/sgnus/sgnus_wallet.dart` - `SGNUSWallet`; SGNUS balance display, wraps `WalletPreview` (03-04's `wallet_preview.g.dart`)
- `lib/components/coins/view/coin_card_container.dart` - `CoinCardContainer`; card chrome wrapper, orphaned even on the source branch
- `lib/components/number_pad.dart` - `NumberPad`; 4-digit PIN entry, uses develop's existing `StringButton`
- `lib/components/toast/ticker_provider.dart` - `ToastTickerProvider`; `TickerProvider` implementation supporting the existing toast system
- `lib/components/splash.dart` - `Splash` (the third shadow); verbatim port + required head comment + the one documented import-repoint deviation
- `lib/theme/genius_wallet_colors.dart` - added `gray500` alias (Rule 2, see Deviations)
- `tool/verify_additive_boundary.sh` - added `lib/components/splash.dart` to the pinned canonical `Loading` importer list (Rule 3, see Deviations)
- `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` - updated `Loading`'s importer count (18 -> 19) and list, with a note explaining the addition

## Decisions Made
- Ported only the `gray500` alias from the reference's larger, still-absent color-alias block (`blue500`, `foundationWhite`, `foundationBlack`, `gray900`, `darkGreen`, `containerGray`, `gray600`) -- verified none of the siblings is referenced by anything in this plan or the tree today, so only the one blocking token was added, not the whole block
- Repointed `splash.dart`'s `Loading` import from the reference's shadow path to develop's canonical path, rather than extending the `Loading` shadow's allowlist to include `splash.dart` -- keeps the shadow's exposure exactly as narrow as 03-SHADOW-NAMES.md originally scoped it (gallery only), and both `Loading` implementations have an identical constructor so the call site is unaffected

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 2 - Missing critical functionality / missing token] `GeniusWalletColors.gray500` absent from develop**
- **Found during:** Task 2 (`flutter analyze` after porting `sgnus/sgnus_wallet.dart`)
- **Issue:** `flutter analyze` reported two hard errors on `sgnus_wallet.dart:38`: `undefined_getter` (`GeniusWalletColors.gray500` does not exist) and `invalid_constant` (the same expression sits inside a `const GeniusBalanceDisplay(...)` constructor, so the undefined getter also breaks constant-folding). Root cause: the reference worktree's `genius_wallet_colors.dart` carries a small alias block (`blue500`, `foundationWhite`, `foundationBlack`, `gray900`, `gray500 = textSecondary`, `darkGreen`, `containerGray`, `gray600`) that Phase 2's port never carried over -- the same class of gap as `brandGreen` (03-03) and `btnDisabled` (03-04). Verified zero prior references to `gray500` (or any of its siblings) anywhere in the tree before this fix.
- **Fix:** Added `static const Color gray500 = textSecondary;` verbatim from the reference worktree, placed directly beside develop's existing `textSecondary` definition. Did not port the other 7 sibling aliases in the same reference block -- none is referenced by anything in this plan's files or anywhere else in the tree, so adding them would be scope creep beyond what this task needs.
- **Files modified:** `lib/theme/genius_wallet_colors.dart`
- **Verification:** `flutter analyze lib/components/sgnus/sgnus_wallet.dart` -- 0 errors (from 2); `flutter analyze lib` -- 0 errors overall
- **Committed in:** `af34c50` (Task 2 commit)

---

**2. [Rule 3 - Blocking / guard boundary] `splash.dart`'s `Loading` import crossed the shadow's allowlist**
- **Found during:** Task 2 (`bash tool/verify_additive_boundary.sh` after porting `splash.dart` verbatim, including its original `import 'package:genius_wallet/components/loading/loading.dart';`)
- **Issue:** The guard's Check 1 failed: `FAIL [Loading]: shadow path '...components/loading/loading.dart' is imported outside its allowlist by: lib/components/splash.dart`. Root cause: the reference's `Splash` genuinely consumes the reference's own re-skinned `Loading` (the shadow, at `components/loading/loading.dart`), but `03-SHADOW-NAMES.md`'s binding rule restricts that shadow's only permitted importer to `lib/dev/design_gallery_screen.dart` -- `splash.dart` (itself a shadow file) is not on that allowlist and must not become a second one, even though this is exactly what the reference source does.
- **Fix:** Repointed `splash.dart`'s import from the shadow (`components/loading/loading.dart`) to develop's canonical (`components/loading.dart`). Both declare `class Loading extends StatelessWidget` with an identical `{String? text}` constructor (verified by reading both files), so the `const Loading()` call site is byte-for-byte unchanged -- only the import line differs from the reference, with an inline comment explaining why. This makes `splash.dart` the canonical `Loading`'s 19th legitimate importer, which required updating `tool/verify_additive_boundary.sh`'s exact-match `LOADING_CANONICAL_EXPECTED` list (Check 1 asserts an exact, sorted match specifically to catch silent swaps -- a new file legitimately starting to import the canonical path is exactly the kind of change that list exists to record, not hide) and `03-SHADOW-NAMES.md`'s importer count/list, both in the same commit as the code change. **This is distinct from `tool/shadow-baseline.txt`** (Check 2's protected duplicate-class-name census, which this deviation did NOT touch) -- Check 1's canonical-importer list is a deliberately-maintained inventory, not a security boundary that must never move.
- **Files modified:** `lib/components/splash.dart`, `tool/verify_additive_boundary.sh`, `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md`
- **Verification:** `bash tool/verify_additive_boundary.sh` -- PASSED (all 3 checks); re-confirmed the `Splash`-pair checks specifically (canonical `screens/splash.dart` importer set still exactly `lib/navigation/router.dart`; shadow `components/splash.dart` still has zero importers) unaffected by this fix
- **Committed in:** `af34c50` (Task 2 commit)

---

**Total deviations:** 2 auto-fixed (1 Rule 2, 1 Rule 3)
**Impact on plan:** Both were necessary for the plan's own files to compile and pass the guard. Neither touches a collision file's behavior, neither changes anything reachable from `main.dart` (the new `gray500` alias and the `splash.dart`-as-Loading-importer are both inert until something imports `splash.dart` or reads `gray500` from a reachable code path -- neither does today). `lib/screens/splash.dart` and `lib/navigation/router.dart` remain byte-for-byte untouched by both deviations.

## Issues Encountered
None beyond the two deviations documented above.

## Stub Tracking
No stubs. All 9 new files are complete, verbatim (or the two documented-deviation) ports of finished hand-written source; none contains a hardcoded empty value or placeholder pending future wiring. None is reachable from `main.dart` this phase -- that dormancy is the plan's explicit, accepted design, not a stub.

## The Two Things That Mattered Here

**1. `components/splash.dart` landed with ZERO importers.** Explicit confirmation:
- `git diff --name-only -- lib/screens/splash.dart lib/navigation/router.dart` returns empty -- both files are byte-for-byte unchanged.
- `lib/navigation/router.dart:30` still reads `import 'package:genius_wallet/screens/splash.dart';` -- the canonical, `StatelessWidget` boot splash.
- `grep -rl 'package:genius_wallet/components/splash.dart' lib/` returns zero results -- nothing in the tree imports the shadow yet.
- The shadow carries its required head comment (`SHADOW-NAMES` reference, full hazard explanation, migration requirement).
- The one deviation this plan needed (repointing `splash.dart`'s internal `Loading` import) touches only `splash.dart` itself and the guard's tracking artifacts -- it does not touch `lib/screens/splash.dart` or `router.dart`, and does not add any new importer of `splash.dart` itself.

**2. `crypto_address_qr.dart` (finding 16) was NOT regressed.** Explicit confirmation:
- `git diff --name-only -- lib/components/qr/crypto_address_qr.dart` returns empty -- this plan did not touch it (it wasn't in scope; confirming zero-diff per the plan's own verification requirement).
- Its QR background remains `Colors.white.withValues(alpha: 0.8)` (line 26) -- a theme-invariant light constant, never bound to `textPrimary`/`textPrimary*` or any appearance-flipping token.
- The new `GWQrScanner` ported this plan (`qr_scanner/gw_qr_scanner.dart`) does not render a QR code itself (it's a camera scanner surface, not a QR-generation surface) and introduces no theme-aware background of its own -- no new QR surface to check against finding 16.

## User Setup Required

None. All 9 new files are Dart-only; `genius_wallet_colors.dart` gained one alias constant, no `pubspec.yaml` change. The user's running debug session can pick these up via hot reload (`r`), but there is nothing to see: none of the 9 files is imported by anything reachable from `main.dart` yet, and `gray500` is consumed only by the still-unconsumed `sgnus_wallet.dart`.

## Next Phase Readiness

- **9/9 of this plan's files landed: `flutter analyze lib` 0 errors, additive-boundary guard green after both task commits.**
- **Running count: 41 (03-01 through 03-05) + 9 (this plan) = 50/50 in-scope files now on develop. DS-02's 50-file port is complete.**
- All three shadow classes (`Loading`, `Splash`, `WalletsOverview`) are now landed: unconsumed except for the two allowlisted, gated exceptions (the not-yet-built `design_gallery_screen.dart` for `Loading`/`Splash`, and 03-04's compile canary for `WalletsOverview`), each gated by `tool/verify_additive_boundary.sh`, each documented in `03-SHADOW-NAMES.md`.
- WIRE-3's binding note (Phase 7): `GWQrScanner`'s `extractWalletAddress` is parse-only; develop's real validation must win whenever Phase 7/10 wires `send_screen.dart` -- never adopt the reference's `recipient.length >= 6` check.
- SGNUS non-derivation note (Phase 5/7/whichever phase eventually wires the SGNUS pair): `sgnus_connected_dropdown.dart` and `sgnus_wallet.dart`'s contracts were not independently verified by the UI-SPEC (recorded there as "low-risk, additive, port as-is") -- this plan did not add independent verification either; it is still an open, accepted gap at the component-contract level, not a rendering gap.

**What this plan does NOT establish, for plan 03-09/03-10 to carry verbatim:** render correctness of any of the 9 new files, and the cold-start boot-path proof (the FIRST thing plan 03-10's phase walk observes) that a fresh launch still shows develop's `Splash` and reaches the dashboard. Nothing calls `build()` on any of these 9 files this plan (no consumer exists yet) -- this is an accepted gap (see coverage item D7), not a deferred PASS. This plan could not perform that proof itself: the user holds the running debug session and its Hive data directory, and launching a second instance is explicitly prohibited by this plan's own constraints.

**Outstanding for the human:**
1. The cold-start boot-path walk (plan 03-10) -- confirm a fresh launch still resolves to develop's `Splash`/`screens/splash.dart` and reaches the dashboard, exactly as before this phase.
2. The full render walk of all 50 files, including this plan's 9, through `/design_gallery` (plans 03-07/03-09 build the gallery; 03-10 records the walk).
3. QR-scanner-specific: the plan's own note that camera permission/entitlement configuration (`NSCameraUsageDescription`, `CAMERA`) is required natively and is not testable in this UI-only stub build -- carried forward, not this plan's job to resolve.

---
*Phase: 03-gw-component-library*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 9 created files confirmed present on disk. Both task commits (`af79e30`, `af34c50`) confirmed present in `git log --oneline --all`.
