---
phase: 12-transactions-redesign
plan: 03
subsystem: dashboard/transactions
tags: [row, drawer, layout, collapse, wcag, freeze-rule]
requires:
  - TransactionBadge / TransactionBadgeKind (12-01)
  - txRowContent / TxRowContent / TxAmountTone / livePricesBySymbol / formatTxAmount (12-02)
  - GWTokenRow geometry
  - ResponsiveDrawer.show
  - GWButton
provides:
  - TransactionRow
  - showTransactionDetails
affects: [12-04 (filters), 12-05 (panel assembly), 12-06 (walk)]
tech-stack:
  added: []
  patterns:
    - "Widget renders, derivation decides: no switch (tx.type) survives in the row"
    - "One identity builder parameterised by a literal size (40 row / 60 drawer), never by constraints"
    - "Detail rows assembled by an append-if-non-empty closure instead of per-type drawers"
key-files:
  created:
    - test/dashboard/transaction_row_test.dart
  modified:
    - lib/dashboard/home/widgets/transaction_displays.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
decisions:
  - "Swap badge anchors top-right (row and drawer); bottom-right is occupied by the to-token"
  - "Swap drawer uses From/To for the amount pairs and DROPS the counterparty address row — two rows labelled To is a defect, and a swap's counterparty is a router contract"
  - "A process drawer emits Job instead of Hash — same value, one row, not printed twice under two labels"
  - "Paired swap icons are local asset art only; the old NetworkImage(fromIconUrl) fired one fetch per visible row"
metrics:
  duration: ~50 min
  completed: 2026-07-22
requirements: [TX-01, TX-05, TX-06, TX-07, TX-09, TX-10]
status: complete
---

# Phase 12 Plan 03: One row, one drawer Summary

Four row widgets and three detail drawers collapsed into one `TransactionRow` and one
`showTransactionDetails`. `transaction_displays.dart` went **625 → 407 lines** (334 insertions,
552 deletions — a net removal of 218). The list's four-branch `switch (txs[i].type)` is gone; per-row
bordered cards are replaced by one surface with hairline `Divider`s.

## What was built

### `lib/dashboard/home/widgets/transaction_displays.dart` — rewritten

Exactly **one public class**: `TransactionRow({required Transaction tx, VoidCallback? onTap})`.
`grep -c '^class [A-Z]'` returns `1`.

Its `build` calls `txRowContent(tx, prices: livePricesBySymbol())` once and paints the record.
There is no `switch (tx.type)` and no status branching anywhere in it — the only `switch` in the
file is `_toneColor(TxAmountTone, GWColors)`, which reads 12-02's tone enum, not the model.

Geometry matches `GWTokenRow` exactly: `Material(transparent)` > `InkWell(radiusMd)` >
`Padding(horizontal: space6, vertical: space4)` > `Row`:

| Slot | Contents |
|---|---|
| Identity | 40×40 `Stack`; one coin `Image.asset` (or two 24×24 overlapped for a swap) + `TransactionBadge` on top |
| gap | `space6` |
| Main | `Expanded` — title + action chip row, `space2`, subtitle. All `maxLines: 1` + ellipsis |
| gap | `space4` |
| Amount | `ConstrainedBox(maxWidth: 132)` — amount (tone-coloured, 16px `numericBody`) + optional fiat line |
| gap | `space4` |
| Time | `SizedBox(width: 44)` — 13px `numericBody`, right-aligned |

`Tooltip` wraps the amount **only** when `content.exactAmount != null`, so a row whose amount was
not clamped carries no empty tooltip.

Deleted outright: `TransactionItem`, `TransactionPurchasedItem`, `TransactionSwappedItem`,
`TransactionEscrowReleaseItem`, `_buildCoinIconWithBadge`, both `_buildAmountTrailing` helpers,
`_buildOverlappedIcons`, `_buildSwapAmounts`, the three `_show*TransactionDetails` methods and the
file-level `currencyFormatter`. The `timeago`, `genius_wallet_colors` and `genius_wallet_decorations`
imports went with them.

### `showTransactionDetails(BuildContext, Transaction)` — one drawer for all seven types

Drawer title is `content.action`. Header is a centred 60×60 identity built by the **same**
`_identity()` the row uses, then the amount at `numericHeadline` in the tone colour. Rows are
assembled by an `add(label, value)` closure that skips anything empty:

`Date` (always `.toLocal()` now — the old `TransactionItem` drawer formatted the raw UTC stamp while
the other two localised it), `Status` (`gw.statusError` for failed/cancelled), the counterparty
`To`/`From`, `Network`, **`Network Fee`** (where the fee now lives), and `Hash`.

Swap adds `From` / `To` amount+symbol pairs and `Rate`. `process` labels its hash row `Job`.

The **View on Explorer** footer is now `null` when `getExplorerUrl()` returns empty — the old
`TransactionItem` rendered that button unconditionally, so on any chain missing from `explorerMap`
it was a button that did nothing.

`_buildRow`'s hardcoded `GeniusWalletColors.textPrimary70` became `gw.textPrimary70`, so the drawer
re-skins on a live appearance toggle.

### `lib/dashboard/home/widgets/transactions_slim_view.dart` — three surgical changes

- `itemBuilder` → `TransactionRow(tx:, onTap: () => showTransactionDetails(context, txs[i]))`.
  The four-branch `switch` is deleted, not moved.
- `separatorBuilder` → `Divider(height: 1, thickness: 1, color: gw.borderSubtle)` — the homepage
  pattern verbatim (`coins_screen.dart:311`), replacing the `SizedBox(height: space6)` that used to
  space the bordered cards apart.
- `ListView.separated` `padding` → `EdgeInsets.zero`, so the hairlines run full-bleed.

Filters, empty states and the footer are untouched (12-04 / 12-05 own those). 172 → 169 lines.

## The swap badge anchor decision

`TransactionBadge` is **last** in the identity `Stack` so it paints over the coin art. It sits at
`Positioned(right: -2, bottom: -2)` for a single-token row.

**For a swap it anchors `Positioned(right: -2, top: -2)` instead** — the bottom-right corner of a
paired identity is occupied by the to-token, and a bottom-right badge would land squarely on it.
This is deliberate and commented in place. It means a swap row's badge sits over the **top-right of
the from-token** (which occupies 0,0 → 24,24 in the 40×40 slot). **12-06 should look at this
directly** — arithmetic says it clears, but only an eyeball can say whether it reads as intentional
overlap or as collision.

## Two deliberate deviations from sketch 014, both forced by the AA constraint

1. **The time column and the em-dash amount are `gw.textSecondary`, not `--text-primary-38`.**
   The sketch paints both at 38% primary, which resolves to roughly **3.0:1** on the dark panel.
   Both are meaningful text — a timestamp and a "no amount" statement — so they take
   `textSecondary` (~5.4:1 dark, ~6.3:1 light). The shipped row is therefore lighter-weight-looking
   than the mockup in those two places. Do not "fix" it back.
2. **13px `labelMd` / 14px `bodySm`, not the sketch's 11px.** `genius_wallet_typography.dart`
   records "Floor raised 12→13: 12px read too small on a touchscreen". The action chip and subtitle
   use the project's own floor, so the row is a little taller and a little louder than the HTML.

(12-01 already recorded the third sketch divergence: the failed badge's glyph is computed ink, not
the sketch's white-on-`#FF4D4D` at 3.27:1. Unchanged here.)

## Deviations from Plan

**1. [Rule 1 — Bug] The swap drawer's `From`/`To` labels would have collided**
- **Found during:** Task 2(a).
- **Issue:** The plan asks for the counterparty address row (`To` when sent, `From` when received)
  **and additionally** `From`/`To` amount+symbol pairs for a swap. On a sent swap that produces two
  rows both labelled `To` with different values.
- **Fix:** for `swap` only, `From`/`To` carry the amount pairs and the counterparty address row is
  dropped. A swap's counterparty is a router contract, not a person, so the address was the less
  informative of the two. Every other type keeps the address row exactly as planned.

**2. [Rule 1 — Bug] The `process` drawer would have printed the same hash twice**
- **Issue:** The plan asks for a `Job` row carrying the short hash **and** a `Hash` row, which is
  `WalletUtils.getAddressForDisplay(tx.hash)` — the identical string under two labels.
- **Fix:** for `process` the row is labelled `Job`; for everything else, `Hash`. One row either way.

**3. [Rule 2 — Missing layout guard] `_buildRow` gained `maxLines: 1`**
- **Issue:** `_buildRow` had `overflow: TextOverflow.ellipsis` with no `maxLines`. Ellipsis without
  a line cap only trims the *last visible* line, and with no height constraint the `Text` simply
  wraps forever — so an unbounded model string (a malformed `fees`, a long `exchangeRate`) grows
  the drawer row without limit. That is T-12-02's threat, on the surface the plan explicitly widens.
- **Fix:** `maxLines: 1` added. Every value in this drawer is a short string or an already-truncated
  address, so nothing legitimate is lost.

**4. [Rule 2] `Network Fee` runs through `formatTxAmount(tx.fees)`**
- The plan specifies the raw `${tx.fees} ${tx.coinSymbol}`. `tx.fees` is an untrusted model string
  and the clamp is this phase's rule for exactly that; reusing 12-02's formatter costs nothing and
  closes the same hole as deviation 3. Consistent with 12-02's `process` value line, which already
  formats the fee.

**5. [Style] `_identity()` is one shared builder, and the fallback dot is a function**
- The plan describes the row identity and the drawer identity separately. Writing them twice is the
  duplication this plan exists to remove, so there is one `_identity(content, gw, {required size})`
  called with the literals `40` and `60`. The paired-icon sub-size is `size * 0.6`, i.e. the bounded
  set `{24, 36}` — **derived from a literal parameter, never from constraints**, so the 37639d5
  freeze rule holds.
- `_FallbackDot` is private in `gw_token_row.dart`, so its body was copied. It is a **function**
  `_fallbackDot(GWColors)`, not a class, which also keeps `grep -c '^class [A-Z]'` at exactly 1.

**6. [Scope] Dead `currencyFormatter` + `intl` import removed from `transactions_slim_view.dart`**
- The plan said "three surgical changes and nothing else". This is a fourth, but it is pure dead-code
  deletion: `currencyFormatter` was declared at line 14 and referenced nowhere in the file or the
  repo (grep-verified), and `intl` was imported only for it. 12-02 explicitly set up `formatFiat` so
  these duplicates could go. `transaction_displays.dart`'s copy was deleted as the plan required.

**7. [Scope] `test/dashboard/transaction_row_test.dart` was created — not in the plan**
- `./CLAUDE.md`: "Lazy code without its check is unfinished: non-trivial logic leaves ONE runnable
  check behind." 12-02's 40 unit tests pin every string this row prints but cannot see whether those
  strings **fit**, which is the one thing this plan could actually break. See below.

**8. [Scope] No commits created.** `./CLAUDE.md` holds the commit gate and the plan's `<objective>`
repeats it. Nothing was staged; `git diff --cached` is empty. The executor's per-task atomic-commit
protocol was suppressed for both tasks.

**9. [Scope] `STATE.md` / `ROADMAP.md` untouched**, consistent with 12-01 and 12-02 — the shared
working tree already carries the user's uncommitted edits to both.

## The one check left behind

`test/dashboard/transaction_row_test.dart` (188 lines, 50 tests) renders the **real** `TransactionRow`
for all seven `TransactionType` values plus a null type, `pending`, `failed` and a
`123456789.123456789123456789` whale with a 21-character symbol — at **320px** (narrower than the
dashboard's right-hand column ever gets) and **900px** (the full-page route), in **both
appearances**. Each case asserts `tester.takeException()` is null (a RenderFlex overflow surfaces
there) and that exactly one `TransactionBadge` is present — `escrowRelease` and `process` used to
render as a bare `ListTile` string with no icon at all, which is the regression that line guards.

**The check has teeth.** I re-ran a throwaway copy with the widths list forced to `[100]`: all 24
cases failed with RenderFlex overflow. The probe file was deleted (`git status` is clean of it).

It also carries the first real exercise of 12-02's `livePricesBySymbol()`, which the 12-02 summary
flagged as never executed:

| Path | Assertion | Real result |
|---|---|---|
| No Hive binding | `isBoxOpen` false → `const {}`, no throw | passes (and every one of the 48 layout tests runs through it) |
| Real box on disk | `Hive.box<CoinGeckoMarketData>` typing matches `init.dart`; keys lowercased | `{'eth': 2400.0}` |

The typed read is the part worth pinning: `Hive.box<T>` **throws** on a value-type mismatch, so this
would have failed loudly if `init.dart`'s typing ever diverged from `transaction_utils.dart`'s.

## Verification actually run

| Check | Command | Real output |
|---|---|---|
| Baseline before any edit | `flutter test` | `00:04 +94 -1: Some tests failed.` — matches the stated baseline |
| Task 1 analyze | `flutter analyze lib/dashboard/home/widgets/transaction_displays.dart` | `No issues found! (ran in 3.9s)` |
| Task 1 class count | `grep -c '^class [A-Z]' …/transaction_displays.dart` | `1` |
| Task 2 analyze | `flutter analyze lib/dashboard/home/widgets` | `No issues found! (ran in 7.4s)` |
| Whole project analyze | `flutter analyze lib test \| grep -i transaction` | no matches — the 62 remaining issues are all pre-existing and in unrelated files (`squid_router`, `web_view_mobile`, `token_info_*`) |
| New test alone | `flutter test test/dashboard/transaction_row_test.dart` | `00:02 +50: All tests passed!` |
| Overflow probe (throwaway) | same file with `widths = [100]` | `+0 -24` — all fail on RenderFlex overflow, then deleted |
| Full suite | `flutter test` | `00:05 +144 -1: Some tests failed.` — **94 + 50 = 144** |
| Sole failure unchanged | `flutter test \| grep '\[E\]'` | `Failed to load ".../test/local_wallet_storage_test.dart": Missing definition of 'main' method.` — the pre-existing, entirely-commented-out file. Still the only red. |
| The collapse | `git diff --stat …/transaction_displays.dart` | `334 insertions(+), 552 deletions(-)` — deletions dominate, as required |
| No `Fee:` on a resting row | `grep -rn "Fee:" lib/dashboard/` | one hit, and it is 12-02's doc comment explaining the removal |
| No per-row `NetworkImage` | `grep -rn NetworkImage lib/dashboard/` | one hit, and it is my comment explaining the removal; the other is `CachedNetworkImage` in the news screen |
| All three mount points | `grep -rn "TransactionsSlimView\|TransactionsStream" lib` | `dashboard_screen.dart:366`, `transactions_screen.dart:31`, `sgnus_transactions_screen.dart:48` — all three compile under the whole-project analyze above |
| Nothing staged | `git diff --cached --stat` | empty |

## NOT verified — nothing was rendered

**No app run. No screenshot. No golden.** `flutter run -d macos` needs an interactive foreground
session this executor cannot hold, and hard rule 10 forbids backgrounding it. Everything below is
open until 12-06 walks it:

- **The paired swap identity has never been seen.** Three specific things need a human eye:
  1. **The art source changed.** The old `_buildOverlappedIcons` used `NetworkImage(tx.fromIconUrl)`
     / `toIconUrl`; the new slot uses local `assets/images/crypto/<sanitised symbol>.png`. A swap
     into a token with **no local PNG now shows the fallback dot** where it previously showed
     remote art. This is a deliberate trade (a network fetch per visible row in a scrolling list is
     T-12-02), but it is a visible behaviour change and the dev mock swap batch should be checked.
  2. **The two icons use different fits.** From-token is `BoxFit.contain`; to-token is `ClipOval` +
     `BoxFit.cover` inside its 2px `gw.surfaceElevated` ring (the ring reads as a circle, so its
     content should fill it). Square coin art with transparent padding may crop under `cover`.
  3. **The fallback dot inside a 24×24 paired slot.** `CircleAvatar(radius: 20)` is constrained down
     to 24 by the parent `SizedBox`, but its `Icon(size: 18)` is not — so the fallback glyph will
     look proportionally much larger in a swap slot than in a single-token slot.
- **The badge ring against real coin art.** `TransactionBadge` defaults its ring to
  `gw.surfaceElevated`; whether that reads as "punched through" on the transactions panel's actual
  surface is 12-06's call.
- **The em dash and U+2212 real minus at render size** — still asserted only as strings (12-02's
  open item, unchanged).
- **The drawer has never been opened.** Layout tests cover the row, not `showTransactionDetails`.
  The 60px identity, the `numericHeadline` amount and the suppressed explorer footer are
  analyze-clean and nothing more.
- **Light mode is measured, not seen** — the layout tests run in both appearances, but only for
  overflow, not for how it looks.

## Success criteria

- [x] One row widget serves all seven transaction types; the list's type `switch` is gone
- [x] A processing-job row and a swap row both render icon, title, action chip, meta line, amount column and time
- [x] A swap row shows both tokens in its identity slot
- [x] No `Fee:` on any resting row; the fee appears once, in the drawer
- [x] No row prints a currency zero twice (12-02 owns this; the row renders `content.amount` verbatim)
- [x] Rows separated by `Divider(height: 1, thickness: 1, color: gw.borderSubtle)`
- [x] `transaction_displays.dart` came out materially shorter (625 → 407)
- [x] No commit created

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transaction_displays.dart` — FOUND (407 lines, modified)
- `lib/dashboard/home/widgets/transactions_slim_view.dart` — FOUND (169 lines, modified)
- `test/dashboard/transaction_row_test.dart` — FOUND (188 lines, created)
- `TransactionRow` / `showTransactionDetails` — both present and referenced from `transactions_slim_view.dart`
- Commits — intentionally none (CLAUDE.md gate); nothing staged.
