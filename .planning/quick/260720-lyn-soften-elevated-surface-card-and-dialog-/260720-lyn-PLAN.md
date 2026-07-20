---
phase: quick-260720-lyn
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/theme/genius_wallet_elevation.dart
autonomous: false
requirements: [QUICK-260720-lyn]
must_haves:
  truths:
    - "In LIGHT mode the elevated-surface card shadow is noticeably softer/subtler; in DARK mode it is unchanged (black @35%)."
    - "The dialog shadow is likewise softer in light mode, unchanged in dark."
    - "The change is appearance-aware via GWAppearance.isLight; no const-context breakage (all 4 GeniusWalletElevation.card/.dialog consumers are runtime BoxDecorations)."
  artifacts:
    - lib/theme/genius_wallet_elevation.dart
  key_links:
    - "GeniusWalletElevation.card get -> GWAppearance.isLight ? light-alpha : dark-alpha -> every GWDecorations.surface(elevated) + GWCard + actionCircle shadow softens on light."
---

<objective>
Soften the elevated-surface shadows in LIGHT mode. GeniusWalletElevation.card is black @35%
(Color(0x59000000)) and dialog @45% (Color(0x73000000)) — tuned for near-black dark surfaces
where they read as a soft glow, but on a light surface the same dark shadow reads too heavy
(walk feedback: "shadows are too strong on light mode"). Make card + dialog appearance-aware:
much softer alpha in light mode, dark mode byte-unchanged. App-wide (every elevated card/dialog).
</objective>

<tasks>

<task type="auto">
  <name>Task 1: Make GeniusWalletElevation.card + dialog appearance-aware (softer in light)</name>
  <files>lib/theme/genius_wallet_elevation.dart</files>
  <action>
Add `import 'package:genius_wallet/theme/gw_appearance.dart';`.
Convert `card` and `dialog` from `static const List<BoxShadow>` to `static List<BoxShadow> get`
that switch on `GWAppearance.isLight`:
- card: DARK = `Color(0x59000000)` (unchanged, ~35%); LIGHT = a much softer black, ~`Color(0x1F000000)` (~12%). Keep `blurRadius: 16`, `offset: Offset(0, 4)`.
- dialog: DARK = `Color(0x73000000)` (unchanged, ~45%); LIGHT = softer, ~`Color(0x33000000)` (~20%). Keep `blurRadius: 32`, `offset: Offset(0, 8)`.
Keep the shadow list shape (single BoxShadow each). Leave glowBrand/glowGradient unchanged
(they are brand glows, not neutral drop shadows). The BoxShadow elements can stay `const` inside
the returned list; only the outer member becomes a getter. Zero other changes.
Safety: all 4 consumers (gw_card.dart:56, gw_dialog.dart:65, genius_wallet_decorations.dart:102, :121)
use it inside runtime BoxDecorations / a runtime spread — none is a const context, so const→getter compiles.
  </action>
  <verify>
    <automated>flutter analyze lib/theme/genius_wallet_elevation.dart lib/components/cards/gw_card.dart lib/components/overlays/gw_dialog.dart lib/theme/genius_wallet_decorations.dart</automated>
  </verify>
  <done>card/dialog are appearance-aware getters; light-mode alphas softened (~12% / ~20%), dark unchanged; analyze 0 errors across all consumers.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Appearance-aware, softer light-mode card/dialog shadows.</what-built>
  <how-to-verify>On the already-running GW_DEV_TOOLS=true build (no rebuild): flip to LIGHT via the dev bubble and confirm card shadows (markets grid, dashboard sections, transaction rows) + any dialog read as a subtle elevation, not a heavy drop shadow; flip to DARK and confirm the elevation looks exactly as before (unchanged).</how-to-verify>
  <resume-signal>Type "approved" or say softer/stronger.</resume-signal>
</task>

</tasks>

<output>
Create .planning/quick/260720-lyn-soften-elevated-surface-card-and-dialog-/260720-lyn-SUMMARY.md when done.
</output>
