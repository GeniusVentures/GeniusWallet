# Session summary - 2026-08-10 (Crypto News feed + Transactions filter)

Window: 2026-08-09 evening to 2026-08-10 early. Branch
`redesign/news-digest-tx-filters-260810`, stacked on `redesign/assets-boxed-panels-260808`.
Draft PR #231. Standup note in the team's flat-bullet chat format below; paste as plain text.

```
Shipped to draft PR #231 (github.com/GeniusVentures/GeniusWallet/pull/231):

Crypto News, phone:
 • The grid is gone. On a phone it resolved to two 181px columns, which gave a 16px
   headline 147px of line against a 62-character median headline, so nearly every card
   was truncated and 30 articles spent 4,248px of grid. It now leads with the hero story
   and follows with one digest panel - the same DashboardScrollContainer every other list
   page uses - holding the search field, a story count and each remaining article as a
   72px-thumbnail row. "Next up" is gone as a band; its three stories are the first three
   rows. Wide layout is byte-identical.
 • The refresh button renders on desktop only. It exists because pull-to-refresh is
   unreachable with a mouse, and that only holds where there is a mouse; on a phone
   RefreshIndicator is already over the same feed. Its 40px tap target, not the 32px
   title, set the header height, so the header goes 56 to 48.
 • The "Updated Xm ago" stamp moved down 1px. GWPageHeader centres a trailing by line
   box, and Inter's proportional leading puts the title's ink at 7.93..30.61 and the
   stamp's at 11.49..25.03, so it read a pixel high.

Transactions, phone:
 • The filter left the list. It was the dashboard panel's bar: four icon-only chips,
   five more filters behind an overflow menu, no labels anywhere, names only in a
   Tooltip a finger cannot open, and a menu pick left no mark on the page at all - the
   list read as unfiltered while showing part of itself.
 • It is now a funnel in GWPageHeader.trailing, costing the page zero vertical space,
   opening our own ResponsiveDrawer with a GWSelectRow per filter carrying the same
   badge mark the rows use plus a live count. All nine filters and All are one gesture
   away and every one is named. A live filter tints the trigger and adds a dismissible
   chip row with the filter's name and "3 of 10" - the count Assets prints and this page
   never had.
 • Icons.filter_alt_outlined, not Icons.tune: tune is already Swap's settings glyph, and
   the funnel is already this screen's own filtered-empty mark.
 • The page filter moved from TransactionsSlimView's State up to TransactionsScreen,
   because the trigger sits two widgets above the list. Both pass-throughs take it as an
   optional parameter, so the dashboard panel keeps its own filter and its call sites are
   unchanged.
 • Three corrections found on device: the page title sat 8px lower than every other page
   title (a 48x48 IconButton sets the header row's height against the 32px title line -
   the trigger is 48x32 now and the page measures 48/0/48, identical to Assets); the
   phone background dropped GWMeshBackground for the flat surfaceBase Assets and News
   paint (#0B0D12 dark, #DCE0E6 light); "No more transactions" is gone.

Verification:
 • dart format 399 files 0 changed, flutter analyze clean, flutter test +1203 ~3 all
   passed, check_brace_style / check_raw_colors / check_onboarding_seed_safety /
   check_no_new_key_logging all 0.
 • check_agent_rules_sync is RED and was red before this branch: AGENTS.md and
   .github/copilot-instructions.md have drifted in the lazy-developer-ladder prose.
   Neither file is touched here. Someone owns that sync; it should not ride a UI PR.
 • Test count 1207 to 1203, accounted for exactly: a 14-test group on the old filter bar
   became a 9-test group on the new control, the drawer-padding census gained one, three
   end-of-list tests folded to two cap tests, one header-geometry test added. One
   assertion has no successor and was deleted rather than faked - it measured the font
   size of the terminus label, which no longer exists.

Known and deliberately not fixed:
 • The filter drawer will be full-screen height on a phone, ~180px empty below the last
   row. EVERY mobile ResponsiveDrawer does this whatever it holds -
   _ResponsiveDrawerScaffold returns a Scaffold, which takes constraints.biggest.
   Measured: a drawer whose whole body is Text('one line') reports Size(390, 844).
   Fixing it means a maxHeight on the component and ~19 call sites to re-check. Worth
   its own ticket; it affects every sheet in the app, not just this one.
 • _TransactionFilterBar and _FilterChip are now dead code, ~200 lines. Deleting the
   narrow page's filter row removed their only LIVE call site: _panel only runs when
   page == false, so its "page ? bar : GWViewAllLink" ternary has taken the link arm
   since the 2026-08-07 merge. Kept for now because removing them is a separate call.
 • The trigger's tap target is 48x32, down from 48x48. 32 clears WCAG 2.2 SC 2.5.8's
   24x24 floor and 48dp Android horizontally, but is under Apple's 44pt vertically. That
   is the price of the title landing level with the other pages. The alternative is
   teaching GWPageHeader to absorb a tall trailing into its own bottom gap, which
   touches a component shared with Buy GNUS and Swap.
 • Filters still mixes two orthogonal axes - seven types and two statuses in one enum
   with single-value selection - so picking Pending un-picks Sent and "my failed sends"
   cannot be asked. Measured in sketch 191: Failed alone returns 2 rows, Sent + Failed
   returns 1. Sketch 191-F7 is the design. Model change, not a filter treatment.
 • Mint is the only filter whose mark is not a Material icon but a stroked SVG asset at
   stroke-width 3.2, so it reads heavier than everything beside it at any size. True in
   the shipped app. Recorded in sketch 193, not fixed silently.
 • The "Updated" stamp can lie: _load stamps on whenComplete while the API returns its
   cache untouched for two minutes, so a refresh in that window says "Updated now"
   having fetched nothing. Sketch 194 finding 3.

Design record:
 • Sketches 189 to 195 committed. 189 news feed (scheme C shipped), 190 Transactions in
   the Assets language (C chosen), 191 and 192 two rounds of filter treatments, 193 the
   corrections round, 194 the news freshness stamp (A shipped), 195 the filter design
   that shipped.
 • Three corrections recorded there rather than quietly fixed: 188/190/191/192 drew
   hand-made filter glyphs instead of the shared badgeSpec table, so their marks were
   stroked where the app's are filled and vertical where the app's are diagonal;
   188/190 drew a count on each filter chip that the code has never rendered; 191/192
   invented a bottom sheet instead of using ResponsiveDrawer. Layout findings stand, but
   any impression they invited about how the control felt was formed against wrong marks.

Base branch note:
 • #231 is stacked on #230 (assets-boxed-panels), which is on #227 (row-rhythm).
   Targeting develop directly would drag ~50 commits already in review into the diff.
   Retarget once the parents land.
```
