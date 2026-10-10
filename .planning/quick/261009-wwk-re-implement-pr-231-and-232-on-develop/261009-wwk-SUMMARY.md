---
quick_id: 261009-wwk
phase: quick-261009-wwk
plan: 01
subsystem: dashboard / transactions / news / swap / inputs
tags: [re-implementation, pr-231, pr-232, news-digest, transactions-filter, keyboard-done-bar, page-header]
status: complete
requirements: [WWK-01, WWK-02, WWK-03, WWK-04]
key-files:
  created:
    - lib/components/inputs/gw_keyboard_done_bar.dart
    - test/components/gw_keyboard_done_bar_test.dart
    - test/dashboard/crypto_news_digest_test.dart
    - test/squid_router/swap_header_alignment_test.dart
  modified:
    - lib/dashboard/news/view/crypto_news_screen.dart
    - lib/dashboard/transactions/transactions_screen.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/dashboard/transactions/view/transactions_stream.dart
    - lib/dashboard/transactions/sgnus_transactions_screen.dart
    - lib/components/scaffold/gw_page_header.dart
    - lib/squid_router/swap_screen.dart
    - lib/squid_router/swap_field.dart
    - lib/squid_router/swap_settings_drawer.dart
    - lib/dashboard/bridge/bridge_screen.dart
    - lib/screens/banxa_buy_screen.dart
    - lib/tokens/token_info_screen.dart
    - lib/settings/settings_screen.dart
    - lib/send/send_screen.dart
    - lib/child_wallets/child_operation_dialogs.dart
    - test/dashboard/transaction_filters_test.dart
    - test/dashboard/transactions_page_frame_test.dart
    - test/dashboard/dashboard_section_caps_test.dart
    - test/dashboard/transaction_filter_rail_test.dart
    - test/dashboard/buy_orders_filter_test.dart
    - test/components/drawer_padding_invariant_test.dart
    - test/components/gw_page_header_centered_test.dart
---

# Quick 261009-wwk: Re-implement PR #231 and #232 on develop (summary)

Nothing is committed, staged or pushed. Every change is an unstaged working-tree edit in
`/Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232` (`git diff --cached --stat` is empty).
Submodules were checked out with `git submodule update --init` (content only).

## Per-task outcome

### Task 1 - Crypto News digest (WWK-01): PORT

- `git show 843f78cb -- lib/dashboard/news/view/crypto_news_screen.dart | git apply -` applied cleanly.
- September tokens survived: `statusSuccessText` (2 uses, `_MetaLine`) and `surfaceWell`
  (`_NewsPhoto` placeholder and error fills; the new 72px thumbnail reuses `_NewsPhoto`, so it
  takes the same well). No `Colors.*` other than `Colors.transparent`.
- Phone: hero, then one `DashboardScrollContainer` (search field, story count, every other
  article as a 72px-thumbnail `_NewsListRow`); no "Next up"; no Refresh glyph. Desktop keeps the
  band and the Refresh glyph.
- New `test/dashboard/crypto_news_digest_test.dart` (2 tests, cache seeded through Hive, no HTTP):
  390x844 hero once and the other five titles inside the single panel, no "Next up", no
  "Refresh" tooltip; 1280 wide has the Refresh tooltip. Green, with `freeze_rule_test` and
  `news_article_short_time_test`.

### Task 2 - Transactions filter in the header (WWK-02): ADAPT

All four lib files re-written by hand on develop's versions (plain apply fails on all four).
Kept: Buy GNUS in the header, the `purchase` (Buy orders) filter with order rows, the open-order
pill, `OrdersStatus` loading/error empty states, develop's `onRefresh` body verbatim,
`?filter=` routing.

- `TransactionsScreen` is now a `StatefulWidget` owning `_filter`
  (`initialFilter` seeds it; `didUpdateWidget` applies the same "new non-null value switches"
  rule the slim view used to). `TransactionsSlimView` takes optional `selectedFilter` +
  `onFilterChanged` (null = uncontrolled = dashboard panel, call sites unchanged);
  `TransactionsStream` / `SgnusTransactionsScreen` forward them. All `setState(selectedFilter=)`
  now go through `_selectFilter`.
- One scoping, two readers: top-level `scopeTransactions(...)` (SGNUS-only scoping, then order
  rows appended) is called by the state getter and by the header's private `_FilterTrigger`
  (which maps orders with `orderAsTransaction`); `openBuyOrderCount(...)` shares the
  `!isFinal` test. Drawer counts and "N of M" cannot disagree (T-12-14).
- Header: `LayoutBuilder`, `wide >= GeniusBreakpoints.medium` (same test `_page` makes). Wide:
  Buy GNUS only. Narrow: `Row(Buy GNUS, space4, funnel)`. `GWMeshBackground` and `compact`
  dropped; `Scaffold(body: page)` at every width.
- `TransactionsFilterTrigger` (public): `Icons.filter_alt_outlined`, 22px glyph, tight
  **44x44** (adapted from 48x32, see ledger), tooltip `Filter transactions` / `Filtered: <label>`,
  live tint `brandPrimaryOnSurface` + 8px `brandCta` dot with a 1.5px `surfaceBase` ring,
  `SizedBox.shrink()` on an empty scope.
- Drawer: `ResponsiveDrawer.show(title: 'Filter', bodyPadding: zero)` over a `ListView`
  (`kDrawerBodyPadding`): Type kicker, All + `Filters.primary` (includes Buy orders) +
  `overflowTypes`, Status kicker, `overflowStatuses`; `GWSelectRow` each with badge glyph 21,
  live count, check on selected; Buy orders with open orders shows `_OpenCountPill` as
  `titleTrailing` and reads `Buy orders, N open` to a screen reader. Added to the
  `drawer_padding_invariant_test` census.
- Narrow body: chip row deleted; one `DashboardScrollContainer` holding `_LiveFilterRow`
  (only when scoped is non-empty and filter is not All: `_LiveFilterChip` + `N of M` kicker)
  then `_body(...)`. `chipSize`/`touchChipSize` folded back to a fixed 32.
- `endOfTransactionsLabel` constant and the terminus removed (grep over non-comment lines = 0).
- Kept (SKIP, per ledger): `_TransactionFilterBar` / `_FilterChip`, still referenced by the dead
  page arm of `_panel`; the `_panel` doc comment now says so.
- Tests: `transaction_filters_test` (old "bar fits" group replaced by a 10-test phone control
  group: empty wallet no funnel, funnel 44x44, drawer lists All + nine filters incl. Buy orders,
  picking filters and the chip names it in dark and light, chip clears without opening anything,
  filtered-empty keeps both ways out, dashboard panel shows View all and no filter, contrast);
  `transactions_page_frame_test` (44px chip test replaced by "flat canvas, no mesh" and
  "the funnel does not change the header's height"; the phone page now `pumpAndSettle`s);
  `dashboard_section_caps_test` (terminus tests folded into cap tests, plus a no-terminus
  assertion); `buy_orders_filter_test` (chip/More-menu tests became drawer tests: Buy orders is a
  drawer row, picking it filters, pill + `Buy orders, 2 open` semantics, no pill when nothing is
  open; `initialFilter:` became `selectedFilter:`); `transaction_filter_rail_test` and the drawer
  census applied cleanly from the reference diff.
- Measured: page header = Buy GNUS 44 + space8 16 = 60, identical with and without the funnel.
  Contrast on `surfaceBase`: funnel glyph / chip edge (`brandPrimaryOnSurface`) 7.60:1 dark,
  4.76:1 light (needs 3:1); chip label (`textPrimary`) 19.43:1 dark, 14.02:1 light (needs 4.5:1);
  idle funnel (`textSecondary`) 6.01:1 dark, 4.75:1 light.

### Task 3 - Keyboard Done bar + centred-header glyphs (WWK-03 / WWK-04): PORT + ADAPT

- A. `gw_keyboard_done_bar.dart` and its 14 tests imported from `bf8a6b1f` unchanged; they
  compiled as is and all 14 pass, including `a chevron with nowhere to go is disabled to a
  screen reader` (it did not show the order dependency PR #232 reported). 94% fill alpha and
  contrast table untouched.
- B. Explicit `GWKeyboardDoneBar(child: ...)` at all 8 numeric sites: `swap_field.dart`
  (`enabled: isSelectingFrom`, so read-only You Receive is not a stop), `bridge_screen.dart`,
  `swap_settings_drawer.dart`, `banxa_buy_screen.dart`, `token_info_screen.dart`,
  `settings_screen.dart` (hoisted `isNumber`, `enabled: isNumber`), `send_screen.dart`,
  `child_operation_dialogs.dart`. `grep numberWithOptions|TextInputType.number lib` lists only
  wrapped files.
- C. `GWPageHeader` centred path: when `trailing` is present the title becomes
  `Stack(centerRight, [Center(titleText), trailing])` and the outer whole-block Stack is gone.
  No new parameter. Non-centred tree unchanged. Stale "(Swap, Feedback)" docs fixed to
  "Swap and Buy" in two places; `centered` doc now states the 22px finding and the
  "trailing no taller than 32" obligation.
- D. Swap `Icons.tune` and Buy `Icons.receipt_long_outlined` IconButtons: `padding: zero`,
  `BoxConstraints.tightFor(width: 48, height: 32)`, `VisualDensity.standard`,
  `tapTargetSize: shrinkWrap`, inline at both sites (Rule of Three). Buy keeps its `Buy orders`
  tooltip and `context.go('/transactions?filter=purchase')`.
- E. `gw_page_header_centered_test` +2 (trailing on the title's centre line; a 48x32 trailing does
  not grow the header). Mutation check: with the old `gw_page_header.dart` the first new test
  fails, with the new one it passes. `swap_header_alignment_test` ported with the current
  `SwapScreen` harness (swapAvailable + empty provider + seeded wallet/network): phone and
  desktop "centred title and subtitle, glyph on the title line", "same Y as the Assets title"
  (holds on develop, title top = 24 in both), and the 360/390/430/767 "title yields rather than
  overflowing" band. All 4 green.

## Port / adapt / skip ledger result

As planned, with these notes: News PORT; Tx filter ADAPT (44x44 funnel; the "title level with
Assets" test replaced by "funnel does not change the header height"); keyboard bar PORT +
8 ADAPTed sites; centred header ADAPTed without the `trailingOnTitleLine` flag; Swap form clear
SKIPPED (develop's `_applyOutcome` already clears after a real success); `.planning` sketches
and handoffs SKIPPED.

## Deviations from Plan

None that changed scope. Small implementation notes:

- `scopeTransactions` takes `orderRows` as a required `Iterable<Transaction>` (the plan said
  "inputs: transactions, sgnus-only flag, order rows"); `openBuyOrderCount` was added as a
  second tiny top-level function so the header and the view share the `!isFinal` test.
- The header funnel reads SGNUS rows with `getSGNUSTransactionsController().stream` (the same
  source `SgnusTransactionsScreen` listens to) rather than `getSGNUSTransactionsStream()`, so
  existing test fakes that override only the controller keep working.
- The wide-page and dashboard-panel behaviour is covered by the existing rail/panel tests, which
  pass unchanged except the documented rename.

## Verification (real output)

Baseline, untouched tree (before any edit, same worktree):

```
03:19 +2505 ~6 -2: Some tests failed.
```

Two pre-existing failures, both in `test/send/send_screen_test.dart`
(`the review drawer fits a short screen with large text, and Send in its footer still signs` and
`Review stays reachable on a short screen with large text and the keyboard up`): a 12px
RenderFlex overflow in `lib/send/recipient_field.dart:87`.

After all three tasks:

```
02:44 +2524 ~6 -2: Some tests failed.
```

Same two failures, same names, same 12px overflow in `recipient_field.dart:87`
(re-run alone: `+24 -2`). **Zero new failures; +19 passing tests** (new files: 2 news + 14 bar +
4 swap header = 20; +2 centred header; frame/caps/buy-orders/filters regrouped, net -3).
Skipped count unchanged at 6.

- `dart format lib test`: `Formatted 520 files (0 changed)`; `--set-exit-if-changed` exit 0.
- `flutter analyze`: `No issues found! (ran in 11.3s)`.
- `tool/check_brace_style.sh` 0, `tool/check_raw_colors.sh` 0,
  `tool/check_no_new_key_logging.sh --scan-tree` 0, `tool/check_onboarding_seed_safety.sh` 0
  ("PASSED -- all seven checks"), `tool/check_agent_rules_sync.sh` 0 ("PASS").
- `git diff --cached --stat`: empty. Nothing committed or staged.

## Follow-ups

- Dead code: `_TransactionFilterBar` and `_FilterChip` are only referenced from a dead arm in
  `_panel`; deleting the arm removes both (separate design decision, kept per PR #231).
- Transactions title sits 6px lower than Assets' because Buy GNUS (44) sets the header row since
  phase 39; pre-existing, not caused here.
- The filter drawer is full-height on phones, as every `ResponsiveDrawer` is (app-wide).
- The two `send_screen_test.dart` failures (recipient field overflow at large text) need their
  own fix; unrelated to this task.
- `swap_screen.dart` and the Buy page run the 48x32 trigger inline twice; a third occurrence
  would earn a shared widget.

## Self-Check: PASSED

- Created files exist: `gw_keyboard_done_bar.dart`, `gw_keyboard_done_bar_test.dart`,
  `crypto_news_digest_test.dart`, `swap_header_alignment_test.dart`.
- No commits were made by design (user override), so no commit hashes to verify.
