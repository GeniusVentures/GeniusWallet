# Phase 10: dApp connectivity - Context

**Gathered:** 2026-09-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Reown/WalletConnect pairing wears the redesign end to end, recovers from a failed WalletKit start,
and is proven to pair on x64 Windows. Requirement SCR-06; ROADMAP criteria 1-4.

**Measured on `develop` @ e100e435 before planning — do not re-fix what already holds:**
- Criteria 2 and 3 already hold in code. Findings 3 and 20 (`.planning/reference/REVIEW_FINDINGS_REDESIGN.md`)
  describe the abandoned redesign branch, not `develop`: there is no `Platform.version` arch skip, and
  `maybeInitWalletKit()` (`lib/reown/reown_connect_button.dart:210`) is develop's Completer guard.
  They only need proof (D-07), not code.
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

### Claude's Discretion
- The drawer's exact layout, spacing and copy, within the redesign drawer rules.
- How `initOnce()` is made testable (injected init function vs. a seam), keeping the diff small.

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
- `WalletKitInstance` is a singleton shared by the button and `web_view_windows.dart`.

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
