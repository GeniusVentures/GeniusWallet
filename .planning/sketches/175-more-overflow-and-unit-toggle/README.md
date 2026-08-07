# Sketch 175 - replacing the "More" overflow, and making "selected" visible

http://localhost:8899/175-more-overflow-and-unit-toggle/

Two defects reported by Jakub on the 2026-08-06 live iPhone walk. Both live on the mobile shell
that phase 24 owns.

## 1. The three-dots overflow

`_moreDestinations` (`responsive_overlay.dart`) resolves to News, Web, Feedback, Settings, plus a
hard-coded Accounts row. Three findings, all read out of the code rather than guessed:

1. It holds **three unlike kinds of thing** in one flat list - destinations (News, Web), utilities
   (Feedback, Settings) and identity (Accounts). No rule can be stated about what lives behind the
   dots, so no memory of it can form.
2. **Accounts is duplicated.** The header wallet chip already calls `AccountDrawer.show(context)`;
   the sheet row calls the identical method.
3. The sheet is built from **`GWSelectRow`, a selection component**. Its job elsewhere is "pick one
   of these, here is a checkmark". Using it for navigation borrows mismatched semantics.

| Scheme | Idea | Verdict |
| --- | --- | --- |
| A | 4th tab becomes **Wallet** - identity-led full screen with grouped rows | Runner-up |
| B | Keep the sheet, swap the row list for a 3-across **tile grid** | Rejected |
| C | **Delete the overflow.** News to the 4th tab, Accounts stays on the header chip, Web/Settings/Feedback into a Settings screen behind a gear | **★ Recommended** |
| D | Tap More expands a **`GWControlTrack` rail** above the bar - no modal | Wildcard |

**★ C** because it removes the defect rather than decorating it, and introduces the fewest new
components - the criterion Jakub set ("ideally it fits the other components"). All four routes
already exist in `_allDestinations`; the gear is the chip shape the network selector already is;
the settings screen is the accounts drawer's own construction.

**D wins the literal "fits our components" test** by being `GWControlTrack` rather than merely
resembling it, but five chips across 342px gives each ~66px with a 9.5px label - under the app's
own floor - and it hard-caps how much the overflow can hold.

### Open question, blocks the choice

**How often does anyone open Web?** Under C it goes from one tap to three. If it is a daily
surface, C is wrong and A is right. Nothing else in the sketch depends on a fact not in the repo.

## 2. The GNUS / MIN toggle

Jakub: "should follow a similar component to the timeframe filter, to see way better what is
selected." He is right, and there is a number: the selected chip's fill measures **1.15:1** against
the track it sits in. WCAG 1.4.11 requires **3:1** for a state indicator. `surfaceMenu` `#171A21`
on `surfaceSunken` `#06080C` are two nearly identical blacks.

| Scheme | Selected state | Indicator ratio | Verdict |
| --- | --- | --- | --- |
| Today | `surfaceMenu` fill | 1.15:1 | FAIL |
| U1 | brand gradient, exactly `_TimeframeTab` | 10.80 / 7.84:1 | Runner-up |
| U2 | lift chip - `surfaceElevated` + `borderStrong` | 1.04:1 fill, 2.19:1 edge | Rejected |
| U3 | `brandSecondary` 14% fill + 50% edge | 4.00:1 edge, 10.92:1 label | **★ Recommended** |

U2 is the instructive failure: `surfaceElevated` is *darker* than `surfaceMenu`, so "lifting" the
chip makes it less visible. The design system's lift-chip hover works on the page canvas, not
inside a sunken well.

### U1 would reverse a recorded decision

`compute_panel.dart`'s `_UnitSegment` carries an explicit note: *"Colour deviates from
`_TimeframeTab` on purpose ... no gradient in any state ... the Compute panel already has one
filled commitment CTA (New processing job), and a unit selector must not carry the same visual
weight."* That is the CTA weight rule - fill means commitment, at most one per surface.

U1 is exactly what Jakub asked for and is the brightest option. It is a defensible trade, it just
must not be made silently. If U1 is chosen, the partner move is to weaken "New processing job" to
an outline button so the surface still has one filled thing on it.

**★ U3** satisfies both rules at once, and is not invented here - the `ACTIVE ON NODE` badge built
for the accounts sheet (sketch 174) already uses brand-at-12%-fill with a 50% border.

## DECIDED 2026-08-06: Jakub picked **U1**, the gradient

Built and live on device. The recommendation went to U3; Jakub chose the brighter option with the
CTA-weight consequence stated and accepted. `_UnitSegment`'s doc comment in `compute_panel.dart`
now records the reversal, the measurements, both rejected alternatives, and the partner move
(demote "New processing job" to an outline button) should the doubled fill ever read wrong.

The overflow question (A/B/C/D) is still open.

## Provenance

Tokens verbatim from `genius_wallet_colors.dart` / `genius_wallet_consts.dart`. Contrast computed
with the WCAG 2.x relative-luminance formula. Phones are 390x844 at 1:1 with the real shipping bar
geometry (60px bar, 64px dock, 26px overhang, 84px slot). `node --check` clean; div balance 0.
