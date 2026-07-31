# CORRECTED: the 0-100 reading was a dev fixture, not the SDK - scale still unconfirmed

## CORRECTION (2026-07-31)

Quick task 260731-hrn re-derived this finding against the current source and found the trace
misread.

**What `init=37.0` actually was.** It was `DevMockSgnus.armInitPercentage(37)` - the `SGNUS init`
dev button, pressed sometime between the two traced builds - not a value read from the SDK. Two
independent reasons support this: (1) the fixture's own literal is `37`, an exact match with no
rounding; (2) `37.0` is a clean hand-entered integer with none of the float32 rounding signature the
`0.525` sample carries (`0.5249999761581421`), and `armInitPercentage`'s single call site is the
only place in the compute path that literal `37` can come from.

**The SDK-speaks-0-100 claim therefore has no surviving evidence and must not be acted on.** The
entire case below rested on `init=37.0` being a genuine FFI read. It was not. Do not normalize
`GeniusApi.getInitializationStatus()` or change `resolveComputeState`'s `< 1.0` gate on the strength
of this todo - there is nothing left here to act on for that question.

**The fix sketch's point 4 was not describing a bug.** `_onInitializationStatusTicked`
(`app_bloc.dart:367`) cancelling the init timer once `percentage >= 1.0` is correct behaviour under
the 0.0-1.0 reading the doc comment documents (`genius_api.dart:81`) - it only looked wrong under the
mistaken 0-100 premise this correction retracts.

**The `0.525` ceiling question is still genuinely open.** Whether the real SDK's init feed truly
stops at `0.525` (as `.planning/sketches/166-compute-missing-screens/DECISION.md` assumed) or keeps
climbing past it was never settled by this trace either way - the one number in the trace that could
have proven "it keeps climbing" (`37.0`) turned out to be a button press, not a poll. Only a full
boot trace, from 0 through completion, with no dev fixture armed, settles this. Do not treat this
correction as having answered it.

**What this quick task did and did not do.** 260731-hrn fixed the fixture: `armInitPercentage` now
takes a 0.0-1.0 value (`0.37`, matching the field's documented scale) instead of `37`, added a guard
so the real 3s init poll cannot overwrite an armed override, and added a one-shot release so `Clear`
does not strand the panel in `startingUp` forever. It left the SDK's own contract - and the question
this todo was created to answer - untouched.

---

# The SDK's init percentage is a 0-100 scale read as a 0.0-1.0 fraction

**Created:** 2026-07-31. **Area:** compute panel / genius_api. **Severity:** the panel reports a
node as `Ready` while it is still initializing. **Found by instrumentation on a live app**, not by
reading code.

## The measurement

A temporary trace was added to `wallet_overview.dart`, logging every change of the resolved compute
state together with the inputs that decide it. Two consecutive resolutions, same session, real FFI
(the SGNUS connection was dev-mocked, but `initPercentage` was not - see "Is it dev-only" below):

```
[compute-trace] build#1 -> startingUp | init=0.5249999761581421 | connected=true | feed=live
[compute-trace] build#2 -> ready      | init=37.0               | connected=true | feed=live
```

`init=37.0` is the whole finding. It cannot occur on a 0.0-1.0 scale.

## The contradiction

`packages/genius_api/lib/src/genius_api.dart:81` documents the field as:

> `/// Initialization progress from 0.0 to 1.0.`

`GeniusApi.getInitializationStatus()` (`:1216-1222`) passes `result.percentage` straight through
from `GeniusSDKGetInitializationStatus()` with no scaling. The measured values say the native side
speaks 0-100. The Dart doc comment is wrong.

Corroborating: `processingPercentage` is already treated as 0-100 everywhere (the dev mock uses
`42.0`, the height-test fixture uses `52.5`). Init is the odd one out, and only because a comment
said so.

## What breaks

`compute_state.dart`'s gate is:

```dart
if (initPercentage != null && initPercentage < 1.0) {
  return ComputeState.startingUp;
}
```

On a 0-100 scale that fires **only below 1%**. From 1% onward the ladder falls through to
`ComputeState.ready`. So the panel says **Ready while the node is 37% initialized** - the exact
class of dishonesty Phase 14 exists to remove.

It also explains the flicker reported on a live walk: the panel resolves `startingUp` while the
value is under 1.0, then flips to `ready` the moment it crosses. Because the states have different
heights (14-07 measured 256 / 234 / 268 / 274px), the whole dashboard visibly jumps at that
crossing.

And every derived number was off by 100x. `0.525` rendered as "52%" is really **0.525%**.

## This probably invalidates sketch 166's founding premise

`.planning/sketches/166-compute-missing-screens/DECISION.md` opens with:

> "The SDK's init feed stops at `0.525` forever. A determinate bar is a promise about a denominator
> that does not exist."

The feed does not stop. It was at **0.525%** and kept climbing - it reached 37% in the same session.
Whoever observed it saw a number that barely moved (because 0.5% to 0.6% is a small step) and
concluded it was frozen.

Plan 14-09 was executed against that premise on 2026-07-31 and deleted the determinate bar during
`startingUp`. **The change is still safe** - a bar driven by a value the code misreads by 100x was
worse than no bar - but the stated reason is wrong, and once the scale is fixed the denominator is
real (100) and a determinate bar becomes honest. Re-open the bar question after fixing this, do not
treat 166 as having settled it.

## Fix sketch (not yet planned)

1. Establish the true native contract first. Do not guess from two samples - read the SuperGenius
   header for `GeniusSDKGetInitializationStatus`, or log a full boot from 0 to completion.
2. Fix it in ONE place, at the boundary: either normalize in
   `GeniusApi.getInitializationStatus()` so Dart only ever sees 0.0-1.0, or change the field's
   contract to 0-100 and update `resolveComputeState`'s gate plus every derived readout. The first
   is preferable - it keeps the `< 1.0` gate and every existing test's meaning intact.
3. Whichever is chosen, correct the doc comment at `genius_api.dart:81`, which is what caused this.
4. `_onInitializationStatusTicked` (`app_bloc.dart:367`) also cancels the timer at
   `percentage >= 1.0`. On a 0-100 scale that stops the init poll at 1%, so it has been reporting a
   stale value ever since. Fix it in the same change or the gate fix alone will not help.

## Is it dev-only? No

The dev-tools mock (`app_bloc.dart:200`) requires `kDebugMode && kShowDevTools` AND an explicitly
set override. The session that produced this trace had the SGNUS **connection** mocked
(`nodeAddr=0xDEV5GNUS…`, `dev_mock_sgnus.dart:29`), but `initPercentage` carried
`0.5249999761581421` - the float32 rounding signature of a real FFI double, not a hand-entered
override. A release build reads the same feed through the same gate.

Related: [[2026-07-29-stall-detector-needs-a-traced-processing-feed]] asks for a traced processing
feed for a different reason; a full boot trace would serve both.
