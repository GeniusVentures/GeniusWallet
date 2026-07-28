---
sketch: 072
name: coin-actions-only-what-exists
question: "What does the coin page's action row look like when it holds ONLY actions the code can actually perform - given the live count changes depending on which of the four routes you took to reach the page?"
winner: null
tags: [coin-detail, token-info, actions, cta, data-honesty, dead-affordances, routing, follows-071, follows-069]
lane: execution
---

# Sketch 072: The coin page's actions, holding only what the code can do

Jakub, 2026-07-28, after the 071-B walk, verbatim:

> *"dla CTA, dla których nie ma nic zbudowanego [...] nie możemy tego używać. Nie budujemy tego, więc
> musimy redesignować nasz page na bazie obecnych komponentów, ale respektując to, co jest w kodzie.
> Jeśli czegoś nie ma w kodzie, to nie uwzględniamy designu."*

No new features, no speculative affordances. Every element maps to an existing component **and** to a
code path that exists.

## How to view

```
open .planning/sketches/072-coin-actions-only-what-exists/index.html
```

Four variants × **three entry points**, dark and light. **The entry-point switch is the sketch** -
the same page has a different number of live actions depending on how you got to it, and today's
fixed four-tile row cannot express that.

## What each button actually has behind it

| CTA | Code behind it | Verdict |
|---|---|---|
| **Receive** | `CryptoAddressQR` in a `ResponsiveDrawer` | **real, works on every route** |
| **Send** | no screen, no route | **not built** |
| **Swap** | `/swap` + `SwapScreen` exist and work | **built, never wired** |
| **More** | Bridge Tokens row → `/bridge` | **real, but see finding 2** |

## Findings from the code

**1 · Send does not exist at any layer a user can reach.** No screen, no route.
`lib/reown/send_transaction_details.dart` is the WalletConnect **request** view - a dApp asking you to
sign - not a transfer you start. `GeniusApi.transferTokens(amount, address, {tokenId})` is real
(`genius_api.dart:879`) and has **zero callers in the entire repository**: a native transfer
capability with no UI above it. `web3.dart`'s two `sendTransaction` calls sit inside
`executeBridgeOutTransaction` and `signAndSendTransaction`, i.e. bridge mechanics and reown signing.
Send is a **feature**, not a wiring job, so by the rule above the button leaves the design.

**2 · More is dead on THREE of the four ways into this page - the finding that reframes the sketch.**
`isGnusWalletConnected` is **hardcoded `false`** at `markets_screen.dart:58` and
`dashboard_markets.dart:83`, and `markets_search_bar.dart:93` does not pass the key at all
(`null` → false). Only `coins_screen.dart:296` forwards a real value.

**So arriving from Markets - the main route - exactly ONE of four buttons does anything.** The page
ships an action bar that is **75% inert on its primary path**, and no screenshot of it looks broken.

**3 · Three different truths, one grey box.** `_ActVariant.disabled` renders Send, Swap and a
GNUS-gated More identically. *"Nobody built this"*, *"this works, it just is not connected here"* and
*"this only applies to GNUS"* are not the same message. **Variant A dissolves this rather than
solving it** - with nothing dead in the row there is no grey box left to disambiguate.

**4 · Swap can be wired today; preselection cannot.** `SwapScreen` takes **no parameters at all**
(`const SwapScreen({super.key})`), so tapping Swap opens an empty form and the user re-picks the
token they were just looking at. The fix pattern is next door
(`BridgeScreen(fromToken: walletCubit.state.selectedCoin)`, `router.dart:281`) but it is a change, so
**no variant here draws a preselected swap.** Honest cost: a `fromToken` param, a `state.extra` read,
and mapping a `Coin` to a `SquidTokenInfo` by symbol + chain - that mapping is the real work.

**5 · Buy is reachable in code, and is deliberately NOT proposed.** `BanxaBuyScreen` takes
`initialCryptoCode` and `initialWalletAddress`, and `/createOrder` accepts them. But two todos are
already filed against that path: the app's existing Buy CTA **opens the order history instead of a
buy screen**, and the Banxa orders fetch **uses a hardcoded placeholder customer id**. Adding a Buy
button here would be putting a new door on a corridor already reported broken. It appears only as a
disabled candidate inside variant B, so the option is visible without being taken.

**6 · There is no token-address explorer link to draw.** `getExplorerUrl(coinSymbol, txHash)` takes a
**transaction hash**, so "view token on explorer" is not in the code. Not drawn.

## Defects vs design choices

**Defects, and they ride with whichever variant wins:**
- Send leaving the page (finding 1).
- The three hardcoded `isGnusWalletConnected: false` call sites (finding 2). **That is a bug in the
  callers, not something a layout can paper over**, and it should be filed regardless of the pick -
  it may be that More should be live from Markets too, in which case the design's live-count changes.

**Genuine design choices:** how the row handles a count that changes by route, and whether
unavailable actions are absent or shown disabled.

## Variants

| | Variant | Shape | 2 live actions look like | Cost |
|---|---|---|---|---|
| **0** | **Today** | 4 equal tiles, fixed | 2 live + 2 grey slabs | - |
| **A** ★ | **Only what works** | `GWButton`s at natural width, left-aligned | 2 buttons sized to their labels | the row's width stops being meaningful |
| **B** | **One CTA + menu** | Receive as a gradient `GWButton` + a ⋮ `MenuAnchor` | 1 button + a menu of 3 | one click to reach anything but Receive |
| **C** | **Into the header** | icon buttons in `GWPageHeader`'s trailing slot | 2 icons beside the price | the price and the actions fight for one slot |

## Recommendation

**★ A · Only what works.** The literal answer to the rule that prompted the sketch: the row contains
what the code can do and nothing else. No disabled state to design, no grey box collapsing three
meanings, no promise the app cannot keep. It needs no new pattern - `GWButton` at natural width,
left-aligned - and it makes the count honest on every route, which is finding 2 made **visible**
rather than hidden.

**Runner-up: B · One CTA + menu.** The right answer if the action list is expected to **grow**. It is
the exact discipline 069-A settled for the SDK rows - one menu, same items, same order, inapplicable
ones disabled rather than absent - and Buy would slot into it without a redesign. Not the pick today
because with two live actions a menu is a heavy way to hold one item, and because the growth it is
designed for is speculative, which is precisely what the rule forbids.

**Rejected: C · Into the header.** Reclaims ~74px and looks tidy, but `GWPageHeader.trailing` already
holds the price and its change pill (071-B, shipped the same day). Putting actions there means either
the price moves or the actions become unlabelled icons - and on a narrow window the page's **only**
live action ends up as a 16px glyph next to a 28px number.

## What this does NOT propose

- **No Send**, in any form, including a disabled one.
- No Buy button (finding 5), no explorer link (finding 6), no preselected swap (finding 4).
- No change to `CoinInfoCard`, `CoinConvertCard`, the stat rail or the chart - all 071-B/070-A,
  shipped.
- No change to the drawers Receive and More open.

## MANIFEST row

```
| 072 | coin-actions-only-what-exists | What does the coin page's action row look like when it holds ONLY actions the code can actually perform - given the live count changes with which of the 4 routes you took to reach the page? | **Recommended A · Only what works** - `GWButton`s at natural width, left-aligned, containing exactly the live actions; no disabled state to design, so finding 3 is dissolved rather than solved. Runner-up B · One CTA + menu (069-A's SDK-row discipline: one menu, same items, inapplicable ones DISABLED not absent - right if the list is expected to grow, and where Buy would slot in; rejected today because a menu is heavy for one item and the growth is speculative, which is what the rule forbids). Rejected C · Into the header (reclaims ~74px but `GWPageHeader.trailing` already holds the price + pill from 071-B, so actions become unlabelled icons and on a narrow window the page's ONLY live action is a 16px glyph). **Findings: SEND does not exist at any layer a user can reach** - no screen, no route, `send_transaction_details.dart` is the WalletConnect REQUEST view, and `GeniusApi.transferTokens()` is real with **zero callers in the repository**; it is a FEATURE not a wiring job, so the button leaves the design. **MORE is dead on THREE of the four routes in** - `isGnusWalletConnected` is hardcoded `false` at markets_screen.dart:58 and dashboard_markets.dart:83 and never passed at markets_search_bar.dart:93, so **arriving from Markets exactly ONE of four buttons does anything and the bar is 75% inert on its primary path**; that is a bug in the CALLERS and rides with any variant. **SWAP is built and never wired** (`/swap` + SwapScreen work) but `SwapScreen` takes NO parameters, so preselection is not in the code and no variant draws it - the honest cost is a `fromToken` param plus mapping `Coin`→`SquidTokenInfo` by symbol+chain. **BUY is reachable** (`BanxaBuyScreen` takes `initialCryptoCode`) but deliberately NOT proposed - two todos already say the existing Buy CTA opens the order history and the Banxa fetch uses a placeholder customer id. No token-address explorer link exists (`getExplorerUrl` takes a tx hash). `_ActVariant.disabled` currently collapses three different truths into one grey box. | coin-detail, token-info, actions, cta, data-honesty, dead-affordances, routing, follows-071, follows-069 |
```
