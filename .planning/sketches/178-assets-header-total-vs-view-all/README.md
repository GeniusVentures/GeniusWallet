# Sketch 178 - the Assets header: a total and a View all in one row

http://localhost:8899/178-assets-header-total-vs-view-all/

Jakub, 2026-08-07, on his iPhone:

> "nie podoba mi sie sekcja assets, poniewaz tam masz view all oraz kwote po prawej stronie,
> chcialbym zebysmy to dobrze jakos rozwiazali, bo nie wyglada to dobrze. (...) Czy usuwamy stamtad
> total kwote i ona jest dopiero wyswietlana na subpage'u, jakby po klikniecu view all?"

## The row is not overflowing, and that changes what a fix has to do

Measured at 390pt: the title row's content box is **336** (390 minus 2x `space3` list padding, minus
2x (`space6` + 1px border) card inset, minus 2x `space4` title inset). "Assets" takes about 58,
`GWViewAllLink` about 86, the gap 24. That leaves about **168** for the total block, and the widest
realistic pair - `$1,234,567.89` at 20px over its change line at 13px - measures about 143 and 126.

**It fits, with room to spare.** So this is a hierarchy problem, not a geometry problem: the biggest
number in the row and the only tappable thing in the row sit 24px apart and neither wins. A scheme
that only rearranges pixels without deciding which element is dominant has not fixed anything.

## Two constraints every scheme is measured against

1. **Markets and Transactions both put `GWViewAllLink` at the far right of their title rows**, and the
   current Assets arrangement deliberately matches that pixel region so the eye learns one place for
   it. All four schemes keep it there. A scheme that moved it would have to move all three.
2. **Jakub approved the Assets title gap on device this morning** - `contentTopInset: 20`, rendered
   gap 30. Two of the four schemes change it, because they change what the first widget under the
   title is. Recorded per scheme rather than discovered later.

## The four schemes

| | Idea | Height | Title gap | Verdict |
| --- | --- | --- | --- | --- |
| A | Title row cleaned, total becomes a hero band under it | +52px | changes to 26 | runner-up |
| B | **Jakub's own** - total leaves the dashboard, lives on `/assets` | 0 | unchanged | see below |
| **C** | "Assets" demotes to a kicker, the total becomes the section headline | **0** | **unchanged** | **recommended** |
| D | Total becomes a labelled summary well above the list | +64px | changes to 26 | rejected |

## Recommendation: C

It is the only scheme that fixes the hierarchy at **zero height cost** and **without touching the
gap Jakub approved this morning**. Two elements in the row instead of three, and the number a wallet
exists to show becomes the biggest ink on the section. The 44px header min-height already absorbs a
14px kicker over a 28px line, so nothing grows.

**Its real cost, stated plainly:** Assets stops looking like Markets and Transactions, whose names
are 18px white titles. Here the name drops to an 11px secondary kicker. That is an inconsistency
introduced by the one phase that was about making sections consistent, and if it reads badly side by
side on the phone, **A** is the safe answer - it keeps the title identical to its siblings and pays
52px for it.

**Rejected: D.** The most height of any scheme, on the exact panel phase 25 just capped to five rows,
and a bordered well above a five-row list reads as a sixth row. It solves the problem by adding
furniture.

## On B, which is Jakub's own idea

B is the calmest panel of the five and costs nothing, so it is genuinely tempting. The objection is
not how it looks, it is what it removes: **the portfolio total appears nowhere else on the home
screen.** Verified, not assumed - the Compute panel's balance tile is the GNUS compute balance, a
different number (`compute_panel.dart`). After B, "how much am I holding" costs a navigation, and
that is the single most common question a wallet is opened to answer.

If Jakub still wants B having seen it, it is a legitimate product call and roughly one line of work
plus the hero on `/assets` (which the sketch already shows). I just do not think the crowding is
worth that much.

## Contrast, computed from the real tokens

| Pairing | Ratio | Needs | |
| --- | --- | --- | --- |
| total `#FFFFFF` on card `#0C0E14` | 19.6:1 | 4.5:1 | pass |
| change up `#0AD89C` | 10.4:1 | 4.5:1 | pass |
| change down `#FF4D4D` | 5.9:1 | 4.5:1 | pass |
| kicker `#8A8F9D` (scheme C) | 6.0:1 | 4.5:1 | pass |
| `VIEW ALL` gradient stops | 10.4:1 / 7.6:1 | 4.5:1 | pass |

No scheme is blocked on contrast. The decision is entirely hierarchy, height and consistency.

## Still open

If C ships and the kicker treatment proves right, there is a follow-up worth discussing separately:
whether Markets should carry its 24h index move the same way. Deliberately **not** bundled here.

## Provenance

Tokens verbatim from `genius_wallet_colors.dart` / `genius_wallet_consts.dart`. Phones are 390x844 at
1:1 with the real shipping bar geometry (56px app bar, 60px bar, 64px dock, 26px overhang, 84px
slot). Totals, day change and percentages are computed live from the row data in every scheme, in
both the FUNDED and ALL-ZERO states. `node --check` clean; div balance 111/111.
