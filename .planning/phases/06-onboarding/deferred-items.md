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
