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
