---
phase: 29
slug: fee-transparency
# status lifecycle: draft (seeded by plan-phase) → validated (set by validate-phase §6)
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-09-18
---

# Phase 29 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | `flutter_test` (bundled with the SDK; already used throughout `test/squid_router/` and `test/swap/`) |
| **Config file** | none — no `dart_test.yaml`; standard `flutter test` discovery |
| **Quick run command** | `flutter test test/squid_router/route_details_card_test.dart test/swap/squid_quote_mapping_test.dart` |
| **Full suite command** | `flutter test` |
| **Estimated runtime** | quick: **27s measured** 2026-09-18 (8 tests, all green) — nearly all of it `pub get` and SDK startup; the tests themselves run sub-second |

The SDK is **not on `PATH`** in this environment. It lives at
`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter` (note the doubled directory —
the outer `flutter/` is the thirdparty build tree, not the SDK).

---

## Sampling Rate

- **After every task commit:** the quick run command above
- **After every plan wave:** `flutter test`
- **Before `/gsd-verify-work`:** full suite green, plus `flutter analyze` (exits non-zero on infos
  by design — a gate, never evidence), `bash tool/check_brace_style.sh`, `bash tool/check_raw_colors.sh`
- **Max feedback latency:** ~30s

Both shell gates are relevant here and not boilerplate: this phase adds conditionals (brace rule)
and touches a themed widget (raw-colour rule).

---

## Per-Task Verification Map

Task IDs are assigned by the planner; this table is seeded at requirement level and is filled in
after `PLAN.md` exists. Every row below must end up owned by at least one task.

| # | Requirement | Behavior to prove | Test Type | Automated Command | File Exists |
|---|-------------|-------------------|-----------|-------------------|-------------|
| V-1 | FEE-02 · crit 1 | `crossChainRoute` renders a row labelled `"Gas receiver fee"` carrying its own `$0.48`, not merged into a total | widget | quick run | ✅ extend `route_details_card_test.dart` |
| V-2 | FEE-02 · crit 1 | A synthetic ≥2-entry `feeCosts[]` maps to 2 fee lines with distinct names, both surviving to distinct rendered text | unit + widget | quick run | ❌ Wave 0 — inline synthetic JSON |
| V-3 | FEE-02 · crit 2 | Fee rows and the gas row are separately findable — never one merged string. Gas carries no `name` from Squid (`type: "executeCall"` only), so its label is ours | widget | quick run | ✅ extend |
| V-4 | FEE-02 · crit 3 | `sameChainRoute` (zero fee entries) renders no fee row and no `$0.00` line — only gas at `$0.01` | widget | quick run | ✅ extend |
| V-5 | FEE-02 · crit 4 | No arithmetic against `toAmount` anywhere | static grep | `grep -rn 'toAmount -' lib/` (manual, not a test target) | ✅ existing mapping tests already pin `toAmountDisplay` |
| V-6 | FEE-02 · crit 5 | An uncommon `FeeType` name (e.g. `"Boost fee"`) renders through the same generic path — no hard-coded label | unit | quick run | ❌ Wave 0 — same synthetic body as V-2 |
| V-7 | FEE-02 · crit 2 | Rows read correctly in both appearances | widget | quick run | ⚠ see note |

**V-7 note:** `route_details_card_test.dart` currently pumps **only** `GWColors.dark()`
(`_host`, line 13-16). There is no light-mode pump anywhere in this file, so "readable in both
appearances" has no automated coverage today. Either the host helper gets parameterised over both
extensions, or criterion 2's both-appearance half is manual-only. The planner must pick one
explicitly — silently inheriting dark-only coverage is how the light-mode regressions in this repo
have historically shipped.

---

## Wave 0 Requirements

- [ ] An **inline synthetic** multi-entry `feeCosts[]` JSON body in a test file — ≥2 named entries
      plus one uncommon `FeeType` name. Covers V-2 and V-6.
      **Not** a new file under `test/squid_router/fixtures/`: every fixture there is a recorded real
      response, and no route we can actually fetch carries two fee entries today (no integrator fee
      is enabled on either ID). Recording a fabricated "fixture" would break exactly the honesty
      property this phase exists to establish.
- [ ] One assertion resolving the open question on `FeeType.<X>.name` — does the built_value enum
      accessor yield the wire string (`"Gas receiver fee"`) or the Dart constant name? Must be
      settled *before* the typed-path mapper is written against it. Fallback if it does not: read
      `fee['name']` on the raw-JSON path, which is unambiguous.

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Fee rows readable at phone width in the running app | FEE-02 · crit 2 | Layout overflow at narrow widths is not caught by a widget test at default surface size | Run the app, open `/swap`, select a cross-chain pair, inspect route details at a narrow window |
| Light-mode contrast of the new rows | FEE-02 · crit 2 | Only if V-7 is resolved as manual rather than parameterising the pump helper | Toggle appearance, confirm label/value/divider all meet AA |

---

## Validation Sign-Off

- [ ] All tasks have an `<automated>` verify or a Wave 0 dependency
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers both MISSING references above
- [ ] No watch-mode flags
- [ ] Feedback latency < 30s
- [ ] V-7 resolved explicitly (parameterised pump **or** recorded as manual)
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
