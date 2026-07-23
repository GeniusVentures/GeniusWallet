---
sketch: 034
name: receive-qr
question: "How should a receive drawer balance the QR, the full address, the copy action, and the network warning?"
winner: "A"
tags: [drawers, receive, qr, address, copy, network-warning]
---
# Sketch 034: Receive / QR

## Design Question
How should a receive drawer balance the QR code, the full wallet address, the copy
action, and the "only send the right asset on the right network" warning — when some
users scan and some users read/verify the address by eye?

## How to View
open .planning/sketches/034-receive-qr/index.html

All three variants reuse the 030 drawer shell verbatim (shell A · Framed: centered
"Receive" title + close ✕, 20px padding). Variant tabs switch archetypes; the Dark/Light
toggle is bottom-right. The QR is drawn as a 25×25 CSS grid with real finder squares and
stays black-on-white in both themes (it has to scan). Copy → toast "Address copied",
Share → toast, the C segmented control switches QR / Address / Options, close ✕ slides out.

## Variants
- **A · QR hero** — big centered QR on a white tile, coin+network chip above, truncated
  `0x1d9b…4a87` with an inline copy icon below, warning as a quiet amber line, footer
  [Copy address] primary. The classic clean receive screen.
- **B · Address-forward card** — QR shrinks to a header cue, then a prominent bordered
  address card shows the FULL wrapped address in mono with a Copy button welded to it,
  a coin/network row, a full amber warning banner, and a secondary [Share]. Better when
  the user needs to read/verify the address.
- **C · Tabbed QR / Address / Options** — a segmented control (QR | Address | Options)
  folds the QR, the full-address panel, and the wallet_information "More Options" list
  into one drawer. Options = Set as default receive address, View on explorer, Show full
  address. Footer CTA appears on QR/Address, hides on Options.

## What to Look For
- Does the truncated `0x1d9b…4a87` (A/C-QR) give enough to verify, or does verification
  demand the full wrapped address (B, C-Address)?
- Quiet amber line (A) vs. full banner (B) — is the warning loud enough at each weight?
- Does C's third tab justify the extra chrome, or is "More Options" better as its own
  drawer over a clean A?
- QR legibility on the white tile in dark mode; copy-affordance discoverability.

## Covers
Receive (hero), Your <network> address, More Options.

## Round 2 — A fine-tunes
Winner is **A · QR hero** (the QR is the hero; verification is the minority case).
Round 2 keeps that decision and tunes only the address grouping, the warning weight,
and the copy affordance. All three fine-tunes reuse the refined **030 B1 "Quiet band"**
shell chrome verbatim (60px header, LEFT "Receive" title, close ✕ top-right, 1px
`--brand-primary-subtle` hairline, single gradient primary footer). Tabs: A1/A2/A3 +
a `baseline · chosen A` for comparison; A1 is default.

- **A1 · Pure hero** — big QR on a white tile (radius `--radius-2xl`, 16px pad),
  coin+network chip ABOVE, truncated `0x1d9b…4a87` with an inline copy icon BELOW, the
  warning as one quiet amber line with a small ⚠. Minimal, calm — the classic clean code.
- **A2 · Grouped address** — QR shrinks slightly; the FULL address sits below as a
  tappable mono block, character-grouped into 4-char chunks with first/last chunks
  emphasized (easier to eyeball-verify), a copy icon welded in; network chip; warning as a
  bordered amber note — a touch louder. Footer still [Copy address].
- **A3 · Caption + toggle** — QR on the white tile with "GNUS Network" as a caption
  directly under it; a small **Short / Full** segmented toggle swaps the truncated address
  ↔ the full grouped address in place; copy icon; warning inline as one line.

### Respected audit gaps
The real `CryptoAddressQR` widget carries ONLY a CopyButton, so every fine-tune's footer is
**Copy address only**:
- **No Share** — would require `share_plus`, which is not in the widget today.
- **No "set as default receive address"** — the real "More Options" is Submit Job + Delete
  Wallet, not a default-address setter, so that action is deliberately omitted.
`qr_flutter` IS available, so the QR is faithful (drawn here as a CSS grid because CSP blocks
images); it stays black-on-white in both themes so it always scans.
