---
phase: 24
name: Mobile nav shell - center dock, wallet header, two-section accounts sheet
status: in-progress
started: 2026-08-06
sketches: [171, 172, 173, 174]
decisions_by: Jakub, 2026-08-06
---

# Phase 24: Mobile nav shell

## Decisions locked

- **171 variant B** - bottom bar is 4 destinations + a centre dock, not 5 flat tabs.
- **172 variant A** - the dock is **Swap**, using the existing `Icons.swap_vert_rounded`.
- **174** - the accounts sheet has **two labelled sections**: SDK Accounts and Your Accounts.
- All user-facing copy in **English**.
- Reuse existing `GW*` components wherever one exists.

## Resulting mobile IA

`Home · Markets · (Swap dock) · Activity · More`, with More opening a sheet holding News, Web,
Feedback, Settings and Accounts. All 8 original destinations stay reachable - the hard constraint
from Phase 4 criterion 2 and todo `2026-07-18-mobile-nav-ia-curate-bottom-nav.md`.

## Tasks

1. **Asset-row contrast fix.** `coin_card_row.dart:126,134` paints zero balances at
   `textPrimary38` = 3.54:1, under WCAG AA 4.5:1. Raise to `textPrimary80` = 12.4:1.
2. **Accounts sheet** (new, `lib/account/accounts_sheet.dart`): two sections, minions vs network
   currency, `ACTIVE ON NODE` badge separating the two independent selection axes, explicit
   disconnected state. Built on `GWBottomSheet` + `GWSelectRow`.
3. **Mobile top bar**: wallet identity (name + truncated address) opening the accounts sheet, plus
   the network chip. Replaces the literal `Text("Genius Wallet")` and the desktop control track
   crammed into `AppBar.actions`.
4. **Mobile bottom bar**: 4 destinations + centre Swap dock. Desktop `_DesktopTopBar` untouched.
5. **Active-tab fix**: `_currentIndex()` silently returns 0, so `/buy` and `/token-info` light up
   Dashboard. Make "no match" explicit.
6. **Global FAB**: hide on mobile - the dock replaces it, and it currently overlaps the asset list.

## Out of scope

- Desktop chrome (`_DesktopTopBar`) - unchanged this phase.
- Light mode verification - dark-first rule.
- Building Send/Receive routes: they do not exist as routes today, and creating them is its own work.

## Added during the live iPhone walk, 2026-08-06

Found by looking at the running app on Sidney, not by reading code. Both are on the same surface
this phase owns, so they belong here rather than in a separate quick task.

7. **Dock overlaps the bar.** The dock was flush inside the bar; Jakub's reference has it breaking
   the top edge. `_kDockSize` 64, `_kDockOverhang` 26, `_kDockSlotWidth` 84 - so 26px protrudes and
   38px sits inside. Built with an explicitly-sized `Stack`, NOT `Transform.translate`: Flutter
   hit-tests a child only inside its parent's bounds, so a translated dock would have a dead
   protruding half.
8. **Active tab is the brand gradient, not flat blue.** `_MobileBarSlot` painted
   `brandPrimaryStrong`. Jakub: "follow the component" - the desktop bar's selected underline is
   `brandCta`. Uses `GeniusWalletGradient.brandCtaText(gw.surfaceElevated)` through one srcIn
   `ShaderMask` over opaque-white children, the `gw_view_all_link.dart` recipe. `brandCtaText`
   rather than raw `brandCta` because the raw stops measure 1.65:1 on a light surface.
9. **Dashboard section order.** Transactions moved from LAST to third:
   Compute -> Assets -> Transactions -> Chart -> Markets. Assets stays above Transactions; balance
   is the more frequent question. Chart and Markets are browsing, not tasks, and Markets already
   owns a bottom-nav tab.

## Open question for Jakub

- **The header shows the address twice.** Title reads `0x5Ac...9Cf6`, subtitle `0x5Ac1...9Cf6`.
  This is data, not layout: the title is `wallet.walletName`, and this wallet was NAMED with a
  truncated address at import (`import_security_screen.dart:236` takes a free-text field). SDK
  wallets are named properly (`app_bloc.dart:616` -> "Super Genius Wallet"). Options: leave it,
  suppress the address line when the name already looks like an address, or fix the naming at
  import. Not changed unilaterally - it is onboarding behaviour, outside this phase's scope.

10. **Flat page background on mobile.** Jakub: the home page reads "szarawy". `MobileOverlay`
    wrapped its body in `GWCanvasBackground`, which paints THREE layers over the page: a 3-stop
    `canvas` gradient whose top stop is `#14171E` (~+9 L* over `surfaceBase` `#0B0D12`), a
    `canvasTopLight` radial white-12% glow centred near the top, and a 4% noise texture. At 390px
    the glow's radius spans most of the width, so all three land in the top third - exactly where
    the grey was seen. Replaced with `Scaffold(backgroundColor: gw.surfaceBase)`, the same line
    `DesktopOverlay` already carries and the same value `theme.dart:66` sets globally.
    **Desktop keeps the canvas**: the wash exists to stop a very large dark fill reading as dead,
    which is a real problem at 1400px and not one at 390px.

## Further open questions from the walk

- **"Transactions" is printed twice** on the Activity screen - once as the page header, once as the
  section title directly beneath it. One of the two should go; likely the inner `GWSectionTitle`,
  since the page header is what the route names.
- **Sketch 175** (`/175-more-overflow-and-unit-toggle/`) proposes replacing the three-dots overflow
  and fixing the GNUS/MIN toggle. Both await Jakub's pick. The toggle carries a real WCAG 1.4.11
  failure: the selected chip measures 1.15:1 against its track against a required 3:1.

11. **GNUS / MIN toggle: brand gradient (sketch 175, scheme U1).** Jakub picked U1 on 2026-08-06
    after seeing the alternatives and the contrast maths. The old selected chip measured **1.15:1**
    against its track (`surfaceMenu` `#171A21` on `surfaceSunken` `#06080C`) - a WCAG 1.4.11 failure,
    not a matter of taste, since 3:1 is required for a state indicator. Now `brandCta` +
    `textOnBrand`, identical to `_TimeframeTab`: 10.80:1 / 7.84:1 indicator, 10.66:1 / 7.74:1 label.

    **This knowingly reverses the 260731-kc5 decision.** That plan recorded no-gradient on the
    grounds of the CTA weight rule - the Compute panel already carries one filled commitment CTA
    ("New processing job"). The concern was raised with Jakub before the change and he confirmed.
    `_UnitSegment`'s doc comment now records the reversal, the measurements, the two rejected
    alternatives, and the accepted consequence: this surface carries TWO filled brand gradients.
    The recorded partner move, if that ever reads wrong, is to demote "New processing job" to an
    outline button rather than quietly reverting the chip.
