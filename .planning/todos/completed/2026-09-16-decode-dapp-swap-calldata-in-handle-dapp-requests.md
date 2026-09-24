---
created: 2026-09-16T00:00:00.000Z
title: Decode dApp swap calldata in handle_dapp_requests (kill blind signing)
area: reown
priority: high
resolves_phase: 30
files:
  - lib/reown/handle_dapp_requests.dart
  - lib/reown/send_transaction_details.dart
  - lib/reown/approve_transaction_drawer.dart
---

## Problem

The Reown/WalletConnect path — the only **real** swap execution path shipped today —
**blind-signs**. When a dApp sends `eth_sendTransaction`,
`handle_dapp_requests.dart` shows raw from/to/value/gas and never decodes `tx['data']`:

```dart
// todo parse the data to get token swap information
// no built in help.. might need to build manually :(
//final data = (tx['data']);
```
(`handle_dapp_requests.dart:44-46`)

The approval drawer therefore cannot tell the user *"you are swapping X for Y"* — only that
*something* is being sent to a contract for some gas. That is a security defect (the user
cannot meaningfully consent) as much as a UX one, and it stays true regardless of the
2026-09-16 decision to wire Squid for the in-app tab: Reown remains the path for any
dApp-initiated swap.

## Solution

Decode swap calldata well enough to describe the transaction in human terms in
`SendTransactionDetails` / `ApproveTransactionDrawer`:

1. Decode the common primitives first: ERC-20 `transfer` / `transferFrom` / `approve`
   (method-id + ABI-packed args) — this alone covers token moves and router allowances.
2. For known router selectors (Squid/AggregatedRouter, 0x, UniversalRouter — start with
   whichever the companion dApp actually uses), decode enough of the call to extract the
   swap pair and amounts for the drawer's summary line.
3. Anything undecodable degrades honestly: label it as an unknown contract call with a
   visible warning, never as a plain "send".

Note: there is no built-in decoder in `reown_walletkit` (per the original TODO's complaint),
so this is manual ABI decoding — small, testable pure-Dart logic.

## Closed 2026-09-24

Shipped in phase 30, PR #235 (merge 3afe7578), extended in b44c9e99: ERC-20 transfer/approve and the Squid router input side decode; anything else is labelled an unknown call with a visible warning. DAP-02's destination side was accepted as a partial at v2.0 close. `transferFrom` is not decoded but falls to the warned unknown-call path, so nothing is blind-signed.
