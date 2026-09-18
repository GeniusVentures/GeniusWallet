# Phase 29: Fee transparency - Research

**Researched:** 2026-09-18
**Domain:** In-repo Dart/Flutter domain modeling + widget rendering (no external API research needed — CONTEXT.md already settled Squid's fee product; this file is a code-level investigation only)
**Confidence:** HIGH (every claim below is read directly from source this session; no web search was used or needed)

## Summary

This phase has no external unknowns left. CONTEXT.md already answers what Squid sends and why; the
only open question was **what the code currently does with `feeCosts[]`/`gasCosts[]` and exactly
what has to change**. That has now been read end to end: two call sites in
`squid_swap_provider.dart` (one typed, one raw-JSON) each fold `feeCosts` into a single `double`
and discard every entry's `name`; one render site in `route_details_card.dart` sums that double
with `gasUsd` into one `"Fees"` row. Nothing else in the app reads `feeCosts` or `gasCosts`.

The fix is small and additive, matching D-03's "additive field on `SwapQuote`; `feesUsd` can stay."
Add one plain domain type (a "fee line": `name` + `amountUsd`) and one new `SwapQuote` field
(`feeLines`, defaulted to `const []` so no existing constructor call breaks), map `feeCosts[]` into
it at both adapter call sites through one shared private helper, and render it in
`RouteDetailsCard` as N additional rows above (or replacing) today's single `"Fees"` row, keeping a
separate `"Network gas"`-style row for `gasUsd` so criterion 2 (fees visibly distinct from gas) is
satisfied structurally, not by styling. `gasCosts` entries carry **no `name` field at all** — the
generated `GasCost` model has only `type` (`executeCall`/`jitoTipFee`), so gas cannot and should not
be itemized by name; it stays one summed figure, which the roadmap's criterion 2 does not ask to
change.

**Primary recommendation:** Add a `FeeLine`-shaped class next to `SwapQuote` in `swap_quote.dart`
(name + amountUsd, plain class, no Equatable — matches the file's existing convention), thread it
through both `squidQuote`/`squidQuoteFromJson` mapping paths via one new shared private function,
and extract `RouteDetailsCard._row` into a small private `StatelessWidget` while adding the itemized
rows — the extraction is incidental (AGENTS.md forbids new `_build`-style helpers) but the itemized
rows are the actual point.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Fee itemization (map `feeCosts[]` → domain type) | API/Adapter (`SquidSwapProvider`, the only file allowed to know Squid's wire shape) | — | Phase 26's adapter-boundary rule: no Squid type may escape `lib/squid_router/`; mapping happens once, at the adapter |
| Fee/gas display (rows, labels, colour) | Browser/Client (Flutter widget, `RouteDetailsCard`) | — | Pure presentation of already-mapped domain data; no business logic belongs here |
| Domain model (`SwapQuote`, new fee-line type) | Shared domain layer (`lib/swap/`) | — | Consumed by both the adapter (writer) and the widget (reader); belongs to neither alone |

## Package Legitimacy Audit

**Not applicable — this phase installs no new package.** Everything needed (`FeeType`, `FeeCost`,
`GasCost`, `GasCostType`) already exists in the `squidrouter` submodule, which is generated,
already vendored, and explicitly off-limits to modify (AGENTS.md, ROADMAP.md "Constraint: do not
modify the `squidrouter/` submodule"). No `pubspec.yaml` change is required.

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| FEE-02 | "Route details name every fee the route charges, separate from chain gas, before confirmation — nothing merged into one figure, nothing silently deducted" (`REQUIREMENTS.md:198-199`) | Exact code sites and minimal diff identified below; domain type + adapter mapping + widget row plan satisfies all 5 ROADMAP success criteria |
</phase_requirements>

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** FEE-02 only. The phase closes on honest fee itemization, not on a fee existing.
- **D-02:** FEE-01 is not app work and was deferred to the backlog. `RouteRequest` carries no fee
  parameter; there is no lever on our side.
- **D-03:** **Render the fee list generically.** Carry `estimate.feeCosts[]` through the adapter as
  our own domain type and render whatever entries arrive, each with its own name and amount. Do not
  look up a row called "Integrator fee." — Reversibility: reversible — additive field on
  `SwapQuote`; `feesUsd` can stay.
- **D-04:** **Never do fee arithmetic.** Show `toAmount` exactly as the route returns it and show
  fees as their own lines. Nothing anywhere computes `receive = toAmount - fee`. — Reversibility:
  one-way in spirit — this is the phase's core safety property.
- **D-05:** No hard-coded fee label, no hard-coded percentage. Match names **case-insensitively**
  against both `"integrator fee"` and `"service fee"`. `FeeType` admits eight names; Squid's docs
  say integrator and platform fees may be aggregated into `"Service fee"`. An unrecognised name
  still renders.
- **D-06:** The empty case is the **normal** case, not an edge case. Same-chain swaps return
  `feeCosts: []` — gas only. No placeholder row, no `$0.00` line.
- **D-07:** Ship `supergenius-*` (already in `squid.local.json`). Not code-relevant to this phase.

### Carried forward from Phase 26 (not re-litigated)

- No Squid type escapes the adapter. `SquidSwapProvider` is the only file that may name `FeeCost`.
  The itemized fee type is ours, named for the domain, never `Squid*`.
- Mapping happens once, at the adapter. Nothing downstream re-reads `route.estimate.*`.
- The `squidrouter/` submodule is consumed as-is, never modified.
- No visual redesign of the swap screen.

### Claude's Discretion

Row-vs-nested-breakdown layout, wording, and whether amounts read as USD, token or percentage were
not settled in discussion. Pick what reads honestly at phone width in both appearances; the
constraint that matters is D-03/D-06, not the chrome.

### Deferred Ideas (OUT OF SCOPE)

- FEE-01 — Squid enabling the integrator fee (backlog, business item).
- Requesting the 10 RPS production tier.
- Cross-chain swap via Squid (picker widening) — product decision, not this phase.
- Bridge fee treatment (`lib/dashboard/bridge/` never calls Squid) — not code-relevant here.
</user_constraints>

## Standard Stack

No new libraries. This phase is pure Dart domain modeling + a Flutter widget change inside an
existing file, using types the `squidrouter` submodule already generates
(`FeeCost`, `GasCost`, `FeeType`, `GasCostType`) and patterns already established in
`lib/swap/swap_quote.dart` and `lib/squid_router/squid_swap_provider.dart`.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| A plain `FeeLine` class (name + amountUsd) | Carrying the full generated `FeeCost` object through to the widget | Rejected — violates the Phase 26 adapter-boundary rule (`import 'package:squidrouter/...'` would leak past the adapter into `lib/swap/` or the widget) |
| One shared private mapping helper used by both `squidQuote`/`squidQuoteFromJson` | Duplicating the fold logic in both functions | Rejected — CONTEXT.md's own "Reusable Assets" note says "fix the shared shape once"; the two call sites already duplicate `feesUsd`/`gasUsd` and that duplication is exactly what a shared helper avoids growing further |
| Extracting `RouteDetailsCard._row` into a `StatelessWidget` while adding rows | Leaving `_row` as a method and adding a second private method for fee rows | Rejected — AGENTS.md forbids new `_build`-style helpers returning `Widget`; touching `_row` while already in the file is the natural point to fix it, not a second violation |

## Architecture Patterns

### System Architecture Diagram

```
   /v2/route response (JSON)
          │
          ▼
 SquidSwapProvider (adapter — the ONLY file that may know FeeCost/GasCost exist)
   ├─ squidQuote(RouteResponseData)        ─┐
   ├─ squidQuoteFromJson(Map<String,dyn>)  ─┤  BOTH call the same new private
   │                                        │  mapper: feeCosts[] -> List<FeeLine>
   └─ (existing) _sumUsd / _sumUsdRaw  ─────┘  gasCosts[] -> gasUsd (unchanged, no name)
          │
          ▼
   SwapQuote (domain type, lib/swap/swap_quote.dart)
     feesUsd (unchanged) · gasUsd (unchanged) · feeLines: List<FeeLine> (NEW, additive)
          │
          ▼
   RouteDetailsCard (widget, lib/squid_router/route_details_card.dart)
     for each entry in quote.feeLines -> one named row (D-03)
     if quote.feeLines.isEmpty -> render nothing extra (D-06)
     gasUsd -> its own separate row, never merged with a fee line (criterion 2)
```

### Recommended Project Structure

No new files/folders required — every change lands inside three already-existing files plus their
existing test siblings:

```
lib/swap/swap_quote.dart              # + FeeLine class, + SwapQuote.feeLines field
lib/squid_router/squid_swap_provider.dart   # + one shared private mapper, used at :187 and :246
lib/squid_router/route_details_card.dart    # itemized rows + _row extracted to a StatelessWidget
test/squid_router/route_details_card_test.dart   # extended with per-row assertions
test/swap/squid_quote_mapping_test.dart          # extended with feeLines assertions
```

### Pattern 1: Domain type for one itemized fee

**What:** A plain class carrying exactly what D-03 requires: a display name and a USD amount.

**Source (verbatim, current `SwapQuote`, what to match):**
```dart
// lib/swap/swap_quote.dart:29-64 (current, read this session)
class SwapQuote {
  const SwapQuote({
    required this.id,
    required this.exchangeRate,
    required this.priceImpact,
    required this.fromAmount,
    required this.toAmount,
    required this.toAmountMin,
    required this.fromAmountDisplay,
    required this.toAmountDisplay,
    required this.feesUsd,
    required this.gasUsd,
    required this.estimatedDuration,
  });
  ...
  final double feesUsd;
  final double gasUsd;
  final Duration estimatedDuration;

  double get totalCostUsd => feesUsd + gasUsd;
}
```

**Recommended addition** (mechanical extension of the same file, same conventions — const
constructor, named-required params, no `Equatable` under `lib/swap/` confirmed by grep this
session):
```dart
/// One entry from a route's `feeCosts[]`, kept exactly as Squid named it — no
/// enum, because D-05 requires an unrecognised name to still render.
class FeeLine {
  const FeeLine({required this.name, required this.amountUsd});

  final String name;
  final double amountUsd;
}
```
Then on `SwapQuote`: add `this.feeLines = const []` as an **optional, defaulted** field (not
`required`) — see "Why optional, not required" under Common Pitfalls; this is what keeps every
existing direct `SwapQuote(...)` construction in `test/squid_router/swap_submit_test.dart` and
`test/swap/squid_quote_mapping_test.dart` compiling unchanged.

**When to use:** Exactly here — one adapter-owned mapping, one aggregate field. Do not carry
`token`, `percentage`, `gasLimit` or `data` from `FeeCost` — D-03 says "our own domain type," not a
mirror of Squid's shape, and nothing in the locked decisions or the ROADMAP criteria asks for a
per-fee token amount or percentage to be *rendered*. (`percentage` is available on `FeeCost` if a
later plan's UI wants it — Claude's Discretion covers this — but it is not required to close any
criterion.)

### Pattern 2: Adapter mapping — one shared function, two call sites

**Current state, read this session, both call sites shown together because CONTEXT.md's own note
says to fix them once:**

```dart
// lib/squid_router/squid_swap_provider.dart:187-188 (typed path, inside squidQuote)
    feesUsd: _sumUsd(estimate.feeCosts.map((fee) => fee.amountUsd)),
    gasUsd: _sumUsd(estimate.gasCosts.map((gas) => gas.amountUsd)),
```
```dart
// lib/squid_router/squid_swap_provider.dart:246-247 (raw-JSON path, inside squidQuoteFromJson)
    feesUsd: _sumUsdRaw(estimate['feeCosts']),
    gasUsd: _sumUsdRaw(estimate['gasCosts']),
```

**Existing tolerant-parse helpers to copy the convention from** (`squid_swap_provider.dart:256-270`,
read this session, quoted verbatim):
```dart
/// A cost Squid sends as an unparseable string is worth nothing here, not a
/// crash on a screen the user is mid-swap on.
double _sumUsd(Iterable<String> amounts) =>
    amounts.fold(0.0, (sum, usd) => sum + (double.tryParse(usd) ?? 0.0));

/// [_sumUsd] over a raw `feeCosts`/`gasCosts` list. Same rule: a cost that
/// cannot be read is worth nothing, and an absent list is not a failure — a
/// same-chain swap genuinely has no bridge fee.
double _sumUsdRaw(Object? costs) => costs is! List
    ? 0.0
    : _sumUsd(
        costs.map(
          (cost) => cost is Map ? (cost['amountUsd']?.toString() ?? '') : '',
        ),
      );
```

**What to add — one new private mapper used by both call sites**, following the same
tolerant-parse, never-throw convention, and reading `name` off `FeeType` for the typed path (its
wire value is already the human-readable string — e.g. `FeeType.GAS_RECEIVER_FEE.name` maps through
`@BuiltValueEnumConst(wireName: r'Gas receiver fee')`, so the enum's `.name` getter — inherited from
`EnumClass`, which `built_value` backs with the wire name — already yields `"Gas receiver fee"`, not
a Dart-side constant identifier; confirmed by reading `fee_cost.dart`'s serializer, which serializes
`object.name` through `FullType(FeeType)` using the same built-value enum machinery). For the raw
JSON path, `fee['name']?.toString()` is the equivalent. Something in the shape of:

```dart
List<FeeLine> _feeLines(Iterable<({String name, String amountUsd})> costs) => [
  for (final cost in costs)
    FeeLine(name: cost.name, amountUsd: double.tryParse(cost.amountUsd) ?? 0.0),
];
```
called as `_feeLines(estimate.feeCosts.map((f) => (name: f.name.name, amountUsd: f.amountUsd)))` on
the typed path and the equivalent raw-map extraction on the JSON path — the exact record/tuple shape
is an implementation detail the planner/executor can choose; the constraint that matters is **one
function, two call sites**, matching how `_sumUsd`/`_sumUsdRaw` already split typed-vs-raw parsing
but share the final fold.

**`gasCosts` — verified this session, do NOT itemize by name:**
```dart
// squidrouter/lib/src/model/gas_cost.dart:20-42 (GasCost — read this session, full field list)
abstract class GasCost implements Built<GasCost, GasCostBuilder> {
  @BuiltValueField(wireName: r'type')
  GasCostType get type;          // enum: executeCall | jitoTipFee — NOT a display name
  @BuiltValueField(wireName: r'token')
  Token get token;
  @BuiltValueField(wireName: r'gasLimit')
  String get gasLimit;
  @BuiltValueField(wireName: r'amount')
  String get amount;
  @BuiltValueField(wireName: r'amountUsd')
  String get amountUsd;
```
There is **no `name` field on `GasCost` at all** — Braian's probe showing `name` undefined on the
raw JSON gas-cost entries is confirmed at the generated-model level, not just an artifact of one
live response. `GasCostType` (`squidrouter/lib/src/model/gas_cost_type.dart:11-15`) only admits
`executeCall`/`jitoTipFee`, neither of which is a user-facing label. **Recommendation: keep `gasUsd`
as the existing single summed figure and render it as one row, separate from the itemized fee
rows.** This satisfies ROADMAP criterion 2 ("fees and chain gas are visibly distinct") by keeping
them in different rows/sections — it does not require inventing a per-gas-cost label that the wire
format has no field for.

### Pattern 3: Widget rendering

**Current single row, read this session:**
```dart
// lib/squid_router/route_details_card.dart:38-40, 65 (current)
    final fees = '\$${quote.totalCostUsd.toStringAsFixed(2)}';
    ...
          _row(gw, "Fees", fees),
```

**`_row` today (lines 71-108, quoted in full above the fold in this file's own read) is a
`Widget _row(...)` method — the exact `_build`-style helper AGENTS.md forbids for new code**
("Widgets, not helper methods... A helper rebuilds the whole enclosing widget, can't be `const`,
and is invisible to the DevTools inspector"). Since this phase must touch this method anyway to add
N rows, extract it into a small private `StatelessWidget` in the same file (e.g. `_FeeDetailRow`),
carrying `gw`, `label`, `value`, `showDivider`, `valueColor` as constructor fields — a mechanical
`Widget` → `class` conversion of the body already shown above, not a redesign. **Rule of Three
applies to promoting it out of this file, not to the extraction itself** — keep it private to
`route_details_card.dart` unless a third consumer appears elsewhere in the codebase (none does
today).

**Rendering logic to add**, honoring D-03 (generic, one row per entry) and D-06 (empty is normal,
no placeholder):
```dart
for (final fee in quote.feeLines)
  _FeeDetailRow(gw: gw, label: fee.name, value: '\$${fee.amountUsd.toStringAsFixed(2)}'),
// then the existing gas figure, kept separate:
_FeeDetailRow(gw: gw, label: 'Network gas', value: '\$${quote.gasUsd.toStringAsFixed(2)}'),
```
No `if (quote.feeLines.isEmpty)` placeholder branch is needed — an empty list simply contributes
zero widgets to the `Column`'s children, which is D-06's "no placeholder, no `$0.00` line" by
construction, not by an explicit empty-state check. The exact label wording ("Network gas" vs.
keeping "Fees" for gas, vs. some other phrasing) is Claude's Discretion per CONTEXT.md — pick
whatever reads honestly; the requirement is separation, not a specific string.

**`totalCostUsd` (the existing `feesUsd + gasUsd` getter) is not removed** — nothing in the
decisions asks for its removal, and it may still be useful elsewhere (none of `lib/`'s other call
sites currently use it — verified by grep this session, only `route_details_card.dart:40` reads
it — but removing a public getter with no locked instruction to do so is scope creep the "lazy
senior developer" doctrine rejects; leave it and simply stop using it for the row string, or repoint
it if a summary total row is still wanted alongside the itemized ones — Claude's Discretion).

### Anti-Patterns to Avoid

- **Subtracting a fee from `toAmount` anywhere** — explicitly forbidden by D-04. `grep -rn
  'toAmount -' lib/` should stay empty after this phase; verify it does.
- **Hard-coding `"Integrator fee"` or `"Service fee"` as a lookup key** — D-05 forbids this. The
  rendering must iterate `feeLines` generically; there must be no `if (fee.name == 'Integrator
  fee')` branch anywhere.
- **Letting a Squid type escape the adapter** — `FeeType`/`FeeCost`/`GasCost` must not appear in
  `lib/swap/` or `lib/squid_router/route_details_card.dart`. `grep -rn "squidrouter" lib/swap/
  lib/squid_router/route_details_card.dart` must stay empty (excluding the adapter file itself).
- **Making `feeLines` a required constructor param on `SwapQuote`** — this breaks every existing
  direct construction (`swap_submit_test.dart:78-92`, `squid_quote_mapping_test.dart` reads it via
  `squidQuote(...)` so unaffected, but any other direct `SwapQuote(...)` call would need updating for
  no behavioral reason). Default it to `const []`.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| USD currency formatting | A `CurrencyFormatter` class or `intl`'s `NumberFormat.currency` | The existing inline `'\$${value.toStringAsFixed(2)}'` pattern | Confirmed this session (grep across `lib/squid_router/` and `lib/utils/formatters.dart`) — **no USD/currency formatter exists anywhere in the app**; every one of the four existing money-display call sites (`route_details_card.dart:40`, `swap_field.dart:381`, `swap_screen.dart:516` via a different path, `swap_settings_drawer.dart:78,131`) does the same inline `toStringAsFixed(2)`. Introducing a formatter class for this phase would be an abstraction nobody asked for — the lazy-senior-developer doctrine's rung 6 ("Can this be one line? Make it one line") already answers this: keep using the inline pattern |
| Case-insensitive fee-name matching (D-05) | A `Map<String, String>` lookup table keyed by lowercased known names | Nothing — there is no matching to do. D-03 already resolves this: render `fee.name` verbatim, whatever Squid sent. D-05's "case-insensitive matching" only matters if some *later* feature wants to detect a specific fee type (e.g. highlight "the integrator fee" specifically) — nothing in this phase's locked scope requires that; the generic renderer needs no name comparison at all |
| Itemized gas-cost display | A synthetic label derived from `GasCostType` (`executeCall`→"Execution", `jitoTipFee`→"Priority tip") | Keep `gasUsd` as one summed row | `GasCostType` only ever contains `executeCall` for every recorded fixture (Jito tips are Solana-specific and this app's routes are all EVM per the fixtures); inventing a label mapping for a case that has never been observed live is speculative work outside D-03/D-05's scope, which is about `feeCosts`, not `gasCosts` |

**Key insight:** This phase's entire "don't hand-roll" risk is over-building — adding a formatter
class, a name-matching utility, or a gas-cost label table that nothing in the locked decisions asks
for. The lazy-senior-developer doctrine and D-03's genericity both point the same direction: map the
list, render the list, stop.

## Common Pitfalls

### Pitfall 1: Making `feeLines` a required `SwapQuote` field

**What goes wrong:** Every existing direct `SwapQuote(...)` construction outside the adapter
(`test/squid_router/swap_submit_test.dart:78-92`, quoted below) fails to compile.

```dart
// test/squid_router/swap_submit_test.dart:80-92 (read this session, verbatim)
  Future<SwapQuote> quote(SwapQuoteRequest request) async => SwapQuote(
    id: 'q1',
    exchangeRate: '2500',
    priceImpact: '0.02',
    fromAmount: BigInt.parse('1000000000000000000'),
    toAmount: BigInt.parse('2500000000000000000000'),
    toAmountMin: BigInt.parse('2490000000000000000000'),
    fromAmountDisplay: '1',
    toAmountDisplay: '2500',
    feesUsd: 0,
    gasUsd: 0.42,
    estimatedDuration: const Duration(seconds: 20),
  );
```

**Why it happens:** Dart's named-required parameters are compile-time enforced; adding one more
`required` field to a widely-constructed class is a breaking change everywhere it's built directly.

**How to avoid:** Give `feeLines` a default: `this.feeLines = const []`. This is also the literal
instruction in D-03 ("additive field on `SwapQuote`").

**Warning signs:** `flutter analyze` reporting missing-required-argument errors in
`swap_submit_test.dart` or anywhere else `SwapQuote(` is constructed directly (confirmed via grep
this session: only `squid_swap_provider.dart` (2x, via named constructor), `swap_submit_test.dart`
(1x direct), and read-sites in `squid_quote_mapping_test.dart`/`route_wrap_drift_test.dart`/
`live_quote_walk_test.dart` which only read fields, never construct — so the actual blast radius of
a required-field mistake is exactly one file, `swap_submit_test.dart`, but there's no reason to
force that edit at all).

### Pitfall 2: No recorded fixture proves the multi-fee-entry case

**What goes wrong:** A planner assumes `route_response_cross_chain.json` is enough to test "each
entry renders as its own line," writes only a single-entry assertion, and ships code that happens
to work for lists of length 0 or 1 but was never exercised against 2+ entries — the actual case
D-03's "whichever label they return, it renders" and "render whatever entries arrive" language is
guarding against.

**Why it happens:** All four recorded fixtures predate any fee being enabled on either integrator
ID (confirmed live-probe finding in CONTEXT.md, and confirmed structurally this session: see the
table below). No live route currently returns two-or-more `feeCosts` entries to record.

**Measured fixture contents (read this session via each fixture's raw JSON):**

| Fixture | `feeCosts` count | Entries | `gasCosts` count |
|---|---|---|---|
| `route_response.json` | 0 | — | 1 (`executeCall`, $0.01) |
| `route_response_cross_chain.json` | **1** | `"Gas receiver fee"`, $0.48 | 1 (`executeCall`, $0.02) |
| `route_response_executable.json` | 0 | — | 1 (`executeCall`, $0.01) |
| `route_response_wrap.json` | 0 | — | 1 (`executeCall`, $0.00) |

(Note: these dollar figures were captured at a different moment than CONTEXT.md's own probe table,
which recorded $0.91/$0.01 for the same route shape — ETH price and gas price drift between
captures; this is expected and does not affect the design. What matters structurally is unchanged:
exactly one fee entry named `"Gas receiver fee"`, never two.)

**How to avoid:** Do **not** record a new live fixture to get a 2-entry case — no fee is currently
enabled on either integrator ID, so there is no live route to record, and `route_fixture.dart`'s own
doc comments (`"A recorded real /v2/route body"`) make a fabricated multi-fee "recording" dishonest
labeling. Instead, construct a small **inline synthetic JSON map** directly inside the mapping
test (`test/swap/squid_quote_mapping_test.dart` or a new small test) — e.g. a hand-built
`{'route': {'estimate': {..., 'feeCosts': [{'name': 'Integrator fee', 'amountUsd': '0.30', ...},
{'name': 'Gas receiver fee', 'amountUsd': '0.48', ...}]}}}` passed through `squidQuoteFromJson`
directly — to prove the N-entry case. This is cheaper than a fixture file and is honest about being
synthetic rather than recorded. The existing single-entry fixture (`route_response_cross_chain.json`)
is sufficient to prove the 1-entry render path end-to-end (widget test); the synthetic JSON covers
the ≥2-entry generic-list guarantee that no live capture can currently produce.

**Warning signs:** A widget test file that only ever pumps `sameChainRoute` (0 fees) and
`crossChainRoute` (1 fee) and never asserts two distinctly-named rows rendering side by side.

### Pitfall 3: Treating `RouteDetailsCard`'s `_row` extraction as in-scope for a design pass

**What goes wrong:** Scope creep — turning the mechanical `_row` → `StatelessWidget` conversion into
an opportunity to also restyle the card, adjust spacing, or promote the new widget into
`lib/components/cards/`.

**Why it happens:** The extraction is genuinely necessary (AGENTS.md's rule), which can read as
license to do more while already in the file.

**How to avoid:** CONTEXT.md is explicit: "No visual redesign of the swap screen" (carried from
Phase 26) and this phase's own scope is fee itemization, not a card redesign. Keep the extracted
widget private to `route_details_card.dart`; do not export or promote it (Rule of Three: two
occurrences — the existing rows plus the new fee rows all live in one file already — do not justify
a shared component).

**Warning signs:** A diff touching files outside `lib/swap/swap_quote.dart`,
`lib/squid_router/squid_swap_provider.dart`, `lib/squid_router/route_details_card.dart`, and their
test siblings.

## Code Examples

### Verified current mapping code (both call sites, quoted exactly as they exist today)

```dart
// lib/squid_router/squid_swap_provider.dart:165-193 — squidQuote (typed path)
SwapQuote squidQuote(RouteResponseData route) {
  final estimate = route.route.estimate;
  final fromAmount = BigInt.parse(estimate.fromAmount);
  final toAmount = BigInt.parse(estimate.toAmount);

  return SwapQuote(
    id: route.route.quoteId,
    exchangeRate: estimate.exchangeRate,
    priceImpact: estimate.aggregatePriceImpact,
    fromAmount: fromAmount,
    toAmount: toAmount,
    toAmountMin: BigInt.parse(estimate.toAmountMin),
    fromAmountDisplay: formatTokenAmount(fromAmount, estimate.fromToken.decimals.toInt()),
    toAmountDisplay: formatTokenAmount(toAmount, estimate.toToken.decimals.toInt()),
    feesUsd: _sumUsd(estimate.feeCosts.map((fee) => fee.amountUsd)),
    gasUsd: _sumUsd(estimate.gasCosts.map((gas) => gas.amountUsd)),
    estimatedDuration: Duration(seconds: estimate.estimatedRouteDuration.round()),
  );
}
```

```dart
// lib/squid_router/squid_swap_provider.dart:204-254 — squidQuoteFromJson (raw path, abridged
// to the relevant lines; full function reads the estimate map defensively with amount()/decimalsOf())
  return SwapQuote(
    id: route['quoteId']?.toString() ?? '',
    exchangeRate: estimate['exchangeRate']?.toString() ?? '',
    priceImpact: estimate['aggregatePriceImpact']?.toString() ?? '',
    fromAmount: fromAmount,
    toAmount: toAmount,
    toAmountMin: amount('toAmountMin'),
    fromAmountDisplay: formatTokenAmount(fromAmount, decimalsOf('fromToken')),
    toAmountDisplay: formatTokenAmount(toAmount, decimalsOf('toToken')),
    feesUsd: _sumUsdRaw(estimate['feeCosts']),
    gasUsd: _sumUsdRaw(estimate['gasCosts']),
    estimatedDuration: Duration(seconds: (estimate['estimatedRouteDuration'] as num? ?? 0).round()),
  );
```

### Existing widget test pattern to extend (quoted in full, `test/squid_router/route_details_card_test.dart`)

```dart
Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(body: child),
);

Future<void> _pumpCard(WidgetTester tester, String fixture) async {
  await tester.pumpWidget(
    _host(
      RouteDetailsCard(
        quote: squidQuote(loadRouteFixture(fixture)),
        fromAmount: '1',
        toAmount: '0.757304',
        fromSymbol: 'GNUS',
        toSymbol: 'USDC',
        slippage: '0.5',
      ),
    ),
  );
}
```
Extend by (a) parameterizing `_host`'s `GWColors` to loop dark/light (see Both-Appearance pattern
below) and (b) adding assertions like `expect(find.text('Gas receiver fee'), findsOneWidget);
expect(find.text('\$0.48'), findsOneWidget);` against `crossChainRoute`.

### Both-appearance test pattern (established elsewhere in the repo, not yet used in this file)

Read this session from `test/dashboard/transaction_row_test.dart:103-127`:
```dart
for (final appearance in {
  'dark': GWColors.dark(),
  'light': GWColors.light(),
}.entries) {
  for (final entry in cases.entries) {
    testWidgets(
      'row fits: ${entry.key} (${appearance.key})',
      (tester) async {
        await tester.pumpWidget(_host(entry.value, gw: appearance.value));
        expect(tester.takeException(), isNull);
      },
    );
  }
}
```
`route_details_card_test.dart`'s current `_host` hard-codes `GWColors.dark()` only
(`route_details_card_test.dart:13-16`). Parameterizing it with an optional `GWColors gw =
GWColors.dark()` default-argument, then wrapping the existing three test bodies in the same
dark/light `.entries` loop, is the minimal extension — no new test infrastructure file needed.
`contrastRatio` (`test/theme/theme_contrast_test.dart:20-27`, re-exported and reused by
`test/dashboard/transaction_badge_test.dart` and `transaction_filter_rail_test.dart` via `show
contrastRatio`) is the reusable WCAG helper if a specific contrast assertion is wanted for the new
fee-row text colour — not strictly required since the rows reuse `gw.textPrimary`/`gw.textSecondary`
exactly as the existing rows do, which are already the AA-verified getters per `29-PATTERNS.md`'s
own reading of `gw_colors.dart:129-135,301-303`.

## State of the Art

Not applicable — no external library or API surface changed. The generated `squidrouter` submodule
is pinned and unmodifiable; the "state of the art" for this phase is entirely about what the
existing code does today (documented above) versus the minimal diff needed.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `FeeType.NAME.name` (the `EnumClass` getter) yields the human-readable wire string (e.g. `"Gas receiver fee"`) rather than a Dart-side constant identifier like `"GAS_RECEIVER_FEE"` | Pattern 2 (Adapter mapping) | If wrong, the typed-path mapper would need to read the wire name a different way (e.g. via the serializer or a `FeeType`→`String` lookup); this is inferred from how `built_value`'s `EnumClass` + `@BuiltValueEnumConst(wireName: ...)` typically expose the wire string through `.name`, but was not proven by executing code this session (no Dart runtime was invoked) — **the planner/executor should add one quick assertion in the adapter test confirming `fee.name.name == 'Gas receiver fee'` against the real `crossChainRoute` fixture before relying on it**, since the raw-JSON path (`fee['name']?.toString()`) is unambiguous and already proven, but the typed path's exact accessor is not |

**All other claims in this research were verified by reading source files directly this session**
(`squid_swap_provider.dart`, `swap_quote.dart`, `route_details_card.dart`, `fee_cost.dart`,
`gas_cost.dart`, `gas_cost_type.dart`, `fee_type.dart`, all four fixture JSON files,
`route_details_card_test.dart`, `route_parse_test.dart`, `route_fixture.dart`,
`squid_quote_mapping_test.dart`, `swap_submit_test.dart`, `transaction_row_test.dart`,
`theme_contrast_test.dart`, `lib/utils/formatters.dart`, `swap_screen.dart`) — no training-data
guesses about this codebase's shape were needed beyond A1 above.

## Open Questions

1. **Does `FeeType.name` (the enum accessor) return the wire string or the Dart constant name?**
   - What we know: the raw-JSON path is unambiguous (`fee['name']` is literally the wire string,
     confirmed against `route_response_cross_chain.json`'s raw content: `"name": "Gas receiver
     fee"`). The typed path goes through `built_value`'s generated `FeeType` enum, which is
     conventionally exposed the same way in every other enum this codebase already reads (e.g.
     `GasCostType`, same pattern) — but this specific `.name` accessor was not executed this
     session.
   - What's unclear: whether `FeeType`'s generated `.name` getter (from `EnumClass`) returns the
     `wireName` string or something else, without running the code.
   - Recommendation: the executor's first task in this phase should include one fast unit
     assertion — `expect(FeeType.GAS_RECEIVER_FEE.name, 'Gas receiver fee')` — before building the
     itemized mapper on top of it. If it fails, fall back to Squid's serializer
     (`standardSerializers.serialize(fee.name, specifiedType: FullType(FeeType))`) to get the wire
     string, or simply route the typed path through the same raw-JSON style extraction used
     elsewhere in this file (the adapter already mixes typed and raw approaches per-endpoint, so
     this would not be a new pattern).

## Runtime State Inventory

Not applicable — this is not a rename/refactor/migration phase. No stored data, live service
config, OS-registered state, secrets, or build artifacts reference `feeCosts`/`gasCosts` naming
today; this phase adds a new field, it does not rename or migrate an existing one.

## Environment Availability

Not applicable — this phase has no external tool/service/runtime dependency. It reads a submodule
already vendored in the repo and writes Dart source + tests; `flutter analyze`/`flutter test` are
already-available project tooling (per `AGENTS.md`'s standing instruction to run them before
calling anything done — Flutter SDK is not on `PATH` by default in this environment per user
memory, so the executor must resolve it the same way prior phases have).

## Validation Architecture

`workflow.nyquist_validation` is `true` in `.planning/config.json` (confirmed this session) — this
section is required.

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with the Flutter SDK; already used throughout `test/squid_router/`) |
| Config file | none — no `dart_test.yaml`/custom config found; standard `flutter test` discovery |
| Quick run command | `flutter test test/squid_router/route_details_card_test.dart test/swap/squid_quote_mapping_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| FEE-02 (criterion 1: every `feeCosts[]` entry renders as its own named line) | `RouteDetailsCard` pumped with `crossChainRoute` shows a row labeled `"Gas receiver fee"` and its own `$0.48` value, not merged into the totals row | widget | `flutter test test/squid_router/route_details_card_test.dart` | ✅ file exists, extend with new `expect`s |
| FEE-02 (criterion 1, N≥2 entries) | A synthetic 2-entry `feeCosts[]` JSON maps to 2 `FeeLine`s with distinct names, each surviving through to distinct rendered text | unit + widget | new test in `test/swap/squid_quote_mapping_test.dart` (mapping) + `route_details_card_test.dart` (rendering) | ❌ Wave 0 — needs the synthetic JSON body (see Pitfall 2) |
| FEE-02 (criterion 2: fees visibly distinct from gas) | The card renders the itemized fee row(s) and a separate gas row; asserting both `"Gas receiver fee"`/`"$0.48"` AND a distinct gas-labeled row/value both find exactly one widget, never merged into a single string | widget | `flutter test test/squid_router/route_details_card_test.dart` | ✅ extend existing file |
| FEE-02 (criterion 3: empty `feeCosts` reads correctly) | `sameChainRoute` (0 entries) renders no fee rows and no `$0.00` line, only the gas row | widget | existing test in `route_details_card_test.dart` already pumps `sameChainRoute` — extend with a `findsNothing` assertion for any fee-row text | ✅ |
| FEE-02 (criterion 4: no arithmetic on `toAmount`) | `grep -rn 'toAmount -' lib/` returns nothing; `toAmount`/`toAmountDisplay` pass through unchanged | static grep + existing `squid_quote_mapping_test.dart` assertions on `toAmountDisplay` (already present, unaffected by this phase) | `grep -rn 'toAmount -' lib/` (manual, not a `flutter test` target) | ✅ existing tests already cover the mapping is unchanged |
| FEE-02 (criterion 5: no hard-coded label/percentage) | Rendering iterates `feeLines` generically; a fee named something other than `"Integrator fee"`/`"Gas receiver fee"` (e.g. `"Boost fee"`) still renders via the same code path | unit | synthetic JSON test with an uncommon `FeeType` name (e.g. `"Boost fee"`) through `squidQuoteFromJson` | ❌ Wave 0 — same synthetic fixture as above can cover this with a third entry |

### Sampling Rate
- **Per task commit:** `flutter test test/squid_router/route_details_card_test.dart test/swap/squid_quote_mapping_test.dart`
- **Per wave merge:** `flutter test`
- **Phase gate:** Full suite green before `/gsd-verify-work`; also run `flutter analyze` (0 errors is
  a gate, never evidence per `ROADMAP.md`'s standing "Verification reality" note) and
  `bash tool/check_brace_style.sh` / `bash tool/check_raw_colors.sh` since this phase touches
  conditionals and a themed widget.

### Wave 0 Gaps
- [ ] A synthetic (not recorded) multi-entry `feeCosts[]` JSON body, inline in a test file, covering
  ≥2 named entries plus one uncommon `FeeType` name — needed for criteria 1 and 5. No new fixture
  file under `test/squid_router/fixtures/` is needed or appropriate (see Pitfall 2) — an inline
  `Map<String, dynamic>` literal in the test file is the honest, minimal approach.
- [ ] One quick assertion resolving Open Question 1 (`FeeType.GAS_RECEIVER_FEE.name` value) before
  the typed-path mapper is written against it.

## Security Domain

`security_enforcement` is `true` in `.planning/config.json` (confirmed this session) — this section
is required.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | This phase touches no auth surface |
| V3 Session Management | no | No session state involved |
| V4 Access Control | no | No access-control decision involved |
| V5 Input Validation | yes | The fee-mapping code parses untrusted API response data (`fee['amountUsd']`, `fee['name']`) — the existing `double.tryParse(...) ?? 0.0` tolerant-parse pattern (already used by `_sumUsd`/`_sumUsdRaw`) must be reused for the new per-line mapping, never a throwing `double.parse` or a force-cast, since a malformed or absent field must not crash a screen the user is mid-swap on (this is already the file's own stated design principle, quoted above) |
| V6 Cryptography | no | No key material, no secrets — `FeeCost`/`GasCost` carry no wallet or key data (confirmed by reading both models this session: fields are `name`/`description`/`percentage`/`token`/`amount`/`amountUsd`/`gasLimit`/`logoURI`/`data`, none of which is secret material) |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Untrusted numeric string from an external API rendered without validation, causing a crash or a misleading `$0.00`/exception mid-swap | Denial of Service (availability) | Reuse the existing `double.tryParse(...) ?? 0.0` tolerant-parse convention for every new field read off `feeCosts[]`/`FeeCost`; never `double.parse` (throwing) or force-unwrap a nullable field from the wire |
| A fee amount silently netted into another figure, masking what the user is actually being charged | Repudiation / Tampering (the display no longer matches what was actually charged) | D-04 already forbids this outright — the phase's core safety property. No code path may compute `toAmount - fee` anywhere; verify with `grep -rn 'toAmount -' lib/` before closing the phase |

## Sources

### Primary (HIGH confidence — read directly this session)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\lib\squid_router\squid_swap_provider.dart` (full file)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\lib\swap\swap_quote.dart` (full file)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\lib\squid_router\route_details_card.dart` (full file)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\lib\squid_router\squid_util.dart` (full file)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\squidrouter\lib\src\model\fee_cost.dart`,
  `fee_type.dart`, `gas_cost.dart`, `gas_cost_type.dart` (full files)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\squidrouter\doc\FeeCost.md`
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\squidrouter\lib\src\model\estimate.dart` (field list, lines 31-79)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\test\squid_router\fixtures\route_response*.json` (all four, `feeCosts`/`gasCosts` contents extracted this session)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\test\squid_router\route_details_card_test.dart`, `route_fixture.dart`, `route_parse_test.dart` (full files)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\test\swap\squid_quote_mapping_test.dart` (full file)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\test\squid_router\swap_submit_test.dart` (relevant construction site)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\test\dashboard\transaction_row_test.dart`, `test/theme/theme_contrast_test.dart` (both-appearance test pattern)
- `C:\Users\User\Documents\Projects\GNUS\GeniusWallet\lib\utils\formatters.dart` (confirmed no USD formatter exists)
- `.planning\phases\29-fee-transparency\29-CONTEXT.md`, `.planning\ROADMAP.md` (Phase 29 + Phase 26 sections), `.planning\REQUIREMENTS.md` (FEE-02), `.planning\phases\26-swap-that-actually-swaps\26-CONTEXT.md`, `.planning\phases\29-fee-transparency\29-PATTERNS.md`, `.planning\config.json`

### Secondary (MEDIUM confidence)
- None used — no web/docs lookups were needed for this phase; all facts were code-local.

### Tertiary (LOW confidence)
- A1 in the Assumptions Log — `FeeType.name`'s exact runtime value, inferred from `built_value`
  conventions rather than executed.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new stack; existing conventions read directly
- Architecture: HIGH — adapter boundary and mapping sites read line-by-line
- Pitfalls: HIGH — each pitfall traced to a specific file/line read this session, except A1 which is explicitly flagged LOW and given a one-line verification step

**Research date:** 2026-09-18
**Valid until:** Stable until the `squidrouter` submodule is regenerated (out of this phase's
control) or Squid enables a fee on either integrator ID (FEE-01, backlog) — neither is expected
within 30 days.
