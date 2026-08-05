---
sketch: 013
name: mint-job-badge-colour
question: "What colour should the Mint and Processing-job badges be, given green/red/amber/slate are already taken?"
winner: "Mint = brandTertiary #C28FFF · Job = brandPrimaryStrong #0AAEE6"
tags: [transactions, badges, color, contrast]
---

# Sketch 013: Mint + Processing-job Badge Colour

## Decisions
- **Mint = `brandTertiary` `#C28FFF`** — furthest hue from every taken colour; already in the
  palette and used nowhere else, so zero new tokens.
- **Processing job = `brandPrimaryStrong` `#0AAEE6`** — compute is the product, so jobs carry the
  house accent.

## The constraint that decided it
Four badge colours were already spoken for: green = money in, red = failed, amber = pending,
slate = sent. Whatever Mint and Job took had to stay distinguishable from all four **at 18px**.
The sketch computes hue gaps live and flags collisions.

## Rejected, with reasons
- **`brandSecondary` `#2BF5B4`** — the literal "mint green" pun, but it sits only ~14° from
  `statusSuccess` `#0AD89C`. At badge size they read as the same green, merging Mint into Received.
- **`statusSuccess`** — honest (value did arrive) but then Mint and Received are indistinguishable.
- **Gold `#D9A441`** — pairs well with the pickaxe, but sits too close to Pending amber.
- **Slate for Mint** — identical to Sent, which is the opposite direction.
