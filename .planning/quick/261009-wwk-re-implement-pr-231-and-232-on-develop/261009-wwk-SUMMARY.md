---
quick_id: 261009-wwk
phase: quick-261009-wwk
plan: 01
subsystem: dashboard / transactions / news / swap / inputs
tags: [re-implementation, pr-231, pr-232, news-digest, transactions-filter, keyboard-done-bar, page-header]
status: complete
requirements: [WWK-01, WWK-02, WWK-03, WWK-04]
key-files:
  created: [lib/components/inputs/gw_keyboard_done_bar.dart, test/components/gw_keyboard_done_bar_test.dart, test/dashboard/crypto_news_digest_test.dart, test/squid_router/swap_header_alignment_test.dart]
  modified: [lib/dashboard/news/view/crypto_news_screen.dart, lib/dashboard/transactions/transactions_screen.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/transactions/view/transactions_stream.dart, lib/dashboard/transactions/sgnus_transactions_screen.dart, lib/components/scaffold/gw_page_header.dart, lib/squid_router/swap_screen.dart, lib/squid_router/swap_field.dart, lib/squid_router/swap_settings_drawer.dart, lib/dashboard/bridge/bridge_screen.dart, lib/screens/banxa_buy_screen.dart, lib/tokens/token_info_screen.dart, lib/settings/settings_screen.dart, lib/send/send_screen.dart, lib/child_wallets/child_operation_dialogs.dart, test/dashboard/transaction_filters_test.dart, test/dashboard/transactions_page_frame_test.dart, test/dashboard/dashboard_section_caps_test.dart, test/dashboard/transaction_filter_rail_test.dart, test/dashboard/buy_orders_filter_test.dart, test/components/drawer_padding_invariant_test.dart, test/components/gw_page_header_centered_test.dart]
---

# Quick 261009-wwk: Re-implement PR #231 and #232 on develop

**Task 1, News (PORT):** 843f78cb applied cleanly; `statusSuccessText`/`surfaceWell` kept. Phone = hero + one digest panel, no Next up, no Refresh glyph; desktop unchanged. New digest test, 2 cases.

**Task 2, Transactions (ADAPT):** screen owns the filter; slim view takes `selectedFilter`/`onFilterChanged`. One `scopeTransactions` feeds list and funnel. 44x44 funnel beside Buy GNUS opens a drawer with live counts and the Buy orders pill. Live chip + `N of M`; flat canvas; terminus removed. Header stays 60 with or without the funnel. Contrast on `surfaceBase`: funnel 7.60/4.76:1, chip label 19.43/14.02:1 (dark/light).

**Task 3, Keyboard bar + header (PORT + ADAPT):** component and 14 tests imported unchanged, all pass. Wrapped at 8 numeric sites. Centred header puts `trailing` on the title line, no new flag; Swap and Buy glyphs 48x32. Centred header +2 tests (mutation-checked); swap header alignment test ported, 4 green.

**Deviations:** `openBuyOrderCount` added beside `scopeTransactions` so header and view share the `!isFinal` test. The funnel reads SGNUS rows via `getSGNUSTransactionsController().stream` so existing fakes keep working.

**Verification:** baseline `+2505 ~6 -2`, after `+2524 ~6 -2`. The 2 failures are pre-existing (`send_screen_test.dart`, 12px overflow at `recipient_field.dart:87`). Format 0 changed; analyze no issues; brace, raw-colour, key-logging, onboarding and agent-rules checks all 0. Nothing staged.

**Follow-ups:** delete the dead `_TransactionFilterBar`/`_FilterChip` arm in `_panel`. The Transactions title sits 6px below Assets because of Buy GNUS (pre-existing). Fix the two send test failures. A third 48x32 trigger would justify a shared widget.
