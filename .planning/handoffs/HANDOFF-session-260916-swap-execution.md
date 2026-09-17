# Session handoff — 2026-09-16 (Phase 26: swap execution, plans 04–08)

**Executor session.** Branch `phase-26-swap-wiring`, **not pushed, no PR.** 30 commits
(`223db81f..bf3a2aa3`), of which 5 are `origin/develop`'s and 1 is a second agent's (see below).

**Phase 26 is code-complete: all 8 plans landed, every one has a SUMMARY, and NONE has been
walked.** No swap has ever executed through this code. That is the single most important sentence
in this file.

## Where it stands

```
flutter test --no-pub     → 1347 pass / 5 skip / 0 fail, exit 0
flutter analyze --no-pub  → No issues found, exit 0 — root AND packages/genius_api
dart format (scoped)      → exit 0        tool/check_brace_style.sh --count → 0
live catalogue walk       → +1 (real credential)
live quote walk           → +1 (real credential)
```

Entering baseline was 1258 pass / 4 skip. `grep 'hash: ""' lib/` and `grep 993.72 lib/` both return
nothing — **the fabricated-success bug the phase exists to kill is gone.**

## Done this session

- **26-04** live catalogue + real balances. `SwapToken` replaced `lib/squid_router/models/`;
  `SquidTokenService` deleted. Balances read from chain for holdings only, one RPC per holding.
- **26-05** the orchestrator. `executeSwap` = route → allowance → exact-amount approval → send →
  status poll, behind a sealed outcome where only a hash-bearing shape may cause a side effect.
- **26-06** `_submitSwap` became a thin adapter; the fabricated `completed` row is deleted. The row
  is written *pending under the real hash* before polling, then resolved.
- **26-07** six failure shapes, each with its own message, no default arm in the switch.
- **26-08** the three moved-money states: paused / partial / refunded, with Squid's own recovery
  link captured (never composed) and persisted at Hive field 17.
- Merged `origin/develop` (milestone v2.0) and reconciled two competing roadmaps.

## Four API drifts found live — read this before trusting the generated client

The `squidrouter/` submodule's spec has drifted from the live API in **four** places. Every one was
found by calling it, not by reading it:

1. `getSDKInfo()` cannot parse the real `/v2/sdk-info` — `EvmChain.enableBoostByDefault` arrives null
   on a non-nullable field and the whole payload is rejected.
2. `transactionRequest` is unreachable: its `oneOf` collapses the object into a `ListJsonObject`.
3. `/v2/status` is read raw for the same reason.
4. **Squid sends `value`, `gasLimit` and both fee fields as DECIMAL strings, and
   `signAndSendTransaction` parses every one as hex.** `gasLimit: "969344"` read as hex is 9,868,100
   — ten times over, on a value that costs money. The adapter converts; the test round-trips through
   the signer's own parser.

Also: an unindexed transaction is **HTTP 404**, not a `not_found` status — it reaches the poller as a
throw and must be treated as "not yet", never as an answer. And `requestId` is absent from the
top-level body but present inside `transactionRequest`, equal to the `x-request-id` header.

The adapter reads all four endpoints off the generated client's **own dio** — base path, timeouts and
the integrator-ID interceptor reused, only the deserialization bypassed. This made `dio` a declared
dependency (already in the binary, same pinned 5.11.1).

## Two agents shared this branch — resolved, but worth knowing

A second code-committing agent ran on this index (its one commit, `09669d8b`, is labelled
`feat(26-05)` but implements 26-08). It went dormant at 16:56 leaving three red tests; those are
closed in `26a48c18` and 26-08 was finished here. **`.planning/STATE.md` now records that this
branch takes ONE committing agent until it merges.** The collision cost a misdiagnosis: a file
changed between two of my reads and I nearly filed "the analyzer is blind to non-exhaustive
switches" as a finding. It was not — I checked before reporting.

## Tomorrow: three walks, all needing a wallet

**Use Base mainnet 8453 — NOT the dead 84531 "Base - Sepolia" entry.** Run with
`flutter run -d windows --debug --dart-define-from-file=squid.local.json`.

1. **26-06** — one real swap on a throwaway funded wallet. The receipt's hash must resolve on the
   explorer and the stored row must match chain truth. **Record the hash in `26-06-SUMMARY.md`.**
2. **26-07** — underfund gas and submit: the message names the send failure, the list gains no row,
   the form stays usable. Needs dust only.
3. **26-08** — dev mocks on, open all three recovery rows in **both** appearance modes. Three
   fixtures are seeded for exactly this; no funds needed.

Every summary is marked `status: complete-pending-walk`. Flip to `complete` only as each walk passes.

## Gotchas that cost time today

- **Never run `dart format` over `packages/genius_api/lib`.** It reflows a 6,325-line generated FFI
  binding the package excludes from analysis. I did it twice and reverted twice. Scope it to files
  you touched.
- **A green test is not evidence until you know it can fail.** Three times a passing assertion was
  passing for the wrong reason: `find.text('Swap')` matched the page header rather than the CTA; a
  loop of `pumpWidget` inside one `testWidgets` reused the `State` and tapped nothing; and a
  "dropped consumer" was really the default 800×600 viewport. Mutate the implementation and watch
  the test redden.
- The plan checkpoint in 26-05 asked whether to extend `TransactionStatus`. It was **already**
  extended. Read the enum before answering a question about the enum.

## Uncommitted, and not mine

`.github/copilot-instructions.md`, `.gitignore`, `AGENTS.md` — all dirty since before this session
started. Left untouched.
