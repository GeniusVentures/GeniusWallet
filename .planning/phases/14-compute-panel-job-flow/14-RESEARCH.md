# Phase 14: Compute panel & job flow - Research

**Researched:** 2026-07-29
**Domain:** Flutter / bloc state modelling over an FFI poll, plus a drawer-hosted transactional flow
**Confidence:** HIGH on the code findings (every one re-read at `8ed02e78`), MEDIUM on the stall
detector's N (derived from one trace, on a different feed from the one it will guard)
**Working tree at time of research:** `8ed02e78`, clean

> **Every number below was re-measured against the working tree.** Where a claim inherited from
> `14-CONTEXT.md`, sketch 076/077 or `ROADMAP.md` did not survive re-measurement, it is marked
> **CORRECTION** and the corrected value is given. Three inherited claims did not survive.

---

<user_constraints>

## User Constraints (from 14-CONTEXT.md)

### Locked Decisions

| Decision | Value | Provenance |
|---|---|---|
| Panel layout | **P1 · Twin tiles** (016-B2 rebuilt on components) | 077, chosen by Jakub 2026-07-29 |
| Status treatment | **Dot + label**, 9 states | 017-A, chosen 2026-07-22, re-affirmed in 076 |
| Job flow | **F1 · Drawer, vertical steps** | 018-A, re-affirmed in 077 |
| `/submit_job` | **Kept** as the full-screen host for deep links, rendering the same step bodies | 018-A |

Chosen on "go with your recommendation" (flag if Jakub wants to revisit):

| Open question | Resolution taken |
|---|---|
| Section label | **`GWKicker` (13px, non-dense)**, not `GWSectionTitle` |
| The 3px overflow | **Drop the `≈ $312.40` subline** in the states where the compute bar is visible |
| GNUS/USD unit clash | **Kept**, mitigated by the `≈ $` subline in all non-tall states |
| `View transaction ›` | **Dropped** |

Hard constraints, copied verbatim:

- **Height budget: 276px.** `maxHeight: 300` at `dashboard_screen.dart:212` minus
  `DashboardScrollContainer`'s `EdgeInsets.all(space6)`. **Anything added to the compute block breaks
  this first.**
- **`+12.4 GNUS earned` is out of scope.** No mint/job-reward aggregate exists in `genius_api` or any
  cubit. It is not a UI decision; it is missing data.
- **No ring.** A determinate ring's grammar is "this will fill up" and it cannot render *stalled* or
  *unknown* without lying. The ring survives only in the 56px `GWAiFab`, under the rule **no live
  percentage → no ring**.
- **No golden tests, no snapshot/pixel/visual-regression tooling, no `integration_test`, no `patrol`,
  no Playwright.** Declined twice by Braian. Ordinary `flutter test` cases in the existing style are
  fine; a harness is not.
- **No new dependencies.** Two package installs declined in a row.
- **Do not delete `GeniusWalletColors`** - demote to private primitives; `GWColors` stays semantic.
- **Rule of Three** for any extraction, unless explicitly overridden.

### Claude's Discretion

Everything in the six non-UI code items below is implementation-shaped, not design-shaped: the
CONTEXT names *what* must change and leaves *how* open. That is the scope of this document.

### Deferred Ideas (OUT OF SCOPE)

`/network` re-skin (sketch 023) · the `+earned` readout (no API) · `View transaction ›` (no job→tx
correlation) · balances and holdings elsewhere on the dashboard (Phase 5) · light-mode-only issues
(dedicated app-wide pass after dark) · the full de-hex of 525 raw colour references.

</user_constraints>

---

## Project Constraints (from CLAUDE.md)

Directives the planner must verify compliance against. These carry the same authority as the locked
decisions above.

| Directive | Consequence for this phase |
|---|---|
| **Lazy senior developer ladder** - YAGNI → stdlib → native platform → installed dep → minimum code | Item 6's fix is a `<` → `<=`; do not build a validator class for it. The 4px bar is a `Container`, not a package. |
| **No abstractions that weren't explicitly requested** | `GWStatusDot` / `GWProgressBar` / `GWCopyRow` / `GWStepList` *were* explicitly requested (sketch 077 inventory). Nothing else may be extracted. |
| **Mark intentional simplifications with a `ponytail:` comment**, naming the ceiling and the upgrade path if the shortcut has one | The stall detector's N is exactly such a shortcut and MUST carry one. |
| **Non-trivial logic leaves ONE runnable check behind** - smallest thing that fails if the logic breaks; no frameworks, no fixtures | Five of the six items are non-trivial. See `## Validation Architecture`. |
| **Not lazy about**: input validation at trust boundaries, error handling that prevents data loss, security, accessibility | The job file is a trust boundary (`jsonDecode` on a user-picked file). The burned-`txHash` is a data-loss bug. Both fall in the not-lazy set. |
| **Do not create commits** | Research and planning only. |
| **Files under `/banxa` and `/squidrouter` are auto-generated** | Untouched by this phase. |
| **Only the EXECUTOR may run `flutter run`, the full `flutter test` suite, or touch git** | The baseline below was taken by a research session; the executor owns the authoritative one. |
| **Only the executor may write `ROADMAP.md` / `STATE.md` / `MANIFEST.md` / `HANDOFF.json`** | Plan files go in the phase directory only. |
| **Every session writes its own `.planning/HANDOFF-<topic>.md` before it ends** | Applies to the executing session. |

---

<phase_requirements>

## Phase Requirements

Derived from `14-CONTEXT.md` "Scope fence" and "Success criteria". IDs assigned here because
`14-CONTEXT.md` carries none.

| ID | Description | Research Support |
|----|-------------|------------------|
| CMP-01 | `RetryProcessingStatus` event re-arms the killed polling timer | § Item 1. The re-arm path already exists and is exercised on every pull-to-refresh. |
| CMP-02 | Stall detector flips to *stalled* after N unchanged polls | § Item 2. N derived, and the feed ambiguity in CONTEXT resolved. |
| CMP-03 | Public `AccountDrawer.show(context)`, no new UI | § Item 3. Three call-site couplings to break; the seam is clean. |
| CMP-04 | `txHash` preserved when `requestGeniusSDKProcess` fails after a successful `bridgeOut` | § Item 4. Three terminal states specified. |
| CMP-05 | Error channels split; "File Picker Error" stops being the title for six unrelated origins | § Item 5. **CORRECTION**: 9 call sites / 6 origins, not 4. |
| CMP-06 | `jobCost <= gnusBalance`, and cost-unknown split from insufficient-funds | § Item 6. Types confirmed; the ETH question answered. |
| CMP-07 | Nine compute states, none pixel-identical to another | § The Nine States. **CORRECTION**: 4 free / 5 need new code, not 6/3. |
| CMP-08 | Card fits 276px in every one of the nine states | § Height Budget. The budget arithmetic re-derived from real component metrics. |
| CMP-09 | Five shipped bugs closed | § The Five Shipped Bugs, all re-measured. |
| CMP-10 | `flutter analyze` 0 · suite green · `tool/check_brace_style.sh --count` 0 | § Validation Architecture. All three measured at HEAD. |

</phase_requirements>

---

## Summary

Every claim in `14-CONTEXT.md` about *where the bugs are* survived re-measurement. Two claims about
*how much is already free* did not, and one of those changes the size of the phase.

The six non-UI items are smaller than they look, with one exception. Items 1, 3, 4 and 6 are each a
handful of lines against a mechanism that already exists and already works: the polling timer is
already re-armed on every pull-to-refresh (`dashboard_screen.dart:112` → `app_bloc.dart:123`), the
account drawer's whole machinery is one `Future` away from public, the burned `txHash` is already in
a local variable four lines above the branch that throws it away, and the boundary fix is one
character. Item 5 is mechanical but larger than recorded. Item 2 - the stall detector - is the only
one with a genuine unknown in it, and the unknown is not "how" but "against which feed", because the
measured 52.5% stall and the 1s poll interval named in the CONTEXT **belong to two different feeds**.

The claim that six of the nine states are free is wrong. Four are. States **03 Starting up** and
**09 Offline** were counted as free but neither has a data source reachable from the dashboard:
`getInitializationStatus()` is polled inside a private `State` object with no exposure
(`sgnus_connection_widget.dart:37-59`), and `connectivity_plus` - an installed dependency, so no new
package - is consumed only by `network_page.dart`. Both need a small amount of new plumbing. That
moves the phase from *three states blocked* to *five*.

**Primary recommendation:** own the whole compute feed in `AppBloc`. Every state the panel must
render is a function of data the bloc either already holds or can hold for the cost of two more
fields and one more timer, and every alternative puts the panel's truth in a widget's private
`State` where the panel cannot read it - which is the exact defect that produced the 52.5% lie in the
first place.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|---|---|---|---|
| Node processing status poll | `AppBloc` (app state) | - | Already there: `_processingTimer`, `app_bloc.dart:135-141`. |
| Node initialization status poll | `AppBloc` (app state) | - | Today it is in `SGNUSConnectionState`, a widget's private `State` (`sgnus_connection_widget.dart:25-59`). The compute panel cannot read it there. Moving it is what makes state 03 renderable. |
| Stall detection | `AppBloc`, backed by a **pure function** in its own file | - | House pattern: `bridge_cta_state.dart` / `swap_cta_state.dart`. Keeps the derivation testable with a plain `test()` and no bloc harness. |
| Nine-state resolution | **Pure function**, own file | Widget reads the result | Same house pattern. Nine states x precedence is exactly what `resolveBridgeCtaState` is for. |
| Purchase-state ladder (cost unknown / insufficient / ready) | **Pure function**, own file | `SubmitJobCubit` | Directly mirrors `bridge_cta_state.dart`, which already has the correct `>` boundary this screen got wrong. |
| Job submission, bridge, terminal states | `SubmitJobCubit` | - | Owns `bridgeOut` and `requestGeniusSDKProcess` today. |
| Wallet selection from the panel | `WalletDetailsCubit.selectWallet` + Hive | `AccountDrawer.show()` | The side effects already live at `account_dropdown_selector.dart:221-222`. |
| Connectivity (state 09) | `AppBloc` or a small provider | `connectivity_plus` (installed) | Must be above the root navigator to be readable from a drawer. |
| Drawer shell, insets, panel chrome | `ResponsiveDrawer` | - | The archetype owns them since `8044bdb7`. Callers supply body/footer only. |

---

## The Five Shipped Bugs - re-measured 2026-07-29 at `8ed02e78`

All five alive. Every CONTEXT pointer confirmed correct; the ROADMAP's are the stale ones.

| # | Bug | CONTEXT pointer | Re-measured | Verdict |
|---|---|---|---|---|
| 1 | The 52.5% lie - determinate ring on a feed that stalls | `sgnus_connection_widget.dart:89` | `child: CircularProgressIndicator(` is line **89**; `value: _initPercentage` is line **90** | **CONFIRMED** [VERIFIED: file read] |
| 2 | The silent death - timer cancelled permanently | `app_bloc.dart:192-195` | `catch (_) {` line 192, `_processingTimer?.cancel();` line 193, `emit(...)` line 194, `}` line 195 | **CONFIRMED, exact** [VERIFIED: file read] |
| 3 | The vanishing button | `submit_job_dashboard_button.dart:26` | `return const SizedBox.shrink();` is line **26**; the discarded comparison is lines **22-23** | **CONFIRMED** [VERIFIED: file read] |
| 4 | Zero balance painted as failure | `wallet_overview.dart:143-145` | `'No funds available'` line **143**, `color: GeniusWalletColors.statusError` line **145**; the `if (balance == 0)` gate is line **141**. File is at `lib/components/wallet_overview.dart` | **CONFIRMED** [VERIFIED: file read] |
| 5 | Hardcoded `Colors.white` | `lib/wallets/view/genius_balance_display.dart:81`, 48px default at :79 | `fontSize: widget.fontSize ?? 48` line **79**; `color: widget.fontColor ?? Colors.white` line **81** | **CONFIRMED, exact** [VERIFIED: file read] |

**A sixth `Colors.white` sits four lines below**, at `genius_balance_display.dart:94`
(`color: widget.fontColor ?? Colors.grey` on the suffix) - same defect, same widget, and it is *not*
named in CONTEXT or ROADMAP. If bug 5 is fixed by moving the balance to `GWAnimatedNumber`, the
suffix path goes with it; if it is fixed in place, this one must be fixed too or the widget half
re-skins. [VERIFIED: file read]

---

## The Six Non-UI Code Items

### Item 1 - `RetryProcessingStatus` event

**The kill.** `app_bloc.dart:192-195`:

```
} catch (_) {
  _processingTimer?.cancel();
  emit(state.copyWith(isProcessing: false, processingPercentage: 0.0));
}
```

`catch (_)` is untyped, so *any* throw from `api.getProcessingStatus()` (`app_bloc.dart:178`) is
terminal. `getProcessingStatus` is a raw FFI call with **no `_isSdkInitialized` guard**
(`genius_api.dart:1210-1213`) - the in-file comment at `app_bloc.dart:157-158` already records this.
[VERIFIED: file read]

**Where the timer starts.** `_startProcessingPolling()`, `app_bloc.dart:135-141`. **CONTEXT's "~line
135" is exact.** [VERIFIED: file read]

```
void _startProcessingPolling() {
  _processingTimer?.cancel();
  _processingTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
    add(ProcessingStatusTicked());
  });
}
```

It already cancels before re-creating, so it is **idempotent by construction** - calling it twice
cannot leak a timer.

**Is re-arming safe mid-lifecycle? Yes, and this is already proven in production, not inferred.**
`_startProcessingPolling()` is called from exactly one place: `_onLoadWallets`, `app_bloc.dart:123`.
`LoadWallets` is dispatched from four sites (`router.dart:59`, `dashboard_screen.dart:112`,
`new_wallet_flow.dart:26`, `existing_wallet_flow.dart:26`), and `dashboard_screen.dart:112` is inside
`_onRefresh` - **pull-to-refresh**. So a user whose feed has died today can already revive it by
pulling down on the dashboard. The re-arm path exists, is reached repeatedly, and has never been
reported as a source of duplicate timers. `RetryProcessingStatus` is a cheap, direct entry to a
mechanism already load-bearing. [VERIFIED: file read + call-site grep]

**Construction and disposal.** Constructed once in `main.dart:332-341`, inside the
`MultiBlocProvider` **above `MaterialApp.router`** - therefore above the root navigator, which is why
a drawer body can read it (see § Drawer Hosting). Disposed in `close()`, `app_bloc.dart:452-457`,
which cancels both the timer and the SGNUS subscription. A `RetryProcessingStatus` handler that only
calls `_startProcessingPolling()` inherits that disposal for free. [VERIFIED: file read]

**One gap worth naming:** `_onLoadWallets` returns early at `app_bloc.dart:90` when
`_baseWallets.isEmpty`, **before** reaching line 123. A user with zero wallets therefore never polls
at all. That is not this phase's bug, but state 01 (*No wallet*) must not be derived from "the
percentage is missing" - it has to be derived from the wallet list, or it will be indistinguishable
from state 08. [VERIFIED: file read]

**Does the *unavailable* / *idle* flag belong in `AppState`? Yes, and it is the only place it can
go.** `app_state.dart:23-24` today:

```
final bool isProcessing;
final double? processingPercentage;
```

Two booleans cannot express three outcomes. `isProcessing:false` is emitted by the healthy idle path
(`app_bloc.dart:184-186`), the dev override (`:167-172`) **and** the catch (`:194`). Nothing
downstream can tell them apart - which is success criterion 1's exact failure.

**Trap the planner must know about.** `AppState.copyWith` uses `x ?? this.x` for **every** field
(`app_state.dart:69-86`). Passing `null` is therefore a **no-op, not a clear**. Consequences:

- `processingPercentage` can never be reset to null once set. This is the mechanism behind CONTEXT's
  bug 4 (stale percentage), and it is why `app_bloc.dart:194` passes `0.0` rather than `null`.
- Any new nullable field added for this phase inherits the same trap. Model the feed state as a
  **non-nullable enum with a default**, not as a nullable flag.

Recommended shape (planner may refine):

```dart
enum ProcessingFeed { unknown, live, unavailable }
```

`unknown` = never ticked (pre-`LoadWallets`, or the zero-wallet path). `live` = a tick landed.
`unavailable` = the catch fired. Default `unknown`. Non-nullable, so `copyWith` behaves.
[ASSUMED - shape is a recommendation; the three-outcome requirement is VERIFIED]

**Cost:** one enum, one `AppState` field + `copyWith` + `props` entry, one event class in
`app_event.dart` (which is a plain `abstract class AppEvent` with no Equatable -
`app_event.dart:3`), one `on<>` registration, one three-line handler.

---

### Item 2 - The stall detector

#### The measured data, re-read at source

`.planning/sketches/015-boot-loading-sequence/README.md:71-82`:

```
freeze-lift   t=9594ms
poll#1        t=9847ms   pct=0.20   "Migrating database (step 3 of 5): v3.4.0 -> v3.5.0"
poll#2        t=10097ms  pct=0.25   "Migrating database (step 4 of 5): v3.5.1 -> v3.6.0"
poll#3        t=10346ms  pct=0.30   "Migrating database (step 5 of 5): v3.6.0 -> v3.7.0"
poll#4        t=10597ms  pct=0.525  "Initializing blockchain service"
poll#5..161   …          pct=0.525  "Initializing blockchain service"   ← still stuck at t=49.8s
```

Derived facts, computed from those timestamps rather than quoted:

| Fact | Value | Derivation |
|---|---|---|
| Trace poll interval | **250ms** | 9847 → 10097 → 10346 → 10597, and 161 polls across ~40s |
| Advancing phase duration | **750ms** | poll#1 t=9847 to poll#4 t=10597 |
| Longest plateau *during* healthy advance | **0 repeats** (250ms between distinct values) | every one of polls 1-4 differs from its predecessor |
| Stall length observed | **157 polls ≈ 39.25s** | polls 5..161 at 250ms |
| Did the stall end? | **No** - the trace ended, the stall did not | README:79 |

#### **CORRECTION: the 1s poll interval and the 52.5% stall are two different feeds**

`14-CONTEXT.md` line 169 asks for N "given a 1s poll interval". That interval belongs to
`_processingTimer` (`app_bloc.dart:138`, `Duration(milliseconds: 1000)`), which polls
**`getProcessingStatus()`**. The 52.5% stall was measured on **`getInitializationStatus()`**, whose
only in-app consumer polls it at **3 seconds** (`sgnus_connection_widget.dart:42`,
`Timer.periodic(const Duration(seconds: 3), ...)`). Neither is the trace's 250ms - that was a spike
harness. Three intervals, and the CONTEXT conflates two of them. [VERIFIED: file read x2 + sketch
015 read]

Sketch 077's state list confirms which feed *stalled* watches: state 04's subline is
`"Stuck at 52.5% for 40s"` (`077-compute-interactive/index.html:248-249`), i.e. the **init** feed,
not the processing feed. [VERIFIED: file read]

**Consequence for the plan:** the detector guards a feed the compute panel cannot currently read at
all (see Item "The Nine States", state 03). Whoever plans this must decide the poll interval as part
of moving that feed into `AppBloc` - it is not inherited.

#### Deriving N

Two bounds, both from the measured trace:

**Lower bound (false-positive floor).** The detector must not fire on a healthy-but-slow feed. The
only evidence available is that during the healthy phase the init feed changed on *every* 250ms
poll - zero repeats, longest measured genuine plateau **< 250ms**. Applying a 10x safety factor to
the longest measured healthy plateau gives a floor of **2.5s**.

**Upper bound (usefulness ceiling).** The stall must be *detected*, not merely survivable. Detection
inside 25% of the observed stall window (39.25s) gives a ceiling of **9.8s**.

**Therefore: 3s ≤ N·interval ≤ 9.8s.** At a 1s interval that is `3 ≤ N ≤ 9`; at a 3s interval it is
`1 ≤ N ≤ 3`.

**Recommendation: express the threshold in *seconds*, not polls, and set it to 8s.** N = 8 at a 1s
interval; N = 3 at a 3s interval. 8s sits inside the band, is 32x the longest measured healthy
plateau, and is 20% of the measured stall window. Expressing it as a duration means the constant
survives a change to the poll interval, which is exactly the kind of drift that produced the
CONTEXT's 1s/3s conflation.

**What is NOT measured, and must be said out loud:** the trace covers only
`getInitializationStatus()`. **`getProcessingStatus().percentage` has never been traced.** If the
detector is ever pointed at the processing feed, 8s is a guess with a specific failure mode: a real
AI job reporting in 1% steps plateaus for `duration/100` seconds per step, so any job longer than
~13 minutes would false-positive continuously at 8s. The band derived above does not transfer to a
feed whose cadence is unknown. [VERIFIED: only one trace exists - grep across `.planning/spikes`
and `.planning/sketches` returns exactly one]

**Required `ponytail:` comment** (CLAUDE.md mandates one where a shortcut has a known ceiling):
name the ceiling as "8s is derived from a single init-feed trace; the processing feed has never been
traced, and a job reporting in 1% steps over >13 minutes would false-positive", and name the upgrade
path as "trace the processing feed and set the threshold per-feed".

#### Where the counter lives

**Recommendation: split it.** A pure function in its own file, holding the *rule*; the counter's two
fields in `AppState`, holding the *value*.

Why not a helper object owned by the bloc: an object with mutable state cannot be tested with a plain
`test()` without instantiating and driving it, and the house pattern here is unambiguous -
`bridge_cta_state.dart` and `swap_cta_state.dart` are both pure, Flutter-free modules whose tests
(`test/dashboard/bridge/bridge_cta_state_test.dart`, 231 lines, zero mocks, zero `pumpWidget`) are
the cheapest tests in the repo. [VERIFIED: file read]

Why not the counter in a local field on the bloc: `AppState` is `Equatable` with an explicit `props`
list (`app_state.dart:89-105`). A counter held outside the state cannot be asserted on, and the
consecutive-count is precisely the thing a test needs to drive.

Shape:

```dart
// lib/.../compute_stall.dart  - pure, no Flutter import
bool isStalled({
  required double? lastPercentage,
  required double? currentPercentage,
  required Duration unchangedFor,
  Duration threshold = const Duration(seconds: 8),
});
```

`AppState` gains `initPercentage` and the timestamp (or tick count) at which it last changed. Both
non-nullable-with-default, for the `copyWith` reason in Item 1.

---

### Item 3 - Public `AccountDrawer.show(context)`

**The mechanism, verified end to end.** `_showAccountDrawer()`,
`account_dropdown_selector.dart:165-223`:

| Line | What it does |
|---|---|
| 166 | `context.read<WalletDetailsCubit>()` - captured **before** the await |
| 168-213 | `ResponsiveDrawer.show<Wallet>(...)` with `bodyPadding: EdgeInsets.zero` (the list owns the scrolling viewport, per `responsive_drawer.dart:24-28`), title `"Your Accounts"`, a `BlocBuilder<AppBloc, AppState>` body, and a `GWButton` footer |
| 215-217 | Early return when the result is null or unchanged |
| 219 | `setState(() => selectedWallet = selected)` - **widget-local** |
| 220 | `widget.onAccountSelected?.call(selected)` - **widget-local** |
| 221 | `walletCubit.selectWallet(selected)` - **the real side effect** |
| 222 | `await Hive.box(walletBoxName).put(selectedWalletKey, selected.address)` - **the real side effect** |

[VERIFIED: file read]

**Three couplings to break, and only three:**

1. **`selectedWallet`** - the `State` field, used at line 194 to mark the selected row. Two
   context-free sources exist: `WalletDetailsCubit.state.selectedWallet` (the cubit is already read
   at line 166), and `Hive.box(walletBoxName).get(selectedWalletKey)` (already the seed at line 52).
   Prefer the cubit - it is the same value `selectWallet` writes at
   `wallet_details_cubit.dart:119-122`, so the highlight cannot desync from the selection.
2. **`_buildDrawerRow` / `_buildAvatar`** - private instance methods
   (`account_dropdown_selector.dart:225-360` and `362-383`). Neither touches `widget` or `setState`
   except `_buildDrawerRow`'s calls into `_confirmRenameWallet` / `_confirmDeleteWallet` (lines 341,
   351), which *do* use `setState` (lines 95-97, 156-160) and `mounted` (92, 148).
3. **`setState` + `onAccountSelected`** - lines 219-220, genuinely widget-local.

**Cleanest extraction, and it adds no UI:**

Move the drawer body, its rows and its avatar into a new `AccountDrawer` with a single static
`Future<Wallet?> show(BuildContext context)` that:
- reads the currently-selected wallet from `WalletDetailsCubit`,
- opens the identical `ResponsiveDrawer.show<Wallet>` call,
- performs lines 221-222 (`selectWallet` + Hive write) itself, since those are the *meaning* of
  selecting a wallet and every caller wants them,
- returns the selected `Wallet?`.

`_AccountDropdownSelectorState._showAccountDrawer()` then becomes:

```dart
Future<void> _showAccountDrawer() async {
  final selected = await AccountDrawer.show(context);
  if (selected == null || selected == selectedWallet) return;
  setState(() => selectedWallet = selected);
  widget.onAccountSelected?.call(selected);
}
```

The compute panel's `switch wallet ›` link calls `AccountDrawer.show(context)` and ignores the
result. **No new UI, no duplicated drawer, one behaviour.**

**The rename/delete complication, and why it does not block this.** Those two flows use `setState`
and `mounted` on the *selector's* State. They are reachable from the row's overflow menu. Two honest
options for the planner:

- **(a)** Move them with the rows into `AccountDrawer` as a small `StatefulWidget` body. Their
  `setState` calls (lines 95-97, 156-160) only maintain the local `selectedWallet` mirror, which
  `AccountDrawer` would own anyway. Cleanest.
- **(b)** Keep them where they are and pass them in as callbacks. Smaller diff, but the compute
  panel's call site would have to supply two callbacks it has no business knowing about, or the rows
  lose their menu when opened from the panel - which would make the same drawer behave differently
  depending on who opened it. **Rejected on that basis.**

Recommend **(a)**.

**Root-navigator hazard, already documented in this file.** Lines 61-67 and 104-110 both capture
`Navigator.of(context, rootNavigator: true)` *before* popping the drawer, with a comment explaining
why. `swap_settings_drawer.dart:52-63` records the same trap and what it cost when missed. Any
extraction must preserve those captures verbatim. [VERIFIED: file read x2]

---

### Item 4 - Preserving `txHash` on partial failure

**The exact code.** `submit_job_cubit.dart:184-223`:

```
184  final resp = await geniusApi.bridgeOut(...);
193  final txHash = resp.data;
195  if (!resp.isSuccess || txHash == null) {          // BRIDGE FAILED - nothing spent
196    emit(state.copyWith(isBridgingTokens: false,
199         processErrorMessage: 'Bridge transaction failed. Please try again.'));
203    return;
204  }
206  // process the job
207  final processResult = geniusApi.requestGeniusSDKProcess(jobJson: ...);
210  if (processResult != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
211    emit(state.copyWith(isBridgingTokens: false,
214         processErrorMessage: _processErrorMessage(processResult)));
217    return;                                          // ← txHash is IN SCOPE and DISCARDED
218  }
220  unawaited(fetchGnusBalanceWithDelay());
222  emit(state.copyWith(txHash: txHash, isBridgingTokens: false));
```

`14-CONTEXT.md`'s `195-218` is right as a span; the precise defect is **lines 210-218**. `txHash` is
a non-null local from line 193, in scope at line 211, and simply not passed. [VERIFIED: file read]

**The minimal state change.** `SubmitJobState.txHash` is already `String` with default `''`
(`submit_job_state.dart:4, 17`) - the hash needs no new field. What is missing is *which outcome the
hash belongs to*. Today `txHash.isNotEmpty` is read as "success" by
`submit_job_screen.dart:48`, so writing the hash on the failure path without a discriminator would
raise the success toast on a failed job. **The one-line fix is wrong on its own.**

**Recommended terminal states.** A non-nullable enum on `SubmitJobState`, defaulting to `none`:

```dart
enum JobOutcome {
  none,        // not submitted
  done,        // bridgeOut ok, requestGeniusSDKProcess ok  - hash is the receipt
  bridgedOnly, // bridgeOut ok, requestGeniusSDKProcess FAILED - hash is PROOF OF BURN
  bridgeFailed // bridgeOut failed - nothing spent, retry in place
}
```

This is exactly sketch 076's three terminal states (`076/README.md:141-149`) and CONTEXT's
"third terminal state: *bridged, not processed*". Mapping: line 195-204 → `bridgeFailed`; line
210-218 → `bridgedOnly` **plus `txHash: txHash`**; line 222 → `done`.

Non-nullable-with-default for the `copyWith` reason - `SubmitJobState.copyWith` is `x ?? this.x` on
every field (`submit_job_state.dart:43-55`), so a nullable outcome could never be reset.

**Two further defects in the same region the planner must handle, both new here:**

1. **`resetState()` cannot clear `filePickerError`.** `submit_job_cubit.dart:240` passes
   `filePickerError: null`, and `copyWith` at `submit_job_state.dart:51` is
   `filePickerError ?? this.filePickerError`. **Passing null is a no-op.** The identical dead line is
   at `:65` under the comment `// Clear previous errors`. Neither clears anything; only
   `setFilePickerError("")` (`:251`) does. Any new outcome field must not repeat this. [VERIFIED:
   file read]
2. **`resetState()` before the toast** - `submit_job_screen.dart:49` calls `resetState()` and
   `:50-55` then reads `state.txHash` from the *captured listener parameter*, so the toast does
   render the hash. But the screen is already empty and the hash exists nowhere else. CONTEXT's
   "unrecoverable by construction" is correct; the mechanism is that the hash survives only in the
   closure, not that the toast is blank. **CORRECTION of the mechanism, not the conclusion.**
   [VERIFIED: file read]

**A third, unrelated hazard the drawer will expose.** `SubmitJobCubit._initialize()`
(`:26-29`) is fired from the constructor and awaits two network calls. `fetchGnusBalance` guards its
emit with `if (!isClosed)` (`:42`), but **`fetchGnusTokenInfo`'s emit at `:58` and
`setFilePickerError`'s at `:247` do not.** On a route this rarely bites - the screen stays open. In a
drawer, which a user dismisses casually, an emit-after-close is reachable during the initial fetch.
[VERIFIED: file read]

---

### Item 5 - Splitting the error channels

**CORRECTION: the count in `14-CONTEXT.md` (and 076) undercounts.** CONTEXT names four origins
("balance, token-info and gas-estimate failures plus 'no file selected'"). Re-measured, there are
**nine call sites across six origins**, all funnelling to one field and one toast title.

| Line | Message | True origin | File picker? |
|---|---|---|---|
| 37 | `Unable to fetch GNUS balance` | Balance fetch (`gnusCubit.fetchGnusBalance`) | no |
| 54 | `Unable to fetch token information` | Token info (`gnusCubit.fetchGnusInfo`) | no |
| 89 | `Unable to retrieve job cost` | SDK cost lookup (`requestGeniusSDKCost` returned 0) | no |
| 104 | `No file selected.` | **File picker** (user cancelled) | **yes** |
| 108 | `The Selected File is not valid json` | **File picker** (`FormatException` from `jsonDecode`) | **yes** |
| 110 | `Failed to pick file: ${e.runtimeType}` | **File picker** (any other throw) | **yes** |
| 131 | `Missing required data for bridge gas estimation. Please select a wallet and network.` | Precondition (no wallet/network/token address) | no |
| 149 | `Failed to estimate bridge gas cost.` | **Gas estimate** | no |
| 176 | `Missing required data. Please select a wallet and network.` | Precondition at bridge time | no |

[VERIFIED: file read, `submit_job_cubit.dart`]

Six of the nine have nothing to do with a file picker, and all nine surface under
`title: "File Picker Error"` (`submit_job_screen.dart:32`). Two of them (37, 54) fire from
`_initialize()` in the **constructor**, so the very first thing a user can see on opening the flow is
a "File Picker Error" raised before any picker existed.

**How errors route today.** Two string-ish fields, two toasts, one listener:

- `SubmitJobState.filePickerError` - a `FilePickerError` wrapper class with a single `String message`
  (`submit_job_state.dart:59-63`). **Not `Equatable`, no `==` override**, so every
  `FilePickerError(...)` is a distinct instance and `previous.filePickerError != current...` at
  `submit_job_screen.dart:21` is identity-based - it fires on every emit, including
  `setFilePickerError("")`. Harmless today because the empty message is then skipped at `:28`.
- `SubmitJobState.processErrorMessage` - plain `String`, toast title `"Job Submission Error"`
  (`:38-46`), written only by `bridgeTokens` (`:199`, `:214`) via `_processErrorMessage`
  (`:258-275`, which maps the seven `GeniusNodeReturnValue` cases and returns `''` for `RET_OK`).
- The listener at `submit_job_screen.dart:19-57` calls the reset **before** raising each toast, and
  reads the message off the captured `state` parameter rather than the live one. Works, but means
  every toast costs a second emit.

[VERIFIED: file read x2]

**The smallest correct split.** Three channels, matched to the three things the UI must do
differently:

| Channel | Origins | UI treatment | Why separate |
|---|---|---|---|
| `fileError` | 104, 108, 110 | Toast / inline on step 1, "File Picker Error" stays honest | Only these are the picker |
| `costError` | 37, 54, 89, 131, 149 | **Inline `GWWarningNote` in step 2**, not a toast | These are all "we cannot price this job yet". They belong next to the cost, not in a corner. They also drive `costUnknown` in Item 6, which is a *state*, not an *event* - a toast is the wrong grammar for a state |
| `submitError` | 176, 199, 214 | Step 5 terminal state (`bridgeFailed` / `bridgedOnly`) | Already `processErrorMessage`; needs the outcome enum from Item 4, not a new channel |

Three fields, not nine. Line 176 moves from `filePickerError` to `submitError` - it is raised inside
`bridgeTokens`, i.e. at commit time, and today it is the one place the picker field is written
directly rather than through `setFilePickerError`.

**One message is being destroyed and should not be.** `submit_job_cubit.dart:148-151`:

```
if (!resp.isSuccess || jobGasCost == null) {
  setFilePickerError('Failed to estimate bridge gas cost.');
```

`resp.errorMessage` is discarded. The estimate path runs `createBridgeOutTransaction`
(`web3.dart:343+`), which at `web3.dart:390-400` calls `hasEnoughFundsForGas` and returns
`ApiResponse.error("Not enough funds for gas to bridge tokens")`. **That is the ETH-shortfall
message, and it is thrown away and replaced with a generic one under a file-picker title.** Passing
`resp.errorMessage` through instead is a one-line change that makes a whole class of failure
diagnosable. [VERIFIED: file read x2]

**A trap for the new fields.** Model each channel as a non-nullable `String` defaulting to `''`, not
a nullable object. The `x ?? this.x` `copyWith` (`submit_job_state.dart:43-55`) makes `null`
un-settable, and the existing `FilePickerError` wrapper buys nothing - it has one `String` field, no
`==`, and no subtype.

---

### Item 6 - `jobCost <= gnusBalance`

**The line, and the types - both confirmed.**

`submit_job_screen.dart:65`:

```dart
final isPurchaseable = jobCost != 0 && jobCost < gnusBalance;
```

- `jobCost`: **`int`** - `submit_job_state.dart:7` `final int jobCost;`, default `0` (`:20`). Sourced
  from `geniusApi.requestGeniusSDKCost(...)` at `submit_job_cubit.dart:79-81`.
- `gnusBalance`: **`double`** - `submit_job_state.dart:10` `final double gnusBalance;`, default `0`
  (`:23`). Sourced from `Coin.balance` via `gnusCubit.fetchGnusBalance()` at
  `submit_job_cubit.dart:32-47`.

[VERIFIED: file read x2] `int < double` is legal in Dart (both are `num`), so `<=` is a
one-character change with no cast.

**Both halves of the flag are broken, and they are separate bugs:**

1. `jobCost < gnusBalance` refuses **exactly enough**. `jobCost == 100`, `gnusBalance == 100.0` →
   `false` → the button disables and `submit_job_screen.dart:167-174` prints
   `* You do not have enough GNUS`. Wrong on the facts.
2. `jobCost != 0` folds **cost-unknown** into the same flag, and the `if (!isPurchaseable)` at `:167`
   makes cost-unknown *render as* insufficient funds. The user is told they are poor when the app
   simply has not priced the job.

**The house already has the right answer, one directory over.** `bridge_cta_state.dart:62`:

```dart
if (balance == null || parsedAmount > balance) {
  return BridgeCtaState.insufficientBalance;
}
```

`>`, not `>=` - so exactly-affordable passes. Pinned by
`test/dashboard/bridge/bridge_cta_state_test.dart:59-69`
(`'amount 1, balance 1 (exactly affordable) -> NOT insufficient'`). **Submit-job is the outlier, not
the norm.** [VERIFIED: file read x2]

**Recommendation:** a `submit_job_cta_state.dart` pure module in the same shape as
`bridge_cta_state.dart` - a `resolveSubmitJobCtaState(...)`, a `submitJobCtaLabel(...)`, a
`submitJobCtaEnabled(...)`, and a rung ladder that separates the states the one boolean conflates:

`submitting` → `noFile` → `costUnknown` → `costError` → `insufficientFunds` → `ready`

`insufficientFunds` carries the shortfall (`jobCost - gnusBalance`) so the UI can print it as a
number, per `076/README.md:151-153`.

#### Should the comparison account for gas? **No - and it must not.**

Three independent reasons, all measured:

1. **Units do not compose.** `jobCost` is GNUS, an integer. The gas figure is
   `state.jobGasCost`, a **preformatted display `String`** like `"0.00 Gwei"` -
   `submit_job_state.dart:8, 21`, produced at `genius_api.dart:1183-1186`
   (`"${gasPriceInGwei?.toStringAsFixed(2)} Gwei"`). Adding a Gwei-denominated string to a GNUS
   integer is not arithmetic.
2. **It is a gas *price*, not a gas *cost*.** `genius_api.dart:1183` calls
   `web3.getGasPriceInGwei(gasResponse.data)`, and `web3.dart:493` returns
   `gas?.getValueInUnit(EtherUnit.gwei)` - a price per unit of gas, never multiplied by the gas
   limit. `bridge_receipt.dart:17-23` already documents this exact caveat and refuses to print the
   figure as a fee for the same reason. So there is no total-cost number to subtract even in
   principle.
3. **The ETH check already exists and already runs.** `web3.dart:500-522`
   `hasEnoughFundsForGas({walletAddress, rpcUrl, gasLimit, gasPrice})` fetches
   `client.getBalance(address)` and compares against `gasPrice.getInWei * gasLimit`. It is called at
   `web3.dart:390-395`, **inside `createBridgeOutTransaction`** - which is on the path of *both*
   `getBrigeOutGasCost` and `bridgeOut`. So the ETH balance is checked at estimate time and again at
   submit time, before either can proceed.

[VERIFIED: file read x3 - `web3.dart`, `genius_api.dart`, `bridge_receipt.dart`]

**Direct answer to the question asked: yes, an ETH balance check exists.** It is
`hasEnoughFundsForGas` at `web3.dart:500`, reached from `web3.dart:390`. It is not missing - **its
error message is swallowed** at `submit_job_cubit.dart:148-151` (see Item 5). The correct fix is to
surface that message through the `costError` channel, not to widen the GNUS comparison.

---

## The Nine States - **CORRECTION to the 6-free / 3-blocked claim**

`14-CONTEXT.md:112` and `077/README.md:52-54` both record "10 exist / 5 to build / 6 need non-UI code
first", and CONTEXT:166-167 says three states "need new code before they can be rendered at all". The
task asked me to verify that rather than repeat it. **It does not hold: four states are free, five
need new code.**

Data reachable from the dashboard **today**, without new plumbing:

| Source | Where | Reachable from a dashboard widget? |
|---|---|---|
| `AppState.wallets` | `app_state.dart:5` | **yes** - `AppBloc` is provided in `main.dart:332`, above `MaterialApp.router` |
| `WalletDetailsState.selectedWallet` | `wallet_details_cubit.dart` | **yes** - `main.dart:325-330` |
| `SGNUSConnection{sgnusAddress, walletAddress, isConnected}` | `api.getSGNUSConnectionStream()` | **yes** - already consumed at `wallet_overview.dart:172-181` |
| `AppState.isProcessing` / `.processingPercentage` | `app_state.dart:23-24` | **yes** |
| `getInitializationStatus()` → `GeniusInitStatus{percentage, message}` | `genius_api.dart:1216-1222` | **NO** - polled only inside `SGNUSConnectionState`'s private fields (`sgnus_connection_widget.dart:25-27, 37-59`) and in `network_page.dart:64`. Nothing exposes it |
| `getNodeState()` → `GeniusNodeState` (8 values) | `genius_api.dart:1230-1233` | **NO** - grep across `lib/` and `packages/` finds **zero** call sites outside its own definition and `_mapNodeState`. Entirely unused |
| Connectivity | `connectivity_plus: 7.0.0` (`pubspec.yaml:45`) | **NO** - consumed only by `network_page.dart:3, 20-46` |

[VERIFIED: grep across `lib/` and `packages/genius_api/lib/`]

| # | State (sketch 077) | Data needed | Free? | What is missing |
|---|---|---|---|---|
| 01 | No wallet | `wallets.isEmpty` / `selectedWallet == null` | **FREE** | - |
| 02 | Not linked | `selectedWallet.address != connection.walletAddress` | **FREE** | The comparison is already computed at `submit_job_dashboard_button.dart:22-23` and discarded at `:26`. UI change only |
| 03 | Starting up | `getInitializationStatus().percentage < 1.0` | **NO** | The feed is trapped in a widget's private `State`. Needs exposure - `AppBloc` field + poll, or `getNodeState()` (better: 8 explicit lifecycle values instead of a float, and it is already written) |
| 04 | Stalled | init percentage unchanged for N | **NO** | Item 2 |
| 05 | Ready (idle) | `!isProcessing` | **FREE** | Free *as a value*, but indistinguishable from 08 until Item 1 lands. Success criterion 1 names this pair specifically |
| 06 | Processing | `isProcessing && processingPercentage` | **FREE** | Free, but the bar/number **must gate on `isProcessing`** - `app_bloc.dart:184-191` emits the percentage only while processing and `copyWith` cannot null it back (`app_state.dart:79`), so `isProcessing:false, processingPercentage:87.0` is reachable and permanent |
| 07 | Ready · last job finished | an `isProcessing` true→false **edge** | **NO** | Nothing stores it. `AppState` has no history and `AppBloc` keeps no prior tick |
| 08 | Unavailable | feed-dead flag | **NO** | Item 1 |
| 09 | Offline | connectivity | **NO** | `connectivity_plus` is installed (**no new dependency**) but exposed nowhere above `network_page.dart`. Needs a stream into `AppBloc` or a small provider above the root navigator |

**Score: 4 free (01, 02, 05, 06) · 5 need new code (03, 04, 07, 08, 09).**

CONTEXT's list of three blocked states (*stalled*, *job complete*, *unavailable* = 04, 07, 08) is
correct as far as it goes; it misses **03** and **09**. The design for those two cannot be verified
until their plumbing exists, which is the same risk CONTEXT:166-167 already names - it just applies
to five states, not three.

**`getNodeState()` deserves an explicit decision.** `GeniusNodeState`
(`genius_api_ffi.dart:997-1005`) enumerates `CREATING(0)`, `MIGRATING_DATABASE(1)`,
`INITIALIZING_DATABASE(2)`, `INITIALIZING_PROCESSING(3)`, `INITIALIZING_BLOCKCHAIN(4)`,
`INITIALIZING_TRANSACTIONS(5)`, `INITIALIZING_DHT(6)`, `READY(7)`. It maps 1:1 onto state 03's
sublines, is already wrapped with a fail-soft `_mapNodeState` (`genius_api.dart:1244-1250`), and is
**not a percentage** - so it cannot stall at 52.5% and cannot lie the way the ring does. It has never
been called. Whether to use it instead of, or alongside, `getInitializationStatus()` is a real
design choice the plan should make deliberately rather than inherit. [VERIFIED: file read]

---

## The FFI Processing Surface

Everything below re-read at the cited lines in `packages/genius_api/lib/ffi/genius_api_ffi.dart`.
**CONTEXT's "around lines 1001 and 1087-1120" is close: the node-state enum starts at 997 (not
1001), and the processing block runs 1087-1119.** [VERIFIED: file read]

```
997   enum GeniusNodeState { CREATING(0) … GENIUS_NODE_READY(7) }         // :997-1005
1087  enum GeniusProcessingStatus {
1089    GENIUS_PR_STATUS_DISABLED(0),    // "Processing was disabled"
1092    GENIUS_PR_STATUS_IDLE(1),        // "Not processing at the moment"
1095    GENIUS_PR_STATUS_PROCESSING(2);  // "Currently processing a job"
      }
1111  final class GeniusProcessingStatusInfo extends ffi.Struct {
1113    @GeniusProcessingStatus_t() external int status;
1117    @ffi.Float() external double percentage;   // "Progress percentage from 0.0 to 100.0"
      }
1121  final class GeniusStatusInfo extends ffi.Struct { double percentage; Pointer<Char> message; }
```

**A fourth value the current code cannot express.** `app_bloc.dart:180-182` collapses the three-value
enum to one boolean:

```dart
final isProcessing = statusInfo.status ==
    GeniusProcessingStatus.GENIUS_PR_STATUS_PROCESSING.value;
```

`DISABLED(0)` and `IDLE(1)` both become `false`, and so does a dead feed (`:194`). **Three distinct
node conditions collapse to one pixel.** `DISABLED` is arguably a tenth state ("processing turned
off"), or it can fold into 08 *Unavailable* - either is defensible, but the fold should be a decision
in the plan, not an accident of `==`.

**Units.** `GeniusProcessingStatusInfo.percentage` is documented **0.0-100.0** (`:1116`), and
`sgnus_connection_widget.dart:126` renders it with a literal `%` suffix. `GeniusInitStatus.percentage`
is **0.0-1.0** (`genius_api.dart:81`), and `sgnus_connection_widget.dart:96` multiplies by 100. **Two
percentage feeds on two different scales.** Any shared `GWProgressBar` must take a normalized 0-1
`value` and let each call site convert, or one of the two bars will be off by 100x.

**No fail-soft wrapper on the processing read.** `getProcessingStatus()` (`genius_api.dart:1210-1213`)
returns the raw struct with no try/catch and no `fromValue` mapping - unlike `getNodeState()`
(`:1230-1233` → `_mapNodeState` → `try/catch` → fallback) and `getTransactionManagerState()`
(`:1224-1227`). This is why `app_bloc.dart`'s untyped `catch` is the only guard, and why the
`14-CONTEXT` comment at `app_bloc.dart:157-158` calls it out.

---

## `ResponsiveDrawer` - current API and archetype

`lib/components/bottom_drawer/responsive_drawer.dart`, 342 lines, re-read in full.

```dart
static Future<T?> show<T>({
  required BuildContext context,
  required Widget child,
  String? title,
  List<Widget>? actions,
  Widget? footer,
  double desktopWidth = 420,
  bool useRootNavigator = true,
  bool isDismissible = true,
  bool enableDrag = true,
  EdgeInsetsGeometry bodyPadding = kDrawerBodyPadding,   // ← :102
});
```

[VERIFIED: file read, `:92-103`]

**What the shell owns since `8044bdb7` (2026-07-28) - the caller must NOT re-supply any of it:**

| Owned by the shell | Value | Line |
|---|---|---|
| Body inset | `kDrawerBodyPadding` = `fromLTRB(20, 24, 20, 20)` | `:29-34`, applied `:321` |
| Footer inset | `kDrawerFooterPadding` = `all(20)` - **no opt-out** | `:44-46`, applied `:331` |
| Footer top rule | `Border(top: BorderSide(color: gw.borderSubtle))` | `:332-334` |
| Panel fill | `gw.surfaceElevated` (#0C0E14), painted in **three** places | `:142`, `:172`, `:232` |
| Panel hairline | `Border.all(color: gw.borderSubtle, width: 1)` | `:148`, `:174` |
| Header | 56px toolbar, `titleLg` 18/w600, title inset 20, ✕ top-right, 1px `brandPrimarySubtle` rule | `:208`, `:217`, `:246-314` |
| Desktop vs mobile | `>= GeniusBreakpoints.medium` → right-aligned 420px dialog; else `showModalBottomSheet` | `:104-105`, `:124`, `:162` |

`EdgeInsets.zero` is the **only** sanctioned opt-out, and only for a body that owns a scrolling
viewport (`:24-28`). The job flow's step bodies are short and do not scroll, so **F1 should pass
nothing** and take the default. `account_dropdown_selector.dart:172` passes zero because its body is
a `ListView` - a different case.

**Three consumer hazards, all already documented in-repo:**

1. **Root navigator.** `useRootNavigator: true` by default (`:99`). A `Navigator.of(context).pop()`
   using the *caller's* context resolves to the shell's nested navigator and pops the **route**, not
   the drawer. `swap_settings_drawer.dart:52-63` records what this cost when missed (Apply dropped
   the user on the dashboard). Pop with `Navigator.of(context, rootNavigator: true)` from a caller
   context, or with a context from inside the drawer.
2. **Bloc visibility.** Because the drawer is pushed on the **root** navigator, its body builds under
   the root - so only providers **above `MaterialApp.router`** are visible. `AppBloc`,
   `WalletDetailsCubit`, `GeniusApi` all qualify (`main.dart:325-341`). **`SubmitJobCubit` does
   not** - it is created inside the `/submit_job` `GoRoute` builder (`router.dart:303-307`), which is
   *below* the root navigator. Every one of the 20 existing `ResponsiveDrawer.show` call sites either
   uses a root-level bloc or holds plain local state; **not one provides a bloc into a drawer**, so
   there is no precedent to copy. The job-flow drawer must wrap its `child` **and** its `footer` in
   an explicit `BlocProvider`/`BlocProvider.value`, or the cubit will not resolve. [VERIFIED: grep of
   all 20 call sites]
3. **Disposal of anything the drawer creates.** House idiom is
   `ResponsiveDrawer.show(...).whenComplete(() { ...dispose... })` - `swap_settings_drawer.dart:66-69`
   with the comment *"Both are created here, so both are disposed here - when the route is gone, not
   when either half unmounts."* If the drawer creates the `SubmitJobCubit`, this is where it closes.
   Note `router.dart:305` also builds a bare `GnusCubit(CoinService(), walletCubit)` that is never
   provided and never closed - do not copy that.

`ResponsiveDrawer`'s behaviour is pinned by `test/components/responsive_drawer_body_padding_test.dart`
(133 lines, 4 cases). Anything this phase changes about the shell will fail there first - which is
the point.

---

## Height Budget - re-derived from live constants

Every input re-read rather than carried from 076.

| Input | Value | Source |
|---|---|---|
| Card cap | `maxHeight: 300` | `dashboard_screen.dart:212` (two-column) **and `:293`** (one-column `OneColumnDashBoardView`) - the budget applies at **two** call sites, not one |
| Container inset | `EdgeInsets.all(GeniusWalletConsts.space6)` | `dashboard_screen.dart:342`, inside `DashboardScrollContainer` (`:322-347`) |
| `space6` | **12.0** | `genius_wallet_consts.dart:28` |
| **Usable** | **300 - 24 = 276px** | **CONFIRMED** |

The card is `OverviewDashboardView` (`dashboard_screen.dart:349-365`) → `DashboardScrollContainer` →
`WalletsOverview` (`lib/components/wallet_overview.dart`).

**Real component metrics, read from source, for the planner's own arithmetic:**

| Component | Metric | Source |
|---|---|---|
| `GWKicker` dense | 11px / w600 / ls 0.6 / **line-height 16** | `gw_kicker.dart:52-58` |
| `GWKicker` default | 13px / w600 / ls 0.5 / **line-height 18** | same |
| `GWAnimatedNumber` @ `numericDisplay` | 32px / w700 / **line-height 40** | `genius_wallet_typography.dart:102-109` |
| `GWStatTile` | dense kicker (16) + **3px gap** + `numericBody` 15/w600 **lh 20** = **39px** | `gw_stat_tile.dart:50-64` |
| `GWDetailGrid` row inset | `symmetric(h: space6=12, v: space4=8)` | `gw_detail_grid.dart:12-15` |

**One inherited number I could not verify.** Sketch 076's budget table (`076/README.md:105-110`)
gives the default `GWKicker` a height of **14** and the section-label option **~17px**. The style's
own line-height is **18** (13 x 18/13, `gw_kicker.dart:57`), and `GWStatTile` composes it as
**16** in its dense form. Neither 14 nor 17 appears in the source. That is a **3-4px discrepancy
against a budget with 3px of slack** - i.e. the discrepancy is the same size as the margin.
**Flagged, not smoothed over:** the 276px fit (success criterion 2) must be measured on a real
render, not carried from the sketch's table.

**Two structural facts the budget interacts with:**

- `WalletsOverview` already ships a `LayoutBuilder` + `SingleChildScrollView` + `ConstrainedBox`
  wrapper (`wallet_overview.dart:93-105`) precisely because the content does not fit today - the
  05-08 gap-B1 workaround, with a 35-line comment explaining it (`:53-92`). If Phase 14's card fits
  in 276px, **that wrapper becomes removable**, which is a deletion the phase can bank. If it does
  not fit, the phase has shipped the same workaround twice.
- The comment at `wallet_overview.dart:54` cites `dashboard_screen.dart:198-201, :270-273` for the
  two capped call sites. **Both pointers have drifted**: they are now **:211-213** and **:292-294**.
  A fourth stale pointer, in a source comment rather than a planning doc.

---

## Don't Hand-Roll

| Problem | Don't build | Use instead | Why |
|---|---|---|---|
| The 4px determinate bar | A `fl_chart` widget, or a new package | A `ClipRRect` + two `Container`s, or `LinearProgressIndicator` with `minHeight: 4` | `fl_chart` **is** already a dependency (`pubspec.yaml:36`, `^1.2.0`) so it would not be a *new* install - but it is a charting library and this is a rectangle. Nothing else in `lib/` uses a linear progress widget at all (grep: 8 `CircularProgressIndicator`, **zero** `LinearProgressIndicator`, **zero** `FractionallySizedBox`), so there is no fork to unify - `GWProgressBar` is a genuinely new primitive. **No new dependency is needed or permitted.** |
| State-ladder resolution (9 compute states, purchase rungs) | A `switch` inlined in `build()` | A pure module + plain `test()`, per `bridge_cta_state.dart` / `swap_cta_state.dart` | Two precedents, both with tests that need no mocks, no `pumpWidget`, no bloc harness |
| Drawer chrome (insets, hairlines, header, footer rule, panel fill) | Any `Padding`/`Border` in the job-flow body | `ResponsiveDrawer.show()` defaults | The shell owns all of it since `8044bdb7`, and `responsive_drawer.dart:15-28` records that "every caller remembers" already failed once with 17 unwalked drawers behind it |
| The label/value table in steps 2-3 | A hand-built `Column` of `Row`s | `GWDetailGrid` + `kGWDetailRowPadding` | `gw_detail_grid.dart:7-15` - rows pad themselves so a tappable copy row's hit area fills its cell |
| The "not enough GNUS" line | A red `Text` (which is what ships today, `submit_job_screen.dart:167-174`) | `GWWarningNote` | `gw_warning_note.dart:8-29` - it already solved the light-mode 1.6:1 amber failure that a raw `statusWarning` foreground reproduces |
| A copy affordance for the bridge hash | A fresh `Clipboard.setData` + snackbar | The `_CopyRow` shape at `transaction_displays.dart:534-580` | See the `GWCopyRow` note below |
| Spinners | `CircularProgressIndicator` | `GWSpinner` / `GWLoadingState` | `gw_spinner.dart:7` - *"Replace ad-hoc CircularProgressIndicator usages with this"*. `submit_job_screen.dart:201`'s `Loading(text:)` is one of them |
| Auto-fitting text anywhere the dashboard mounts | `AutoSizeText`, `FittedBox` | Fixed style + `overflow: TextOverflow.ellipsis` | **Enforced by `test/freeze_rule_test.dart`** across `lib/dashboard`, `lib/chart`, `lib/components/coins`, `lib/components/cards`, `lib/components/feedback`. Two commits have chased this macOS drag-resize hang |

**Key insight:** five of the seven rows above are enforced by something already in the repo - a test,
a shell default, or a doc comment written after the mistake was made once. In this codebase
hand-rolling is not just wasteful; it usually breaks a guard.

### `GWCopyRow` - the Phase 23 spillover, re-measured

Sketch 077 and CONTEXT both say the bridge-hash row makes a **third** consumer, reopening an
extraction Phase 23 refused at two
(`HANDOFF-260728-codebase-hygiene-and-standards.md:66`: *"`GWCopyRow` has 2 forks not 3"*).

Re-measured: `Clipboard.setData` appears at **10** sites in `lib/`. Most are one-shot buttons, not
label/value rows. The two genuine *rows* are `transaction_displays.dart:534-580` (`_CopyRow`, a
private `StatefulWidget` with hover, mono value, `kGWDetailRowPadding`, snackbar confirmation) and
`crypto_address_qr.dart:38`. That matches Phase 23's count of two. **The third consumer claim is
sound.** [VERIFIED: grep + file read]

Per CONTEXT:129-132 this must be **raised, not silently taken** - it is a Phase 23 decision. The
planner should include an explicit checkpoint asking whether to (a) extract `GWCopyRow` now and
reverse Phase 23's refusal, or (b) fork `_CopyRow` a third time and let Phase 23 decide later.

---

## Common Pitfalls

### Pitfall 1: `copyWith(x: null)` is a no-op, not a clear

**What goes wrong:** a field can never be reset. **Why:** every `copyWith` in the affected classes is
`x ?? this.x` - `AppState` (`app_state.dart:69-86`), `SubmitJobState` (`submit_job_state.dart:43-55`),
`GnusState` (`gnus_cubit.dart:26-32`). **Already shipped twice:** `submit_job_cubit.dart:65` and
`:240` both pass `filePickerError: null` under comments claiming to clear it, and neither does.
`AppState.processingPercentage` has the same problem, which is exactly CONTEXT's bug 4.
**Avoid:** non-nullable fields with sentinel defaults (`''`, `0`, an enum's `none`). **Warning sign:**
a `reset*` method that does not visibly change the UI.

### Pitfall 2: gating a bar or number on the percentage rather than on `isProcessing`

**What goes wrong:** `isProcessing:false, processingPercentage:87.0` is reachable and permanent.
**Why:** `app_bloc.dart:188-191` emits the percentage only inside `if (isProcessing)`, and Pitfall 1
means it can never be nulled. **Avoid:** every bar and every number gates on `isProcessing` first.
**Warning sign:** a stale percentage that survives a completed job - CONTEXT's bug 4 verbatim, and
what state 07 exists to prevent.

### Pitfall 3: popping a drawer with the caller's context

**What goes wrong:** the *route* pops, dumping the user on the dashboard mid-flow. **Why:**
`useRootNavigator: true` (`responsive_drawer.dart:99`) while the caller lives under the shell's
nested navigator. **Already shipped once** - `swap_settings_drawer.dart:52-63`. **Avoid:**
`Navigator.of(context, rootNavigator: true)`, or a context from inside the drawer.
**Warning sign:** on this flow it would mean a user loses a burned-token receipt.

### Pitfall 4: a bloc provided below the root navigator is invisible inside the drawer

**What goes wrong:** `context.read<SubmitJobCubit>()` throws `ProviderNotFoundException` from inside
the drawer. **Why:** `router.dart:303-307` creates it in the `/submit_job` route builder, below the
root navigator that `ResponsiveDrawer` pushes on. **No existing drawer provides a bloc**, so nothing
in-repo will remind anyone. **Avoid:** wrap `child` *and* `footer` in an explicit `BlocProvider`.
**Warning sign:** the drawer works from `/submit_job` and crashes from the dashboard.

### Pitfall 5: emit after close

**What goes wrong:** `Bad state: Cannot emit new states after calling close`. **Why:**
`SubmitJobCubit._initialize()` (`:26-29`) awaits two network calls fired from the constructor;
`fetchGnusBalance` guards with `if (!isClosed)` (`:42`) but `fetchGnusTokenInfo` (`:58`) and
`setFilePickerError` (`:247`) do not. A drawer gets dismissed far more casually than a route.
**Avoid:** guard every emit, or hoist the cubit above the drawer's lifetime.

### Pitfall 6: `AutoSizeText` anywhere the dashboard reaches

**What goes wrong:** a permanent macOS hang on drag-resize (100% of one core, window dead until
killed). **Why:** it emits a new `TextStyle` per frame, thrashing skia's `ParagraphCache`.
**Enforced:** `test/freeze_rule_test.dart` scans `lib/dashboard`, `lib/chart`,
`lib/components/coins`, `lib/components/cards`, `lib/components/feedback`. Note the compute panel's
current widgets sit **outside** those directories -
`lib/components/sgnus/sgnus_connection_widget.dart:138` and `lib/components/wallet_overview.dart`
still use `AutoSizeText` and are not scanned. **If Phase 14 moves any of this into
`lib/components/cards/`, the guard starts failing.** That is the guard doing its job; the fix is a
fixed style plus `overflow: TextOverflow.ellipsis`, never widening the exclusion list.

### Pitfall 7: `FilePickerError` has no `==`

**What goes wrong:** `listenWhen` at `submit_job_screen.dart:21` compares by identity, so it fires on
every emit including the empty reset. **Why:** `submit_job_state.dart:59-63` is a plain class with a
single `String` and no `Equatable`; `SubmitJobState` is not `Equatable` either. Harmless today
because `:28` skips empty messages, but it makes any value-equality test impossible. **Avoid:** plain
`String` channels (Pitfall 1's recommendation solves this too).

---

## Code Examples

### The house pure-module pattern (verbatim shape to copy for items 2 and 6)

```dart
// Source: lib/dashboard/bridge/bridge_cta_state.dart:42-82 - verbatim
BridgeCtaState resolveBridgeCtaState({
  required String amount,
  required double? balance,
  required bool isEstimating,
  required bool hasEstimate,
  required bool isError,
  required bool isSubmitting,
}) {
  if (isSubmitting) return BridgeCtaState.submitting;

  final parsedAmount = double.tryParse(amount);
  if (amount.isEmpty || parsedAmount == null) return BridgeCtaState.enterAmount;

  // NOTE the boundary: `>` not `>=`, so exactly-affordable PASSES.
  if (balance == null || parsedAmount > balance) {
    return BridgeCtaState.insufficientBalance;
  }
  if (isEstimating) return BridgeCtaState.estimatingGas;
  if (isError) return BridgeCtaState.gasError;
  if (hasEstimate) return BridgeCtaState.ready;
  return BridgeCtaState.estimatingGas;
}
```

### Its test (no mocks, no `pumpWidget`, no bloc harness)

```dart
// Source: test/dashboard/bridge/bridge_cta_state_test.dart:59-69 - verbatim
test('amount 1, balance 1 (exactly affordable) -> NOT insufficient', () {
  final state = resolveBridgeCtaState(
    amount: '1', balance: 1,
    isEstimating: false, hasEstimate: false,
    isError: false, isSubmitting: false,
  );
  expect(state, isNot(BridgeCtaState.insufficientBalance));
});
```

This is the check Item 6 needs, one identifier renamed.

### Exhaustive-enum guard - cheap and it catches a whole class of drift

```dart
// Source: test/dashboard/bridge/bridge_cta_state_test.dart:223-230 - verbatim
group('bridgeCtaEnabled — exhaustive', () {
  test('only ready is enabled', () {
    final enabledStates = BridgeCtaState.values.where(bridgeCtaEnabled).toSet();
    expect(enabledStates, {BridgeCtaState.ready});
  });
});
```

For CMP-07 the analogue is: every one of the nine states maps to a distinct `(dot, label)` pair -
which is success criterion 1 expressed as one `expect` on a `Set` length.

### Drawer-created disposables

```dart
// Source: lib/squid_router/swap_settings_drawer.dart:45-69 - shape
ResponsiveDrawer.show<void>(
  context: context,
  title: 'Swap Settings',
  child: _SlippageForm(controller: controller),
  footer: _ApplyFooter(
    raw: raw,
    onApply: (value) {
      onSlippageChanged(value);
      // rootNavigator: true - see Pitfall 3.
      Navigator.of(context, rootNavigator: true).pop();
    },
  ),
  // Both are created here, so both are disposed here.
).whenComplete(() {
  controller.dispose();
  raw.dispose();
});
```

### The measured re-arm path (Item 1's safety proof)

```dart
// Source: lib/dashboard/home/view/dashboard_screen.dart:110-117 - verbatim
Future<void> _onRefresh(BuildContext context) async {
  final walletCubit = context.read<WalletDetailsCubit>();
  context.read<AppBloc>().add(LoadWallets());   // → _startProcessingPolling(), app_bloc.dart:123
  if (walletCubit.state.selectedWallet != null &&
      walletCubit.state.selectedNetwork != null) {
    walletCubit.getCoins();
  }
}
```

---

## Runtime State Inventory

Phase 14 is not a rename or migration, but it does touch persisted and OS-level state, so the five
categories are answered explicitly rather than skipped.

| Category | Items found | Action required |
|---|---|---|
| Stored data | **Hive `walletBoxName` / `selectedWalletKey`** - written by `account_dropdown_selector.dart:222`. `AccountDrawer.show()` must keep writing it or wallet selection stops persisting across restarts. No schema change, no key rename. | Code move only - **no data migration** |
| Live service config | **None.** No n8n, Datadog, Tailscale or Cloudflare surface is touched. Verified by grep for those names across `lib/` and `.planning/phases/14-*` - zero hits. | none |
| OS-registered state | **None.** No task scheduler, launchd or pm2 registration. The only OS coupling is the macOS Hive container lock at `~/Library/Containers/ai.gnus.GeniusWallet.jakub/` (CLAUDE.md), which constrains *how many sessions may run the app*, not what this phase changes. | none |
| Secrets / env vars | **`GW_DEV_TOOLS`** - `--dart-define=GW_DEV_TOOLS=true` gates `kShowDevTools`, which gates `DevMockSgnus.processingOverride` (`dev_mock_sgnus.dart:61`, `app_bloc.dart:162-175`). **This is the only way to reach the SGNUS branch in a walk** (`dev_mock_sgnus.dart:6-9`: that branch had never been reached by any walk before the fixture existed). If Item 1 adds a feed-state enum, the dev override at `app_bloc.dart:167-172` must set it too, or the mock renders a state the real feed cannot produce. | **Code edit** to the dev override |
| Build artifacts | **None.** No generated Dart, no egg-info, no native rebuild. `flutter analyze` is clean at HEAD, so no stale `.g.dart` is masking anything. | none |

---

## Environment Availability

| Dependency | Required by | Available | Version | Fallback |
|---|---|---|---|---|
| Flutter toolchain | everything | **yes** | `flutter analyze` ran clean in 6.8s | - |
| `flutter test` | CMP-10 | **yes** | 516 cases execute | - |
| `tool/check_brace_style.sh` | CMP-10 | **yes** | returns `0` at HEAD | - |
| `connectivity_plus` | state 09 | **yes** | `7.0.0`, `pubspec.yaml:45` | Already installed - **no new dependency** |
| `mockito` | tests, if needed | **yes** | `^5.0.0`, `pubspec.yaml:58` | The house pattern needs no mocks |
| `bloc_test` | bloc tests | **NO** | not in `pubspec.yaml` | **Do not add it.** Pure modules + plain `test()` is the house pattern and covers everything here |
| `fl_chart` | not needed | yes (`^1.2.0`) | - | Irrelevant - the bar is a `Container` |
| Live SGNUS node | walking states 03/04/06 | **unknown** | - | `--dart-define=GW_DEV_TOOLS=true` + the dev bubble's MOCK section fakes `isProcessing`; it does **not** fake the init feed or the stall |
| macOS signing profile | `flutter run` on macOS | **unverified** | - | Expires every 7 days (memory: `geniuswallet-macos-ios-setup`). Executor concern, not research |

**Missing dependencies with no fallback:** none.

**Gap worth naming:** `DevMockSgnus` can force `isProcessing` (`:61`, `:70`) and a fixed 42.0%
percentage (`:65`), but there is **no** dev override for the init feed, the stall, or connectivity.
States **03, 04, 09 have no walk path today.** If success criterion 1 is to be verified by eye, the
plan needs to extend the dev bubble - which is a real task, not a footnote.

---

## Validation Architecture

### Test framework

| Property | Value |
|---|---|
| Framework | `flutter_test` (SDK), `pubspec.yaml:56-57`. **No `bloc_test`.** `mockito: ^5.0.0` present but unused by the pure-module pattern |
| Config file | none - default `test/` discovery |
| Quick run | `flutter test test/<file>_test.dart` |
| Full suite | `flutter test` |
| Analyzer gate | `flutter analyze` - **`No issues found!` at HEAD** (measured) |
| Brace gate | `bash tool/check_brace_style.sh --count` - **`0` at HEAD** (measured) |
| Test files | **57** |
| **Baseline** | **`+515 -1`** at `8ed02e78` (measured 2026-07-29) |
| The 1 failure | `test/components/gw_page_header_subtitle_gap_test.dart` - *"a tall trailing does not push the subtitle down"*. **Pre-existing, unrelated to Phase 14**, tree was clean when measured |

**Baseline caveat, per CLAUDE.md.** *"Only the executor may run the full `flutter test` suite and
quote a baseline."* This one was taken by a research session so the plan could be written against a
real number. **The executor must re-take it before trusting it.** Note also that CLAUDE.md's parallel
-sessions section records a 187 → 222 drift that made agents misread neighbours' tests as
regressions; `test/boot_sequence_test.dart:10-13` still cites 187. The count is now 516. Do not
inherit a baseline from a document.

**Also note:** the previously-documented failure (`test/local_wallet_storage_test.dart`, "Missing
definition of main method", cited at `boot_sequence_test.dart:11-13`) **no longer appears** - that
file is not in the current `test/` listing. The one failure today is a different one. **Two stale
test facts corrected.**

### Phase requirements → test map

| Req | Behaviour | Type | Command | Exists? |
|---|---|---|---|---|
| CMP-01 | `RetryProcessingStatus` re-arms the timer; `unavailable` != `idle` in state | unit | `flutter test test/dashboard/compute_feed_state_test.dart` | ❌ Wave 0 |
| CMP-02 | N unchanged samples → stalled; N-1 → not stalled; a changed value resets the counter | unit (pure fn) | `flutter test test/dashboard/compute_stall_test.dart` | ❌ Wave 0 |
| CMP-03 | `AccountDrawer.show()` returns the tapped wallet; `selectWallet` + the Hive write both happen | widget | `flutter test test/account/account_drawer_show_test.dart` | ❌ Wave 0 |
| CMP-04 | process-fails-after-bridge → outcome `bridgedOnly` **and `txHash` non-empty**; bridge-fails → `bridgeFailed` and hash empty | unit (cubit) | `flutter test test/submit_job/submit_job_outcome_test.dart` | ❌ Wave 0 |
| CMP-05 | each of the 9 raise sites lands in the right channel; the ETH-shortfall message survives instead of being replaced | unit | `flutter test test/submit_job/submit_job_errors_test.dart` | ❌ Wave 0 |
| CMP-06 | **exactly-affordable is purchasable**; `jobCost == 0` → `costUnknown`, never `insufficientFunds`; shortfall arithmetic | unit (pure fn) | `flutter test test/submit_job/submit_job_cta_state_test.dart` | ❌ Wave 0 - clone `bridge_cta_state_test.dart` |
| CMP-07 | all 9 states map to **distinct** `(dot, label)` pairs - success criterion 1 as one `expect` | unit (pure fn) | `flutter test test/dashboard/compute_state_test.dart` | ❌ Wave 0 |
| CMP-08 | 276px in all 9 states | **manual walk** | - | Not automatable without the banned golden/visual harness. Success criterion 2 says *measured, not estimated* - so it is a walk with a measurement, and the sketch's in-browser meter is the closest proxy |
| CMP-09 | five bug sites no longer produce the old output | covered by CMP-01/06/07 + walk | - | partial |
| CMP-10 | analyze 0, suite green, brace 0 | gate | `flutter analyze && flutter test && bash tool/check_brace_style.sh --count` | ✅ exists |

### Sampling rate

- **Per task commit:** the single new `*_test.dart` for that task, plus `flutter analyze`.
- **Per wave merge:** `flutter test` + `bash tool/check_brace_style.sh --count`.
- **Phase gate:** full suite green **against the executor's own re-taken baseline**, analyze 0, brace
  0, then `/gsd-verify-work`.

### Wave 0 gaps

- [ ] `test/dashboard/compute_stall_test.dart` - CMP-02
- [ ] `test/dashboard/compute_state_test.dart` - CMP-07
- [ ] `test/dashboard/compute_feed_state_test.dart` - CMP-01
- [ ] `test/submit_job/submit_job_cta_state_test.dart` - CMP-06
- [ ] `test/submit_job/submit_job_outcome_test.dart` - CMP-04
- [ ] `test/submit_job/submit_job_errors_test.dart` - CMP-05
- [ ] `test/account/account_drawer_show_test.dart` - CMP-03
- [ ] No framework install needed. **No `bloc_test`.** No fixtures, no harness.

`test/submit_job/` and `test/dashboard/` (the latter exists) are the natural homes;
`test/dashboard/bridge/` is the precedent for a nested subdirectory.

---

## Security Domain

`security_enforcement: true`, `security_asvs_level: 1` (`.planning/config.json`).

### Applicable ASVS categories

| Category | Applies | Standard control here |
|---|---|---|
| V2 Authentication | no | Phase touches no auth path |
| V3 Session management | no | No sessions |
| V4 Access control | no | Local-first wallet, no server-side authz |
| V5 Input validation | **yes** | The job file is a trust boundary - see below |
| V6 Cryptography | **indirectly** | Private keys are read at `genius_api.dart:1198` / `web3.dart:524+`. **Do not touch.** No key material may reach a new state field, a log line, or a toast |
| V7 Error handling & logging | **yes** | Item 5 rewrites the error surface. `tool/check_no_new_key_logging.sh` exists and guards this |
| V9 Communications | no | RPC URLs unchanged |

### Threat patterns for this stack

| Pattern | STRIDE | Standard mitigation | Status here |
|---|---|---|---|
| Unvalidated file read + parse | Denial of service | Size cap before `readAsString`, and parse off the UI isolate | **PRESENT, unmitigated.** `submit_job_cubit.dart:74-77` does `File(result.files.single.path!).readAsString()` then `jsonDecode(content)` with **no size limit and no isolate**. A large or deeply-nested JSON blocks the UI thread. Extension is filtered to `json` (`:69`) but an extension is not a size. **This is a trust boundary, and CLAUDE.md's not-lazy list names input validation at trust boundaries explicitly.** [VERIFIED: file read] |
| Null-assertion on external input | Crash / DoS | Null-check | `result.files.single.path!` (`:75`) - the bang is on a `FilePicker` field that is nullable on some platforms. Caught by the outer `catch` at `:106` and re-raised as `Failed to pick file: ...`, so it degrades rather than crashes. Acceptable, worth a note |
| Sensitive data in a log or toast | Information disclosure | Never format key material into a message | The `txHash` is a **public** on-chain identifier - safe to display and copy. `_processErrorMessage` (`:258-275`) maps a fixed enum to fixed strings and interpolates nothing. `Failed to pick file: ${e.runtimeType}` (`:110`) prints a **type**, not a path or content - deliberately narrow, and it should stay that way when the channels split |
| New logging of key material | Information disclosure | `tool/check_no_new_key_logging.sh` | Guard already exists. **The planner should add it to the phase gate**, since Item 5 rewrites error strings |
| Irreversible spend with no receipt | Repudiation | Persist the proof | **This is Item 4.** The user burns GNUS and is left with no evidence. It is the phase's most consequential security-adjacent defect, and it is already in scope |

**Recommendation for V5:** a size cap before `readAsString` (a `File.length()` check against a
constant, ~2-3 lines) is the minimum-code fix and belongs in this phase, since Item 5 is already
rewriting the surrounding error handling. Moving `jsonDecode` to an isolate is a larger change and
can be a `ponytail:` with a named ceiling.

---

## State of the Art (in-repo, not ecosystem)

| Old approach | Current approach | When it changed | Impact on this phase |
|---|---|---|---|
| Each drawer caller pads its own body/footer | The shell owns both insets; `EdgeInsets.zero` is the only opt-out | `8044bdb7`, 2026-07-28 | F1 passes **no** `bodyPadding` |
| Drawer panel `surfaceMenu` #171A21, no border | `surfaceElevated` #0C0E14 + `borderSubtle` hairline, in all three paint sites | `8044bdb7`, 2026-07-28 | Nothing to do - inherited |
| Hand-built kicker in five places, 3 sizes / 5 trackings | `GWKicker(dense:)`, two steps | sketch 065 | The `COMPUTE` / `BALANCE` labels |
| Hand-built stat pairs (10 instances) | `GWStatTile` | 2026-07-28 | The compute readouts |
| Balance at a hardcoded 48px `Colors.white` | `GWAnimatedNumber` @ `numericDisplay` 32/40 w700 | 2026-07-28 | Bug 5's fix, and it returns 16px to the budget |
| Ad-hoc `CircularProgressIndicator` | `GWSpinner` / `GWLoadingState` | `gw_spinner.dart:7` | Replaces `Loading(text:)` at `submit_job_screen.dart:201` |
| `AutoSizeText` everywhere | Fixed style + ellipsis, guarded by a test | `37639d5` + `freeze_rule_test.dart` | Constrains anything moved into a scanned directory |
| Ladder logic inlined in `build()` | Pure module + plain `test()` | `swap_cta_state.dart`, then `bridge_cta_state.dart` | The pattern for items 2, 6 and CMP-07 |

**Deprecated / outdated in this area:**

- `Loading(text:)` (`lib/components/loading.dart`) - superseded by `GWSpinner`/`GWLoadingState`.
- The `filePickerError` / `FilePickerError` pair - superseded by Item 5's split.
- `GeniusBalanceDisplay`'s hardcoded 48px + `Colors.white` (`:79`, `:81`) **and `Colors.grey`
  (`:94`)** - superseded by `GWAnimatedNumber`.
- **`getNodeState()` is not deprecated - it has simply never been called.** It may be the right
  source for state 03.

---

## Package Legitimacy Audit

**This phase installs no external packages.** CONTEXT hard-constraint: *"No new dependencies. Two
package installs declined in a row."*

| Package | Registry | Verdict | Disposition |
|---|---|---|---|
| *(none)* | - | - | - |

Everything required is already in `pubspec.yaml` and was confirmed by reading the file rather than a
registry: `connectivity_plus: 7.0.0` (`:45`), `mockito: ^5.0.0` (`:58`), `equatable: ^2.0.5` (`:18`),
`flutter_test` from the SDK (`:56-57`).

**Packages removed due to a `[SLOP]` verdict:** none.
**Packages flagged `[SUS]`:** none.
**`bloc_test` is deliberately NOT recommended** - not present, not needed, and adding it would breach
the no-new-dependency constraint.

---

## Assumptions Log

| # | Claim | Section | Risk if wrong |
|---|---|---|---|
| A1 | N = 8 seconds is the right stall threshold | Item 2 | The detector guards a feed that has never been traced. Too low → healthy long jobs render as *stalled*; too high → the 52.5% lie persists for longer than a user waits. **Mitigation: the derivation band (3-9.8s) is measured; only the point inside it is a judgement, and the required `ponytail:` names the ceiling** |
| A2 | `ProcessingFeed{unknown, live, unavailable}` is the right shape for the feed flag | Item 1 | Shape only. The *requirement* (three outcomes cannot fit in one bool) is verified; a different encoding works equally well |
| A3 | Three error channels (`fileError` / `costError` / `submitError`) is the right split | Item 5 | If the UI wants finer granularity - e.g. gas-estimate separate from cost-lookup - a fourth channel is a trivial addition. The 9-sites/6-origins measurement is verified; the grouping is a recommendation |
| A4 | Option (a) - moving rename/delete into `AccountDrawer` - is the right extraction | Item 3 | Larger diff than (b). (b) was rejected on a reasoned basis (same drawer behaving differently by opener), not measured |
| A5 | `getNodeState()` is a better source for state 03 than `getInitializationStatus()` | The Nine States | It has never been called, so its runtime behaviour is **completely unverified**. It may not advance, may throw, or may sit at `INITIALIZING_BLOCKCHAIN(4)` forever - the same stall the percentage shows, just spelled differently. **Must be spiked before it is planned on** |
| A6 | A size cap before `readAsString` is the right V5 control | Security Domain | The vulnerability is verified; the specific control is a recommendation. An isolate-based parse is the more complete fix |
| A7 | The macOS signing profile is currently valid | Environment | Not checked. Blocks `flutter run` walks, not `flutter test`. Executor's problem |

---

## Open Questions

1. **Which feed does the stall detector guard, and at what interval?**
   - Known: the 52.5% stall is on `getInitializationStatus()`; the app polls that at **3s**
     (`sgnus_connection_widget.dart:42`) and `getProcessingStatus()` at **1s**
     (`app_bloc.dart:138`); the trace was at **250ms**. `14-CONTEXT.md` names 1s, which belongs to
     the other feed.
   - Unclear: whether the panel should also stall-detect the *processing* percentage. Nothing has
     ever measured its cadence.
   - **Recommendation:** guard the init feed only, at a duration-expressed threshold, and record
     explicitly that the processing feed is untraced. A processing-feed detector is a second,
     separate decision that needs a measurement first.

2. **`getNodeState()` - use it, or leave it?**
   - Known: it exists (`genius_api.dart:1230`), is fail-soft (`_mapNodeState`, `:1244-1250`),
     enumerates 8 explicit lifecycle values (`genius_api_ffi.dart:997-1005`), and maps cleanly onto
     state 03's sublines. It has **zero** callers.
   - Unclear: whether it actually advances at runtime. Nobody has ever called it.
   - **Recommendation:** a 15-minute spike before planning around it. If it advances to
     `GENIUS_NODE_READY(7)` it is strictly better than a float that stalls at 0.525. If it stalls
     too, the stall detector covers both and the choice is cosmetic.

3. **Does `DISABLED(0)` deserve a tenth state?**
   - Known: `GENIUS_PR_STATUS_DISABLED(0)` (`genius_api_ffi.dart:1089`) is currently collapsed into
     `isProcessing:false` alongside `IDLE(1)` and alongside a dead feed.
   - Unclear: whether it is reachable in this build.
   - **Recommendation:** fold it into 08 *Unavailable* with a distinct subline, and say so in the
     plan. A tenth state on a 3px budget is not free.

4. **`GWCopyRow` - extract now, or fork a third time?**
   - Known: two genuine forks today (`transaction_displays.dart:534-580`,
     `crypto_address_qr.dart:38`), so Phase 23's refusal was correctly measured; this phase makes a
     third.
   - **This is a Phase 23 decision.** CONTEXT:129-132 requires it be raised, not taken.
   - **Recommendation:** an explicit checkpoint in the plan.

5. **How are states 03, 04 and 09 walked?**
   - Known: `DevMockSgnus` can force `isProcessing` and a fixed 42.0% (`:61`, `:65`). It cannot fake
     the init feed, a stall, or connectivity.
   - **Recommendation:** extend the dev bubble as an explicit task, or success criterion 1 cannot be
     verified for three of the nine states.

6. **Does the 05-08 scroll wrapper come out?**
   - Known: `wallet_overview.dart:93-105` exists only because the content overflows 276px, and
     carries a 35-line justification.
   - Unclear: whether the P1 rebuild genuinely fits, given the 3-4px `GWKicker` discrepancy between
     sketch 076's table and the live constants.
   - **Recommendation:** measure on a real render before deciding. If it fits, delete the wrapper -
     that is the phase's cleanest deletion. If it does not, the workaround has now shipped twice on
     the same card.

---

## Sources

### Primary (HIGH confidence) - files read in this session at `8ed02e78`

- `lib/bloc/app_bloc.dart` (458 lines, full) · `lib/bloc/app_state.dart` (111, full) ·
  `lib/bloc/app_event.dart` (70, full)
- `lib/submit_job/cubit/submit_job_cubit.dart` (277, full) ·
  `lib/submit_job/cubit/submit_job_state.dart` (64, full) ·
  `lib/submit_job/view/submit_job_screen.dart` (209, full)
- `lib/account/account_dropdown_selector.dart` (432, full) ·
  `lib/components/bottom_drawer/responsive_drawer.dart` (342, full)
- `lib/components/wallet_overview.dart` (239, full) ·
  `lib/components/sgnus/sgnus_connection_widget.dart` (157, full) ·
  `lib/components/job/submit_job_dashboard_button.dart` (42, full)
- `lib/dashboard/home/view/dashboard_screen.dart` (:105-120, :166-235, :238-470) ·
  `lib/dashboard/gnus/cubit/gnus_cubit.dart` (88, full) ·
  `lib/dashboard/bridge/bridge_cta_state.dart` (113, full) ·
  `lib/dashboard/bridge/bridge_receipt.dart` (:1-60) ·
  `lib/dashboard/home/widgets/transaction_displays.dart` (:534-580)
- `lib/components/cards/gw_kicker.dart` · `gw_stat_tile.dart` · `gw_detail_grid.dart` ·
  `lib/components/feedback/gw_warning_note.dart` · `lib/components/data/gw_animated_number.dart`
- `lib/theme/genius_wallet_consts.dart` (:19-35) · `genius_wallet_typography.dart` (:98-115) ·
  `gw_colors.dart` · `genius_wallet_colors.dart` (:213)
- `lib/navigation/router.dart` (:292-315) · `lib/main.dart` (:320-350) ·
  `lib/components/overlay/responsive_overlay.dart` (:135-160) · `lib/dev/dev_mock_sgnus.dart`
- `packages/genius_api/lib/ffi/genius_api_ffi.dart` (:985-1130) ·
  `packages/genius_api/lib/src/genius_api.dart` (:70-100, :1154-1255) ·
  `packages/genius_api/lib/web3/web3.dart` (:320-345, :370-540)
- `test/dashboard/bridge/bridge_cta_state_test.dart` (231, full) ·
  `test/components/responsive_drawer_body_padding_test.dart` (133, full) ·
  `test/freeze_rule_test.dart` (full) · `test/boot_sequence_test.dart` (:1-40)
- `pubspec.yaml` · `.planning/config.json` · `CLAUDE.md`

### Primary - commands run in this session

- `flutter analyze` → **`No issues found! (ran in 6.8s)`**
- `flutter test` → **`+515 -1`**, one pre-existing failure in
  `test/components/gw_page_header_subtitle_gap_test.dart`
- `bash tool/check_brace_style.sh --count` → **`0`**
- `find test -name "*_test.dart" | wc -l` → **57**
- grep sweeps: `LoadWallets` dispatch sites · `ResponsiveDrawer.show` call sites (20) ·
  `hasEnoughFundsForGas` · `getNodeState` · `Clipboard.setData` (10) ·
  `LinearProgressIndicator` (0) · `FractionallySizedBox` (0) · `connectivity` ·
  `class GWStatusDot|GWProgressBar|GWCopyRow|GWStepList|GWStepBar` (0 - all confirmed absent)

### Secondary (MEDIUM confidence) - planning documents, cross-checked against code

- `.planning/phases/14-compute-panel-job-flow/14-CONTEXT.md`
- `.planning/sketches/076-compute-on-base-components/README.md` ·
  `.planning/sketches/077-compute-interactive/README.md` and `index.html:235-300`
- `.planning/sketches/015-boot-loading-sequence/README.md:55-110` - **the only trace of the 52.5%
  stall that exists**
- `.planning/spikes/MANIFEST.md:3` and `.planning/spikes/002-init-progress-polling/README.md:13` -
  both carry a NOTE stating the 52.5% figures come from a **later** 40s/161-poll cold-start trace,
  **not** from spike 002. Sketch 015 is authoritative for those numbers
- `.planning/HANDOFF-260728-codebase-hygiene-and-standards.md:66, 81` - the `GWCopyRow` refusal
- `git show --stat 8044bdb7` - the drawer archetype change

### Tertiary (LOW confidence)

- None. No web search was performed. Nothing in this phase depends on external documentation - the
  entire surface is this repository plus a vendored FFI header, and every claim above was checked by
  reading a file or running a command in this session.

---

## Metadata

**Confidence breakdown:**

| Area | Level | Reason |
|---|---|---|
| The five shipped bugs | **HIGH** | All five re-read at the cited lines. All CONTEXT pointers exact |
| Items 1, 3, 4, 6 | **HIGH** | Mechanism read end to end; re-arm path proven live via pull-to-refresh; boundary precedent already tested one directory over |
| Item 5 (split) | **HIGH** on the measurement (9 sites / 6 origins, enumerated), **MEDIUM** on the 3-channel grouping (a recommendation) |
| Item 2 (stall detector) | **MEDIUM** | The band 3-9.8s is derived from measured data. N=8 inside it is a judgement, and the feed it will guard has never been traced |
| The nine states | **HIGH** | Every data source grep'd for reachability. The 4-free/5-blocked correction is verified, not inferred |
| FFI surface | **HIGH** | Enums, struct and units read at source; the two-scale percentage hazard is verified |
| `ResponsiveDrawer` | **HIGH** | Read in full; all 20 call sites grep'd; the bloc-visibility hazard follows from `useRootNavigator: true` and is confirmed by zero counter-examples |
| Test patterns | **HIGH** | Baseline and both gates measured. **Two stale test facts in existing docs corrected** |
| Height budget | **MEDIUM** | Constants verified; the sketch's `GWKicker` heights (14 / ~17) do not match the source line-heights (16 / 18), a 3-4px gap against 3px of slack. Must be measured on a real render |
| No-new-dependency | **HIGH** | `LinearProgressIndicator` 0 hits, `FractionallySizedBox` 0 hits, `connectivity_plus` already installed, `fl_chart` unnecessary |
| Security | **MEDIUM-HIGH** | The unbounded `readAsString` + `jsonDecode` is verified. The specific control is a recommendation |

**Inherited claims that did NOT survive re-measurement (3):**

1. **"Six of the nine states are free, three need new code."** It is **four free, five blocked** -
   states 03 (*Starting up*) and 09 (*Offline*) have no data source reachable from the dashboard.
2. **"`filePickerError` carries four origins."** It carries **six origins across nine call sites**.
3. **"1s poll interval" for the stall detector.** The 52.5% stall is on a feed the app polls at
   **3s**; the trace was at **250ms**; 1s belongs to the *processing* feed, which the stall detector
   is not guarding.

**Plus four stale pointers found in-repo** (none of them in `14-CONTEXT.md`, which was accurate
throughout):

- `wallet_overview.dart:54` cites `dashboard_screen.dart:198-201, :270-273`; now **:211-213,
  :292-294**.
- `test/boot_sequence_test.dart:11` quotes a 187-test baseline; it is now **516**.
- `test/boot_sequence_test.dart:11-13` names `test/local_wallet_storage_test.dart` as the standing
  failure; that file is **gone** and a different test fails.
- `ROADMAP.md:671` still cites `sgnus_connection_widget.dart:85`; it is **:89** (076 already caught
  this one).

**Research date:** 2026-07-29
**Valid until:** 2026-08-05 (7 days). This is a fast-moving tree - 298 files were rewritten in one
recent pass, and four stale pointers were found in documents written within the last week. **Re-run
`flutter test` and re-check every `file:line` above before executing.**
