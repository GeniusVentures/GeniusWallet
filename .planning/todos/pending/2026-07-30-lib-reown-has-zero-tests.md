# `lib/reown/` is mostly untested — the approval drawers are now covered, the rest is not

**Created:** 2026-07-30, while bumping `reown_walletkit` 1.3.9 → 1.4.0 (`3017f9f`).
**Updated:** 2026-07-30 — **partly closed by 21-04.**
**Area:** testing / security
**Severity:** reduced — the signing surfaces have a contract test; the request pipeline does not

## Partly closed

Plan 21-04 created `test/reown/approve_drawer_contract_test.dart`, the first test this directory has
ever had. It asserts approve / reject / dismiss on both the desktop panel and mobile sheet branches
for `approve_transaction_drawer.dart` and `approve_dapp_connection_drawer.dart`.

It earned its keep on the first run: writing it caught a live `Incorrect use of ParentDataWidget`
that the re-skin had just introduced — deleting a zero-inset `Padding` also removed the `Column` that
gave a pre-existing `Flexible` its Flex ancestor (`ListView.children` is a sliver list, not a Flex).
On a signing drawer with no golden baseline, nothing else we run would have seen it.

**Still uncovered**, and this is the part that matters most:
`handle_dapp_requests.dart` (253 LOC) — the method dispatch that decides which RPC request reaches
which handler — and `reown_connect_button.dart` (675 LOC), the pairing surface. A remote dApp reaches
those before it ever reaches a drawer.

## The original gap

There was no `test/reown/` directory at all. Nothing in the then-726-test suite touched `lib/reown/`:

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

- ~~The approval drawers render their request details and the reject path returns a rejection rather
  than silently closing.~~ **DONE — 21-04, `test/reown/approve_drawer_contract_test.dart`.**
- `WalletKitInstance.initOnce()` is idempotent — a second call returns the same in-flight future and
  does not re-init (`reown_walletkit_instance.dart:22-31`). Cheap, pure, no network. **Still open.**
- `handle_dapp_requests.dart`'s method dispatch maps each supported RPC method to its handler, with an
  unknown method rejected rather than ignored. **Still open, and the highest-value one remaining** —
  it is the gate every dApp request passes through before any drawer is shown.

## Also still true

`lib/reown/` is NOT covered by `tool/check_raw_colors.sh`. Three known raw-colour offenders remain in
`handle_dapp_requests.dart` and `reown_connect_button.dart`; 21-03 deliberately did not widen the
gate to that directory because those files were outside every plan's fence. So a green raw-colour
gate does not mean this directory is clean.

Prior art for a no-network approach to a hard dependency: `test/account/account_drawer_show_test.dart`
uses hive_ce's in-memory backend (`Hive.openBox(name, bytes: Uint8List(0))`) to avoid real I/O
entirely rather than trying to mock around it.

## Related

- `3017f9f` — the 1.4.0 bump this was found under
- `0bde805` — removed two WalletConnect pairing-URI console logs (the URI carries a `symKey`);
  a test asserting no key material reaches logs would belong in this same floor
- SCR-06 in `.planning/REQUIREMENTS.md` — dApp connectivity, still pending, notes an arch-based skip
  that killed WalletConnect on x64 desktop (not present in `lib/reown/` today, re-checked 2026-07-30)
