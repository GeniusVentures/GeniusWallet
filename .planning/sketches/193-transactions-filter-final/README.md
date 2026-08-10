---
sketch: 193
name: transactions-filter-final
question: "The final: no count line, the app's own drawer, and the app's own icons. Two of the three assumptions were wrong."
winner: "Final = 190-C page + 192-G2 header trigger, no kicker, live-filter chip row, ResponsiveDrawer + GWSelectRow, real badgeSpec glyphs"
tags: [mobile, ios, transactions, filters, final, drawer, responsive-drawer, gw-select-row, icons, material-glyphs, badge-spec, pickaxe, wcag-1.4.11, corrects-188, corrects-190, corrects-191, corrects-192]
---

# Sketch 193 - transactions filters, final

http://localhost:8899/193-transactions-filter-final/

Jakub, 2026-08-09: **"I do not know if this is needed at all. Show me what it looks like without those
'transactions'. When you open that menu from the bottom, I assume the font, the font size and so on are
all based on components we already have from other menus that open. Plus the icons are respected
against how they actually look in Transaction, right? Check it and send me the final design."**

Three assumptions, all checked against source. **Two came back no.** This sketch is the correction.

## 1. Without the count line - you were right

| | With the kicker | Without |
| --- | --- | --- |
| Vertical before the first row | 24px | **0px** |
| First thing under the title | a caption in 11px uppercase | **Today, then the row** |
| Rows above the fold | 6 | **6** |

**It does not even buy a row.** The 24px falls inside the slack above the bottom bar, so at this list
length the count is chrome that changes nothing about what you can see. That only becomes visible when
it is drawn.

What the count was actually for was never *how many transactions do you have*; it was **this list is
filtered, and by how much** - what Assets says with `3 of 11 assets`. That job survives and moves to
the filter: press Sent and a chip row appears carrying `Sent ×` and `3 of 10`. Idle, nothing. Filtered,
one row that names the filter, quantifies it, and can be dropped without opening anything.

**Consequence to see before agreeing:** turn `LIVE CHIPS` off with a filter active. The only remaining
signal is the tinted header icon and its dot - which is the `⋯`'s existing defect, named in source at
`transactions_slim_view.dart:906-907`. The chip row is not decoration; it is what makes dropping the
count safe.

## 2. The drawer - no, it was not built on our components

191 and 192 drew an invented sheet. Every value below is from source.

| Piece | 191 / 192 drew | The app's drawer | Source |
| --- | --- | --- | --- |
| Panel fill | `surfaceMenu` #171A21 | **`surfaceElevated` #0C0E14** | `responsive_drawer.dart:172` |
| Panel edge | 1px top only | **`borderSubtle` 1px all round** | `:174` |
| Top radius | 20 | **`radiusXl` = 24** | `:175-177` |
| Header | a grab handle | **no handle. A 56px bar, title + × top right** | `:208`, `:240-280` |
| Title type | 10.5px uppercase caption | **`titleLg` 18 / w600** | `:257` |
| Title inset | 16 | **`space10` = 20** | `:217`, `:247` |
| Row height | 40, fixed | **intrinsic: `space6` 12 top and bottom** | `gw_select_row.dart:101-103` |
| Row radius / gap | none | **`radiusMd` 12, `space2` 4 between rows** | `:99`, `:113` |
| Row label | 13 / w500 | **`bodySm` 14 / w600** | `:132-137` |
| Selected label | gradient-masked text | **label unchanged** | `:132` |
| Selected mark | none | **`Icons.check_circle` 20, brandCta ShaderMask** | `:155-165` |
| Selected fill | none | **tint `0x2E0AD89C` → `0x2E0AAEE6` + `hoverEdge`** | `:78-82`, `:110-122` |

**The check glyph is not optional.** `GWSelectRow`'s own doc measures it: on this panel the gradient
tint is **1.39:1** and the brand edge **1.60:1**, so neither carries selection alone. The check at
`brandPrimaryStrong` is **6.81:1** and carries it by itself. Selection is a state, so WCAG 1.4.11
applies. The gradient-masked label I drew did the tint's job and none of the glyph's.

### The one genuine conflict, which needs a call

Toggle `GLYPH` under the drawer. The app disagrees with itself:

- **Badge disc** - leading is the row's badge at 36px, fill from `badgeSpec` with the glyph knocked
  out. This is what was asked for: a picker whose marks are the marks in the list. It also fills
  `GWSelectRow`'s leading slot the way its other four consumers do (~36px avatar or chain icon).
- **Flat grey** - a 20px glyph in `textSecondary`, which is what the shipped overflow menu and the wide
  rail both do, under a stated decision: *"The glyph NEVER changes with selection: same icon, same
  colour, active or not. Locked decision - do not tint it, do not gradient it."*
  (`transactions_slim_view.dart:988-990`).

**Recommended: the badge disc**, and it does not break the locked decision - that decision forbids the
glyph changing *with selection*, and the disc does not change with selection either. `All` takes
neither, in both modes: it is the one filter with no `badgeKind` (`:68`), so it has no fill to sit on,
and the rail already answers this with its own neutral `Icons.list_alt_outlined` (`:1246-1252`).

## 3. The icons - no, they were mine

The app reads one table, `badgeSpec` (`transaction_badge.dart:42-106`), and the row, the chip, the menu
and the rail all read it. 191 and 192 used hand-drawn strokes instead. The real outlines are now
extracted from the Flutter SDK's own `MaterialIcons-Regular.otf` (unitsPerEm 512) and flipped to screen
coordinates.

**The flip was verified, not assumed:** `Transform(1, 0, 0, -1, 0, 512)` puts `close`'s bounding box at
exactly **5..19** in the 24 grid and `check_circle`'s at **2..22**, which match the published Material
paths. An earlier attempt flipped about the ascent (448) and put `lock` at **-43**, outside the box.

| Filter | The app paints | Fill |
| --- | --- | --- |
| Sent | `Icons.north_east` | `statusNeutral` #64748B |
| Received | `Icons.south_west` | `statusSuccess` |
| Mint | **`assets/images/pickaxe.svg`**, stroked, width 3.2 | `brandTertiary` #C28FFF |
| Jobs | `Icons.dns` | `brandPrimaryStrong` |
| Escrow | `Icons.lock` | `statusNeutral` |
| Swap | `Icons.swap_horiz` | `statusNeutral` |
| Purchase | `Icons.credit_card` | `statusSuccess` |
| Pending | `Icons.schedule` | `statusWarning` |
| Failed | `Icons.close` | `statusError` |

Three things the audit tab makes visible:

1. **Material icons are FILLED; mine were stroked.** That is on every single one, and it is why the old
   chips read lighter than the badges in the rows beneath them.
2. **Sent and Received are DIAGONAL** - `north_east` / `south_west`, not the vertical up/down I drew. A
   diagonal reads as out of / into the wallet; a vertical arrow reads as sort order.
3. **Mint is not a Material icon at all.** It is a stroked SVG asset at stroke-width 3.2, so it sits
   heavier than every glyph beside it at any size. **That is true in the shipped app**, not something
   this sketch introduced. It is a real inconsistency in the icon set and deserves its own decision; it
   is not one to fix silently.

**Scope of the error:** sketches 188, 190, 191 and 192 all drew the wrong glyphs. Their layout findings
stand, since none turned on which arrow was used, but any judgement they invited about how the control
*felt* was made against the wrong marks. 193 is the only one drawn with the real ones.

## The final, assembled

- **Page** = 190-C, one panel.
- **Control** = 192-G2, `Icons.tune` in `GWPageHeader.trailing` - the slot Crypto News already fills
  with `_UpdatedStamp` (`crypto_news_screen.dart:137`). 0px inside the panel, 0px on the page.
- **No kicker.**
- **Live filters** = a chip row that exists only while a filter is on, carrying the name, the badge mark
  and `3 of 10`.
- **Picker** = `ResponsiveDrawer` bottom sheet with `GWSelectRow` rows and the brandCta check.
- **Icons** = `badgeSpec`, real.

## What to look for

- Tab 1 idle: title, then `Today`, then the first transaction. Nothing between them.
- Press **Sent**, then turn **LIVE CHIPS** off. That is the argument for keeping them.
- Tab 2: flip **GLYPH** between badge disc and flat grey. That is the open call.
- Tab 3: the middle column is the real outline, the left is what I drew. Look at Mint especially.

## Provenance

Drawer geometry from `responsive_drawer.dart:162-280` and `kDrawerBodyPadding` (`:29-33`); row geometry,
type and selection treatment from `gw_select_row.dart:95-175`; hover fill and edge from
`genius_wallet_decorations.dart:176-177`; badge table, fills and glyph choices from
`transaction_badge.dart:42-106`, badge disc geometry from `:160-196`, glyph-on-fill contrast computed
the way `badgeGlyphColor` computes it rather than tabulated; `Filters.badgeKind` and the `All` glyph
from `transactions_slim_view.dart:60-70` and `:1246-1252`; the locked flat-glyph decision from
`:988-990`; the invisible-filter defect from `:906-907`. Material outlines from
`~/development/flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf`, codepoints from
the SDK's `icons.dart`. Mint is `assets/images/pickaxe.svg` verbatim with `#000000` swapped for
`currentColor`, which is what `SvgPicture`'s colorFilter does at the call site. Inter inlined from the
shipping TTFs. `node --check` clean; div balance 0; zero em dashes; rendered in jsdom with **zero script
errors** and nine assertions, including that the drawer has no grab handle, that selection paints a
check, that all 13 glyph paths are well formed, and that the pickaxe matches the shipped asset. One real
bug was caught by that harness before the page was opened: `All` has no `badgeKind`, so it cannot take a
badge disc.
