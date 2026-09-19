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
