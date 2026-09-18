---
phase: 29-fee-transparency
verified: 2026-09-18T00:00:00Z
status: human_needed
score: 10/10 must-haves verified
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Open /swap, select a cross-chain pair (e.g. Base ETH -> Ethereum USDC), open route details, and inspect the fee/gas rows at phone width (narrow window)."
    expected: "The route-fee row (e.g. \"Gas receiver fee\" / \"$0.48\") and the \"Network gas\" row both render without text overflow or clipping at the default mobile widths this app ships to."
    why_human: "Widget tests in this phase run at the default `flutter_test` surface size; narrow-width layout overflow is not caught there. Flagged explicitly in 29-VALIDATION.md's Manual-Only table and in 29-04-SUMMARY.md as carried to UAT by design -- not a gap, but not yet exercised in the running app either."
---

# Phase 29: Fee Transparency Verification Report

**Phase Goal:** Route details name every fee the route charges and keep them separate from chain gas, so the user sees what they are paying before confirming — nothing merged, nothing silently deducted.
**Verified:** 2026-09-18
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Every entry in the live route's `estimate.feeCosts[]` renders as its own named line with its own amount — no collapsing (ROADMAP crit 1) | VERIFIED | `route_details_card.dart:63-69` iterates `quote.feeLines` with one `_DetailRow` per entry, no summing. `route_details_card_test.dart`: "a second real quote renders itemized fee and gas" and "three fee entries each render as their own row" both pass (run directly: 7/7 green). |
| 2 | Route fees and chain gas are visibly distinct, readable in both appearances (ROADMAP crit 2) | VERIFIED (distinctness) / see human item (phone-width) | "the route fee and the gas cost stay separately findable, never merged" asserts no single rendered `Text` contains both `0.48` and `0.02`. "fee and gas rows stay legible in both appearances" flips the real `GWAppearance` global (not just the colour constructor — confirmed `_surfaceElevated` is a getter gated on `GWAppearance.isLight`, `lib/theme/genius_wallet_colors.dart:131`), asserts the flip took via `surfaceElevated.computeLuminance() > 0.5` in light, then asserts both rows render and clear 4.5:1 contrast in both modes. All 3 tests pass. Phone-width overflow is unexercised — see human verification. |
| 3 | A route with no fee costs renders no placeholder and no `$0.00` line — the normal same-chain case (ROADMAP crit 3) | VERIFIED | "a same-chain route renders no fee row -- the normal case" asserts `find.textContaining('fee')` and `find.text('\$0.00')` both `findsNothing`, checked on the word rather than one label. Passes. |
| 4 | Nothing subtracts a fee from `toAmount` anywhere (ROADMAP crit 4) | VERIFIED | `grep -rn 'toAmount -' lib/` returns nothing. Broader indirect-arithmetic sweep (`grep -rn "toAmount" lib/` minus display/field declarations) found no arithmetic against the receive amount anywhere in `lib/squid_router/` or `lib/swap/` — `toAmount` is only parsed, displayed, or passed through. `totalCostUsd = feesUsd + gasUsd` still exists on `SwapQuote` but is no longer read by any rendering code (`grep -rn 'totalCostUsd' lib/` → declaration only). |
| 5 | No hard-coded fee label, no hard-coded percentage; names matched case-insensitively and rendered as given (ROADMAP crit 5) | VERIFIED | `grep -rniE 'integrator fee|service fee|toLowerCase.*fee'  lib/` returns nothing — there is no name-comparison logic anywhere, which trivially satisfies "no hard-coded label": every fee name is rendered verbatim off the wire (`_DetailRow(label: fee.name, ...)`), including names the wire enum doesn't list (`squid_quote_mapping_test.dart#a fee name the wire schema does not list still renders verbatim`, passes). |
| 6 | The fee-name accessor question is settled by a running assertion, not inference (D-03, plan 01) | VERIFIED | `route_wrap_drift_test.dart#the generated fee enum hides the wire name behind its serializer`: asserts `.name` yields `'GAS_RECEIVER_FEE'` and the serializer yields `'Gas receiver fee'`. Passes; `_feeLines` in `squid_swap_provider.dart:281-288` uses the serializer, never the bare accessor. |
| 7 | The two adapter paths (typed vs raw) cannot silently disagree on a fee's name or amount | VERIFIED | `route_wrap_drift_test.dart#the raw mapper agrees with the generated one where both can read` compares projected `feeLines` names and amounts for both real fixtures. Passes. |
| 8 | Two or more fee entries map to distinct named lines, an unrecognised name survives verbatim | VERIFIED | `squid_quote_mapping_test.dart#three fee entries map to three lines, in order` and `#a fee name the wire schema does not list still renders verbatim` both pass, using `syntheticRouteWithFees` (no fabricated fixture file — `ls test/squid_router/fixtures/ \| wc -l` = 4, unchanged). |
| 9 | A malformed cost entry degrades to nothing, never a crash mid-swap (T-29-01) | VERIFIED | Three cases pass: non-list `feeCosts` → empty `feeLines`; non-map element → skipped; unreadable amount string → named line at `0.0`. |
| 10 | FEE-02 checked off and traced complete | VERIFIED | `.planning/REQUIREMENTS.md:204` shows `[x] FEE-02`; traceability table row `FEE-02 \| Phase 29 — Fee transparency \| Complete`. |

**Score:** 10/10 truths verified (0 present-but-behavior-unverified)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/swap/swap_quote.dart` | `FeeLine` class + `SwapQuote.feeLines` | VERIFIED | Plain `const` class, two required fields (`name`, `amountUsd`); `feeLines` defaults to `const []`, additive per D-03. |
| `lib/squid_router/squid_swap_provider.dart` | Shared converter reachable from both call sites | VERIFIED | `_feeLine`/`_feeLines`/`_feeLinesRaw` present; both `SwapQuote(` construction sites (typed ~line 189, raw ~line 249) fill `feeLines:`. |
| `lib/squid_router/route_details_card.dart` | Generic per-fee rows + separate gas row, no name comparisons | VERIFIED | `_DetailRow` is a private `StatelessWidget` (not a `_build*` helper — `grep -cE 'Widget +_[a-z]'` on non-comment lines returns 0), replaces the old merged `Fees` row. Iteration is a plain `for` loop over `quote.feeLines`, no literal comparison. |
| `test/squid_router/route_wrap_drift_test.dart` | Serializer proof + typed/raw parity extended to fee lines | VERIFIED | 7/7 tests pass (run directly). |
| `test/swap/squid_quote_mapping_test.dart` | Multi-entry, unrecognised-name, malformed-input coverage | VERIFIED | 10/10 tests pass (run directly). |
| `test/squid_router/route_details_card_test.dart` | Empty case, distinctness, multi-fee render, both-appearance render | VERIFIED | 7/7 tests pass (run directly). |
| `test/squid_router/route_fixture.dart` | `syntheticRouteWithFees` helper | VERIFIED | Present, returns smallest raw-mapper-acceptable body; no fixture file added. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `squidQuote` (typed) | `SwapQuote.feeLines` | `_feeLines(estimate.feeCosts)` using `standardSerializers.serializeWith(FeeType.serializer, ...)` | WIRED | Confirmed at `squid_swap_provider.dart:189`, `:281-288`. Never the bare `.name` accessor. |
| `squidQuoteFromJson` (raw) | `SwapQuote.feeLines` | `_feeLinesRaw(estimate['feeCosts'])` reading `name`/`amountUsd` keys | WIRED | Confirmed at `squid_swap_provider.dart:249`, `:293-303`. |
| `SwapQuote.feeLines` | `RouteDetailsCard` rows | `for (final fee in quote.feeLines) _DetailRow(...)` | WIRED | Confirmed at `route_details_card.dart:63-69`. No intermediate transform, no comparison. |
| Both adapter paths | Each other | Parity assertions comparing projected name/amount lists | WIRED | `route_wrap_drift_test.dart`'s parity case, extended in plan 03, passes for both real fixtures. |

### Data-Flow Trace (Level 4)

| Artifact | Data Variable | Source | Produces Real Data | Status |
|----------|---------------|--------|---------------------|--------|
| `route_details_card.dart` fee rows | `fee.name`, `fee.amountUsd` | `SwapQuote.feeLines`, populated from the live `/v2/route` response via `squidQuote`/`squidQuoteFromJson` | Yes | FLOWING |
| `route_details_card.dart` gas row | `quote.gasUsd` | `_sumUsd(estimate.gasCosts...)` / `_sumUsdRaw(estimate['gasCosts'])` | Yes | FLOWING |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Fee-line unit/widget tests (targeted) | `flutter test test/squid_router/route_details_card_test.dart` | 7/7 passed | PASS |
| Fee-line unit/widget tests (targeted) | `flutter test test/squid_router/route_wrap_drift_test.dart` | 7/7 passed | PASS |
| Fee-line mapping tests (targeted) | `flutter test test/swap/squid_quote_mapping_test.dart` | 10/10 passed | PASS |
| Full suite regression | `flutter test` (run once) | 1374 passed, 5 skipped, 0 failed | PASS — matches orchestrator-reported baseline exactly |
| Static analysis | `flutter analyze` | No issues found | PASS |
| Brace style gate | `bash tool/check_brace_style.sh` | exit 0 | PASS |
| Raw-colour gate | `bash tool/check_raw_colors.sh` | exit 0 | PASS |
| D-04 grep gate | `grep -rn 'toAmount -' lib/` | no output (exit 1 / no match) | PASS |
| D-05 grep gate | `grep -rnE '(Integrator\|Service\|Axelar) fee' lib/` | no output | PASS |
| D-07 grep gate | `grep -rn 'supergenius\|gnus.ai-wallet' lib/ test/` | no output | PASS |
| Fixture count unchanged | `ls test/squid_router/fixtures/ \| wc -l` | 4 | PASS |
| `pubspec.yaml` untouched within phase 29 | `git diff 7e2253ad^..12cd2472 -- pubspec.yaml` | empty | PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|-------------|-------------|--------------|--------|----------|
| FEE-02 | 29-01..29-04 | Route details name every fee, separate from chain gas | SATISFIED | All 5 ROADMAP success criteria verified above; `REQUIREMENTS.md` checkbox `[x]`, traceability row "Complete". |

No orphaned requirements found for Phase 29 — `REQUIREMENTS.md`'s Phase 29 mapping is FEE-02 alone, matching all four plans' `requirements: [FEE-02]` fields.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| `test/squid_router/route_details_card_test.dart` | 104 | Comment contains the word "placeholder" | Info | Descriptive prose about test intent ("a future placeholder row can't slip past"), not a stub or debt marker. No action needed. |
| `.planning/phases/29-fee-transparency/29-03-SUMMARY.md` | body | Body is 42 lines, 2 over AGENTS.md's SUMMARY.md ≤40-line budget | Info | Documentation-budget nit only; does not affect code correctness or goal achievement. |

No `TBD`/`FIXME`/`XXX` markers, no empty/stub implementations, and no hardcoded-empty-data patterns found in any file this phase modified.

### Human Verification Required

### 1. Fee rows at phone width in the running app

**Test:** Open `/swap`, select a cross-chain pair (e.g. Base ETH → Ethereum USDC), open route details, and inspect the fee and gas rows at a narrow (phone-width) window.
**Expected:** The fee row (e.g. `Gas receiver fee` / `$0.48`) and the `Network gas` row both render fully, without text clipping or layout overflow.
**Why human:** `flutter_test` widget tests run at a fixed default surface size; narrow-width overflow is not caught there. This is the one item `29-VALIDATION.md`'s Manual-Only table and `29-04-SUMMARY.md` both flag as deliberately carried to UAT rather than covered by automation — not a gap, but not yet exercised in a running app either.

### Gaps Summary

None. All five ROADMAP success criteria and all plan-level `must_haves` are verified against running code and passing tests, not inferred from SUMMARY.md claims. Every targeted test file was re-run independently in this verification (7/7, 7/7, 10/10) and the full suite was re-run once (1374 passed, 5 skipped, 0 failed), matching the orchestrator's reported baseline exactly. `flutter analyze` and both shell gates are clean. The only open item is the one already-acknowledged manual-only phone-width visual check, which routes this report to `human_needed` rather than `passed` per the verification decision tree — it does not block phase closure, only final UAT sign-off.

FEE-01 (Squid enabling the integrator fee) is correctly out of scope per the 2026-09-18 re-scope and was not evaluated as a gap.

---

*Verified: 2026-09-18*
*Verifier: Claude (gsd-verifier)*
