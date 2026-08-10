---
quick_id: 260808-whb
slug: assets-page-scheme-c-boxed-panels
date: 2026-08-08
mode: quick
branch: redesign/row-rhythm-260808
---

# Quick task: `/assets` adopts sketch 187 scheme C (boxed panels)

## The instruction

Jakub, 2026-08-08, after walking sketch 187: **apply design C, boxed panels**, and use the component
sizes, tokens, spacing and fonts we already have in the system - **the same ones the homepage
dashboard panels use**.

Scheme C was the one this session recommended against (the cost is recorded in
`.planning/sketches/187-assets-page-frame/README.md` and re-stated below). He chose it after the cost
was stated. Recorded, not silent.

## What changes

`lib/dashboard/assets/assets_screen.dart` goes from a flat page to two panels drawn with the
dashboard's own container.

| | Today | After |
| --- | --- | --- |
| Back link | `GWBackLink('HOME')` `:342` | **deleted** - `/assets` is a bottom-bar tab (`nav_destinations.dart:143-146`) |
| Top gap | hardcoded `space32` (64) `:292` | `GeniusBreakpoints.pageTitleGap(context)` = 24 at phone |
| Side gutter | hardcoded `12` on six children | `GeniusBreakpoints.pageGutter(context)` = 6 at phone, applied ONCE on the frame |
| Total | `GWPageHeader.trailing`, ad-hoc 20px column `:404` | panel 1, the dashboard's own total band at `numericHeadline` 24/32 w700 |
| Search / sort / rows | bare on `surfaceBase` | panel 2 |

## Decisions, and why each is the dashboard's own answer rather than a new one

1. **The panel container is `DashboardScrollContainer`, imported, not re-created.**
   `dashboard_screen.dart:395-425` - `GWDecorations.surface(radius: radiusLg, border: borderSubtle)`
   with `space6` padding on desktop and `space3` on a phone. Precedent for importing it from outside
   that file already exists: `transactions_slim_view.dart` does exactly this. Hand-rolling a
   `GWCard(padding: space3)` would render the same pixels today and drift the day the panel recipe
   changes.
2. **The total band is EXTRACTED, not copied.** `_AssetsTotalBand` is private inside
   `coins_screen.dart:530`. It moves to `lib/components/coins/assets_total_band.dart` as public
   `AssetsTotalBand`; `coins_screen.dart` imports it and its own class is deleted. Both surfaces then
   render one widget, which is the point - the dashboard panel and `/assets` cannot disagree about
   the total's type, colour or optical centring. No behaviour changes: the widget moves verbatim,
   including its `space4` horizontal inset and the `CrossAxisAlignment.center` decision Jakub walked
   on 2026-08-07.
3. **Panel 1 is labelled with `GWKicker`, not `GWSectionTitle`.** The page header already says
   "Assets"; a second title-weight string is the duplicate-title defect this file's own comment
   (`:352-355`) forbids. `GWKicker('total value', dense: true)` is the same 11px label the count line
   below already uses, and it carries no padding of its own by design, so the call site insets it by
   `space4` - the same 8 the band and every `CoinCardRow` wall use, so panel 1 and panel 2 share one
   left edge at 6 + 8 = 14 from the phone edge, exactly as the dashboard's Assets panel does.
4. **Inter-panel gap is `space3`.** `OneColumnDashBoardView:330` uses `SizedBox(height: space3)`
   between every homepage panel. Same value here, so the two pages have one rhythm.
5. **All five states stay inside panel 2.** Loading, error, the no-coins empty state with its
   Receive / Buy GNUS pair, the no-match empty state, and the rows. A state rendered outside the
   panel would make the page change shape as data arrives.

## The cost, restated so it is on the record

Row content width drops from **362 to 348** at 390pt: page gutter 12 + card border 2 + card padding
12 + row wall 16. The amount column was measured clipping ordinary amounts at 390pt on 2026-08-07
(todo filed). This change makes that 14px worse. It is accepted at Jakub's explicit direction.

## Tasks

1. Extract `AssetsTotalBand` to `lib/components/coins/assets_total_band.dart`; rewire
   `coins_screen.dart`. Prove `assets_header_scheme_a_test.dart` still passes.
2. Rebuild `assets_screen.dart` as scheme C: frame helpers, no back link, two panels.
3. `flutter analyze` at the 0-issue baseline; full `flutter test`; hot reload onto Sidney and walk.

## Out of scope

The 187 sketch's own winner marking, the light pass, and the amount-column clipping todo.
