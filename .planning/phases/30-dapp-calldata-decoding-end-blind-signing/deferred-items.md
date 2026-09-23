# Deferred items found during phase 30

Out of scope for the plan that found them; logged rather than fixed.

## Decision/threat IDs in `lib/reown/` source comments (AGENTS.md forbids them)

Found while checking plan 30-01's own files. These sit in files 30-01 does not
touch, so fixing them would have widened an unrelated diff on the signing path.

- `lib/reown/swap_result_drawer.dart:16` — `(D-02, 21-03)`
- `lib/reown/swap_result_drawer.dart:21` — `(T-21-04)`
- `lib/reown/swap_result_drawer.dart:30` — `That is Phase 10 ...`
- `lib/reown/approve_dapp_connection_drawer.dart:31,86` — `(T-21-12)`, `(T-21-13)`
- `lib/reown/approve_transaction_drawer.dart:37` — `(T-21-12)`
- `lib/reown/send_transaction_details.dart:14` — `T-21-11's`

The one at `send_transaction_details.dart:69` was removed by 30-01, which was
already editing that block.

Consequence: plan 30-01's Task 2 verification greps all of `lib/reown/` for
these patterns and expects no match. That gate cannot pass on this branch until
the list above is cleared; 30-01's own three files are clean.

## `gsd-tools query state.*` corrupts STATE.md on this repo

Observed 2026-09-19 while closing 30-01. Running `state.update-progress` then
`state.record-session` (gsd-core at `~/.claude`) rewrote STATE.md and:

- reset `current_phase: 30` to `26`
- invented `last_activity_desc: Milestone v2.0 roadmap created`
- mangled a progress bar into `36/36 plans ([██████████] 95%)`
- inserted blank lines into unrelated prose and converted the whole file CRLF→LF
  (a 1436-line diff for a 12-line intent)

`roadmap.update-plan-progress 30` got the plan checkboxes right but also added
stray blank lines to unrelated v2.0 bullet lists.

Both files were restored from `702b39be` and edited by hand instead. Until this
is fixed, edit STATE.md and ROADMAP.md directly rather than through those verbs.

## `getExplorerUrl` is keyed on the coin symbol, not the chain

Found by 30-03 while threading the decoded symbol into the Hive record.

`lib/dashboard/home/widgets/transaction_utils.dart:11` maps a coin symbol to
an explorer base URL. Two consequences, one pre-existing and one new:

- Pre-existing: a Reown send on Base recorded `ETH` and therefore linked to
  etherscan.io, which is the wrong chain.
- New as of 30-03: a decoded token send records `USDC` (or the contract
  address for an unverified token), which is not in the map, so
  `getExplorerUrl` returns `''` and the receipt drawer shows no explorer link
  at all. No link beats a wrong-chain link, so this was accepted, not worked
  around. A plain send now records the selected network symbol, so Base
  linking is correct for the first time.

The fix is to key the explorer off `chainId`, which both the receipt drawer
and the history row already have access to via the selected network. Out of
scope here: it touches every transaction display, not the signing path.

**Closed** by phase 31 plan 1: `explorerUrlFor` keys the link off
`Transaction.chainId`, falling back to the old symbol map for a row that has
none.

## A token receipt has one unit, and history reads three things off it

Codex on PR #235 (P1): `Transaction.coinSymbol` is the only unit the model
carries, and history renders the amount, the Network Fee and the Network row
from it. A decoded token transfer is now filed under its token (`USDC`), so
the ETH gas and the network read as USDC, and the row still stores the token
contract as the recipient with the native value (usually 0) as the amount.
Filing it under the chain coin instead would hide the token entirely, which is
what develop did before this phase with a hardcoded `ETH`.

Neither is right; the model needs an asset unit distinct from the chain coin
(a new Hive field, plus the history amount row reading it). That is a schema
change across every transaction display, not a signing-path fix, so it is
deferred with the explorer-link item above, which wants the same split.

**Closed** by phase 31 plan 1: `Transaction.assetSymbol`/`chainId` split the
asset from the chain; the dApp record now stores `coinSymbol` as the gas coin
and `assetSymbol` as the decoded token, with the real recipient/amount pair
instead of the contract and the native value.
