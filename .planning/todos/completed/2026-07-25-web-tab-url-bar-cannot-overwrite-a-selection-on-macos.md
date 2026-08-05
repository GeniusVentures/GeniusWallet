---
created: 2026-07-25T11:51:00.947Z
resolved: 2026-07-25T21:40:00.000Z
title: Web tab URL bar cannot overwrite a selection (macOS)
area: ui
files:
  - lib/web/web_view_mobile.dart
  - test/web/url_bar_focus_remount_test.dart
---

## Outcome

RESOLVED 2026-07-25. **The root cause recorded below was wrong, and so was the
symptom's framing.** Nothing about text input, WKWebView or selection replace was
involved.

## Actual root cause

`_buildOmniboxCenter` wrapped the field in `Container(decoration: editing ? BoxDecoration(...) : null)`.
`Container` inserts a `DecoratedBox` **only when `decoration` is non-null**, so focusing
the bar changed the SHAPE of the widget tree. Flutter could not match the existing
child against the new `DecoratedBox`, so it unmounted and rebuilt the entire subtree —
disposing the just-focused `EditableText` one frame after `_handleFocusChanged` had
consumed the focus node's single keyboard token (`FocusNode.consumeKeyboardToken`,
focus_manager.dart:978; the token is granted only inside `_doRequestFocus`, and only
once per focus request).

The replacement `EditableText` therefore had focus but **no text-input connection**, and
`_openInputConnection` is only ever reached from the focus-change listener — which does
not fire, because focus did not change. On macOS every text-editing operation, arrow keys
included, is routed through that connection (see the doc comment above
`_shouldCreateInputConnection`, editable_text.dart:2594-2599), so every key returned
unhandled and AppKit beeped.

Blurring and re-focusing granted a fresh token to the new state, which is exactly why
"the second time it works".

## Fix

`web_view_mobile.dart` — the decoration is now unconditional; only the border colour
changes (`Colors.transparent` at rest). Tree shape is constant, the `EditableText`
survives focus, the connection stays open. Select-all-on-focus was restored to the
platform default, so the omnibox now behaves like a browser: one click selects the whole
URL and typing replaces it. The `selection = TextSelection.collapsed(...)` workaround was
deleted — it never took effect anyway, because `EditableText._defaultSelectAllOnFocus` is
true on macOS and its focus listener runs after the app's.

Guard: `test/web/url_bar_focus_remount_test.dart` (2 tests, both passing). The second one
pins the trap itself by reproducing the remount.

## How the wrong diagnosis survived three attempts

All three earlier attempts (sync select-all, post-frame select-all, collapsed caret)
changed selection timing, because the symptom was read as "cannot replace a selection".
The evidence that broke it open: a `HardwareKeyboard` probe showed key events reaching
Flutter with `primaryFocus` correctly on the URL bar, `onChanged` never firing, and
**arrow keys not moving the caret** — arrow keys have nothing to do with selection
replace, which killed the theory outright.

Also disproven: the "macOS-only, Windows uses WebView2 so it cannot reproduce" note. The
defect is platform-independent tree-shape handling; only the *beep* is macOS. Whether
Windows shows it depends on the platform's text-input path, not on WebView2.

Verified live by Jakub on macOS: first click selects the whole URL, typing replaces it.
`flutter analyze lib` = 59, unchanged.
