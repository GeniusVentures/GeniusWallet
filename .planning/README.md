# .planning — UI redesign upgrade plan (AI-ingestable)

This folder is the machine-readable plan for bringing the **GNUS UI redesign**
(branch `ui-redesign-3.514`) onto `develop`. An AI or a developer can ingest these
docs to understand what changed, what is safe, and what remains to be wired.

## Read order

1. **[CHANGELOG.md](CHANGELOG.md)** — what already changed on this branch (the 4
   post-review fix commits + the redesign) since review HEAD `1b83a67`.
2. **[REVIEW_FINDINGS.md](REVIEW_FINDINGS.md)** — the verified pre-production review:
   corrections to the handoff, security items, and the §G priority checklist. Items
   already fixed are marked ✅.
3. **[WIRING.md](WIRING.md)** — the remaining work as a `WIRE-1..11` checklist, each
   mapped to a greppable `// WIRE-n` marker in the code (`grep -rn "WIRE-" lib/`).

## Reference (kept at the repo root, not here)

- **`../HANDOFF.md`** — the team's integration/handoff guide (design system, deps,
  native follow-ups, rebase). Referenced by name throughout the docs above.
- **`../DESIGN_SYSTEM.md`** — design tokens & rules; see migration **v1.4** for the
  touch-legibility / tap-target pass.

## How to use for the develop upgrade

- The actual redesign code lives on this branch (`ui-redesign-3.514`) under `lib/`.
- Start from `REVIEW_FINDINGS.md` §G (priority checklist) and `WIRING.md` (WIRE-1..11).
- `grep -rn "WIRE-" lib/` lists every integration point still needing real data/APIs.
- Blockers/decisions are flagged 🔴 / ⚖️ — do those before shipping.
- **Rebase first** (`REVIEW_FINDINGS.md` §A1): `dev_logsubmissions` / `develop` have
  moved far ahead, so a rebase/merge with real conflicts (esp. `lib/banxa/*`) is
  required before this branch integrates cleanly.

_The three docs reference each other by name and all sit in this folder._
