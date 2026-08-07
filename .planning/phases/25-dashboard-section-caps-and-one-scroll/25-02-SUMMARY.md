---
phase: 25-dashboard-section-caps-and-one-scroll
plan: 02
subsystem: dashboard/assets
tags: [route, sort, search, empty-states, a11y, mobile]
status: complete
requires:
  - WalletDetailsCubit (read-only, plus selectCoin on row tap)
  - CoinCardRow, GWPageHeader, GWSearchField, GWKicker, GWBackLink, GWEmptyState, GWErrorState, GWButton, ResponsiveDrawer + CryptoAddressQR, Loading
  - fetchAllCoinGeckoCoins / fetchCoinsMarketData (3-minute shared Hive cache)
provides:
  - "`/assets` route, registered INSIDE the ShellRoute"
  - "`compareAssetsByValue` / `sortAssets` - the single ordering authority plan 25-01's top-5 must call"
  - "`AssetsMarketDataResolver` seam + `resolveAssetsMarketData`"
  - "`DevMockHoldings.loadUnpriced()` + the `Unpriced` dev button"
affects:
  - lib/navigation/router.dart (one import, one route)
  - lib/dev/dev_mock_holdings.dart, lib/dev/dev_tools_bubble.dart (additive)
tech-stack:
  added: []
  patterns:
    - "pure comparator beside the widget (sibling of markets_sort.dart)"
    - "injectable resolver seam (widened from token_info_screen.dart's List<String> to List<Coin>)"
key-files:
  created:
    - lib/dashboard/assets/assets_sort.dart
    - lib/dashboard/assets/assets_market_data.dart
    - lib/dashboard/assets/assets_screen.dart
    - test/dashboard/assets_sort_test.dart
    - test/dashboard/assets_screen_test.dart
  modified:
    - lib/navigation/router.dart
    - lib/dev/dev_mock_holdings.dart
    - lib/dev/dev_tools_bubble.dart
decisions:
  - "Fetch market data on mount as well as on cubit change - BlocListener alone leaves the page permanently priceless"
  - "Sort the (Coin, AssetRowData) pair with compareAssetsByValue directly rather than sortAssets over bare rows, so duplicate symbols cannot cross-wire rows"
  - "The one-scroll assertion counts VERTICAL scrollables - every EditableText carries a horizontal one"
metrics:
  tasks: 3
  files_touched: 8
  tests_added: 25
  test_baseline_before: 1035
  test_total_after: 1060
  test_passing_after: 1058
  completed: 2026-08-07
---

# Phase 25 Plan 02: The /assets Full Page Summary

`/assets` ships as a real route inside the ShellRoute: page header with the wallet total, a search
field, one value-keyed sort toggle whose arrow shows the CURRENT direction, and one `CoinCardRow` per
matching coin in a single scroll region - with the ordering rule extracted as a pure, unit-tested
function so plan 25-01's capped dashboard section can call the identical code.

## No commits created

The working tree is left dirty for review, per the standing project rule and the plan's own
`<output>` block. Nothing was staged and nothing was committed.

`.planning/STATE.md` was deliberately NOT updated either: it is already modified in the working tree
by parallel session work, and rewriting it from this agent risks clobbering plan 25-01's own state
edits. Flagged rather than done silently.

## Measured test baseline, before and after

| | Count |
|---|---|
| Baseline before starting (`flutter test`, measured, not quoted) | **1035 passing** |
| Tests added by this plan | **25** (16 unit + 9 widget) |
| Total after | **1060** |
| Passing after | **1058** |
| Failing after | **2** |

`flutter analyze`: **0 issues** ("No issues found!"), before and after formatting.

`flutter test test/dashboard/assets_sort_test.dart test/dashboard/assets_screen_test.dart`: **25
passing** on their own.

### The 2 failures, named, and NOT papered over

Both are **census / registry tests** that enumerate call sites across `lib/`. Both fail because this
plan legitimately adds a call site the hand-written census does not list yet. **Neither indicates a
defect in the new code** - every *semantic* assertion in both files passes.

| Test file | Failing assertion | Why | Fix (one line) |
|---|---|---|---|
| `test/tokens/coin_page_entry_parity_test.dart` | `exactly three /token-info push call sites in lib/` | `assets_screen.dart` is the 4th push site | change the expected `3` to `4` |
| `test/components/drawer_padding_invariant_test.dart` | `every ResponsiveDrawer.show call site in lib/ is in the census` | the S3 Receive drawer is a new, unclassified call site | add `'lib/dashboard/assets/assets_screen.dart': _Inset.shellInset,` to `_census` |

Evidence the underlying invariants HOLD rather than being bypassed:

- The parity file's *other* assertions pass, including `every one passing a TokenInfoArgs` (the new
  push passes `extra: TokenInfoArgs(...)`, so the route stays the only assembler) and `no file in
  lib/ puts a connection flag key inside a /token-info extra`.
- The drawer file's per-file classification tests all pass. The new drawer passes no `bodyPadding`,
  which is exactly the `shellInset` classification already recorded for `coins_screen.dart` - the
  file this drawer is duplicated from.
- Both tests' own failure messages prescribe updating the census as the intended action ("this count
  (3) is the census to update once that holds").

**These two edits were NOT made**, because both files sit outside this plan's `files_modified` fence
and the execution brief is explicit: stop and report rather than reach for a file outside the list.
They are one line each and are the last thing standing between this plan and a green suite.

## Which of the four `<audit_verification>` findings survived contact with the code

| # | Finding | Verdict |
|---|---|---|
| 1 | `CoinsScreen` has NO `isDashboard` parameter | **Confirmed.** `coins_screen.dart:33-38` takes `onCoinSelected`, `filterCoins`, `isUseDivider`; `isDashboard` is derived at line 247 from `onCoinSelected == null`. The BRIEF's "cheap option" was never compilable. |
| 2 | The search component is `GWSearchField`, not bare `GWTextField` | **Confirmed and used.** `gw_text_field.dart:351` ships it pre-wired with the search icon, a Clear button and the gradient focus ring. Nothing was hand-rolled. |
| 3 | `GWEmptyState` is ONE component at TWO call sites with different copy | **Confirmed.** S3 (`No coins yet` + the Receive / Buy GNUS pair) and S4 (`No assets found`, no CTA). The widget test asserts they are different states, not just different strings. |
| 4 | The real reused count is higher than 7; 2 new UI + 2 new pure libraries | **Confirmed.** Reused as-is: `CoinCardRow`, `GWPageHeader`, `GWSearchField`, `GWKicker` (+ its `trailing` slot), `GWBackLink`, `GWEmptyState`, `GWErrorState`, `GWButton`, `ResponsiveDrawer`, `CryptoAddressQR`, `Loading`, `assetsTotal`/`assetsDayChange`, `GeniusBreakpoints`. New: the route + `_AssetsSortToggle`, plus `assets_sort.dart` and `assets_market_data.dart`. |

One further correction the audit did not anticipate: `GWEmptyState` mounts its own
`SingleChildScrollView`, but only when its slot is height-BOUNDED. Inside this page's scroll view the
slot is unbounded, so it returns the plain centred tree and the one-scroll invariant holds. Verified
by test, not by reading.

## Deviations from Plan

### 1. [Rule 2 - missing critical functionality] Market data is also fetched on mount

- **Found during:** Task 2.
- **Issue:** D-5 step 1 specifies a `BlocListener` as the only fetch trigger. `BlocListener` fires on
  a state CHANGE. `/assets` is reached FROM the dashboard, where `coinsStatus` is already
  `successful` and no further change is coming - so the listener would never fire and the page would
  sit **permanently priceless**: every row reading `$0.00` and, worse, every held coin wrongly
  classified into the unpriced tier, inverting the whole sort. `CoinsScreen` does not hit this
  because it mounts at app start while coins are still `initial`.
- **Fix:** an `addPostFrameCallback` in `initState` that reads the CURRENT cubit state - `getCoins()`
  when `initial && selectedNetwork != null`, otherwise resolve market data for the coins already
  there. The `BlocListener` is kept for later changes. No timer, no `dart:async` import.
- **Files:** `lib/dashboard/assets/assets_screen.dart`.

### 2. [Rule 2 - missing error handling] The fetch cannot strand `_isFetching`

- **Issue:** the copied shape sets `_isFetching = true` before awaiting and only clears it on the
  success paths. A throwing resolver (a rate limit, an offline phone) would leave it `true` forever,
  wedging the page priceless for the rest of its life - including across pull-to-refresh.
- **Fix:** `try`/`catch` that clears the flag and KEEPS the last good price map, so a failed refresh
  never blanks a page that is already showing prices. `ponytail:`-noted that the failure is silent.
- **Note:** `coins_screen.dart` has the same latent bug. It is fenced, so it was not touched. Logged
  below as a follow-up.

### 3. [design, stated] Rows are sorted as (Coin, AssetRowData) pairs

- The plan says "sort with `sortAssets(...)`". Sorting bare `AssetRowData` would force a lookup back
  to the `Coin` by symbol, and a wallet may hold two entries with the SAME symbol on different
  networks - both rows would get the same coin and tap to the same token page.
- The pair list is sorted with `compareAssetsByValue` **directly**, which is the same authority
  `sortAssets` itself delegates to, so the order is byte-identical. `sortAssets` remains the public
  entry point for plan 25-01, and a widget test asserts the page's rendered order equals
  `sortAssets(rows, ascending: false)`.

### 4. [test correction, not a relaxation] The one-scroll assertion counts VERTICAL scrollables

- `expect(find.byType(Scrollable), findsOneWidget)` is **factually impossible** on a page with a text
  field: every `EditableText` carries its own HORIZONTAL `Scrollable` (`axisDirection: right`,
  `restorationId: "editable"`) to scroll text inside the input. It is not a page scroll region and
  cannot capture a vertical drag.
- The assertion now counts scrollables whose axis is vertical and requires exactly 1 - which is the
  invariant the phase actually cares about, and the one a stray `ListView` would break. The grep gate
  guards the same property from the source side.

### 5. [test harness bugs, mine, found and fixed]

- `addTearDown(handle.dispose)` for `tester.ensureSemantics()` fails every test that uses it: the
  framework's leaked-handle check runs BEFORE tearDowns. Worse, it leaked semantics into the next
  test in the file, which is how the S3/S4 test was briefly reading an enabled-semantics tree it
  never asked for. Handles are now disposed at the end of the body.
- The S3/S4 test pumped two structurally identical `_host` trees back to back. `BlocProvider`'s
  `create:` runs once per ELEMENT, so the second pump reused the first cubit and its four seeded
  coins - the S3 half was asserting against the S4 wallet. Fixed with an explicit unmount
  (`pumpWidget(const SizedBox.shrink())`) between them, and the reason is written at the call site.
- One assertion of mine was simply WRONG and was corrected rather than deleted: it asserted the sort
  toggle was absent in S4. D-2 says S4 keeps BOTH controls mounted. It now asserts the toggle is
  present in S4 and absent in S3.

## The fence: how non-violation was PROVEN, not asserted

The plan's fence gate is `git status --porcelain | grep -cE '<25-01 files>' | grep -qx 0`. **That
gate cannot pass in this working tree and never could**: all five of plan 25-01's fenced files were
ALREADY modified before this plan started (pre-existing session work). The gate's premise - a clean
tree - is false here.

Substituted a stronger check: SHA-256 of each fenced file captured before the first edit and
re-checked at the end.

| File | Hash before | Hash after |
|---|---|---|
| `lib/dashboard/home/view/dashboard_screen.dart` | `d747e294…` | `d747e294…` |
| `lib/components/coins/view/coins_screen.dart` | `d4363f3c…` | `d4363f3c…` |
| `lib/dashboard/home/widgets/transactions_slim_view.dart` | `7585365f…` | `7585365f…` |
| `lib/dashboard/chart/dashboard_markets.dart` | `62d455ec…` | `62d455ec…` |
| `lib/dashboard/compute/compute_panel.dart` | `cc70b397…` | `cc70b397…` |
| `test/dashboard/compute_panel_height_test.dart` | `a192e74d…` | `a192e74d…` |

All six byte-identical. Nothing owned by 25-01 was touched.

Also worth recording: the plan lists `compute_panel.dart` at `lib/dashboard/home/widgets/`. Its real
path is `lib/dashboard/compute/compute_panel.dart`. Both were hashed.

## Automated gates

| Gate | Result |
|---|---|
| `flutter analyze` = 0 issues | **PASS** |
| `grep -c "path: '/assets'" lib/navigation/router.dart` = 1 | **PASS** |
| no `dart:async` in `assets_screen.dart` | **PASS** |
| no `GWSectionTitle` in `assets_screen.dart` | **PASS** |
| no `setSelectedWalletBalance` in `assets_screen.dart` | **PASS** |
| no `ListView`/`GridView`/`NestedScrollView`/`CustomScrollView` | **PASS** |
| no Flutter widget import in `assets_sort.dart` | **PASS** |
| fenced files unmodified | **PASS** (by hash; the git-status form is inapplicable) |
| `dart format` clean on all touched files | **PASS** |

## `ponytail:` notes added (so the post-25-01 follow-up can be written from this file alone)

1. **`resolveAssetsMarketData` duplicates `CoinsScreenState._fetchMarketData`'s id resolution**
   (`assets_market_data.dart`). Written in its final shared home, so the follow-up is a DELETION in
   `coins_screen.dart` plus a call here, not a move. Ceiling: until then the two copies can drift and
   nothing fails loudly when they do.
2. **`_showReceive` duplicates `CoinsScreenState._showReceive`** (`assets_screen.dart`). Upgrade
   path: promote to a shared `showReceiveDrawer(context, state)` and delete both copies.
3. **Eager row building** (`assets_screen.dart`). Every row is built; a wallet holding hundreds of
   tokens builds them all. Upgrade path: a `CustomScrollView` with a sliver list, once that is a real
   wallet and not a hypothesis.
4. **Silent fetch failure** (`assets_screen.dart`). No toast, no error row; the total reads what the
   last good fetch said. Upgrade path: a non-blocking error that does not fight the five states.

## Deferred / follow-up items

- **The two census updates** (see the failures table above). One line each.
- **`coins_screen.dart` has the same `_isFetchingMarketData` stranding bug** fixed here as deviation
  2. Out of scope: fenced file. Worth folding into the post-25-01 extraction.
- **`markets_table.dart:146`** paints its active sort arrow with raw `brandCta`, which measures
  1.40:1 and 1.95:1 on the light canvas. This page declined to add a second instance (D-4), so
  `/assets` needs nothing from the light pass; `/markets` does. Dark mode first, unchanged.
- **`resolveAssetsMarketData` is unexercised by any automated test** - the widget tests all go
  through the stub seam.

## Threat Flags

None. No new endpoint, no dependency added to `pubspec.yaml`, no key material, nothing signed. The
search query reaches `matchesAssetQuery` and nothing else, which is now checkable in a unit test
rather than asserted in a comment (T-25-02-02). The no-second-timer mitigation (T-25-02-03) and the
no-balance-write mitigation (T-25-02-04) are both enforced by grep gates rather than by convention.

## Known Stubs

None. Every row is fed from real cubit state through the real resolver; the only injected value is
the test seam, which is null in every production call site.

## Self-Check: PASSED

All five created files exist on disk. No commits were created, so there are no hashes to verify -
which is itself the expected outcome for this plan.
