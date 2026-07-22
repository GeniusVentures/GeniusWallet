# Two sketches share the number 020

**Found:** 2026-07-22, during the Phase 14 design session (observed, not caused by it)
**Kind:** looks wrong / will break tooling — not blocking anything today

## What

Two sketch directories carry the same number, and both are listed in `MANIFEST.md`:

- `.planning/sketches/020-transactions-tab` — MANIFEST line 38, decided (**B · Filter rail** + **E2**), superseded by 021
- `.planning/sketches/020-boot-mesh-depth` — MANIFEST line 41, **still `_pending pick_`** (rec **B · Deep**)

## Why it matters

- `.planning/sketches/020-*` globs to two directories. Any workflow that resolves a sketch by number
  (the sketch workflow's own "find next available number" step, frontier mode's landscape load, or a
  plan citing "sketch 020") gets an ambiguous match.
- `phase.add`-style auto-numbering computes "next number" from the highest existing — that still
  works, but a reader following a `020` citation cannot tell which sketch is meant.
- One of the two is undecided, so this is not purely historical — `020-boot-mesh-depth` will be
  referenced again when its pick is made.

## Suggested fix

Renumber `020-boot-mesh-depth` → **023** (022 is the current high-water mark), update its MANIFEST
row and its README frontmatter, and grep for `020` citations in `.planning/phases/13-*` before
moving it.

**Not done in this session** — `020-boot-mesh-depth` is another session's live work and renaming a
directory out from under it mid-flight is worse than the collision.

## Related

The Phase 14 ROADMAP entry already routes around this: the `/network` re-skin sketch is recorded as
**023**, which would collide with the suggested fix above. Whichever lands second takes 024.
Resolve the numbering before creating either.
