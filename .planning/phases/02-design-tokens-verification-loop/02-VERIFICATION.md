# Phase 2 Verification Record (BLD-02)

This document is the BLD-02 deliverable itself, not a formality: the verification loop it
establishes here is the one every later phase inherits. It exists because the forward-port
reached **0 `flutter analyze` errors and still dropped 37 develop behaviors, 3 of them blockers**
(see `.planning/REVIEW_FINDINGS_REDESIGN.md`). Recording an unearned PASS in this document would
recreate exactly that failure mode — see threat T-02-18. Every row below carries a real observation
or is marked OUTSTANDING/DEFERRED with the reason; a criterion with no observation behind it is
FAIL, not PASS, by this phase's own rule.

## Standing run recipe

This is the standing command for the rest of the milestone (UI-SPEC §7):

```
CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug
```

Append `--dart-define=GW_DEV_TOOLS=true` to enable dev tools (the `Dev` row and its `Tokens`
button).

`CMAKE_BUILD_TYPE=Release` is **deliberate and correct**, not a bug to fix: the multi-config Visual
Studio generator takes the actual build configuration from `--config` (which `flutter run -d
windows --debug` supplies), while the CMake dependency downloader keys its cache path off
`CMAKE_BUILD_TYPE`. Setting it to anything else re-triggers a full dependency re-download.

Cold build: several minutes. Hot reload (`r`): ~1s.

**`flutter analyze` is a gate, never evidence.** It must report 0 new errors before any task in
this phase is considered done, but an analyze-clean state proves nothing about runtime behavior —
that is exactly what masked the forward-port's 37 regressions. Every PASS below is backed by a
human running the app and observing it, not by a clean analyzer run.

There is **no working test harness** (`flutter test` does not compile — APP-02). No tests were
written or run for this phase.

## Standing environment facts (for every later phase)

1. **The reference Release exe and the develop build cannot run simultaneously.** Both read/write
   the same Hive data directory; running both at once deadlocks on file locks. Close
   `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` before starting/reloading
   the develop build, and vice versa.
2. **Hot reload (`r`) applies Dart edits in ~1s; a cold build takes several minutes.** Prefer
   reload for anything that doesn't add a new native dependency or change `pubspec.yaml`; fall back
   to hot restart (`R`) if reload produces any analyzer/incremental-compile error, and to a full
   stop/re-run only for pubspec or native-dependency changes.

---

## Criterion 1 — Hot reload + debugger

> "A Windows debug build launches from `ui-redesign-port`, hot reload applies a token edit without
> a restart, and the Dart debugger attaches and hits a breakpoint."

**What was run:** Nothing yet against this exact check. The probe surface this check partly relies
on (`TokenProbeScreen.build()`, the natural breakpoint target) did not exist until this plan's
Task 1 — it exists now (commit `758aa03`), and its route/entry point landed in Task 2 (commit
`a27f663`).

**What was observed:** No agent-side observation is possible — hitting a breakpoint and confirming
a hot-reloaded edit requires an interactive Dart debugger session and a human watching the running
Windows GUI, neither of which this agent has access to.

**Status: OUTSTANDING.**

**What to do:** With the app running (reload picks up this plan's changes — see "Reload guidance"
below):
1. Edit `GeniusWalletMotion.base`'s duration in `lib/theme/genius_wallet_motion.dart`, save, press
   `r` in the terminal (or the IDE's hot-reload button). Confirm the change applies without a full
   restart. Revert the edit afterward.
2. Set a breakpoint in `TokenProbeScreen.build()` (`lib/dev/token_probe_screen.dart`). Open the
   probe (`Dev` row → `Tokens`, dev-tools build only). Confirm the Dart debugger attaches and stops
   at the breakpoint.

---

## Criterion 2 — No-visual-change walk

> "Every existing screen renders exactly as it did before the token layer landed — walking the app
> top to bottom shows no visual change and no startup exception (tokens coexist; nothing is skinned
> yet)."

**What was run and observed (human-confirmed, prior plans in this phase):**

| After | What the human did | Result |
|-------|--------------------|--------|
| 02-01 + 02-02 | Restarted the app (pubspec change: `google_fonts`, dev-tools gating). Reached the dashboard with no startup exception; confirmed the new `preferences` Hive box opens cleanly; confirmed the `Dev` header row is **absent** in a default build. | "ALL GOOD" |
| 02-03 (the crux — the 3 colliding theme files) | Hot-reloaded and walked the app, specifically the swap settings drawer and the Banxa buy screen (the two live `greenBlueGreenGradient` call sites), the header height, and text-field labels. | "all good" — nothing changed |
| 02-04 (the 6 additive theme files, incl. dormant `GWCanvasBackground`) | Hot-reloaded and confirmed nothing changed and no missing-asset placeholder appeared anywhere. | "nothing changes, all good" |

These three walks together cover every file this phase's token vocabulary touches or adds:
`genius_wallet_colors.dart`, `genius_wallet_consts.dart`, `genius_wallet_gradient.dart` (02-03, the
only files with any pre-existing symbol at stake), and the six wholly-new files from 02-04.

**What this plan (02-05) additionally changed, and why it doesn't reopen the question:**
`lib/navigation/router.dart` gained one appended `GoRoute` (`git diff` for the route: 7 insertions,
**0 deletions** — see the mechanical proof below) and `lib/test/dev_tools_widget.dart` gained one
button inside the already dev-gated `DevToolsWidget`. Neither is reachable from a normal build:
the route is inert until something links to it, and the button lives behind
`kDebugMode && kShowDevTools`, the same gate 02-02 established. `lib/theme/theme.dart`,
`lib/main.dart` and `lib/components/overlay/responsive_overlay.dart` all show **zero diff** across
this entire phase (checked again after this plan's commits, see mechanical proof below).

**Mechanical proof (this agent, not a substitute for the human walk, but consistent with it):**
```
$ git diff --stat -- lib/components/overlay/responsive_overlay.dart lib/theme/theme.dart lib/main.dart
(empty output)

$ git diff 758aa03~1..a27f663 -- lib/navigation/router.dart
# +7 insertions (1 import line, 1 GoRoute block), 0 deletions
```

**Status: PASS**, on the strength of the three human-confirmed walks above, which cover the
phase's entire symbol-collision surface. The two files this plan itself touches are proven
additive/gated by mechanical diff, not by a fresh human walk — if you are doing the reload for
criteria 1/3 below anyway, a final quick glance at the dashboard confirms this for free, but it is
not being recorded as a separate blocking requirement given the diff is provably zero-deletion and
the new button is provably behind the existing gate.

---

## Criterion 3 — Token + appearance probe

> "The new token set resolves at runtime and flips correctly with light/dark appearance,
> demonstrable on a probe surface without touching an un-ported screen."

**What was run:** `TokenProbeScreen` was built this plan (Task 1, commit `758aa03`) and wired to
`/dev/token-probe` behind the `Tokens` button in `DevToolsWidget` (Task 2, commit `a27f663`). It
has not yet been opened in a running app by a human.

**What was observed:** Nothing yet — this is new surface area created by this very plan; per this
phase's own rule, it cannot be marked PASS on the strength of code review alone (that is the
analyze-clean trap this document exists to avoid).

**Status: OUTSTANDING.**

**What to do:** Run the standing recipe **with** `--dart-define=GW_DEV_TOOLS=true`. In the `Dev`
row, press `Tokens`. Confirm:
- `/dev/token-probe` opens and renders a heading, body text, a card with a visibly rounded corner
  and hairline border, and a button filled with the green→blue horizontal CTA gradient with dark
  (not white) label text.
- Pressing the appearance toggle flips the whole probe live, no restart: background from
  near-black `#0B0D12` to light gray `#DCE0E6`, card from near-black to white, text from white to
  dark ink, hairline border flipping polarity. Press again, confirms it flips back.
- Navigating out and back into the probe reopens it in the mode you left it in (proves
  `GWAppearance.instance.load()` and the `preferences` Hive box round-trip).

---

## Criterion 4 — Dev-gating

> "In a normal build the `Dev` header row and the onboarding `Mock` button are absent; with the
> opt-in dev flag on, both appear and `Mock` still injects its fake wallet + 20 fake transactions."

**What was run and observed:**

| Sub-check | Status | Evidence |
|-----------|--------|----------|
| `Dev` row absent, no define | **Observed, confirmed.** | Human-confirmed after 02-01+02-02: "ALL GOOD" — the row was absent in a default build. |
| `Dev` row (+ now `Tokens` button) present, `--dart-define=GW_DEV_TOOLS=true` | **Not re-observed on this branch.** | Verified only by mechanism/code review: `lib/dev/dev_flags.dart`'s `kShowDevTools` gates `responsive_overlay.dart:97` (`if (kDebugMode && kShowDevTools) const DevToolsWidget()`), and `DevToolsWidget`'s new `Tokens` button (this plan) is inside that same widget, inheriting the gate for free — no second flag, no second call site (confirmed by grep gate: `kShowDevTools|kDebugMode` count in `dev_tools_widget.dart` is 0). This has not been re-run and watched by the human on `ui-redesign-port` since the branch diverged; do not treat as observed. |
| Onboarding `Mock` button absent/present | **Deferred, not PASS.** | Does not exist on develop today. It is redesign-only and lands in Phase 6, which ports `wallet_creation_screen.dart` and `lib/dev/mock_mode.dart` together and carries `kShowDevTools` forward (UI-SPEC §8, ROADMAP Phase 6). Recording this as out of scope, not verified. |

**Status: PARTIAL / OUTSTANDING.** The "absent by default" half is genuinely observed. The
"present with the flag" half — now including this plan's `Tokens` button — needs one more human
run with the define set (the same run that closes criterion 3, above, already exercises this).
The `Mock` button clause is explicitly deferred to Phase 6 and must not be counted toward this
phase's closure.

**What to do:** As part of the criterion-3 run above (dev-tools build), confirm the `Dev` row is
present and the `Tokens` button sits alongside the three existing test buttons. Then stop the app
and re-run the standing recipe with **no** define; confirm the `Dev` row and `Tokens` button are
both absent and `/dev/token-probe` is reachable from nowhere in the UI.

---

## Criterion 5 — `floatingLabelBehavior` (finding 36)

> "Form-field labels stay pinned above the field on every existing TextField (finding 36 —
> `floatingLabelBehavior: always` survives the theme rewrite)."

**What was run and observed:** Human-confirmed as part of the 02-03 walk: "specifically including
... text-field labels ... confirmed NOTHING changed." This holds structurally because
`lib/theme/theme.dart` — the single file that sets `floatingLabelBehavior: FloatingLabelBehavior
.always` — has zero diff for the entire phase (confirmed by `git diff --numstat -- lib/theme/theme
.dart` returning empty output after every plan in this phase, including this one).

**Status: PASS.**

---

## Summary

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Hot reload + debugger | OUTSTANDING — needs human run (probe now exists to anchor the breakpoint check) |
| 2 | No-visual-change walk | PASS — 3 human-confirmed walks across the whole token vocabulary; this plan's own additions proven zero-deletion/gated by mechanical diff |
| 3 | Token + appearance probe | OUTSTANDING — probe built this plan, not yet opened/flipped by a human |
| 4 | Dev-gating | PARTIAL — absent-by-default observed; present-with-flag not yet re-observed on this branch; onboarding `Mock` button explicitly deferred to Phase 6 |
| 5 | `floatingLabelBehavior` (finding 36) | PASS — human-confirmed in the 02-03 walk, backed by `theme.dart`'s zero diff |

**BLD-02** is established as a repeatable loop by this document, not claimed as a one-time pass —
criteria 1 and 3 are new surface this same plan created and genuinely cannot be observed by an
agent; they are handed to the human explicitly rather than inferred from a clean `flutter analyze`.

**DS-01** closes on the mechanical side: the full token vocabulary (colors, spacing, radius,
typography, elevation, gradients, motion, decorations, copy) exists on `develop`, compiles, and is
proven — via 0-deletion diffs plus the three human walks above — not to have repointed a single
symbol any un-ported screen depends on. The remaining human-observation gaps (criteria 1, 3, and
half of 4) are about the *new* probe surface this plan adds, not about any risk to existing
screens.

## Reload guidance for the outstanding items

Your running debug session should pick up this plan's changes with **hot reload (`r`)** — both
edits (`router.dart`'s appended route, `dev_tools_widget.dart`'s appended button) are additive
Dart changes with no new imports beyond `go_router` (already a dependency) and no pubspec change.
If `r` produces any analyzer/incremental-compile error, fall back to `R` (hot restart). To exercise
the `--dart-define=GW_DEV_TOOLS=true` path you need a fresh `flutter run` with the define set —
hot reload cannot add a `dart-define` to an already-running process.

Order of operations for the fastest single pass through all three outstanding items:
1. Close the reference Release exe (shared Hive lock).
2. Run the standing recipe **with** `--dart-define=GW_DEV_TOOLS=true`.
3. Confirm `Dev` row + `Tokens` button present (closes criterion 4's second half).
4. Press `Tokens`, do the appearance-flip + reachability walk (closes criterion 3).
5. Edit `GeniusWalletMotion.base`, hot-reload, revert; set a breakpoint in
   `TokenProbeScreen.build()`, re-open the probe, confirm the debugger hits it (closes criterion 1).
6. Stop, re-run with no define, confirm `Dev` row/`Tokens` absent (re-confirms criterion 4's first
   half and criterion 2 for this plan's own additions).

---
*Phase: 02-design-tokens-verification-loop*
*Plan: 02-05*
