---
phase: 41-linux-in-app-webview
plan: 02
provides: [opensInApp/inAppWeb, WebViewLinux, native focus hand-back, WebOverlayGate]
affects: [41-03, 41-04]
key-files:
  created: [lib/web/web_view_linux.dart, lib/web/web_overlay_gate.dart, test/web/web_utils_test.dart, test/web/web_overlay_gate_test.dart]
  modified: [lib/web/web_utils.dart, lib/web/web_view_screen.dart, lib/navigation/router.dart, third_party/.../linux/src/platform/flutter_view.cc, test/theme/status_text_color_invariant_test.dart]
status: complete
actuals: {tokens: 12000, tasks: 3, commits: 4}   # chars/4 over the 4 new files; web_view_linux.dart is a 771-line copy
---
# Phase 41 Plan 02: In-app page, focus hand-back, popup gate

A News article opens inside the Linux window; clicking the omnibox after the page had focus sends the keys to Flutter; drawers draw whole over a page that returns unchanged.

Commits: 69e01cc7 in-app decision + WebViewLinux / de7d1260 native focus fix (third_party only) / d3641142 WebOverlayGate / 4d68c707 census entry for the new lock icon.

## Gates
- `flutter test`: rc 0, `+2558 ~6` (new: 3 + 6 tests). Analyze rc 0 ("No issues found"), format rc 0, brace rc 0, raw-colour rc 0, ID gate 0 (also over the whole range).
- diff mobile/linux browser: 37 lines (limit 60); `launchWebSite(` 10, `launchUrl(` only in web_utils, checkout_screen, order_drawer_footer; channel/TLS/permission grep 0; `Platform.isLinux` in router 0; `button-press-event` grep 1; `WebOverlayGate.shellPopupRoutes` grep 1.
- Container build `BUILD_RC=0` each time (`--no-undefined` links). Walks ran in gw041-u2404 (WebKitGTK 2.52.6, libsoup3), throwaway profile, no gcr-prompter at any point, close via WM_DELETE exit 0.
- walk/02-article.png: a News card opens in the window with the browser chrome. 02-focus.png: example.com loaded from the omnibox; the pre-Return shot showed omnibox `example.com`, Wikipedia field `abcabc` (two runs of abc, none of example.com). 02-selector.png and 02-drawer.png: scrim and drawer whole, no page drawn through; after close the privacy page is back at the same scroll offset, not reloaded.

## Deviations
- [Rule 1] Focus: the plan's `button-press-event` hook never fired (log showed FlView consumes it; omnibox click left focus on WebKitWebView and typing went to the page). Listening on the generic `event` signal for GDK_BUTTON_PRESS fixed it; no Dart `releaseFocus` fallback was needed. The grep gate still counts 1 (the comment names the signal).
- [Rule 3] Copied browser carried five decision IDs in comments; stripped them (ID gate 0). Census test failed on the new lock-icon read; added the entry (26 files, 51 reads).
- 02-drawer.png shows the WalletConnect drawer (same ResponsiveDrawer), not Accounts: the profile had no wallet because the wallet created in the first run was not kept in the container volume, and the header pill is inert with no wallet.
- Tracer gate: mode is not auto, so the gate would hand a human-verify checkpoint; the slice was instead walked end to end (02-article.png) before any expansion task, per the spawning instruction.
- Evidence PNGs: 02-article in 69e01cc7; 02-focus, 02-drawer, 02-selector in d3641142 (so the focus commit touches only third_party).

## For later plans
- Walk helpers (scratchpad phase41/): `ctr2.sh` (24.04 container, keyring files kept, DISPLAY only for the wallet), `s.sh`/`w.sh` (lx wrapper), `sb2.sh` (sync+build), `close.sh`. Set window size first (`w size 1908 999`): layouts shift by a few px between runs. Create-wallet recovery-phrase shots must be deleted; legal screen opens a page without a wallet.
- Throwaway wallet does not persist across ctr2 runs; the Privacy Policy route gives a browser page and the full header with no wallet.
- No popup menu or dropdown is reachable over a page today; the widget test covers the shell navigator. MenuAnchor/toasts are not gated (checkout menu is 41-04's).
- `inAppWeb` is the one decision; 41-03 gates the Web tab/nav on it. Linux browser still ignores `includeBackButton` (41-03).

## Self-Check: PASSED
