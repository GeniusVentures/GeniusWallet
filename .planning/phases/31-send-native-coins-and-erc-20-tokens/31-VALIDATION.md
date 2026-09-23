---
phase: 31
slug: send-native-coins-and-erc-20-tokens
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-23
---

# Phase 31 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (app) + Dart `test` ^1.24.1 (declared in `packages/genius_api`, no `test/` dir yet) |
| **Config file** | none — `pubspec.yaml` only |
| **Quick run command** | `flutter test test/send/ test/tokens/coin_page_stat_rail_test.dart` · `dart test` inside `packages/genius_api/` |
| **Full suite command** | `flutter test` (develop baseline 1590 pass / 5 skip on 2026-09-23) |
| **Estimated runtime** | ~35 seconds (full app suite) |

---

## Sampling Rate

- **After every task commit:** the quick-run command for the files touched
- **After every plan wave:** `flutter test` + `dart test` in `packages/genius_api`
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze` clean, all `tool/*.sh` gates pass
- **Max feedback latency:** 40 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Requirement → test map from research:

| Requirement | Behaviour proven | Test type | Command | Exists |
|-------------|------------------|-----------|---------|--------|
| SEND-01 | Old 18-field `Transaction` rows still read; asset field drives amount/title/icon; `coinSymbol` still drives network, fee and explorer | unit | `dart test` (genius_api) + `flutter test test/dashboard/` | ❌ W0 |
| SEND-02 | Native send: fee estimate before confirm; MAX = balance − max fee; legacy fallback when EIP-1559 throws | unit | `dart test test/send_service_test.dart` (genius_api) | ❌ W0 |
| SEND-03 | ERC-20 `transfer` calldata decodes back to the form's recipient and amount | unit | app-level test (the decoder lives in `lib/reown/`, not importable from genius_api) | ❌ W0 |
| SEND-04 | Poll resolves pending → completed/failed; exhausted poll leaves the row pending without throwing; the cubit gets one row, not two | unit | `dart test` (genius_api) + app cubit test | ❌ W0 |
| SEND-05 | Address validation, self-send and contract warnings, QR button absent on Windows/Linux | widget | `flutter test test/send/` | ❌ W0 |
| SEND-06 | `/send` reads `extra` symbol/chainId; dashboard entry opens a coin picker | widget | `flutter test test/send/` | ❌ W0 |
| SEND-07 | Confirm shows the built values via `SendTransactionDetails`; pending row then resolved outcome; coin-page test asserts the Send CTA | widget | `flutter test test/tokens/coin_page_stat_rail_test.dart` | ✅ edit |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `packages/genius_api/test/` — the package has no test directory; the first plan that adds package code creates it
- [ ] `test/send/` — new app-level directory for the form, route and confirm tests

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| A real native send and a real ERC-20 send land on-chain | SEND-02..04, SEND-07 | Needs a funded testnet wallet and a live RPC | On Polygon Amoy (80002) or Ethereum Sepolia (11155111) — NOT "Base - Sepolia", whose `networks.json` chainId 84531 is the retired Base Goerli id (Base Sepolia is 84532). Send a small native amount and a small ERC-20 amount; check the fee shown vs charged, the self-send and contract warnings against two prepared addresses, pending → completed with no duplicate row, and the explorer link. Record both hashes and the wallet address. |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 40s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
