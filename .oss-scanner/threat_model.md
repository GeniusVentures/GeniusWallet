# Anthropic OSS Scanner threat model — GeniusWallet

## What matters

GeniusWallet is a Flutter desktop/mobile wallet with token balances, hardware/native FFI bridges, transaction construction, local secure storage, network and swap providers, and GNUS.ai token flows. Public pinned submodules include `squidrouter`, `banxa`, and `tokeninfo`. The scanner should inspect the Dart app, local packages in `packages/`, native interop code, and the wallet's CMake bridge; it must not assume a UI check secures a raw API call.

## Untrusted inputs and invariants

- Treat RPC replies, transaction proposals, DApp/WalletConnect requests, signed payloads, QR/deep links, token lists, ENS-like names, bridge and swap quotes, and chain metadata as hostile.
- Never sign or broadcast a transaction whose actual recipient, value, calldata, chain, token, or permissions differ from what the user approved. Prevent chain and nonce replay.
- Reject malformed amounts, overflow/underflow, approvals to unexpected spenders, dangerous gas/slippage changes, and state changes after the signing prompt.
- Seed phrases, private keys, secrets, and session tokens must never appear in logs, analytics, crash data, screenshots, or network requests.
- Secure storage and FFI boundaries must not expose keys or allow arbitrary untrusted Dart-to-native pointers, sizes, or callback lifetimes.
- API/network failures, stale balances, incorrect provider chain choice, and mixed accounts must not present incorrect send capabilities or silently retry a payment.
- App links, webviews, external content, and transaction metadata must not trigger unapproved sign/send actions.

## Severity and reports

**Critical:** extracting signing keys, unauthorized signing/broadcast of funds, remote execution through untrusted input, or silent large-value transfer manipulation.

**High:** reliable recipient/amount/chain substitution, privilege bypass, leaked recovery data, replay or bypass of explicit transaction approval.

**Medium:** limited loss, stale state that misleads users, bounded denial of service, or disclosure of less-sensitive wallet metadata. **Low:** defensive improvements without a reachable attack.

For each finding, provide the actual malicious input, affected module and method, reproduction, security impact and small fix. Prefer tests for both valid and rejected transaction forms. Never publish exploit details.

## Running inside the offline scanner

The Dockerfile compiles the Dart/Flutter app bundle and caches pub packages/Flutter SDK under `/src` and `/opt/flutter`. Representative offline tests:

```bash
cd /src
flutter test --no-pub test/send/built_tx_matches_test.dart test/markets_sort_test.dart test/assets_totals_test.dart
```

These tests verify intended transfer recipient/amount checks, market ordering, and balance arithmetic. They do **not** prove a full AlmaLinux 8 Linux desktop binary: the native FFI/CMake/plugin build remains an independent test requirement. The native SuperGenius and GeniusSDK code is audited in its own upstream project.

## Restrictions

No live wallet accounts or seed phrases, remote RPC or broadcast tests, third-party sign-in, or production key access. Never run a signing test with real credentials or contact an external chain. Report reachable project-specific issues privately to `admin@gnus.ai`.
