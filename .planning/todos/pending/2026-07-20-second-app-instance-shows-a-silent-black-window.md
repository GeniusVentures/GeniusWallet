---
created: 2026-07-20T10:15:42.522Z
title: Second app instance shows a silent black window
area: general
files:
  - lib/main.dart:120
---

## Problem

Launching the app while another instance is already running produces a **fully black
window with no error, no log line, and no dialog**. Hive grants its container lock to the
first process; later processes hang before first paint and give the user nothing to go on.

Hit during the 05-01 human walk (2026-07-20) and it cost real debugging time — the black
window was initially mistaken for a rendering regression in the code under test. Three
instances were live at once:

| PID | Started | Source |
|-----|---------|--------|
| 27359 | 11:54 | `flutter run -d macos` (the walk) |
| 25786 | 11:50 | an earlier `gmac`, never quit |
| 788 | 10:17 | `/Applications/Genius Wallet.app` auto-started from macOS **login items** |

All three shared `~/Library/Containers/ai.gnus.GeniusWallet.jakub/`.

The login-item entry is the nasty part: it is installed silently as a side effect of
running the app, starts on every boot, and the user has no idea it is holding the lock.
It has been removed from this machine's login items, but it will come back for anyone
else who runs a desktop build.

**Second symptom, same cause:** CoinGecko returned HTTP 429 (`You've exceeded the Rate
Limit`) because each instance independently runs the finding-14 60-second market timer —
three instances is three times the request rate against the free tier. The app's own
handling was **correct**: it logged `Returning cached market data due to API failure` and
degraded to cache rather than crashing. No fix needed there.

## Solution

TBD. Options, cheapest first:

1. **Detect and tell the user.** Catch the Hive lock failure at
   `GWAppearance.instance.load()` / storage init (`lib/main.dart:120` is where startup
   storage work begins) and show "Genius Wallet is already running" instead of an empty
   window. Even a `debugPrint` would have saved the debugging time.
2. **Single-instance guard** on desktop — focus the existing window instead of opening a
   dead second one.
3. Worth a line in the run instructions either way: a black window on startup is far more
   likely a stale second instance than a rendering bug. This generalisation is already
   recorded in `05-01-SUMMARY.md`.
