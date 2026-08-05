---
phase: quick-260721-ed9
verified: 2026-07-21T00:00:00Z
status: human_needed
score: 8/8 must-haves verified (code-level)
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "flutter run -d macos --dart-define=GW_DEV_TOOLS=true — inspect the top-bar right cluster in DARK mode"
    expected: "All five controls (chain chip, SDK chip, wallet chip, Connect, Buy GNUS) read as one 40px family with even space4(8) gaps; the three context chips are quiet (surfaceMenu fill, borderSubtle rest border) and show borderStrong on hover; Connect is the outlined secondary (brandPrimaryStrong border/label, legible); Buy GNUS is the only gradient; SDK-absent case leaves no visible hole in the row."
    why_human: "Visual appearance, hover-state rendering, and real layout/tap-target feel cannot be verified by static analysis or grep — must be seen in a running app."
  - test: "Same walk, LIGHT mode — toggle appearance and re-inspect the same cluster"
    expected: "Connect's outline/label use the darker appearance-aware brand (0xFF0B6E8F) and are clearly legible against light's pure-white surfaceElevated (not the raw ~2:1 brandPrimaryStrong); context chips' surfaceMenu/borderSubtle/borderStrong remain visually 'quiet' (not blown out) in light; Buy GNUS gradient still reads as the single primary CTA."
    why_human: "WCAG contrast passing a computed test does not guarantee the color reads correctly with real light-mode surfaces, shadows, and adjacent chrome — visual confirmation required per project's dark-mode-first/light-pass memory note."
  - test: "Exercise Connect's 5 states live (idle → connecting → connected → disconnect; force a timeout/error if possible) at both breakpoints (label visible / label hidden on narrow width)"
    expected: "All 5 states (Connect/Connecting/Timed Out/Retry Connect/Disconnect) still fire with correct status colors and the 40px shell holds at every state; SDK chip and wallet-address chip labels drop correctly below GeniusBreakpoints.small."
    why_human: "State-machine transitions triggered by live WalletKit events and responsive breakpoint behavior require a running app / real window resize, not static code inspection."
---

# Quick Task 260721-ed9: Re-skin top-bar right cluster per sketch 005 winner B — Verification Report

**Task Goal:** Re-skin the top-bar right cluster per approved sketch 005 winner B (Normalized quiet
chips) — all 5 controls one 40px family, quiet surfaceMenu chips + borderSubtle (hover
borderStrong), radiusMd, Connect outlined secondary (appearance-aware AA), Buy GNUS the ONLY
gradient, space4 row gap. Preserve dropdowns / SDK SizedBox.shrink() / Reown 5-state machine /
breakpoint label-drops. NO edits to theme.dart textButtonTheme. NO commits.

**Verified:** 2026-07-21
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | All five controls render at ONE explicit height: 40px | ✓ VERIFIED | `navChipShell` pins `minimumSize: Size(0,40)` + `maximumSize: Size(double.infinity,40)` + `tapTargetSize.shrinkWrap` + `VisualDensity.compact` (lib/theme/nav_chip_style.dart:17-30); test asserts `minSize?.height==40` and `maxSize?.height==40` and PASSES. `gw_button.dart` gained additive `height` field consumed at Buy GNUS call site with `height: 40` (responsive_overlay.dart:379). |
| 2 | Context chips 1-3 are quiet: surfaceMenu fill + borderSubtle, hover→borderStrong, radiusMd(12), padding space6(12), internal gap space4(8) | ✓ VERIFIED | `navContextChipStyle` sets `backgroundColor: WidgetStatePropertyAll(gw.surfaceMenu)`, `side: WidgetStateProperty.resolveWith(...)` returning `borderSubtle` at rest / `borderStrong` on hover (nav_chip_style.dart:37-51); test asserts both and PASSES. All 3 call sites (`network_dropdown_selector.dart:141`, `sdk_account_manager.dart:47`, `account_dropdown_selector.dart:428`) apply `navContextChipStyle(context)` and each internal `Row` uses `spacing: GeniusWalletConsts.space4`. |
| 3 | Connect is outlined secondary, 40px shell, WCAG AA in both modes | ✓ VERIFIED | `reown_connect_button.dart:551-563` reads `connectBrandColor(context)` for idle icon/text/border and applies `navChipShell(context).copyWith(backgroundColor:..., side:...)`. Test asserts `contrastRatio(0xFF0B6E8F, 0xFFFFFFFF) >= 4.5` and `contrastRatio(brandPrimaryStrong, 0xFF0C0E14) >= 4.5`, both PASS. Light color is `Color(0xFF0B6E8F)`, NOT raw `brandPrimary`/`brandPrimaryStrong`. |
| 4 | Buy GNUS is the ONLY gradient; height dropped 48→40 via LOCAL override; GWButtonSize.md stays 48 app-wide | ✓ VERIFIED | `gw_button.dart:39,73,77-87`: `height` field is optional (default `null`), `_height` returns `height ?? <size switch>`; `GWButtonSize.md` case still returns `48`. Buy GNUS call site (`responsive_overlay.dart:376-384`) passes `variant: GWButtonVariant.gradient, size: GWButtonSize.md, height: 40`. |
| 5 | Right Row has even gaps: spacing space4(8) | ✓ VERIFIED | `responsive_overlay.dart:372-373`: `Row(spacing: GeniusWalletConsts.space4, children: [..._buildActionRowWidgets(context), GWButton(...)])`. |
| 6 | SDKAccountManagerButton still returns SizedBox.shrink() when no SDK accounts | ✓ VERIFIED | `sdk_account_manager.dart:40-42`: `if (accounts.isEmpty) { return const SizedBox.shrink(); }` unchanged; parent `Row(spacing:)` naturally collapses the gap around a zero-size child. |
| 7 | ReownConnectButton keeps its 5-state machine and status colors | ✓ VERIFIED | `reown_connect_button.dart:517-558`: `isConnected` (Disconnect) / `_isConnecting` (Connecting) / `_timedOut` (Timed Out) / `_hasError` (Retry Connect) / else (Connect, idle) — all 5 branches present with unchanged status colors (`statusError`/`statusWarning`); only shell (`navChipShell(...).copyWith(...)`) changed. |
| 8 | theme.dart textButtonTheme is UNTOUCHED (the trap) | ✓ VERIFIED | `git diff lib/theme/theme.dart` shows a real diff (11 insertions/11 deletions) but `grep -i textButtonTheme` on that diff returns NO hits — the diff is entirely `brandPrimary`→`brandPrimaryStrong` swaps in unrelated theme sections (datePicker/tab/navigationRail/bottomNav), pre-existing uncommitted work from a different in-flight quick task, not this plan's edits. |

**Score:** 8/8 truths verified at code level (0 present-but-behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/theme/nav_chip_style.dart` | New shared ButtonStyle builder (navChipShell, navContextChipStyle, connectBrandColor) | ✓ VERIFIED | Exists, 63 lines, no stub patterns, all 3 functions present and used by 4 call sites. |
| `test/theme/nav_chip_style_test.dart` | Runnable check for height/radius/fill/hover/AA | ✓ VERIFIED | Exists, 3 tests, all pass (independently re-run, not just trusting SUMMARY). |

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|----|--------|---------|
| responsive_overlay.dart `_DesktopTopBar` right Row | GeniusWalletConsts.space4 | `spacing:` param | ✓ WIRED | Line 373. |
| network_dropdown_selector.dart / sdk_account_manager.dart / account_dropdown_selector.dart | nav_chip_style.dart | `style: navContextChipStyle(context)` | ✓ WIRED | All 3 TextButtons confirmed. |
| reown_connect_button.dart | nav_chip_style.dart | `navChipShell(context).copyWith(backgroundColor:, side:)` | ✓ WIRED | Line 561-564; per-state fill/border preserved. |
| gw_button.dart height param | responsive_overlay.dart Buy GNUS call site | `height: 40` | ✓ WIRED | Line 379; `GWButtonSize.md` unaffected elsewhere (grep confirms no other call site passes `height:`). |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Shared style test suite passes | `flutter test test/theme/nav_chip_style_test.dart` | `00:00 +3: All tests passed!` (independently re-run by verifier) | ✓ PASS |
| No compile/lint regressions on touched files | `flutter analyze` on all 7 touched/created files | 3 pre-existing `info`-level `use_build_context_synchronously` warnings (network_dropdown_selector.dart:76, reown_connect_button.dart:160,405) — confirmed unrelated to this diff's edited lines | ✓ PASS (no new issues) |
| Trap check: theme.dart textButtonTheme untouched | `git diff lib/theme/theme.dart \| grep -i textButtonTheme` | no output | ✓ PASS |
| Trap check: GWButtonSize.md still 48 | inspect `gw_button.dart` `_height` switch | `case GWButtonSize.md: return 48;` | ✓ PASS |
| No commits created | `git log --oneline -1` | `7a95e68` — same as pre-task HEAD | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|------------|-------------|--------|----------|
| SKETCH-005-B | 260721-ed9-PLAN.md | Normalized quiet chips per sketch 005 winner B | ✓ SATISFIED | All must_haves truths verified above. |

### Anti-Patterns Found

None. No TBD/FIXME/XXX/TODO/HACK/PLACEHOLDER markers in any of the 7 touched/created files. No stub `return null`/empty-body handlers introduced. `SizedBox.shrink()` in `sdk_account_manager.dart` is pre-existing intentional behavior (empty-state), not a stub of this task's work.

### Human Verification Required

The plan itself specifies a final visual walk (macOS, both light and dark themes) as the closing
verification step — this is legitimately human-verifiable only, not derivable from static analysis:

1. **Dark-mode visual walk** — run `flutter run -d macos --dart-define=GW_DEV_TOOLS=true`; confirm all
   five controls read as one 40px family, quiet chips with correct hover, Connect legible, Buy GNUS
   the only gradient, no gap-hole in the SDK-absent case.
2. **Light-mode visual walk** — toggle appearance; confirm Connect's appearance-aware brand color is
   legible against light's pure-white surfaceElevated and chips still read as "quiet" rather than
   blown out.
3. **Live state-machine + breakpoint check** — exercise Connect's 5 states and resize across
   `GeniusBreakpoints.small` to confirm label-drops still work with the new shell.

## Gaps Summary

No code-level gaps found. All 8 must-have truths, both required artifacts, and all 4 key links are
verified against the actual source (not SUMMARY claims) — the test suite was independently re-run
(3/3 pass), `flutter analyze` was independently re-run (clean except 3 pre-existing unrelated
warnings), and the two hard constraints (theme.dart textButtonTheme untouched, GWButtonSize.md still
48) were independently confirmed via `git diff` and source inspection. HEAD is unchanged at `7a95e68`
— no commit was created. The only remaining item is the visual walk, which this task's own
verification recipe correctly scopes to a human (macOS, both themes, live state machine).

---

_Verified: 2026-07-21_
_Verifier: Claude (gsd-verifier)_
