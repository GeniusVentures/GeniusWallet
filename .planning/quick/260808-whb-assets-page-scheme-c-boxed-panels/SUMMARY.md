---
quick_id: 260808-whb
slug: assets-page-scheme-c-boxed-panels
date: 2026-08-08
status: incomplete
blocked_on: nothing - app is running on Sidney with this build, awaiting Jakub's walk
committed: nothing (no authorisation)
---

# Summary: `/assets` adopts sketch 187 scheme C

Jakub picked scheme C after seeing sketch 188, which is what settled it: `/transactions` already
boxes its list on a phone, so Assets was the app's only unboxed list, not its only clean one.

## What changed

| File | Change |
| --- | --- |
| `lib/components/coins/assets_total_band.dart` | **NEW.** `_AssetsTotalBand` promoted out of `coins_screen.dart` verbatim - same tokens, same `space4` inset, same `CrossAxisAlignment.center`. Public so both surfaces mount ONE widget. |
| `lib/components/coins/view/coins_screen.dart` | -105 lines: the private class deleted, the promoted one imported, two now-unused imports dropped. The dashboard's rendered tree is unchanged. |
| `lib/dashboard/assets/assets_screen.dart` | The page rebuilt as two `DashboardScrollContainer` panels; back link deleted; frame moved onto `pageGutter` / `pageTitleGap`; the six hardcoded `horizontal: 12` paddings removed. |
| `test/components/assets_header_scheme_a_test.dart` | Finder repointed from the string predicate `'_AssetsTotalBand'` to `find.byType(gwband.AssetsTotalBand)`. |
| `lib/components/scaffold/gw_page_header.dart` | **Page titles moved in.** New exported `gwPageHeaderContentInset(context)`; the left-aligned identity row is padded by it. Reaches Assets, Activity, Markets, News, Banxa, the coin page and New processing job in one edit. |
| 3 tests repointed to the new rule | `gw_page_header_trailing_flush_test`, `gw_page_header_centered_test`, `submit_logs_page_frame_test` - each now READS the inset from the component instead of restating a number. |

## Decisions taken while building, with the reason

1. **`DashboardScrollContainer` imported, not re-created.** Precedent: `transactions_slim_view.dart`
   already imports it from outside its defining file. A local `GWCard(padding: space3)` renders the
   same pixels today and drifts the day the panel recipe changes.
2. **The page title sits at the frame gutter (6), not at the card wall (21).** That is what
   `transactions_screen.dart:114` does with "Transactions", so Assets now matches the sibling page
   rather than an alignment invented here. Sketch 187 C drew the title at 14; the shipped sibling
   won.
3. **Full-width children get NO `space4` wall; labelled ones do.** The dashboard's own answer:
   `coins_screen.dart`'s Receive / Buy GNUS row runs edge to edge inside its panel, while
   `GWSectionTitle` charges `space4` (`gw_section_title.dart:168`) and `kGWRowWall` gives every row
   the same 8. So the search field is edge to edge; the count line, the sort control and the rows
   share one left edge.
4. **Panel 1 is labelled with `GWKicker`, not `GWSectionTitle`** - the page header already says
   "Assets" and a second title-weight string is the duplicate-title defect. `space2` between the
   kicker and the band, the app's existing label-to-line gap.
5. **A name collision forced a prefixed import in the test.** The test file declares its OWN
   `AssetsTotalBand` as a measurement probe, so `find.byType(AssetsTotalBand)` resolved to the probe
   and found nothing. Imported the shipping one `as gwband` rather than renaming either - a probe
   called something else drifts out of step with what it claims to mirror. (`shipped` was tried
   first and collides with a local `CrossAxisAlignment` identifier in that file.)

## Follow-up in the same task: the title inset (Jakub, on device)

> looks good, but I would like you to propose a bigger left offset for the "title" component, in this
> case Assets - and then: yes, definitely, apply B to the whole component and the other titles like
> Activity / Crypto News.

Measured at 390pt before the change: panel edge 6, card content 13, and the column everything is
actually read in - coin names, both kickers, row icons - at **21**. The title sat at 6.

Three options were put up; he took **B**:

| | Inset | Title lands at | Aligns with |
| --- | --- | --- | --- |
| A | `space4` = 8 | 14 | nothing, just less cramped |
| **B** | `1 + space3 + space4` = 15 | **21** | coin names, both kickers, row icons |
| C | `1 + space3` = 7 | 13 | the search field's border |

B wins on a fact rather than a preference: **21 is the X the dashboard's own section titles land on**
(`ListView` `space3` + border 1 + card `space3` + `GWSectionTitle`'s `space4`), so a page title now
lines up with the panel titles on Home. `space8` = 16 was rejected despite being a single token: it
gives 22 and misses the content column by 1px, and an alignment off by a pixel is worse than one that
is deliberately different.

It lives in `GWPageHeader`, not at the call sites, because he asked for the component. Consequences,
all named:

- **The centred form is deliberately exempt** (Swap, Feedback's header style): there the header sits
  inside a centred card column, not above a content column.
- **On `GWCard` pages the title lands near its text, not on it** - a default card starts content 17
  inside its edge (2 more than the inset on a phone, 4 less on desktop); Feedback's `space12` composer
  starts at 25. One inset shared by every title, so the tabs agree with each other, beats four insets
  that each agree with one page and no other.
- **Three tests encoded the old rule and were repointed, not deleted.** All three now read
  `gwPageHeaderContentInset` from inside the pumped tree, so a future change to the inset moves the
  component and its tests together instead of turning them red.

## Verification

| Gate | Result |
| --- | --- |
| `flutter analyze lib` | **No issues found** - the 0-issue baseline holds |
| `flutter analyze test/components/assets_header_scheme_a_test.dart` | No issues |
| `flutter test test/components/assets_header_scheme_a_test.dart` | **8/8**, and the measurements are byte-identical to the pre-change run: `boxH=32.0 totalMid=16.125 pctMid=16.25 drop=0.125`, `header=94.0` |
| `flutter test test/dashboard/assets_screen_test.dart` | **9/9** |
| `flutter test` (full, after BOTH changes) | **1207 passed, 3 skipped** - the same count as before the task |
| Device walk on Sidney | **PENDING** - the app is built and running with this code |

The `RenderFlex overflowed` dumps in the full run come from
`test/tokens/coin_page_range_tile_test.dart` ("no rail row leaves a hole at its right edge, at any
tested width"), which probes narrow widths deliberately. Pre-existing, untouched by this task, and
the suite is green.

## Layout verified off-device before the walk

The device was locked for two launch attempts (`Sidney may need to be unlocked to recover from
previously reported preparation errors`), so the layout was proven with a throwaway widget test that
pumped the real `AssetsScreen` at 390x844 with the four shipping Inter faces and wrote a PNG: two
panels, kicker over the band, the search field edge to edge inside panel 2, the count/sort line and
the rows on the `space4` wall, dividers at full card width. The throwaway test was deleted after
reading. The app then launched successfully on the third attempt and is running with this build.

Nothing is committed - no authorisation given.

## Not done, deliberately

- **Transactions is untouched.** Sketch 188 recommends its scheme C (the filter track in its own
  panel) so the two tabs agree, but Jakub asked for 187 C only. If he does not take 188 C, the two
  neighbouring tabs will draw a list with the track inside a panel on one and outside on the other.
- Sketch 187's `winner:` is still null; mark it C once the walk passes.
- The light pass, and the amount-column clipping todo, which this change makes 14px worse by design.
