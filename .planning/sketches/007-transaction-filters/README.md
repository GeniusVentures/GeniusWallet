---
sketch: 007
name: transaction-filters
question: "How should the Sent / Received / Escrow / Mint transaction filter read — especially in the narrow dashboard panel where it currently renders as a tiny scaled-down SegmentedButton?"
winner: null
tags: [transactions, filters, segmented, chips, dashboard, chrome]
---

# Sketch 007: Transaction Filters

## Design Question
The Transactions panel filters (**Sent / Received / Escrow / Mint**; "All" = nothing selected) are
today a generic Material `SegmentedButton` lifted onto the section-title row as `trailing`, wrapped
in `FittedBox(scaleDown)` to survive the narrow dashboard right-panel — so it renders tiny and
off-brand. How should this control read, and where should it live (title-row trailing vs its own
row), across **two surfaces**: the tight dashboard slim view and the wider transactions area?

## How to View
open .planning/sketches/007-transaction-filters/index.html

Toggle **Narrow / Wide** to feel both surfaces, and **Dark / Light**. Clicking a filter actually
filters the mock rows; clicking the active filter again clears back to All (matches the current
`emptySelectionAllowed`).

## Variants
- **A · Branded segmented track** — refined `SegmentedButton`: one `surfaceMenu` track, four equal
  segments, active = solid `brandPrimaryStrong`. Own row, full-width. Familiar; can't share the
  title row when narrow.
- **B · Semantic color chips** — individual pills, each with its icon + own status color when active
  (Sent=red, Received=green, Escrow=amber, Mint=mint-brand). Wraps when narrow. Most expressive;
  louder than the app's one-accent restraint.
- **C · Compact icon-only segmented ★** — icon-only in the narrow panel (tooltips); the *active* chip
  expands to show its label. Stays on the title row as trailing, kills the overflow, stays legible.
  On the wide surface all labels show. **Recommended.**
- **D · Gradient-underline tabs** — nav-tab language (icon+label + `brandCta` gradient underline
  under active). Reads as "sections"; needs its own row; extends the gradient-underline motif that's
  otherwise reserved for the nav.
- **E · Dropdown / menu filter** — one compact trigger on the title row; menu with icons + live
  counts, current shown on the trigger. Most space-frugal + most scalable (counts, future filters).
  Options are one click away → less glanceable.

## What to Look For
- **Narrow panel:** does the control fit on the title row (C, E) or force its own row (A, B, D)?
  Does anything overflow or shrink illegibly (the FittedBox problem)?
- **Brand fit:** solid `brandPrimaryStrong` active (A, C) vs multi-color semantic (B) vs
  gradient-underline (D) vs quiet menu (E). Keep the gradient reserved for the primary CTA.
- **Scannability vs restraint:** icons help identify types fast (all but A's text-first), but
  per-filter colors (B) may be too much next to the already color-coded rows.
- **Scalability:** more filters later (Swap, Purchase)? E and C absorb them best.
- **Two-surface consistency:** which one control reads well in BOTH the slim view and the wide area
  without a separate layout?
