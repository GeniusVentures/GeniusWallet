---
phase: 10-dapp-connectivity
plan: 04
status: complete
requirements: [SCR-06]
completed: 2026-09-26
---

# 10-04: gates and the live Windows x64 pairing walk

First dApp pairing ever recorded on desktop. Walked with Braian on Windows 11 x64 (AMD64).

## Gates (tip 94d7aee9, before the walk fixes)
- `flutter analyze`: `No issues found!`, exit 0
- `flutter test`: `+1837 ~5: All tests passed!`
- `check_brace_style.sh`, `check_raw_colors.sh`: exit 0
- `git ls-files --eol`: `i/lf` for pair_dapp_drawer.dart, its test, walletkit_init_test.dart
- `dart format --set-exit-if-changed`: only `packages/local_secure_storage/lib/src/local_secure_storage_base.dart`
  differs, and it already did before this phase (see deferred-items.md)

## Walk
1. Log: `✅ WalletKit initialized`, no MissingPluginException. Drawer opens on paste, QR, Cancel: **pass**
   after two fixes found on the walk: QR was left-aligned (62b574f0), footer buttons too tall (6ef06466, lg→md).
2. Paired react-app.walletconnect.com via pasted link, approved: chip Disconnect, log `✅ Connected to React App`: **pass**
3. personal_sign approved, dApp shows the signature: **pass**
4. Disconnect: **pass**
5. Light mode: chip, drawer, QR, buttons, `hello` error line all legible: **pass**
6. Web tab clipboard with a broken wc: link: exactly one toast, no repeat in 10 s: **pass**
7. Offline relaunch: balances failed (eth.drpc.org errors) but `✅ WalletKit initialized` still logged: the SDK
   swallows relay errors at startup, so init did not fail offline. Braian reported the step as passing; no
   restart toast was observed. Criterion 4's fail-then-retry path is carried by the unit test from plan 02.
8. `grep -c symKey`: 0 in the online log, 0 in the offline log; `wc:` links: 0: **pass**

## Carried
- Android flutter_secure_storage v9→v10 upgrade walk: after merge, on the CI develop APK (D-09).
- Approve-connection drawer still uses 56px buttons; the pairing drawer now uses 48px.
