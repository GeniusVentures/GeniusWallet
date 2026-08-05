---
phase: quick-260731-gow
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dev/dev_tools_host.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/components/toast/toast_manager.dart
  - lib/components/overlay/responsive_overlay.dart
  - lib/main.dart
  - test/dev/dev_tools_bubble_above_barrier_test.dart
  - test/dev/dev_tools_bubble_persistence_test.dart
autonomous: true
requirements: [QUICK-260731-GOW]

must_haves:
  truths:
    - "With a drawer open on desktop, tapping the dev-tools bubble leaves the drawer OPEN and the tap reaches the bubble."
    - "With a drawer open, tapping anywhere else outside the drawer still CLOSES it, exactly as today."
    - "The dev bubble renders at full opacity above the drawer scrim instead of dimmed under it."
    - "Every dev-panel button still works from the new mount: cubit reads, toasts, drawer demos, and both NAVIGATE pushes."
    - "The bubble is mounted exactly once in lib/."
  artifacts:
    - lib/dev/dev_tools_host.dart
    - test/dev/dev_tools_bubble_above_barrier_test.dart
  key_links:
    - "main.dart builder wraps GlobalSwapFabHost with the new dev host, so the bubble's Stack sits above the root Navigator."
    - "DevToolsBubble takes a GoRouter explicitly and derives an app-navigator BuildContext from it for every action that needs a Navigator or an Overlay."
    - "ToastManager falls back to the Navigator's own overlay when the given context has no ancestor Overlay."
---

<objective>
Tapping the dev-tools panel while a drawer is open dismisses the drawer. Re-home the
bubble above the router's Navigator so its own taps stop landing on the drawer's modal
barrier, without weakening barrier dismissal for anything else.

Purpose: Jakub reported it live on 2026-07-31 - open a drawer, click the already-open dev
panel, the drawer closes. The panel is unusable while inspecting a drawer.
Output: one dev-only host mounted in `MaterialApp.router`'s builder, both in-page mounts
removed, and a two-sided regression test.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md

@lib/main.dart
@lib/components/overlay/global_swap_fab_host.dart
@lib/components/overlay/responsive_overlay.dart
@lib/dev/dev_tools_bubble.dart
@lib/components/toast/toast_manager.dart
@lib/components/bottom_drawer/responsive_drawer.dart
@test/dev/dev_tools_bubble_persistence_test.dart
</context>

<standing_rules>
Read these before Task 1. They override GSD defaults.

1. **DO NOT COMMIT. DO NOT PUSH. DO NOT open a PR.** Leave every change in the working
   tree. Jakub reviews locally and opens the PR himself into `ui-redesign-port`. This
   overrides the GSD atomic-commit default and is his standing rule for this project.
   `git add` is also unnecessary. Just leave the files edited.
2. **No em dashes.** Not in code, not in comments, not in test names, not in the summary.
   Write " - " (space hyphen space). The existing files contain em dashes in older
   comments; leave those alone, but never write a new one.
3. Branch is `redesign/jakub-260730` (verified). Do not switch branches.
4. Do not touch `isDismissible` anywhere, and do not make any drawer non-dismissible.
   The fix is a layering change, not a dismissal-policy change.
</standing_rules>

<root_cause>
Already verified against source before this plan was written. Do not re-derive it.

- Desktop `ResponsiveDrawer.show` calls
  `showDialog(useRootNavigator: true, barrierDismissible: isDismissible, barrierColor: Colors.black54)`
  at `responsive_drawer.dart:125-129`. Its `ModalBarrier` is a full-screen layer in the
  ROOT navigator's overlay, above the whole page.
- The bubble is mounted inside the page: `responsive_overlay.dart:493` (MobileOverlay)
  and `:520` (DesktopOverlay), both in a `Stack` owned by the ShellRoute's page, so BELOW
  the dialog route.
- A tap on the panel therefore lands on the barrier and never reaches the panel. Same
  layering is why the panel renders dimmed under the `black54` scrim.

The fix is the mount point, and `GlobalSwapFabHost` is the precedent: it floats
`GWSwapFab` over every route from `MaterialApp.router`'s builder with a plain `Stack`
(`global_swap_fab_host.dart:150-161`), and it takes a `GoRouter` explicitly because
"the builder's context can sit above the InheritedGoRouter" (`:16-17`).
</root_cause>

<decisions>
Decided while planning, verified against source. Implement these; do not re-open them.

**D-01: a sibling host, not an extension of `GlobalSwapFabHost`.**
That class is stateful only to carry route-listening machinery (`_ready`, the delegate
listener) whose sole job is hiding the FAB on `_hiddenPaths`. The dev bubble needs none
of it (see D-04). Extending it would put dev-only code and a `lib/dev/` import inside a
shared production component, and would leave a class named `GlobalSwapFabHost` mounting
something that is not a swap FAB. New file `lib/dev/dev_tools_host.dart`, stateless, in
`lib/dev/` where the rest of the dev-only code already lives. Write this reason into the
class doc comment.

**D-02: the debug gate moves onto the host as a defaulted field.**
`kShowDevTools` is `const bool.fromEnvironment('GW_DEV_TOOLS')` (`lib/dev/dev_flags.dart`),
so it is `false` under `flutter test` and cannot be flipped at runtime. If the host hard-codes
`kDebugMode && kShowDevTools` the regression test can only exercise a copy of the host's body,
which is a test of the wrong thing. Give the host
`final bool enabled;` defaulting to `kDebugMode && kShowDevTools` (both are consts, so the
default stays const). `main.dart` passes nothing, the test passes `enabled: true`. The gate
is still exactly one expression and still tree-shaken out of release builds.

**D-03: the bubble takes a `GoRouter` and derives an app-navigator context from it.**
This is the trap `global_swap_fab_host.dart:16-17` documents, and it is worse for the bubble
than for the FAB, because the bubble needs a Navigator AND an Overlay ancestor, and the
builder's context has neither (the Navigator is the builder's *child*). Verified call sites
inside `_buildExpandedPanel` (lines 262-1100): 18 `context.read`, 2 `context.push`
(`:1048` `/dev/token-probe`, `:1052` `/design_gallery`), ~25
`ToastManager.instance.showToast(context: context, ...)`, and 6 drawer `.show(context)`
calls (`ApproveDappConnectionDrawer :782`, `SwapResultDrawer :792` and `:803`,
`ApproveTransactionDrawer :814`, `BuySuccessDrawer :902`, `BuyCancelledDrawer :907`).
See `<how_each_call_site_survives>` for what each one does at the new mount point.

**D-04: no `_hiddenPaths` equivalent for the dev bubble. Do not add one.**
Justification, stated because the brief demands the answer either way: `_hiddenPaths`
exists for the FAB because the FAB is fixed at `bottom: 80 + inset, right: space10` and
can permanently cover an onboarding or checkout CTA that the user cannot move. The dev
bubble is draggable and collapses to a 48px circle, so it can never trap a control, and
it is behind a dart-define that is off in every build Jakub has not explicitly asked for
it in. It is also most useful exactly on the surfaces it could not reach before:
appearance toggling during an onboarding walk, mock injection before a wallet exists.
Cost, accepted and recorded in the threat model: it now floats over recovery-phrase and
wallet-creation screens in `GW_DEV_TOOLS=true` debug builds.

**D-05: the single-child `Stack`s in `MobileOverlay` / `DesktopOverlay` stay.**
Scaffold lays its body out under LOOSE constraints, so a `Stack` expands to the full body
box while a bare child may size to itself. Deleting the now-single-child `Stack` would
silently change body sizing for every page in the shell, which is an unrelated layout risk
inside a bug fix. Keep both `Stack`s and add a one-line comment saying why they are kept.
</decisions>

<how_each_call_site_survives>
Verified, so the executor does not have to rediscover it. `_appContext` below means
`widget.router.routerDelegate.navigatorKey.currentContext ?? context`
(`navigatorKey` is public on `GoRouterDelegate`, `delegate.dart:207`, go_router 17.3.0).

| Call site | From the builder's own context | From `_appContext` |
|---|---|---|
| `context.read<TransactionsCubit\|OrdersCubit\|WalletDetailsCubit\|AppBloc>()` | works - all four are provided ABOVE `MaterialApp.router` (`main.dart:320-343`) | works |
| `MediaQuery.sizeOf` / `Theme.of` | works - `MediaQuery` and `AnimatedTheme` both wrap the builder (`GlobalSwapFabHost:148` already reads MediaQuery there) | works |
| `context.push(...)` | UNSAFE - the documented `InheritedGoRouter` trap | replaced by `widget.router.push(...)` per D-03 |
| `ResponsiveDrawer.show` via the 6 drawer `.show(context)` calls | THROWS - `showDialog` needs `Navigator.of(context)` and the Navigator is the builder's child, not its ancestor | works - `Navigator.of` has an explicit self case for a context that IS the Navigator's `StatefulElement`, and `rootNavigator: true` falls back to it |
| `ToastManager.showToast(context:)` | THROWS - `toast_manager.dart:20` calls `Overlay.of(context)` and there is no ancestor `Overlay` above the root Navigator | needs the Task 2 `ToastManager` fallback |

The `?? context` fallback matters: `navigatorKey.currentContext` is null before the
Navigator mounts and in tests that build the bubble under a plain `MaterialApp`.
</how_each_call_site_survives>

<tasks>

<task type="auto">
  <name>Task 1: Create the dev-tools host and move the mount above the Navigator</name>
  <files>lib/dev/dev_tools_host.dart, lib/main.dart, lib/components/overlay/responsive_overlay.dart</files>
  <action>
Create `lib/dev/dev_tools_host.dart` with a stateless `DevToolsBubbleHost`, modelled on
`global_swap_fab_host.dart` but without its route-listening machinery (per D-01 and D-04).
Fields: `final GoRouter router`, `final Widget child`, and `final bool enabled` defaulting
to the const expression `kDebugMode && kShowDevTools` (per D-02). `build` returns `child`
untouched when `enabled` is false, otherwise `Stack(children: [child, DevToolsBubble(router: router)])`.
The bubble's own `build` returns a `Positioned`, so it must be a direct child of that Stack.

Class doc comment must record, in prose without em dashes: that this exists because the
bubble has to sit above the root Navigator's overlay or a drawer's `ModalBarrier` eats its
taps; why it is a sibling of `GlobalSwapFabHost` rather than an extension of it (D-01); why
the gate is a defaulted field rather than an inline const (D-02); and that no hidden-path
set is wanted here, with D-04's reason.

In `lib/main.dart`, wrap the existing `GlobalSwapFabHost` (`:351-357`) so the builder reads
`DevicePreview.appBuilder(context, DevToolsBubbleHost(router: geniusWalletRouter, child: GlobalSwapFabHost(...)))`.
Dev host OUTSIDE the swap host so a debug tool is never occluded by a product affordance,
and INSIDE `DevicePreview.appBuilder` so it stays within the simulated device frame like the
FAB does. Add the import.

In `lib/components/overlay/responsive_overlay.dart`, delete the bubble line from
`MobileOverlay` (`:493`) and from `DesktopOverlay` (`:520`), including each `if (kDebugMode
&& kShowDevTools)` guard. Keep both `Stack`s exactly as they are, each now with a single
child, and add a one-line comment on each saying it is kept deliberately because Scaffold
lays the body out under loose constraints and dropping the Stack would change body sizing
(D-05). Then remove only the imports that genuinely became unused - check whether
`kDebugMode`, `kShowDevTools` and the `flutter/foundation.dart` import are still used
elsewhere in that file before deleting anything. The project holds `flutter analyze` at 0,
so a leftover unused import is a failure.
  </action>
  <verify>
    <automated>grep -rn "DevToolsBubble(router:" lib/ | wc -l | tr -d ' ' | grep -qx 1 &amp;&amp; grep -c "DevToolsBubble" lib/components/overlay/responsive_overlay.dart | grep -qx 0 &amp;&amp; flutter analyze lib --no-fatal-infos</automated>
  </verify>
  <done>Exactly one mount of the bubble exists in `lib/`, it is in the new host, `responsive_overlay.dart` no longer references the bubble at all, both single-child Stacks survive with their comment, and `flutter analyze` is still clean.</done>
</task>

<task type="auto">
  <name>Task 2: Give the bubble a router and an app-navigator context for its actions</name>
  <files>lib/dev/dev_tools_bubble.dart, lib/components/toast/toast_manager.dart</files>
  <action>
Add `required this.router` / `final GoRouter router;` to `DevToolsBubble`. Add to
`_DevToolsBubbleState` a documented getter returning
`widget.router.routerDelegate.navigatorKey.currentContext ?? context`, named for what it
is (the app Navigator's context, not the builder's). Its doc comment states the trap in
one sentence: at the new mount point the builder's context has neither a `Navigator` nor
an `Overlay` ancestor, because the Navigator is the builder's child.

Rebind the panel's action context in ONE place: pass that getter, not `context`, as the
first argument of the `_buildExpandedPanel(...)` call at `:231`. The parameter is already
named `context` inside `_buildExpandedPanel`, so all 18 `context.read` calls, ~25
`showToast(context: context)` calls and all 6 drawer `.show(context)` calls rebind at
once. Verified safe: the table in `<how_each_call_site_survives>` covers every kind of use
inside that method, and the only build-time reads in there are `MediaQuery.sizeOf`
(`:293`, inside a drag callback) plus the `gw`/`isLight` values already passed in as plain
parameters, so no foreign element gets a build dependency registered on it. Put a comment
at the call site explaining the single substitution, because a reader will otherwise not
see that one argument is rebinding thirty call sites.

Convert the two NAVIGATE pushes (`:1048` `/dev/token-probe`, `:1052` `/design_gallery`)
from `context.push` to the explicit `widget.router.push` form, matching
`global_swap_fab_host.dart:159`. Do this even though the rebound context would probably
resolve `InheritedGoRouter`: the explicit form is the one the precedent file documents,
and it cannot silently break.

In `lib/components/toast/toast_manager.dart:20`, change `Overlay.of(context)` to fall back
to the Navigator's own overlay when the context has no ancestor Overlay:
`Overlay.maybeOf(context) ?? Navigator.of(context).overlay!`. Comment it: every existing
caller passes an in-page context and keeps taking the first branch unchanged, the fallback
exists for a context that IS the root Navigator, and the resulting `OverlayEntry` is
inserted at the top of the same root overlay toasts already use, so nothing about where a
toast renders changes. Do not add an early return that swallows the toast - if neither path
resolves, throwing is correct and is what the code does today.

Update the `DevToolsBubble` class doc: its opening lines still say the gate lives at
`responsive_overlay.dart`'s DesktopOverlay / MobileOverlay (`:29-35`) and
`DevToolsBubblePanelState`'s doc still argues from "two separate call sites, in two
different Scaffolds" (`:68-84`). Both statements are now false. Rewrite them to describe
the single host mount, and re-examine the "at most one DevToolsBubble is mounted at a
time" claim the singleton rests on: it is still true, and now trivially so, but it must be
true for a NEW reason and the comment has to say the new one. Leave the singleton itself
alone.
  </action>
  <verify>
    <automated>grep -c "context.push(" lib/dev/dev_tools_bubble.dart | grep -qx 0 &amp;&amp; grep -c "widget.router.push(" lib/dev/dev_tools_bubble.dart | grep -qx 2 &amp;&amp; grep -q "Overlay.maybeOf" lib/components/toast/toast_manager.dart &amp;&amp; flutter analyze lib --no-fatal-infos</automated>
  </verify>
  <done>The bubble takes a `GoRouter`, both NAVIGATE targets go through it, the panel's actions run against the app Navigator's context, `ToastManager` resolves an overlay from a Navigator context, and the two stale doc comments now describe the real mount.</done>
</task>

<task type="auto">
  <name>Task 3: Two-sided regression test, full gate run, and the two required findings</name>
  <files>test/dev/dev_tools_bubble_above_barrier_test.dart, test/dev/dev_tools_bubble_persistence_test.dart</files>
  <action>
Write `test/dev/dev_tools_bubble_above_barrier_test.dart`. Harness: a `GoRouter` whose `/`
route is a `Scaffold` with a button that calls `ResponsiveDrawer.show(context: ..., title:
..., child: Text('DRAWER BODY'))` from a `Builder` context inside it, rendered by
`MaterialApp.router(routerConfig: router, theme: ThemeData.dark().copyWith(extensions:
[GWColors.dark()]), builder: (context, child) => DevToolsBubbleHost(enabled: true, router:
router, child: child ?? const SizedBox.shrink()))`. Set `tester.view.physicalSize = const
Size(1200, 900)` with `devicePixelRatio = 1.0` and `addTearDown(tester.view.reset)`, so
`ResponsiveDrawer` takes its DESKTOP `showDialog` branch (`width >=
GeniusBreakpoints.medium`, which is 768) - that barrier is the reported bug. Reset
`DevToolsBubblePanelState.instance` in `setUp` and `tearDown` exactly as
`dev_tools_bubble_persistence_test.dart:30-38` does, since it is a process-wide singleton.

BOTH halves are required, and the second is not optional decoration - a test asserting
only the first would also pass if the drawer had stopped being dismissible at all, which
is the opposite of what was asked.

Test 1, the bug: open the drawer, assert `DRAWER BODY` is on screen, tap
`find.byIcon(Icons.bug_report)`, settle, then assert BOTH that `DRAWER BODY` is STILL on
screen AND that `find.byIcon(Icons.close)` appeared. The second assertion is what proves
the tap reached the bubble rather than being swallowed silently, since `tester.tap` only
warns when a tap misses its target. Then, in the same test, tap the barrier and assert the
drawer closes, proving the exception is scoped to the panel and did not leak into the
barrier's behaviour.

Test 2, the guard: open the drawer and `tester.tapAt` a point that is on the barrier and
on nothing else - the drawer is 420 wide and right-aligned on a 1200 wide window, and the
bubble sits top-right, so somewhere around `Offset(100, 700)` is safely clear of both.
Compute the point from the real numbers rather than trusting that offset, and say in a
comment how it was derived. Assert `DRAWER BODY` is gone.

Do NOT build a `MultiBlocProvider` for this harness. Expanding the panel needs no
providers: `dev_tools_bubble_persistence_test.dart` already taps `bug_report` and expands
the panel under a bare `MaterialApp` with zero providers and passes today, which proves
every `context.read` in the panel sits inside a callback. If that turns out to be false,
report it rather than quietly adding provider plumbing.

Update `dev_tools_bubble_persistence_test.dart`'s two harness helpers for the new required
`router` argument. A trivial standalone `GoRouter` object is enough there - the bubble only
stores it, and `navigatorKey.currentContext` being null is exactly what the `?? context`
fallback is for. If a bare `GoRouter` proves awkward to construct in that file, move that
harness to `MaterialApp.router` too rather than weakening the constructor.

Then run, in this order, and record the real numbers: `flutter analyze` (root and
genius_api), `flutter test` (baseline is 847 passing - expect 847 plus the new cases),
`./tool/check_brace_style.sh`, `./tool/check_raw_colors.sh` (note `lib/dev` IS in that
script's covered list, so the new host file is scanned), and `dart format` on the touched
files. Both scripts live in `tool/`, not at the repo root - the paths in the brief were
approximate and these are the verified ones.

Finally write `.planning/quick/260731-gow-mount-dev-tools-bubble-above-the-router-/260731-gow-SUMMARY.md`
containing the gate numbers and, as named sections, the two findings the brief requires:

FINDING 1 - what the clamp constants mean now. `_headerHeight =
GeniusWalletConsts.appBarHeight` (68) and `MediaQuery.sizeOf` drive `_clamp`
(`dev_tools_bubble.dart:165-190`, `:206-219`). Confirm what actually changed: `sizeOf`
returned the whole window BOTH before and after, because `Scaffold` does not shrink
`MediaQuery` for its body, but the Stack the offsets are measured in changed from the
Scaffold BODY box to the whole window. So state plainly whether `minTop = appBarHeight +
edgeInset` was double-counting the app bar before (a top inset measured from below the app
bar, then pushed down by the app bar's height again) and is only now literally true, and
whether `_panelMaxHeight`, computed from window height while living in a shorter body,
could previously push the panel under the mobile tab bar. Also say whether the mobile
bottom nav is accounted for anywhere in the clamp now, since nothing subtracts it. If a
constant has stopped describing anything real at the new mount point, say so rather than
keeping a name that has stopped meaning what it says.

FINDING 2 - reach. State which surfaces the bubble can now float over that it could not
before (splash, landing, onboarding, backup and recovery phrase, wallet creation, checkout
and KYC - everything outside the authenticated shell), confirm D-04 still holds after
seeing the real list, and flag anything that changes the answer. Recovery-phrase screens in
particular: say whether a draggable 48px debug bubble over a seed-phrase screen is
acceptable given the dart-define gate, or whether it argues for a hidden-path set after
all.

The summary is a report, not a commit. Do not commit it and do not commit the code.
  </action>
  <verify>
    <automated>flutter test test/dev/ &amp;&amp; flutter analyze --no-fatal-infos &amp;&amp; ./tool/check_brace_style.sh &amp;&amp; ./tool/check_raw_colors.sh</automated>
  </verify>
  <done>Both halves of the regression test pass, the persistence test still passes, full `flutter test` is at or above 847 plus the new cases with no new failures, all four gates pass, and the summary carries both findings with real measurements rather than restatements of the brief.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| debug build to release build | dev-only affordance gated by a compile-time const; the gate is the only thing keeping it out of shipped binaries |
| dev panel to wallet state | panel buttons inject mock wallets, coins and transactions into live cubits |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-gow-01 | Elevation of Privilege | `DevToolsBubbleHost.enabled` | high | mitigate | Default stays the const `kDebugMode && kShowDevTools`, so release builds tree-shake the mount. The `enabled` field exists only so a test can pass `true`; `main.dart` must never pass it. Task 1 verify greps for a single mount and analyze stays clean. |
| T-gow-02 | Information Disclosure | bubble now reachable on recovery-phrase and wallet-creation screens (D-04) | low | accept | Accepted because the surface is unreachable without `--dart-define=GW_DEV_TOOLS=true` on a debug build, and the bubble is draggable so it cannot occlude a phrase permanently. Task 3 FINDING 2 must re-examine this against the real screen list and say so if it changes. |
| T-gow-03 | Tampering | mock injection now reachable pre-wallet | low | accept | Same gate. Injecting a mock wallet before a real one exists is a dev workflow, not a new capability. |

No package installs in this plan, so no legitimacy audit applies.
</threat_model>

<verification>
1. `flutter analyze` clean at root and in `genius_api` (baseline 0/0).
2. Full `flutter test` at 847 plus the new cases, no new failures.
3. `./tool/check_brace_style.sh` and `./tool/check_raw_colors.sh` both pass.
4. `grep -rn "DevToolsBubble(router:" lib/` returns exactly one line.
5. Working tree is DIRTY and UNCOMMITTED at the end. If anything was committed, that is a
   failure of this plan, not a convenience.
</verification>

<success_criteria>
- With a drawer open at desktop width, a tap on the dev bubble expands the panel and the
  drawer stays open, proven by a test asserting both facts.
- With a drawer open, a tap elsewhere outside it still closes it, proven by a separate test.
- `isDismissible` is untouched everywhere; `git diff` shows no change to that argument.
- Toasts, the six drawer demos, all cubit reads and both NAVIGATE pushes still work from
  the new mount, by construction per `<how_each_call_site_survives>` and by a clean analyze.
- The two required findings are written with measured answers, including any admission
  that a constant has stopped meaning what its name says.
- Nothing is committed or pushed.
</success_criteria>

<output>
Write `.planning/quick/260731-gow-mount-dev-tools-bubble-above-the-router-/260731-gow-SUMMARY.md` when done. Do not commit it.
</output>

<!-- planner-discipline-allow: DevToolsBubble -->
<!-- planner-discipline-allow: context.push( -->
</content>
</invoke>
