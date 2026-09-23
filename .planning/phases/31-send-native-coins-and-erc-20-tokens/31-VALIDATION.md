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
| **Framework** | `flutter_test` (app only). `packages/genius_api` declares no `test` dependency and imports Flutter, and CI runs only the root suite, so its send code is tested from the app's `test/send/` |
| **Config file** | none — `pubspec.yaml` only |
| **Quick run command** | `flutter test test/send/ test/tokens/coin_page_stat_rail_test.dart test/dashboard/` |
| **Full suite command** | `flutter test` (develop baseline 1590 pass / 5 skip on 2026-09-23) |
| **Estimated runtime** | ~35 seconds (full app suite) |

---

## Sampling Rate

- **After every task commit:** the quick-run command for the files touched
- **After every plan wave:** `flutter test`, plus `flutter analyze` at the root and in `packages/genius_api`
- **Before `/gsd-verify-work`:** full suite green, `flutter analyze` clean, all `tool/*.sh` gates pass
- **Max feedback latency:** 40 seconds

---

## Per-Task Verification Map

Filled by the planner per task. Requirement → test map from research:

| Requirement | Behaviour proven | Test type | Command | Exists |
|-------------|------------------|-----------|---------|--------|
| SEND-01 | Old 18-field rows still read; asset drives title/amount/icon; gas coin drives the fee row; chainId drives the explorer | unit + widget | `flutter test test/dashboard/transaction_asset_chain_test.dart test/reown/handle_dapp_requests_test.dart` (31-01) | ❌ W0 |
| SEND-02 | Native send: fee before confirm; legacy fallback; MAX = balance − max fee | unit + widget | `flutter test test/send/send_service_test.dart test/send/send_screen_test.dart test/send/send_cubit_test.dart` (31-02, 31-03) | ❌ W0 |
| SEND-03 | ERC-20 `transfer` decodes back to the form's recipient and amount | unit | `flutter test test/send/send_token_test.dart` (31-03) | ❌ W0 |
| SEND-04 | Poll resolves pending → completed/failed; exhaustion leaves pending; the cubit gets one row, not two | unit + widget | `flutter test test/send/send_service_test.dart test/send/send_screen_test.dart` (31-02) | ❌ W0 |
| SEND-05 | Validation, paste, self-send and contract warnings, QR absent on Windows/Linux, MAX | widget | `flutter test test/send/recipient_field_test.dart test/send/send_cubit_test.dart` (31-03, 31-04) | ❌ W0 |
| SEND-06 | `/send` seats the extra's coin; dashboard entry opens the picker | widget | `flutter test test/send/send_screen_test.dart test/dashboard/dashboard_send_entry_test.dart` (31-02, 31-05) | ❌ W0 |
| SEND-07 | Review shows the built values via `SendTransactionDetails`; pending then resolved row; coin-page test asserts the CTA | widget | `flutter test test/send/send_screen_test.dart test/tokens/coin_page_stat_rail_test.dart` (31-02, 31-05) | ✅ edit |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `test/send/` — new app-level directory, created by 31-02's tracer; it also covers the genius_api send code
- [ ] `test/dashboard/transaction_asset_chain_test.dart` — created by 31-01's tracer

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
