---
created: 2026-07-18T10:52:39.825Z
title: Bundle Inter font so it loads offline instead of GoogleFonts network fetch
area: ui
files:
  - lib/theme/genius_wallet_typography.dart:28
  - pubspec.yaml:13
  - pubspec.yaml:203
---

## Problem

Surfaced during the Phase 4 / 04-01 D-02 gallery re-walk (2026-07-18).

Button labels — and, by the same mechanism, likely ALL Inter body/heading text —
render in a platform fallback font instead of Inter. On the gallery walk this
showed up as button labels in the wrong (serif-ish) font.

Root cause: `GeniusWalletTypography._inter()` builds every text style via
`GoogleFonts.inter(...)` (`lib/theme/genius_wallet_typography.dart:28`). The
`google_fonts` package fetches the font over the network at runtime unless it is
bundled as an asset. `pubspec.yaml` bundles only **JetBrainsMono**
(`pubspec.yaml:203`), not Inter. When the app runs offline / with blocked network
(this machine's build run showed repeated `HandshakeException` /
`ClientException` in the log), Inter never downloads and text falls back to the
default platform font.

This is app-wide (not gallery-specific) and independent of the appearance-toggle
work — it just became visible during the re-walk.

## Solution

TBD — evaluate during Phase 4 planning. Candidate approaches:

1. Add the Inter TTFs to `assets/fonts/` and declare an `Inter` family under
   `flutter: fonts:` in `pubspec.yaml` (mirroring the existing JetBrainsMono
   block), then either (a) point `google_fonts` at the bundled files, or (b) drop
   `GoogleFonts.inter()` and use `TextStyle(fontFamily: 'Inter', ...)` directly so
   there is no network path at all.
2. If keeping `google_fonts`, disable runtime fetching
   (`GoogleFonts.config.allowRuntimeFetching = false`) once fonts are bundled, so
   a missing bundle fails loudly instead of silently falling back.

Cross-ref: sibling finding this session
`2026-07-18-const-widgets-do-not-re-skin-on-live-appearance-toggle.md`.
