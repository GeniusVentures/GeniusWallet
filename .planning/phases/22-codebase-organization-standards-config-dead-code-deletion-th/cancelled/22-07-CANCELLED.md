# 22-07 — CANCELLED (golden tests, permanently)

**Status:** CANCELLED, not deferred. **Do not execute `22-07-PLAN.md`** — it sits in this
`cancelled/` directory precisely so no executor picks it up.

**Decided:** 2026-07-28 by Braian, twice.
1. At 22-07's blocking-human package gate: declined both the `alchemist` install **and** the
   no-dependency `matchesGoldenFile` fallback.
2. On being asked again after a full explanation of what golden tests are and what they catch:
   *"lets not have golden stuff for now… no need to test it design diff wise."*

**Scope of the decision:** no golden tests, no snapshot tests, no pixel comparison, no visual
regression tooling of any kind. Also — stated in the same breath — **no replacement test
infrastructure right now**: *"wait we will not add now I just dont want the golden tests."*

Functional E2E is a **later** topic. Braian mentioned "playwright or the equivalent" as a someday
item. Note for whoever picks that up: Playwright is the wrong tool for Flutter — the app renders to
a single `<canvas>` (CanvasKit/Skia), so there are no DOM nodes to select. The Flutter-native
equivalents are **`integration_test`** (ships in the SDK) and **`patrol`** (adds native dialogs,
permissions, biometrics — relevant for a wallet).

## What this cost, and how it was resolved

Phase 23's original 7-plan cut was built around this baseline and referenced goldens **104 times**.
Rather than patch around that, **Phase 23 was fully re-planned** on 2026-07-28 without goldens. The
superseded plans are at `.planning/phases/23-.../superseded-golden-based/`.

The re-plan did not merely substitute a weaker proof. For most of the phase it found a stronger one:

| Workstream | What proves it now |
|---|---|
| Colour parity layer | **Value equality** — every token asserted identical old-path vs new-path in both modes. For "did the painted colour change", this is stronger than pixel comparison. |
| 288-site codemod | Parity holds by construction + access-path-only rewrite + analyzer 0 + 512 tests |
| Mode-breaking colour fixes | **Measured WCAG ratios** asserted in the existing `test/theme/theme_contrast_test.dart`. Goldens were never right here — these changes *deliberately* alter rendering. |
| Primitive demotion | **The compiler** — `part`/`part of` makes reachability a compile error |
| Component extraction | Narrowed hard (see below), and the one survivor preserves paint *by construction* |

## The real cost, stated plainly

**Nothing automated proves layout or spacing anywhere in Phase 23.** A 2px padding drift or a wrong
radius can ship undetected. The re-plan responded by cutting extraction work rather than pretending
otherwise — `GWChangePill` cut, `GWCopyRow` and `GWTimeframeSegment` refused, `GWAppBar` and the
whole `GWScreen` sweep deferred until a functional test net exists. Only `GWHoverable` survived,
because its paint is preserved by construction rather than by inspection.

That is the honest trade: **less shipped, but nothing shipped on faith.** ORG-05 lands PARTIAL by
design and is marked so in `REQUIREMENTS.md`.

## Effect on Phase 22 itself

None to its exit criteria. 22-08 was repointed `depends_on: ["22-06"]` (wave 7 → 6) so CI wiring was
never blocked. Phase 22 shipped: analyzer **0 / exit 0**, tests **512/0**, brace rule enforced at
**0**, CI gates live, −1,744 LOC. It simply shipped without a golden baseline.

## If this is ever revisited

`22-07-PLAN.md` is intact in this directory and was verified by the plan-checker alongside the
others. It can be run as-is. The deferred extraction work (`GWAppBar`, `GWScreen`, `GWCopyRow`,
`GWChangePill`, `GWTimeframeSegment`) is the natural beneficiary and is recorded in Phase 23's
handover.
