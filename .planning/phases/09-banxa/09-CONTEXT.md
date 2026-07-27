# Phase 9: Banxa - Context

**Gathered:** 2026-07-27
**Status:** Ready for planning

<domain>
## Phase Boundary

The fiat on-ramp — buy, KYC, checkout, order history and order details — **wears the redesign**.

**This phase is a RE-SKIN ONLY.** Braian, 2026-07-27: *"lets just redesign stuff on what we can."*
Asked whether to settle the KYC-redirect fix, the end-to-end buy walk, the Linux fallback and the
light-mode question first, he chose to narrow the phase to the visual work and leave the rest.

That decision is respected here, and its cost is written down rather than glossed: **Phase 9 as
scoped does NOT satisfy all four of its ROADMAP success criteria.** See `<scope_reduction>`.

</domain>

<scope_reduction>
## What this phase will NOT deliver — read before claiming criteria

The ROADMAP lists four criteria for Phase 9. Under the re-skin-only scope:

| # | Criterion | Status under this scope |
|---|-----------|-------------------------|
| 1 | "…and a buy flow runs end to end" | **PARTIAL.** The surfaces get re-skinned. The end-to-end run is NOT walked — it needs sandbox KYC data, a payment method and a live order, and that depth was not authorised. |
| 2 | KYC redirect matches `BanxaApiService.redirectUrl`, not a placeholder (**flagged a blocker**) | **NOT ADDRESSED.** This is a behaviour fix, deliberately out of the re-skin. |
| 3 | Checkout QR scans in both light and dark (finding 6); Linux KYC falls back to browser (finding 7) | **NOT ADDRESSED.** Light mode is deferred project-wide; Linux is unverifiable on the Windows host. |
| 4 | develop-only additions wear the extended design language | **IN SCOPE.** This is the phase. |

**Consequence for closing the phase:** verification must record criteria 1–3 as OUTSTANDING, or the
phase closes with an explicit override citing this decision — the same pattern Phase 8 used for its
declined light-mode pass. **Never record them as met.** SCR-05 names the KYC redirect explicitly
("*including the real KYC redirect URL*"), so SCR-05 cannot be marked satisfied by this phase alone.

**Recommended follow-up:** a small behaviour-fix phase covering criterion 2 (the blocker) and
finding 7, separate from this re-skin. Criterion 2 is the one that actually blocks users.

</scope_reduction>

<decisions>
## Implementation Decisions

### Scope
- **D-01: Re-skin only.** Surfaces wear the redesign; behaviour, structure, order and wiring are
  untouched. This is the milestone's standing rule — *"Re-skin, never restructure"* and *"Take
  Alex's visual, never his behavior"* — applied without the criterion-2 exception the ROADMAP had
  carved out.
- **D-02: No behaviour fixes in this phase**, including the finding-1 KYC redirect blocker. Anything
  that would change what the code *does* rather than how it *looks* is out, and gets recorded for a
  follow-up phase rather than smuggled into a re-skin commit.
- **D-03: No end-to-end buy walk.** Verification is limited to what can be seen without submitting a
  live sandbox order. No KYC submission, no payment method, no order creation.

### Surfaces in scope
- **D-04:** The Banxa screens and cards: `lib/screens/banxa_buy_screen.dart`,
  `lib/banxa/banxa_orders_history.dart`, `lib/banxa/banxa_payment.dart`,
  `lib/banxa/checkout_qr.dart`, `lib/banxa/user_kyc/kyc_registration.dart`, and
  `lib/banxa/banxa_components/{order_card,order_details_card,quote_card}.dart`.

### Surfaces explicitly NOT in scope
- **D-05: The four Banxa DRAWERS belong to Phase 21, not Phase 9.**
  `buy_success_drawer.dart`, `buy_cancelled_drawer.dart` and their two `_content` files are already
  claimed by plan `21-04` (drawer-language rollout, 031-B1). Phase 9 must not touch them.
  This fence is deliberate: Phase 21's `21-04` was written before Phase 8 ran and collided with
  files 08-05 had deleted. Two phases editing the same drawers would repeat that, and the
  drawer-language phase is the one that owns drawer archetypes.
- **D-06:** Cubits and services are untouched — `banxa_order/*`, `banxa_api_services.dart`,
  `banxa_model.dart`, `banxa_helpers/*`. A re-skin has no business in the order state machine.

### Claude's Discretion
- Which redesign primitives each surface adopts (GWCard, GWButton, GWPageHeader, the shipped input
  theme, `GWColors` reads) — the design language is already settled across phases 3–8; this is
  translation with a right answer.
- Plan decomposition and wave grouping.

### Folded Todos
- **"Drawer bodies have no horizontal padding"**
  (`.planning/todos/pending/2026-07-27-drawer-bodies-have-no-horizontal-padding.md`) — NOT folded
  into Phase 9; it names Banxa-adjacent drawers but those are D-05's fence. Left with Phase 21,
  whose `21-01` and `21-06` add the padding primitive and its invariant test.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Governing rules
- `.planning/PROJECT.md` §64–65 — *"Take Alex's visual, never his behavior"* and *"Re-skin, never
  restructure"*. Both bind this phase; D-01 and D-02 are their direct application.
- `.planning/REQUIREMENTS.md` — SCR-05 (line 50) and GAP-05 (line 82). Note SCR-05's wording
  includes the KYC redirect, which this phase does NOT deliver.
- `.planning/ROADMAP.md` § Phase 9 — the four criteria, three of which this scope leaves open.

### Prior phase decisions that constrain this one
- `.planning/phases/07-token-screens/07-CONTEXT.md` — D-01/D-02 set the precedent for fencing a
  behaviour fix out of a re-skin phase (Send left inert). Phase 9 applies the same reasoning to the
  KYC redirect.
- `.planning/phases/08-swap-bridge/08-CONTEXT.md` — D-22 (descoping a walk) and D-23 (never
  executing a real fund-moving call without explicit authorisation at the time). D-23's spirit
  applies to any sandbox order submission.
- `.planning/phases/08-swap-bridge/08-VERIFICATION.md` — the override pattern this phase will need
  if it closes without criteria 1–3.

### Design language
- `.planning/sketches/MANIFEST.md` — the shipped archetypes. Relevant winners: **030-B1** drawer
  shell, **032-A1** list picker, **031-B1** receipt, **063-A** settings form.
- `.planning/sketches/drawers-final/README.md` — consolidated drawer decisions.

### Findings referenced but NOT actioned here
- Finding 1 (KYC redirect blocker), finding 6 (QR in both appearances), finding 7 (Linux fallback).
  Recorded in `<deferred>` so the follow-up phase inherits them.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `GWCard`, `GWButton`, `GWPageHeader`, `GWEmptyState`, `GWFocusRing` and the shipped input theme —
  the same set phases 3–8 used. Every Banxa surface should be expressible in them.
- `GWColors` extension read via `Theme.of(context).extension<GWColors>()` with the fail-soft
  `?? GWColors.dark()` idiom — the app-wide convention for live appearance-toggle correctness.

### Established Patterns
- **Live appearance reads.** Const widgets do not re-skin on an appearance toggle (a known todo);
  every re-skinned widget must take a live `GWColors` read rather than baking constants.
- **No hardcoded colours.** Banxa currently carries pre-redesign literals; these are exactly what
  the re-skin replaces. WCAG AA in both modes is the standing rule even though light mode is not
  being *walked* this phase.

### Integration Points
- Banxa targets **`banxa-sandbox.com`** (`banxa_api_services.dart:18`) — no real money is involved
  in this integration today, which is why the buy-walk decision (D-03) is about effort, not risk.
- The buy redirect is already built as `geniuswallet://banxa/callback?extOrderId=…`
  (`banxa_api_services.dart:146`) with a matching route at `router.dart:114` that parses
  `status`/`extOrderId`/`orderId`. **There are two redirect definitions** — the const at
  `banxa_api_services.dart:17` and the inline `Uri` at `:146`. That split is very likely what
  finding 1 is pointing at. Left untouched by D-02, but the follow-up phase should start here.

</code_context>

<specifics>
## Specific Ideas

No specific visual references given for Banxa. The instruction was to apply what the design system
already settled — so the surfaces should read as siblings of the Transactions, Markets and News
pages rather than inventing a Banxa dialect.

</specifics>

<deferred>
## Deferred Ideas

- **Criterion 2 / finding 1 — the KYC redirect blocker.** A behaviour fix; needs its own phase.
  Start at the two competing redirect definitions noted in `<code_context>`.
- **Finding 7 — Linux KYC browser fallback.** Unverifiable on the Windows host; needs either a
  Linux box or an explicit code-level argument plus a recorded deferral.
- **Finding 6 / light mode** — deferred project-wide; the QR's light-mode legibility rides with the
  eventual dedicated light pass.
- **End-to-end sandbox buy walk** — worth doing once, but it needs KYC data and a payment method
  set up first.

### Reviewed Todos (not folded)
- *Drawer bodies have no horizontal padding* — belongs to Phase 21 per D-05.
- The 44 keyword-matched UI todos (light-mode treatment, const-widget re-skin, hover rounding, etc.)
  are project-wide design-system items, not Banxa-specific. None folded.

</deferred>

---

*Phase: 9-Banxa*
*Context gathered: 2026-07-27*
