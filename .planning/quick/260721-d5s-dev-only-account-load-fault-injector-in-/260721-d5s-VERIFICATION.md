---
phase: quick-260721-d5s
verified: 2026-07-21T00:00:00Z
status: gaps_found
score: 6/9 must-haves verified
behavior_unverified: 2 # present + wired; end-to-end UI runtime confirmation is the outstanding, by-design 05-07 Task 2 walk
overrides_applied: 0
re_verification: null
gaps:
  - truth: "05-07 Task 2's walk recipe no longer instructs a hand-edit of lib/bloc/app_bloc.dart, and its harness-leak gate no longer polices a harness that no longer exists — tooling and instructions agree."
    status: partial
    reason: >
      Part A steps 1-6, the <files>/<action> blocks, the <verify><automated> harness-leak gate, and
      <done> were all correctly rewritten to remove every hand-edit instruction and point at the bubble
      button — confirmed by direct reading. However the <resume-signal> block (05-07-PLAN.md:329-332),
      which was NOT in the d5s plan's explicit edit list for Task 3, was missed in the sweep and still
      reads "Type \"approved\" once Part A step 4 has been observed in BOTH appearance modes and the
      harness edit is reverted, or describe what happened instead." This is the last thing a walker
      reads before typing "approved" and it references a harness edit that the rest of the document
      (lines 266, 311, 365) now correctly says does not exist. Tooling and instructions do not fully
      agree — one stale instruction survived the rewrite.
    artifacts:
      - path: ".planning/phases/05-dashboard/05-07-PLAN.md"
        issue: "Line 331: <resume-signal> still says 'the harness edit is reverted'; contradicts Part A step 6 and <done>, both of which correctly say there is nothing to revert."
    missing:
      - "Update 05-07-PLAN.md's Task 2 <resume-signal> block to drop the 'harness edit is reverted' clause — e.g. 'Type \"approved\" once Part A step 4 has been observed in BOTH appearance modes, or describe what happened instead.'"
behavior_unverified_items:
  - truth: "Pressing MOCK -> 'Fail acct' drives AppBloc into its real error branch and DashboardScreen's error branch actually renders on screen."
    test: "Run with --dart-define=GW_DEV_TOOLS=true, land on dashboard, open bubble, expand MOCK, press 'Fail acct'."
    expected: "Dashboard shows 'Something went wrong!' with a gradient-filled Retry button + refresh icon, appearing immediately after the press."
    why_human: "Code reading proves the wiring is unbroken (arm -> add(FetchAccount()) -> gated throw -> catch emits AppStatus.error -> DashboardScreen checks accountStatus == AppStatus.error and renders Retry) but only running the app proves the widget tree actually paints the error branch."
  - truth: "The fault is one-shot: after 'Fail acct' consumes the arm, the dashboard's own Retry press reaches api.getAccount() for real and the app genuinely recovers (the criterion-3 proof)."
    test: "After observing the error branch, press Retry."
    expected: "Screen flips to LoadingScreen, then the full dashboard renders (balances, Assets, chart, Markets, Transactions)."
    why_human: "consumeAccountLoadFailure()'s decrement-once logic is deterministic and was confirmed correct by code reading (a second call with no re-arm returns false, unconditionally), but the end-to-end claim ('the app genuinely recovers') is a UI-rendered state transition that only the app running can confirm. This is 05-07 Task 2's own blocking human-verify checkpoint and is explicitly out of scope for this quick task per its own <verification> item 4 ('the walker performs this after the task commits, not here')."
human_verification:
  - test: "Run with --dart-define=GW_DEV_TOOLS=true, land on dashboard, open bubble, expand MOCK, press 'Fail acct'."
    expected: "Dashboard shows 'Something went wrong!' with a gradient-filled Retry button + refresh icon."
    why_human: "Runtime UI render — grep/code-reading cannot observe a paint."
  - test: "Press Retry after the error branch is showing."
    expected: "LoadingScreen, then full dashboard recovers — proves Retry works and the fault auto-cleared."
    why_human: "End-to-end state transition; this is 05-07 Task 2's own outstanding walk, deliberately unblocked (not performed) by this quick task."
---

# Quick Task 260721-d5s: Dev-Only Account-Load Fault Injector Verification Report

**Task Goal:** A dev-only, one-shot account-load fault injector reachable from the dev-tools bubble, so
plan 05-07's Task 2 walk (proving the new dashboard Retry actually recovers the app) is repeatable
without hand-editing source — and with zero possibility of reaching a release build.

**Verified:** 2026-07-21
**Status:** gaps_found
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Pressing 'Fail acct' drives `_onFetchAccount` through its real `try`/`throw`/`catch(_)` path to `accountStatus: AppStatus.error`, and the dashboard's real error branch renders — nothing simulated at the render layer | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | Wiring confirmed by code reading end-to-end: `dev_tools_bubble.dart:308-321` arms then dispatches `FetchAccount()`; `app_bloc.dart:168-201` `_onFetchAccount` gate throws inside the existing `try`, existing `catch (_)` (unchanged, `:199`) emits `accountStatus: AppStatus.error`; `dashboard_screen.dart:69-79` renders Retry when `state.accountStatus == AppStatus.error`. Actual on-screen paint is the outstanding 05-07 Task 2 walk (by design, not performed here). |
| 2 | The armed fault is ONE-SHOT and auto-clears; the very next `FetchAccount()` (the dashboard's own Retry) reaches `api.getAccount()` normally and the app genuinely recovers | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `dev_fault_injector.dart:29-33` `consumeAccountLoadFailure()`: returns `false` unconditionally when `_pendingAccountLoadFailures <= 0`; decrements-and-returns-`true` exactly once per arm otherwise. Deterministic by inspection — a second call with no re-arm cannot return `true` twice. Full runtime "app genuinely recovers" claim is the 05-07 Task 2 walk, explicitly out of scope here per the task's own `<verification>` item 4. |
| 3 | Arming SETS the pending-failure count to 1; it never increments — five presses cannot queue five failures | ✓ VERIFIED | `dev_fault_injector.dart:21-23`: `void armAccountLoadFailure() { _pendingAccountLoadFailures = 1; }` — a plain assignment, no `+=`/`++`. Confirmed by `grep -vE '^\s*//' lib/dev/dev_fault_injector.dart \| grep -cE '\+= 1\|\+\+'` → `0`. |
| 4 | In a release build (or any debug build without `GW_DEV_TOOLS`), `_onFetchAccount` behaves exactly as at HEAD — the gate leads with two compile-time `const bool`s before the injector call | ✓ VERIFIED | `app_bloc.dart:186-196`: `if (kDebugMode && kShowDevTools && DevFaultInjector.instance.consumeAccountLoadFailure())`, in that exact order. `kDebugMode` (`dart:core`) and `kShowDevTools` (`dev_flags.dart:15`, `const bool.fromEnvironment('GW_DEV_TOOLS')`) are both compile-time consts; Dart constant-folds the chain to `false` in a release build, eliminating the branch (language-level guarantee, not a runtime claim). |
| 5 | `app_bloc.dart`'s diff is a PURE INSERTION — zero deleted lines | ✓ VERIFIED | `git diff --numstat 1360350^ 1360350 -- lib/bloc/app_bloc.dart` → `30  0` (30 insertions, 0 deletions). Full diff inspected line-by-line: only new imports and one new `if`/`throw` block were added; every existing `emit`, the `catch (_)`, and the handler registration at `:50` are untouched. |
| 6 | The walker is never guessing at the semantics: button label, tooltip, and toast all state the fault is one-shot and self-clearing | ✓ VERIFIED | `dev_tools_bubble.dart:308-321`: label `'Fail acct'`; `tooltip:` reads "Arms a ONE-SHOT account-load failure and re-fetches now; the fault clears itself when consumed..."; toast title "Account-load failure armed", message "One-shot: already spent by the fetch just dispatched...". `grep -ci 'one-shot' lib/dev/dev_tools_bubble.dart` → `2`. |
| 7 | `lib/dev/dev_fault_injector.dart` depends on nothing — no Flutter, no app, no package imports | ✓ VERIFIED | `grep -cE '^import ' lib/dev/dev_fault_injector.dart` → `0`. File contents read in full: zero import statements. |
| 8 | No raw values introduced anywhere; new button goes through `_devButton`; injector file declares no colors/spacing/type | ✓ VERIFIED | `git diff a122530^ a122530 -- lib/dev/dev_tools_bubble.dart \| grep '^+' \| grep -E 'Colors\.\|Color\(0x\|TextStyle\(\|EdgeInsets\.\|height: [0-9]\|width: [0-9]\|fontSize: [0-9]'` → no matches. `dev_fault_injector.dart` contains only integer state and doc comments — no UI types at all. |
| 9 | 05-07 Task 2's walk recipe no longer instructs a hand-edit of `app_bloc.dart`, and its harness-leak gate no longer polices a harness that no longer exists — tooling and instructions agree | ✗ FAILED (partial) | Part A steps 1-6, `<files>`, `<action>`, `<done>`, and the harness-leak gate (`git status --porcelain lib/` → EMPTY, confirmed to actually be empty at HEAD) were all correctly rewritten — verified by direct reading of `05-07-PLAN.md:260-369`. **But** the `<resume-signal>` block (`:329-332`), not in d5s's explicit Task 3 edit list, still says "...and the harness edit is reverted", contradicting the surrounding, correctly-updated text. See Gaps Summary. |

**Score:** 6/9 truths verified, 2 present-behavior-unverified (by design — deferred to the 05-07 Task 2 walk), 1 failed (partial).

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/dev/dev_fault_injector.dart` | Dependency-free singleton in the `DevMockHoldings`/`DevMockTransactions` shape, exposing `armAccountLoadFailure()`/`consumeAccountLoadFailure()`/`disarm()` | ✓ VERIFIED | File exists, read in full (39 lines). Private named ctor `DevFaultInjector._()` + `static final DevFaultInjector instance = DevFaultInjector._()`; all three members present with the exact semantics the plan specifies; zero imports; `ponytail:` comment present. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| Bubble 'Fail acct' | `DevFaultInjector.armAccountLoadFailure()` | direct call, first line of handler | WIRED | `dev_tools_bubble.dart:310` |
| Arm | `context.read<AppBloc>().add(FetchAccount())` | dispatched immediately after arming, before the toast | WIRED | `dev_tools_bubble.dart:311`, arm precedes dispatch (order confirmed by reading, not just presence) |
| `FetchAccount()` | `_onFetchAccount`'s gated throw → existing `catch (_)` → `accountStatus: AppStatus.error` | the new `if` inserted as first statement of the existing `try` | WIRED | `app_bloc.dart:186-201`; catch and emit are the pre-existing, unedited lines |
| `accountStatus: AppStatus.error` | `DashboardScreen` error branch + Retry button | `BlocBuilder` condition | WIRED | `dashboard_screen.dart:69-79` (shipped by 05-07 Task 1, `64fa92d`, out of this task's scope but confirmed still present/unedited) |
| `kDebugMode && kShowDevTools` | short-circuit before `DevFaultInjector` is touched | `&&` chain ordering | WIRED | `app_bloc.dart:186-188` — both consts precede the impure consume call in the same chain |
| Bubble 'Clear' | `DevFaultInjector.disarm()` | added alongside the pre-existing clear calls | WIRED | `dev_tools_bubble.dart:328-336`, `disarm()` at `:330`, inside the `'Clear'` handler (confirmed not inside 'Fail acct') |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Injector has zero imports | `grep -cE '^import ' lib/dev/dev_fault_injector.dart` | `0` | ✓ PASS |
| Arm never increments | `grep -vE '^\s*//' lib/dev/dev_fault_injector.dart \| grep -cE '\+= 1\|\+\+'` | `0` | ✓ PASS |
| `app_bloc.dart` gate ordering (comments filtered) | `grep -vE '^\s*//' lib/bloc/app_bloc.dart \| grep -c 'kDebugMode &&'` / `'kShowDevTools &&'` / `'consumeAccountLoadFailure()'` | `1` / `1` / `1` | ✓ PASS |
| `app_bloc.dart` pure insertion | `git diff --numstat 1360350^ 1360350 -- lib/bloc/app_bloc.dart` | `30  0` | ✓ PASS |
| `subscribeToWalletStatus` untouched (no second fault leg smuggled in) | `grep -vE '^\s*//' lib/bloc/app_bloc.dart \| grep -c 'subscribeToWalletStatus'` | `3` | ✓ PASS |
| `dev_tools_bubble.dart` button count / label | `grep -c "_devButton(" lib/dev/dev_tools_bubble.dart` → `18`; `grep -c "'Fail acct'"` → `1` | `18`, `1` | ✓ PASS |
| `dev_tools_bubble.dart` pure(ish) insertion | `git diff --numstat a122530^ a122530 -- lib/dev/dev_tools_bubble.dart` | `24  0` | ✓ PASS |
| No raw values added (bubble diff) | `git diff a122530^ a122530 -- lib/dev/dev_tools_bubble.dart \| grep '^+' \| grep -E 'Colors\.\|Color\(0x\|TextStyle\(\|EdgeInsets\.\|height: [0-9]\|width: [0-9]\|fontSize: [0-9]'` | no matches | ✓ PASS |
| Harness-leak gate as rewritten | `git status --porcelain lib/` | empty | ✓ PASS |
| No debt markers (`TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER`) in the 3 touched source files | `grep -n -iE "TBD\|FIXME\|XXX\|TODO\|HACK\|PLACEHOLDER"` on all 3 files | none | ✓ PASS |
| `flutter analyze lib` clean against the 3 touched files, total count matches SUMMARY's claimed 61 | ran live: `flutter.bat analyze lib` | `61 issues found`; none reference `dev_fault_injector.dart`, `app_bloc.dart`, or `dev_tools_bubble.dart` | ✓ PASS |

`flutter test` not run — does not compile on this branch (standing constraint, confirmed pre-existing per STATE.md/AGENTS.md; not treated as a gap per task instructions).

### Requirements Coverage

PLAN frontmatter declares `requirements: []`. No REQUIREMENTS.md entries to cross-reference.

### Anti-Patterns Found

None. All three touched/created source files (`lib/dev/dev_fault_injector.dart`, `lib/bloc/app_bloc.dart`, `lib/dev/dev_tools_bubble.dart`) scanned clean for `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER`, empty-return stubs, and hardcoded-empty-data patterns.

### Human Verification Required

### 1. Dashboard error branch actually renders on 'Fail acct' press

**Test:** Run with `--dart-define=GW_DEV_TOOLS=true`, land on the dashboard, open the dev-tools
bubble, expand MOCK, press **'Fail acct'**.
**Expected:** The dashboard shows "Something went wrong!" with a gradient-filled Retry button and
refresh icon, appearing immediately after the press.
**Why human:** Code reading proves the wiring is unbroken end-to-end (arm → dispatch → gated throw →
existing catch → `accountStatus: AppStatus.error` → `BlocBuilder` error branch), but only running the
app proves the widget tree actually paints it.

### 2. Retry genuinely recovers the app (the criterion-3 proof)

**Test:** After observing the error branch, press Retry.
**Expected:** Screen flips to `LoadingScreen`, then the full dashboard renders (balances, Assets,
chart, Markets, Transactions).
**Why human:** `consumeAccountLoadFailure()`'s one-shot logic is deterministic and confirmed correct by
code reading, but the end-to-end "app genuinely recovers" claim is a UI state transition. This is
05-07 Task 2's own blocking human-verify checkpoint. It is deliberately **not performed** by this quick
task — this quick task only makes the walk repeatable. Its absence here is by design, not a gap in this
quick task's scope.

### Gaps Summary

One concrete, code-verifiable defect was found, isolated to a single line of documentation:

**`05-07-PLAN.md` Task 2's `<resume-signal>` block was not swept during the Task 3 rewrite and still
references reverting a harness that no longer exists.** Everything else in the recipe — the `<files>`
line, `<action>`, all six numbered Part A steps, the rewritten harness-leak gate, and `<done>` — was
correctly and consistently updated to remove every hand-edit instruction and point at the bubble
button. The lone surviving stale line is `:331`: "Type \"approved\" once Part A step 4 has been
observed in BOTH appearance modes **and the harness edit is reverted**, or describe what happened
instead." This directly contradicts Part A step 6 (`:311`, "There is nothing to revert...") and
`<done>` (`:365`, "...there is nothing to revert..."), both of which are correct.

This is not a release-safety or one-shot-semantics defect — both of those load-bearing properties are
solid, confirmed by direct code reading and a live `git diff --numstat`/`flutter analyze` run. It is a
one-line instruction-drift bug in a document this quick task's own success criteria explicitly commit
to keeping internally consistent ("tooling and instructions agree"). Given the task's stated design
philosophy — "the walker is never guessing at the semantics" — a walker reading the resume-signal
immediately before typing "approved" would be told to confirm something that isn't true.

**Fix:** one-line edit to `.planning/phases/05-dashboard/05-07-PLAN.md:329-332`, dropping the "and the
harness edit is reverted" clause. No source code changes required.

Separately (not a gap, recorded per task instruction): the two behavior-dependent truths — the error
branch actually rendering on screen, and Retry actually recovering the app — are present and correctly
wired by every check code-reading can perform, but their full runtime confirmation is the 05-07 Task 2
human walk, which remains outstanding by design. This quick task's job was to make that walk possible
without a source edit, not to perform it.

---

_Verified: 2026-07-21_
_Verifier: Claude (gsd-verifier)_
