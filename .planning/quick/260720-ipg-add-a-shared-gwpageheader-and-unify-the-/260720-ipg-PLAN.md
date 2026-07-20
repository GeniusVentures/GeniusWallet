---
phase: quick-260720-ipg
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/scaffold/gw_page_header.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/news/view/crypto_news_screen.dart
  - lib/squid_router/swap_screen.dart
autonomous: false
requirements: []

must_haves:
  truths:
    - "All three in-body page titles (Markets, News, Swap) render at the same size/weight (headlineLg 24/w600) in the same left-aligned position, in both light and dark mode."
    - "The News title is no longer the oversized ~36px Material default — the displaySmall path (which toMaterialTextTheme never maps) is gone."
    - "The Swap title is left-aligned (no longer centered) and no longer raw Colors.white — it flips correctly in light mode."
    - "Markets search IconButton and Swap settings IconButton retain their exact existing onPressed behavior."
    - "Spacing below each title is consistent and single (no double gap)."
  artifacts:
    - "lib/components/scaffold/gw_page_header.dart (new shared GWPageHeader widget)"
  key_links:
    - "GWPageHeader reads gw via Theme.of(context).extension<GWColors>() ?? GWColors.dark() so the title flips live on an appearance toggle."
    - "Each migrated screen passes its existing trailing IconButton (with unchanged onPressed) into GWPageHeader.trailing."
---

<objective>
Add a shared `GWPageHeader` component and migrate the Markets, News, and Swap in-body page titles onto it, unifying them to `headlineLg` / `gw.textPrimary`, left-aligned, with a single header-owned gap below.

Purpose: The three page titles currently diverge — Markets uses `headlineLg` (24/w600, correct), News uses `Theme.of(context).textTheme.displaySmall` (which `toMaterialTextTheme()` never maps, so it falls through to the ~36px/w400 Material default — the outlier that reads too big), and Swap uses a raw centered `TextStyle(Colors.white, 24, w500)` (wrong in light mode, wrong alignment). One shared component makes them consistent and tokenized.

Output: One new widget file plus three migrated screens. No behavior change to search drawer, swap settings, or the news feed.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md

# Token sources
@lib/theme/genius_wallet_typography.dart
@lib/theme/gw_colors.dart
@lib/theme/genius_wallet_consts.dart

# Home + convention for the new widget
@lib/components/scaffold/gw_screen.dart

# Screens to migrate
@lib/dashboard/chart/markets_screen.dart
@lib/dashboard/news/view/crypto_news_screen.dart
@lib/squid_router/swap_screen.dart
</context>

<constraints>
- A debug build is ALREADY RUNNING. Do NOT run `flutter build`, `flutter run`, or hot-reload commands. The only automated gate is `flutter analyze <files>`.
- `flutter test` does NOT compile in this repo — do not add or run tests.
- Windows env. Stage files by explicit path only. README.md is dirty and unrelated — NEVER `git add -A`/`git add .`. Do not commit docs and do not touch ROADMAP.md.
- Token discipline: `GeniusWalletTypography.headlineLg` + `gw.textPrimary` + `GeniusWalletConsts` spacing only. No raw `Colors.*`, hex, or bare px on the header. WCAG AA in both modes (textPrimary over surfaceBase already passes app-wide).
- Do NOT touch in-card SECTION titles (DashboardMarkets `titleLg`, Bitcoin Chart) — different tier. Do NOT touch AppBar-title screens.
- Keep each screen's other structure/behavior unchanged (search drawer, swap settings drawer, news feed grid, retry handlers, ConstrainedBox/maxWidth, appearance-aware `gw` reads).
</constraints>

<tasks>

<task type="auto">
  <name>Task 1: Create the shared GWPageHeader component</name>
  <files>lib/components/scaffold/gw_page_header.dart</files>
  <action>
Create a new `GWPageHeader` StatelessWidget at `lib/components/scaffold/gw_page_header.dart`, placed next to `gw_screen.dart` in the existing scaffold/ layout directory (justification: it is a screen-level layout primitive in the same family as GWScreen, so it belongs beside it rather than in a new headers/ dir — keeps the scaffold primitives co-located and discoverable).

Constructor: `const GWPageHeader({super.key, required String title, Widget? trailing})`.

build():
- Resolve `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` — this fail-soft read registers the Theme InheritedWidget dependency so the title flips live on an appearance toggle (same pattern used across the migrated screens).
- Render a `Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [...])` containing:
  1. A `Row` with `crossAxisAlignment: CrossAxisAlignment.center` whose children are: a `Text(title, style: GeniusWalletTypography.headlineLg.copyWith(color: gw.textPrimary))`, then a `Spacer()`, then — only when `trailing != null` — the `trailing` widget. Build the children list conditionally so no null slot is emitted when trailing is absent.
  2. A `SizedBox(height: GeniusWalletConsts.space8)` as the header-OWNED gap BELOW the title (space8 = 16.0; matches Markets' old Column spacing and Swap's old 16px gap, and normalizes News' old 24px down to the shared value). This is why the migrated screens each DROP their own spacer — the header owns this gap now.

Imports: `package:flutter/material.dart`, `genius_wallet/theme/genius_wallet_typography.dart`, `genius_wallet/theme/genius_wallet_consts.dart`, `genius_wallet/theme/gw_colors.dart`. Do NOT import or use any raw `Colors.*`, hex literal, or bare numeric px (the only literal spacing is via the `space8` token). Add a short doc comment describing it as the shared in-body page-title header owning its own bottom gap.
  </action>
  <verify>
    <automated>flutter analyze lib/components/scaffold/gw_page_header.dart</automated>
  </verify>
  <done>GWPageHeader exists, analyzes with 0 errors, renders left-aligned headlineLg/gw.textPrimary title + optional trailing via Spacer + a space8 bottom gap, and reads gw via the fail-soft Theme extension pattern.</done>
</task>

<task type="auto">
  <name>Task 2: Migrate Markets, News, and Swap titles onto GWPageHeader</name>
  <files>lib/dashboard/chart/markets_screen.dart, lib/dashboard/news/view/crypto_news_screen.dart, lib/squid_router/swap_screen.dart</files>
  <action>
Add `import 'package:genius_wallet/components/scaffold/gw_page_header.dart';` to each of the three files.

**Markets (`markets_screen.dart`, ~:70-103):** Replace the title `Row` (the one whose children are the `Text("Markets", ...)` and the search `IconButton`) with `GWPageHeader(title: 'Markets', trailing: IconButton(...))`, preserving the search IconButton VERBATIM: `icon: const FaIcon(FontAwesomeIcons.magnifyingGlass, size: 18)` and its exact `onPressed` that calls `ResponsiveDrawer.show<void>(context: context, title: "Search Coins", child: ListView(...MarketSearchBar...))`. Reconcile the gap: the enclosing `Column(spacing: 16.0, ...)` now double-gaps because GWPageHeader owns a 16px bottom gap AND the Column adds another 16 between its two children — remove the `spacing: 16.0` argument from that Column (its only inter-child gap was header→content; the header now provides it) so the space below the title stays a single ~16px. Leave the FutureStateWidget child and everything else untouched. The `Text` import path `genius_wallet_typography.dart` may become unused in this file after removal — if `flutter analyze` flags it as unused, remove that import; if it is still referenced elsewhere in the file, keep it.

**News (`crypto_news_screen.dart`, ~:49-53):** Replace the `Text('Crypto News', style: Theme.of(context).textTheme.displaySmall)` AND the immediately-following `const SizedBox(height: 24)` with a single `GWPageHeader(title: 'Crypto News')` (no trailing). This removes the unmapped-displaySmall outlier and the now-redundant 24px spacer (the header owns the gap). Keep the surrounding `Column(crossAxisAlignment: CrossAxisAlignment.start, ...)`, the `Expanded(FutureStateWidget(...))`, and the feed unchanged.

**Swap (`swap_screen.dart`, ~:227-262):** Replace the entire title `Row` — currently `Row(children: [const SizedBox(width: 24), const Expanded(child: Center(child: Text("Swap", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w500)))), IconButton(tune...)])` — with `GWPageHeader(title: 'Swap', trailing: IconButton(...))`. Drop the leading `SizedBox(width: 24)` balance spacer, the `Center`, and the raw `Colors.white` Text: the title becomes LEFT-ALIGNED (deliberate standardization) and tokenized. Preserve the settings IconButton's `onPressed` VERBATIM (`SwapSettingsDrawer.show(context, initialSlippage: slippage, onSlippageChanged: ...)`); keep its `icon: const Icon(Icons.tune, size: 24)` (the icon may keep its existing color argument — the IconButton is passed through as trailing unchanged; only the title text is retokenized). Reconcile the gap: GWPageHeader owns a 16px bottom gap, and there is a `const SizedBox(height: 16)` immediately after the header's `Padding` — remove that trailing `SizedBox(height: 16)` so spacing below the Swap title stays a single ~16px (no double gap). Leave the outer `Padding(horizontal: 20)`, the leading `const SizedBox(height: 24)` above the Padding, and all swap form content below unchanged.
  </action>
  <verify>
    <automated>flutter analyze lib/dashboard/chart/markets_screen.dart lib/dashboard/news/view/crypto_news_screen.dart lib/squid_router/swap_screen.dart</automated>
  </verify>
  <done>All three screens import and render GWPageHeader; Markets/Swap pass their original IconButtons (unchanged onPressed) as trailing; News has no trailing; the displaySmall path, the raw white centered Swap title, the leading Swap SizedBox(24), the News SizedBox(24), and the Swap trailing SizedBox(16) / Markets Column spacing double-gaps are all resolved; analyze reports 0 errors across the three files.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>A shared GWPageHeader (left-aligned headlineLg/gw.textPrimary title + optional trailing action + space8 bottom gap) now backs the Markets, News, and Swap in-body page titles, replacing three divergent implementations.</what-built>
  <how-to-verify>
Using the ALREADY-RUNNING debug build (no rebuild needed; use the dev-tools bubble's light/dark toggle to flip appearance in place):

1. Navigate to Markets, News, and Swap. Confirm all three page titles now render at the SAME font size/weight (24/semibold) and are LEFT-ALIGNED — in particular the News title is no longer noticeably larger than the others, and the Swap title is no longer centered.
2. Confirm the gap below each title looks consistent and single (no obvious double gap / no cramped title).
3. Markets: tap the search icon (right of the title) — the "Search Coins" drawer still opens and search works.
4. Swap: tap the settings/tune icon (right of the title) — the slippage settings drawer still opens and works.
5. Flip to LIGHT mode and repeat 1-4: all three titles must be legible dark ink on the light surface (no white-on-white, no black-on-black), trailing icons still work, Swap still left-aligned.
6. Flip back to DARK and confirm titles are legible light ink.
  </how-to-verify>
  <resume-signal>Type "approved" (both modes, all 3 screens: consistent title size/spacing, left-aligned, trailing actions work) or describe issues.</resume-signal>
</task>

</tasks>

<verification>
- `flutter analyze lib/components/scaffold/gw_page_header.dart lib/dashboard/chart/markets_screen.dart lib/dashboard/news/view/crypto_news_screen.dart lib/squid_router/swap_screen.dart` → 0 errors.
- No raw `Colors.*`, hex, or bare px in `gw_page_header.dart` (spacing via `GeniusWalletConsts.space8` only).
- Blocking human-verify walk passes in both light and dark across all three screens.
</verification>

<success_criteria>
- GWPageHeader exists at lib/components/scaffold/gw_page_header.dart and is used by Markets, News, and Swap.
- All three titles are headlineLg / gw.textPrimary, left-aligned, with a single consistent header-owned gap below.
- News no longer uses displaySmall; Swap no longer uses raw white / centered text.
- Markets search and Swap settings trailing actions retain exact original onPressed behavior.
- Analyze clean; walk approved both modes.
</success_criteria>

<output>
Stage only these files by explicit path (never `git add -A`): lib/components/scaffold/gw_page_header.dart, lib/dashboard/chart/markets_screen.dart, lib/dashboard/news/view/crypto_news_screen.dart, lib/squid_router/swap_screen.dart. Do not stage README.md or any docs.
</output>
