---
phase: 09-banxa
verified: 2026-07-27T00:00:00Z
status: human_needed
score: 7 of 8 must-haves verified (4 verified + 3 accepted overrides); 1 present-but-unwalked
behavior_unverified: 0 # no state-transition/cancellation invariant truths in this phase; the open items are visual/dynamic-render judgments, listed under Human Verification instead
overrides_applied: 3
overrides:
  - must_have: "ROADMAP Criterion 2 — Completing KYC pops the webview and returns success to the caller: the redirect matches `BanxaApiService.redirectUrl`, not a placeholder (finding 1, a blocker)"
    reason: >
      Deliberately NOT ADDRESSED. 09-CONTEXT.md D-02 fences this behaviour fix out of a re-skin
      phase by explicit, dated, quoted decision — Braian, 2026-07-27: "lets just redesign stuff on
      what we can," given after being asked directly whether to settle the KYC-redirect fix first.
      Independently re-confirmed here, not merely trusted: `git diff a3ee489^ a3ee489` and
      `git diff cf05642^ cf05642` (the two commits that touched `banxa_payment.dart` and
      `kyc_registration.dart` in this phase) show zero diff hunks inside either file's
      `onNavigationRequest` body — the redirect-matching logic is byte-identical to what shipped
      before this phase, not fixed. `09-OUTSTANDING.md` names a recommended follow-up phase to
      close this, starting at the two competing redirect definitions
      (`banxa_api_services.dart:17` and `:146`). SCR-05 is NOT marked satisfied because of this —
      see Requirements Coverage.
    accepted_by: "braian"
    accepted_at: "2026-07-27"
  - must_have: "ROADMAP Criterion 3 — the checkout QR scans in both light and dark appearance (finding 6), and opening Banxa KYC on Linux falls back to the browser instead of crashing (finding 7)"
    reason: >
      Deliberately NOT ADDRESSED, for two independent reasons recorded in 09-CONTEXT.md's
      <scope_reduction>: light-mode work is deferred project-wide (no light-mode walk is
      authorised in this or any current phase), and no Linux host exists in this environment to
      exercise the `Platform.isLinux` branch. 09-05 preserved the QR's white backing by construction
      (verified independently: `checkout_qr.dart:137` still reads `color: Colors.white`, allowlisted
      by name in the 09-07 literal gate) — that satisfies finding 6's visual precondition, not the
      finding itself, which needs a phone camera. 09-06 proved by diff that both webview hosts'
      `Platform.isLinux` branch condition is unchanged; the fallback screen's chrome is re-skinned,
      the branch firing is unverifiable on this Windows host.
    accepted_by: "braian"
    accepted_at: "2026-07-27"
  - must_have: "ROADMAP Criterion 1 (second clause) — a buy flow runs end to end"
    reason: >
      Deliberately NOT PERFORMED. 09-CONTEXT.md D-03 forbids any live sandbox order this phase —
      no KYC submission, no payment method, no order creation — because that depth was never
      authorised alongside the re-skin-only scope decision. The first clause of this criterion
      (surfaces render in the redesign skin) IS independently verified below. The end-to-end run
      itself is recorded as a real, open item — not claimed as met — and 09-OUTSTANDING.md names it
      as worth doing once a payment method and KYC data are set up.
    accepted_by: "braian"
    accepted_at: "2026-07-27"
requirements: [SCR-05, GAP-05]
automated_gates:
  analyze: "59 issues (pinned baseline 61 per 09-01, and 09-07's own re-pin) — no regression, independently re-run"
  reskin_literal_gate: "test/banxa/banxa_reskin_literals_test.dart — 31/31 passing, independently re-run"
  test_banxa_directory: "test/banxa/ — 88/88 passing, independently re-run"
  full_suite: "464 pass / 1 known pre-existing failure (test/local_wallet_storage_test.dart — 'Missing definition of `main` method,' predates this phase), independently re-run"
gaps: []
human_verification:
  - test: "Walk all ten in-scope Banxa surfaces in dark mode against the shipped design language (spacing, contrast, hierarchy, as rendered — not as coded)."
    expected: "Each surface reads as a sibling of Transactions/Markets/News/Swap, matching 09-UI-SPEC.md's contract."
    why_human: "D-03 forbade any walk this phase. No human has ever looked at the rendered output of any of the ten files this phase touched. This is the largest single open item and is also what GAP-05's own definition ('a before/after comparison must show the same items in the same order doing the same things') and ROADMAP Criterion 4's fidelity clause both still need."
  - test: "Reach the buy screen's ENABLED Create Order rung (`state.canCreateOrder == true`, needs a real sandbox quote) and observe its `GWButton(gradient)` paint and tap behaviour."
    expected: "The gradient CTA renders correctly and is tappable, matching the disabled rung's already-tested treatment."
    why_human: "D-03 forbids the live sandbox quote needed to reach this state. Only the disabled rung and the retry affordance are pinned by `test/banxa/banxa_buy_screen_test.dart` (09-03)."
  - test: "Drive a real checkout redirect carrying a `pendingpayment`/`declined`/`completed` status into `order_details_page.dart` and observe `OrderStatusBanner`'s live paint."
    expected: "The tinted-severity banner renders with the correct tone and is legible against the card."
    why_human: "D-03 forbids the sandbox network round trip. The tone mapping is proven by unit test against synthetic status strings (`order_details_card_test.dart`, 09-04), not by a real redirect."
  - test: "Measure `GeniusWalletColors.statusWarning` (`#FFC42E`)'s WCAG AA contrast as pill/banner running text against `surfaceElevated`, in both appearance modes."
    expected: "The pairing holds AA, or the token is demoted to tint/icon-only use per 09-UI-SPEC's own fallback instruction."
    why_human: "Flagged since 09-RESEARCH Assumption A2 as never measured by any prior phase. No `theme_contrast_test.dart`-style pinned test covers this token; this phase inherited the recipe, it did not invent or measure it."
  - test: "Render the orders-history empty state at a realistic window size and confirm `GWEmptyState` does not fall into its compact (<192px slot height) tier unexpectedly."
    expected: "The empty state renders in its full tier at normal window dimensions."
    why_human: "The empty state's host `Column` has no fixed height; the widget test confirms the empty state RENDERS, not which tier it renders in at real layout dimensions."
  - test: "Scan the checkout QR with a phone camera in both light and dark appearance (finding 6)."
    expected: "The QR scans successfully in both modes."
    why_human: "No light-mode walk is authorised this phase; no camera/device verification can be automated. Covered by an accepted override for phase-closure purposes, but the finding itself is not resolved."
  - test: "Trigger the Linux browser-fallback branch on a real Linux host (finding 7)."
    expected: "`banxa_payment.dart`/`kyc_registration.dart` launch the system browser instead of crashing."
    why_human: "No Linux host exists in this environment. `webview_fallback_test.dart` (09-06) proves the fallback screen's LAYOUT via an inline widget reconstruction — a different claim from the branch actually firing. Covered by an accepted override for phase-closure purposes, but the finding itself is not resolved."
---

# Phase 9: Banxa Verification Report

**Phase Goal:** The fiat on-ramp wears the redesign and keeps develop's rework
**Verified:** 2026-07-27
**Status:** human_needed
**Re-verification:** No — initial verification

## Governing scope decision (read first)

This phase was deliberately narrowed to a **re-skin only** by a dated, quoted, user decision
recorded in `09-CONTEXT.md`: Braian, 2026-07-27 — *"lets just redesign stuff on what we can."*
Asked directly whether to settle the KYC-redirect fix, the end-to-end buy walk, the Linux fallback,
and the light-mode question first, he chose to narrow scope and leave those for later. The phase's
own governing documents (`09-CONTEXT.md`, `09-OUTSTANDING.md`) state plainly, and repeatedly, that
**Phase 9 as scoped does NOT satisfy three of its four ROADMAP success criteria**, and that this
must never be recorded as met. This report independently confirms both halves of that claim: that
the re-skin genuinely happened (not merely claimed), and that the phase did not overclaim what it
did not deliver.

## Goal Achievement

### ROADMAP Success Criteria

| # | Criterion | Status | Evidence |
| --- | --- | --- | --- |
| 1 | Buy, KYC, checkout, order history/details render in the redesign skin **and a buy flow runs end to end** | ⚠️ PARTIAL | Rendering half VERIFIED (see Required Artifacts below — all ten in-scope files use `GWCard`/`GWButton`/`GWColors` live reads, zero un-allowlisted raw colour literals, confirmed by independent test run). End-to-end run NOT performed — **override accepted** (D-03), see frontmatter. |
| 2 | Completing KYC pops the webview and returns success — the redirect matches `BanxaApiService.redirectUrl`, not a placeholder (finding 1, blocker) | ✗ NOT ADDRESSED | Independently confirmed: `onNavigationRequest` bodies in both `banxa_payment.dart` and `kyc_registration.dart` are byte-identical before/after this phase's commits (`git diff a3ee489^ a3ee489`, `git diff cf05642^ cf05642` — zero hunks touch the redirect-matching logic). **Override accepted** (D-02) — deliberately deferred, not a defect introduced or missed by this phase. |
| 3 | Checkout QR scans in both light and dark (finding 6); Linux KYC falls back to browser (finding 7) | ✗ NOT ADDRESSED | QR's white backing preserved by construction (`checkout_qr.dart:137`, allowlisted in the literal gate) — satisfies the visual precondition, not the finding. Linux branch condition unchanged (confirmed via diff); firing is unverifiable on this Windows host. **Override accepted** for phase-closure — both findings remain genuinely open, see Human Verification. |
| 4 | develop-only Banxa additions (`banxa_orders_history.dart`, `banxa_payment.dart`, `banxa_buy_screen.dart`) wear the extended design language per Phase 3 | ✓ VERIFIED at code level | All three named files, plus all seven other in-scope files, independently confirmed re-skinned (GWCard/GWButton/GWColors, zero raw literals). Visual fidelity (does it actually LOOK right) is unwalked — listed under Human Verification, not claimed here. |

### Additional Truths (fence compliance and regression gate — not in ROADMAP wording, but load-bearing for the goal)

| # | Truth | Status | Evidence |
| --- | --- | --- | --- |
| 5 | No behaviour, structure, or wiring changed under cover of the re-skin (D-01/D-02) | ✓ VERIFIED | Diffed every phase commit against its parent; every changed file's callback bodies, cubit calls, redirect logic, and route literals are structural/paint-only changes. Explicit spot-check on the two `onNavigationRequest` bodies (Criterion 2) confirms zero behavioural drift. |
| 6 | The four Phase-21 drawers (D-05) and all cubit/service/model files (D-06) were never touched | ✓ VERIFIED | `git show --stat` on every commit across the phase (`b479266` through `6c66d9d`) touches only `test/banxa/`, the ten named `lib/` files, and two `.planning/` docs — zero touches to `buy_success_drawer.dart`, `buy_cancelled_drawer.dart`, either `_content` file, `banxa_order/*`, `banxa_api_services.dart`, `banxa_model.dart`, or `banxa_helpers/*`. Root-level `banxa/`/`squidrouter/`/`tokeninfo/` submodules also confirmed untouched by this phase's commit range. |
| 7 | A standing regression gate exists and passes, preventing the re-skin from rotting | ✓ VERIFIED | `flutter test test/banxa/banxa_reskin_literals_test.dart` — 31/31 pass, independently re-run (not taken from SUMMARY claim). |
| 8 | The phase's requirement claims match reality — SCR-05/GAP-05 are not falsely marked complete | ✓ VERIFIED | Both remain `- [ ]` unchecked in `REQUIREMENTS.md` at HEAD. Confirmed the one mistaken tick (SCR-05 checked by commit `cdcd164`, 09-04's docs commit) was reverted in the very next commit `5d445af` (09-05's docs commit) — the mistake-and-correction narrative in the SUMMARYs matches the actual git history. |

**Score:** 7/8 must-haves verified (4 VERIFIED + 3 PASSED-by-override), 1 remains PARTIAL/open pending a human walk (Criterion 1's second clause folds into the same open item as Criterion 4's fidelity walk, counted once).

### Required Artifacts (all ten in-scope files, D-04 + D-07 + UI-SPEC addendum)

| Artifact | Expected | Status | Details |
| --- | --- | --- | --- |
| `lib/screens/banxa_buy_screen.dart` | GWButton CTA ladder, no hand-rolled gradient tree | ✓ VERIFIED | `grep` confirms `GWButton(variant: GWButtonVariant.gradient, ... label: 'Create Order')` at CTA site; the old `InkWell`/`Ink`/`BoxDecoration(greenBlueGreenGradient)` tree is gone; only allowlisted `Colors.black45` (boot scrim) and `Colors.white` remain n/a here (checked separately below) |
| `lib/banxa/banxa_orders_history.dart` | GWErrorState/GWEmptyState, back-arrow AppBar | ✓ VERIFIED | `grep` confirms `GWErrorState`, two `GWEmptyState` branches ("No orders yet" / "No orders match this filter."), zero "No orders found." string |
| `lib/banxa/banxa_components/order_card.dart` | GWCard, OrderStatusPill, GWButton ladder | ✓ VERIFIED | `grep` confirms `GWCard`, `OrderStatusPill(status: order.status)`, three `GWButton` variants (gradient/secondary/tertiary), zero raw `Colors.*`/`lightGreenSecondary` |
| `lib/banxa/banxa_components/order_details_card.dart` | Tinted severity banner, 4-bucket ladder | ✓ VERIFIED | `grep` confirms `OrderStatusBanner`, no opaque `bannerColor` fill |
| `lib/screens/order_details_page.dart` | Banner-tone plumbing, twin GWButton swap | ✓ VERIFIED | Confirmed via 09-04 diff and literal gate (file #10 in the 31-test gate) |
| `lib/banxa/banxa_components/quote_card.dart` | GWCard, still dead code (D-08) | ✓ VERIFIED | `grep -rc 'QuoteCard(' lib/` still resolves to exactly the component's own constructor — confirmed still unwired, per D-08's explicit intent |
| `lib/banxa/checkout_qr.dart` | GWButton Copy Link, white QR backing preserved | ✓ VERIFIED | `Colors.white` still present at line 137 (allowlisted), `GWColors` live read present |
| `lib/banxa/handle_banxa_drawer.dart` | Re-skinned checkout options sheet (D-07) | ✓ VERIFIED | Confirmed in the literal gate's ten-file list |
| `lib/banxa/banxa_payment.dart` | Shared back-arrow AppBar, GWButton fallback buttons, redirect logic untouched | ✓ VERIFIED | `onNavigationRequest` diff-confirmed byte-identical |
| `lib/banxa/user_kyc/kyc_registration.dart` | Same twin treatment, redirect logic untouched | ✓ VERIFIED | `onNavigationRequest` diff-confirmed byte-identical |
| `test/banxa/banxa_reskin_literals_test.dart` | Standing 31-test gate over all ten files | ✓ VERIFIED | Independently re-run: 31/31 pass |
| `.planning/phases/09-banxa/09-OUTSTANDING.md` | Honest ledger of undelivered criteria | ✓ VERIFIED | Exists, matches the actual code state confirmed above |

### Key Link Verification

| From | To | Via | Status | Details |
| --- | --- | --- | --- | --- |
| `order_card.dart`, `order_details_card.dart`, `order_details_page.dart` | `order_status_style.dart` | shared `OrderStatusTone`/`OrderStatusPill`/`OrderStatusBanner` | ✓ WIRED | One ladder, imported by all three consumers, confirmed by `order_status_style_test.dart` (69 passing sub-assertions in the full `test/banxa/` run) |
| `banxa_buy_screen.dart`, `banxa_orders_history.dart` (×2), `order_details_page.dart` | `handle_banxa_drawer.dart`'s `showCheckoutOptionsSheet` | 4 call sites, unchanged signature | ✓ WIRED | Confirmed unchanged by 09-05's diff check; not independently re-diffed here beyond the phase-wide fence check (Truth 5/6) |
| `banxa_payment.dart` / `kyc_registration.dart` | `BanxaApiService.redirectUrl` / `banxaKycUrl` | `onNavigationRequest`'s `request.url.contains(...)` match | ✓ WIRED, UNCHANGED | Confirmed byte-identical pre/post phase — this is the finding-1 blocker logic, deliberately left as-is (D-02) |

### Anti-Patterns Found

None. Scanned all ten in-scope files plus `order_details_page.dart` for `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/placeholder language — zero matches. The two "todo" string matches found (`handle_banxa_drawer.dart`, `quote_card.dart`) are prose references to filed `.planning/todos/pending/*.md` documents, not in-code debt markers, and both filed todo files were confirmed to exist on disk.

### Requirements Coverage

| Requirement | Source Plans | Description | Status | Evidence |
| --- | --- | --- | --- | --- |
| SCR-05 | 09-01..09-07 | Banxa wears the redesign and keeps develop's rework — **including the real KYC redirect URL** | ✗ NOT SATISFIED (by this phase's own design) | `REQUIREMENTS.md` line 50 remains `- [ ]`. The redirect-URL clause is explicitly what D-02 defers; this phase proved the redirect logic untouched, not fixed. Cannot be satisfied by this phase alone — carries to the recommended follow-up phase. |
| GAP-05 | 09-02, 09-03, 09-06 | Banxa additions re-skinned in place; structure unchanged — **and** a before/after comparison shows the same items, in the same order, doing the same things (per `REQUIREMENTS.md`'s own GAP-02..06 completion clause) | ⚠️ PARTIAL | First clause SATISFIED: all three named files (`banxa_orders_history.dart`, `banxa_payment.dart`, `screens/banxa_buy_screen.dart`) independently confirmed re-skinned with structure preserved (diff-checked callback bodies/route literals unchanged). Second clause NOT PERFORMED: no before/after visual walk was done (D-03) — `REQUIREMENTS.md` line 82 correctly remains `- [ ]`. |

**Both requirements correctly remain unchecked at HEAD** — matches the phase's own stated intent, and the one mid-phase mistake (SCR-05 briefly ticked by commit `cdcd164`) was independently confirmed reverted by the following commit (`5d445af`).

### Automated Gates — Independently Re-Run (not taken from SUMMARY claims)

| Gate | Command | Result | Claimed (SUMMARY) | Match? |
| --- | --- | --- | --- | --- |
| Analyze | `flutter analyze lib` | 59 issues | 59 (baseline 61) | ✓ exact match |
| Reskin literal gate | `flutter test test/banxa/banxa_reskin_literals_test.dart` | 31/31 pass | 31/31 | ✓ exact match |
| `test/banxa/` directory | `flutter test test/banxa/` | 88/88 pass | 88 | ✓ exact match |
| Full suite | `flutter test` | 464 pass / 1 known failure | 463+31=494? claimed "463 pass" at 09-07 head, then 464 after full re-run here | ✓ matches "the_thing_that_matters_most" brief's independently-confirmed 464/1 |

The one failure (`test/local_wallet_storage_test.dart` — "Missing definition of `main` method") was independently confirmed to be the same named pre-existing failure, not a new one.

## Human Verification Required

See frontmatter `human_verification` for the full structured list (7 items). Summarized:

1. **The ten-surface dark-mode visual walk** — never performed this phase (D-03). This is the single
   largest open item; it also closes GAP-05's second clause and Criterion 4's fidelity question.
2. **The enabled Create Order CTA rung** — unreachable without a live sandbox quote (D-03).
3. **The order-details banner's live paint from a real redirect** — unreachable without the sandbox network (D-03).
4. **`statusWarning`'s WCAG AA contrast measurement** — flagged since 09-RESEARCH, never measured by any phase.
5. **`GWEmptyState`'s compact-tier threshold on the orders grid** — needs a real window-size render.
6. **Finding 6 — QR scans in both appearances** — needs a phone camera and the (project-wide-deferred) light-mode pass.
7. **Finding 7 — Linux fallback actually fires** — needs a Linux host, none available here.

## Gaps Summary

No code-level gaps were found: the re-skin is real (not stubbed), every fence held (D-01, D-02,
D-05, D-06 all independently re-confirmed via diff), the standing regression gate passes, and the
phase does not overclaim — both SCR-05 and GAP-05 correctly remain unchecked, and the one mid-phase
mistaken checkbox was caught and reverted within the phase itself.

What remains is not a defect to fix inside Phase 9, but a set of items this phase's own governing
documents (`09-CONTEXT.md`, `09-OUTSTANDING.md`) already named and deliberately left open by a
dated, attributed product decision: no visual walk was authorized or performed, and two ROADMAP
findings (1 and 6/7) are explicitly deferred to a recommended follow-up phase. Status is
`human_needed` rather than `passed` because the visual walk — unlike Phase 8, where a full
dark-mode walk was performed before closing — was never performed at all in this phase, and a human
still needs to either (a) perform that walk, or (b) explicitly accept closing without it, before
Phase 9 is fully done. Status is not `gaps_found` because there is no code-level defect requiring a
new Phase 9 plan — the recommended remediation is a separate, already-named follow-up phase for the
KYC redirect fix (criterion 2) and the Linux fallback (finding 7), not more work inside this phase.

**Recommended next step:** review the human-verification list above; if accepted as final for this
phase's closure (matching the precedent `08-VERIFICATION.md` set for its declined light-mode pass),
record explicit acceptance and proceed to Phase 10. The KYC redirect fix (criterion 2) is the one
item on this list with real user impact and should not wait indefinitely.

---

*Verified: 2026-07-27*
*Verifier: Claude (gsd-verifier)*
