---
sketch: 159
name: receive-drawer
question: "034-A2 decided the receive drawer and two thirds of it shipped. What is missing, what is broken, and is there anything worth adding?"
winner: null
tags: [drawers, receive, qr, address, copy, network-warning, data-honesty, follows-034]
lane: B
---

# Sketch 159: Receive - the decision was made, two thirds of it shipped

Jakub, 2026-07-27, with a screenshot of the Receive drawer and no further words. So this sketch starts by
answering the unasked question: **is this drawer what was decided?** Mostly, and the gap is specific.

## What 034 round 2 chose

**A2 "Grouped address"**: a gap above the QR, the network chip **above** it, the address as a
**4-character-chunked mono block with the first and last groups emphasised**, copy only - no Share, no
set-default. `crypto_address_qr.dart` cites that decision in its own docstring.

Two of the four landed.

## Findings

1. **Drift: the chunked address became a middle-truncated one.** `_shortAddress()` (`:51`) renders
   `0x9fF8C9…262e2b`. A2 chose chunks precisely because a receive address is the one string a user
   **eyeball-verifies against another screen**, and truncation hides the 26 middle characters - the ones a
   clipboard-swapping attack changes. Sketch **154-D** proposes the same 4-char treatment for the transaction
   drawer, so this is now one component owed to two sketches.
2. **The drawer body has zero horizontal padding.** `ResponsiveDrawer` passes `body: child` straight through
   (`responsive_drawer.dart:208`) and `coins_screen.dart:170` hands it a bare `CryptoAddressQR`. The centred
   column is fine; the amber note is a full-width `Container`, so **it runs to both panel edges** - visible in
   the screenshot. Identical class of defect to **154 finding 1**, and the same fix location: 030-B1 already
   specified 20px of body padding for every drawer, and the shell still does not apply it.
3. **An empty network name produces broken copy.** The caller passes
   `selectedNetwork?.name ?? selectedNetwork?.symbol ?? ''` and the warning is
   `"Only send ${network}-network assets to this address."`, so a blank network renders
   **"Only send -network assets to this address."** The sketch has a **Network blank** toggle to read it.
4. **`AssetImage("")` when the network has no icon.** `:109` builds `embeddedImage: AssetImage(widget.iconPath
   ?? "")` with no `embeddedImageEmitsError`. The `if (iconPath != null)` guard four lines earlier protects
   the chip avatar but not the QR's centre image.
5. **Two hard-won things are correct and must not be touched.** The QR keeps a solid white backing in **both**
   appearances so a phone camera can read it, and the amber uses a darkened light-mode value (`#92400E`,
   7.1:1) because `statusWarning` is a fill token that fails as text on white. Both are commented in place;
   no variant changes them.

## How to View

```
open .planning/sketches/159-receive-drawer/index.html
```

Deep links `#a` .. `#d`. Toolbar: five panels, a **Network known / Network blank** state toggle for finding 3,
**Edge marks** (draws where the 20px body padding would be, so finding 2 is visible rather than described),
and Light/Dark.

## Variants

- **0 · Today** - literal render, including the edge-to-edge amber note.
- **A · A2 as decided ★** - the standing decision finished: 20px body padding, 4-char chunks with the first
  and last group at full weight, the address in a labelled card, the QR in a rounded white tile, Copy moved
  to the footer where every other drawer's primary action lives.
- **B · Request amount** - an optional amount field; the QR encodes a payment URI instead of a bare address.
- **C · Network picker** - A plus a tappable network chip opening the shipped 032-A1 list picker.
- **D · Compact** - no chip, smaller QR, the warning as plain text. Shortest panel.

## Recommendation

**★ A · A2 as decided.** This drawer has been designed once and ported two thirds of the way. Designing it
again before the first decision is finished would be the same mistake sketch 154 names about the transaction
drawer. Everything in A is either a decision already taken (chunks, padding) or a shell rule already written
(footer action).

**The chunking is worth building as a component, not a helper.** `GWChunkedAddress(address, groups: 4)`
serves this drawer, 154-D's copy rows, and any future explorer link. One widget, two sketches paid off.

**Runner-up: C · Network picker.** It costs almost nothing - the Select Network drawer already exists as
032-A1 - and it turns finding 3 from a thing you read into a thing you fix. The one real risk is that the
address and QR re-render on switch, and **the wrong address on screen for one frame is worse than an extra
tap**, so it needs the re-render to be atomic. Take it after A, not with it.

**B · Request amount is the right idea and the wrong time.** The QR side is free (`qr_flutter` encodes any
string), but the URI scheme is per-chain: EIP-681 is well defined for EVM, Bitcoin uses `bitcoin:`, and every
other chain needs its own rule. **A wrong scheme is a lost payment, not a cosmetic bug.** If it is taken, take
it EVM-only and hide the field on any chain without a verified scheme.

**D · Compact is rejected for one reason:** it un-boxes the network warning. That single line is the only
thing on the panel standing between a user and a permanent loss of funds, and it is the last element that
should get quieter.

## What to Look For

1. **Edge marks on, variant 0.** The amber note against the panel edge is the defect; everything else on this
   panel is fine.
2. **Read the chunked address in A and then the truncated one in 0.** Ask which one you could check against a
   phone screen.
3. **Network blank, on 0.** "Only send -network assets to this address."
4. **A's footer.** Copy as a real footer button is the 030-B1 rule; the question is whether the tap-to-copy
   card makes it redundant. Both are drawn - A has both on purpose so the pair can be judged.
5. **Light mode.** The amber and the QR backing are the two things to check, and both are already handled -
   confirm rather than redesign.

## Cross-sketch note

Findings 1 and 2 both belong to a shared component and a shared shell, not to this file:

- The **chunked address** is owed to 154-D as well.
- The **body padding** is owed to every drawer; `drawers-final/README.md` already says the fix belongs in
  `responsive_drawer.dart`, and the ~19-drawer walk in `HANDOFF.json` is where the full list gets recorded.

Fixing either one here alone would be the third place the same decision gets half-applied.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 159 | receive-drawer | 034-A2 "Grouped address" was chosen and two thirds of it shipped. What is missing, what is broken, and is anything worth adding? | _pending pick_ (rec **A · A2 as decided** - finish the standing decision: 20px body padding, 4-char chunks in a labelled card, QR in a rounded white tile, Copy in the footer; runner-up **C · Network picker** = A + the shipped 032-A1, take after A because the address must re-render atomically; **B · Request amount** right idea wrong time - the QR is free but per-chain URI schemes are not, and a wrong scheme is a lost payment; rejected **D · Compact** - it un-boxes the one warning that prevents losing funds). Findings: the chunked address shipped as a middle truncation (`_shortAddress:51`), the drawer body has ZERO horizontal padding so the amber note touches both panel edges (same class as 154 finding 1), a blank network renders "Only send -network assets to this address.", and `AssetImage("")` is constructed when the network has no icon. The white QR backing and the darkened light-mode amber are correct and untouched. | drawers, receive, qr, address, copy, network-warning, data-honesty, follows-034 |
```
