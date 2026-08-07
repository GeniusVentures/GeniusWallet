---
date: 2026-08-07
walked_by: Jakub, iPhone 14 Pro Max "Sidney", dark mode
branch: redesign/navigation-260806
committed: nothing
---

# Walk record, 2026-08-07

Consolidated verdicts from the day's on-device walks, so the open decisions stop being open.

## Approved outright

| Thing | His verdict |
| --- | --- |
| Section rhythm, option B | the border-to-title gap is right - approved |
| Phase 25, one page scroll | the scrolling is fine, you can close the item |
| Drawer footer bottom inset, 54pt to 40pt | the explorer CTA looks pretty good |
| Assets section title back on the shared component (scheme A) | the title is right |
| The enlarged brand lockup, mark 28 / wordmark 18 | G-news looks good |
| The homepage as a whole | as far as the homepage goes, everything is in order |
| 24h percentage optically centred on the total | the % is nicely fixed, thanks |
| GNUS pinned first, `Unpriced` and `Populated` scenarios | 10. ok / 11. ok |
| Assets header height, 24h percent only, sibling comparison | 5/6/7/8 - all ok |
| `View all` gradient (later reversed by him, see below) | 9. works |

## Decided, with the reasoning recorded

- **Explorer CTA size: `leave-it`.** The census inverted the premise - 6 of 6 single-action drawer footers are `lg` + `expand`, so this button is the standard, not the outlier, and a sweep was unavailable (3 of the 6 sit under `/banxa` and `/squid_router`). The space fix delivered 14pt against the size change's 12pt.
- **`View all` back to flat grey.** He approved the gradient at 09:xx and reversed it later the same day. Both are recorded; the reversal is the live state. Side effect: with the links flat, the standing "max one gradient per surface" rule holds as written, the SWAP dock being the only gradient fill.
- **GNUS pinned first, everywhere.** Restores a rule phase 25 silently demoted to a tie-break. Lives in `compareAssetsByValue` so the dashboard panel and `/assets` cannot disagree.
- **Job wording: hybrid.** `Processing job` on completed rows, `Job` on failed, pending and cancelled - shown the measured table and chose it over both extremes. Accepted cost: the label's length varies with status.
- **Counterparty address stays** on send and receive rows; only the job hash was removed.
- **Wordmark is `GNUS.AI`**, matching the splash. He first said `GeniusAI`, was shown that the shipped `logo_and_title.png` renders `GNUS.AI`, and resolved it toward the existing asset.
- **Header position frozen.** Logo and pill both stay at the `AppBar` default 16. He narrowed this twice, ending at: just make the logo and the name bigger for now, leave the wallet and the alignment as they are, we will judge after the changes.

## Accepted by omission, and flagged as such

He wrote that whatever he had skipped over was probably fine, which covers these. They were built, put on the walk list, and not objected to - **but not individually confirmed**, so they are recorded here as accepted-by-omission rather than as approvals:

- **The pending mint still reads `Minte...`.** A measured 7.7px shortfall that removing the job hash did not touch, because mint's context is a qualifier and mint never printed a hash. Still worth its own task if it ever irritates him.
- Failed swap, escrow release and long-token-name rows.
- The drawer's `Job` copy row.
- The bar's 1px bottom edge and the two-tap network switch.

## Still genuinely open

1. ~~The wallet control's width.~~ **CLOSED 2026-08-07** - sketch 181 scheme F picked, then sketch 183 scheme F for its treatment (Jakub: let's try 183F, and if it turns out badly we can fall back to 183C later). 224px pill to a 44 + 12 + 44 = 100 cluster. Shipped in quick task `20260807-bottom-nav-s7`, uncommitted. The width crisis dissolved with it: the pill was a remainder absorber, the cluster is fixed, so free space in the title Row went 12.00 to 135.94.
2. **The bottom bar's destinations** - S7 (`Home, Assets, Swap, Activity, News`) built and awaiting the on-device walk. Plan and executor summary in `.planning/quick/20260807-bottom-nav-s7/`.

2a. **The hamburger's treatment is REOPENED and there is a red test saying so.** Jakub, 2026-08-07 after the walk: add a border around the hamburger menu as well - that is sketch 183 scheme **A**, both controls carrying the chip recipe, and I applied it to `mobile_header.dart` as an **evaluation toggle** rather than a decision. It is on device. `mobile_header_brand_and_pill_test.dart:521` ("THE TREATMENTS DIFFER ON PURPOSE") fails BY DESIGN, because that assertion pins F and the toggle contradicts it. **Do not "fix" that test.** Either the toggle is reverted (delete `backgroundColor` and `shape` from `HeaderMenuButton`'s `styleFrom`) or A is adopted and the assertion is rewritten inside a proper quick task. A's measured objection, unchanged: two identical stadiums 12px apart leave 12.00px of ink at a 56px pitch, which is segmented-control geometry.

2b. **The wallet control becomes a generic wallet icon.** Jakub, 2026-08-07: he would like a plain wallet icon shown there, next to the menu icon. Sketch 185 in progress. **This knocks the leg out from under F**: F's split was justified because the wallet held a value and the hamburger did not, and a generic glyph holds nothing either. So 183C (both bare) gains a real argument, and 2a above is being decided at the same moment the ground under it moves. Consequence to state when he picks: the header can then NEVER say which wallet is live, whereas the avatar could still have been recovered by 181-E's monogram.
3. ~~Mock transactions and holdings vanish on their own.~~ **CLOSED 2026-08-07** - Jakub on the vanishing mocks: ok, done. Two unguarded emits in `wallet_details_cubit.dart`: `getCoins()` was a check-then-act race (the dev guard ran BEFORE the await, the success emit after it re-checked only `isClosed`), and `loadInitial()` reset `coins` to `const []` with no guard at all, reachable from one accidental pull-to-refresh - and worse, `mockMode` stayed true afterwards so the other guard then blocked the refetch and the panel sat empty. Timing came from the log: `getCoins settled in 28517ms`, an RPC timing out and CoinGecko 429ing, so the delay was however long the in-flight fetch had left rather than any fixed interval. Both guards lead with the `kDebugMode && kShowDevTools` const pair, so release builds constant-fold them and the real data path is byte-identical. The transactions half was NOT reproduced - already fixed 2026-07-31 in `8c172866` - and one untested candidate remains: the dashboard panel caps at 5 rows, so if the live SGNUS feed returns anything newer than the batch, mock rows drop off the PANEL while still living on `/transactions`. Next occurrence, tap `View all` first.
4. ~~The 24h percentage is not vertically centred.~~ **CLOSED 2026-08-07** - `CrossAxisAlignment.baseline` to `.center`, drop 4.13px to 0.13px, approved on device. See quick task `260807-pct`.
5. **The `WalletPill` radius**, deferred by him - we judge it after the changes land. Finding on file: the pill is new but its stadium shape is not - the network chips in the drawer it opens use the identical `Material` + `StadiumBorder` + `borderControl` recipe and are literally the widget it replaced.
6. **The 114x114 logo export.** Without it, mark 28 is a 2.21x upscale and is as far as this asset goes; 32 is where blur is expected to show. Pure drop-in, same filename and folder.
7. **The dollar figure on the 24h change**, dropped when the total went to 24px. The new band has room again, about 10.4px of margin.
8. **Sketch 175's overflow pick** - still unanswered from earlier in the day, and sketch 182 may make it moot.
9. **The double-address header defect** - halved, not fixed. Root cause is the free-text name field at `import_security_screen.dart:236`; no code derives a name from an address.
10. **Duplicate page titles sweep**, parked at his request - Transactions is not the only affected screen.

## The Menu opens from the BOTTOM, decided 2026-08-07

Jakub, 2026-08-07: ok, so let's stay with the Menu that opens from the bottom. This **supersedes** the full-page-from-the-right
instruction and makes most of `.planning/quick/20260807-menu-page/PLAN.md` obsolete - that plan is built
around a top-level `/menu` route.

He raised the problem himself: the wallet control opens a surface you drag back down, the menu icon sits
12px away and looks the same, so a menu that slides in from the right would make two identical-looking
controls behave categorically differently.

What decided it, in order of weight:

1. **The inconsistency did not exist yet.** Today BOTH controls land on `showModalBottomSheet` -
   `AccountDrawer.show` via `ResponsiveDrawer.show`, `MoreSheet.show` via `GWBottomSheet.show`
   (`more_sheet.dart:22`, `responsive_drawer.dart:100-101, 162-168`), both `enableDrag: true`,
   `isDismissible: true`. The page would have INTRODUCED the problem, so the question was never how to
   fix it.
2. **The body and the container are independent.** Variant C - kickers, hairlines, nothing boxed - is
   what the menu LOOKS like, and it carries into a sheet unchanged. Choosing the sheet gives up nothing
   he picked.
3. **Four rows do not fill a screen.** His own screenshot showed roughly 40% of the page empty below
   Feedback. A sheet sized to its content states the truth about how much is in there.
4. **It costs nothing.** The hamburger already calls `MoreSheet.show(context)`. `endDrawer` appears
   NOWHERE in `lib/`, so the right-side panel would have been a new pattern, not a reuse.

Independently, the menu-page planner had already found that of three original arguments for a full page
only "it has children" survived, and that one falls too: `job_steps.dart:806` already pushes a route out
of a sheet.

**Still open under this decision:** Accounts has two doors - it is a row in the sheet AND the wallet icon
opens the same place directly. Decide whether the row goes.

Sketch 186 was started to compare the four containers and **stopped once he decided**, rather than run to
completion for a question that was already answered.

## The app keeps losing its debug connection

Three times on 2026-08-07: `Lost connection to device`, each time shortly after `SuperGeniusNode: Error
starting blockchain: Blockchain not fully initialized -> Scheduling blockchain retry after failure`, with
`HandshakeException: Connection terminated during handshake` on the price fetches and a
`TimeoutException` on bitcoin prices. An earlier launch died with `App terminated due to signal 11`,
which is native rather than Dart. Not investigated - relaunching clears it each time. Worth a debug
session if it ever happens to Jakub outside a `flutter run`.

## Not chased

`Bad state: Cannot emit new states after calling close` - a cubit emitting after disposal. Pre-existing, unrelated to any of today's work.
