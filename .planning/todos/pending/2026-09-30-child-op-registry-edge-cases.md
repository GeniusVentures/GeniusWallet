---
created: 2026-09-30
area: child-wallets
when: after the child-wallet flow is walked against a live node, not mocks
---

# Child-operation registry: four known edge cases

Found in the PR #261 review rounds and left open by choice.

1. A registration change (revoke, detach, register, move) that times out without landing stops blocking other operations on that child. Registration ops have no expiry like fund/recover do. Fix: give them a lifetime expiry, or a per-write receipt.
2. Main/child cycles: an account can register under an account that is its own pending or confirmed child. Needs a descendant exclusion in the main picker via `ownRegistrations()`. SDK behaviour on a cycle is unknown.
3. An account that is both a child and a main: movement through its two roles can be read as the other operation landing (same ceiling as the existing baseline-window ponytail in `child_operations_cubit.dart`).
4. An account can be deleted once an incoming register or move naming it has timed out (matches how `hasPendingFrom` treats timed-out ops).
