---
phase: 9
slug: banxa
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-27
---

# Phase 9 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

**Shape of this phase, and why it drives everything below:** Phase 9 is a **re-skin only**
(09-CONTEXT.md D-01/D-02/D-03). No behaviour changes, and **no authorised end-to-end walk** (D-03).
Research found **zero existing test coverage for any Banxa surface** — `test/banxa/` does not exist.
That combination means validation cannot lean on behaviour assertions or on a human walk, so it
leans on what a re-skin can actually pin: **that the pre-redesign literals are gone, that the
shipped tokens are used, and that each surface still builds and renders its states.**

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (ships with Flutter 3.41.9) |
| **Config file** | none needed — `test/` is the convention; `test/banxa/` must be created (Wave 0) |
| **Quick run command** | `flutter test test/banxa/` |
| **Full suite command** | `flutter test` |
| **Static gate** | `flutter analyze lib` — **baseline 59 issues, must not regress** |
| **Estimated runtime** | ~15s for the full suite; ~2s for `test/banxa/` |

Flutter binary on this host: `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat`

**Known pre-existing failure, NOT this phase's:** `test/local_wallet_storage_test.dart` fails with
"Missing definition of `main` method". The suite is 376 pass / 1 fail before this phase starts.
Any executor reporting "1 failure" must confirm it is *that* one.

---

## Sampling Rate

- **After every task commit:** `flutter analyze lib` (~3s) — the fastest signal that a re-skin
  edit compiles and introduced no new lint.
- **After every plan wave:** `flutter test` (~15s) + `flutter analyze lib`
- **Before `/gsd-verify-work`:** full suite green (except the known failure above), analyze ≤ 59
- **Max feedback latency:** ~15 seconds

---

## What a re-skin can and cannot pin

This is the crux of the phase's validation design, so it is stated before the task map.

**Automatable (the phase's real gate):**
- **Negative literal checks** — the pre-redesign colours (`GeniusWalletColors.deepBlue*`, raw
  `Colors.green` / `Colors.orange` / `Colors.red` / `Colors.grey`) are ABSENT from each re-skinned
  file. This is the single most valuable assertion available, because it is exactly what the
  re-skin does, and it is trivially checkable.
- **Widget-tree assertions** — each surface pumps and renders without exception; `GWCard`,
  `GWButton`, `GWPageHeader`, `GWEmptyState` / `GWErrorState` appear where the UI-SPEC contracts
  them.
- **State rendering** — the Orders History empty and error states (both NEW per the UI-SPEC) render
  their contracted copy.
- **The status ladder** — `order_details_card.dart` gains an error/declined branch it does not have
  today (currently a 2-way `Colors.green : Colors.orange` ternary). Each of the four buckets is
  assertable from a synthesized order.
- **Live appearance reads** — a widget that bakes colours does not re-skin on an appearance toggle;
  pumping the same widget under `GWColors.dark()` and `GWColors.light()` and asserting the rendered
  colour differs catches the const-widget defect class directly.

**NOT automatable here, and why:**
- Anything requiring the **Banxa sandbox network**, KYC submission, a payment method or a live
  order — D-03 forbids the end-to-end walk, and these screens are webview- and deep-link-driven.
- **Visual fidelity** — whether the re-skin *looks* right is a walk judgement, and no walk is
  authorised. Recorded honestly rather than faked with golden tests that would only pin the
  implementation to itself.
- **Light mode** — deferred project-wide. Token choices must still be WCAG AA in both modes; that
  is enforced by *which tokens are used*, not by a rendered assertion.

---

## Per-Task Verification Map

Task IDs are provisional — the planner assigns final numbering. Requirement coverage is what
matters: **every task maps to SCR-05 or GAP-05.**

| Task ID | Plan | Wave | Requirement | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------------|-----------|-------------------|-------------|--------|
| 09-00-01 | 00 | 0 | SCR-05 | N/A | scaffold | `flutter test test/banxa/` | ❌ W0 | ⬜ pending |
| 09-xx-01 | — | 1+ | SCR-05 | N/A | widget | `flutter test test/banxa/banxa_buy_screen_test.dart` | ❌ W0 | ⬜ pending |
| 09-xx-02 | — | 1+ | SCR-05 | N/A | widget | `flutter test test/banxa/orders_history_states_test.dart` | ❌ W0 | ⬜ pending |
| 09-xx-03 | — | 1+ | SCR-05 | N/A | unit | `flutter test test/banxa/order_status_ladder_test.dart` | ❌ W0 | ⬜ pending |
| 09-xx-04 | — | 1+ | GAP-05 | N/A | widget | `flutter test test/banxa/checkout_qr_test.dart` | ❌ W0 | ⬜ pending |
| 09-xx-05 | — | 1+ | GAP-05 | N/A | grep-gate | `flutter analyze lib` + literal-absence assertions | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

`test/banxa/` does not exist. This is a **Wave 0 gap, not a Wave 2 backfill** — without it there is
no place to put a single assertion, and every later task would have no automated verify.

- [ ] `test/banxa/` directory created
- [ ] A shared pump helper mirroring the existing convention in
      `test/squid_router/route_details_card_test.dart` —
      `MaterialApp(theme: ThemeData(extensions: [gw ?? GWColors.dark()]), home: Scaffold(body: child))`
      — so both appearance modes can be pumped for the live-read assertions
- [ ] Synthesized Banxa order/quote fixtures, so nothing in `test/banxa/` needs the network
- [ ] No framework install needed — `flutter_test` already ships

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Visual fidelity of each re-skinned surface | SCR-05 | A re-skin's success is whether it *looks* right; no assertion captures that | Deferred — D-03 authorises no walk this phase. Record as OUTSTANDING at verification. |
| Buy flow end to end | SCR-05 (criterion 1) | Needs sandbox KYC, a payment method and a live order | **NOT AUTHORISED** this phase (D-03). Criterion 1 closes as PARTIAL. |
| Checkout QR scans in both appearances | GAP-05 (criterion 3, finding 6) | Needs a phone camera against a rendered QR | Deferred with light mode. |
| Linux KYC browser fallback | criterion 3 (finding 7) | No Linux host available | **UNVERIFIABLE** here; deferred with evidence, never claimed. |

---

## Validation Sign-Off

- [ ] Wave 0 creates `test/banxa/` before any task claims an automated verify
- [ ] Every task has an `<automated>` verify or an explicit Wave 0 dependency
- [ ] Sampling continuity: no 3 consecutive tasks without an automated verify
- [ ] No watch-mode flags (`--watch` is banned; it never exits)
- [ ] `flutter analyze lib` ≤ 59 at every wave boundary
- [ ] Feedback latency < 15s
- [ ] `nyquist_compliant: true` set in frontmatter once the planner's task map is filled in

**Approval:** pending — awaiting the planner's task IDs
