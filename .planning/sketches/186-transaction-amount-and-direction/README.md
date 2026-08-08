---
sketch: 186
name: transaction-amount-and-direction
question: >
  Jakub, 2026-08-07, twice in one message. (1) The transactions situation is grating - he thinks a colour
  was changed on Processing job / Sent / Received / Card purchase. (2) The right-hand side shows things
  differently row to row, especially the colours - the plus/minus per token and the value are inconsistent,
  and on BTC you only see how much BTC with no conversion of what it was worth. Three whole schemes for
  the AMOUNT COLUMN and its direction signal, judged on six row states including the unpriced BTC row.
winner: null
tags: >
  mobile, ios, transactions, row, amount-column, direction, tone, sign-glyph, fiat, value-line,
  missing-price, structural-jitter, badge, status-colour, subtitle-lead, contrast, wcag-1.4.11,
  wcag-1.4.1, tabular-figures, code-grounded, follows-179, follows-183, follows-185
---

# Sketch 186 - the transaction row's amount column, and what carries direction

http://localhost:8899/186-transaction-amount-and-direction/

Direct continuation of `179-transaction-row-action-tag`, whose scheme **C** shipped this afternoon in
`0cd2889b` and is what Jakub is looking at. 179 fixed the left half of the row. This is the right half,
plus the one thing 179 changed on the left that he noticed.

## Correction to the brief, first, because everything else stands on it

This sketch was commissioned with a stated fact: that **today's diff changed no colour line at all**, and
that Jakub's memory of a colour decision was therefore about the lead-versus-context split rather than
about the lead versus the ticker. The reasoning attached was sound - a scheme that fixes a change that
never happened is built on sand.

**The premise is wrong.** `git show 0cd2889b` disagrees, and so does the commit's own message body:

> Lead and context are separated by COLOUR rather than by weight or a separator - textPrimary against
> textSecondary, 19.4:1 against 6.01:1.

Here is the whole of it, both sides, from the two blobs:

| | Before today (`d5993c58`) | After today (`0cd2889b` + `260807-ubg`) |
| --- | --- | --- |
| where the word sits | a chip **beside the ticker**, on the title line | **leading the subtitle**, on the second line |
| container | `gw.surfaceMenu` box, `radiusXs` | none, deleted |
| token | `labelMd` 13, shrunk to **11** on a phone | `bodySm` **14** |
| weight | w500 | **w600** |
| **colour** | **`gw.textSecondary` #8A8F9D** | **`gw.textPrimary` #FFFFFF** |

The four strings that moved are `_actionFor`'s output: `Sent`, `Received`, `Card purchase`,
`Processing job` - **exactly the four Jakub named, and no others**. His memory is correct and it is
specific.

What is inverted is the direction. He remembers the change being made *so it would not be the same
colour as the ticker*. The ticker - `content.title`, the row headline - is `gw.textPrimary` at w600 and
has been throughout; nothing touched it. So the change did not separate the lead from the ticker, it
**collapsed them together**:

| | ticker | lead, after today |
| --- | --- | --- |
| colour | `textPrimary` #FFFFFF | **`textPrimary` #FFFFFF** |
| weight | w600 | **w600** |
| size | `titleMd` **16** | `bodySm` **14** |
| ratio between the two inks | | **1.00:1** |

**Two pieces of text, 4px apart vertically, in the same ink at the same weight, differing by 2px of
size.** That is the whole of complaint 1, and it is a real defect rather than a misremembering. It got
worse this evening, not better: the uncommitted `260807-ubg` work removed the phone type scale, so the
gap that used to be 14 against 11 is now 16 against 14.

One smaller correction while the diff is open. The shipped comment cites **19.4:1 / 6.01:1**. Those are
the ratios against **`surfaceBase` #0B0D12**, the page canvas. The row is drawn inside a `GWCard`, and
`GWDecorations._surfaceSheenDark` has **the same stop twice**, so the row's canvas is a flat
**`surfaceElevated` #0C0E14**. The correct pair is **19.29:1 / 5.97:1**. Both still pass; the numbers in
the file are measured against a surface the row does not sit on.

### What this sketch does about it

Complaint 1 is a **lead** question and complaints 2 is an **amount column** question, and mixing them
would make three schemes that each move two variables. So the lead is an independent control, live in
all four panes, and the three schemes are judged with it held wherever you leave it:

| | Lead treatment | on #0C0E14 | vs context #8A8F9D | vs ticker #FFFFFF |
| --- | --- | ---: | ---: | ---: |
| **L1** | `textPrimary` - what ships tonight | 19.29:1 | 3.23:1 | **1.00:1** |
| **L2** | white 70% `#B6B7B8` | 9.60:1 | 1.61:1 | **2.01:1** |
| **L3** | `textSecondary` w600 - weight only | 5.97:1 | **1.00:1** | 3.23:1 |

**L2 is not my invention - the shipped file names it.** The comment beside the lead ends: *"Named
fallback if white reads too hot on the second line: white at 70%, still well clear of AA."* This is the
condition that fallback was written for. It keeps **1.61:1** of separation from the context beside it
(weak, but the w600 step carries the rest) and buys **2.01:1** against the ticker above it, which is the
thing complaint 1 is about. L3 gives the ticker a clean 3.23:1 but hands the lead-versus-context job
entirely to one weight step - the exact arrangement Jakub rejected on device this morning, in those
words. **My reading: L2.** It is a one-token edit and it is the only option that improves the pairing he
complained about without reopening the one he already ruled on.

## The two real defects, confirmed in code

### A. The tone rule is asymmetric, and it is the *third* statement of the same fact

`_toneColor` (`transaction_displays.dart:168-172`) is three arms:

```
incoming -> gw.statusSuccess     green
outgoing -> gw.textPrimary       the row's default ink, i.e. no colour at all
none     -> gw.textSecondary
```

The sign is already inside the string. `transaction_utils.dart:608` and `:618` compose
`'${outgoing ? _minus : '+'} ...'`, and `_minus` is **U+2212 REAL MINUS**, chosen by a comment that says
why: same advance width as `+` under tabular figures. Measured against the shipped
`Inter-SemiBold.ttf` at the row's 16px: **`+` = 10.35px, `−` = 10.35px.** The comment is true and the
column stays aligned.

The part the brief did not have, and it is the one that decides the sketch: **the badge already states
direction in colour, in both directions, at the left wall.** `badgeSpec`
(`transaction_badge.dart:44-55`):

| kind | fill | glyph |
| --- | --- | --- |
| `sent` | `statusNeutral` **#64748B**, 4.05:1 | `Icons.north_east` |
| `received` | `statusSuccess` **#0AD89C**, 10.39:1 | `Icons.south_west` |

So on a credit the row says "money came in" **three times** - badge fill, badge arrow, sign glyph - and
then tints the number a fourth. On a debit it says it twice and the tint contributes nothing, because
`textPrimary` is what every other ink in the row already is. **The asymmetry Jakub felt is real, and it
is not that one direction lost its colour. It is that one direction never needed it.**

### B. The value line vanishes, and the cost is not the one you would guess

`amountColumn` renders its second child only `if (content.valueLine != null)` (`:342`). `_fiatLine`
returns null when the amount will not parse **or** when `fiatValue()` finds no key for the symbol.
`livePricesBySymbol()` returns whatever the **Assets** fetch happened to load into the Hive market box -
the transactions surface adds no network call of its own, which its own doc states plainly. BTC is not
in that map. Jakub's device log agrees: `Historical - API error (404): coin not found`.

The intuitive complaint is "the rows are different heights". Measured, that is **almost false**, and the
near-falseness is the trap - it makes this look like a non-defect:

| | priced row | BTC row | delta |
| --- | ---: | ---: | ---: |
| amount column height | 46.857 | 22.857 | 24.000 |
| name column height | 46.000 | 46.000 | 0.000 |
| **row height** | 70.857 | 70.000 | **0.857** |
| **amount first-line top edge** | 0.000 | 11.571 | **11.571** |

The name column is the taller of the two, so it sets the row and the height barely moves. But `Row`
centres its children (`CrossAxisAlignment.center`, the default), and a one-line amount column centred
inside a 46.00px block sits **11.571px lower** than a two-line one. **The BTC amount drops more than
half a text line out of the column its neighbours share** - a visible break in a right-aligned stack,
with no height change to explain it. The sketch draws this: set the overlay to **amount baseline** and
the hairline steps on `NOW` and runs straight on A, B and C. Flip **BTC price** to *present* and the
step vanishes, which is the proof that the missing line is the entire cause.

Derived from Flutter's own line metrics: `height` is a multiplier, so `numericBody`'s `20/14` at
`fontSize: 16` is a **22.857px** line, not 20.

**The one exception that must survive every scheme:** a failed or cancelled row sets
`valueLine = 'Not charged'` and `tone = none`. Its own comment calls it load-bearing - *"`− 0.75 ETH`
with no value line reads as a wallet that lost 0.75 ETH. Never drop it."* All three schemes keep it, and
two of them make it louder.

## Geometry, derived from the measured card

Not guessed. `SEPARATOR-RHYTHM-MEASURED.md` puts the card **content box at x = 13, width 364.00** on a
390pt phone, and records that the `/transactions` page is byte-identical to the dashboard panel on every
number in that document. The rest is `gw_row_rhythm.dart`, shipped this afternoon.

| | width |
| --- | ---: |
| card content box (measured) | **364.00** |
| less `kGWRowWall` 8, both sides | 348.00 |
| less `kGWRowIconSize` **38** | 310.00 |
| less `kGWRowIconToText` 8 | 302.00 |
| less the name/amount gutter `space4` 8 | 294.00 |
| split 1:1 (`Expanded` / `Expanded`) | **147.00** name, **147.00** amount |

Every string on the phone is the shipping Inter, inlined as a subset of `Inter-Regular.ttf` and
`Inter-SemiBold.ttf` and verified **byte-exact in advance widths** against the full files - delta 0.0000
on every string measured here, with `tnum` preserved. Without the real font the page would measure a
system fallback and every number below would be a different number.

| String | style | width | fits 147.00 |
| --- | --- | ---: | --- |
| `+ 1,250.00 GNUS` | amount, 16 w600 tabular | 135.96 | yes, 11.04 spare |
| `− 0.0042 BTC` | amount | 107.90 | yes |
| `+ 0.0500 BTC` | amount | **107.90** | **identical - tabular proved** |
| `− 0.00420000 BTC` | amount | 149.30 | **no, ellipsises by 2.30** |
| `Processing job` | lead, 14 w600 | 100.37 | yes, 46.63 spare |
| `Card purchase` | lead | 99.78 | yes |
| `Not charged` | value, 14 w400 | 82.19 | yes |
| `No price` | value | **56.27** | yes, 90.73 spare |

And the subtitle paragraph, which is the name column less `space2` less the status tail:

| status | tail | tail width | paragraph |
| --- | --- | ---: | ---: |
| completed | none | 0.00 | **147.00** |
| failed | `Failed` | 39.64 | 103.36 |
| pending | `Pending` | 54.20 | **88.80** |
| cancelled | `Cancelled` | 66.04 | 76.96 |

**Two findings fall straight out of that table, and both are corrections to live comments.**

**(1) `Processing job` no longer ellipsises on a completed row.** The brief and the file both expect it
to. At 100.37 in 147.00 it fits with 46.63 to spare. The comment's 113.0px line and the
`260807-ubg` plan's ~150px derivation both predate this afternoon's geometry - the 1:1 flex, the 38
glyph and the 8 wall together give the paragraph more room than either predicted. The sketch draws it
un-clipped because that is what renders.

**(2) The status-varying wording rule is still correct, and only just.** `Processing job` needs
100.37 + 12.10 of ellipsis; the pending paragraph is 88.80 and the cancelled one 76.96, so both cut, and
`Job` at 25.38 clears every case. But the **failed** paragraph is now **103.36**, and `Processing job`
is **100.37** - it would fit, with 2.99 to spare. One arm of a four-arm rule has quietly stopped being
necessary. Not this sketch's decision to make; recorded so it is not rediscovered.

## The three schemes

All three fix defect **B** the same way, because there is only one honest fix: the second line always
occupies its slot. They differ entirely on defect **A**.

### A - neutral amount, fixed two-line slot ★

**The number is never a colour. The slot is never empty.** Direction rides on the `+`/`−` glyph already
in the string and on the badge that already states it symmetrically. Colour is thereby **freed** for the
one thing a sign cannot say: status.

The argument for removing a duplicated cue is not mine - it is already load-bearing three lines away in
`TxRowContent.statusTail`'s doc (`transaction_utils.dart:285-289`), where sketch 179's leading middle
dot was deleted:

> the row pins this to the right edge as a separate element with its own `space2` gutter, so **a
> separator between two already-separated elements does nothing** - and the 8px the dot costs is exactly
> what makes a pending mint render `Minte…` instead of `Minted`

Swap "separator" for "direction cue" and the sentence needs no other edit. The tint restates a fact the
sign and the badge have already stated, and unlike the dot it does not cost width. It costs something
worse: **the ability of colour to mean anything else in that column.**

And it is a weak cue on its own terms. Measured as ink against ink, which is what "these two amounts
differ" actually asks:

| pairing | ratio | 3:1 (WCAG 2.2 1.4.11) |
| --- | ---: | --- |
| `statusSuccess` against `textPrimary` - **the entire green/white distinction** | **1.86:1** | **fail, by more than half** |
| `statusNeutral` against `statusSuccess` - the two badge fills | **2.56:1** | fail |
| `+` against `−` | a **shape** at 19.29:1 | n/a, and that is the point |

Where the colour goes instead, all of it width-free because these elements are already drawn:

| Element | Today | A | on #0C0E14 | AA |
| --- | --- | --- | ---: | --- |
| amount, live row | green or white | `textPrimary` always | 19.29 | PASS |
| amount, dead row | `textSecondary` | `textSecondary`, kept | 5.97 | PASS |
| `Not charged` | `textSecondary` | **`statusError`** | 5.90 | PASS |
| tail `Pending` | `textSecondary` | **`statusWarning`** | 12.11 | PASS |
| tail `Failed` | `textSecondary` | **`statusError`** | 5.90 | PASS |
| value line, priced | `textSecondary` | unchanged | 5.97 | PASS |
| value line, **unpriced** | **absent** | **`No price`** | 5.97 | PASS |

Today `Pending` is the same grey as the address 4px to its left. That is the colour A recovers, and it
costs zero pixels - `_narrowStatusMaxWidth`'s 76 cap is untouched.

**Why `No price` and not a dash.** A bare em dash is ruled out **by this codebase in writing**:
`transaction_utils.dart:185-187` records that 15-01 removed the last `_emDash` assignment under
*"TT-06: no row prints a dash where the number belongs"*. `$0.00` is ruled out just as explicitly by
`fiatValue`'s doc - *"Inventing a zero is the same defect sketch 010 flagged on the failed row."* That
leaves a real phrase. Measured alternatives: `Price unavailable` 112.61 (fits, but it becomes the
loudest string in a column of numbers), `Unpriced` 60.66 (jargon), `—` 14.00 (banned above).
`No price` at 56.27 is shorter than the `Not charged` the failed row already prints in that slot.

**The honest cost: a credit stops being green.** That is a genuine loss of a pre-attentive marker for a
colour-normal reader and this README will not pretend otherwise. What replaces it is not nothing: the
badge is green with a south-west arrow on exactly those rows, and it sits at the **left wall where the
eye enters the row**, not at the right edge where it leaves.

### B - tinted in, neutral out, stated as a rule

Everything in A, except the credit keeps its green - and the debit's neutral becomes a **declared rule**
rather than the accident it is today (`outgoing -> textPrimary` reads in the source like a colour
decision; it is the absence of one).

B exists because the strongest objection to A is behavioural, not numeric: **money coming in is what
people scan a history for**, and green is this app's success colour in a dozen places already.

**What B has to defend, and it can.** "Why is the debit not coloured too?" - because a red debit would
be a lie. `statusError` is this app's failure colour and a successful send is not a failure. The
codebase already argues exactly this, in the dead-status block: *"incoming -> statusSuccess GREEN on a
failed receive would be actively false; green is this app's success colour."* Read backwards, that is
B's defence, and it is a real one.

**What B cannot defend.** The 1.86:1 above. B spends the column's only colour channel on a distinction
measuring less than a third of what 1.4.11 asks of a non-text indicator, on a signal the sign glyph and
the badge both already carry - and it then has to place the status colours somewhere that does not
collide, which it does, on the tail. That works. It also means **colour means two different things in
one row**:

| Colour | In A it means | In B it means |
| --- | --- | --- |
| `statusSuccess` | nothing in this column | the amount is a credit |
| `statusWarning` | this row is pending | this row is pending |
| `statusError` | this row failed, no money moved | this row failed, no money moved |
| `textPrimary` | this is the amount | the amount is a debit |

**So: the asymmetry Jakub noticed survives in B, by choice.** I am not going to dress that up. B answers
him with "yes, and here is why", where A answers with "yes, and it is gone". The reason B stays on the
page is that it is **one ternary from A in either direction** and fixes complaint 2 completely on its
own, so A and B are a safe pair to settle on Sidney rather than on a screen.

### C - value-first hierarchy

The fiat becomes the primary line at `numericBody` 16 w600; the token amount drops to the caption at
`bodySm` 14. Direction rides on a **coloured sign glyph only**, not on the whole number.

The argument is genuinely good: what a person asks a history is *how much money moved*, and
`0.0500 BTC` answers that for nobody without a price in their head. Width is not the obstacle -
`− $2,341.90` is 95.76 in a 147.00 column and `0.75 ETH` is 60.89.

**The finding that kills it, and it is not about layout.** `fiatValue()` multiplies the transaction's
amount by `CoinGeckoMarketData.currentPrice` - **today's price**, read out of the market cache the
Assets panel filled. Applied to a transaction from last month, the number it produces is **not what that
transaction was worth**; it is what those tokens are worth now. The app knows: the device log shows it
asking for a historical price and being refused, `Historical - API error (404)`. **So C promotes to the
headline the least reliable number in the row, and demotes to a caption the only number that is a ledger
fact.** A and B leave it where it is - quiet, secondary, and honest about its own standing.

**And the missing-price row breaks the scheme, not just the row.** A and B answer an absent price with
one word in a slot that was being drawn anyway. C has no such answer, because what is missing is its
**headline**. There are three moves and all three are bad:

| Move | Result |
| --- | --- |
| `No price` as the headline | The largest, boldest thing in the row is an apology. Worse than today. |
| Drop the headline | Exactly the defect this sketch exists to remove, promoted to the primary line. |
| **Fall back to token-first** | What the sketch draws. The row inverts its own hierarchy, so the BTC row means something different from its neighbours **by construction**. **C degrades into A on precisely the row that prompted the work.** |

A scheme whose answer to its worst case is "become a different scheme" has told you which scheme to
ship. The rest of C's cost, for completeness: it is the largest diff by a distance (a new
`TxRowContent` field so the fiat arrives unformatted, a rewritten `amountColumn`, and the receipt
drawer, which prints the same two values at `numericHeadline`); it demotes the token amount that
010-A made the row's organising fact; colouring only the sign shrinks the colour cue to a 10.35px target
for a 3:1 rule; and the `process` row has no clean form, because its value line is `$0.53 fee` and the
word is part of the string.

## The six row states, and why these six

Every scheme is drawn against all six in the same phone, so it is judged on its worst case:

| # | Row | What it tests | Lead |
| --- | --- | --- | --- |
| 1 | ETH send, completed, priced | the plain debit | `Sent` |
| 2 | GNUS receive, completed, priced | the plain credit - where green lives | `Received` |
| 3 | **BTC receive, completed, NO PRICE** | **Jakub's row.** Green *and* a missing line at once | `Received` |
| 4 | USDC card purchase, **failed** | `Not charged`, tone `none`, and the tightest paragraph on the page | `Card purchase` |
| 5 | ETH send, **pending** | pending is not dead - tone and value line are the completed derivation | `Sent` |
| 6 | GNUS **processing job**, completed | the fee IS the amount; the longest lead | `Processing job` |

That set covers **all four strings Jakub named** in complaint 1, which is why the failed row is a card
purchase rather than another send.

Two details in there are derivations people get wrong, so they are drawn rather than described. A
**card purchase is `+`, not `−`**: `purchase` is not `transfer`, so `outgoing` is false and the tone is
`incoming` - you receive the crypto. And **row 4 is the tightest line on the page**: `Card purchase`
99.78 inside the failed row's 103.36 paragraph, **3.58px of slack**. Fits, measured, and worth knowing
before someone adds a word to a status label.

Prices used, so the fiat arithmetic is checkable rather than decorative: ETH $3,122.53, GNUS $0.42,
USDC $1.00, and BTC deliberately absent from the map. The hypothetical BTC price behind the toggle is
$96,251.00.

## Contrast, computed against the surface the row is actually drawn on

WCAG 2.x sRGB relative luminance, against **`surfaceElevated` #0C0E14** - the flat card fill, because
`GWDecorations._surfaceSheenDark` has the same stop at both ends. Translucent values are composited
first, then measured.

| Token | Value | on #0C0E14 | AA text 4.5:1 |
| --- | --- | ---: | --- |
| `textPrimary` | #FFFFFF | **19.29:1** | PASS |
| `textPrimary70` composited | #B6B7B8 | **9.60:1** | PASS |
| `textSecondary` | #8A8F9D | **5.97:1** | PASS |
| `statusSuccess` | #0AD89C | **10.39:1** | PASS |
| `statusWarning` | #FFC42E | **12.11:1** | PASS |
| `statusError` | #FF4D4D | **5.90:1** | PASS |
| `statusNeutral` (badge fill) | #64748B | 4.05:1 | fill, not text |
| `brandPrimaryStrong` (job badge fill) | #0AAEE6 | 7.54:1 | fill, not text |
| `borderSubtle` 12% - the row rule | #292B30 | 1.36:1 | fail, shipped knowingly |
| `surfaceMenu` on the card | #171A21 | 1.11:1 | the fill that identifies nothing |

Every ink any scheme proposes clears 4.5:1. **`statusError` at 5.90:1 is the weakest and it is used in
two places in A and B** - `Not charged` and the `Failed` tail - both of which are 14px w400, i.e. normal
text, so 4.5:1 is the right floor and it clears by 1.40.

And the pairings that decide the schemes, which are ink-against-ink rather than ink-against-surface:

| pairing | ratio | what it is being asked to do |
| --- | ---: | --- |
| `statusSuccess` vs `textPrimary` | **1.86:1** | tell two amounts apart in B - **fails 1.4.11's 3:1** |
| `statusNeutral` vs `statusSuccess` | **2.56:1** | tell two badges apart - fails, in every scheme |
| `textPrimary` vs `textSecondary` | 3.23:1 | tell lead from context - passes, and is today's L1 |
| `textPrimary` vs `textPrimary` | **1.00:1** | tell lead from ticker - **this is complaint 1** |

Neither of the two failing pairings is a conformance violation on its own, because in both cases the
distinction is **also** carried by a glyph - the sign and the arrow - which is exactly what 1.4.1 asks
for. They are quoted because they measure how much work the colour is really doing, and the answer is:
less than the glyph beside it, in both.

## Recommendation

**★ Ship A - the neutral amount with a slot that is never empty.** It is the only scheme that answers
both complaints with one rule instead of two, and it wins on three grounds that survive a device walk.
**It removes a fourth statement of a fact the row already makes three times** - and it does so on the
codebase's own precedent, quoted above almost verbatim, which the same file applied to the middle dot
eight hours ago. **It measures better where it matters:** the cue it deletes is worth 1.86:1 against a
3:1 bar, and the colours it frees land at 12.11 and 5.90 on elements that carry information a sign
cannot carry, for zero width. **It is close to the cheapest diff on the page:** a two-arm `_toneColor`,
one `??` in `_fiatLine`'s consumer, and two ink swaps. Its one real cost - a credit stops being green -
is named above and answered by the badge that was already green.

**Runner-up: B - keep the green, and write the rule down.** Not because I think it is right, but because
the objection it embodies is behavioural and this sketch cannot settle a behavioural question on a
screen. B is **one ternary** from A, it fixes complaint 2 in full on its own, and if the column reads
flat on Sidney it is the fallback with nothing to rebuild. Framing it exactly as 183's C and F were
framed: **A and B are a safe pair to decide between on device.** The honest admission B forces, and I
would rather it were said than implied: **the asymmetry Jakub noticed survives in B by choice, and B's
answer to him is "yes, and here is why", not "yes, and it is gone".**

**Explicitly rejected: C - value first.** Not on layout, which it passes comfortably, and not on taste.
It is rejected because `fiatValue()` multiplies by `currentPrice` - **a present-day price applied to a
past transaction** - so C would promote the row's least reliable number to its headline, on a screen
whose entire purpose is a historical record. Its second failure is structural and is the tell: the only
workable answer to a missing price is to **fall back to token-first**, which means C stops being C on
the exact row that prompted the work.

**I would ship A, with the lead at L2.** Those are two independent edits and neither blocks the other.

### The cheapest diff, per scheme

| Scheme | Diff |
| --- | --- |
| **★ A** | **about 8 lines.** `_toneColor` loses its `incoming` arm and becomes two-way (`none -> textSecondary`, everything else `textPrimary`). `amountColumn` drops the `if (content.valueLine != null)` gate and reads `content.valueLine ?? 'No price'`. The value line's colour becomes `content.status.isDead ? gw.statusError : gw.textSecondary`. The status tail's colour reads `txStatusColors(content.status, gw).fg` - **a function that already exists and is already correct for all four states**, so the tail costs one expression, not a table. |
| **B** | **A plus one line** - `_toneColor` keeps `incoming -> gw.statusSuccess`. |
| **C** | **about 60 lines plus a model change.** A new unformatted-fiat field on `TxRowContent` (the formatted string cannot be re-split - `$0.53 fee` carries a word), a rewritten `amountColumn` with a fallback branch, a `Text.rich` for the coloured sign, and the receipt drawer, which prints the same two values at `numericHeadline`. |
| **Lead L2** | **one token** - `gw.textPrimary` to `gw.textPrimary70` in the lead's `TextStyle` (`:548-551`). |
| **Lead L3** | **one token**, and it reopens the decision Jakub made on device this morning. |

**The cost none of those line counts contains.** Three comment blocks state today's reasoning as
settled fact and become false the moment `_toneColor` loses an arm: the tone comment at `:164-167`
(which claims the tone comes "from 12-02's tone - never from a re-inspection of `tx.type`" and is still
true, but whose `none` justification changes), and above all the **dead-status block** at
`transaction_utils.dart:625-650`, which argues in eleven lines why `none` is not `outgoing` - an
argument that gets *stronger* under A, not weaker, and whose text must say so. Rewriting them is how
this is actually finished; leaving them is how the next reader restores a tint on an argument that
expired.

Unchanged in every scheme, and it must be: **`Not charged`**, its `tone = none`, and the whole
`isDead` override. Also unchanged: the `exactAmount` tooltip, `formatTxAmount`'s unparseable early
return (a freeze guard, `37639d5`, not a formatting nicety), and the `_narrowStatusMaxWidth` cap.

Still owned elsewhere and **not decided here**: whether `Processing job` should now render on a failed
row too (finding 2 above), whether the type scale stays off (`260807-ubg`, uncommitted), and what the
wide `/transactions` page does with its Status pill - every number here is the narrow phone row.

## Provenance

Shipped code read directly, not described: `lib/dashboard/home/widgets/transaction_displays.dart`
(`_toneColor` :168-172, `amountText` :315-327, `amountColumn` :332-356, the subtitle lead :492-571,
`txStatusColors` :76-99), `lib/dashboard/home/widgets/transaction_utils.dart` (`TxAmountTone` :183,
`_minus` :192, the tone/`valueLine` assignment :576-650, `_fiatLine` :679-690, `fiatValue` :126-133,
`livePricesBySymbol` :145-165, `statusTail` :291-293), `transaction_badge.dart` (`badgeSpec` :42-105),
`lib/components/cards/gw_row_rhythm.dart` (the four numbers Jakub walked this afternoon),
`lib/theme/genius_wallet_typography.dart`, `lib/theme/gw_colors.dart`,
`lib/theme/genius_wallet_decorations.dart` (`_surfaceSheenDark` - the two identical stops),
`lib/utils/wallet_utils.dart` (`getAddressForDisplay`, 6 + `...` + 4).

The complaint-1 correction is `git show 0cd2889b` and `git show d5993c58:...` compared blob to blob,
plus the uncommitted `260807-ubg` working tree. The 364.00 card content box and the `/transactions`
page's identity with the dashboard panel are quoted from
`.planning/quick/260807-v6m-.../SEPARATOR-RHYTHM-MEASURED.md`, which measured painted ink rather than
source padding.

Text widths measured from the shipping fonts with `fontTools` - advance widths out of
`assets/fonts/Inter-Regular.ttf` and `Inter-SemiBold.ttf` at 2048 upm, with the `tnum` GSUB
substitution applied wherever the row applies `FontFeature.tabularFigures()`. The same two files are
**inlined into the page** as subsets and verified byte-exact against the originals (delta 0.0000 on
every string), so what the browser lays out is what Flutter lays out rather than a system fallback.
Row heights and the 11.571px offset are derived from Flutter's line metrics, where `height` is a
multiplier of `fontSize`.

Contrast is WCAG 2.x sRGB relative luminance, computed against **#0C0E14** and stated per pairing.
Where a value is translucent it is composited onto the card first and then measured. Colours verbatim
from `genius_wallet_colors.dart` dark, cross-checked against `.planning/sketches/themes/default.css`.

Phone is 390 x 844 at 1:1 with the real 60px app bar, the real 6pt page gutter and the real card, and
the row is assembled from the shipped anatomy - 38 glyph, 18 badge hung at `right:-2 bottom:-2`, 8/12
padding, two `Expanded` columns at 147.00. No scaled thumbnails and no fragments.

`node --check` clean on the single `<script>` block; whole-file `<div>` balance **0**; **24** render
combinations (4 schemes x 2 price states x 3 lead treatments) execute headlessly without error and every
one produces a div-balanced fragment containing all six rows. All four phones verified to render
**distinct DOM** - the trap that once made a sketch show five identical phones - with per-scheme
assertions: value lines NOW 5 / A 6 / B 6 / C 6, `No price` NOW 0 / A 1 / B 1 / C 1, green amount inks
NOW 2 / A **0** / B 2, status-coloured elements A and B 3 each. With the BTC price toggled *present*,
NOW renders **6** value lines instead of 5 and its markup comes within one character of A's (5629
against 5628) - the jitter is the missing line and nothing else.
