---
created: 2026-07-17T11:04:50.863Z
title: Design system has no light-mode treatment
area: ui
files:
  - lib/theme/genius_wallet_decorations.dart:145-181
  - lib/components/effects/gw_mesh_background.dart:59-79
  - lib/theme/genius_wallet_colors.dart:73-79
  - .planning/phases/03-gw-component-library/03-09-PLAN.md
---

## Problem

Alex Faber's design system appears to have no complete light-mode treatment. Two components
surfaced this in the 03-07 gallery walk (2026-07-17), and **neither is a port defect** — both
were verified byte-identical to the reference before this was written:

**1. `GWCanvasBackground`** (`genius_wallet_decorations.dart:145`) gates its top-light gradient
AND its `noise.png` grain behind `if (!isLight)`. In light mode it paints only the base
`GWDecorations.canvas` gradient — no grain. This is Alex's own explicit gate.

**2. `GWMeshBackground`** (`gw_mesh_background.dart`) never reads the appearance at all. Its
three blobs are hardcoded to `brandPrimary`/`brandSecondary`/`brandTertiary` (invariant consts
`0xFF14C8FF`/`0xFF2BF5B4`/`0xFFC28FFF`) at `alpha 110`, over a black vignette at `alpha 38`.
Only the backdrop flips — `surfaceBase` goes `_surfaceBaseDark 0xFF0B0D12` →
`_surfaceBaseLight 0xFFDCE0E6`. Pastel blobs over near-black read as a vivid glow; the same
wash over light gray loses most of its contrast. The human reported it as "just a blank space"
in light mode.

**Evidence this is NOT a port defect** (gathered 2026-07-17, decisive):
- `cmp lib/components/effects/gw_mesh_background.dart <ref>` → IDENTICAL
- Our `_surfaceBaseLight`/`_surfaceBaseDark` values + getter logic → identical to reference
- Our `brandPrimary`/`brandSecondary`/`brandTertiary` values → identical to reference
- Identical code + identical inputs ⇒ our render *is* the reference's render. Nothing to
  reconcile against the Release exe for these two.

**Why this matters beyond the gallery:** if light mode is a shipping appearance, these are the
components every screen in Phases 4–9 mounts. A dark-only design system is a gap those phases
will hit repeatedly. Scope is currently **unknown** — could be 2 components, could be many.

**Unresolved (needs the human's eye, cheap to answer during 03-09):** whether the light-mode
mesh is a flat blue-gray *wash* or genuinely empty. Two live hypotheses, not yet discriminated:
- **H1 (design):** dark-designed component, low contrast on a light base.
- **H2 (demo geometry):** blob radius is `0.95 × maxDim` but the gallery demo box is only 180px
  tall, so only the near-center plateau of three oversized gradients is visible — which would
  flatten blob structure in BOTH modes, with dark merely hiding it better. If H2, the demo box
  is the problem and a light-mode treatment fixes nothing.

## Solution

TBD — deliberately not decided yet. Do NOT hack the `if (!isLight)` gate.

Constraints that bound any future fix:
- Removing the gate is insufficient. `opacity: 0.04` monochrome grain was tuned for a near-black
  canvas; over `0xFFDCE0E6` it is essentially invisible. A real treatment needs new opacity,
  possibly a new blend mode or texture — i.e. **new design values that do not exist in the token
  system**. UI-SPEC §8 forbids inventing them ("If a section seems to need a token that does not
  exist, stop").
- Changing `genius_wallet_decorations.dart` breaks byte-identity with the reference (the
  invariant 50/50 ported files currently hold) and makes 03-10's fidelity comparison against the
  Release exe fail by construction, for reasons unrelated to any actual error.
- Milestone rule: "re-skin, never restructure." Inventing a light-mode treatment is a design
  judgement with no owner in this milestone (PROJECT.md Key Decisions).
- This is **not** GAP-01's scope. 03-08's GAP-01 inventories *develop surfaces with no Alex
  analog* (screen-level, re-skin vs restructure). A component-treatment gap is a DS-02-scope
  question per 03-08-PLAN.md:159, not a GAP-01 row.

**Next step that produces the missing data:** 03-09's human-check already walks every gallery
section in both appearance modes. That walk is what yields the real count of dark-only
components. Decide only once that number exists.

Note: 03-09's `must_haves.truths` currently asserts "Every gallery entry renders correctly in
both light and dark appearance" — that expectation is probably false as written, in the same way
the 03-07 handoff's criterion 3 ("mesh shows animated blobs in both modes") was. Both need
correcting to record what is actually there rather than failing against a wrong expectation.
</content>
</invoke>
