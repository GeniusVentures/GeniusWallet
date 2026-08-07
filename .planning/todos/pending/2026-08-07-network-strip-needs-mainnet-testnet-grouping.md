# The network strip needs mainnet/testnet grouping, and networks.json cannot express it

Captured 2026-08-07 by quick task `20260807-mobile-header-brand-and-wallet-pill`.

## The cost, with its number

`assets/json/networks/networks.json` holds **10 networks**, and **5 of them are testnets**:

| Mainnet | Testnet |
| --- | --- |
| Ethereum | Ethereum Sepolia |
| Polygon | Polygon Amoy |
| Super Genius | Super Genius - TestNet |
| BNB | BNB TestNet |
| Base | Base - Sepolia |

As a horizontal chip strip they total roughly **1294px against about 350px of visible sheet width**,
about 3.7 screens. The current network is ordered **first**, so the answer to "which chain am I on"
costs no scrolling, and roughly two to three chips are reachable at rest - but the tenth network
takes about three horizontal swipes.

Half of that scrolling exists to reach networks most users will never select.

## Why it was not fixed in the same task

The honest fix is a **data** change, not a layout one: a mainnet/testnet field in `networks.json` so
the strip can show the 5 mainnets and tuck the 5 testnets behind a disclosure.

That field **does not exist**. The only alternative is inferring "testnet" from the name, and the
data above shows exactly why that is a guess that breaks silently: the marker is spelled four
different ways - `Sepolia`, `Amoy`, `- TestNet`, `TestNet`, `- Sepolia` - with and without a
separating hyphen, and `Ethereum Sepolia` carries no substring that a naive `contains('test')` would
catch. A network wrongly classified as a testnet disappears from the default strip.

## The fix

1. Add an explicit boolean (`"testnet": true`) to each entry in
   `assets/json/networks/networks.json`, and to the `Network` model in
   `packages/genius_api/lib/models/network.dart`.
2. Group the strip: mainnets at rest, testnets behind a disclosure. Keep current-first ordering,
   and keep the current network visible even when it is a testnet - a developer working on Sepolia
   must not have to expand a disclosure to see where they are.

## Where the strip lives

`lib/account/account_drawer.dart`, the `widget.networks.isNotEmpty` block in `_AccountDrawerBody`,
using `NetworkSelectChip` from `lib/network/network_dropdown_selector.dart`.
