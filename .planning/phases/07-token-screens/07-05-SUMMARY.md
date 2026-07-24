---
phase: 07-token-screens
plan: 05
subsystem: ui
tags: [re-skin, receive-qr, gwcolors, wcag, finding-16, gap-closure, sketch-034]

# Dependency graph
requires:
  - phase: 07-01
    provides: Opaque-light Receive QR (finding 16/6 regression guard) that this plan re-skins in place
provides:
  - "CryptoAddressQR re-skinned to sketch 034-A2: contained QR (explicit size:190, was full-bleed ~304px), network chip moved above the QR, full address shown as a tappable 4-char-chunked mono block (copy-only), bordered amber network-mismatch note"
affects: [07-08 (human re-walk confirms ~60% size + phone-camera dark-mode scan)]

tech-stack:
  added: []
  patterns:
    - "Local mode-divergent warning color (light 0xFF92400E / dark GeniusWalletColors.statusWarning) scoped inside the widget file, mirroring GWColors.light()/.dark()'s own statusSuccess/statusError divergence, without touching gw_colors.dart (out of this plan's file scope)"
    - "JetBrainsMono registered font family reused for the chunked-address mono block (same font already used by verify_recovery_phrase_screen.dart)"

key-files:
  created: []
  modified:
    - lib/components/qr/crypto_address_qr.dart

key-decisions:
  - "QR contained size set to 190px (~62% of the prior ~304px full-bleed fill, inside the plan's stated 180-200px range) via QrImageView(size:), independent of the caller's wrapping SizedBox"
  - "GeniusWalletColors.statusWarning (#FFC42E) is a FILL-ONLY token (documented in transaction_badge.dart as tuned for dark badge fills) and fails WCAG non-text contrast (~1.6:1) on the light canvas; introduced a local light-mode-only divergent amber (#92400E, ~7.1:1 on white) scoped to this file rather than editing gw_colors.dart, which is outside this plan's files_modified boundary"
  - "Converted CryptoAddressQR from StatelessWidget to StatefulWidget to drive the inline copy-icon 'copied' feedback (content_copy -> check), replacing the full-width CopyButton widget with the sketch's welded inline copy affordance while keeping the same Clipboard.setData copy-to-clipboard behavior"

requirements-completed: [SCR-03]

coverage:
  - id: D1
    description: "QR is contained via an explicit QrImageView(size: 190) instead of filling its parent — self-contained regardless of the caller's SizedBox"
    requirement: "SCR-03"
    verification:
      - kind: unit
        ref: "grep -Eq 'QrImageView\\(' && grep -Eq 'size:' lib/components/qr/crypto_address_qr.dart"
        status: pass
    human_judgment: false
  - id: D2
    description: "QR backing stays raw opaque Colors.white in both modes (finding 16/6 regression guard, no appearance-token binding)"
    requirement: "SCR-03"
    verification:
      - kind: unit
        ref: "grep -q 'backgroundColor: Colors.white' lib/components/qr/crypto_address_qr.dart"
        status: pass
    human_judgment: false
  - id: D3
    description: "Network chip moved above the QR; 'Your $network Address' heading removed"
    requirement: "SCR-03"
    verification:
      - kind: unit
        ref: "! grep -q 'Your \\$network Address' lib/components/qr/crypto_address_qr.dart"
        status: pass
    human_judgment: false
  - id: D4
    description: "Full address renders as a 4-char-chunked, copy-only mono block with first/last chunk emphasis; no Share / set-default action added"
    verification: []
    human_judgment: true
    rationale: "Visual chunk grouping, emphasis weighting, and inline copy affordance placement are layout/appearance judgments best confirmed at the 07-08 human re-walk, not greppable"
  - id: D5
    description: "The ~60% QR size reduction and continued phone-camera scannability in dark mode"
    verification: []
    human_judgment: true
    rationale: "Real-device visual size perception and phone-camera QR decode are explicitly deferred to the 07-08 human re-walk per this plan's own verification section"

duration: ~15min
completed: 2026-07-24
status: complete
---

# Phase 7 Plan 05: Receive QR re-skin to sketch 034-A2 Summary

**Re-skinned `CryptoAddressQR` to the locked sketch 034-A2 "Grouped address": an explicitly-sized contained QR (190px, was an unbounded fill inside a 320px caller SizedBox ≈ 304px), the network chip moved above the QR, and the full address rendered as a tappable 4-char-chunked JetBrainsMono block with copy-only inline affordance — while preserving the finding-16/6 opaque-white QR backing.**

## Performance

- **Duration:** ~15 min
- **Completed:** 2026-07-24T12:50:28Z
- **Tasks:** 1
- **Files modified:** 1

## Accomplishments
- `QrImageView` now takes an explicit `size: 190` (self-contained, independent of the caller's `SizedBox`) instead of filling its parent — closes gap 3 (oversized Receive QR).
- Coin/network identity moved to a borderless chip ABOVE the QR (small `CircleAvatar` + network name, `textSecondary`); the "Your $network Address" `headlineSmall` heading is gone.
- Full address now renders below the QR as a tappable, `JetBrainsMono` 4-char-chunked block with first/last chunks emphasized (`textPrimary`/`w700`) and middle chunks in `textSecondary`/`w400`, with a welded inline copy icon (swaps to a check on copy, same 2s reset behavior as `CopyButton`) — copy-only, no Share/set-default.
- The generic "Use this address to receive tokens." line became a quiet bordered amber network-mismatch note.
- `backgroundColor: Colors.white` on the `QrImageView` is untouched (finding 16/6, §4.4 always-light exception) — the QR still renders default-black modules on an opaque light tile in both appearance modes.

## Task Commits

1. **Task 1: Re-skin CryptoAddressQR to sketch 034-A2 — contained QR, network chip above, chunked address** - `e245167` (feat)

**Plan metadata:** (this commit, docs — see final commit below)

## Files Created/Modified
- `lib/components/qr/crypto_address_qr.dart` - Contained QR (explicit `size: 190`), network chip above the QR, 4-char-chunked copy-only mono address block, bordered amber warning note; finding-16/6 opaque-white backing preserved verbatim.

## Decisions Made
1. **QR size = 190px.** Inside the plan's stated 180-200px range and ~62% of the prior ~304px full-bleed fill (a bit under the "~60%" target but within tolerance); final visual sizing judgment deferred to 07-08.
2. **Local mode-divergent warning color, not a `gw_colors.dart` edit.** `GeniusWalletColors.statusWarning` (`#FFC42E`) is documented in `transaction_badge.dart` as a FILL-ONLY token tuned for the dark badge canvas (~13:1 contrast there); measured contrast on the light canvas is ~1.6:1, well under both the 3:1 non-text and 4.5:1 text WCAG floors. Rather than add a new field to `GWColors` (out of this plan's `files_modified: [lib/components/qr/crypto_address_qr.dart]` boundary), a local `warningColor` mirrors the exact pattern `GWColors.light()`/`.dark()` already use for `statusSuccess`/`statusError`: a darkened amber (`#92400E`, ~7.1:1 on white) for light mode, the vivid token for dark mode. Scoped entirely inside this file with an inline comment explaining the rationale and the upgrade path (promote to `GWColors` if a second consumer appears).
3. **`StatelessWidget` → `StatefulWidget`.** Needed local state (`_copied`) to drive the inline copy-icon feedback per the sketch's "welded" copy affordance, replacing the full-width `CopyButton` that no longer fits the design. The copy-to-clipboard mechanism itself (`Clipboard.setData` + 2s auto-reset) is unchanged from `CopyButton`'s implementation.

## Deviations from Plan

None — plan executed exactly as written. The single judgment call (local warning-color scoping, decision 2 above) was explicitly anticipated by the plan's own instruction ("Use a status/warning token; do NOT use raw Colors.amber") and resolved within the plan's file-scope constraint rather than expanding scope into `gw_colors.dart`.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Verification

- **Grep gate (plan's `<verify>`):** PASS — `QrImageView(` present, `size:` present, `backgroundColor: Colors.white` present, `Your $network Address` heading absent.
- **`flutter analyze lib`:** 59 issues total (down from the 61-issue baseline recorded in 07-01-SUMMARY.md — no regression). Zero of the 59 issues are in `crypto_address_qr.dart` (grep of the analyzer output for the filename returned nothing).
- **`bash tool/verify_additive_boundary.sh`:** FAILS on Check 2 (duplicate public class name census: `_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`, `_TimeframeTabState`) both BEFORE and AFTER this plan's change — confirmed via `git stash` isolating the single modified file and re-running the script, which reproduced the identical failure list with the change reverted. Pre-existing, not introduced or worsened by this plan.
- **Not asserted here (07-08's human re-walk, per this plan's own verification section):** the visual ~60% size reduction and phone-camera QR scan in dark mode over the redesigned contained tile.

## Next Phase Readiness
- `crypto_address_qr.dart` matches sketch 034-A2's structure (chip-above, contained QR, chunked copy-only address, bordered amber note); no caller changes were needed (`token_info_screen.dart`, `coins_screen.dart`, `wallet_information.g.dart`, `design_gallery_screen.dart` all remain untouched, matching the plan's self-containment requirement).
- Ready for 07-08's human re-walk to confirm the QR reads as visibly smaller and still decodes on a real phone camera in dark mode.

## Self-Check: PASSED
- lib/components/qr/crypto_address_qr.dart — FOUND
- commit e245167 — FOUND

---
*Phase: 07-token-screens*
*Completed: 2026-07-24*
