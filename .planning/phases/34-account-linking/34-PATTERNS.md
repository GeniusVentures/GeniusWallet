# Phase 34: Account linking - Pattern Map

**Mapped:** 2026-09-29
**Files analyzed:** 6 (all modified, no new files — this phase edits existing files only)
**Analogs found:** 6 / 6 (all are self-analogs: the closest pattern for each edit lives in the same file, next to the code it extends)

## File Classification

| File to Modify | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `packages/local_secure_storage/lib/src/local_secure_storage_base.dart` | model/storage | CRUD (key-value) | itself — `saveSGNUSLinkedAddress`/`getSGNUSLinkedWalletPrivateKey` (lines 312-347) | exact |
| `packages/genius_api/lib/src/genius_api.dart` | service | event-driven (FFI + diff-and-persist) | itself — `_registerWallet` (302-332), `_initSDK` (206-286) | exact |
| `lib/bloc/app_bloc.dart` (`_mergeSgnusWallet`, five `_getSDKAccountState()` sites, `_onDeleteWallet`, `_onDeleteSDKAccount`) | controller/bloc | request-response (event -> state) | itself — the five identical copyWith blocks (699-838) | exact |
| `lib/bloc/app_state.dart` | model | CRUD (immutable state) | itself — `sdkAccounts`/`selectedSDKAccount`/`linkedSDKAccount` field triplet (80-187) | exact |
| `lib/account/sdk_account_manager.dart` (`_buildAccountRow`, add-account handlers) | component | request-response | itself — `_buildAccountRow` (169-286), `sdkRowActions` (608-617) | exact |
| `lib/account/account_drawer.dart` / `lib/components/wallet_information.dart` | component | request-response | `account_drawer.dart:_confirmDeleteWallet` (186-244) is the analog `wallet_information.dart`'s delete button must copy | role-match (one file is correct today, the other must be conformed to it) |

No new files are created in this phase — every edit extends an existing pattern in place, per RESEARCH.md's "Recommended Project Structure".

## Pattern Assignments

### `packages/local_secure_storage/lib/src/local_secure_storage_base.dart` — new link-map storage

**Analog:** the existing start-account key, same file, lines 22-24, 342-347.

**Key-declaration pattern** (lines 15-24):
```dart
class LocalWalletStorage {
  static const _pinKey = '__pin_key__';
  static const _watchesKeyPrefix = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';
  static const _accountKeyPrefix = '__account__';

  /// Address of the wallet the Genius SDK is initialised with. Must not
  /// contain [_walletKeyPrefix], or it would be read back as a wallet.
  static const _sgnusLinkedAddressKey = '__sgnus_linked_address__';
```
Add a new `static const` key for the link map next to this block, following the same
`__snake_case__` convention and the same doc-comment-explains-the-collision-risk style.

**Write pattern** (lines 340-347):
```dart
  /// Records the wallet the SDK was initialised with, so later starts reuse
  /// its key instead of adding another SDK account.
  Future<void> saveSGNUSLinkedAddress(String address) async {
    await _secureStorage.write(
      key: _sgnusLinkedAddressKey,
      value: address.toLowerCase(),
    );
  }
```
For the link map (sgnusAddress -> ethAddress), read-modify-write the whole map through
`jsonEncode`/`jsonDecode` (see `getAllWallets`'s use of `jsonDecode` at line 301 for the
project's existing JSON-in-secure-storage convention) — lowercase both keys and values,
matching this method's own `.toLowerCase()` call.

**Read pattern to mirror** (lines 312-323, `getSGNUSLinkedWalletPrivateKey`):
```dart
  Future<StoredKey?> getSGNUSLinkedWalletPrivateKey() async {
    final keys = await _secureStorage.readAll();
    for (final key in sgnusLinkCandidates(keys)) {
      final storedKey = StoredKey.importJson(keys[key]!);
      if (storedKey != null) {
        return storedKey;
      }
    }
    return null;
  }
```
`getSDKAccountLinks()` should follow this shape: read once via `_secureStorage.read(key: ...)`,
`jsonDecode` into `Map<String, String>`, return `{}` if absent — never throw on a missing key.

---

### `packages/genius_api/lib/src/genius_api.dart` — diff-and-persist link capture

**Analog:** itself, `_registerWallet` (302-332) — this is the one function RESEARCH.md
identifies as having both addresses in scope.

**Core pattern to extend** (lines 302-332):
```dart
  Future<void> _registerWallet(StoredKey storedKey) async {
    final wasAlreadyInitialized = _isSdkInitialized;

    await _secureStorage.saveStoredKey(storedKey);
    await _initSDK(storedKey);

    // If the SDK was already initialized, _initSDK returned early and did
    // NOT register this account on the SDK side. Register it now.
    if (wasAlreadyInitialized) {
      if (storedKey.isMnemonic()) {
        final mnemonic = storedKey.decryptMnemonic(Uint8List(0));
        if (mnemonic != null) {
          addAccountWithMnemonic(mnemonic);
        }
      } else {
        final privateKey = storedKey.privateKey(
          TWCoinType.TWCoinTypeEthereum,
          Uint8List(0),
        );
        if (privateKey != null) {
          final privateKeyAsStr = privateKey
              .data()
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join();
          addAccountWithPrivateKey(privateKeyAsStr);
        }
      }
    }

    await loadStoredWallets();
  }
```
Wrap this with a `before = getAvailableAccounts()` at entry and
`after = getAvailableAccounts()` right before `loadStoredWallets()`, then call
`_secureStorage.saveSDKAccountLink(newAddress, storedKey.account(0).address())` for a
single-element `after - before` diff — no new control-flow shape, same try/no-throw style as
`_initSDK`'s own link save (below).

**Error-handling pattern for the new save call** (lines 276-285, `_initSDK`):
```dart
    // Pinning the key the node now knows keeps later starts from adding an
    // SDK account each time readAll() happens to list another wallet first.
    try {
      await _secureStorage.saveSGNUSLinkedAddress(
        storedKey.account(0).address(),
      );
    } catch (_) {
      debugPrint('Failed to record the SDK-linked wallet');
    }
```
Copy this exact try/catch/debugPrint shape for the new link-save call — link persistence is
best-effort and must never fail the wallet import it rides on (D-06, D-07).

**New StoredKey-building method (D-01/D-02):** mirror `importWalletFromMnemonic`/
`importWalletFromPrivateKey` (genius_api.dart:704-737, cited in RESEARCH.md) — same
`StoredKey.importHDWallet`/`StoredKey.importPrivateKey` construction, then call
`_registerWallet(storedKey)` instead of duplicating the add-account FFI call directly.

---

### `lib/bloc/app_bloc.dart` — state distribution and relabeling

**Analog:** itself — the five identical `_getSDKAccountState()` + `copyWith` blocks (699-838)
are the shared pattern every new field must be threaded through.

**Repeated emit shape** (example at 695-708, identical at 747-763, 765-781, 783-799, 801-824,
826-838):
```dart
  FutureOr<void> _onSgnusConnectionChanged(
    SgnusConnectionChanged event,
    Emitter<AppState> emit,
  ) async {
    final sdkState = _getSDKAccountState();
    emit(
      state.copyWith(
        wallets: await _mergeSgnusWallet(),
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
        linkedSDKAccount: api.getStartAccountAddress(),
      ),
    );
  }
```
A new `sdkAccountLinks` field must be added to `copyWith` at every one of these six call
sites (RESEARCH.md's "all five `_getSDKAccountState()` call sites" plus `_onDeleteWallet`) —
read via a new `api.getSDKAccountLinks()` call alongside `api.getStartAccountAddress()`, same
line, same pattern.

**Label pattern to replace** (`_mergeSgnusWallet`, 710-733):
```dart
  Future<List<Wallet>> _mergeSgnusWallet() async {
    final connection = await api.getSGNUSConnectionStream().first;
    if (!connection.isConnected) {
      return _baseWallets;
    }

    final accounts = api.getAvailableAccounts();
    final sgnusWallets = accounts.asMap().entries.map((entry) {
      final index = entry.key;
      final address = entry.value;
      return Wallet(
        walletName: accounts.length == 1
            ? 'Super Genius Wallet'
            : 'Super Genius Wallet ${index + 1}',
        walletType: WalletType.sgnus,
        address: address,
        currencySymbol: 'minions',
        coinType: TWCoinType.TWCoinTypeEthereum,
        balance: 0,
      );
    }).toList();

    return [...sgnusWallets, ..._baseWallets];
  }
```
LINK-02 replaces the ternary `walletName` with a link-map lookup (wallet name if linked,
else `'Unlinked SDK account ${index + 1}'` per D-16) — same `.map()` shape, only the
`walletName:` expression changes.

**Delete-coupling analog** (`_onDeleteWallet`, 620-654, and `_onDeleteSDKAccount`, 801-824):
these are the two handlers D-08..D-11's shared rule extends. `_onDeleteSDKAccount`'s existing
start-account guard is the pattern to copy for D-11's "block if active wallet" guard:
```dart
    // The next start imports this account's key again, so deleting it would
    // silently bring it back.
    final start = api.getStartAccountAddress();
    if (start != null &&
        start.toLowerCase() == event.publicAddress.toLowerCase()) {
      return;
    }
```

---

### `lib/bloc/app_state.dart` — new `sdkAccountLinks` field

**Analog:** the `sdkAccounts`/`selectedSDKAccount`/`linkedSDKAccount` triplet, same file
(80-187) — a `Map<String,String>` field follows exactly the `sdkAccounts` (`List<String>`)
precedent for a collection field with a `const []`-equivalent default:

```dart
  /// All available SDK account addresses.
  final List<String> sdkAccounts;
```
Field declaration, constructor default (`this.sdkAccounts = const [],`), `copyWith` param
(`sdkAccounts ?? this.sdkAccounts`), and `props` entry must all be added in the same four
places for `sdkAccountLinks` (default `const {}`).

**D-20 rename note:** `linkedSDKAccount` here means "start-account" and is renamed per D-20's
reference list (occurs at lines 87, 111, 134, 158, 185) — do not confuse with the new field.

---

### `lib/account/sdk_account_manager.dart` — row relabel (D-17) and SDK-form add (D-01)

**Analog:** itself — `_buildAccountRow` (169-286) and `sdkRowActions` (608-617).

**Row layout to extend** (211-219 is the exact collision point RESEARCH.md's Pitfall 4
flags):
```dart
      title: WalletUtils.getAddressForDisplay(address),
      titleStyle: GeniusWalletTypography.bodySm.copyWith(
        fontFamily: GeniusWalletTypography.monoFamily,
        color: gw.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      subtitle: isSelected
          ? 'Active processing account'
          : (isStartAccount ? 'The app starts with this account' : null),
```
D-17 wants wallet name as title, address as subtitle — plan should decide (per Open
Question 1) where `'Active processing account'`/`'The app starts with this account'` move
(e.g. a trailing badge, following the row's existing `action: MenuAnchor(...)` trailing-slot
pattern already used for the overflow menu).

**Pure-function status pattern to extend for D-16's "Unlinked" surfacing** (608-617):
```dart
({bool payout, bool phrase, bool qr, bool delete}) sdkRowActions({
  required bool isSelected,
  required bool hasMnemonic,
  bool isStartAccount = false,
}) => (
  payout: isSelected,
  phrase: isSelected && hasMnemonic,
  qr: isSelected && hasMnemonic,
  delete: !isSelected && !isStartAccount,
);
```
A record-returning pure function is this file's established way to compute row-level
derived booleans — reuse this shape rather than inlining conditionals in the widget for any
new D-11 "delete blocked, active wallet" gate on this row.

---

### `lib/account/account_drawer.dart` vs `lib/components/wallet_information.dart` — D-12 delete unification

**Analog:** `account_drawer.dart:_confirmDeleteWallet` (186-244) is the CORRECT, already-fixed
pattern. `wallet_information.dart`'s `SlidingDrawerButton.onPressed` (229-259) is the ONE
file that must be rewritten to match it.

**Pattern to copy into `wallet_information.dart`** (`account_drawer.dart`, 186-244):
```dart
  Future<void> _confirmDeleteWallet(BuildContext context, Wallet wallet) async {
    final appBloc = context.read<AppBloc>();
    // Capture the ROOT navigator before closing the drawer: closing the drawer
    // deactivates `context`, so the dialog (pushed on the root navigator by
    // GWDialog.show) and its action pops must go through this stable
    // NavigatorState, not the now-defunct outer `context`.
    ...
    if (!AppBloc.canDeleteWallet(appBloc.state.wallets)) {
      showToast(
        navigator.context,
        'You must keep at least one wallet.',
        type: ToastType.warning,
        duration: const Duration(seconds: 2),
      );
      ...
    }
    ...
        DeleteWallet(
          wallet.address,
          watchOnly: wallet.walletType == WalletType.tracking,
        ),
      );
```

**Pattern to DELETE from `wallet_information.dart`** (229-250) — the direct-API-bypass:
```dart
                            SlidingDrawerButton(
                              onPressed: () {
                                geniusApi.deleteWallet(
                                  state.selectedWallet?.address ?? "",
                                  watchOnly:
                                      state.selectedWallet?.walletType ==
                                      WalletType.tracking,
                                );
                                showToast(
                                  context,
                                  'Wallet ${state.selectedWallet?.walletName ?? ""} deleted!',
                                );
                                Navigator.of(context).pop();
                                Future.delayed(
                                  const Duration(milliseconds: 100),
                                  () {
                                    // ignore: use_build_context_synchronously
                                    context.go('/dashboard');
                                  },
                                );
                              },
```
Replace the `onPressed` body with `context.read<AppBloc>().add(DeleteWallet(...))`, gated on
`AppBloc.canDeleteWallet`, same as `account_drawer.dart`'s call — drop the direct
`geniusApi.deleteWallet` call and the unconditional navigation.

**D-11 shared rule extension point:** `AppBloc.canDeleteWallet` (app_bloc.dart:609-610) is
where both paths converge; D-11's "block if this is the active wallet's linked SDK account"
guard belongs in `_onDeleteSDKAccount` (app_bloc.dart:801-824), following the existing
start-account guard shown above.

## Shared Patterns

### "Diff and persist" for link capture
**Source:** `genius_api.dart:_registerWallet` (302-332), combined with `_initSDK`'s
try/catch save (276-285).
**Apply to:** the new link-capture code in `_registerWallet`, and the D-13/D-14 backfill loop
(same diff idiom, looped over stored wallets).

### "Observe the list, don't trust the call" for completion signals
**Source:** `sdk_account_manager.dart:510-514` (used identically at 460-463 for delete).
```dart
final before = bloc.state.sdkAccounts.length;
final grew = bloc.stream
    .map((s) => s.sdkAccounts.length > before)
    .firstWhere((added) => added)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```
**Apply to:** any "SDK account pending" (D-06) UI feedback and the D-01 SDK-form add success
signal — never trust a synchronous FFI return value alone.

### Bloc state threading (five/six copyWith sites)
**Source:** `app_bloc.dart:695-838` — every SDK-account-affecting handler re-reads
`_getSDKAccountState()` and `api.getStartAccountAddress()` and re-emits the full tuple.
**Apply to:** every handler that must also emit the new `sdkAccountLinks` field —
`_onSgnusConnectionChanged`, `_onSelectSDKAccount`, `_onAddSDKAccountWithMnemonic`,
`_onAddSDKAccountWithPrivateKey`, `_onDeleteSDKAccount`, `_onRefreshSDKAccounts`,
`_onDeleteWallet`.

### `GWDialog.show<bool>` for destructive confirmations
**Source:** `account_drawer.dart:211-232`, identically `sdk_account_manager.dart:426-443`.
**Apply to:** D-10's new SDK-account-delete confirmation that names the wallet it will
remove.

## No Analog Found

None — every file in scope is an edit to existing, already-patterned code; RESEARCH.md's
"Recommended Project Structure" confirms no new directories or files are needed this phase.

## Metadata

**Analog search scope:** `packages/genius_api/`, `packages/local_secure_storage/`,
`lib/bloc/`, `lib/account/`, `lib/components/`
**Files scanned:** 6 (all files named in RESEARCH.md's "Recommended Project Structure")
**Pattern extraction date:** 2026-09-29
