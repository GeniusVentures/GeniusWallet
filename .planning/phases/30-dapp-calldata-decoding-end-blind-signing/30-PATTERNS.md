# Phase 30: dApp Calldata Decoding - Pattern Map

**Mapped:** 2026-09-19
**Files analyzed:** ~5 (decoder, drawer content widget, 2 modified files, tests)

## File Classification

| New/Modified File | Role | Data Flow | Closest Analog | Match Quality |
|---|---|---|---|---|
| `lib/reown/calldata_decoder.dart` (new, name TBD by planner) | utility (pure logic) | transform | `lib/reown/utilities.dart` + `lib/squid_router/squid_util.dart` | role-match |
| decoded-call content widget (new, under `lib/reown/`) | component (drawer content) | request-response | `lib/reown/send_transaction_details.dart` | exact |
| `lib/reown/handle_dapp_requests.dart` (modified) | controller (event handler) | event-driven | itself (existing) | exact — edit in place |
| `lib/reown/send_transaction_details.dart` (modified, per D-03) | component | request-response | itself (existing) | exact — edit in place |
| `test/reown/<decoder>_test.dart` (new) | test (pure unit) | transform | `test/reown/utilities_test.dart` | exact |
| `test/reown/handle_dapp_requests_test.dart` or contract test additions | test (widget/behavioural) | event-driven | `test/reown/approve_drawer_contract_test.dart` | exact |

## Pattern Assignments

### Pure-Dart decoder (new file under `lib/reown/`)

**Analog:** `lib/reown/utilities.dart` (whole file, 16 lines) and `lib/squid_router/squid_util.dart` (whole file, 12 lines)

Convention observed across both: **top-level free functions, no wrapper class, no barrel export.** Each function is single-purpose (`formatEth`, `parseHexToBigInt`, `formatTokenAmount`), imported directly by full path where used (`package:genius_wallet/reown/utilities.dart`). No `part`/`part of`, no static-method class. Model the new decoder the same way — e.g. `decodeCalldata(String data, ...)` as a free function, not a `CalldataDecoder` class, unless the router allow-list (D-06) needs a lookup table, in which case a top-level `const Map` (see below) is the established shape, not a class with static fields.

**Existing constant to extend, not duplicate** (per RESEARCH's insight, confirmed at `packages/genius_api/lib/web3/web3.dart:42`): the ERC-20 ABI fragment already lists `name`/`decimals`/`balanceOf`/`symbol`. Add `transfer`/`approve` there rather than inlining a second ABI JSON blob in the new decoder file.

**Failure shape convention:** both existing pure-logic files swallow bad input and return a zero/sentinel value rather than throwing (`formatEth`'s catch returning `'0'`; `parseHexToBigInt`'s null-coalesce to `BigInt.zero`). D-06's "falls through to unknown-call treatment, never a partial guess" is the phase's version of this same defensive-return convention — return a sentinel (e.g. `null` or an `UnknownCall` variant) on any selector/decode mismatch, do not throw across the decode boundary that `handle_dapp_requests.dart` calls into.

### Decoded-call content widget

**Analog:** `lib/reown/send_transaction_details.dart` (full file, 154 lines) — this is the exact same slot (`ApproveTransactionDrawer`'s `content` parameter) for the exact same purpose (present a parsed on-chain call as human-readable rows before signing).

**Structure to copy:**
- `StatelessWidget`, `const` constructor, all fields `required`/named, no internal state.
- Token reads via `context.gw` (line 65: `final gw = context.gw;`), NOT `Theme.of(context).extension<GWColors>()` directly — that pattern only appears in `GWWarningNote` because it fails soft with `?? GWColors.dark()`. `send_transaction_details.dart` and `handle_dapp_requests.dart` (line 81: `navigatorKey.currentContext!.gw`) both use the `context.gw` extension; follow that, it is the live convention for this file family.
- `GWKicker('Details')` + `GWDetailGrid(rows: [...])` for the label/value block, with `GWCopyRow` for anything that should copy the full value (addresses) and a local `_PlainDetailRow` (lines 119-154, copy verbatim as a private widget in the new file if it needs its own rows, or reuse `SendTransactionDetails`'s if this content nests inside it) for plain label/value pairs. Row spacing constant: `kGWDetailRowPadding` from `gw_detail_grid.dart`.
- `GWWarningNote(message)` for both the unlimited-approve warning (D-04) and the unknown-call warning (D-05) — single positional `String` constructor, no named variant exists, don't invent one (AGENTS.md Rule of Three is explicitly declined for this component in `send_transaction_details.dart`'s own doc comment, lines 29-42).
- Spacing constants: `GeniusWalletConsts.space4/space6/space10` between sections (see lines 82, 87, 89 for the exact rhythم: space6 after hero, space10 before Details kicker, space4 between kicker and grid).
- `GeniusWalletTypography.numericHeadline` for the hero amount, `.bodySm`/`.bodyMd` for row label/value.
- **AGENTS.md "widgets not helper methods" is already enforced here** — `_PlainDetailRow` is a private `StatelessWidget`, not a `_buildRow()` method. Do not regress this.

### `handle_dapp_requests.dart` modifications

**Current unknown-call branch to replace (D-05):** lines 76-114 — the `else` branch building a `SingleChildScrollView`/`Container` with `gw.deepBlueCardColor` fill and hard-coded `Colors.white70` `Text(event.params.toString())`. This whole block is deleted and replaced by a call to the decoder + the new unknown-call presentation (reuse `GWWarningNote` styling per D-05, not a bespoke container).

**Method router shape:** single `if (method == 'eth_sendTransaction') { ... } else { ... }` — line 53. D-07 requires widening this before the `tx['from']`/params[0] cast at line 39-40 runs, since that cast currently executes unconditionally for every method including `personal_sign`/`eth_signTypedData` (which don't shape their params as `[Map]`). Keep the router as plain `if/else if` chain — no per-method handler registry exists in this codebase; do not introduce one.

**Hardcoded values to replace, per decisions:**
- Line 96 in `send_transaction_details.dart`: `'$amount ETH'` — becomes parameterized unit symbol (D-03).
- Line 148 `const coinSymbol = "ETH";` in `handle_dapp_requests.dart` — becomes the decoded symbol (D-08), threaded into the `Transaction` model at line 181 and into `SwapResultDrawer.show` calls at lines 187-193, 216-223.
- Decoding must read `tx` without mutating it (D-09) — `tx` is the same `Map<String, dynamic>` built at line 39-40 and passed by reference to `geniusApi.signAndSendTransaction(tx: tx, ...)` at line 152. Any decode helper must take an immutable view/copy; do not call `tx.remove`/`tx['x'] =` anywhere in the new code path.

### Test files

**Pure decoder test — analog:** `test/reown/utilities_test.dart` (full file). Convention: plain `test()` blocks (no `testWidgets`), grouped with `group(...)`, heavy prose comments at file-top explaining WHY the test exists and what "going red" means, explicit `FALLBACK`-style sub-groups for pinned defensive-return behaviour. Import only `package:flutter_test/flutter_test.dart` and the target file — no widget harness needed for the decoder test.

**Widget/behavioural test — analog:** `test/reown/approve_drawer_contract_test.dart`. If the new content widget needs a pumped test, follow `_openDrawer(tester, show)` (lines 59-83): build a `MaterialApp(theme: ThemeData(extensions: [GWColors.dark()]), home: Scaffold(body: Builder(...ElevatedButton triggers show()...)))`, tap 'open', `pumpAndSettle`, then assert on `find.text`/`find.byType(Text)`. Never call `Navigator.pop` directly to simulate dismissal/approval — always go through the widget's real gesture, per this file's own stated rule (lines 9-13).

**D-10 — Case 6 amendment, not workaround:** `test/reown/approve_drawer_contract_test.dart` around line 461-469 builds `knownNumbers = {_txFixture.amount, totalGasFee, maxFeePerGas, priorityFee}` and asserts every `\d+\.\d+` match on screen is one of those four. When the content widget adds a decoded amount, extend this literal `knownNumbers` set (or the fixture) — do not delete or loosen the regex/`$`-fiat assertion, which must stay exactly as strict (lines 447-457).

## Shared Patterns

### Token/spacing/typography source of truth
**Source:** `lib/theme/gw_context_extension.dart` (`context.gw`), `lib/theme/genius_wallet_consts.dart` (`space4/6/10`, `radiusMd`), `lib/theme/genius_wallet_typography.dart`.
**Apply to:** the new content widget and any modified widget in this phase. No raw `Colors.*`/`Color(0x…)` — this phase's own D-05 explicitly retires the one `Colors.white70` violation on this path.

### Warning presentation
**Source:** `lib/components/feedback/gw_warning_note.dart` (full file, 71 lines).
**Apply to:** unlimited-approve warning (D-04) and unknown-call warning (D-05). Single `String` message constructor only — no border-less/severity variant exists; don't add one for a 4th consumer per the Rule-of-Three note already recorded in `send_transaction_details.dart`.

### Detail rows
**Source:** `lib/components/cards/gw_detail_grid.dart` (`GWDetailGrid`, `kGWDetailRowPadding`), `lib/components/data/gw_copy_row.dart` (`GWCopyRow`), `lib/components/cards/gw_kicker.dart` (`GWKicker`).
**Apply to:** any new label/value row in the decoded-call content widget (contract address, decoded method name, unverified-amount row per D-02).

## No Analog Found

| File | Role | Data Flow | Reason |
|---|---|---|---|
| Router allow-list table (D-06) | config/data | lookup | No existing chain-keyed allow-list pattern in `lib/reown/` or `lib/squid_router/`; RESEARCH.md is the right source for shape (likely a `Map<int, Map<String, ...>>` keyed by chainId then selector — follow the free-function/top-level-const convention above, not a class). |
| `personal_sign`/`eth_signTypedData` cannot-decode presentation (D-07) | component | request-response | No existing "cannot decode this" view exists yet; D-05's unknown-contract-call view is the sibling this should visually match — build once, route both unknown-call and unsigned-method cases through it. |

## Convention Traps (things a new file could violate by accident)

1. **`test/components/drawer_padding_invariant_test.dart`** is a hand-maintained census of `ResponsiveDrawer.show` call sites (`lib/**` scanned by hand, not by glob, per its own header comment, lines 29-38). This phase adds no new `ResponsiveDrawer.show` call site (the decoded content slots into the existing `ApproveTransactionDrawer.show` call already in `handle_dapp_requests.dart`), so this census should NOT need an entry — confirm during planning that no new drawer-level file is introduced, only content widgets.
2. **`test/reown/approve_drawer_contract_test.dart` Case 6** (`knownNumbers` literal set, ~line 461) will start failing the moment a decoded amount appears on screen unless updated — this is D-10's explicit instruction, not a bug to route around.
3. **`analysis_options.yaml`** excludes only `lib/**/*.g.dart`, `lib/**/*.freezed.dart`, `banxa`, `squidrouter` (lines 4-9) — a new `lib/reown/*.dart` file is NOT excluded and will be linted normally; no silent-skip risk here.
4. **`AGENTS.md` "Rule of Three" already declined once** for `GWWarningNote` in `send_transaction_details.dart`'s doc comment (lines 29-42) — a fourth/fifth consumer in this phase (unlimited-approve + unknown-call warnings) still should NOT fork or flag the component; use the plain `String` constructor as-is.
5. **Byte-identity contract (D-09):** `tx` is passed by reference into `geniusApi.signAndSendTransaction` at `handle_dapp_requests.dart:152`. Any decode step inserted before that call must not mutate `tx` in place (no `tx['data'] = ...normalized...`) — copy before decoding.
6. **`GeniusWalletTypography`/`GeniusWalletConsts` vs. hand-typed values:** `send_transaction_details.dart`'s own doc comment (lines 10-17) flags that the ONLY hand-typed style values it replaced were a stray `fontSize: 28/FontWeight.bold` pair — don't reintroduce hand-typed sizes/weights in the new widget; use the typography tokens.

## Metadata

**Analog search scope:** `lib/reown/`, `test/reown/`, `lib/squid_router/squid_util.dart`, `lib/components/{cards,data,feedback}/`, `packages/genius_api/lib/web3/web3.dart`, `analysis_options.yaml`, `test/components/drawer_padding_invariant_test.dart`.
**Files scanned:** 11
**Pattern extraction date:** 2026-09-19
