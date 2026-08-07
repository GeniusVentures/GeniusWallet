---
sketch: 173
name: variant-a-interactive
question: "What happens when you tap the wallet name - and does variant A hold up once you can actually click through it?"
winner: null
tags: [mobile, ios, prototype, interactive, wallet-switcher, navigation, follows-171, follows-172]
---

# Sketch 173: Variant A as a clickable prototype

## Design Question

Jakub picked **A · Curated Five** (2026-08-06) and immediately found the hole in the static mockups:
what happens when the wallet expands, when he taps in there - make a fully interactive version.

A static image does not answer what the header does. This sketch answers by working.

## How to View

```
open http://localhost:8899/173-variant-a-interactive/
```

Everything on the phone is clickable. Every tap lands in the **log** on the right with the name of
the route that would have fired in `router.dart` - or a note that no such route exists.

## The main answer: the wallet is a sheet, not a dropdown

Tapping the wallet name opens a sheet listing the wallets (Main Wallet / Trading / Cold Storage),
with the balance and asset count beside each, plus the actions: Add wallet, Connect via WalletConnect,
Manage wallets. Choosing one **really switches state** - the header and the balance change.

**Why a sheet and not a dropdown.** A dropdown under the header has to fit inside 390 px
and grows downward over the content. At a ~56 px row (name + address + balance) four wallets cover
half the screen and still need scrolling, and the top edge of the list is out of thumb reach.
A sheet comes up from the bottom, has room for the address, balance and network, and uses `GWBottomSheet`,
which already backs "More" - zero new patterns.

## What else works

- **Network chip** → the network sheet; changing network rebuilds the asset list (Ethereum 3 / Polygon 2 / BNB 1).
- **Address** → copy with confirmation.
- **Asset row** → the coin screen, with a back bar showing where you came from.
- **Swap from a coin** → the log shows `/swap extra:{symbol}`, the real contract from `router.dart:224`.
- **Bottom bar** → five items; More opens a sheet with News / Web / Feedback / Settings.
- **Action rail** → Send / Receive / Buy / Compute.

## What the log reveals

Three taps end in `no route`: **Receive**, **Send** and **Compute**. That is not a defect of the
prototype - it is the state of the app. Send and Receive live today as buttons inside screens
(`wallet_information.dart:176-185`, `coins_screen.dart:179,345`) rather than as routes, so navigation
has no way to show them. This prototype makes that gap visible.

## Open

- Whether the wallet switcher should switch the network too, or whether those are two independent axes (independent for now).
- Whether Compute deserves its own route.
- Behaviour with a single wallet - a sheet with one item makes no sense, a collapsed state is needed.
