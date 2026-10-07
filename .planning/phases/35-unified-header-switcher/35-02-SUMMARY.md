---
phase: 35-unified-header-switcher
plan: 02
subsystem: ui
tags: [flutter, bloc, wallet-safety, send, swap]
requires: [35-01]
provides: [GWCopyRow caption, SendTransactionDetails fromWalletName, Swap From-wallet line and Switch link]
affects: [35-03]
key-files:
  modified: [lib/components/data/gw_copy_row.dart, lib/reown/send_transaction_details.dart, lib/send/send_screen.dart, lib/squid_router/swap_screen.dart]
key-decisions:
  - "Send's fromWalletName is null unless the selected wallet's lowercased address equals the signing address"
  - "Swap's From line sits directly above the CTA, keeping the existing space4 gap"
requirements-completed: [SWT-05]
duration: 35min
completed: 2026-09-29
status: complete
---

# Phase 35 Plan 02: Wrong-account guard on Send and Swap

Send's review From row and Swap's submit button both name the wallet that will actually sign.

## Built
- `GWCopyRow` gained an optional `caption` line above the mono value; null/empty renders exactly as before and the clipboard write is untouched.
- `SendTransactionDetails` takes an optional `fromWalletName`, wired only from `send_screen.dart`; the Reown dApp drawer and dev tools bubble are untouched.
- Send names the wallet only when its address matches the signer, so a mid-review switch falls back to the address alone instead of naming the wrong wallet.
- Swap's `_SwapFromWallet` (via `context.select`) shows 'Sending from {name} · {short address}' (address alone when unnamed) plus a Switch link opening `AccountDrawer.show`; CTA and `_submitSwap` unchanged.

## Notes
- No deviations from plan.
- Swap's "CTA unchanged" behaviour is covered by an existing-shape assertion, since it needed no new code.

## Verification
- Full suite: 1958 passed / 5 skipped / 0 failed (1952 baseline + 6 new).
- `flutter analyze lib test`: 0 issues; `dart format`, `check_brace_style.sh`, `check_raw_colors.sh`: clean.
