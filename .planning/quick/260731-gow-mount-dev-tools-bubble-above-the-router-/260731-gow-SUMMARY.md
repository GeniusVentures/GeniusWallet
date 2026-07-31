---
phase: quick-260731-gow
plan: 01
subsystem: ui
tags: [flutter, go_router, dev-tools, overlay, drawer, toast]

requires: []
provides:
  - "DevToolsBubbleHost (lib/dev/dev_tools_host.dart), the dev bubble's single mount point above the app's root Navigator"
  - "DevToolsBubble takes an explicit GoRouter and derives an app-navigator context for its actions (drawer .show, ToastManager, cubit reads, NAVIGATE pushes)"
  - "ToastManager.showToast falls back to Navigator.of(context).overlay when the given context has no ancestor Overlay"
affects: [dev-tools, drawer, toast]

tech-stack:
  added: []
  patterns:
    - "Overlay.wrap(child: ...) to give a widget mounted above the root Navigator its own local Overlay, so Tooltip/OverlayEntry-based descendants still resolve"

key-files:
  created:
    - lib/dev/dev_tools_host.dart
    - test/dev/dev_tools_bubble_above_barrier_test.dart
  modified:
    - lib/main.dart
    - lib/components/overlay/responsive_overlay.dart
    - lib/dev/dev_tools_bubble.dart
    - lib/components/toast/toast_manager.dart
    - test/dev/dev_tools_bubble_persistence_test.dart

key-decisions:
  - "D-01: DevToolsBubbleHost is a stateless sibling of GlobalSwapFabHost, not an extension of it - the FAB's route-listening machinery has no dev-bubble use, and D-04 rules out a hidden-path set."
  - "D-02: enabled defaults to the const expression kDebugMode && kShowDevTools on the host, not a hard-coded check on the bubble - main.dart passes nothing, the regression test passes enabled: true."
  - "D-03: DevToolsBubble takes a GoRouter and derives _appNavigatorContext = router.routerDelegate.navigatorKey.currentContext ?? context, rebinding all 18 context.read, ~25 showToast(context:), and 6 drawer .show(context) calls in one substitution at the _buildExpandedPanel call site."
  - "D-04 (re-checked against the real route list, holds): no hidden-path set for the bubble. It is draggable, collapses to 48px, and is gated behind a dart-define off in every build not opted into."
  - "D-05: MobileOverlay/DesktopOverlay keep their now-single-child Stacks, each with a comment, because Scaffold lays its body out under loose constraints and a Stack forces full-body sizing."
  - "Deviation (Rule 1/3, found running Task 3's test): GWButton's tooltip calls Overlay.of(context) on its OWN ancestor chain, independent of the _appNavigatorContext rebinding, and the new mount point has no Overlay ancestor above the root Navigator at all. Fixed by wrapping DevToolsBubble in Overlay.wrap(child: ...) inside DevToolsBubbleHost - Flutter's own sanctioned API for exactly this case."

requirements-completed: [QUICK-260731-GOW]

coverage:
  - id: D1
    description: "A tap on the dev-tools bubble expands the panel and leaves an open drawer open (the reported bug is fixed)"
    requirement: "QUICK-260731-GOW"
    verification:
      - kind: unit
        ref: "test/dev/dev_tools_bubble_above_barrier_test.dart#Test 1 (the bug): a tap on the dev bubble expands the panel and leaves an open drawer open, and the exception does not leak into the barrier's own dismissal behaviour"
        status: pass
    human_judgment: false
  - id: D2
    description: "A tap anywhere else on the drawer's barrier still closes it, exactly as before (dismissal is not weakened)"
    requirement: "QUICK-260731-GOW"
    verification:
      - kind: unit
        ref: "test/dev/dev_tools_bubble_above_barrier_test.dart#Test 1 (the bug): ... (same test, barrier-tap assertion) and #Test 2 (the guard): a tap on the barrier away from the drawer and the collapsed bubble closes the drawer, exactly as before this change"
        status: pass
    human_judgment: false
  - id: D3
    description: "Every dev-panel button still works from the new mount (cubit reads, toasts, drawer demos, both NAVIGATE pushes)"
    verification:
      - kind: unit
        ref: "test/dev/dev_tools_bubble_persistence_test.dart (both tests, updated harness) plus flutter analyze clean"
        status: pass
    human_judgment: false

duration: not independently timed (quick task)
completed: 2026-07-31
status: complete
---

# Quick Task 260731-gow: Mount the dev-tools bubble above the router Summary

**Re-homed `DevToolsBubble` from two in-page `Stack` mounts (`responsive_overlay.dart`) to a single `DevToolsBubbleHost` above `MaterialApp.router`'s root Navigator, so a drawer's `showDialog` barrier no longer eats the panel's taps.**

## Accomplishments

- Created `lib/dev/dev_tools_host.dart`'s `DevToolsBubbleHost`, a stateless sibling of `GlobalSwapFabHost`, mounted in `main.dart` outside `GlobalSwapFabHost` (dev tool never occluded by the swap FAB) and inside `DevicePreview.appBuilder` (stays within the simulated device frame).
- Deleted both old bubble mounts (`MobileOverlay`/`DesktopOverlay` in `responsive_overlay.dart`); each now-single-child `Stack` is kept with a comment explaining why (Scaffold's loose body constraints).
- `DevToolsBubble` now takes a `router: GoRouter` and derives an app-navigator `BuildContext` (`_appNavigatorContext`) for every panel action, rebound in one substitution at the `_buildExpandedPanel` call site.
- Both NAVIGATE pushes (`/dev/token-probe`, `/design_gallery`) converted from `context.push` to `widget.router.push`, matching `GlobalSwapFabHost`'s own precedent.
- `ToastManager.showToast` now resolves `Overlay.maybeOf(context) ?? Navigator.of(context).overlay!`, so a toast fired from the app-navigator context still finds an overlay.
- New two-sided regression test proving both halves of the fix in one place, plus a separate guard test.
- Updated `dev_tools_bubble_persistence_test.dart`'s two harnesses for the new required `router` parameter (a trivial standalone `GoRouter`, exercising the `?? context` fallback since its Navigator never mounts).

## Files Created/Modified

- `lib/dev/dev_tools_host.dart` (new) - `DevToolsBubbleHost`, the single mount point
- `lib/main.dart` - wraps `GlobalSwapFabHost` with `DevToolsBubbleHost`, added import
- `lib/components/overlay/responsive_overlay.dart` - both bubble mounts deleted, single-child `Stack`s kept with a comment, three now-unused imports removed (`flutter/foundation.dart`, `dev/dev_flags.dart`, `dev/dev_tools_bubble.dart`)
- `lib/dev/dev_tools_bubble.dart` - `router` field, `_appNavigatorContext` getter, rebind at the `_buildExpandedPanel` call site, both NAVIGATE pushes converted, two stale doc comments rewritten
- `lib/components/toast/toast_manager.dart` - `Overlay.of` to `Overlay.maybeOf(context) ?? Navigator.of(context).overlay!`
- `test/dev/dev_tools_bubble_above_barrier_test.dart` (new) - the two-sided regression test
- `test/dev/dev_tools_bubble_persistence_test.dart` - harness updated for the new required `router` argument

## Decisions Made

See the `key-decisions` frontmatter block above (D-01 through D-05, all decided during planning and implemented as specified) plus the one deviation below.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1/3 - Bug/Blocking] `GWButton`'s `Tooltip` has no `Overlay` ancestor at the new mount point**

- **Found during:** Task 3, first run of the new regression test - every panel button that passes a `tooltip` (e.g. "Long / extreme values", "Missing icon scenario") threw `No Overlay widget found` the instant the panel expanded.
- **Issue:** `GWButton` wraps itself in a `Tooltip` when `tooltip` is given, and `Tooltip` calls `Overlay.of(context)` on **its own ancestor chain in the real widget tree** - a fact independent of the `_appNavigatorContext` rebinding, which only changes the `context` value used *inside* `_buildExpandedPanel`'s body for `context.read`/`showToast`/`.show()` calls. The panel's actual mounted position in the tree is still wherever `DevToolsBubble` itself sits: above the root Navigator, where (per `WidgetsApp`/`MaterialApp.router`'s own structure) there is no `Overlay` ancestor at all - `Navigator` builds its `Overlay` as a *child* of itself, not above it.
- **Fix:** Wrapped `DevToolsBubble(router: router)` in `Overlay.wrap(child: ...)` inside `DevToolsBubbleHost.build()` - Flutter's own sanctioned convenience API for exactly this ("wrap the provided child in an Overlay to allow other visual elements to float on top of it"). This gives the whole panel subtree a local `Overlay` to resolve `Tooltip` (and anything else `OverlayEntry`-based) against, with no effect on where the panel itself renders: `DevToolsBubble.build()`'s `Positioned` still positions against this `Overlay`'s own internal `Stack`, which fills the same space a bare `Positioned` did (`ToastManager` calls are unaffected either way - they already go through `_appNavigatorContext`, which resolves the app's real root Navigator overlay).
- **Files modified:** `lib/dev/dev_tools_host.dart`
- **Verification:** `flutter test test/dev/` - all 19 tests pass, including every "MOCK" section button with a tooltip now rendering under `pumpAndSettle()` with no exception. Full `flutter test` - 849/849, no new failures.
- **Committed in:** not committed (standing rule - see below)

---

**Total deviations:** 1 auto-fixed (Rule 1/3 - a real crash discovered by the plan's own regression test, directly caused by this plan's mount-point change)
**Impact on plan:** Necessary for correctness - every panel button with a tooltip would have thrown the instant the panel was expanded in the real app, which the plan's own "every dev-panel button still works" success criterion requires. No scope creep: the fix is confined to the new host file.

## Issues Encountered

None beyond the deviation above. One self-correction, not a deviation: the regression test's first draft computed the bubble/panel's clamp geometry using `edgeInset = 4`; the real constant (`GeniusWalletConsts.space4`) is `8.0`. The test's `Offset(100, 700)` guard point was unaffected either way (it is far outside both the drawer's and the bubble's occupied x-range regardless), but the derivation comments were corrected to the real numbers (`right: 8, top: 76`) before finishing, so the comments describe what the code actually does rather than a plausible-looking approximation.

## Verification (real numbers)

1. **`flutter analyze` (root):** `No issues found!` - 0/0, matches the 0/0 baseline.
2. **`flutter analyze` (genius_api):** `No issues found!` - 0/0.
3. **Full `flutter test`:** `849/849` passing (`847` baseline + `2` new cases in `dev_tools_bubble_above_barrier_test.dart`), no failures. Several pre-existing `RenderFlex overflowed` warnings print during the run (`gw_page_header.dart`, `token_info_screen.dart`, `coin_page_range_tile_test.dart` fixtures) - these are unrelated to this plan's files and print in the baseline run too; they are warnings inside otherwise-passing tests, not failures.
4. **`./tool/check_brace_style.sh`:** exit 0, no output - PASS.
5. **`./tool/check_raw_colors.sh`:** exit 0, no output - PASS. `lib/dev` is in this script's covered path list, so `dev_tools_host.dart` was scanned and contains no raw `Color`/`Colors.*`.
6. **`dart format`** on every touched file: `Formatted 7 files (0 changed)` - already correctly formatted (0 changes needed) after all edits.
7. **`grep -rn "DevToolsBubble(router:" lib/`:** exactly one line (`lib/dev/dev_tools_host.dart`) - the mount is singular.
8. **Working tree:** dirty and uncommitted at the end (see below) - nothing was committed or staged by this task.

### Does a tap on the dev panel leave the drawer open, and does a tap elsewhere still close it?

**Yes to both, proven by two different assertions in `test/dev/dev_tools_bubble_above_barrier_test.dart`:**

- **"leaves it open" half:** `Test 1 (the bug): a tap on the dev bubble expands the panel and leaves an open drawer open, and the exception does not leak into the barrier's own dismissal behaviour` - after `tester.tap(find.byIcon(Icons.bug_report))` while the drawer is open, the test asserts BOTH `find.text('DRAWER BODY')` is still `findsOneWidget` AND `find.byIcon(Icons.close)` (the panel's own X, unambiguous here because the harness's drawer is given no title) is `findsOneWidget` - the second assertion is what proves the tap reached the bubble rather than being silently swallowed by the barrier underneath it (`tester.tap` only warns, never fails, on a missed target).
- **"still closes it" half, proven twice:** (a) in the *same* Test 1, immediately after the panel-expand assertions, `tester.tapAt(Offset(100, 700))` (derived to be clear of both the drawer at x∈[780,1200] and the expanded panel at x∈[932,1192]) is asserted to make `DRAWER BODY` `findsNothing` - proving the panel's tap-exception is scoped to the panel and did not leak into the barrier's general behaviour, even with the panel still expanded on screen. (b) `Test 2 (the guard): a tap on the barrier away from the drawer and the collapsed bubble closes the drawer, exactly as before this change` repeats the same barrier tap with the bubble in its default collapsed state, as an isolated control.

`git diff -- lib/components/bottom_drawer/responsive_drawer.dart` is empty - `isDismissible` and the rest of `ResponsiveDrawer.show` are byte-identical to before this plan.

## Required Finding 1: what the clamp constants mean now

**`_headerHeight = GeniusWalletConsts.appBarHeight` (68) was double-counting the app bar before this fix, and is only now literally true - on the screens that have that app bar at all.**

Before: `DevToolsBubble` lived inside `MobileOverlay`/`DesktopOverlay`'s `Stack`, which is the `body:` of a `Scaffold` that already has its own `AppBar` (`_DesktopTopBar`, `preferredSize: GeniusWalletConsts.appBarHeight` = 68 on desktop; a bare `AppBar(title: ...)` at the *default* `kToolbarHeight` = 56 on mobile - not 68, a pre-existing mismatch this plan did not introduce or touch). `Scaffold` positions `body:` **below** the app bar, but it does **not** shrink `MediaQuery` for that body - `MediaQuery.sizeOf(context)` inside the old `DevToolsBubble` returned the **full window size**, exactly as it does now. The `Positioned(top: minTop)` computed from that full-window `screenSize`, though, was being placed inside the body `Stack`'s own **local** coordinate space - whose origin (0,0) was *already* below the app bar in absolute screen terms. So `minTop = headerHeight + edgeInset` pushed the bubble down by a second app-bar's-worth of space on top of the one `Scaffold` already reserved: on desktop, roughly 68 (Scaffold's real offset) + 68 (the clamp) = 136px from the true top, when 68 alone would have cleared the bar exactly.

After this fix: `DevToolsBubbleHost` mounts the bubble **above** the entire `MaterialApp.router` tree - above every `Scaffold`, every `AppBar`, everything. A `Positioned(top: minTop)` here is now measured from the **true top of the screen** (y=0 of the whole window), not from inside an already-offset body box. So on the authenticated shell (where a real 68px desktop app bar exists), `minTop = appBarHeight + edgeInset` now does exactly what its name says: reserve one app-bar's height from the true top, once. The double-counting is gone.

Two qualifications, both real and worth stating plainly rather than glossing over:

1. **The mount is now global, but the constant's meaning is not.** The bubble floats over *every* route via one host, including the many routes with **no app bar at all** (splash, onboarding, checkout, recovery-phrase - see Finding 2). On those screens `appBarHeight` describes an app bar that is not there; the clamp still reserves 68+8=76px from the true top on those screens as a side effect of being a single global constant, not because there's anything to clear. This is a minor cosmetic overcaution (the bubble simply starts slightly lower than it strictly needs to on those specific screens), not a functional bug, and not something this plan's scope calls for fixing (it would need per-route awareness the host deliberately does not have, by the same D-04 reasoning that says no per-route logic is wanted here).
2. **On mobile, the constant was already approximate before this fix and still is.** Mobile's real `AppBar` height is `kToolbarHeight` (56), not `GeniusWalletConsts.appBarHeight` (68) - `_MobileTabBar`'s own `AppBar()` never sets `toolbarHeight`. This 12px mismatch predates this plan and this plan does not touch it.

**The mobile bottom nav is not accounted for anywhere in the clamp, before or after this fix - nothing subtracts its height from `_panelMaxHeight`.** This is unchanged code, but the *consequence* of that gap is different now. Before, the old `Stack` (default `Clip.hardEdge`) was scoped to the **body's own box**, so even if `_panelMaxHeight`'s math under-accounted for the bottom nav, an oversized panel would simply be clipped at the body's bottom edge - visually cut off, never drawn over the nav bar. Now, `DevToolsBubbleHost`'s `Stack` is scoped to the **whole screen**, above the entire `Scaffold` including `bottomNavigationBar` in paint order. If `_panelMaxHeight` (still just `screenSize.height - headerHeight - 2*edgeInset`, still not subtracting the bottom nav's own height) computes a max height that runs into the mobile tab bar's vertical space, the panel is no longer safely clipped away from it - it can now paint visibly **over** the bottom nav rather than being invisibly cut off before it. This is a real, if minor, consequence of the mount change that the plan's own clamp-constants question surfaced; it was not previously reachable because the old `Stack`'s clip boundary masked it. Recommend a follow-up (not fixed here, out of this quick task's scope): subtract the mobile bottom nav's height from `_panelMaxHeight` when running under `MobileOverlay`'s breakpoint, or accept the visual overlap as another debug-only cosmetic cost alongside D-04's list.

## Required Finding 2: reach

**The bubble is now reachable on literally every route in the app, not only the four categories D-04 named - and D-04's reasoning holds for all of them, unchanged.**

Walking `lib/navigation/router.dart` and `lib/onboarding/routes/wallet_routes.dart`: every `GoRoute` that sits **outside** the `ShellRoute` (the only place `MobileOverlay`/`DesktopOverlay`, and therefore the old bubble mount, ever applied) was **previously unreachable** by the dev bubble. That set is larger than D-04's named list:

- `/` (splash), `/landing_screen`, `/backup_phrase`, `/recovery_phrase`, `/verify_recovery_phrase`, `/import_wallet`, `/import_security`, `/import_existing_wallet`, `/create_wallet` (onboarding/backup/recovery/wallet-creation - matches D-04's list)
- `/checkout`, `/checkoutQR`, `/kyc` (checkout/KYC - matches D-04's list)
- `/network`, `/buy/orders`, `/createOrder`, `/orderDetails`, `/banxa/callback`, `/bridge`, `/submit_job` - **not named by D-04**, standalone routes outside the shell
- `/dev/token-probe`, `/design_gallery` - already dev-only screens, so their own reachability is moot

**D-04 still holds after seeing this fuller list, and nothing changes the answer.** D-04's reasoning (draggable, collapses to a 48px circle so it can never permanently trap a control; gated behind a dart-define that is off in every build nobody explicitly asked for it in) is generic to the bubble itself, not to any specific screen - it applies identically to `/bridge` and `/submit_job` as it does to `/recovery_phrase`. No per-route exception is warranted for any of the additional surfaces either.

**Recovery-phrase specifically: acceptable, does not argue for a hidden-path set.** `DevToolsBubble` never reads or displays wallet secrets - the panel's buttons inject mock coins/transactions/orders and toggle appearance; nothing in it touches a seed phrase, private key, or the real recovery-phrase text on screen. A draggable 48px icon floating in a corner of that screen (behind `--dart-define=GW_DEV_TOOLS=true`, absent from every release and from every debug run that didn't explicitly opt in) discloses nothing about the phrase itself - consistent with this plan's own threat register (T-gow-02, severity low, accepted). Agreeing with D-04: no hidden-path set.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- The mount-point fix is complete and self-contained; nothing else in the codebase references the old two-call-site mount.
- Follow-up recommended, not required by this quick task: account for the mobile bottom nav's height in `_panelMaxHeight` (see Finding 1) now that an oversized panel can paint over it instead of being clipped away.
- **Nothing was committed or staged.** Per this task's standing rule, every file above is left modified/created in the working tree for Jakub to review and commit himself. `git add`/`git commit`/`git push` were not run at any point in this task.

## Self-Check: PASSED

- FOUND: `lib/dev/dev_tools_host.dart`
- FOUND: `test/dev/dev_tools_bubble_above_barrier_test.dart`
- FOUND: `.planning/quick/260731-gow-mount-dev-tools-bubble-above-the-router-/260731-gow-SUMMARY.md`
- Confirmed via `git status --short`: both new files are untracked (`??`), no commits were made, working tree is dirty as required.

---
*Quick task: 260731-gow*
*Completed: 2026-07-31*
