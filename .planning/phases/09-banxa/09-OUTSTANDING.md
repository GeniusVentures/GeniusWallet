# Phase 9 (Banxa): What This Phase Did Not Deliver

Phase 9 was scoped, deliberately, as **a re-skin only** — the fiat on-ramp's five screens and
their shared components wear the redesign's visual vocabulary, but no behaviour, no structure and
no wiring changed underneath them (D-01/D-02). No end-to-end buy was walked (D-03): everything
below was verified by automated test or by direct code inspection, at dark-mode depth only, on a
Windows host. The direct consequence, stated once here so nobody has to re-derive it: **Phase 9 as
scoped does NOT satisfy all four of its ROADMAP success criteria.** This document is where
`/gsd-verify-work` and any future phase-closeout reader should look before recording this phase as
more complete than it is.

## The four ROADMAP criteria, honestly

| # | Criterion | Status | Why |
|---|-----------|--------|-----|
| 1 | "Buy, KYC, checkout and order history/details render in the redesign skin and a buy flow runs end to end" | **PARTIAL** | All five screens and every shared component are re-skinned and test-covered (09-01 through 09-06). The end-to-end run is NOT walked — it needs sandbox KYC data, a payment method and a live order, and that depth was never authorised (D-03). |
| 2 | "Completing KYC pops the webview and returns success to the caller — the redirect matches `BanxaApiService.redirectUrl`, not a placeholder" (finding 1, flagged a blocker) | **NOT ADDRESSED** | This is a behaviour fix, deliberately fenced out of a re-skin phase (D-02). 09-06 proved by diff against a pre-edit baseline that `onNavigationRequest`'s redirect-matching logic in both `banxa_payment.dart` and `kyc_registration.dart` is byte-identical to what shipped before this phase touched either file — the blocker is untouched, not fixed. |
| 3 | "The checkout QR scans in both light and dark appearance (finding 6), and opening Banxa KYC on Linux falls back to the browser instead of crashing (finding 7)" | **NOT ADDRESSED** | Finding 6: light mode is deferred project-wide; 09-05 preserved the QR's white backing by construction and pinned it mode-invariant by test, which closes the visual precondition but is not the same claim as "scans," which needs a phone camera and a light-mode pass neither authorised. Finding 7: 09-06 re-skinned the Linux-fallback screen's chrome, but `Platform.isLinux` is false on this Windows host, so the fallback branch has never been reached in this phase's tests or this session — unverifiable here. |
| 4 | "The develop-only Banxa additions (`banxa_orders_history.dart`, `banxa_payment.dart`, `banxa_buy_screen.dart`) wear the extended design language per the Phase 3 treatment" | **IN SCOPE, delivered at the code level** | This is the phase. All three named files (plus every other in-scope surface) are re-skinned, test-covered, and now held under the 09-07 literal gate. The remaining open question is the visual judgement below — whether the re-skin actually LOOKS right — which is a walk question, not a code question. |

**Consequence for closing the phase:** criteria 1–3 must be recorded as OUTSTANDING at phase
verification, or the phase closes with an explicit override citing this document — the same
pattern `08-VERIFICATION.md` used for its declined light-mode pass. They must never be recorded as
met.

## Consolidated OUTSTANDING list

Every row below is a genuine gap, each with a named owner and a path to closing it. None of these
were silently dropped — each is a deliberate, reasoned scope decision recorded in the plan that
produced it.

| Item | What's unverified | Why it could not be verified this phase | What would verify it |
|------|--------------------|------------------------------------------|------------------------|
| Visual fidelity, all ten surfaces | Whether the re-skin actually LOOKS right against the shipped design language — spacing, contrast, hierarchy, as rendered, not as coded | D-03 forbids any walk this phase; this is the largest single item this phase closes with (09-CONTEXT `<human_judgment>`) | A dark-mode visual walk across all ten in-scope files, the same depth Phase 8's walk performed |
| The ENABLED Create Order CTA rung | `banxa_buy_screen.dart`'s `GWButton(gradient)` Create Order button's enabled paint and tap behaviour | Reaching the enabled rung needs a live sandbox quote (`state.canCreateOrder == true`), which D-03 forbids; only the disabled rung and the retry affordance are pinned by `banxa_buy_screen_test.dart` (09-03) | A sandbox quote fetched through to a real `MakeOrderState`, then the CTA observed enabled during a walk |
| The order-details banner's live appearance | `order_details_page.dart`'s `OrderStatusBanner`, driven by `bannerTone(widget.initialStatus)`, has never been seen painted from a real checkout redirect round trip | D-03 forbids the sandbox network; the tone mapping is proven by unit test (`order_details_card_test.dart`, 09-04) against synthetic status strings, not by a real redirect | A real checkout redirect carrying a `pendingpayment`/`declined`/`completed` status, observed during a walk |
| `GeniusWalletColors.statusWarning`'s AA contrast as pill/banner text | Whether the mode-invariant `#FFC42E` token is WCAG AA-compliant as running text against `surfaceElevated`/the pill fill, in either mode | Flagged since 09-RESEARCH Assumption A2 as never measured by any prior phase; this phase inherited the already-shipped `transaction_displays.dart` recipe rather than inventing a new one, so the risk carried forward rather than being created here | A contrast measurement (e.g. the project's `theme_contrast_test.dart` pattern extended to this token) against both `surfaceElevated` variants |
| `GWEmptyState`'s compact-layout threshold on the orders grid | `GWEmptyState` auto-switches to a compact tier below a 192px slot height (09-RESEARCH); `banxa_orders_history.dart`'s empty-state `Column` has no fixed height, so which tier renders depends on real layout, not on the widget test's synthetic host | Not observable without a real render at real window dimensions; the widget test in `orders_history_states_test.dart` (09-02) confirms the empty state RENDERS, not which tier it renders in | A walk at a realistic window size, checking the empty state is not squeezed into the compact tier unexpectedly |
| Finding 6 — checkout QR scans in both appearances | Whether the QR actually scans with a phone camera, in both light and dark | No light-mode walk is authorised this phase (deferred project-wide); no camera/device verification can be automated | A light-mode pass plus a real phone-camera scan test, once the project-wide light-mode work is scheduled |
| Finding 7 — Linux KYC browser fallback fires | Whether `banxa_payment.dart`/`kyc_registration.dart`'s `Platform.isLinux` branch actually launches the system browser instead of crashing | No Linux host exists in this environment; `webview_fallback_test.dart` (09-06) proves the fallback screen's LAYOUT via an inline widget reconstruction, which is a different claim from the branch FIRING | A Linux-capable host, or an explicit Linux CI run exercising the real `Platform.isLinux` branch |

## Requirement status

**SCR-05 must NOT be marked complete by this phase, and stays unchecked in `REQUIREMENTS.md`.**
SCR-05's own wording is *"Banxa … wears the redesign and keeps develop's rework — including the
real KYC redirect URL."* The redirect fix is exactly what D-02 defers (see criterion 2 above);
this phase proved the redirect logic untouched, not fixed. A requirement whose own text names a
deliverable this phase explicitly did not attempt cannot be satisfied by this phase alone.

**GAP-05** names three files — `banxa_orders_history.dart`, `banxa_payment.dart`,
`screens/banxa_buy_screen.dart` — and all three are re-skinned in place with structure unchanged,
which is what GAP-05's first clause asks for. But GAP-05's own definition (`REQUIREMENTS.md`)
carries a second clause: a before/after comparison must show the same items in the same order
doing the same things. No walk performed that comparison this phase — every claim of
structure-preservation in 09-02/09-03/09-06 rests on `git diff` (confirming untouched call sites,
untouched signatures, untouched business logic) and on widget tests pinning byte-identical copy
and row values, not on a human looking at the running screen before and after. That is real
evidence, and it is not the same evidence GAP-05's own wording asks for. **This checkbox is left
unchecked here, deliberately, so that phase verification makes this judgement with the full
picture in front of it rather than inheriting a decision already made for it.** Three earlier
plans in this phase each mistakenly ticked a requirement checkbox and had to revert it
(`REQUIREMENTS.md`'s SCR-05 traceability row records the same correction) — this document does
not repeat that mistake in either direction.

## ⚠ The finding that actually blocks closeout — the layout was never designed

Added 2026-07-27, after Braian reached the re-skinned screens in the running app:
**"we need to redesign the banxa screens it's too ugly."**

This is not a defect in Phase 9's execution, and it is not a token problem. Asked to distinguish,
Braian confirmed it is **layout and structure**, not "the re-skin didn't land". The 09-07 literal
gate (31 tests) and the verifier's code-level grep both independently confirm the tokens ARE
applied. The screens are consistent. They are not good.

**The cause is structural and was baked in from the start.** `PROJECT.md` line 33 says the
develop-era surfaces have **no mockup** — "they wear the design language in place, structure
unchanged" — and §65's *"Re-skin, never restructure"* then held that structure fixed. So Phase 9
correctly applied a design system to a layout that had never been designed. Every other surface in
this milestone got a sketch first:

| Surface | Sketches |
|---------|----------|
| Swap | 105, 040, 041, 060, 062 |
| Feedback | 150, 153, 064 |
| Markets | 103, 107–115 |
| Transactions | 007–014, 020–030 |
| Token picker / numbers | 032, 065, 066 |
| **Banxa** | **none** |

**What is concretely wrong, from reading the code:**

- `banxa_buy_screen.dart` is a bare `Column` of three stock Material `DropdownMenu`s (Fiat, Crypto,
  Payment Method) plus a `TextField` amount, a Get Quote button, a quote `GWCard` and a wallet
  `TextField`. No grouping, no hierarchy, and stock dropdowns rather than the app's own field
  language. A re-skin could not fix this: swapping a `DropdownMenu` for something else is
  restructuring.
- `banxa_orders_history.dart` stacks a Status dropdown, a "Pick Date Range" button, a date string
  and "Total Orders: N" in a plain `Column` above the list — filters as loose controls rather than
  a designed toolbar.

**Both have a precedent this app already settled**, which is why the fix is tractable rather than
open-ended:

- **Buy is Swap with one side fixed to fiat.** Sketch 105-A1 solved the same shape — a 560px
  column, two amount cards, a details card, a gradient CTA ladder.
- **Orders-with-filters is Transactions.** Phases 12/15 solved filter-above-list already.

**Status: this item is OUTSTANDING and it is the one that should gate calling Banxa "done".** The
other items above are verification debt — things true but unwitnessed. This one is a product gap:
the surfaces are finished to spec and the spec was never drawn.

**Next step, agreed but not yet executed:** sketch the buy form and the orders page (3 variants
each, grounded in the two precedents above), pick winners, then implement in a follow-up phase.
Sketch numbers 067 and 068 are free and reserved for this. Deferred at the end of the 2026-07-27
session; nothing has been built yet.

## Recommended follow-up

A small, separate behaviour-fix phase covering criterion 2 (the KYC redirect blocker — the one
that actually blocks users) and finding 7 (the Linux fallback), starting at the two competing
redirect definitions 09-CONTEXT's `<code_context>` already identifies: the const at
`banxa_api_services.dart:17` and the inline `Uri` at `:146`. Criterion 2 is the one item on this
list with real user impact; everything else here is a verification gap, not a functional one.
