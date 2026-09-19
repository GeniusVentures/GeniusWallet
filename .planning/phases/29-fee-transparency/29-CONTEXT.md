---
phase: 29
name: Fee transparency
status: unblocked
created: 2026-09-18
---

# Phase 29: Fee transparency - Context

**Gathered:** 2026-09-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Route details on `/swap` name every fee the route charges and keep them separate from chain gas,
so the user sees what they are paying before confirming.

Re-scoped on 2026-09-18 from "Integrator fee (~3% via the integratorId)". FEE-01 left for the
backlog as a business item; this phase owns FEE-02 alone. Nothing here depends on Squid answering.

</domain>

<decisions>
## Implementation Decisions

### What the phase is

- **D-01:** FEE-02 only. The phase closes on honest fee itemization, not on a fee existing.
  It is worth doing on its own merits: today a cross-chain quote renders one `$0.92` that merges
  Axelar's `"Gas receiver fee"` ($0.91) with chain gas ($0.01) — two unlike costs as one number,
  with no integrator fee anywhere in the picture.
- **D-02:** FEE-01 is not app work and was deferred to the backlog. Squid configures the integrator
  fee server-side against the integrator ID; `RouteRequest` carries no fee parameter, and
  `customParams` carries only `jitoTipFeeInLamports`. There is no lever on our side.

### How the fees render

- **D-03:** **Render the fee list generically.** Carry `estimate.feeCosts[]` through the adapter as
  our own domain type and render whatever entries arrive, each with its own name and amount. Do not
  look up a row called "Integrator fee". This is what makes all three of Squid's unanswered
  questions irrelevant to the code: whichever label they return, it renders.
  — **Reversibility:** reversible — additive field on `SwapQuote`; `feesUsd` can stay.
- **D-04:** **Never do fee arithmetic.** Show `toAmount` exactly as the route returns it and show
  fees as their own lines. Nothing anywhere computes `receive = toAmount - fee`. The fee lines and
  the receive figure then agree *by construction*, because both come from one response — and
  netted-vs-charged-on-top stops being a correctness question.
  — **Reversibility:** one-way in spirit — reintroducing arithmetic later silently reopens the
  disagreement this decision exists to prevent; it is the phase's core safety property.
- **D-05:** No hard-coded fee label, no hard-coded percentage. Match names **case-insensitively**
  against both `"integrator fee"` and `"service fee"`. `FeeType` admits eight names, v1 docs used a
  capital F, and Squid's docs say integrator and platform fees may be aggregated into
  `"Service fee"`. An unrecognised name still renders.
- **D-06:** The empty case is the **normal** case, not an edge case. Same-chain swaps return
  `feeCosts: []` — gas only. No placeholder row, no `$0.00` line.

### Integrator ID

- **D-07:** Ship `supergenius-*` (the value already in `squid.local.json`). We hold two working IDs;
  the newer `gnus.ai-wallet-*` was rejected because Phase 26's verified mainnet walk was executed
  against `supergenius-*` and switching would strand that evidence. BD must name this ID explicitly
  when asking Squid to enable the fee, or it lands on the wrong one.
  — **Reversibility:** reversible — one gitignored value; never commit either ID.

### Carried forward from Phase 26 (not re-litigated)

- No Squid type escapes the adapter. `SquidSwapProvider` is the only file that may name `FeeCost`.
  The itemized fee type is ours, named for the domain.
- Mapping happens once, at the adapter. Nothing downstream re-reads `route.estimate.*`.
- The `squidrouter/` submodule is consumed as-is, never modified.
- No visual redesign of the swap screen.

### Claude's Discretion

Row-vs-nested-breakdown layout, wording, and whether amounts read as USD, token or percentage were
not settled in discussion. Pick what reads honestly at phone width in both appearances; the
constraint that matters is D-03/D-06, not the chrome.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Phase inputs
- `.planning/ROADMAP.md` → `### Phase 29: Fee transparency` — goal and the five success criteria
- `.planning/REQUIREMENTS.md` → `### Fee Transparency (FEE)` — FEE-02; FEE-01 under "Beyond v2.0"
- `.planning/phases/26-swap-that-actually-swaps/26-CONTEXT.md` — the adapter-boundary rule, the
  integrator-ID handling, and the original Squid question list

### Code this phase touches
- `lib/squid_router/squid_swap_provider.dart:187` — where `feeCosts[]` collapses into one double
  and each entry's `name` is lost
- `lib/squid_router/route_details_card.dart:65` — the single `"Fees"` row, fed by `totalCostUsd`
- `lib/swap/swap_quote.dart:57-63` — `feesUsd`, `gasUsd`, `totalCostUsd`
- `test/squid_router/fixtures/route_response*.json` — four recorded routes; none contains an
  integrator fee, all predate any fee being enabled
- `test/squid_router/route_details_card_test.dart` — existing figure tests to extend

### Wire format (authoritative, generated from Squid's OpenAPI spec)
- `squidrouter/lib/src/model/fee_type.dart` — the eight legal `FeeCost.name` values
- `squidrouter/doc/FeeCost.md` — per-entry shape: `name`, `description`, `percentage?`, `token`,
  `amount`, `amountUsd`
- `squidrouter/doc/RouteRequest.md` — confirms no fee parameter exists
- `squidrouter/lib/src/api.dart:15` — base URL is pinned, not configurable

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `RouteDetailsCard._row(...)` already renders a label/value/divider row — the itemized lines are
  more of these, not a new component. (Note it is a `_build`-style helper returning a `Widget`,
  which the Dart standards disallow for new code; extracting a `StatelessWidget` while touching it
  is in the spirit of the rule, but is not itself the phase's job.)
- `squidQuoteFromJson` and the typed adapter path both already read `feeCosts` — two call sites,
  `squid_swap_provider.dart:187` and `:246`. Both need the same change; fix the shared shape once.

### Established Patterns
- Colours and spacing come from `Theme.of(context).extension<GWColors>()`; no raw `Colors.*`
  outside `lib/theme/`. CI enforces this via `tool/check_raw_colors.sh`.
- Every `if` is braced with the body on its own line — `tool/check_brace_style.sh` enforces it.

### Integration Points
- `SwapQuote` gains the itemized list; `RouteDetailsCard` consumes it. Nothing else should need to
  change — the fee data does not leave the card.

</code_context>

<specifics>
## Specific Ideas

Braian's framing, verbatim in intent: *"we will need to do UI changes to include the fee from Squid
not just the fee from the blockchain so we are transparent on it."* Service fees and network gas are
different things and must read as different things.

### Measured evidence (live, read-only, 2026-09-18)

| Route | `feeCosts` | Note |
|---|---|---|
| Base ETH → Base USDC (same-chain) | `[]` | gas only — the normal case |
| Base ETH → Ethereum USDC | `[{ name: "Gas receiver fee", amountUsd: 0.91 }]` | displayed today merged with $0.01 gas as `$0.92` |

Both integrator IDs, same route seconds apart: `toAmount` 7678339 vs 7674664 — a 0.048% spread,
i.e. ETH price drift, not a fee. A 3% fee would move it ~230,000 units. **No fee is configured on
either ID**, proven by output amount rather than by a missing field.

Re-running that same two-ID comparison after Squid enables the fee is the only way to settle
whether `toAmount` is netted — and D-04 means the answer cannot break the display either way.

</specifics>

<deferred>
## Deferred Ideas

- **FEE-01 — Squid enables the integrator fee.** Backlog, business item. Three answers owed:
  whether the v1 "1% soft limit per tx" still caps us below the ~3% wanted; whether the response
  exposes `"Integrator fee"` or aggregates into `"Service fee"`; and whether `toAmount` is netted.
  Nothing ships in the app when it lands — D-03 and D-05 make it a no-op.
- **Request the 10 RPS production tier.** Both IDs are on the 1 RPS default; probing hit
  `429 RATE_LIMIT` within two calls. Carried over from Phase 26, still open.
- **Cross-chain swap via Squid.** The swap is same-chain only because both token pickers draw from
  the selected network's catalogue (`swap_screen.dart:212-223`). `SwapQuote` and the adapter already
  carry `fromChainId`/`toChainId` separately and cross-chain routes return HTTP 200 today. Widening
  the picker would give the app two overlapping cross-chain paths with different economics — Squid's
  route and the native GNUS bridge. A product decision, not this phase.
- **Bridge fee treatment.** `lib/dashboard/bridge/` is GNUS-only burn→mint and never calls Squid, so
  no integrator fee can reach it. Relevant to revenue modelling, not to code.

### Reviewed Todos (not folded)

`todo.match-phase 29` returned 66 matches, all scored on keyword noise ("user", "walk", "list") and
none about fees or swaps. Reviewed as a set and not folded; no fee-related todo exists.

</deferred>

---

*Phase: 29-fee-transparency*
*Context gathered: 2026-09-18*
