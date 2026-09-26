---
phase: 24-mobile-nav-shell-dock-and-accounts-sheet
plan: 01
subsystem: navigation/mobile-shell
tags: [nav, mobile, header, bottom-bar, accounts, a11y]
status: complete
provides:
  - "MobileHeader: brand lockup + fixed 100px wallet/menu cluster"
  - "Mobile bottom bar: Home, Assets, (Swap dock), Activity, News"
  - "More sheet reached from the header menu button"
  - "Two-section accounts view inside the existing account drawer"
key-files:
  created: [lib/components/overlay/mobile_header.dart, lib/components/overlay/nav_destinations.dart, lib/components/overlay/more_sheet.dart]
  modified: [lib/components/overlay/responsive_overlay.dart, lib/account/account_drawer.dart, lib/network/network_dropdown_selector.dart, lib/components/overlay/global_swap_fab_host.dart, lib/navigation/router.dart]
metrics:
  tests_added: 36 (header 17, nav destinations 11, drawer network section 8)
  completed: 2026-08-07
---

# Phase 24: Mobile nav shell Summary (backfilled from git)

Executed by Jakub outside GSD; this summary is measured from merged code, not the plan.
Shipped in `d3f1122c` (feat(nav)), merged to develop via PR #225 (`241ad41a`,
`redesign/navigation-260806`). `a91fd308` hardened the More-sheet test; `cdb2ba83` made prose English.

## What shipped
- Phone header: wallet control shrank from 224px of 342px to a 44px icon + 44px menu button.
- Bottom bar is Home, Assets, Swap dock, Activity, News. Markets, Web, Feedback, Settings live in the
  More sheet opened by the header menu button; all original destinations stay reachable.
- Zero-balance asset rows raised from `textPrimary38` to `textPrimary80` (`coin_card_row.dart`).
- Global swap FAB hidden on mobile (the dock replaces it).

## Deviations from the plan
- **IA changed after the walk (sketch 182, S7):** the plan's `Home, Markets, dock, Activity, More`
  became `Home, Assets, dock, Activity, News`; More moved to a header button.
- **No `lib/account/accounts_sheet.dart`:** the two-section SDK/Your Accounts view was built into
  `account_drawer.dart` instead of a new sheet.
- Known gap: two wallets on the same chain render the same header avatar (semantic label still
  differs); filed as a todo.
