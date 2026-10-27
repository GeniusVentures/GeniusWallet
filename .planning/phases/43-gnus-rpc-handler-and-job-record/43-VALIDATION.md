---
phase: 43
slug: gnus-rpc-handler-and-job-record
# status lifecycle: draft (seeded by plan-phase) -> validated (set by validate-phase)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-10-27
---

# Phase 43 - Validation Strategy

> Per-phase validation contract for feedback sampling during execution. Source: 43-RESEARCH.md "Validation Architecture".

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (Flutter 3.41.9 / Dart 3.11.5), plain `test()` only in this phase, hand-written fakes (`implements GeniusApi` + forwarding `noSuchMethod`), no mocktail |
| **Shared fakes** | `test/gnus_bridge/gnus_fakes.dart` (no `_test` suffix, never run on its own): `FakeGnusApi`, `SeededGnusCubit`, `PushableWalletDetails`, `GnusHarness`, and the two fake transports `viaDirect` and `viaJson` |
| **Hive in tests** | in-memory `Box<String>` via `bytes: Uint8List(0)` (close in tearDown); the restart tests use a real temp dir with `Hive.init`, `Hive.close`, re-init, reopen. Never `testWidgets`: real Hive I/O hangs in the fake-async zone |
| **Config file** | none beyond `pubspec.yaml`; analyzer rules in `analysis_options.yaml` |
| **Setup** | Flutter is not on PATH: `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` in every shell call |
| **Quick run command** | `flutter test --no-pub test/gnus_bridge` |
| **Focused regression set** | `flutter test --no-pub test/submit_job test/dev/dev_mock_job_test.dart test/dashboard/compute_panel_wiring_test.dart test/dashboard/bridge` |
| **Full suite command** | `flutter test --no-pub --reporter failures-only` (capture `$?` before any pipe; run in the background if it outlasts the tool timeout) |
| **Static gates** | `dart format --output=none --set-exit-if-changed lib/gnus_bridge lib/submit_job lib/hive lib/main.dart test/gnus_bridge test/submit_job`; `flutter analyze --no-pub lib test` (exit 0; exits 1 on infos); `bash tool/check_brace_style.sh`; new files LF |
| **Estimated runtime** | quick run under 30 s; full suite measured in 43-01 Task 0 |

Baseline: not quoted from memory. 43-01 Task 0 measures analyze, the brace check, the full suite and the focused set at the current HEAD and writes them to `43-01-SUMMARY.md` under `## Baseline`. The last recorded figure (2693 passed / 6 skipped / 0 failed after the Phase 42 review fixes) is a hint, not a baseline.

---

## Sampling Rate

- **After every task commit:** the quick run, plus format on the changed paths, the brace check and `flutter analyze --no-pub lib test`.
- **At the end of every plan (sequential waves 1-5):** the full suite, compared with the 43-01 baseline (0 failed; pass count = previous end count + the plan's new tests).
- **Before `/gsd-verify-work`:** 43-05 Task 2's phase gate.
- **Max feedback latency:** about 30 s for the quick run.

---

## Phase Requirements -> Test Map

| Req / criterion | Behavior | Test type | Automated command | File exists? |
|-----------------|----------|-----------|-------------------|--------------|
| SC1 / RPC-01 | Every method through both fake transports gives deep-equal replies: 4200 unknown and retired, -32602 bad params, 4900 not initialized, -32015 during a switch (getAccounts `switching: true`), -32010 for a zero or failed cost, no reply with cost "0" | unit (table) | `flutter test --no-pub test/gnus_bridge/gnus_rpc_contract_test.dart` | W0: 43-05 Task 2 (first two-transport cases in 43-01 Task 1) |
| SC2 / RPC-02 | getAccounts shape; lowercase 0x+128 SDK and 0x+40 EVM; role main/child/none; canSign false for tracking, sgnus and child | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_reads_test.dart` | W0: 43-04 Task 1 |
| SC2 / RPC-03 | accountsChanged on wallet, SDK account, link, role and switching changes; networkChanged on chain change; none on a processing tick or a repeat | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_events_test.dart` | W0: 43-04 Task 2 |
| SC3 / RPC-04 | estimate returns cost, gas `{gasPriceGwei, symbol}` or null, balance or null, network; -32010 on a failed cost; no gate | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_estimate_test.dart` | W0: 43-03 Task 2 |
| SC3 / RPC-05 | submit through the owner; confirm args; default confirm 4001 with no burn; gate table; -32011 with the panel's rounding; -32013 no record; bridgedNotProcessed recorded; post-confirm recheck | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_submit_test.dart` | W0: 43-01 Task 1, extended in 43-02 and 43-03 |
| SC3 / RPC-06 | same key and body replays with one burn; different body -32602 `idempotency_key_reused`; after 24 h runs again; in-flight -32005 from either origin and for the in-flight key | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_submit_test.dart` | W0: 43-02 Task 2 |
| SC4 / RPC-07 | listJobs newest first, scoped, stable cursor, limit bounds; getJob by each selector, `result: null`, null when absent | unit | `flutter test --no-pub test/gnus_bridge/gnus_job_store_test.dart test/gnus_bridge/gnus_rpc_jobs_test.dart` | W0: 43-02 Tasks 1-2 |
| SC4 / RPC-07 | record survives Hive close and reopen, at store level and handler level, and still satisfies idempotency | unit, real disk | `flutter test --no-pub test/gnus_bridge/gnus_job_store_restart_test.dart` | W0: 43-02 Tasks 1-2 |
| SC4 (crash safety) | `onBurned` fires after the burn and before Process, never on a failed burn; the record exists when Process is called | unit | `flutter test --no-pub test/submit_job/job_submission_test.dart test/gnus_bridge/gnus_rpc_submit_test.dart` | W0: 43-01 Task 2 |
| SC5 / RPC-08 | getEarnings balance in base units, isProcessing from AppState, nulls asserted `isNull`, includeChildren accepted | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_reads_test.dart` | W0: 43-04 Task 1 |
| RPC-09 | -32015 for five methods during a switch; 4900 for all six when not initialized or with no selected account | unit | `flutter test --no-pub test/gnus_bridge/gnus_rpc_reads_test.dart test/gnus_bridge/gnus_rpc_contract_test.dart` | W0: 43-04 Task 1, 43-05 Task 2 |
| Units (D-13 corrected) | cost, payer and node balances in base units of 18, exact strings, no double drift added | unit | `flutter test --no-pub test/gnus_bridge/gnus_amounts_test.dart` | W0: 43-03 Task 1 |
| D-08 wiring | `main.dart` builds the handler with no confirm argument; `initHive` opens `gnusJobs` as `Box<String>` | source guard | `flutter test --no-pub test/gnus_bridge/gnus_rpc_guards_test.dart` | W0: 43-05 Task 1 |
| D-14 | log lines carry only method (or `unsupported`), origin and code; sentinel job, key, cursor and method values never appear | unit (debugPrint capture) | `flutter test --no-pub test/gnus_bridge/gnus_rpc_guards_test.dart` | W0: 43-05 Task 1 |
| One owner | `lib/gnus_bridge/` never calls the burn, gas, cost or process methods; only the store names Hive; no widget imports | source guard | `flutter test --no-pub test/gnus_bridge/gnus_rpc_guards_test.dart` | W0: 43-05 Task 1 |
| Owner unchanged for the panel | panel test files and the cubit show no diff; focused set green | regression | `git diff --exit-code c3fb0a76 -- test/submit_job/job_flow_test.dart test/submit_job/submit_job_errors_test.dart test/submit_job/submit_job_outcome_test.dart test/submit_job/submit_job_cta_state_test.dart test/submit_job/job_off_ui_isolate_test.dart lib/submit_job/cubit/submit_job_cubit.dart` and the focused regression set | yes |

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Threat Ref | Secure Behavior | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|------------|-----------------|-----------|-------------------|-------------|--------|
| 43-01-00 | 01 | 1 | prerequisite | - | N/A (baseline) | env check + focused run | `test -f .dart_tool/package_config.json`, then the focused regression set | yes | pending |
| 43-01-01 | 01 | 1 | RPC-01, RPC-05, RPC-09 | T-43-01, T-43-02, T-43-03, T-43-05, T-43-06, T-43-07 | default confirm rejects with no burn; every non-enabled gate refuses before pricing; fixed internal error; size caps; record without secrets | unit (two transports) | format, brace, analyze, `flutter test --no-pub test/gnus_bridge` | W0 (`gnus_fakes.dart`, `gnus_rpc_submit_test.dart` created) | pending |
| 43-01-02 | 01 | 1 | RPC-05, RPC-07 | T-43-04 | record written before Process; a throwing callback cannot skip Process | unit | panel diff check, format, brace, analyze, gnus_bridge + focused set, full suite | yes (extends `job_submission_test.dart`) | pending |
| 43-02-01 | 02 | 2 | RPC-07 | T-43-12 | corrupt values skipped; box opened at startup | unit + real disk | `grep -q "openBox<String>(gnusJobsBoxName)" lib/hive/init.dart`, format, brace, analyze, `flutter test --no-pub test/gnus_bridge test/hive` | W0 (`gnus_job_store_test.dart`, `gnus_job_store_restart_test.dart`) | pending |
| 43-02-02 | 02 | 2 | RPC-06, RPC-07 | T-43-08, T-43-09, T-43-10, T-43-11, T-43-13 | replay without second burn; lock set before the first await and released in finally; origin- and node-scoped lookups | unit + real disk | format, brace, analyze, `flutter test --no-pub test/gnus_bridge test/submit_job`, full suite | W0 (`gnus_rpc_jobs_test.dart`) | pending |
| 43-03-01 | 03 | 3 | RPC-04 | T-43-14 | exact base-unit strings, null on bad input | unit | format, brace, analyze, `flutter test --no-pub test/gnus_bridge/gnus_amounts_test.dart` | W0 (`gnus_amounts_test.dart`) | pending |
| 43-03-02 | 03 | 3 | RPC-04, RPC-05 | T-43-15, T-43-16, T-43-17, T-43-18 | post-confirm recheck; affordability via the panel rule; unreadable balance fails closed in submit; no cost "0" | unit | format, brace, analyze, `flutter test --no-pub test/gnus_bridge test/submit_job`, full suite | W0 (`gnus_rpc_estimate_test.dart`) | pending |
| 43-04-01 | 04 | 4 | RPC-02, RPC-08, RPC-09 | T-43-19, T-43-20, T-43-22 | address-only payloads; -32015 during a switch; nulls never 0 | unit | format, brace, analyze, `flutter test --no-pub test/gnus_bridge` | W0 (`gnus_rpc_reads_test.dart`) | pending |
| 43-04-02 | 04 | 4 | RPC-03 | T-43-21 | cheap-key gate, dedupe, serial recompute | unit | format, brace, analyze, `flutter test --no-pub test/gnus_bridge test/submit_job`, full suite | W0 (`gnus_rpc_events_test.dart`) | pending |
| 43-05-01 | 05 | 5 | RPC-01 | T-43-23, T-43-24, T-43-25 | no permissive confirm in wiring; no content in logs; no owner bypass | source guard + unit | `grep -q "RepositoryProvider<GnusRpcHandler>" lib/main.dart`, format, brace, analyze, `flutter test --no-pub test/gnus_bridge` | W0 (`gnus_rpc_guards_test.dart`) | pending |
| 43-05-02 | 05 | 5 | RPC-01, RPC-04, RPC-09 | T-43-26 | identical replies on both transports for every method | unit (table) | `grep -q "account_changed" .planning/research/v4.0-gnus-rpc-contract.md`, phase gate, full suite | W0 (`gnus_rpc_contract_test.dart`) | pending |

---

## Wave 0 Requirements

- [ ] Baseline measured at the current HEAD (43-01 Task 0).
- [ ] `test/gnus_bridge/gnus_fakes.dart`: shared fakes and the two transports (43-01 Task 1; extended in 43-02 to 43-04).
- [ ] `test/gnus_bridge/gnus_rpc_submit_test.dart` (43-01), `gnus_job_store_test.dart`, `gnus_job_store_restart_test.dart`, `gnus_rpc_jobs_test.dart` (43-02), `gnus_amounts_test.dart`, `gnus_rpc_estimate_test.dart` (43-03), `gnus_rpc_reads_test.dart`, `gnus_rpc_events_test.dart` (43-04), `gnus_rpc_guards_test.dart`, `gnus_rpc_contract_test.dart` (43-05).
- [ ] New `onBurned` cases in `test/submit_job/job_submission_test.dart` (43-01 Task 2); no other existing test file changes.
- [ ] No framework install.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| A live estimate and submit against the real SDK | RPC-04, RPC-05 | SDK-CA: the live price request fails, so every live estimate is -32010 and a live submit stops before burning; `flutter test` cannot load the native SDK | Phase 48 walk once SDK-CA lands; until then the priced path is proven with fakes and dev-mock scenarios. Record as a blocked gap, not a pass |
| `isProcessing` while the processing feed has never ticked or is unavailable | RPC-08 | reports false, indistinguishable from idle (research Open Question 5) | Phase 48 walk: compare getEarnings with the node status on a node that is processing |
| A window close during the burn itself | RPC-07 | the `onBurned` write covers a kill after the burn returns, not one inside `bridgeOut`; Phase 42's `ponytail:` names it | none in this phase; listed in 43-05-SUMMARY known limits |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency under 30 s for the quick run
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
