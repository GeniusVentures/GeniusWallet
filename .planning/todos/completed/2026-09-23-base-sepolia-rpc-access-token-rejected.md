---
created: 2026-09-23T22:10:00.000Z
title: Base Sepolia's RPC rejects its access token, so the network cannot read or send
area: networks
severity: minor
files:
  - assets/json/networks/networks.json
---

## Problem

`networks.json`'s "Base - Sepolia" entry points at a Chainstack endpoint that answers every call with
"Access token missing or invalid. Make sure you are using the correct node endpoint." (checked with
`eth_chainId` on 2026-09-23). Balances never load and a send cannot be priced or broadcast there.

Ethereum Sepolia had the same kind of rot (its host stopped resolving) and was moved to
`https://ethereum-sepolia-rpc.publicnode.com` the same day.

## Fix direction

Either a fresh Chainstack key (a team decision: who owns the account) or a public Base Sepolia RPC
such as `https://base-sepolia-rpc.publicnode.com`, checked with `eth_chainId` returning `0x14a34`
(84532) before committing.
