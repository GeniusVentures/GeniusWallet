---
phase: 31-send-native-coins-and-erc-20-tokens
plan: 02
status: complete
requirements: [SEND-02, SEND-04, SEND-06, SEND-07]
key-files:
  created: [packages/genius_api/lib/web3/send_service.dart, lib/send/send_cubit.dart, lib/send/send_screen.dart, test/send/send_service_test.dart, test/send/send_cubit_test.dart, test/send/send_screen_test.dart]
  modified: [packages/genius_api/lib/src/genius_api.dart, lib/navigation/router.dart, test/components/drawer_padding_invariant_test.dart]
actuals: { tokens: 16200, tasks: 4, commits: 5 }
---

# Phase 31 Plan 02: native send, form to resolved history

A `/send` screen sends a chain's native coin end to end: `SendCubit` prices
the send through a new `genius_api` service (EIP-1559 fee with a legacy
fallback, bounded receipt poll), opens a review drawer showing the fee in
the gas coin, signs through the existing `signAndSendTransaction`, and
writes a pending-then-resolved history row under one hash.

## Baseline vs. after (measured)

`flutter test`: 1599 pass/5 skip -> 1633 pass/5 skip, exit 0 (+34, all new).
`flutter analyze`: "No issues found!" at root and in `packages/genius_api`,
before and after. `dart format --set-exit-if-changed lib test` (plus the
two touched genius_api files): exit 0. `check_brace_style.sh`,
`check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree`,
`check_onboarding_seed_safety.sh`, `check_agent_rules_sync.sh`: exit 0.
Every new file's `git ls-files --eol` shows lf.

## Deviations

None from the plan's own task text. This plan's frontmatter lists
SEND-06/SEND-07 (entry points, coin-page CTA) but its own tasks and
`files_modified` never touch `token_info_screen.dart` or a dashboard
action -- 31-CONTEXT.md's four-plan sketch placed those in a later plan, so
`/send` ships reachable only by route/test until that plan lands.

## Self-Check: PASSED
