# Phase 31: Send native coins and ERC-20 tokens — context

Decided with Braian on 2026-09-23. Nothing called Send exists at any layer today.

## Locked decisions

- **D-01 Scope:** native coin and ERC-20 tokens on every chain where `canSignOn(network)` holds.
  SGNUS (`GeniusApi.transferTokens`) is out; it has no hash, a different store and an unknown unit.
- **D-02 Entry points:** a Send CTA on the coin page next to Swap/Receive, with the coin preselected,
  plus a Send action on the dashboard that opens with a coin picker.
- **D-03 Shape:** a `/send` screen inside the ShellRoute, built like `/swap` (an `extra` map carrying
  symbol + chainId). Not a drawer: a keyboard form in a bottom drawer is cramped on a phone.
- **D-04 Safety in v1:** EVM address validation, a warning when the recipient is the wallet's own
  address, and a warning when the recipient has code on-chain (`eth_getCode`). No address-poisoning
  check and no PIN re-entry in this phase.
- **D-05 History model first:** `Transaction.coinSymbol` is the only unit today, so a token send is
  mislabelled whichever symbol it is filed under. Plan 1 adds the asset-vs-chain split as a new Hive
  field, keeps old rows readable, and makes the explorer link and fee row use the chain. This also
  closes the receipt-unit item phase 30 deferred.

## Proposed plans

1. History model: the asset/chain split, reads of old rows, explorer link and fee row from the chain.
2. Send service in `genius_api`: build native and ERC-20 transfers, EIP-1559 fee estimate, exact raw
   balances (MAX on a native coin subtracts the fee), sign through the existing
   `signAndSendTransaction`, bounded receipt polling. Unit-tested with no UI.
3. Send form: `SendCubit` (form state only, never a key), coin picker, recipient with paste and QR
   scan (`mobile_scanner` is already a dependency, no scanner widget exists), amount with MAX,
   the two warnings.
4. Confirm and submit: drawer body reusing `SendTransactionDetails`, a pending history row, the
   result, both entry points; the coin-page test that asserts no Send button changes.

## What exists to reuse (verified 2026-09-23)

- `GeniusApi.signAndSendTransaction` — the one signing path; the key never leaves the API package.
  It does no estimating: missing gas and fee fields default to `0x0`.
- `Web3.abi` already has ERC-20 `transfer`; `Web3.approve` is a template for a `transfer` call.
- `summarizeTransaction` / `tryDecodeErc20Transfer` in `calldata_decoder.dart` — decode the built
  transaction back as a self-check that it says what the form said.
- `SendTransactionDetails` renders a native send or a token transfer already.
- `isEvmAddress` (regex, no EIP-55), `GWTextField` with a suffix slot, the swap form's MAX chip.

## Gaps this phase has to fill

- No EIP-1559 fee estimate anywhere; the bridge uses legacy `gasPrice`.
- No on-chain receipt polling anywhere. Swap polls Squid, and the dApp path writes `completed` at once.
- `Coin.balance` is a `double`; the conversion to wei needs an exact raw read, not
  `double * pow(10, decimals)`.
- No QR scanner widget.
