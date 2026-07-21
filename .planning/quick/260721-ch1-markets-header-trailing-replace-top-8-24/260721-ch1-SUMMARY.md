---
task: 260721-ch1
title: Replace Markets header "Top n · 24h" filler with editorial "View all" link (sketch 003-D)
date: 2026-07-21
status: complete
committed: false  # CLAUDE.md forbids commits — left unstaged, WALK PENDING
files_created:
  - lib/components/cards/gw_view_all_link.dart
files_modified:
  - lib/dashboard/chart/dashboard_markets.dart
verification: flutter analyze (2 files) — "No issues found! (ran in 2.5s)"
walk: PENDING
---

# 260721-ch1 — Markets header "View all" link — Summary

## What changed

Replaced the Markets panel header's dead-metadata trailing (`Text('Top ${n} · 24h')`)
with the approved **editorial "View all" link** (sketch 003-markets-panel, variant D).

### 1. New reusable widget — `lib/components/cards/gw_view_all_link.dart`

`GWViewAllLink({required VoidCallback onTap, String label = 'View all'})` — a boxless
text link built for the shared `GWSectionTitle` trailing slot, reusable by other
panels (Assets/Transactions) later.

- **Rest state:** uppercase "VIEW ALL", Inter 11px `w600`, letterSpacing 0.88
  (0.08em tracking), color `gw.textSecondary`; trailing `Icons.arrow_right_alt` (15px)
  in the same color. No background box.
- **Hover (desktop):** label + arrow tint to `GeniusWalletColors.brandPrimary`; the
  arrow slides 3px right (`AnimatedContainer` transform); a 1.5px `brandCta` gradient
  underline (green→blue, matching the mockup's `#0AD89C → #0AAEE6`) fades in under the
  LABEL width only via `AnimatedOpacity`. Pointer cursor.
- **Mechanics:** `StatefulWidget` + `MouseRegion` (`onEnter`/`onExit` → `setState`) +
  `GestureDetector` — deliberately NOT `InkWell` (its hover/splash box violates the
  "no background box" design). Implicit animations at `GeniusWalletMotion.base` (200ms,
  the design-locked duration; `fast` is 120ms so it was not the right token).
- **No layout shift:** the underline lives in a `Column(crossAxisAlignment: stretch)`
  so it sizes to exactly the label width (the arrow sits outside the column); its slot
  (3px gap + 1.5px bar) is ALWAYS reserved and only opacity animates, so hover never
  moves the row baseline. Arrow slide uses `transform` (no reflow).
- **Live re-skin:** fail-soft `Theme.of(context).extension<GWColors>() ?? GWColors.dark()`
  read registers the InheritedWidget dependency (04-04 discipline).

### 2. Wired into `lib/dashboard/chart/dashboard_markets.dart`

`trailing: GWViewAllLink(onTap: () => context.go('/markets'))`. `/markets` is a
top-nav shell destination (`router.dart:237`, `GoRoute('/markets')` inside the shell),
so `context.go` switches the shell tab (correct) rather than pushing a route.

Removed the old `Text(...)` and the now-unused `GeniusWalletTypography` import; added
the `gw_view_all_link.dart` import. Kept `gw` (still used for `gw.borderSubtle`) and
`visibleCoins` (still drives the list).

## Deviations from plan

None — executed exactly as written.

## Verification

`flutter analyze lib/components/cards/gw_view_all_link.dart lib/dashboard/chart/dashboard_markets.dart`:

```
Analyzing 2 items...
No issues found! (ran in 2.5s)
```

- **Widget check:** a pure presentational widget — the check is `flutter analyze` +
  the human hover walk. No hollow unit test (nothing non-trivial to assert; a golden
  would be a fixture-heavy over-build for a hover tint).
- **Light-mode contrast:** dark-first per branch policy. At rest the label is
  `gw.textSecondary` (6.3:1 on light via the appearance-aware token — passes AA); on
  hover the label tints to `brandPrimary` (`#14C8FF`) and the design notes
  `brandPrimaryStrong` (`#0AAEE6`) as the light-mode ideal — deferred to the light pass
  (dark-first). No light nit blocks the dark walk.

## Constraints honored

- No commit / no `git add` — files left unstaged (CLAUDE.md gate). No ROADMAP.md.
- Touched ONLY the new widget + `dashboard_markets.dart`. No other panels, Markets
  rows, `/banxa`, `/squidrouter`, or `*.g.dart` touched. `GWSectionTitle` 44px header
  geometry untouched.

## Walk

PENDING (dark): hover the Markets header "VIEW ALL" — expect brand tint, arrow slide
right, gradient underline draw under the label; click navigates to the `/markets` tab.
