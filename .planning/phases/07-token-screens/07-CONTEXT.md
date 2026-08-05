# Phase 7: Token screens - Context

**Gathered:** 2026-07-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 7 **re-skins the token-detail experience to the redesign, keeping develop's behavior** — it is a
re-skin, not a build-new phase. The surface is centered on `lib/tokens/token_info_screen.dart` (the
`/token-info` route) and the drawers it launches.

**In scope (re-skin what already exists):**
- The token-detail page: chart region, balance/identity header, and the action-button row.
- The **Receive** drawer (`ResponsiveDrawer` + `CryptoAddressQR`).
- The **More** drawer (`ResponsiveDrawer` → Bridge Tokens, gated on `isGnusBridgeEnabled`).
- **Finding 37** — tapping "More" on a non-GNUS token opens an empty drawer; the button must be
  disabled instead.
- **Finding 24** — leaving the token chart mid-fetch / while its refresh timer runs must not throw
  `setState after dispose` (add/keep the `mounted` guard). **This is the ONLY chart work in Phase 7.**
- The Send and Swap action buttons are **re-skinned but remain inert** (see decisions).

**Out of scope (fenced — see Deferred):** wiring a real Send flow, the address book, the Markets tab
(Phase 16), and the token-detail chart re-skin (already done in Phase 5, inherited).
</domain>

<decisions>
## Implementation Decisions

### Send (WIRE-2) — the load-bearing decision
- **D-01: Phase 7 does NOT wire Send. Re-skin only; Send stays inert.** The token-page "Send" button is
  a dead `const ActionButton(text: "Send", …)` with no `onPressed` on develop today
  (`token_info_screen.dart:174`), and there is **no `/send` route or `Send*Screen` anywhere in the
  codebase**. Wiring a send flow (recipient → amount → review → confirm) is build-new, not a re-skin, so
  it is fenced OUT of this phase and deferred to its own phase. The button is re-skinned to the redesign
  but remains non-functional (same as develop). Rationale: the milestone rule is "re-skin, never
  restructure" — Phase 7 must not grow a new capability.
- **D-02: ROADMAP criterion 2's "a send completes end to end" CANNOT be met by Phase 7** and is an
  acknowledged deferral, not a gap to close here. The other half of criterion 2 — "a receive QR scans
  with a real phone camera in both light and dark" — IS in scope and stays.

### Surfaces — drawers vs pages
- **D-03: Keep the existing `ResponsiveDrawer` pattern; re-skin in place. No promotion to full screens.**
  Receive and More stay as drawers (bottom sheet on mobile, side dialog on desktop) — consistent with the
  drawer convention established across phases 3–6. No new routes.

### Token-detail top slot (defaulted — not discussed)
- **D-04: Keep reusing the A2-redesigned `CoinCardRow` for the token-info top slot** rather than a bespoke
  hero. Re-skin consistency with the dashboard Assets panel. (Cross-ref todo:
  "Token-info top slot reuses the A2-redesigned CoinCardRow — review during the token page work.")

### Receive QR
- **D-05: The Receive QR must render on a LIGHT background in BOTH appearance modes** (the finding-16/6
  no-dark-on-dark-QR rule) so a camera can scan it in dark mode.

### Claude's Discretion
- Exact re-skin token choices (GWColors, GWButton variants, spacing) follow the established design system;
  no need to re-decide per-widget.
- Whether finding 37's disabled-More also needs a tooltip/affordance is the planner's call.
</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase scope & ownership
- `.planning/ROADMAP.md` §"Phase 7: Token screens" — goal, the four success criteria, and the **SCOPE
  FENCE** (Markets tab → Phase 16; chart re-skin → Phase 5; only finding-24 is Phase 7's chart work).
- `.planning/ROADMAP.md` §"Surface ownership map" — confirms Phase 7 owns token detail/send/receive/
  address-book only.

### Findings (BEH-01)
- `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` [24] — token chart `setState after dispose`.
- `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` [37] — "More" on a non-GNUS token opens an empty
  drawer; disable the button.

### Requirements
- `.planning/REQUIREMENTS.md` — **SCR-03** (this phase's requirement) and **WIRE-2** (Send is a demo stub
  on Alex's branch; develop's real `signAndSendTransaction` wins — but note D-01: Send is not wired here
  at all).

### Design system
- The `gw_*` primitives + `GWColors` extension (phases 2–6) — the re-skin vocabulary. `ResponsiveDrawer`,
  `ActionButton`, `CryptoAddressQR` are the existing components this phase re-skins.
</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/tokens/token_info_screen.dart` — the phase's primary surface (`/token-info`, `router.dart:244`).
  Contains the action-button `Row` (`:147-199`): Receive (wired), Send (inert `const`), Swap (inert
  `const`, belongs to Phase 8), More (wired, gated).
- `CryptoAddressQR` (`:163`) — the Receive drawer's QR widget; enforce the light-background rule here.
- `ResponsiveDrawer.show<void>(…)` — the drawer mechanism to re-skin (already used by Receive + More).
- `lib/tokeninfo/token_info_loader.dart` + `token_model.g.dart` — token data layer (untouched behavior).
- The embedded token chart is `lib/chart/crypto_live_chart.dart` — **already re-skinned in Phase 5
  (quick task 260721-dws); do NOT re-skin.** Phase 7 touches it only for finding 24.

### Established Patterns
- Re-skin never restructure (milestone rule): keep develop's structure/behavior, apply the skin on top.
- `ResponsiveDrawer` = the app-wide drawer convention (bottom sheet ↔ desktop side dialog at 768px).

### Integration Points
- `/bridge` push from the More drawer (`:189-191`) — behavior preserved.
- `isGnusBridgeEnabled` / `selectedCoin?.balance == 0` gating — preserved; finding 37 tightens the
  non-GNUS case to a disabled button.
</code_context>

<specifics>
## Specific Ideas

- Keep the four-action row (Receive · Send · Swap · More) visually intact and re-skinned; only Receive
  and More are functional. Send + Swap render but do nothing (Swap is Phase 8's).
- QR stays light-on-light for scannability in dark mode.
</specifics>

<deferred>
## Deferred Ideas

- **Real Send flow (recipient → amount → review → confirm, wired to `signAndSendTransaction`)** — its own
  future phase. Build-new, security-sensitive; not a re-skin. This is what makes ROADMAP criterion 2's
  "send completes" unmeetable in Phase 7.
- **Address book** — no `address_book` screen exists in the codebase; building one is build-new, so it is
  fenced OUT of Phase 7 (same logic as Send). Its own future phase. (ROADMAP names it under Phase 7; this
  CONTEXT narrows Phase 7 to the surfaces that actually exist.)
- **Markets tab** — Phase 16 (canonical owner).
- **Token-detail chart re-skin** — Phase 5 (inherited); Phase 7 only does finding 24.
- **Wire real 1H/1D/1W/1M/1Y timeframe ranges into `CryptoLiveChart`** (currently visual-only) — tracked
  todo; a chart feature, not a Phase 7 re-skin item.

### Reviewed Todos (not folded)
- "Token-info top slot reuses the A2-redesigned CoinCardRow — review during the token page work" —
  **acknowledged and folded as D-04** (keep reusing it).
- The chart zoom/pan and timeframe-range todos — reviewed, left deferred (chart is Phase 5's; Phase 7
  only owns finding 24).
</deferred>

---

*Phase: 07-token-screens*
*Context gathered: 2026-07-23*
