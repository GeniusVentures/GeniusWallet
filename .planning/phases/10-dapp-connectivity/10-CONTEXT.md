# Phase 10: dApp connectivity - Context

**Gathered:** 2026-09-26
**Status:** Ready for planning
**Revised:** 2026-09-26: criterion 2 corrected, D-08 added

<domain>
## Phase Boundary

Reown/WalletConnect pairing starts on desktop, wears the redesign end to end, recovers from a failed
WalletKit start, and is proven to pair on x64 Windows. Requirement SCR-06; ROADMAP criteria 1-4.

**Measured on `develop` @ e100e435 before planning — do not re-fix what already holds:**
- Criterion 2 does NOT hold, for a reason findings 3 and 20 never named. WalletKit never initializes on
  any desktop (live on Windows 2026-09-26: `MissingPluginException(No implementation found for method
  initialize on channel walletconnect_pay)`).
  - Since reown_walletkit 1.4.0 (commit 3017f9f3), `init()` ends with an unconditional `pay.init()`.
  - `walletconnect_pay` ships native code for android/ios only, and its channel catches only
    PlatformException.
  - `pay` is a `late final` set inside init(), so a retry after that failure throws
    LateInitializationError. D-04's retry alone would fail forever on desktop.
  - The arch skip of finding 3 is gone, and no upstream fix exists (walletkit 1.5.1 is unchanged).
    D-08 is the fix.
- Criterion 3 holds in code: `maybeInitWalletKit()` (`lib/reown/reown_connect_button.dart:210`) is
  develop's Completer guard, not finding 20's branch. It needs proof (D-07), not code.
- Criterion 4 is half true: the "Please restart the app" toast exists (`:244-256`), but the retry is
  fake. `WalletKitInstance.initOnce()` caches a FAILED future forever, and the button's
  `_initCompleter` is never reset after a failure, so a second Connect press never re-runs init.
- Criterion 1 is half true: the navbar chip (sketch 043 4A) and the approve-connection drawer are
  already redesigned. The pairing dialog (`:272`, raw `AlertDialog`/`TextField`/`OutlinedButton`/
  `FilledButton`) is the one pre-redesign surface left.

</domain>

<decisions>
## Implementation Decisions

### Pairing surface
- **D-01:** The QR / paste-a-`wc:`-link dialog becomes a `ResponsiveDrawer` (bottom sheet on phone,
  side drawer on desktop), the same container as `approve_dapp_connection_drawer.dart` that follows it,
  so the connect flow reads as one surface. Contents use `GWTextField` and `GWButton`.
- **D-02:** Keep today's first view: desktop opens on the paste field, phone opens on the QR, with the
  existing toggle between them. Cancel still resets `_isConnecting`.
- **D-03:** The QR keeps its fixed white quiet zone (scannability, not style). The pairing URI carries a
  symKey: it is never logged and never placed in a toast or error message.

### Failed-init recovery
- **D-04:** Each Connect press genuinely retries WalletKit startup once. Fix the root cause in the
  shared `WalletKitInstance.initOnce()` (drop the cached future when it fails) and reset the button's
  `_initCompleter` on failure, so both callers (navbar button and the browser's clipboard pairing) recover.
  Concurrent presses still initialize exactly once (criterion 3).
- **D-05:** If that retry also fails, show the existing "WalletKit failed to initialize. Please restart
  the app." toast and put the chip in its error state ("Retry Connect").

### In-app browser clipboard pairing
- **D-06:** When `_pairWalletConnectFromClipboard` (`lib/web/web_view_windows.dart:63`) fails, show the
  shared error toast (e.g. "Couldn't connect to the dApp. Try again."). Keep logging only
  `e.runtimeType`; never the URI or the exception text (`Uri.parse` echoes its input).

### Proof
- **D-07:** One unit test for the init logic: a failed start is retried on the next call, and two
  concurrent calls start WalletKit once. Plus one live walk on this Windows x64 machine: pair
  `react-app.walletconnect.com`, approve the session, sign a `personal_sign`, disconnect.

### Desktop startup
- **D-08:** On Windows, macOS and Linux (not web, not android/ios), replace
  `WalletconnectPayPlatform.instance` before WalletKit init.
  - The replacement is a no-op: `initialize` returns success and every other method throws
    `UnsupportedError`. The app uses nothing from Pay.
  - Bump reown_walletkit to ^1.5.1 to get reown_core 1.5.1's Windows relay fix. genius_api's `^1.3.2`
    already admits it.
  - Make `walletconnect_pay` a direct dependency only if `depend_on_referenced_packages` requires it,
    pinned to the locked version.
  - Mark the override with a `ponytail:` comment: it relies on a public but unexported platform-interface
    file; remove it once Reown guards pay.init on unsupported platforms. No upstream issue.
  - One unit test: on a desktop target the override is installed and `initialize` succeeds; on
    android/ios it is not installed.
- *Found while planning D-08 (facts, not decisions):*
  - `depend_on_referenced_packages` is on, so the direct dependency is needed.
  - reown_core 1.4.0 and later require `flutter_secure_storage ^10`. The wallet key store
    (`packages/local_secure_storage`) pins `^9.2.4`, so the bump also upgrades the key store.
  - On Android that upgrade is one-way: v10 re-encrypts the data on first read, and `resetOnError`
    defaults to true, which erases everything on a read error.
  - The bump is still needed here: reown_core 1.5.1 fixes relay connectivity when the Windows version
    string has double quotes, and this machine's does (`"Windows 11 Pro" 10.0 (Build 26200)`).
  - Plan 01 therefore gates the bump behind a decision.

- **D-09:** Take the reown_walletkit ^1.5.1 bump now (plan option-a), guarded: the key store sets `resetOnError: false` and `migrateWithBackup: true`, and the Windows key store file is backed up before the first v10 launch. The Android v9 to v10 upgrade is walked after this phase merges to develop, using the CI-published `Android-develop-Release` APK on the GW_Test emulator: a wallet made on the previous develop build must still open after installing the new one over it. Not a pre-merge gate. — **Reversibility:** one-way — v10 re-encrypts Android secure storage on first read and cannot go back to v9.
### Claude's Discretion
- The drawer's exact layout, spacing and copy, within the redesign drawer rules.
- How `initOnce()` is made testable (injected init function vs. a seam), keeping the diff small.
- Where the Pay stub is installed. Chosen: first in the `WalletKitInstance` singleton's constructor,
  which runs before either caller's init.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Findings and requirement
- `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` §[3], §[20] — the original findings; they describe the old branch, see Phase Boundary
- `.planning/REQUIREMENTS.md` — SCR-06
- `.planning/ROADMAP.md` "### Phase 10" — success criteria 1-4

### Code
- `lib/reown/reown_connect_button.dart` — navbar chip, `maybeInitWalletKit`, `_connect`, the pairing dialog to replace
- `lib/reown/reown_walletkit_instance.dart` — `initOnce()`, the shared root cause for D-04
- `lib/reown/approve_dapp_connection_drawer.dart` — the drawer pattern D-01 matches
- `lib/web/web_view_windows.dart` — clipboard pairing (D-06)
- `lib/components/bottom_drawer/responsive_drawer.dart`, `lib/components/inputs/gw_text_field.dart`, `lib/components/buttons/gw_button.dart`, `lib/components/toast/toast_manager.dart`
- `packages/local_secure_storage/lib/src/local_secure_storage_base.dart:34`: the key store's AndroidOptions (D-08 bump)
- `.planning/reference/FRESH-INSTALL-RECIPE.md`: where the Windows key store file lives

### Desktop startup (D-08), pub cache `C:\Users\User\AppData\Local\Pub\Cache\hosted\pub.dev\`
- `reown_walletkit-1.4.0/lib/walletkit_impl.dart:111-131`: init order; `late final WalletConnectPay pay` at :53. 1.5.1 is identical (https://pub.dev/api/archives/reown_walletkit-1.5.1.tar.gz)
- `walletconnect_pay-1.0.0/lib/walletconnect_pay_platform_interface.dart`: the public `instance` setter; a replacement must `extends` it to pass the token check. Identical in 1.1.0
- `walletconnect_pay-1.0.0/lib/walletconnect_pay_method_channel.dart`: catches only PlatformException
- `walletconnect_pay-1.0.0/lib/walletconnect_pay_impl.dart`: `init()` reads the platform instance at call time
- https://pub.dev/packages/reown_core/changelog: 1.4.0 moves to flutter_secure_storage ^10; 1.5.1 fixes the Windows relay

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ResponsiveDrawer.show<T>()`: already used by the approve-connection drawer.
- `showToast(context, msg, type: ToastType.error)`: the one notification call used everywhere.
- `GWTextField`, `GWButton`, `context.gw` tokens: replace the raw Material widgets in the dialog.

### Established Patterns
- Secrets never reach logs: the pairing URI code already logs only `runtimeType`.
- `test/reown/` holds the existing dApp tests (approve drawer contract, calldata, requests); the new init test goes there.

### Integration Points
- `ReownConnectButton` is mounted once, from `lib/components/overlay/responsive_overlay.dart:71`.
- `WalletKitInstance` is a singleton shared by the button and `web_view_windows.dart`. Its constructor
  runs before any init, which makes it the one place to install the Pay stub (D-08).

</code_context>

<specifics>
## Specific Ideas

- The test dApp for the live walk is `react-app.walletconnect.com`.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope. The pending todos matched by keyword (type scale, Banxa
orders page, desktop top-bar overflow, etc.) are unrelated to dApp connectivity and were not folded.

</deferred>

---

*Phase: 10-dapp-connectivity*
*Context gathered: 2026-09-26*
