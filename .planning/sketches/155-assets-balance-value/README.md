---
sketch: 155
name: assets-balance-value
question: "The Assets panel's total reads as bolted on. What treatment does the dashboard total value deserve, given the same dollar figure is already printed 12px to its left from a different source?"
winner: null
tags: [dashboard, assets, balance, total, delta, typography, data-honesty, gw-section-title]
lane: B
---

# Sketch 155: The Assets balance value

Jakub, 2026-07-27: *"chodzi mi glownie o zmiane wartosci balancu tu, wymysl cos bo wyglada srednio"* -
with an arrow pointing at `$6,090.00 / +$82.91 · +1.36%` in the Assets panel header.

## Design Question

What ships is `coins_screen.dart:258-284`: a `GWSectionTitle` whose `trailing` is a centred two-line
column - the total at 20px/w700 over a delta string in `labelMd`, tinted whole.

```dart
Text(currencyFormatter.format(total), ... fontSize: 20, fontWeight: FontWeight.w700)
if (total > 0)
  Text('${dayChange >= 0 ? '+' : ''}${currencyFormatter.format(dayChange)} · '
       '${dayChange >= 0 ? '+' : ''}${pctOfTotal.toStringAsFixed(2)}%',
       style: labelMd.copyWith(color: dayChange >= 0 ? gw.statusSuccess : gw.statusError))
```

The number is real. `assetsTotal()` and `assetsDayChange()` (`components/coins/assets_totals.dart`)
fold `balance x price` and `balance x price x pct/100` over the live CoinGecko rows, and are unit-tested.
**Nothing in this sketch changes the maths.** The question is only how those two facts should read.

## How to View

```
open .planning/sketches/155-assets-balance-value/index.html
```

Deep links `#a` .. `#e`. Toolbar: six variants, the day state (**Up / Down / Zero**), an **Axes** toggle
that draws the 44px title row and the trailing column so the geometry problem is visible rather than
described, and Light/Dark. The four asset rows below are identical in every variant on purpose - only the
header changes.

## Findings from the code

1. **The same dollar figure is printed twice on one row, from two different sources.**
   `wallet_overview.dart:138` renders `state.selectedWalletBalance` - a string the `WalletDetailsCubit`
   sets from the wallet's own balance (`wallet_details_cubit.dart:46,102`) - as **Current Balance** in the
   left card. The Assets header renders `assetsTotal()`, a CoinGecko fold, 12px to its right. Both carry a
   `$` and neither says what it is. They match in the screenshot because `injectMockCoins` sets both from
   `DevMockHoldings`; **nothing makes them agree in production**, and they poll on different clocks.
   Sketch 016 finding 4 named this as a *unit* clash (GNUS vs USD) before Phase 5; after the re-skin both
   are dollars, so it has become an exact-looking duplicate, which is worse.
2. **The trailing column is vertically centred inside a 44px row.** `GWSectionTitle` wraps its Row in
   `ConstrainedBox(minHeight: 44)` (sketch 004). Two lines of 20px + 13px need ~42px, so the block fills the
   row edge to edge and the total's cap-height rides above the word "Assets". That crowding is most of the
   "wyglada srednio".
3. **The delta joins a rate and an amount at equal rank.** `+$82.91` is money, `+1.36%` is a rate; they are
   separated by a literal `' · '` inside the format string and flooded with one colour. No hierarchy exists
   to read.
4. **`total == 0` already suppresses the delta** (`if (total > 0)`). Every variant keeps that rule, so the
   zero-value footer (Receive / Buy GNUS) is unaffected.
5. **The cents are at full weight.** `$6,090.00` spends four glyphs on a precision nobody scans for at a
   glance.

## Variants

- **0 · Today** - literal render of what ships. Reference, not a proposal.
- **A · Value + chip ★** - the percentage becomes a filled pill, the dollars become quiet grey context, the
  mid-dot is replaced by the word *today*, cents drop to `textPrimary54`. Total 26px/w700.
- **B · Eyebrow stack** - a `TOTAL VALUE` kicker above the number. The only variant that fixes finding 1 by
  *naming* the number. Costs a third line, so the shared title row grows to 56px.
- **C · Sparkline** - number + chip + a 24h portfolio sparkline. Drawn so the cost is visible: **there is no
  portfolio time series in this app.** `BUILD`, not a paint job.
- **D · Balance band** - the total leaves the trailing slot for its own full-width band under the title,
  32px/w700, with room for a provenance line. Costs ~24px of panel height.
- **E · Quiet ledger** - only the arrow glyph carries status colour; the numbers stay `textSecondary`.

## Recommendation

**★ A · Value + chip.** It is the smallest diff that fixes findings 2, 3 and 5 at once: one chip widget, one
opacity on the cents, one string change, and the title row's `minHeight` from 44 to 52. It borrows a shape
the app already uses - the per-coin `+3.20%` pills in the rows directly beneath - so the header stops looking
like a different designer's work from the list it sits on top of.

**Runner-up: D · Balance band.** Structurally the best answer, and the only one with somewhere to put a
provenance line. Take it **if and only if** the left card's *Current Balance* is being restructured anyway -
sketch **016 B2 "Twin tiles"** does exactly that and is already chosen but unbuilt. Two 32px hero balances
12px apart would be worse than what ships today.

**B is not rejected, it is A's other half.** A fixes the geometry; B fixes the ambiguity. If the answer to
finding 1 is "keep both numbers", then take **A + B's eyebrow** - the eyebrow is one 10px line and it is the
cheapest possible defence against a user reading two different sources as one balance.

**Rejected: C · Sparkline.** It promises a portfolio history the code does not have. `CryptoSparkLineChart`
in the Markets rows is a per-coin fetch and cannot be summed into a portfolio line without per-holding
history at matched timestamps. Drawing it now would ship a chart that has to be faked.

**E** is the honest minority report: a whole panel where a bad day is invisible. Worth 30 seconds of looking
at on the **Down** state before dismissing.

## What to Look For

1. **Turn Axes on, on variant 0.** The dashed boxes are the 44px title row and the trailing column. That is
   the crowding, measured.
2. **Cycle Up / Down on A and E.** A floods the chip, E colours one glyph. Which one do you want a red day
   to look like?
3. **Zero.** Every variant must degrade to a bare `$0.00` with no delta - that is shipped behaviour, not a
   design choice, and it is what the Receive / Buy GNUS footer sits under.
4. **Look at the rows under the header while you switch.** The `+3.20%` pills are already there. A borrows
   them; 0 does not.
5. **Read the left card in the app while looking at D.** Two hero balances is the trap D walks into unless
   016 lands first.

## Open questions for the executor

- Does `GWSectionTitle`'s 44px `minHeight` become 52 for every panel, or does Assets get a per-call-site
  override? Sketch 004 unified it deliberately; raising it moves Markets and Transactions too.
- If A is taken, the `' · '` string in `coins_screen.dart:275` splits into two widgets. That string is
  currently one `Text` - the split is the only real code change.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 155 | assets-balance-value | The Assets total reads as bolted on: 20px/w700 over a mid-dot-joined delta string, centred in a 44px title row. What treatment does it deserve? | _pending pick_ (rec **A · Value + chip** - % becomes a filled pill matching the row pills below, dollars go quiet, cents at 54%, "today" replaces the mid-dot; runner-up **D · Balance band** but ONLY with 016-B2, else two hero balances 12px apart; **B · Eyebrow stack** is A's other half - take its `TOTAL VALUE` kicker if both balances stay; rejected **C · Sparkline** - no portfolio time series exists; **E · Quiet ledger** = only the arrow carries colour). Findings: the same `$` figure is printed twice on one row from two sources (`selectedWalletBalance` vs `assetsTotal()`), the trailing column is wedged in a 44px row, and the delta joins a rate and an amount at equal rank. | dashboard, assets, balance, total, delta, typography, data-honesty, gw-section-title |
```
