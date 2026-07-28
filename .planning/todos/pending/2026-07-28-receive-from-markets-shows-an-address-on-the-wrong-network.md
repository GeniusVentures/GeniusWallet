# Receive on a coin page shows the WALLET's address, whatever coin you are looking at

**Found:** 2026-07-28, while fixing *"Receive null"* in the same drawer.
**Type:** correctness. Pre-existing - the old four-tile bar had Receive live on every route too.

## What happens

`token_info_screen.dart`'s Receive drawer passes `selectedWallet?.address` and
`selectedNetwork?.name` - the WALLET's address on the wallet's current network. Arriving from
Markets, the coin on screen has nothing to do with either. Open Bitcoin from Markets on an Ethereum
wallet and you get an Ethereum address under a page titled Bitcoin.

## Why it is not currently dangerous

`CryptoAddressQR` renders the network chip above the QR and a `GWWarningNote` reading *"Only send
Ethereum-network assets to this address."* Both name the ACTUAL network, so a user who reads them
cannot be misled about what the address is for.

The drawer title was the one place that could have lied, and it no longer does: it now takes the
name from `selectedCoin` only - never `marketData` - and falls back to a bare "Receive". Titling it
after the coin you were browsing would have put *"Receive Bitcoin"* over an Ethereum address.

## The open question, which is a product one

Should Receive appear at all on a coin the wallet cannot receive? Three answers, none obviously right:

1. **Leave it.** Receive means "here is my address"; the warning note carries the network. Cheapest,
   and it is what ships today.
2. **Hide it when the coin's chain is not the wallet's chain.** Honest, and consistent with how
   Bridge is now absent rather than greyed when it does not apply. Needs a chain comparison the page
   does not currently make - `Coin` vs the market-data record have no shared chain field.
3. **Show the address for the COIN's chain** if the wallet has one. The largest change, and the only
   one that makes Receive mean what the page implies.

## Related

- `.planning/quick/260728-v6c-coin-actions-074c2/SUMMARY.md`
- `lib/components/qr/crypto_address_qr.dart` - the warning note that keeps option 1 defensible
