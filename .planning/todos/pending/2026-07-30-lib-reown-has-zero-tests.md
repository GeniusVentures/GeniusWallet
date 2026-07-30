# `lib/reown/` has zero tests — 1,444 lines of dApp connection and transaction approval

**Created:** 2026-07-30, while bumping `reown_walletkit` 1.3.9 → 1.4.0 (`3017f9f`).
**Area:** testing / security
**Severity:** no regression net on a money path

## The gap

There is no `test/reown/` directory. Nothing in the 726-test suite touches `lib/reown/` at all:

| File | LOC |
|---|---|
| `lib/reown/reown_connect_button.dart` | 675 |
| `lib/reown/handle_dapp_requests.dart` | 253 |
| `lib/reown/send_transaction_details.dart` | 131 |
| `lib/reown/approve_dapp_connection_drawer.dart` | 125 |
| `lib/reown/swap_result_drawer.dart` | 107 |
| `lib/reown/approve_transaction_drawer.dart` | 105 |
| `lib/reown/reown_walletkit_instance.dart` | 32 |
| `lib/reown/utilities.dart` | 16 |

`approve_transaction_drawer.dart` and `handle_dapp_requests.dart` are the surfaces where a remote
dApp asks this wallet to sign something. They are the highest-stakes code in the app and the least
covered.

## Why it matters now

The 1.4.0 bump was verified by `flutter analyze` (0), the full suite (726/726), four gate scripts,
a clean Windows launch, and **a manual pairing test by the developer**. Only the last of those
touched Reown. The automated signal for this dependency is exactly zero, so every future bump costs
a human session or ships unverified.

## What a floor looks like

Not full coverage — a floor. Enough that a breaking change in the pairing/session API fails a test
instead of a walk:

- `WalletKitInstance.initOnce()` is idempotent — a second call returns the same in-flight future and
  does not re-init (`reown_walletkit_instance.dart:22-31`). Cheap, pure, no network.
- The approval drawers render their request details for a synthetic session-request payload, and the
  reject path returns a rejection rather than silently closing.
- `handle_dapp_requests.dart`'s method dispatch maps each supported RPC method to its handler, with an
  unknown method rejected rather than ignored.

Prior art for a no-network approach to a hard dependency: `test/account/account_drawer_show_test.dart`
uses hive_ce's in-memory backend (`Hive.openBox(name, bytes: Uint8List(0))`) to avoid real I/O
entirely rather than trying to mock around it.

## Related

- `3017f9f` — the 1.4.0 bump this was found under
- `0bde805` — removed two WalletConnect pairing-URI console logs (the URI carries a `symKey`);
  a test asserting no key material reaches logs would belong in this same floor
- SCR-06 in `.planning/REQUIREMENTS.md` — dApp connectivity, still pending, notes an arch-based skip
  that killed WalletConnect on x64 desktop (not present in `lib/reown/` today, re-checked 2026-07-30)
