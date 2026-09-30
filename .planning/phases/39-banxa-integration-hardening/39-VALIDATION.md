---
phase: 39
slug: banxa-integration-hardening
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-30
---

# Phase 39 — Validation Strategy

> Per-phase validation contract. Source: `39-RESEARCH.md` "Validation Architecture".

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | flutter_test (widget + unit), bloc_test where cubits change |
| **Config file** | none; `analysis_options.yaml` for analyze |
| **Quick run command** | `flutter test test/banxa test/transactions` |
| **Full suite command** | `flutter analyze && flutter test` (Flutter SDK at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |
| **Estimated runtime** | ~60 seconds full suite |

## Sampling Rate

- **After every task commit:** quick run command
- **After every plan wave:** full suite command plus `bash tool/check_brace_style.sh` and `bash tool/check_no_new_key_logging.sh --scan-tree`
- **Before `/gsd-verify-work`:** full suite green
- **Max feedback latency:** 60 seconds

## Per-Task Verification Map

Filled by the planner per task (`<automated>` verify on every task). Automated tests run against a fake `BanxaApiService`; no test depends on a `--dart-define`.

## Wave 0 Requirements

- [ ] `git submodule update --init` and `flutter pub get` in the worktree
- [ ] Fake Banxa API used by all Banxa tests (constructor-injected)
- [ ] Banxa order status enum with a table test covering all eleven wire statuses

## Manual-Only Verifications

| Behavior | Why Manual | Test Instructions |
|----------|------------|-------------------|
| A full sandbox buy completes and lands as `complete` in Transactions | Needs the Banxa sandbox key and hosted checkout | Sandbox build, test card 4111 1111 1111 1111, OTP 7203; watch the order reach Done under Buy orders |
| Full-screen checkout per platform (Android, iOS, macOS, Windows) | Platform webviews and camera prompts | Open checkout, complete ID step, close early, confirm return and status |
| GNUS listed on Banxa | Banxa-side action | Re-query `/v2/crypto/buy` for partner `gnus` |

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] No 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all missing references
- [ ] No watch-mode flags
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
