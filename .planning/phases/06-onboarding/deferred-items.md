# Deferred Items — Phase 06 Onboarding

## 06-02: pre-existing `verify_additive_boundary.sh` Check 2 failure (out of scope)

**Found during:** Task 2 verify gate (`bash tool/verify_additive_boundary.sh`).

**Failure:** Check 2 (duplicate public class name census) reports `_Section` as a duplicate
name not in `tool/shadow-baseline.txt`, defined in both `lib/dev/design_gallery_screen.dart:953`
and `lib/dev/dev_tools_bubble.dart:726`.

**Confirmed pre-existing and unrelated:** reproduced identically with this plan's changes
stashed out (clean HEAD at commit `47527bc`, before Task 2's edits). Neither file is touched
by this plan (both are dev-only tooling, not onboarding). Per the executor's scope-boundary
rule, out-of-scope pre-existing failures are logged, not fixed, during this plan's execution.

**Not fixed here.** Recommend a follow-up quick task to either rename one `_Section` class or
add a written, reviewed baseline entry per the script's own guidance ("Do NOT add them to the
baseline without a written, reviewed justification").

## 06-06: `verify_additive_boundary.sh` Check 2 failure has GROWN — still out of scope

**Found during:** Task 1 verify block (`bash tool/verify_additive_boundary.sh`) at HEAD `8f001f6`.

**Failure:** Check 2 now reports FOUR duplicate names not in `tool/shadow-baseline.txt`:
`_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`. Checks 1 (shadow
import boundary) and 3 (WIRE- tripwire) still PASS.

**Confirmed out of scope for onboarding — none are onboarding files:**
- `_SplashState` — `lib/components/splash.dart` + `lib/screens/splash.dart`
- `_TimeframeSegment` / `_TimeframeSegmentState` — `lib/dashboard/chart/markets_hero_card.dart`
- `_Section` — `lib/dashboard/home/view/dashboard_screen.dart`, `lib/dev/design_gallery_screen.dart`,
  `lib/dev/dev_tools_bubble.dart` (the 06-02 finding above, unchanged)

The two new pairs entered from OTHER phases' work that landed on `ui-redesign-port` after the
phase-06 baseline `2e82ec2`: Phase 16 markets (`aa78eec`, `_TimeframeSegment[State]`) and the
Signal Edge boot sequence (`29b183b`, `_SplashState`). 06-06 Task 1 adds only a `tool/` script
and touches no `lib/` file, so it cannot have changed the `lib/` class census; the failure
reproduces independent of this task.

**Note on the plan's Task-1 verify block:** it chains `verify_additive_boundary.sh` with `&&`,
so the block as written cannot pass on this branch until these names are triaged. The block's
implicit assumption that `2e82ec2..HEAD` isolates phase-06 work does NOT hold on this branch —
Phases 12/15/16/17 and the boot sequence all sit in that range. The onboarding-scoped clauses of
the same verify block (the six-item seed-safety gate, the `Colors.`-outside-`routes/` grep, and
the zero-diff scope fence over the 8 bloc files + `backup_phrase_screen.dart`) all PASS.

**Not fixed here** — belongs to the markets/boot/dashboard phase owners (rename, or a reviewed
`shadow-baseline.txt` addition per the script's own guidance).
