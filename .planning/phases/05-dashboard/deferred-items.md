# Deferred Items — Phase 05 Dashboard

Pre-existing issues discovered during plan execution that are out of scope for the
current task (SCOPE BOUNDARY rule — only auto-fix issues directly caused by the
current task's changes).

## 05-04: `tool/verify_additive_boundary.sh` Check 2 — duplicate class `_Section`

- **Found during:** 05-04 Task 1 verification (`bash tool/verify_additive_boundary.sh`)
- **Symptom:** Check 2 (duplicate public class name census) fails: `_Section` is a
  duplicate private class name not in `tool/shadow-baseline.txt`.
- **Location:** `lib/dev/dev_tools_bubble.dart` and `lib/dev/design_gallery_screen.dart`
  both declare a `_Section` class.
- **Root cause:** introduced by unrelated prior work — quick-task commits
  `c29fa0d` ("sectionize dev-tools bubble into 4 collapsible sections"),
  `ddd9978`, and `2c1527f` (2026-07-20, dev-tools bubble branded-button work).
  Neither file is touched by 05-04 (or any 05-* dashboard re-skin plan) — this
  is dev-only tooling, not part of the markets surface.
- **Not fixed here:** out of scope for 05-04's markets_screen.dart /
  markets_search_bar.dart / dashboard_markets.dart re-skin. Checks 1 (shadow
  import boundary) and 3 (WIRE- tripwire) — the checks relevant to this
  plan's scope — both PASS.
- **Suggested resolution:** rename one of the two `_Section` classes (both are
  private, so no external API impact) or add the pair to
  `tool/shadow-baseline.txt` with a written justification, in a future
  dev-tooling cleanup plan.
