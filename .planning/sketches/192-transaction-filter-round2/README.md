---
sketch: 192
name: transaction-filter-round2
question: "F1 and F3 both work but F3's field is too long and too loud, and F5 does not need its search. What sits between them?"
winner: null   # recommending G2
tags: [mobile, ios, transactions, filters, trigger, icon, page-header, kicker, live-chips, round-2, follows-191, follows-190]
---

# Sketch 192 - filters, round 2: the quiet middle

http://localhost:8899/192-transaction-filter-round2/

Jakub on 191: **F1 is fine, F3 is also OK but the "All transactions" field is too long and too
eye-catching, F5 is fine but the search field is unnecessary. Keep those three and add something in
between, ideally with a small filter icon like F5's. Invent two or three more.**

Six tabs: the three survivors, then three new schemes all built on F5's 44px icon.

## What the three survivors are here for

- **F1** - unchanged. It anchors the loud end of the range: **38px**, three to four filters and their
  counts readable without a gesture. Nothing in round 2 beats it on discoverability.
- **F3** - unchanged **on purpose**, so the complaint stays visible next to its fixes.
- **F5'** - the search field removed, as asked.

## Two complaints, and they are not the same complaint

Measured off the rendered DOM:

| Complaint | Measured | Fixed by |
| --- | --- | --- |
| **Too long** - the control is the full card width | 348px of control for a label measuring ~112px | **G1**, intrinsic width |
| **Too eye-catching** - a filled, hairlined 44px box directly under the title | **15,312px²** of fill | **G2**, the control leaves the panel |

The second matters more. A full-width sunken box at the top of the panel reads as the page's
**subject** - it is where Assets puts a search field, and a search field is something you are expected
to use. A filter is not; most sessions never touch it.

## What removing F5's search field revealed

Right call, and it produced the finding the two best new schemes are built on. Without the search,
F5 is **a 44px icon alone on a 44px row**, and that row still charges the panel its `space6` gap:

| | F5 (with search) | F5' (without) |
| --- | --- | --- |
| Total vertical spent | 56px | **56px** |
| Controls in that space | 2 | **1** |
| Ink in that space | ~92% | **13%** |

**F5' pays F5's rent with one tenant** - 304px of empty row beside a single icon. The icon is right;
a row of its own is the wrong home for it. G2 and G3 are that icon moved somewhere it costs nothing.
Turn `RULER` on in F5' and the dead space is drawn as hatching.

## The three new schemes

- **G1 · Compact trigger** - F3's semantics with F3's geometry thrown away: the trigger hugs its
  content and sits at the row wall. **~118 x 36 idle** against F3's 348 x 44, so **28% of the fill**
  and 48px instead of 56. Reads as a chip, not a field. 36 rather than 44 because the whole pill is
  tappable: 4,248px² against a bare 44px square's 1,936, and its shortest side clears WCAG 2.2 SC
  2.5.8's 24px, the only one of the three platform numbers that is a conformance requirement. It is
  also F1's chip height, so if F1 ever wins the two agree. It grows only when the word grows: `All · 10`
  idle, `Sent · 3` filtered, never padded to a fixed size.
- **G2 · Header icon** ★ **recommended** - the filter moves out of the panel entirely and into
  `GWPageHeader.trailing`, the slot Crypto News already fills with `_UpdatedStamp`. **0px inside the
  panel and 0px on the page** - the header row is already 28px and the 44px target fits beside the
  title. The panel opens straight onto the count and the rows, which is **one more row above the fold**
  than F3. A page-level control at page level.
- **G3 · Kicker icon + live chips** - a 24px glyph in the kicker's trailing slot (where
  `assets_screen.dart:444` puts `VALUE ↓`), and the live filters as **dismissible chips** on a row that
  exists only while something is on. Idle **0px**; filtered 40px. The only scheme where a live filter is
  named rather than merely indicated, and the only one where you can drop one axis without opening
  anything - which starts mattering the moment 191-F7's two axes land.

## The state problem, and how each new scheme answers it

An icon is the easiest place in the app for a live filter to go invisible. That is not hypothetical -
it is the defect the `⋯` has today, and the code says so: *"A filter chosen from the menu leaves no
mark on the title row, so without this the list reads as unfiltered while showing a partial list"*
(`transactions_slim_view.dart:906-907`).

| Scheme | How a live filter announces itself |
| --- | --- |
| G1 | the pill prints the filter's name and takes the brand hairline |
| G2 | brand tint + a gradient dot on the icon, **and** the kicker 40px below reads `3 OF 10 TRANSACTIONS` |
| G3 | a named chip you can dismiss |

The sketch asserts this rather than claiming it: with a filter live, every scheme has at least one
element marked active, checked in jsdom across all six tabs.

## Recommendation

**★ G2.** It costs literally nothing, it puts a page-level control at page level, it makes the panel's
first line the thing the user came for, and it is the quietest of everything drawn across both rounds.
It gives up the most discoverability - which is the trade that was asked for.

**Runner-up G1** if the trigger should stay visible inside the panel: it is F3 with the complaint
removed and nothing else touched.

**G3 if filters get used and kept on.** Best at *showing* state, worst at *advertising that state is
available* - its idle affordance is a 24px glyph on an 11px uppercase line, which is the same objection
191 raised against F6.

**F1 remains the answer if filters matter more than quiet.** The two rounds are a single spectrum:
F1 (38px, always readable) → G1 (48px, one word) → G2/G3 (0px, one glyph). Nothing here is strictly
better than F1; they are all quieter than it.

## What to look for

- **F5'** with `RULER` on: the hatched dead space is the whole argument for G2 and G3.
- Press **Filter: Sent** under each phone and watch where the state appears. That is the real
  comparison, not the idle screens.
- **G2**: count the rows above the fold against F3. The header icon buys one.
- **G3**: press Sent, then tap the chip's `×`. Nothing opens, the filter drops.
- The **cost** meter under each phone is `getBoundingClientRect()` on the rendered trigger - width,
  height and area - never a typed number.

## Provenance

`GWPageHeader.trailing` behaviour and its layout reasoning from `gw_page_header.dart:200-260`; the
Crypto News precedent for a control in that slot from `crypto_news_screen.dart:137`; the kicker
trailing precedent from `assets_screen.dart:444`; the invisible-filter defect quoted from
`transactions_slim_view.dart:906-907`; sheet rows are `_menuItem`'s anatomy (`:963-1015`); filter set,
labels and `emptySelectionAllowed` from `:60-150`. Row anatomy, tokens, spacing and row rhythm
unchanged from 190/191. Inter inlined from the shipping TTFs. `node --check` clean; div balance 0; zero
em dashes; rendered in jsdom with **zero script errors** across all six tabs, with three assertions per
tab (3 rows under Sent, at least one active mark on screen, 10 rows in every sheet) and G3's chip
dismissal checked.
