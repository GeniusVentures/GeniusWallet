---
phase: 41-linux-in-app-webview
plan: 03
provides: [WebPageCloseButton, Web tab follows inAppWeb, no-WebKit fallback walked, clean quit walked]
affects: [41-04]
key-files:
  created: [test/web/web_page_close_button_test.dart]
  modified: [lib/web/web_view_linux.dart, lib/components/overlay/nav_destinations.dart, test/web/web_utils_test.dart]
status: complete
actuals: {tokens: 2800, tasks: 2, commits: 2}   # chars/4 over the 5 changed files' diffs
---
# Phase 41 Plan 03: Close control, Web tab rule, fallback walk

Linux pages opened from a link now have the close control Windows has, the Web tab appears only when WebKitGTK loaded, and a box without WebKit behaves as before.

Commits: 2ebcbe3d close control (+ 03-legal.png) / c5f419e3 Web tab rule (+ 03-web-tab.png, 03-no-webkit.png).

## Gates
- `flutter test`: rc 0, `+2563 ~6` (new: 4 close-button, 1 Web-tab). Analyze rc 0 ("No issues found"; one run took 150 s, a second flutter process was holding the lock), format rc 0, brace rc 0, raw-colour rc 0, ID gate 0 on both commits, no Co-Authored-By/Claude in the range.
- `includeBackButton` in web_view_linux.dart: 3; `Colors.white`: 0; mobile/linux diff: 79 changed lines (limit 90); `Platform.isLinux` in nav_destinations.dart: 0.
- Container build `BUILD_RC=0` (3 builds). All walks in gw041-u2404 (WebKitGTK 2.52.6) and gw041-nowebkit, throwaway profile, no gcr-prompter at any point.

## Walks
- 03-legal.png: Privacy Policy from onboarding Legal in-app, close control left of the omnibox. Click: back on Legal. News (reached through the shell nav shown over the page, no wallet needed): a CFTC article opens in-app with the control; click: back on News.
- 03-web-tab.png: Web tab present between News and Feedback; from News it opens the browser home (gnus.ai) with no close control (no includeBackButton).
- 03-no-webkit.png: nowebkit image (log: libwebkit2gtk-4.0.so.37 unavailable), nav has no Web tab; article tap leaves the app on News, no in-app page; Privacy Policy tap on Legal also stays put.
- Quit with a page open (Web tab home, WebKit run): WM_DELETE, container `exited 0 after 2s`, log has no abort/segfault/fatal. The no-WebKit run also exited 0 after 2 s.

## Deviations
- [Rule 1] Walk showed the close icon invisible in light mode: the chrome bar behind it is the fixed dark navy, so `textPrimary` (near-black in light) vanished. `WebPageCloseButton` now sits on the omnibox's own fill (`surfaceWell` + `borderSubtle`, 40 px), where `textPrimary` is correct in both modes. Windows' raw white is not used.
- Web-tab test cannot go red on a Windows box (both sides true); it only discriminates on Linux with WebKit, as the validation note intends.
- Shell nav is reachable without a wallet only over an open page; for the no-WebKit News walk a throwaway wallet (PIN 1234) was created in the container volume. Recovery-phrase captures were temp-only and deleted.
- Tracer gate: mode is not auto; walked end to end (legal and article paths) before the Web-tab task, per the spawning instruction.

## For 41-04
- Walk helpers: ctr2.sh now takes `IMG=` (nowebkit run: `IMG=gw041-nowebkit bash ctr2.sh`); close.sh for quit. Throwaway wallet: onboarding, PIN 1234 twice, tap the 4 missing words in slot order (Continue moves up once chips are gone).
- Checkout menu and dialogs over a page remain 41-04's (MenuAnchor/toasts not gated).

## Self-Check: PASSED
