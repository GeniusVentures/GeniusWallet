---
quick_id: 261009-wwk
phase: quick-261009-wwk
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [WWK-01, WWK-02, WWK-03, WWK-04]
files_modified:
  - lib/dashboard/news/view/crypto_news_screen.dart
  - test/dashboard/crypto_news_digest_test.dart
  - lib/dashboard/transactions/transactions_screen.dart
  - lib/dashboard/home/widgets/transactions_slim_view.dart
  - lib/dashboard/transactions/view/transactions_stream.dart
  - lib/dashboard/transactions/sgnus_transactions_screen.dart
  - test/dashboard/transaction_filters_test.dart
  - test/dashboard/transactions_page_frame_test.dart
  - test/dashboard/dashboard_section_caps_test.dart
  - test/dashboard/transaction_filter_rail_test.dart
  - test/dashboard/buy_orders_filter_test.dart
  - test/components/drawer_padding_invariant_test.dart
  - lib/components/inputs/gw_keyboard_done_bar.dart
  - test/components/gw_keyboard_done_bar_test.dart
  - lib/squid_router/swap_field.dart
  - lib/squid_router/swap_settings_drawer.dart
  - lib/dashboard/bridge/bridge_screen.dart
  - lib/screens/banxa_buy_screen.dart
  - lib/tokens/token_info_screen.dart
  - lib/settings/settings_screen.dart
  - lib/send/send_screen.dart
  - lib/child_wallets/child_operation_dialogs.dart
  - lib/components/scaffold/gw_page_header.dart
  - lib/squid_router/swap_screen.dart
  - test/components/gw_page_header_centered_test.dart
  - test/squid_router/swap_header_alignment_test.dart

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
Re-implement on current develop the user-facing changes of PRs #231 and #232. Their code was merged
into a side branch that had already landed, so it never reached develop; that branch is 809 commits
behind and conflicts in 8 files. Jakub chose RE-IMPLEMENT over cherry-pick: the four reference
commits are reference only, and every change is adapted to the code as it stands today.

Purpose: two phone surfaces still show their desktop shape (News grid, Transactions chip bar), the
numeric keyboard is still a trap on iOS, and the Swap settings icon still sits below its title.
Output: three independent tasks. Any one can be dropped without touching the other two (no file is
shared between tasks).

Reference commits (same object store; read with `git -C $WT show <sha> -- <path>`; ignore every
`.planning/` change in them):
- `843f78cb` news digest (PR #231)
- `9820fb5f` transactions filter into a header drawer (PR #231)
- `bf8a6b1f` GWKeyboardDoneBar (PR #232)
- `2190a07d` swap form clear + settings icon on the title line (PR #232)
Rationale for every number in them: `gh pr view 231` / `gh pr view 232` (run from `$WT`).

## Port / adapt / skip ledger (decided at planning, checked against develop 21b95130)

| Piece | Verdict | Why |
|---|---|---|
| News: hero + digest panel at phone width | PORT | `git apply --check` of the file diff passes on develop; only 10 lines of the file moved since August (Sept colour tokens `statusSuccessText`, `surfaceWell`), all outside the hunks. Every component it uses still exists. |
| News: refresh glyph desktop-only, stamp 1px nudge | PORT | Same diff. |
| Tx: funnel trigger + filter drawer + live chip row | ADAPT | Develop added Buy GNUS to the header trailing, a `purchase` (Buy orders) filter fed by Banxa orders with an open-order pill, and `?filter=` routing via `initialFilter`. All three must survive. |
| Tx: trigger size 48x32 | ADAPT to 44x44 | 32 existed only so the trigger would not set the header row taller than the 32px title. On develop Buy GNUS (`GWButtonSize.sm` = 44 tall) already sets that row to 44, so a 44x44 funnel costs no height and meets Apple's 44pt. |
| Tx: "title sits exactly where Assets puts its own" test | ADAPT | Cannot hold on develop: Buy GNUS (44) already puts the title 6px below Assets' (pre-existing since phase 39, not caused here). Replace it with "the funnel does not change the header height". |
| Tx: drop GWMeshBackground on phone | PORT | Transactions is the last content page still painting the mesh; `scaffoldBackgroundColor` is `gw.surfaceBase` (`lib/theme/theme.dart:66`). |
| Tx: drop "No more transactions" terminus | PORT | Still present on develop (`endOfTransactionsLabel`). |
| Tx: delete dead `_TransactionFilterBar` / `_FilterChip` | SKIP | PR #231 kept them on purpose (separate decision); still referenced by `_panel`'s page arm. Note it as a follow-up in SUMMARY. |
| Keyboard bar component + its 14 tests | PORT (new files) | Nothing exists on develop (no `onTapOutside`, `TapRegion`, `keyboard_actions`). Every token it reads exists with unchanged values (`surfaceMenu` 0xFF171A21/0xFFEFF2F6, `brandPrimaryOnSurface` light 0xFF0A6885, `textSecondary`, `borderSubtle`), so its measured contrast table still holds. |
| Keyboard bar: the six original call sites | ADAPT | All six files moved since August (plain `git apply` fails); wrap by hand. |
| Keyboard bar: Send amount, child-wallet amount dialog | ADAPT (add) | Two numeric fields that did not exist in August (phases 31, 34-38). PR #232's stated scope is "every screen that has one". |
| Swap: form empties after a successful swap | SKIP | Develop's `_applyOutcome` (`swap_screen.dart` ~637-655, phase 26 real execution) already clears both amounts, both controllers, `fetchedQuote`, `submitFailure`, `routeError` after a genuine success and keeps the tokens - PR #232's intent, and its own caveat ("move the clear behind a real success") is already met. The debounce cancel is moot: `_debouncedFetchRoute` nulls `fetchedQuote` immediately, so a pending debounce never coexists with a submittable quote. |
| Swap: settings icon on the title line | ADAPT | No new `trailingOnTitleLine` flag. The flag only existed to protect other centred callers; on develop the centred form has exactly two callers, Swap and Buy, both with a subtitle and a trailing glyph, and both want it. Change the centred path itself, and apply 48x32 to both triggers. |
| Buy page orders glyph | ADAPT (add) | Same defect, same component: Buy's centred header was built "like Swap" (cb9dc62c). Fixing the shared component fixes both; leaving Buy's 48x48 IconButton would grow its header 16px. |
| PR #231/#232 "deliberately not here" items, `.planning/` sketches/handoffs | SKIP | Deferred by the PRs themselves / not code. |

## Hard rules for the executor

- **No `git commit`, no `git add`, no staging, no stash, no push, no PR.** Jakub has not authorised
  commits. Leave every change in the working tree.
- Never use `git apply --index`, `--3way` or `--cached` (they touch the index). Plain `git apply` and
  `git show <sha>:<path> > <new file>` are the only reference-import tools allowed, and the second is
  for files that do not exist on develop.
- Work only in `$WT=/Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232`. Do not edit `banxa/`,
  `squidrouter/`, `tokeninfo/` (auto-generated submodules). Do not write `.planning/ROADMAP.md`,
  `STATE.md` or `MANIFEST.md`. Do not run `flutter run`.
- AGENTS.md: brace every `if` with the body on its own line; widgets, never `_buildFoo()` helpers;
  colours only from `GWColors` tokens (no `Colors.*` except `Colors.transparent`, no `Color(0x...)`
  outside `lib/theme/`); WCAG AA in both themes; no business logic or `Hive`/`http` in widgets;
  Rule of Three before extracting anything. No em dashes in any UI copy.
- Flutter is not on PATH: `F=/Users/jakub/development/flutter/bin/flutter`,
  `D=/Users/jakub/development/flutter/bin/dart` (Flutter 3.41.9, Dart 3.11.5, verified).

## Pre-flight (once, before Task 1)

1. The worktree's submodules are empty (`banxa/`, `squidrouter/`, `tokeninfo/` - `git submodule status`
   shows `-`), and `pubspec.yaml` path-depends on `squidrouter`. Run
   `git -C $WT submodule update --init`. If that cannot reach the network, use
   `--reference /Users/jakub/Desktop/GeniusAI/GeniusWallet/<name>` per submodule. This checks out
   content only; it stages and commits nothing.
2. `cd $WT && $F pub get`.
3. Baseline on the untouched tree: `cd $WT && $F test 2>&1 | tail -3`. Record the exact `+N ~S -F`
   line. (STATE.md's last quoted figure is 2234/5/0, from before phases 39-40; do not reuse it.)
   PR #232 notes the suite's count is not stable run to run in this repo, so if the final count
   differs by a few tests with zero failures, re-run once before calling it a regression.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@.planning/STATE.md
@lib/components/scaffold/gw_page_header.dart
@lib/dashboard/transactions/transactions_screen.dart

Read the rest per task, once each. Large files: grep for the line range first
(`transactions_slim_view.dart` is 1533 lines, `swap_screen.dart` 1266, `token_info_screen.dart` 1627,
`banxa_buy_screen.dart` 1219).
</context>

<tasks>

<task type="auto">
  <name>Task 1: Crypto News - the phone feed leads with a story, then one digest panel (WWK-01, PORT)</name>
  <files>lib/dashboard/news/view/crypto_news_screen.dart, test/dashboard/crypto_news_digest_test.dart</files>
  <action>
Port 843f78cb onto develop. The file diff applies cleanly (checked with `git apply --check` at
planning), so apply that diff - not the old file - with plain apply:
`git -C $WT show 843f78cb -- lib/dashboard/news/view/crypto_news_screen.dart | git -C $WT apply -`.
If it no longer applies (the tree moved), re-implement by hand from `git show 843f78cb` instead; never
copy the August file over the current one.

After applying, read the resulting file once end to end and confirm:
- The September colour fixes survived: `_MetaLine` still paints `gw.statusSuccessText` and
  `_NewsPhoto` still uses `gw.surfaceWell` for placeholder and error fills. If the new 72px-row
  thumbnail introduces any fill of its own, it must be `gw.surfaceWell` too (recessed well), not
  `surfaceSunken`.
- Narrow (`constraints.maxWidth < _NewsMagazine._bandBreakpoint`, a bool from a LayoutBuilder - the
  freeze rule allows a bounded bool, not a continuous dimension): hero first, then `_NewsDigestPanel`,
  a `DashboardScrollContainer` with the search field, a story count (`GWKicker`), and every remaining
  article (`(results ?? items)` minus the hero) as a `_NewsListRow` (72px thumb, 2-line headline,
  1-line dek, `GWHoverRow`, `kGWRowWall`/`kGWRowSeparatorGap` rhythm, `borderSubtle` dividers).
  No "Next up" on narrow. Wide: byte-identical behaviour to today (search field above, hero + Next up
  band, grid).
- `_UpdatedStamp`: refresh IconButton only when `GeniusBreakpoints.useDesktopLayout(context)`; the
  stamp text sits in a `Transform.translate` by the 1px `_opticalNudge` (reason in the reference
  commit message: Inter ink vs line box).
- AGENTS.md rules (braces, no `_build` helpers, tokens only, no em dash in copy).

Then add `test/dashboard/crypto_news_digest_test.dart` (none exists for this screen). Seed the cache so
`fetchCoinTelegraphNews` returns without HTTP: in `setUpAll`, `Hive.init(<temp dir>)`, register
`NewsArticleAdapter` if `!Hive.isAdapterRegistered(3)`, open `coinTelegraphNewsBox` and
`coinTelegraphTimestampBox` (constants in `lib/hive/constants/cache.dart`), put 6 articles and
`timestampBox.put('timestamp', DateTime.now().toIso8601String())`; close and delete in `tearDownAll`
(pattern: `test/dashboard/transaction_row_test.dart` ~392). Use `pump()`/`pump(Duration)`, never
`pumpAndSettle` (the image placeholder spinner animates forever). Cases:
(a) 390x844: article 0's title appears once (the hero); the other five titles each appear inside the
`DashboardScrollContainer`; `find.text('Next up')` finds nothing; `find.byTooltip('Refresh')` finds
nothing. (b) 1280 wide: `find.byTooltip('Refresh')` finds one. End each test by pumping
`const SizedBox()` so no image timer outlives it. If `CachedNetworkImage` raises a plugin exception
in the test host, drain it with `tester.takeException()` in the test rather than changing production
code.
  </action>
  <verify>
    <automated>cd /Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232 && /Users/jakub/development/flutter/bin/flutter test test/dashboard/crypto_news_digest_test.dart test/freeze_rule_test.dart test/news_article_short_time_test.dart && grep -c "statusSuccessText" lib/dashboard/news/view/crypto_news_screen.dart</automated>
  </verify>
  <done>Phone News = hero + one digest panel with search, count and 72px rows; no refresh glyph on phone, still on desktop; Sept tokens intact; new test green; freeze rule test green.</done>
</task>

<task type="auto">
  <name>Task 2: Transactions - the filter leaves the list and lives behind a header funnel (WWK-02, ADAPT)</name>
  <files>lib/dashboard/transactions/transactions_screen.dart, lib/dashboard/home/widgets/transactions_slim_view.dart, lib/dashboard/transactions/view/transactions_stream.dart, lib/dashboard/transactions/sgnus_transactions_screen.dart, test/dashboard/transaction_filters_test.dart, test/dashboard/transactions_page_frame_test.dart, test/dashboard/dashboard_section_caps_test.dart, test/dashboard/transaction_filter_rail_test.dart, test/dashboard/buy_orders_filter_test.dart, test/components/drawer_padding_invariant_test.dart</files>
  <action>
Re-implement 9820fb5f by hand on develop's versions of these files (plain apply fails on all four lib
files; read `git show 9820fb5f -- <path>` for the reference shape). Keep every develop feature listed
in the ledger: Buy GNUS in the header, the `purchase` filter with its order rows and open-order pill,
`OrdersStatus` loading/error empty states, and develop's `onRefresh` body (`getCoins`,
`SettlePendingSends`, `fetchOrders`) verbatim.

1. Filter ownership. `TransactionsScreen` becomes a `StatefulWidget` (keep `initialFilter`) holding
`Filters _filter`, initialised from `widget.initialFilter ?? Filters.all`, with a `didUpdateWidget`
that switches to a new non-null `initialFilter` that differs from the old one - the exact rule
`_TransactionsSlimViewState.didUpdateWidget` applies today, moved up, so
`router.go('/transactions?filter=purchase')` while on the page and the `/banxa/callback` redirect keep
working. `TransactionsSlimView` replaces `initialFilter` with optional `selectedFilter` +
`onFilterChanged` (reference: `_ownFilter`, `selectedFilter` getter, `_selectFilter`); null means
uncontrolled, which is the dashboard panel, whose call sites stay unchanged. Drop the slim view's
`didUpdateWidget`. `TransactionsStream` and `SgnusTransactionsScreen` forward the two new parameters
in place of `initialFilter`. Route every `setState(() => selectedFilter = ...)` in the slim view
(rail, panel bar, filtered-empty "show all" action) through `_selectFilter`.

2. One scoping, two readers. The header funnel's counts must come from the same list the body counts
from (`scopedTransactions`: SGNUS-only scoping, then Banxa order rows appended), or the drawer and the
"N of M" can disagree (T-12-14). Lift that logic into one top-level function in
`transactions_slim_view.dart` (inputs: transactions, sgnus-only flag, order rows) and call it from
both the state getter and the trigger. The trigger builds its order rows with `orderAsTransaction`
(`lib/banxa/banxa_helpers/order_transaction_mapping.dart`) and its open count with the same
`!o.banxaStatus.isFinal` test `_openBuyOrders` uses.

3. Header (`transactions_screen.dart`). Wrap the Column in a LayoutBuilder; `wide =
constraints.maxWidth >= GeniusBreakpoints.medium` (the same test `_page` uses, so the funnel and the
wide rail are never both shown or both missing). `GWPageHeader.trailing`: wide - the Buy GNUS
`GWButton` exactly as today; narrow - a `Row(mainAxisSize: min)` of Buy GNUS, `space4`, then the
funnel at the right edge (where Swap's settings glyph sits). A private `_FilterTrigger` widget feeds
the funnel: non-SGNUS wallet - `BlocBuilder<TransactionsCubit>`; SGNUS - `StreamBuilder` on
`context.read<GeniusApi>().getSGNUSTransactionsStream()` (a `BehaviorSubject`, safe to listen twice);
both inside `BlocBuilder<OrdersCubit, OrdersState>` for the orders. Drop `GWMeshBackground` and the
`compact` variable: `Scaffold(body: page)` at every width (theme scaffold colour is `surfaceBase`).

4. Funnel (`TransactionsFilterTrigger`, public, in the slim view file). `IconButton` with
`Icons.filter_alt_outlined` (not `Icons.tune`, which is Swap's settings glyph), size 22, constraints
tight 44x44 (ADAPTED from the reference's 48x32 - see ledger), `tapTargetSize: shrinkWrap`. Tooltip
`Filter transactions`, or `Filtered: <label>` when live. Live filter: icon `gw.brandPrimaryOnSurface`
plus an 8px `GeniusWalletGradient.brandCta` dot with a 1.5px `gw.surfaceBase` ring; otherwise
`gw.textSecondary`. Renders `SizedBox.shrink()` when the scoped list is empty (same rule as the rail
and the old bar: a control that filters nothing is an offer the app cannot honour).

5. Drawer. `ResponsiveDrawer.show(title: 'Filter', bodyPadding: EdgeInsets.zero, child: ListView(
padding: kDrawerBodyPadding, ...))` with `GWKicker('Type', dense: true)` over All,
`Filters.primary` (now includes Buy orders) and `Filters.overflowTypes`, then `GWKicker('Status',
dense: true)` over `Filters.overflowStatuses`. One `GWSelectRow` per filter: leading
`badgeGlyph(badgeSpec(kind, gw), color: gw.textSecondary, size: 21)` (All: `Icons.list_alt_outlined`),
trailing the live count (`numericBody`, 13, `textSecondary`), `selected`, `onTap` pops the drawer then
calls `onChanged`. Buy orders with open orders > 0: `titleTrailing` is the existing `_OpenCountPill`,
and the row's semantics read `Buy orders, N open` (the wording `_FilterChip` uses today) - this keeps
phase 39 D-07's open-order signal on the phone now that the chip is gone. Add the new
`ResponsiveDrawer.show` call to the hand-written census in
`test/components/drawer_padding_invariant_test.dart`, or that test fails by design.

6. Narrow page body (`_page`, `!wide` branch): delete the `_TransactionFilterBar` row and its gap.
Return one `DashboardScrollContainer` whose Column holds `_LiveFilterRow` (only when scoped is not
empty and the filter is not All) followed by `_body(..., scrollable: false, underSectionTitle: false,
limit: null)`. `_LiveFilterRow`: wall `space6` desktop / `space3` phone, a `_LiveFilterChip` (pill,
32 tall, `brandPrimaryOnSurface` border, `GWHoverable` hover fill `GWDecorations.hoverFill`, badge
glyph 13, label `labelMd` w600 `textPrimary`, close glyph 13; `Semantics(button: true, label: 'Clear
filter: <label>')`; tap selects All) and `GWKicker('$shown of $total', dense: true)` when they differ.
`_TransactionFilterBar.chipSize`/`touchChipSize` lose their only caller: fold back to a fixed 32.
Keep `_TransactionFilterBar` and `_FilterChip` themselves (ledger: SKIP).

<!-- planner-discipline-allow: endOfTransactionsLabel -->
7. Delete the `endOfTransactionsLabel` constant and the terminus entry in `_body`.

8. Tests, rewritten against develop (use `git show 9820fb5f -- test/` for the shape, not the bytes):
- `transaction_filters_test.dart`: replace the `bar fits the title row` group with a phone-page
  control group - empty wallet: no funnel; funnel is 44x44; drawer lists All + all nine filters incl.
  Buy orders, nothing behind an overflow; picking a filter filters the list and the chip names it
  (dark and light); the chip clears without opening anything; filtered-empty keeps both ways out;
  dashboard panel shows View all and no filter.
- `transactions_page_frame_test.dart`: drop the 44px chip touch-target test; phone background is
  `surfaceBase` with no `GWMeshBackground` (the page can now `pumpAndSettle`); add "the funnel does not
  change the header's height" (header with Buy GNUS + funnel == header with Buy GNUS alone).
- `dashboard_section_caps_test.dart`: fold the terminus tests into cap tests (page renders every row,
  panel caps at five, no terminus anywhere).
- `buy_orders_filter_test.dart`: the width-600 chip / `More filters` tests become drawer tests (Buy
  orders is a drawer row; it shows the open pill and `Buy orders, 2 open` semantics; with nothing open
  no pill); `TransactionsSlimView(initialFilter: ...)` becomes `selectedFilter:`; the URL-switch and
  Banxa-callback tests must pass unchanged in intent.
- `transaction_filter_rail_test.dart`: adjust only what the parameter rename breaks.
- `test/banxa/buy_entry_points_test.dart` must still pass untouched (header Buy GNUS pushes /buy).
Measure contrast of the live funnel (`brandPrimaryOnSurface` on `surfaceBase`, >= 3:1 non-text) and
the chip label in both themes with the `contrastRatio` helper pattern from
`test/theme/theme_contrast_test.dart`; quote the numbers in SUMMARY.
  </action>
  <verify>
    <automated>cd /Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232 && /Users/jakub/development/flutter/bin/flutter test test/dashboard/transaction_filters_test.dart test/dashboard/transactions_page_frame_test.dart test/dashboard/dashboard_section_caps_test.dart test/dashboard/transaction_filter_rail_test.dart test/dashboard/buy_orders_filter_test.dart test/components/drawer_padding_invariant_test.dart test/banxa/buy_entry_points_test.dart test/freeze_rule_test.dart && test "$(grep -v '^[[:space:]]*//' lib/dashboard/home/widgets/transactions_slim_view.dart | grep -c endOfTransactionsLabel)" -eq 0</automated>
  </verify>
  <done>All listed tests green; the final grep count is 0. Phone Transactions: no chip row, funnel + Buy GNUS in the header, drawer with ten rows and live counts (Buy orders with its open pill), live-filter chip with "N of M", flat surfaceBase, no terminus. Wide page, dashboard panel and ?filter= routing behave as before.</done>
</task>

<task type="auto">
  <name>Task 3: A way out of the numeric keyboard, and centred-header glyphs on the title line (WWK-03 PORT/ADAPT, WWK-04 ADAPT)</name>
  <files>lib/components/inputs/gw_keyboard_done_bar.dart, test/components/gw_keyboard_done_bar_test.dart, lib/squid_router/swap_field.dart, lib/squid_router/swap_settings_drawer.dart, lib/dashboard/bridge/bridge_screen.dart, lib/screens/banxa_buy_screen.dart, lib/tokens/token_info_screen.dart, lib/settings/settings_screen.dart, lib/send/send_screen.dart, lib/child_wallets/child_operation_dialogs.dart, lib/components/scaffold/gw_page_header.dart, lib/squid_router/swap_screen.dart, test/components/gw_page_header_centered_test.dart, test/squid_router/swap_header_alignment_test.dart</files>
  <action>
A. Component (new files, nothing on develop to overwrite):
`git -C $WT show bf8a6b1f:lib/components/inputs/gw_keyboard_done_bar.dart > $WT/lib/components/inputs/gw_keyboard_done_bar.dart`
and the same for `test/components/gw_keyboard_done_bar_test.dart` (it imports `../banxa/gw_pump.dart`,
which exists). Every import and token it uses exists on develop with unchanged values (checked at
planning), so expect it to compile as is; fix only what `flutter analyze` reports. Do not change the
94% fill alpha or the contrast table. Run the test file alone and note that
`a chevron with nowhere to go is disabled to a screen reader` was reported order-dependent in PR #232:
leave it standing, report its result in SUMMARY.

B. Wrap every numeric-keyboard field by hand with `GWKeyboardDoneBar(child: <field>)` - an explicit
wrapper at each site, as the reference does; do not fold it into `GWTextField` (three sites use a raw
`TextField`, and two need `enabled:` control). Sites on develop:
- `lib/squid_router/swap_field.dart` ~124: the raw `TextField`, `enabled: isSelectingFrom` (the
  read-only You Receive field must not be a chevron stop).
- `lib/dashboard/bridge/bridge_screen.dart` ~447: the amount `TextField` inside the `Flexible`.
- `lib/squid_router/swap_settings_drawer.dart` ~243: the slippage `TextField` (inside a drawer; the
  bar scopes itself by focus scope).
- `lib/screens/banxa_buy_screen.dart` ~571: the `GWTextField` inside the amount field's `Semantics`.
- `lib/tokens/token_info_screen.dart` ~980: the `Token amount` `GWTextField` in `CoinConvertCard`.
- `lib/settings/settings_screen.dart` ~414: hoist `final isNumber = numberKeys.contains(entry.key);`,
  wrap with `enabled: isNumber`, and use `isNumber` in `keyboardType` and `onChanged`.
- `lib/send/send_screen.dart` ~206: the Amount `GWTextField` (new since August).
- `lib/child_wallets/child_operation_dialogs.dart` ~484: the Amount `GWTextField` in the `GWDialog`
  shown via `showDialog` (new since August; root-navigator overlay, same case as the component's
  modal-sheet test).
Then `grep -rn "numberWithOptions\|TextInputType.number" lib` must list only wrapped sites.

C. Title-line trailing in the centred header (`gw_page_header.dart`). In the `centered` path, when a
`trailing` is present, put it on the title's own line: inside `titleBlock`, the title becomes a
`Stack(alignment: Alignment.centerRight, children: [Center(child: titleText), trailing])`, and the
outer `Stack` over title + subtitle goes away. No new parameter (ledger: the old
`trailingOnTitleLine` flag protected callers that no longer exist; `centered: true` has exactly two
callers, Swap and Buy, and both want this). Non-centred callers must render the identical tree. Fix
the stale docs that still say the centred form is "(Swap, Feedback)" - it is Swap and Buy.

D. Triggers, 48x32 so the title line stays 32 tall (a 48-tall control there took the header from 92 to
108 in the reference measurement): in `swap_screen.dart` ~1001 the `Icons.tune` IconButton and in
`banxa_buy_screen.dart` ~161 the `Icons.receipt_long_outlined` IconButton (keep its `Buy orders`
tooltip and its `context.go('/transactions?filter=purchase')`) each get `padding: EdgeInsets.zero`,
`constraints: BoxConstraints.tightFor(width: 48, height: 32)`, `visualDensity:
VisualDensity.standard`, `style: IconButton.styleFrom(tapTargetSize:
MaterialTapTargetSize.shrinkWrap)`. Inline at both sites; two occurrences do not clear the Rule of
Three. Leave Swap's submit/clear logic alone (ledger: SKIP).

E. Tests.
- `test/components/gw_page_header_centered_test.dart`: add "with a subtitle, a centred trailing sits
  on the title's centre line" (trailing centre dy == title centre dy within 0.5; title still centred on
  the column; trailing right == column right) and "a 32-tall trailing does not grow the header"
  (header height with a 48x32 trailing == header height with none). Existing cases must still pass.
- `test/squid_router/swap_header_alignment_test.dart`: port 2190a07d's file, replacing its August
  `_swapHost` with the SwapScreen harness the current `test/squid_router/swap_flip_centring_test.dart`
  uses. Keep its phone and desktop "centred title and subtitle, glyph on the title line" cases and
  the "title yields rather than overlapping the glyph" case. Its "same Y as the Assets title" case:
  keep it if it holds on develop; if it fails for a reason unrelated to this change, drop it and say
  why in SUMMARY rather than chasing it.
  </action>
  <verify>
    <automated>cd /Users/jakub/Desktop/GeniusAI/GW-reimpl-231-232 && /Users/jakub/development/flutter/bin/flutter test test/components/gw_keyboard_done_bar_test.dart test/components/gw_page_header_centered_test.dart test/squid_router test/swap test/send test/banxa test/child_wallets test/tokens test/logs test/dashboard/bridge</automated>
  </verify>
  <done>The bar floats above the keyboard on all eight numeric fields on touch platforms only, chevrons step only between enabled bars, tick and tap-outside dismiss; Swap and Buy glyphs sit on their title line with headers no taller than before; all listed tests green.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| user -> numeric fields | Amounts typed into Swap, Bridge, Send, Buy, child-wallet dialogs. The bar changes focus only; values still flow through each field's existing formatter and validation. |
| route query -> TransactionsScreen | `?filter=` is parsed by `filterFromQuery`, which maps unknown values to null. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-wwk-01 | Information disclosure | GWKeyboardDoneBar | low | mitigate | The bar never reads or logs the field's text; it holds only a FocusNode. `tool/check_no_new_key_logging.sh --scan-tree` must stay 0. |
| T-wwk-02 | Tampering | `?filter=` query | low | accept | `filterFromQuery` already maps unknown names to null (tested in buy_orders_filter_test); the hoisted state keeps using it. |
| T-wwk-03 | Repudiation / integrity | Swap form after submit | low | accept | Unchanged: develop clears the form only after a genuine success (`_applyOutcome`). Task 3 does not touch submit logic. |
</threat_model>

<verification>
Run in `$WT` after all three tasks (or after whichever subset was executed):
1. `$D format <every touched .dart file>`, then `$D format --output=none --set-exit-if-changed lib test` (0 changed).
2. `$F analyze` - must print "No issues found" (it exits non-zero on infos; that is intended).
3. `$F test` - full suite, zero failures; quote the `+N ~S -F` line next to the pre-flight baseline and
   account for the delta by test file.
4. `bash tool/check_brace_style.sh`, `bash tool/check_raw_colors.sh`,
   `bash tool/check_no_new_key_logging.sh --scan-tree`, `bash tool/check_onboarding_seed_safety.sh` - all 0.
   (`tool/check_agent_rules_sync.sh` was red before PR #231 for unrelated prose drift; report its
   result, do not fix it here.)
5. `git -C $WT status --short` shows only working-tree changes (nothing staged: `git -C $WT diff --cached --stat` is empty).
</verification>

<success_criteria>
- WWK-01..WWK-04 truths above hold, each backed by a green targeted test.
- Every ledger row is either implemented as stated or, if the executor had to deviate, the deviation
  and its reason are in SUMMARY.
- No commit, no staged change, no PR. Full suite, analyze and format are green with real output quoted.
</success_criteria>

<output>
Write `.planning/quick/261009-wwk-re-implement-pr-231-and-232-on-develop/261009-wwk-SUMMARY.md`:
per task what was ported/adapted/skipped, the measured numbers (header heights, contrast ratios, test
counts before/after), deviations, and follow-ups (dead `_TransactionFilterBar`/`_FilterChip`; the
6px Transactions-vs-Assets title offset caused by Buy GNUS since phase 39; full-height filter drawer
on phones, app-wide). Do not commit it.
</output>
