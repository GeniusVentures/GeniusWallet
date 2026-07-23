---
sketch: 031
name: receipt
question: "How should a transaction/result receipt read — the hierarchy of identity, amount, status, and detail rows?"
winner: "B"
tags: [drawers, receipt, transaction-detail, amount, status, rows]
---
# Sketch 031: Receipt

## Design Question
The receipt drawer is where a user lands after a transaction, swap, or buy resolves. Today the
transaction-detail drawer ships a bare ListView with zero horizontal padding, so labels touch the
left edge and values slam the window edge. Beyond the min-fix, the real question is how the panel
should *read*: what leads — the identity icon, the amount, or the status — and how do the detail
rows sit under it so that a failed or pending result is as legible as a clean success.

## How to View
open .planning/sketches/031-receipt/index.html

## Variants
- **A · Rows card** — The safe port. Brain icon + amount centered on top, then ONE bordered card of
  label→value rows (label left/muted, value right, tabular-nums, ellipsis on long hashes). Clean and
  boring; the smallest change that fixes the padding bug.
- **B · Status-led receipt** — Leads with a prominent status pill under the amount, then rows grouped
  into labelled "Transaction" / "Network" sections with hairline dividers. A state-cycle control
  (Completed / Pending / Failed) recolors the icon, amount, pill and status row together so the
  reviewer can feel all three states — this is the variant that earns its keep on failed/pending.
- **C · Hero amount + compact meta** — The amount is the true hero (40px), a colored left-accent
  identity chip carries icon + address, and the details drop into a tighter 2-col grid. Mono values
  (address, hash) copy on click and fire a toast. The Explorer button sits inline at the bottom of
  the scroll body rather than in a fixed footer.

## What to Look For
- Hierarchy: does the eye land on amount first, or does identity/status compete?
- How failed/pending read — cycle the state in B; does red/amber carry without extra chrome?
- Copy affordance — is the click-to-copy in C discoverable (⧉ hint) without being noisy?
- Long-value safety — hashes/addresses must ellipsis, never overflow the 420px panel.
- Dark + light — flip the theme toggle; status tones and hairlines must survive both.

## Covers
Transaction detail (hero), Swap Success/Failed, Buy Success/Cancelled, dApp Swap Result.

## Round 2 — B fine-tunes

Round 1 picked **B · Status-led receipt** (status leads and recolors the whole receipt). Round 2 is a
detail pass: three fine-tunes of that direction that differ only in *how* status leads, plus a
`baseline · chosen B` tab for side-by-side comparison. All four sit inside the **refined 030 shell
(B1 "Quiet band")** verbatim — 60px header, left-aligned title "Escrow released", close ✕ top-right, a
1px `--brand-primary-subtle` hairline under a `--border-subtle` border, `.p-body` 8/20/20, `.p-foot`
16/20, and the real brandCta gradient (`--brand-cta-b → --brand-cta-a`) on buttons. The default active
tab is the first fine-tune, **B1**.

- **B1 · Pill + sections** — refined round-1: identity icon + amount centered, then a filled-tint
  **status pill** under the amount (bg = state color @14% alpha, text = state color, 6px leading dot,
  8px 14px padding, pill radius). Rows grouped into TRANSACTION / NETWORK cards with uppercase
  `.sec-label` headers and hairline dividers.
- **B2 · Status banner** — status becomes a full-width **banner** at the top of the body: a 3px
  left-accent bar in the state color + a state chip + bold label + a one-line plain-language reason
  ("Confirmed on-chain" / "Waiting for confirmations" / "Dropped — not mined" / "Cancelled by sender").
  Then amount, then a single flat rows card (no section split — tighter, more alert-like). Best for
  Failed / Cancelled legibility.
- **B3 · Woven minimal** — no pill/banner chrome: a status dot + label sits hairline-thin directly
  under the amount; all rows in one flat card; only the Status row carries the state color. The most
  restrained take.

### The 4-state fix
Audit of the real `TransactionStatus` enum found **four** states; round-1 sketch shipped only three.
Every R2 variant now cycles all four, and icon tint + amount color + status marker (+ B2's reason
line) recolor together live:

| State | Token | Amount |
| --- | --- | --- |
| Completed | `--status-success` #0AD89C | `+ 500.00 GNUS` green |
| Pending | `--status-warning` #FFC42E | `+ 500.00 GNUS` amber |
| Failed | `--status-error` #FF4D4D | `— 500.00 GNUS` red |
| Cancelled | `--status-neutral` #64748B | `— 500.00 GNUS` slate ← the one R1 missed |

Real fields only (no lorem): Date `Jul 22, 2026 · 5:05 PM`, Status, From `0xFrom…ed05` (mono),
Network `GNUS`, Network Fee `0.001 GNUS`, Hash `0xdevm…ck05` (mono). Mono values copy on click → toast
"Copied". No fiat value is shown — the receipt has none. Footer: secondary "View on Explorer". The
`baseline` tab reproduces the round-1 B body (bordered band + trailing glyph, looser spacing) in the
same refined shell, extended to the correct four states, so the pill refinement reads at a glance.

### Recommendation
**B1 · Pill + sections.** It is the closest to what round 1 approved, and the filled-tint pill carries
the state color at a size the eye lands on without shouting; the TRANSACTION / NETWORK grouping keeps a
six-field receipt scannable. B2's banner is the stronger choice *if* Failed/Cancelled are common enough
to warrant always-on alert framing, but for the common success path it spends vertical space on chrome.
B3 is elegant but leans too quiet for a Failed result. Ship B1 as the default; keep B2's banner in
reserve for a future error-emphasis pass.
