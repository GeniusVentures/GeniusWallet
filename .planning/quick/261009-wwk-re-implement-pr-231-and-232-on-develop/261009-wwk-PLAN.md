---
quick_id: 261009-wwk
phase: quick-261009-wwk
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [WWK-01, WWK-02, WWK-03, WWK-04]
files_modified: [lib/dashboard/news/view/crypto_news_screen.dart, test/dashboard/crypto_news_digest_test.dart, lib/dashboard/transactions/transactions_screen.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/transactions/view/transactions_stream.dart, lib/dashboard/transactions/sgnus_transactions_screen.dart, test/dashboard/transaction_filters_test.dart, test/dashboard/transactions_page_frame_test.dart, test/dashboard/dashboard_section_caps_test.dart, test/dashboard/transaction_filter_rail_test.dart, test/dashboard/buy_orders_filter_test.dart, test/components/drawer_padding_invariant_test.dart, lib/components/inputs/gw_keyboard_done_bar.dart, test/components/gw_keyboard_done_bar_test.dart, lib/squid_router/swap_field.dart, lib/squid_router/swap_settings_drawer.dart, lib/dashboard/bridge/bridge_screen.dart, lib/screens/banxa_buy_screen.dart, lib/tokens/token_info_screen.dart, lib/settings/settings_screen.dart, lib/send/send_screen.dart, lib/child_wallets/child_operation_dialogs.dart, lib/components/scaffold/gw_page_header.dart, lib/squid_router/swap_screen.dart, test/components/gw_page_header_centered_test.dart, test/squid_router/swap_header_alignment_test.dart]

must_haves:
  truths:
    - "WWK-01: at phone width Crypto News shows one hero story, then ONE DashboardScrollContainer holding the search field, a story count and every other article as a 72px-thumbnail row; no 'Next up' band; no refresh glyph on a phone; desktop layout unchanged and still has its refresh glyph."
    - "WWK-02: at phone width the Transactions page has no filter chip row; a funnel in the page header (beside Buy GNUS) opens a ResponsiveDrawer listing All + all nine filters with live counts, Buy orders included and carrying its open-order pill; a live filter tints the funnel and shows a dismissible chip + 'N of M' above the list; /transactions?filter=purchase still opens on Buy orders; the dashboard panel and the wide rail behave as before."
    - "WWK-02: the phone Transactions page paints flat surfaceBase (no GWMeshBackground) and the 'No more transactions' terminus is gone."
    - "WWK-03: on iOS/Android every numeric-keyboard field (Swap, Bridge, Swap settings, Buy, token page, Settings, Send, child-wallet amount dialog) shows a floating Done bar while focused; tapping the tick or outside dismisses the keyboard; desktop renders the field untouched."
    - "WWK-04: the Swap settings glyph and the Buy page orders glyph sit on their title's centre line at the right edge, and neither header grows taller."
    - "Nothing is committed, staged or pushed; dart format, flutter analyze and the full flutter test suite are green with the count compared against a baseline taken on the untouched tree."
  artifacts:
    - lib/components/inputs/gw_keyboard_done_bar.dart
    - test/components/gw_keyboard_done_bar_test.dart
    - test/dashboard/crypto_news_digest_test.dart
    - test/squid_router/swap_header_alignment_test.dart
  key_links:
    - "TransactionsScreen._filter <-> TransactionsSlimView.selectedFilter/onFilterChanged (page is controlled, dashboard panel keeps its own state)"
    - "header funnel counts <-> list counts: both read the SAME scoping (SGNUS-only + Banxa order rows), or the drawer and the 'N of M' disagree (T-12-14)"
    - "GWPageHeader centered path <-> Swap + Buy triggers (48x32 so the title line stays 32 tall)"
---

<objective>
Re-implement on develop the user-facing changes of PRs #231 and #232, whose code merged into a side
branch and never reached develop. Re-implement, not cherry-pick: reference commits `843f78cb` (news
digest), `9820fb5f` (transactions filter drawer), `bf8a6b1f` (GWKeyboardDoneBar), `2190a07d` (swap
settings icon on the title line) are read-only references; ignore their `.planning/` changes.
Three independent tasks, no file shared between them.

Ledger (checked against develop 21b95130):
- PORT: News hero + digest; News refresh glyph desktop-only; Tx drop GWMeshBackground; Tx drop
  "No more transactions" terminus; keyboard bar component + its 14 tests.
- ADAPT: Tx funnel + drawer + live chip (keep Buy GNUS, `purchase` filter, open-order pill,
  `?filter=` routing); funnel 44x44 not 48x32 (Buy GNUS already makes the row 44); replace the
  "title level with Assets" test with "funnel does not change header height"; wrap the six original
  numeric sites by hand plus Send and child-wallet amount; centred header puts `trailing` on the
  title line with no new flag (only Swap and Buy use `centered`), both triggers 48x32.
- SKIP: deleting `_TransactionFilterBar`/`_FilterChip` (follow-up); Swap form clear (develop's
  `_applyOutcome` already clears after a real success); PR sketches/handoffs.

Rules: no commit, stage, stash, push or PR; no `git apply --index/--3way/--cached`. Do not edit
`banxa/`, `squidrouter/`, `tokeninfo/`, ROADMAP/STATE/MANIFEST; no `flutter run`. AGENTS.md applies
(braced ifs, widgets not helpers, tokens only, WCAG AA both themes, Rule of Three, no em dash in copy).

Pre-flight: `git submodule update --init`; `flutter pub get`; record the full-suite baseline
`+N ~S -F` on the untouched tree.
</objective>

<tasks>

<task type="auto">
  <name>Task 1: Crypto News phone digest (WWK-01, PORT)</name>
  <files>lib/dashboard/news/view/crypto_news_screen.dart, test/dashboard/crypto_news_digest_test.dart</files>
  <action>
Apply `git show 843f78cb -- <file> | git apply -` (re-implement by hand if it no longer applies).
Confirm: `_MetaLine` keeps `statusSuccessText`, `_NewsPhoto` keeps `surfaceWell`; narrow = hero then
`_NewsDigestPanel` (search, `GWKicker` count, `_NewsListRow` 72px rows); wide unchanged; refresh
IconButton desktop-only; 1px `_opticalNudge` on the stamp.
New test seeds the Hive news cache (no HTTP), uses `pump` not `pumpAndSettle`: 390x844 hero once,
other five titles in the panel, no "Next up", no Refresh tooltip; 1280 wide has the tooltip.
  </action>
  <verify>
    <automated>flutter test test/dashboard/crypto_news_digest_test.dart test/freeze_rule_test.dart test/news_article_short_time_test.dart</automated>
  </verify>
  <done>Phone News = hero + one digest panel; refresh glyph desktop only; tokens intact; tests green.</done>
</task>

<task type="auto">
  <name>Task 2: Transactions filter behind a header funnel (WWK-02, ADAPT)</name>
  <files>lib/dashboard/transactions/transactions_screen.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/transactions/view/transactions_stream.dart, lib/dashboard/transactions/sgnus_transactions_screen.dart, test/dashboard/transaction_filters_test.dart, test/dashboard/transactions_page_frame_test.dart, test/dashboard/dashboard_section_caps_test.dart, test/dashboard/transaction_filter_rail_test.dart, test/dashboard/buy_orders_filter_test.dart, test/components/drawer_padding_invariant_test.dart</files>
  <action>
Re-implement 9820fb5f by hand; keep develop's `onRefresh` body verbatim.
1. `TransactionsScreen` becomes stateful, owns `_filter` (seeded from `initialFilter`; a new
   non-null value switches it). Slim view takes optional `selectedFilter` + `onFilterChanged`
   (null = dashboard panel, unchanged); stream/SGNUS screens forward them.
2. One top-level `scopeTransactions` (SGNUS scoping, then order rows) read by list and funnel.
3. Header: LayoutBuilder, `wide = maxWidth >= GeniusBreakpoints.medium`; narrow trailing is Buy
   GNUS + funnel. `Scaffold(body: page)` at every width, no mesh.
4. `TransactionsFilterTrigger`: `Icons.filter_alt_outlined`, 44x44, live tint + brand dot, hidden on
   an empty scope.
5. Drawer: `ResponsiveDrawer.show` with Type/Status kickers, one `GWSelectRow` per filter with live
   count; Buy orders shows `_OpenCountPill` and reads `Buy orders, N open`. Add it to the drawer
   padding census.
6. Narrow body: no chip row; `_LiveFilterRow` (chip + `N of M`) above the list.
7. Delete `endOfTransactionsLabel` and the terminus.
8. Rewrite the listed tests against develop; measure funnel and chip contrast in both themes.
  </action>
  <verify>
    <automated>flutter test test/dashboard/transaction_filters_test.dart test/dashboard/transactions_page_frame_test.dart test/dashboard/dashboard_section_caps_test.dart test/dashboard/transaction_filter_rail_test.dart test/dashboard/buy_orders_filter_test.dart test/components/drawer_padding_invariant_test.dart test/banxa/buy_entry_points_test.dart test/freeze_rule_test.dart</automated>
  </verify>
  <done>Phone: funnel + Buy GNUS in header, drawer with live counts, live chip, flat canvas, no terminus. Wide page, panel and ?filter= unchanged.</done>
</task>

<task type="auto">
  <name>Task 3: Keyboard Done bar and title-line header glyphs (WWK-03 PORT/ADAPT, WWK-04 ADAPT)</name>
  <files>lib/components/inputs/gw_keyboard_done_bar.dart, test/components/gw_keyboard_done_bar_test.dart, lib/squid_router/swap_field.dart, lib/squid_router/swap_settings_drawer.dart, lib/dashboard/bridge/bridge_screen.dart, lib/screens/banxa_buy_screen.dart, lib/tokens/token_info_screen.dart, lib/settings/settings_screen.dart, lib/send/send_screen.dart, lib/child_wallets/child_operation_dialogs.dart, lib/components/scaffold/gw_page_header.dart, lib/squid_router/swap_screen.dart, test/components/gw_page_header_centered_test.dart, test/squid_router/swap_header_alignment_test.dart</files>
  <action>
A. Import the component and its test from bf8a6b1f unchanged; fix only what analyze reports.
B. Wrap each numeric field in `GWKeyboardDoneBar` by hand: swap_field (`enabled: isSelectingFrom`),
   bridge, swap settings slippage, Buy amount, token amount, settings (`enabled: isNumber`), Send
   amount, child-wallet amount. Then `grep numberWithOptions|TextInputType.number lib` lists only
   wrapped sites.
C. `GWPageHeader` centred path: title becomes `Stack(centerRight, [Center(title), trailing])`;
   outer whole-block Stack removed; non-centred tree identical; fix "(Swap, Feedback)" docs.
D. Swap `Icons.tune` and Buy `Icons.receipt_long_outlined`: 48x32 tight, zero padding, shrinkWrap.
E. Tests: centred header +2 (trailing on title centre line; 48x32 trailing does not grow header);
   port the swap header alignment test onto the current SwapScreen harness.
  </action>
  <verify>
    <automated>flutter test test/components/gw_keyboard_done_bar_test.dart test/components/gw_page_header_centered_test.dart test/squid_router test/swap test/send test/banxa test/child_wallets test/tokens test/logs test/dashboard/bridge</automated>
  </verify>
  <done>Bar on all eight numeric fields on touch platforms only; Swap and Buy glyphs on the title line, headers no taller; tests green.</done>
</task>

</tasks>

<threat_model>
| ID | Category | Component | Disposition | Mitigation |
|---|---|---|---|---|
| T-wwk-01 | Info disclosure | GWKeyboardDoneBar | mitigate | Holds only a FocusNode, never reads text; `check_no_new_key_logging.sh --scan-tree` stays 0. |
| T-wwk-02 | Tampering | `?filter=` | accept | `filterFromQuery` maps unknown names to null. |
| T-wwk-03 | Integrity | Swap form | accept | Submit logic untouched. |
</threat_model>

<verification>
1. `dart format` touched files; `dart format --output=none --set-exit-if-changed lib test` = 0.
2. `flutter analyze`: No issues found.
3. Full `flutter test`: zero new failures vs baseline; account for the delta by file.
4. `tool/check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree`,
   `check_onboarding_seed_safety.sh` all 0.
5. `git diff --cached --stat` empty.
</verification>

<output>
SUMMARY: per task port/adapt/skip, measured numbers, deviations, follow-ups. Do not commit it.
</output>
