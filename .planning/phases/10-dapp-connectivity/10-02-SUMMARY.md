---
phase: 10-dapp-connectivity
plan: 02
subsystem: dapp-connectivity
tags: [reown, walletkit, retry, clipboard-pairing, toast]
requires: [10-01]
provides: [WalletKitInstance.initOnce retry-after-failure, WalletKitInstance.withInit test seam]
affects: [10-03, 10-04]
actuals: {tokens: 1875, tasks: 2, commits: 4}
tech-stack:
  patterns: ["late final field with an inline initializer, short-circuited by ?? so a test seam never builds the real SDK client"]
key-files:
  modified: [lib/reown/reown_walletkit_instance.dart, lib/reown/reown_connect_button.dart, lib/web/web_view_windows.dart, test/reown/walletkit_init_test.dart]
key-decisions:
  - "initOnce() attaches future.catchError(...).ignore() to forget only a still-current failed future, so callers still get the original error"
requirements-completed: [SCR-06]
duration: 40min
completed: 2026-09-26
status: complete
---

# Phase 10 Plan 02: WalletKit Retry + Clipboard Toast Summary

**A failed WalletKit start is forgotten so the next Connect press (or clipboard pair) genuinely retries, and a failed clipboard pairing now tells the user once instead of silently repeating.**

## Accomplishments
- `initOnce()` drops its cached future once it fails, while concurrent callers still share one in-flight start. New `@visibleForTesting WalletKitInstance.withInit()` seam injects a fake init without ever building the real SDK client.
- `maybeInitWalletKit` nulls `_initCompleter` on failure so the next press re-runs init; `_connect` attaches session listeners right after a (possibly late) successful init.
- `_pairWalletConnectFromClipboard` shows one error toast on failure (logs only `e.runtimeType`), and always clears the clipboard in `finally` so the 2-second poller stops re-toasting the same link.
- New TDD group in `walletkit_init_test.dart` pins retry-after-failure (RED against unfixed code, GREEN after), single-start-under-concurrency, and no-repeat-on-success.

## Task Commits
1. Task 1 (tracer/TDD): `35ed9ea6` (RED), `e0e070ee` (GREEN)
2. Task 2: `c922a848`
## Deviations from Plan
- `ad903d42` (coordinator-requested): dropped a `(D-04)` decision-id citation from a source comment per AGENTS.md; grepped `lib/reown/`, `lib/web/`, `test/reown/` for other IDs added this plan — none found.

## Verification
`flutter test` full suite: `+1819 ~5: All tests passed!`. `flutter analyze` on the 4 plan files: no issues, exit=0.
`dart format --set-exit-if-changed`: 0 changed. Brace/raw-colors/key-logging gates: all exit=0. Test file EOL: `i/lf`.
