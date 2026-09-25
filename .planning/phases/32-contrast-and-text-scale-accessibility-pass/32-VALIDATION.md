---
phase: 32
slug: contrast-and-text-scale-accessibility-pass
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-25
---

# Phase 32 — Validation Strategy

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (pinned Flutter 3.41.9) |
| **Config file** | none |
| **Quick run command** | `flutter test test/theme/ test/components/mobile_nav_destinations_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | ~30 s quick, several minutes full |

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite
- **Before `/gsd-verify-work`:** full suite green + `flutter analyze` exit 0 + visual walk in both modes
- **Max feedback latency:** 60 seconds

## Per-Task Verification Map

Filled by the planner per task; one row per goal minimum:

| Goal | Behavior | Test Type | Automated Command | File Exists |
|------|----------|-----------|-------------------|-------------|
| 1 | Enabled switch outline ≥3:1 vs ON and OFF track, both modes | unit (contrast math) | `flutter test test/theme/enabled_control_contrast_test.dart` | ❌ W0 |
| 2 | No un-allowlisted Text/Icon reads raw statusSuccess/statusError | unit (source scan) | `flutter test test/theme/` | ❌ W0 |
| 3 | Bar never overflows above the clamp; scales below it | widget | `flutter test test/components/mobile_nav_destinations_test.dart` | ✅ extend |
| 4 | ActionChip / newly mapped slots resolve Inter | widget | `flutter test test/theme/` | ❌ W0 |

## Wave 0 Requirements

- [ ] Enabled-control contrast test (goal 1)
- [ ] Status-text source-scan test, pattern of `test/components/drawer_padding_invariant_test.dart` (goal 2)
- [ ] ActionChip font-family widget test (goal 4)

## Manual-Only Verifications

| Behavior | Why Manual | Test Instructions |
|----------|------------|-------------------|
| Switch outline, swapped text colours, bar at large text, recovery-phrase chips look right | Visual judgement in both modes | Run the app, toggle Light/Dark in /settings, raise OS text size past 1.23x |

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] No 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
