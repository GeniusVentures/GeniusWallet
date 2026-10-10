# Handoff: re-implementing PR #231 and #232 on develop (2026-10-09/10)

## Why
PRs #231 and #232 merged on 2026-08-10 into `redesign/assets-boxed-panels-260808`, which had
already landed on develop through #230. None of their 6 commits reached develop. By October the
old branch was 809 commits behind with 8 conflicting files. Jakub (after consulting a fellow
developer) chose option 3: re-implement on current code, old commits as reference only.

## Where
- Worktree: `/Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232`
- Branch: `redesign/reimpl-231-232-261009`, cut from origin/develop `21b95130` (latest at start)
- Quick task: `.planning/quick/261009-wwk-re-implement-pr-231-and-232-on-develop/` (PLAN + SUMMARY)
- **Nothing committed, staged or pushed. No PR.** Waiting on Jakub's go-ahead.

## What landed (working tree)
- News: phone feed is hero + one digest panel; refresh glyph desktop-only. Ported as is.
- Transactions: filter moved from the chip row to a header funnel + drawer next to Buy GNUS;
  filter state lives in `TransactionsScreen`; counts share `scopeTransactions`. Adapted.
- `GWKeyboardDoneBar`: ported, wired to 8 numeric fields (Swap, Bridge, Swap settings, Buy,
  token page, Settings, plus new since August: Send and the child-wallet amount dialog).
- Centred `GWPageHeader`: trailing sits on the title line (Swap tune icon, Buy orders glyph).
- Skipped: Swap form reset after swap. Develop's `_applyOutcome` already does it.

## Verification (run by the orchestrator, not only the executor)
- `flutter analyze`: No issues found.
- `flutter test`: `+2524 ~6 -2` (baseline `+2505 ~6 -2`).
- The 2 failures are in `test/send/send_screen_test.dart` (12px overflow at
  `recipient_field.dart:87`) and fail identically with develop's untouched `send_screen.dart`.

## Next
1. Jakub reviews; ideally a walk on iPhone (Done bar, transactions drawer, news digest).
2. On go-ahead: commit (probably 3 commits, one per area), push, open PR to `develop`.
3. Follow-ups: delete dead `_TransactionFilterBar`/`_FilterChip`; fix the 2 Send test failures
   separately; Buy GNUS puts the Transactions title 6px below Assets (pre-existing).
