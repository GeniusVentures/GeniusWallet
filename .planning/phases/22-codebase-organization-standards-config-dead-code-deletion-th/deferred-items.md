# Phase 22 — Deferred Items

Out-of-scope discoveries surfaced while executing this phase's plans. Logged per the executor's
Scope Boundary rule: pre-existing issues not directly caused by the current task's changes are
recorded here, not auto-fixed.

## From 22-03 (rename `*.g.dart` widgets, move the shadow guard)

While re-proving `tool/verify_additive_boundary.sh` after the rename, two of its three checks
failed for reasons unrelated to this plan's changes:

### Check 2 — 6 new "duplicate public class name" false positives

`_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`,
`_TimeframeTabState` are all private (leading-underscore) classes declared in more than one file:

- `_Section`: `lib/dev/design_gallery_screen.dart:953`, `lib/dev/dev_tools_bubble.dart:882`
- `_SplashState`: `lib/components/splash.dart:36`, `lib/screens/splash.dart:78`
- `_TimeframeSegment` / `_TimeframeSegmentState` / `_TimeframeTab` / `_TimeframeTabState`:
  `lib/dashboard/chart/markets_hero_card.dart`, `lib/dashboard/home/view/dashboard_screen.dart`

Dart's privacy is library-scoped (per-file for these purposes) — a private class in one file is
structurally impossible to import or substitute from another file, unlike the public-class
shadow hazard `tool/shadow-baseline.txt`'s Check 2 exists to catch. These are false positives
inherent to Check 2's census regex (`^(abstract )?class ...`), which does not exclude
underscore-prefixed (library-private) names.

`markets_hero_card.dart` traces to Phase 16 (`aa78eec feat(markets): Phase 16 — native-token
hero...`); `design_gallery_screen.dart` / `dev_tools_bubble.dart` and `splash.dart` predate
Phase 22 as well. None of this is caused by 22-03's rename. Not fixed here — baselining requires
a written, reviewed justification per the file's own header rule, and expanding
`tool/shadow-baseline.txt` beyond the WalletsOverview row is outside 22-03's stated charge.

**Recommendation:** a future plan (in this phase or Phase 23) should either (a) baseline all 6
with the private-class rationale above, or (b) fix Check 2's census regex to exclude
`_`-prefixed class names at the source, which would eliminate this whole class of false positive
permanently instead of accreting baseline entries for each new private name collision.

### Check 3 — 1 pre-existing "WIRE-" marker false positive

`lib/components/overlay/global_swap_fab_host.dart:21` contains the prose `"...WIRE-02 keeps the
AI FAB out of this milestone..."` — a reference to an internal work-item ID, not one of Alex's
Parabeac `WIRE-N` placeholder demo tags this check was built to catch (see MEMORY.md: "take
Alex's visual never his WIRE-N demos"). Traces to `43ff62e feat(08-02): port GlobalSwapFabHost
from 7a63b4f, AI-FAB half stripped` — Phase 8, unrelated to Phase 22.

Not fixed here: Check 3 has no allowlist mechanism (unlike Check 2's baseline file), so making it
pass would require either editing the check's logic (weakens a "cheap tripwire" without review)
or rewording an unrelated file's comment (out of 22-03's file scope). Left failing and documented.

**Net effect on `tool/verify_additive_boundary.sh`:** the script's overall exit code is 1 due to
these two pre-existing, unrelated findings. Check 1 (the actual shadow-import-boundary logic this
phase's threat model cares about — Loading, Splash, WalletsOverview) passes cleanly, including a
Loading-baseline drift from 22-01's dead-code deletion that 22-03 also corrected in-scope (see
22-03-SUMMARY.md). WalletsOverview specifically was proven to still enforce by injecting and then
reverting a probe second-importer file.
