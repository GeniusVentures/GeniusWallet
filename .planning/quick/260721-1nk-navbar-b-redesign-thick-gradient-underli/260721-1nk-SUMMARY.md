---
task: 260721-1nk
title: Navbar "B" + Markets "A" + secondary CTA fix
status: complete
date: 2026-07-21
walk: pending
committed: false   # CLAUDE.md gate — all edits left UNSTAGED
files_changed:
  - lib/components/overlay/responsive_overlay.dart
  - lib/theme/genius_wallet_consts.dart
  - lib/reown/reown_connect_button.dart
  - lib/chart/crypto_simple_chart.dart
  - lib/dashboard/chart/dashboard_markets.dart
  - lib/components/buttons/gw_button.dart
requirements: [NAV-B, MKT-A, CTA-SECONDARY]
---

# Quick 260721-1nk — Navbar B + Markets A + secondary CTA fix

Landed three approved, locked dark-first designs on the desktop wallet chrome. No new
deps, no commits (CLAUDE.md gate), `flutter analyze` clean on all touched files.

## Task A — Navbar "variant B" (thick gradient underline, bigger icons, roomier bar, ghost Connect)

- `responsive_overlay.dart`: `_kIconSize` 16 → **23**; active-item `AnimatedContainer` underline
  `height: 1` → **3**, `borderRadius` → `BorderRadius.vertical(top: Radius.circular(3))`
  (rounded top, flush bottom), added a selected-only `boxShadow`
  (`brandPrimaryStrong` @ 0.5, `blurRadius: 10`) for the glow. Kept the one-decoration-per-state
  guard (gradient XOR color — never both), the 200ms duration, and the `hideLabels ? 20 : 60`
  width. Active label/icon stays `brandPrimaryStrong` (0ze sweep, not regressed).
- `genius_wallet_consts.dart`: `appBarHeight` 60 → **68** (single shared token; `_DesktopTopBar`
  preferredSize/SizedBox and `dev_tools_bubble` `_headerHeight` both follow it — correct).
- `reown_connect_button.dart`: idle "Connect" branch restyled to the 002-B ghost — `iconColor`
  and `textColor` → `brandPrimaryStrong`, `backgroundColor` → `Colors.transparent`, plus a
  1.5px `brandPrimaryStrong` outline. Connection logic (`_connect`/`_disconnect`/`onPressed`)
  untouched.

## Task B — Markets "variant A" (real panel header + Assets-mirror rows)

- `crypto_simple_chart.dart`: retired the legacy `_mutedGreen`/`_mutedRed` statics and the
  `priceColor` getter; up/down now `changeColor = priceChangePercent >= 0 ? gw.statusSuccess :
  gw.statusError` (appearance-aware). `iconSize` default 28 → **34**. NAME is now primary
  (`titleMd`/`textPrimary`), price secondary (`bodySm`/`textSecondary`). Trailing % is now a
  **filled chip** (`changeColor` @ 0.15 fill, `labelMd`/`changeColor` text) mirroring the Assets
  `CoinCardRow`. Sparkline resized 80×15 → **56×20**, stroke → `changeColor`. Trailing `SizedBox`
  `height: 44` → **50** (chip ≈22 + spacing 5 + sparkline 20 = 47 ≤ 50 — fixes the RenderFlex
  overflow the pending todo flagged). Dropped the now-unused `GeniusWalletColors` import; added
  `GeniusWalletTypography`.
- `dashboard_markets.dart`: deleted the `index == 0 && widget.title != null` first-item Column
  hack; `itemBuilder` returns just the row. Header promoted to a real row above the list —
  `Column[ Padding(Row[ Text(title ?? 'Markets', titleLg/textPrimary), Text('Top {n} · 24h',
  bodySm/textSecondary) ]), Expanded(ListView.separated(...)) ]`. The `Expanded` keeps the
  existing bounded-height contract intact. Added `GeniusWalletConsts` import. Separator, data
  source, tap/nav unchanged.

## Task C — GWButtonVariant.secondary → brandPrimaryStrong

- `gw_button.dart`: `_palette()` `secondary` case — `foreground` and `border` color
  `brandPrimary` → **brandPrimaryStrong**. Stayed a transparent outline (no gradient). One
  central edit propagates to every secondary CTA app-wide (settings, Add-Wallet/Account,
  transaction displays, empty states).

## Second surface checked — `/markets` full page (shared `CryptoSparkLineChart`)

`markets_screen.dart:186` renders the SAME row for the full-page `/markets` route, each wrapped
in a fixed-height grid cell (`mainAxisExtent: 80`) inside a `Clip.hardEdge`
`GWDecorations.surface(radiusMd)` card, passing `iconSize: 32`.

**Verdict: no clip, no overflow — no source edit to `markets_screen.dart` needed.** Reasoning:
- The row is a two-line `ListTile` (title `titleMd` + subtitle `bodySm`), whose Material minimum
  height is **72px**. The trailing `SizedBox(height: 50)` and the 32px leading icon are both
  **under** that 72px floor, so the ListTile's overall height is governed by the 72px minimum —
  not by the taller trailing box. The old trailing (44) was also < 72, so **the `/markets` cell
  height is unchanged by this redesign** (72px then, 72px now).
- 72px ListTile inside an 80px cell → 8px headroom → no vertical clip against the hardEdge card.
- Inside the trailing box the new Column (chip ≈22 + spacing 5 + sparkline 20 = 47) fits in 50.
- Horizontally the sparkline shrank (80 → 56) and the % became a compact chip, so there is less
  horizontal pressure inside the card than before, not more.
- `iconSize` stays an explicit `32` on `/markets`, so the new default `34` affects only the
  dashboard panel — as intended.

A runtime render-check was not possible (`flutter test` harness is broken per STATE blockers,
no GUI here); the check above is geometric against the ListTile height contract. The human dark
walk should still confirm `/markets` visually per the plan's verification item 4.

## Verification (real output)

`flutter analyze` on all 6 changed files + `markets_screen.dart` (7 items):

```
Analyzing 7 items...
   info • Don't use 'BuildContext's across async gaps • lib/reown/reown_connect_button.dart:158:13 • use_build_context_synchronously
   info • Don't use 'BuildContext's across async gaps • lib/reown/reown_connect_button.dart:403:36 • use_build_context_synchronously
2 issues found. (ran in 4.1s)
```

Both remaining infos are **pre-existing** (lines 158/403, inside the async `_connect`/`_disconnect`
methods — not touched by this task; confirmed via `git blame`, authored by TechUp24/Eduardo).
All Task A/B/C grep gates pass.

## Deviations from plan

1. **[Rule 1 — bug] Connect outline made idle-only, not unconditional.** The plan's literal
   snippet put `side: const BorderSide(...)` directly on the shared `TextButton.styleFrom`,
   which would paint a cyan outline on the red **Disconnect** and warning **Connecting** states
   too — contradicting the plan's own "restyle **ONLY** the idle visual branch" and "leave the
   connected/connecting/timedOut/error branches untouched." Honored the stated intent: added a
   per-branch `BorderSide? border` set only in the idle `else`, passed as `side: border`. Status
   branches stay filled + borderless.
2. **[Rule 1 — analyze cleanliness] Removed the now-dead `gw` local in `reown_connect_button.dart`
   build().** The idle-branch restyle removed its last two reads (`gw.textPrimary`,
   `gw.surfaceElevated`), leaving an `unused_local_variable` warning. Every branch now paints
   fixed brand/status colors, so the build has no appearance-aware output for a live toggle to
   re-skin; removing the read is correct (the `GWColors` import stays — still used at line 251 in
   a separate build). Left a comment explaining why the fail-soft read is intentionally absent.
3. Reworded the `secondary` palette comment to drop the bare token word "brandPrimary" so the
   plan's `! grep brandPrimary[^S]` gate reads literally green (the code was already clean; only
   the comment tripped it).

## Light-mode deferral

`brandPrimaryStrong` (#0AAEE6) outline/text and the status-tint chips are dark-tuned. The status
tokens are appearance-aware and adapt, but the ghost-Connect border/text and the 3px gradient
bar are dark-first. Any light-mode contrast (WCAG AA) for the new accent is **DEFERRED to the
light pass** per front-matter `light_mode_deferral` — not solved here.

## Not touched (as constrained)

`coins_screen.dart` / `coin_card_row.dart` (Assets), `/banxa`, `/squidrouter`, `*.g.dart`. No
other `brandPrimary` site changed. 0ze sweep (gradient CTAs, `brandPrimaryStrong` highlights) and
vwj Assets work not regressed. No new deps in `pubspec.yaml`. No commits.

## Self-Check: PASSED

- All 6 changed files exist and analyze clean (+ `markets_screen.dart` verified unaffected).
- No commits made (verified: edits left unstaged per CLAUDE.md gate).

## Correction pass (mockup alignment)

Follow-up pass — the initial delivery deviated from the APPROVED mockups on 3 points.
Exact fixes below; `flutter analyze` clean on both touched files; no commits (CLAUDE.md gate).

- **FIX 1 — Markets row now horizontal (003-A):** `crypto_simple_chart.dart` trailing was a
  `SizedBox(height:50, child: Column[ %chip ABOVE sparkline ])`. Rebuilt to
  `Row(mainAxisSize: min, crossAxisAlignment: center, children: [ sparkline(56×20),
  SizedBox(width:12 /*space6*/), %chip ])` — sparkline LEFT, % chip RIGHT, side-by-side,
  matching `.right{display:flex}` → `[spark][chip]`. Dropped the fixed `height:50` / `spacing:5`.
  Chip styling (status tint 0.15 + status fg, radius 8) and sparkline (56×20, status stroke)
  unchanged. "First the light graph, then the growth %."
- **FIX 2 — Nav active tab is white, underline is the only accent (002-B):** `_DesktopTopBar`
  active `color` changed `brandPrimaryStrong` → `gw.textPrimary` (drives both the icon ~:239
  and label ~:246). The 3px `brandCta` gradient underline + glow is untouched — now the sole
  accent. Mobile bottom nav left on `brandPrimaryStrong` (separate surface, per constraint).
- **FIX 3 — Nav icons unified to the outline set (002 glyphs):** `_allDestinations` —
  Dashboard `Icons.dashboard`→`dashboard_outlined`; Markets `stacked_line_chart`→`show_chart`;
  News `library_books`→`article_outlined`; Feedback `feedback_outlined`→`chat_bubble_outline`;
  Settings `settings`→`settings_outlined`. Kept (already outline/matching): Transactions
  `FontAwesomeIcons.clock`, Swap `swap_horiz_outlined`, Web `FontAwesomeIcons.globe`. Icon
  size 23 unchanged, no new deps.

Not regressed: 3px gradient underline + glow, appBarHeight 68, `_kIconSize` 23, ghost Connect,
Markets header/status-colors/chip styling, secondary CTA. Touched ONLY `responsive_overlay.dart`
+ `crypto_simple_chart.dart`. No commits.

`flutter analyze lib/components/overlay/responsive_overlay.dart lib/chart/crypto_simple_chart.dart`
→ **No issues found!** (ran in 4.4s)

### Second correction pass — top-nav layout (260721-1nk, `responsive_overlay.dart` only)

Four targeted `_DesktopTopBar` layout fixes to match the mockup's logo/tab alignment. No commits.

- **FIX 1 — Logo bigger:** `Image.asset(geniusappbarlogo.png)` `height: 30` → **40** (~14px
  breathing room inside the 68px bar). Asset + `package: 'genius_wallet'` kept.
- **FIX 2 — Equal, bigger left gaps (page-left→logo AND logo→Dashboard):** bar padding
  `EdgeInsets.symmetric(horizontal: 12)` → `EdgeInsets.fromLTRB(24, 0, 12, 0)` (left 24, right
  unchanged). Restructured the left cluster to
  `Row[ Image(h:40), SizedBox(width:24), Row(spacing: hideLabels?6:2, [...navItems]) ]` — the
  logo→nav gap is a fixed 24 while the inter-nav-item spacing stays tight (2/6).
- **FIX 3 — Vertical alignment:** each tab is now
  `SizedBox(height: appBarHeight=68) > Padding(h:12) > IntrinsicWidth > Column(min,
  mainAxisAlignment: center, ...)`. The icon+label block is centered on the bar's vertical
  center so it lines up with the (40px) logo; the 3px underline sits at the bottom of that
  centered block. (Dropped the old `vertical: 6` padding + `Ink` wrapper.)
- **FIX 4 — Underline spans the full tab name:** removed the fixed `width: hideLabels ? 20 : 60`.
  `Column(crossAxisAlignment: stretch)` inside `IntrinsicWidth` makes the width-less
  `AnimatedContainer` stretch to the icon+label Row's content width — long bar for
  "Transactions", short for "Swap", icon-only when labels hidden. Gradient (`brandCta`),
  `blurRadius: 10` glow, `Radius.circular(3)` rounded top, and the gradient-XOR-color per-state
  guard all preserved. IntrinsicWidth gives the Column a bounded width, so `stretch` has no
  unbounded-width RenderFlex trap.

Not regressed: active tab text/icon `gw.textPrimary` (white), outline icon set, appBarHeight 68,
`_kIconSize` 23, gradient underline + glow + rounded top, ghost Connect, mobile bottom nav.
Touched ONLY `responsive_overlay.dart`. No commits.

`flutter analyze lib/components/overlay/responsive_overlay.dart`
→ **No issues found!** (ran in 4.4s)

### Walk follow-up (gap + vertical-center)
- **Logo→nav gap equalized:** the geniusappbarlogo.png (38×38) bakes in a ~9px transparent RIGHT margin (opaque bbox x:1→29) vs ~1px left, so the raw 24px SizedBox rendered a ~33px visible right gap vs ~25px left. SizedBox 24→**15** compensates → both visible gaps ≈24. (Left bar padding stays 24.)
- **Tab label vertical-center fix:** the item Column was `MainAxisSize.min` so `mainAxisAlignment.center` was a no-op (collapsed to content, top-aligned → label pulled up). Changed to `MainAxisSize.max` → the icon+label block now truly centers in the 68px bar, aligned with the 40px logo.
- Both applied inline (2 one-liners), `flutter analyze` clean, no commit.
