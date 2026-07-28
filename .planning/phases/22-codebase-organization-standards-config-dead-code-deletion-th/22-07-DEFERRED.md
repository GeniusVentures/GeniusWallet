# 22-07 — DEFERRED (not executed)

**Decision date:** 2026-07-28
**Decided by:** Braian, at the plan's own blocking-human package-legitimacy gate.
**Decision:** Skip the golden baseline entirely for now. Do not install `alchemist`, and do not
build the no-dependency `matchesGoldenFile` fallback either.

`22-07-PLAN.md` remains in the phase directory unexecuted. It is not deleted — if the decision is
revisited, it can be run as-is.

## What was skipped

An Alchemist golden baseline over ~17 design-system primitives, captured in **both** light and dark
mode. Its purpose was to be the visual-regression safety net for the design-system work that
follows.

## Consequence — this is the part that matters

**Phase 23's plans were written assuming this baseline exists.** They reference goldens **104 times**
across all seven plans:

| Plan | Golden references | What it relied on them for |
|------|------------------|----------------------------|
| 23-01 | 12 | proving the parity layer is a true zero-diff no-op |
| 23-02 | 10 | "goldens byte-identical each time" after each directory's codemod pass |
| 23-03 | 24 | it is designated **the only plan permitted to move a golden**, and only with a measured WCAG ratio per change |
| 23-04 | 8 | proving primitive demotion changed no rendering |
| 23-05 | 27 | verifying `GWHoverable` / `GWChangePill` / `GWTimeframeSegment` extraction is visually identical |
| 23-06 | 18 | verifying `GWCopyRow` / `GWAppBar` extraction |
| 23-07 | 5 | the `GWScreen` per-site adjudication |

**Those verification steps are now void.** Phase 23 cannot execute as written without either
(a) reinstating a golden baseline, or (b) being re-planned with a different verification mechanism.

This is not a small gap. The research behind Phase 23 identified goldens as the mechanism that
catches spacing, alignment and theme drift that assertion-based widget tests **cannot see** — which
is precisely the failure mode of a 288-call-site colour migration and a component-extraction pass.

## What still protects Phase 23 without goldens

- `flutter test` — 512 tests, but assertion-based: they check derived strings, CTA state ladders and
  style tokens, not rendered pixels.
- `flutter analyze` at 0 with CI enforcing.
- Live human walks in light **and** dark mode, which several Phase 23 plans already mandate.

That is meaningfully weaker for visual work, and the human walk becomes load-bearing rather than
confirmatory.

## Before Phase 23 starts, pick one

1. **Reinstate the baseline** — run 22-07 as written (approve `alchemist`), or build the
   no-dependency fallback.
2. **Re-plan Phase 23** against human-walk verification, accepting that spacing/alignment drift can
   ship undetected, and tightening the walk checklists to compensate.
3. **Narrow Phase 23** to the changes that are provably safe without visual diffing — e.g. the parity
   layer (23-01, zero call sites changed) and the mode-breaking colour fixes (23-03, which are fixing
   *known-wrong* rendering rather than preserving correct rendering.)

Option 3 is the smallest honest scope if the golden decision stands.

## Effect on Phase 22

None to the phase's own exit criteria. 22-08 was repointed `depends_on: ["22-06"]` (wave 7 → 6) so
CI wiring is not blocked. Phase 22 still ends with analyzer 0 / exit 0, tests 512/0, brace rule
enforced at 0, and CI gates live — it simply ends without a golden baseline.
