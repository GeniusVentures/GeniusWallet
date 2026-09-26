# Deferred items — phase 10

## dart format drift in local_secure_storage_base.dart (pre-existing)

`dart format --output=none --set-exit-if-changed packages/local_secure_storage/lib/src/local_secure_storage_base.dart`
exits 1. Confirmed pre-existing: the file at commit 3f8b3e80 (before plan 10-01 touched it) already
fails the same check under the installed Flutter/Dart SDK's current formatter. Out of scope for
10-01 (task only changed the AndroidOptions block, which is itself correctly formatted). Not fixed
here per the scope-boundary rule — a whole-file reformat is a separate, unrelated diff.
