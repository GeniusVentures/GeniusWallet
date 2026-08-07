---
created: 2026-08-07T13:56:00.000Z
title: The phone header no longer identifies WHICH wallet is live
area: ui
files:
  - lib/account/account_drawer.dart:602
  - lib/components/overlay/mobile_header.dart
  - .planning/sketches/181-wallet-control-compact/README.md
---

## Problem

Sketch 183 scheme F (shipped 2026-08-07) replaced the header's 223.94px wallet pill with a
44 x 44 circle. The pill printed the wallet's NAME; the circle prints a picture. **The picture
is of the CURRENCY, not of the wallet.**

`AccountAvatar.build` (`account_drawer.dart:602`) paints a `CircleAvatar` with
`backgroundColor: brandPrimaryStrong` and a child of
`Image.asset('assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png')`. No per-wallet
colour, no blockie, no seed, nothing derived from the address. Sketch 181, finding 1, verbatim:
**"Two ETH wallets render the same pixels."**

It is slightly worse at 44px than it was at 32. The 32px disc draws
`crypto/{currencySymbol}.png` while the 16px badge draws `network.iconPath`, and for Ethereum in
`networks.json` that is `assets/images/crypto/eth.png`. **For an ETH wallet on Ethereum - this
app's default state - those are the same file**, now rendered 3px apart inside one 44px control.
So the header draws the same picture twice and neither instance says which wallet you are on.

What the header's information content actually did:

| Question | Before F | After F |
| --- | --- | --- |
| Which wallet? | its NAME, in text, until it ellipsized | **nothing visible.** The picture is of the currency |
| Which chain? | a 16px badge picture, plus the name in the semantic label | a 16px badge picture, often the same picture as the disc |
| Which wallet and chain, for a screen reader | the semantic label | **unchanged** |

**This is a SIGHTED-USER gap, not a total one.** The semantic label survived the deletion
intact and all three of its branches are now asserted in
`mobile_header_brand_and_pill_test.dart`. VoiceOver still hears
`"{walletName}, on {network}. Opens wallet and network"`. The accounts drawer one tap away still
distinguishes wallets by name and address.

Filed as `T-s7n-03` in the plan's threat register - Spoofing, high severity, **disposition
accept with the acceptance put to the user**. A user can act on the wrong wallet believing it is
another. It was accepted only because the drawer is one tap away and the semantic label is
intact, and it is ruling 1 at the plan's on-device checkpoint. **It must not be closed silently.**

## Solution

**Sketch 181 scheme E: a two-character monogram inside the same 44px circle.** Zero extra width,
and it answers which wallet AND which chain at 44px. 181's own "If F ships" table lists it as an
additive `monogram` branch on `AccountAvatar`, and 183 renders every variant with it.

Not built in the 2026-08-07 change because `lib/account/account_drawer.dart` was outside that
task's file fence, and because the instruction for the wallet control was explicitly that its
decoration does not change and its diff is a deletion.

Constraints on the implementation, so it is one step to pick up:

- **Additive only.** `AccountAvatar` has a hard contract already stated on its `networkIconPath`
  parameter: when that is null it returns today's exact `CircleAvatar` with no `Stack` and no
  wrapper, because the drawer rows above pass nothing and must not change by a pixel. A
  `monogram` branch must honour the same rule.
- **THE ADDRESS-SHAPED RULE GOES FIRST.** `import_security_screen.dart` stores unvalidated free
  text in the name field, so a wallet's "name" can be an address. Taking the first two characters
  of `0xAAAA...` yields `0X`, and taking the last two yields the trailing digits of an address
  rendered as an identity - which is worse than no monogram, because it looks meaningful. Detect
  an address-shaped name FIRST and fall back to something else (the currency glyph as today, or a
  derived index like `S1` / `S2`) before any initials logic runs.
- The `walletName` free-text input defect is its own todo and is not fixed by this.

The alternative Jakub reserved on 2026-08-07 is scheme 183C, which removes the WALLET's border
rather than adding identity. That is a different question - it is about whether the two controls
should match - and it does not address this one.
