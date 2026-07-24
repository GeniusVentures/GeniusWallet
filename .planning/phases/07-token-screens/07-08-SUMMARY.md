---
phase: 07-token-screens
plan: 08
subsystem: token-screens-human-rewalk
tags: [human-verify, walk, sketch-152, redesign, gaps-closed]
requires: [07-04, 07-05, 07-06, 07-07]
provides:
  - "Human-verified PASS for the Phase 7 token-detail re-skin + sketch-152 redesign"
  - "07-VERIFICATION.md flipped to status: passed"
affects: []
tech-stack:
  added:
    - "lib/tokens/widgets/token_detail_hero.dart (TokenDetailHero — identity + price + % hero, responsive/centered on mobile)"
    - "lib/tokens/widgets/token_action_bar.dart (TokenActionBar — compact sketch .actbtn row)"
    - "lib/tokens/widgets/sketch_icons.dart (SketchIcon/SketchIcons — exact sketch-152 SVG glyphs via flutter_svg)"
    - "CryptoLiveChart.showPriceHeader (additive; default true → dashboard unchanged)"
  patterns:
    - "Sketch-driven redesign implemented to sketch 152 (A desktop / D mobile), 034-A2 (receive QR), 030-B1 (drawer shell)"
key-files:
  modified:
    - lib/tokens/token_info_screen.dart
    - lib/chart/crypto_live_chart.dart
    - lib/components/qr/crypto_address_qr.dart
    - lib/components/bottom_drawer/responsive_drawer.dart
    - lib/components/sliding_drawer_button.dart
requirements-completed: [SCR-03]
metrics:
  completed: 2026-07-24
  tasks: 1
status: complete
---

# Phase 7 Plan 08: Human Re-Walk — Summary (PASS)

Blocking human-verify re-walk of the token-detail screen after the 07-04..07-07 gap closure, which
expanded into a full **sketch-152** token-detail redesign. Verified live on the running Windows debug
build across many iterative rebuilds; the user signed off ("all good").

## Result vs the 07-VERIFICATION gaps
1. **Token-detail layout → sketch 152** — PASS. Responsive: two-panel ≥1024, main-card-on-top with
   Info/Convert wrapping below at 768–1024, centered full-column mobile (<768). Content capped at 1200.
2. **Convert Token Price read-only** — PASS (display + READ-ONLY chip; only amount editable).
3. **Receive QR (034-A2)** — PASS (contained QR, decodes on a phone in dark; clean tap-to-copy pill).
4. **Receive drawer shell (030-B1)** — PASS (compact quiet-band header, small top-right ✕, ellipsizing
   non-bold title).
5. **More → Bridge Tokens drawer** — PASS (populated body; finding-37 non-GNUS "More" stays disabled,
   preserved by the isGnusBridgeEnabled → onMore:null gate).
6. **Finding 24 (setState-after-dispose)** — PASS — zero occurrences across every walk (live console
   monitor throughout).
7. **Send/Swap** — render clearly disabled yet legible (compact .actbtn "off" state). The send FLOW is
   the acknowledged **D-02 out-of-scope deferral** (no send flow exists) — NOT recorded as a pass.

## Redesign delivered (new, beyond the original gaps — user-directed)
- `TokenDetailHero`, `TokenActionBar`, `SketchIcons` (exact sketch SVG glyphs), chart `showPriceHeader`
  flag (price moved to the hero), sketch back-chevron header aligned to the page/cards, per-row Info
  glyph colors (appearance-legible), sketch font sizes/paddings, mobile centered idcard + full-width
  cards, desktop flex reflow, Info labels ellipsize.
- Additive-boundary respected (no shadow removal); WCAG contrast held in dark + light; chart plot
  untouched (Phase-5 fence).

Commits: 07-04..07-08 (fix/feat) + the sketch-152 style() series through `b6b3882`.
