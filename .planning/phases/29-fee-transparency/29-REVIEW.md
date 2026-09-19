---
phase: 29-fee-transparency
reviewed: 2026-09-18T16:36:07Z
depth: deep
files_reviewed: 7
files_reviewed_list:
  - lib/swap/swap_quote.dart
  - lib/squid_router/squid_swap_provider.dart
  - lib/squid_router/route_details_card.dart
  - test/squid_router/route_details_card_test.dart
  - test/squid_router/route_wrap_drift_test.dart
  - test/squid_router/route_fixture.dart
  - test/swap/squid_quote_mapping_test.dart
findings:
  critical: 0
  warning: 2
  info: 0
  total: 2
status: resolved
---

# Phase 29: Code Review Report

**Reviewed:** 2026-09-18T16:36:07Z
**Depth:** deep
**Files Reviewed:** 7
**Status:** issues_found

## Summary

Reviewed the diff `6b1981bb..HEAD` on `phase-29-integrator-fee` against `29-CONTEXT.md`'s locked
decisions (D-03 through D-06) and `AGENTS.md`'s enforced rules.

The core correctness properties hold. D-04 (no fee arithmetic) is respected: nothing computes
`toAmount - fee` anywhere in `swap_screen.dart` or the adapter; `toAmount`/`toAmountDisplay` are
shown exactly as the route returns them, and fee/gas lines are rendered as independent figures
sourced from the same response. The production mapping path (`squidQuoteFromJson`, the only one
`SquidSwapProvider.quote` calls) degrades tolerantly on every malformed input traced: a non-list
`feeCosts`, a non-map entry, a missing or unparseable `amountUsd`, and an unrecognised fee name all
resolve to either an empty list or a rendered-verbatim line, never a thrown exception — confirmed
against the wire shape in `squidrouter/lib/src/model/fee_cost.dart` and exercised by
`squid_quote_mapping_test.dart`. `FeeLine`/`SwapQuote` carry no key- or seed-derived data, never
reach a Bloc/Cubit state class, and are never logged or stringified. `route_details_card.dart`'s new
`_DetailRow` is a proper `StatelessWidget` (not a `_buildFoo` helper), reads colours only via
`Theme.of(context).extension<GWColors>()`, and every `if` in the diff is either correctly braced
(test file) or a Dart collection-`if` inside a list literal (no braces applicable). No plan/phase
numbers or test-file names leaked into source comments.

Two issues found, both Warning-level — a latent behavioural gap in the currently-unused typed
mapping path, and dead code the phase's own doctrine says should have been deleted rather than left
in place.

## Warnings

### WR-01: The typed mapping path throws on any fee name outside the pinned eight, silently breaking D-05's "unrecognised name still renders" guarantee

**File:** `lib/squid_router/squid_swap_provider.dart:165-194` (`squidQuote`), fed by
`squidrouter/lib/src/model/fee_type.g.dart:100-107`

**Issue:** D-05 requires that "an unrecognised name still renders." That promise holds for the
production path (`squidQuoteFromJson` → `_feeLinesRaw`, verified by
`squid_quote_mapping_test.dart:82-90`, "a fee name the wire schema does not list still renders
verbatim"). It does **not** hold for the typed path (`squidQuote` → `RouteResponseData`), which
`SwapProvider.quote` no longer calls directly but which the file still exports and documents as the
mapping's source of truth for tests ("Public so the recorded fixtures can prove the mapping").

`FeeCost.name` deserializes through the generated `_$FeeTypeSerializer.deserialize`
(`fee_type.g.dart:100-104`), which falls back to the raw wire string for any name not in its
`_fromWire` map (`_fromWire[serialized] ?? (serialized is String ? serialized : '')`), then hands
that string to `FeeType.valueOf` → `_$valueOf` (`fee_type.g.dart:17-35`), whose `default:` branch is
`throw ArgumentError(name)`. So the moment Squid returns any fee name outside the eight pinned
constants — which the context doc explicitly anticipates ("Squid's docs say integrator and platform
fees may be aggregated into `Service fee`", itself one of the eight, but nothing guarantees Squid
never adds a ninth) — `standardSerializers.deserializeWith(RouteResponseData.serializer, ...)` throws
before `squid_swap_provider.dart:189`'s `_feeLines(estimate.feeCosts)` ever runs. This is not
exercised by any test: `route_wrap_drift_test.dart`'s "the raw mapper agrees with the generated one"
comparison (lines 66-98) only runs `sameChainRoute` and `crossChainRoute`, both of which carry only
recognised names, so the divergence between the two paths on an unrecognised name is invisible to
the suite that claims to prove they agree.

Currently this is contained: `SquidSwapProvider.quote` (line 32) calls only `squidQuoteFromJson`, so
no live swap can hit this. But the function is public, documented as authoritative, and the file's
own comment block explains the raw path exists only to route around an *unrelated* deserialization
gap (`WrapDetails`) — nothing in the code signals that the typed path also silently regressed D-05.
If a future fix to the generated client (or a revert to the typed path once the wrap issue is fixed
upstream) reintroduces `squidQuote` into the live call path, a single unrecognised fee name from
Squid becomes an uncaught crash mid-swap-quote, not a rendered line.

**Fix:** Either delete the typed `squidQuote`/`RouteResponseData` path now that
`squidQuoteFromJson` is what production actually uses (matches this project's "deletion over
addition" doctrine and removes the two-path drift risk entirely), or, if it must stay for fixture
provenance, make its fee mapping tolerant the same way the raw path is:

```dart
List<FeeLine> _feeLines(Iterable<FeeCost> costs) => [
  for (final cost in costs)
    _feeLine(_feeTypeLabel(cost.name), cost.amountUsd),
];

String _feeTypeLabel(FeeType name) {
  try {
    return standardSerializers.serializeWith(FeeType.serializer, name) as String;
  } catch (_) {
    return name.name;
  }
}
```

This alone does not fully close the gap, since the *deserialization* of `RouteResponseData` itself
(not `_feeLines`) is what throws on an unrecognised wire name — the actual fix needs to happen
before `squidQuote` is ever called with such a route, e.g. by not routing unrecognised-fee-name
responses through the typed model at all. Deleting the dead path sidesteps the question entirely.

### WR-02: `feesUsd`, `totalCostUsd`, `_sumUsd`, and `_sumUsdRaw` are now dead in production

**File:** `lib/swap/swap_quote.dart:48,67,78`; `lib/squid_router/squid_swap_provider.dart:187,247,260-272`

**Issue:** Before this phase, `route_details_card.dart` rendered `quote.totalCostUsd` as the single
"Fees" row. That row is gone — replaced by one row per `feeLines` entry plus a separate
`quote.gasUsd` row (`route_details_card.dart:64-73`). Grepping all of `lib/` for `.feesUsd` and
`.totalCostUsd` after the change turns up only their own declarations and the two adapter call sites
that compute them; no widget, screen, or bloc reads either value. `swap_screen.dart:516` reads
`fetchedQuote?.gasUsd` directly and was never touched by this phase. `_sumUsd`/`_sumUsdRaw` exist
solely to feed `feesUsd`, which nothing downstream consumes — and both now duplicate work
`_feeLines`/`_feeLinesRaw` already do by walking the same `feeCosts` collection a second time.

The project's own doctrine (`AGENTS.md`: "Deletion over addition... this project's doctrine is
deletion over addition") calls for removing code once its last caller is gone, and the phase's own
review brief flagged this exact scenario as something to check for. Left in place, `feesUsd` is a
public field on `SwapQuote` that every call site must still populate for no functional reason, and a
future reader has no way to tell whether it is intentionally kept for an API consumer that doesn't
exist yet or simply forgotten.

**Fix:** Delete `feesUsd`, `totalCostUsd`, `_sumUsd`, and `_sumUsdRaw`, and update the handful of
tests that assert on them (`squid_quote_mapping_test.dart:35-58`, `route_wrap_drift_test.dart:59,78`,
`swap_submit_test.dart:90`) to assert on `feeLines` and `gasUsd` instead — which is what a user
actually sees. If a future screen genuinely needs a combined total, it can be derived from
`feeLines.fold(0.0, (sum, f) => sum + f.amountUsd) + gasUsd` at the point of use rather than carried
as a field nothing reads today.

---

_Reviewed: 2026-09-18T16:36:07Z_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: deep_


---

## Resolution — 2026-09-18

Both warnings were acted on. Each was accurate in substance and overstated in scope; the
corrections are recorded here because the narrower version is the one worth remembering.

### WR-01 — resolved by `02d86bfd`

Accurate: nothing pinned the typed path's rejection of an unrecognised fee name, and production
is unaffected only because it reads the raw path.

Overstated: the existing comparison does not claim universal parity — it is named *"the raw
mapper agrees with the generated one where both can read"* and its comment scopes itself to
fixtures the model can parse. It was honest about its limits.

Fix: a case in `route_wrap_drift_test.dart` renames a fee in a real fixture body and asserts
the generated deserializer rejects the whole response, while `squidQuoteFromJson` carries the
name through verbatim. The asymmetry is now recorded rather than incidental, so a later switch
to the typed path cannot turn an unknown fee into a crashed swap unnoticed.

### WR-02 — resolved by `cf2b9608`

Accurate: `feesUsd` and `totalCostUsd` lost their only consumer when the merged row was
dropped.

Overstated: `gasUsd`, `_sumUsd` and `_sumUsdRaw` are **not** dead.
`route_details_card.dart` renders the gas row from `gasUsd` and `swap_screen.dart` writes it
to the stored transaction record; both helpers compute it. Deleting the five as one group would
have broken the gas row.

Fix: `feesUsd` and `totalCostUsd` removed from `SwapQuote` and from both adapter call
sites. The reason to delete rather than leave them is stronger than dead-code hygiene:
`totalCostUsd` **is** `feesUsd + gasUsd` — the merged figure this phase exists to stop
showing — so leaving it on the quote made reinstating that row a one-line change.

Three mapping tests asserted the summing itself, one of them opening *"The whole point of
summing both"*. They now assert the fee line and the gas figure separately.

**After both fixes:** 1375 passing / 5 skipped / 0 failed, `flutter analyze` clean, both shell
gates exit 0, and a repo-wide grep for either removed member returns nothing.
