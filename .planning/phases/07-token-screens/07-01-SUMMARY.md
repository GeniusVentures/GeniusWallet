---
phase: 07-token-screens
plan: 01
subsystem: token-detail-ui
status: complete
tags: [re-skin, gwcolors, action-button, qr, finding-16, finding-37, wcag]
requires:
  - GWColors extension (phases 2-6)
  - gw_* primitives (GWCard, GWDecorations, ResponsiveDrawer, CoinCardRow)
  - GeniusWalletConsts.space* tokens
provides:
  - Appearance-aware ActionButton (nullable color overrides, legible disabled state)
  - Re-skinned /token-info surface (action row, Info card, Convert card, both drawers)
  - Opaque-light Receive QR (finding 16/6 regression guard)
affects:
  - 07-02 (finding-24 chart lifecycle guard — separate file)
  - 07-03 (human visual/QR-scan/disabled-legibility walk)
tech-stack:
  added: []
  patterns:
    - "Fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() read for live-appearance rebuild on const widgets"
    - "§4.4 always-light chip exception (raw Colors.white) for QR backing + token-logo CircleAvatar"
key-files:
  created: []
  modified:
    - lib/components/action_button.dart
    - lib/tokens/token_info_screen.dart
    - lib/components/qr/crypto_address_qr.dart
decisions:
  - "Disabled ActionButton uses surfaceSunken fill + textPrimary54 glyph/caption — distinct AND legible (chose 54% over the plan's example textPrimary38 for stronger WCAG headroom on the 13px caption)"
  - "_MarketDataInfo token-logo fallback Icon left on cs.onSurfaceVariant (pre-existing; the chip is §4.4 always-light — out of this re-skin's scope)"
metrics:
  duration: ~5m
  completed: 2026-07-23
  tasks: 3
  files: 3
---

# Phase 7 Plan 01: Token-detail re-skin Summary

Re-skinned the `/token-info` surface and its two drawers to the redesign system while preserving develop's behavior: the ActionButton component, the token-detail screen (action row, Info card, Convert card, Receive + More drawers), and the Receive QR widget now resolve every color through the appearance-aware `GWColors` extension + `brandPrimaryOnSurface` accent — with finding 37 (More disabled on non-GNUS) and finding 16/6 (opaque-light QR) locked in the same pass.

## What was built

**Task 1 — `lib/components/action_button.dart` (commit 639fe60)**
- The three legacy const color defaults (`deepBlueCardColor` / `lightGreenSecondary` / `Colors.grey`) are removed; the fields are now nullable overrides.
- `build()` does a fail-soft `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` read (registers the InheritedWidget dependency so even a `const ActionButton` re-skins on a live appearance toggle) and resolves: fill → `surfaceElevated`, icon glyph → `brandPrimaryOnSurface`, caption → `textSecondary`.
- Disabled state (Send / Swap / gated More) gets an explicit, legible, appearance-aware treatment: `surfaceSunken` fill via `disabledBackgroundColor` + `textPrimary54` glyph & caption — recessed and clearly not-enabled, yet legible in both modes.
- `borderRadiusCard`, the 13/w500 caption, `AutoSizeText` ellipsis, the rotate animation, and `Semantics(button:true, enabled: onPressed != null)` are all preserved.

**Task 2 — `lib/tokens/token_info_screen.dart` (commit c3141f6)**
- Finding 37 LOCKED: More's `onPressed` stays `isGnusBridgeEnabled ? (...) : null` (line 184), the inner `selectedCoin?.balance == 0 ? null : ...` gate and `/bridge` push are intact. The always-enabled + empty-child anti-pattern was NOT reintroduced.
- Send & Swap stay inert `const ActionButton(...)` with no `onPressed` — they now render the re-skinned disabled treatment from Task 1.
- `_MarketDataInfo`: outer `Card(color: cs.surface)` → `GWCard`; the rainbow leading icons (`amber/lightBlue/orange/red[300]`) AND the `cs.primary` reads on Network/Address/copy → a single restrained `brandPrimaryOnSurface` accent; subtitle → `gw.textSecondary`; token-logo `CircleAvatar` keeps raw `Colors.white` (§4.4).
- `_ConvertSection`: `Card` → `GWCard`; TextFields inherit the shipped input theme (no hardcoded InputDecoration colors); the price×amount calc, controllers, and "Total: $X" readout are unchanged.
- `SlidingDrawerButton` in the More drawer gets `color: gw.textPrimary`.
- Raw spacing literals (`20.0`, `8`, `16`) migrated to `GeniusWalletConsts.space10 / space8 / space4`; `CoinCardRow` top-slot wiring (D-04) left intact.

**Task 3 — `lib/components/qr/crypto_address_qr.dart` (commit dc0b705)**
- `QrImageView.backgroundColor` upgraded from `Colors.white.withValues(alpha: 0.8)` → opaque `Colors.white` so default-black QR modules stay phone-camera scannable over the dark drawer in both modes; never bound to an appearance token (finding 16 regression guard).
- QR-drawer rhythm literals (`height: 32`, `height: 8`) tokenized to `space16` / `space4`.

## Deviations from Plan

**None functionally.** Two documented judgment calls within the plan's stated discretion:
1. **Disabled glyph/caption token:** the plan offered `textPrimary38` as an *example* lowered-but-visible token ("or a lowered-but-visible token such as textPrimary38"). Chose `textPrimary54` instead for stronger WCAG headroom on the 13px caption, while `surfaceSunken` fill + the cyan→gray glyph shift keep it clearly distinct from enabled. Final legibility is the 07-03 walk's to confirm.
2. **Token-logo fallback Icon:** the `CircleAvatar`'s no-image fallback `Icon(Icons.token, color: cs.onSurfaceVariant)` was left unchanged. It sits on the §4.4 always-white chip where an appearance-aware token would be wrong; it is a pre-existing latent condition outside this re-skin's scope (the plan only mandated migrating the rainbow icons, `cs.primary` reads, and the subtitle).

## Verification

- **`flutter analyze lib` = 61 issues** — equal to the stated 61 baseline; **zero** of the 61 issues are in any of the three modified files (grep of the analyzer output for the three filenames returned nothing). No regression. (A cold concurrent run mid-edit transiently reported 64; the warm run settled at 61.)
- **Task 1 grep guard:** PASS — `extension<GWColors>|surfaceElevated|brandPrimaryOnSurface|textSecondary` all present; no `deepBlueCardColor|lightGreenSecondary|Colors.grey` remain.
- **Task 2 grep guard:** PASS — `onPressed: isGnusBridgeEnabled` present (line 184); `GWCard` present (2 sites); no `Colors.amber|lightBlue|orange[|red[` remain. Send/Swap confirmed `const ActionButton` with no onPressed (lines 179-180).
- **Task 3 grep guard:** PASS — `backgroundColor: Colors.white` present; no `backgroundColor` bound to `textPrimary|surface`.
- **Not asserted here (07-03's human walk):** dark+light visual fidelity, phone-camera QR scan in dark mode, and disabled-state legibility.
- **No test regression risk:** grep of `test/` found no references to `ActionButton`, `CryptoAddressQR`, or the changed defaults, so the ActionButton nullable-field API change breaks no test.

## Out of scope / deferred (unchanged by this plan)

- Real Send flow and address book — deferred (D-01/D-02); Send stays a re-skinned dead button.
- Swap wiring — Phase 8.
- `crypto_live_chart.dart` — untouched here; finding-24 lifecycle guard is 07-02's.
- STATE.md / ROADMAP.md writes — owned by the orchestrator, intentionally not touched.

## Self-Check: PASSED
- lib/components/action_button.dart — FOUND
- lib/tokens/token_info_screen.dart — FOUND
- lib/components/qr/crypto_address_qr.dart — FOUND
- commit 639fe60 — FOUND
- commit c3141f6 — FOUND
- commit dc0b705 — FOUND
