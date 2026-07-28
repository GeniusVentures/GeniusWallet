# Phase 22 Plan 01 — Deletion Evidence Record

Measured 2026-07-28, re-verified immediately before deletion in this session. Two-way check per
file: full `package:genius_wallet/...` import path AND bare basename, searched across `lib/` and
`test/` with `grep -rn <name> lib test --include=*.dart`, excluding the file's own declaration
line.

## Unconditional deletions (zero references found)

| File | LOC | References found | Disposition |
|------|-----|-------------------|-------------|
| `lib/components/app_screen_with_header_desktop.dart` | 52 | 0 | Deleted |
| `lib/components/app_screen_with_header_mobile.dart` | 50 | 0 | Deleted |
| `lib/components/button/copy_button.dart` | 78 | 0 | Deleted |
| `lib/components/coins/view/coin_card_container.dart` | 19 | 0 | Deleted |
| `lib/components/currency_dropdown.dart` | 29 | 0 | Deleted |
| `lib/components/desktop_body_container.dart` | 37 | 0 | Deleted |
| `lib/components/desktop_container.dart` | 162 | 0 | Deleted |
| `lib/components/number_pad.dart` | 102 | 0 | Deleted |
| `lib/components/qr_scanner/gw_qr_scanner.dart` | 202 | 0 | Deleted |
| `lib/components/responsive_grid.dart` | 25 | 0 | Deleted |
| `lib/components/sgnus/sgnus_connected_dropdown.dart` | 33 | 0 | Deleted |
| `lib/components/toast/ticker_provider.dart` | 22 | 0 | Deleted |
| `lib/squid_router/models/squid_chain_info.dart` | 99 | 0 | Deleted |
| `lib/tokens/widgets/token_detail_hero.dart` | 303 | 0 | Deleted |

None of the 14 files declared `part of`, so none belonged to another library via `part`. Subtotal:
1,213 LOC.

## Adjudicated files (exactly one reference each)

| File | LOC | Referencing file | Reference kind | Disposition |
|------|-----|-------------------|-----------------|-------------|
| `lib/components/custom_drop_down.dart` | 62 | `lib/tokens/token_info_screen.dart:671` | Prose comment (`` // `custom_drop_down.dart` - for `GWTextField`, which puts the ``) — no import, no symbol usage | Deleted |
| `lib/components/sgnus/sgnus_wallet.dart` | 50 | `lib/theme/genius_wallet_colors.dart:156` | Prose comment (`// Alias used by ported components (e.g. sgnus_wallet.dart) that reference`) — no import, no symbol usage | Deleted |
| `lib/dashboard/chart/markets_search_bar.dart` | 161 | `lib/components/sliding_drawer_button.dart:11` | Prose comment (`// Defaults to false so every pre-existing caller (markets_search_bar.dart,`) — no import, no symbol usage | Deleted |

Note: the plan text paired the three adjudicated files with referencing files in a slightly
different order than what the re-verified grep found (it paired `custom_drop_down.dart` with
`sliding_drawer_button.dart` and `markets_search_bar.dart` with `token_info_screen.dart`; the
actual single reference for each is as listed above). The `sgnus_wallet.dart` ↔
`genius_wallet_colors.dart` pairing matches the plan exactly, confirming the same `gray500` alias
rationale-comment case described in STATE.md. In all three cases the single hit is a comment, not
a live `import`/usage, so per the plan's adjudication rule ("Delete the ones whose only reference
is a comment") all three are dead code and were deleted.

Subtotal: 273 LOC.

## Total

17 files deleted, 1,486 LOC removed from `lib/`.

## Explicitly NOT deleted (per plan's guardrails)

- `lib/web/web_view_mobile.dart`, `lib/web/web_view_windows.dart` — imported relatively by
  `lib/web/web_view_screen.dart`; look unreferenced to a package-path-only scan but are live.
- Everything under `lib/dev/` — `lib/dev/design_gallery_screen.dart` is a deliberate showcase and
  the sole consumer of several design-system components.

## Post-deletion verification (Task 1 gate)

- `flutter analyze --no-pub`: **300 issues found**, 0 `error`-severity diagnostics (baseline was
  319; deletions only lowered the count, as required).
- `flutter test --no-pub`: **512 passing, 1 failing** — the expected pre-existing failure
  (`test/local_wallet_storage_test.dart`), removed in Task 2.
