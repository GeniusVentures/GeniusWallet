---
phase: 41-linux-in-app-webview
plan: 04
provides: [CheckoutWebViewLinux, CheckoutHostKind.linux, one camera/microphone rule, menu gate]
key-files:
  created: [lib/banxa/checkout/checkout_webview_linux.dart]
  modified: [lib/banxa/checkout/checkout_rules.dart, checkout_screen.dart, checkout_webview.dart, test/banxa/checkout_rules_test.dart, .planning/REQUIREMENTS.md]
status: complete
actuals: {tokens: 5100, tasks: 3, commits: 4}   # chars/4 over the diff of lib, test, REQUIREMENTS.md
---
# Phase 41 Plan 04: Banxa checkout in the Linux window

On Linux with WebKitGTK, Banxa checkout renders in the Windows dialog under the same URL rules, one shared camera/microphone rule, and the menu and dialogs draw whole over it.

Commits: 2facff0c checkout host + Linux kind (+ 04-checkout.png) / 9c7b3244 shared rule refactor / 44a8a062 Linux permission handler / f51baed2 menu gate + BUY-07 (+ 04-menu.png, 04-no-webkit.png).

## Gates
- `flutter test`: rc 0, `+2566 ~6` (was 2563). Analyze rc 0 ("No issues found") after each commit, format rc 0, brace rc 0, raw-colour rc 0, ID gate 0 on every commit, key-logging scan of lib/banxa rc 0.
- `git grep GW_SPIKE -- lib` 0; `git status --porcelain lib/screens` empty; `Platform.isLinux` in checkout_screen 0; `print(` in the Linux host 0; `ponytail` there 0; `git stash list` still holds "phase-41 spike wallet changes". No Co-Authored-By or Claude text in the range.
- checkout_webview_windows.dart not touched (last commit c1b54c91). checkout_screen_test.dart unchanged and green.
- Rule callers: checkout_rules.dart (Windows), checkout_webview.dart (mobile), checkout_webview_linux.dart.

## Walks (gw041-u2404, WebKitGTK 2.52.6, throwaway profile, no prompter)
- Painted-while-hidden question: the spinner path works. The view sits behind `WebOverlayGate(hidden: _loading)`, WebKitGTK still finishes loading unpainted, and Banxa's page replaced the spinner (04-checkout.png: "Hello." order-less sandbox page). No painted-from-start fallback needed.
- 04-menu.png: More menu whole, no page drawn; closing it brought the page back without a reload. The Pay-on-another-device drawer and the Leave checkout dialog were both whole over a hidden page; Keep paying brought the page back. Window close with checkout open: container exit 0 after 2 s, no abort.
- 04-no-webkit.png: gw041-nowebkit shows "Finish paying in your browser".
- Nothing typed into Banxa; no account made. Recovery-phrase captures from the throwaway wallet were temp-only and deleted.

## Deviations
- Walk reach: the container has no wallet, so /buy was unreachable. Walk-only edits to router, splash and banxa_buy_screen (redirect the landing screen to /buy, stop the splash re-navigating) were applied to the working tree and reverted; none are in a commit. Patch kept in scratchpad phase41/walk-hook.patch.
- Window must be 1400x650 here: the WSLg screen cuts a taller window and the dialog bottom was off view.
- The Linux permission handler has no automated test (no real WebViewController in tests); the rule itself is covered, and no Banxa page was driven to ask for the camera.

## For the verifier and the final Windows/Android walk
- Mobile (checkout_webview.dart) and Windows (windowsCheckoutPermission) hosts were refactored onto the shared rule and NOT walked; unit tests cover every Windows kind on and off a Banxa page and the mobile type names. Walk a camera/ID check on Android and Windows.
- Offstage on the checkout body is linux-only; confirm no visible change on Windows and mobile (More menu, spinner).
- Manual rows still open: keyed sandbox order, real camera and microphone on Linux, Ubuntu 24.04 native, first linux_arm CI run. WebKitGTK 2.38 (20.04) has no getUserMedia, so ID capture needs "Open in browser" there.
- Square bottom corners of the Linux dialog around the page are accepted.

## Self-Check: PASSED
