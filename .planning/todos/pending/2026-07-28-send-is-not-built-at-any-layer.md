# Send is not built at any layer a user can reach

**Found:** 2026-07-28, Jakub during the 071-B walk: *"Mamy faktycznie kod, który pozwala nam na akcje
RECEIVE, SEND, SWAP i MORE? Bo póki co te CTA są w ogóle nieaktywne."*
**Type:** a missing feature, not a wiring job.

## Two thirds of this closed the same day - 074-C2, quick task `260728-v6c`

Filed as "Send and Swap CTAs have nothing behind them"; the Swap half and the grey-box half are now
done, so what is left is Send alone.

- **Swap is wired** - `context.push('/swap')` from the coin page's action row. **Preselection is
  still not built**, and the paragraph below on `Coin` → `SquidTokenInfo` is still the actual work.
- **The identical grey boxes are gone** - `TokenActionBar` is deleted. Bridge is now absent rather
  than disabled when the coin is not GNUS, and disabled only at zero balance, which is the one case
  the user can act on.
- **Send was removed from the page** rather than shipped as a fourth dead affordance, per Jakub's
  rule: *"Jeśli czegoś nie ma w kodzie, to nie uwzględniamy designu."*

**What this todo is now:** whether Send gets built, and as what. Nothing in the UI claims it exists,
so this is no longer urgent - it is a product decision with no deadline attached.

## Traced, all four

| CTA | UI today | what is behind it | verdict |
|---|---|---|---|
| **Receive** | live, primary | `CryptoAddressQR` in a `ResponsiveDrawer` | **real, works** |
| **Send** | permanently grey | **nothing** - no screen, no route, no caller | **not built** |
| **Swap** | permanently grey | **`/swap` + `SwapScreen` exist and work** | **built, never wired** |
| **More** | live only for GNUS | Bridge Tokens row → `/bridge` | **real, narrow** |

`TokenActionBar` declares `sendEnabled`, `swapEnabled`, `onSend` and `onSwap`. **`grep` finds no
call site anywhere in `lib/` that passes any of them.** They have been dead parameters since the
component was written.

## Swap is the cheap one, and it is nearly free

The swap tab is a working screen (`SwapScreen`, `/swap`, inside the `ShellRoute`) and it was
substantially repaired earlier the same day - the token picker crash, the picker's own selection, the
MAX chip. Wiring the coin page's Swap button is `context.push('/swap')` plus passing
`swapEnabled: true`.

**The one real question is preselection.** `SwapScreen` takes **no parameters** at all
(`const SwapScreen({super.key})`), so today it would open with nothing chosen and the user would pick
the token they had just been looking at. The pattern for fixing that already exists next door:
`BridgeScreen(fromToken: walletCubit.state.selectedCoin)` (`router.dart:281`). Swap needs the same
`fromToken` param plus a `state.extra` read on the route.

Worth checking before building: the coin page's coin is a `Coin`, while the swap screen works in
`SquidTokenInfo`. Matching one to the other is by symbol + chain, and that is the actual work - not
the button.

## Send does not exist at any layer the user can reach

- **No screen.** No `SendScreen`, no send route. `lib/reown/send_transaction_details.dart` is the
  WalletConnect **request** view - a dApp asking you to sign - not a user-initiated transfer.
- **No caller for the native path.** `GeniusApi.transferTokens(amount, address, {tokenId})` exists
  (`packages/genius_api/lib/src/genius_api.dart:879`) and has **zero callers in the whole
  repository**. There is a native transfer capability with no UI on top of it.
- **The web3 sends are not a send flow either.** `web3.dart`'s two `sendTransaction` calls live
  inside `executeBridgeOutTransaction` and `signAndSendTransaction` - bridge mechanics and reown
  signing.

So Send is a **feature**, not a wiring job: an amount field, a recipient field with address
validation and probably a QR scan (`gw_qr_scanner.dart` exists), a fee estimate, a confirmation, and
a result state. It also needs a decision about which path it uses - `transferTokens` for SGNUS versus
a web3 transfer for EVM coins - which is a product question, not a layout one.

## Why the buttons look identical today

`_ActVariant.disabled` renders Send, Swap and a GNUS-gated More the same way. **Three different
truths, one grey box:** "this needs a feature nobody has built", "this works, it just is not
connected here", and "this only applies to GNUS". Whatever is decided about Send, the page should
probably stop claiming all three are the same kind of unavailable.

## Recommended order

1. **Wire Swap**, with or without preselection. It is the largest gap between what exists and what
   the user can reach.
2. **Decide what Send means** before drawing it. If it is not on the roadmap, the honest move is to
   remove the button rather than ship a permanently dead affordance - sketch 152 put it there when
   the flow was assumed to be coming.
3. **Distinguish the disabled states** if any of them stay.

## Related

- `.planning/quick/260728-u8p-coin-page-071b-stat-rail/SUMMARY.md`
- `.planning/sketches/071-coin-page-whole-screen/README.md` - drew all three as genuinely disabled,
  which was accurate but did not ask why
- D-01 / D-02 (Send/Swap disabled) - the original decisions this inherits
