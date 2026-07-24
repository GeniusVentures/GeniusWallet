# Sketch 105 · swap-tab — DECIDED, ready for MANIFEST + commit

Design session (2026-07-24) built `.planning/sketches/105-swap-tab/` (index.html + README).
Did NOT touch MANIFEST.md or commit — it was already dirty from a neighbouring session, and per
CLAUDE.md only the executor writes MANIFEST/commits.

**Decision (2026-07-24):** Round 1 → **A · Faithful**. Round 2 → **A1 · Focused (bigger)** chosen.
Winner marked in README frontmatter (`winner: "A1"`) + ★ on the A1 tab. A2/A3 preserved as alts.

**Executor action:** add this row to `.planning/sketches/MANIFEST.md` (Sketches table), then commit:

```
| 105 | swap-tab | How should the Swap tab read as a whole — the two fields, flip, route, CTA states — reusing the live Squid data, and how should the card carry presence on a wide page? | **A1 · Focused (bigger)** (chosen 2026-07-24) — Faithful two-card stack sized up (560px col, brand sheen, subtitle) | swap, squid, cross-chain, layout, fields, route, cta, states, presence, drawer |
```

Suggested commit (COMMIT_DOCS permitting):
`docs(sketch-105): swap-tab — A1 Focused (bigger) chosen`
`--files .planning/sketches/105-swap-tab/ .planning/sketches/MANIFEST.md`

**Key implementation notes for the eventual build:**
- Kill the `Transform.translate(offset: Offset(0,-170))` flip hack (`swap_screen.dart:306`) — flip
  belongs in the seam between the two cards.
- Move off legacy tokens (`deepBlueCardColor`, raw `Colors.greenAccent`) → `surfaceElevated` cards +
  `brandCta` gradient CTA.
- Add CTA state ladder (empty / insufficient / finding route / swap), MAX tap, USD value line.
- Dead code: duplicated `if (fetchedRoute != null)` at `swap_screen.dart:310-311`.
- A2 needs two small read-only widgets (pair-rate line, recent-swaps from tx history); A1/A3 need no
  new data.
