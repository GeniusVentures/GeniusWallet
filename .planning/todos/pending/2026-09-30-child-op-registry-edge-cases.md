---
created: 2026-09-30
area: child-wallets
when: after the child-wallet flow is walked against a live node, not mocks
---

# Child-operation registry: four known edge cases

Found in the PR #261 review rounds and left open by choice.

1. DONE 2026-10-05: registration changes now keep locking their child, and block deletes, until they expire 6 minutes after submit, like fund/recover.
2. Main/child cycles: an account can register under an account that is its own pending or confirmed child. Needs a descendant exclusion in the main picker via `ownRegistrations()`. SDK behaviour on a cycle is unknown.
3. An account that is both a child and a main: movement through its two roles can be read as the other operation landing (same ceiling as the existing baseline-window ponytail in `child_operations_cubit.dart`).
4. DONE 2026-10-05 with item 1: the delete guard now waits for expiry, not the timeout.
