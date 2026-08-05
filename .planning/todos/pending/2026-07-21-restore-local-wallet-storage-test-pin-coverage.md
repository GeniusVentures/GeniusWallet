---
created: 2026-07-21T00:00:00.000Z
title: Restore local_wallet_storage_test.dart — the only PIN and secure-storage coverage, dark all milestone
area: testing
severity: major
files:
  - test/local_wallet_storage_test.dart
  - pubspec.yaml
---

## Problem

`test/local_wallet_storage_test.dart` is **240 lines, entirely commented out** — every line prefixed
`//`, no `main()`. Flutter therefore reports `Failed to load ...: Missing definition of 'main' method`,
and **that single message is the entire basis for the milestone-long belief that this project has no
working test harness.**

That belief was recorded in `STATE.md` as a standing blocker, carried into every phase plan, every
verification report, and every agent brief. Measured directly on 2026-07-21: `flutter test` runs
**14 passing tests**; this one commented-out file is the only failure. The cost of the
misdiagnosis is documented in `STATE.md`'s Blockers section — six human walks on Phase 05,
`verify:` blocks designed around a human being available, and APP-02 deferred to v2 as though a
harness needed building.

**What the file covers — and why this is not just tidiness:**

| group | asserts |
|---|---|
| `init` | account creation; skips creation when one exists; loads watched wallet from storage |
| `loadAccount` | reads an existing account out of secure storage |
| `saveAccount` | writes an account to secure storage |
| `deleteAccount` | deletes an account from secure storage |
| `storeUserPin` | stores a user PIN |
| `verifyUserPin` | verifies correct PIN → `true`, **and incorrect PIN → `false`** |
| `pinExists` | PIN presence / absence |

This is the **only** automated coverage of secure storage and PIN handling anywhere in the repo. It
is dark on the exact surface Phase 6 is about to re-skin, and on the layer sitting directly beneath
the live PIN defect found the same day (`pin_screen.dart` invoking `onCompleted` during `build()` —
see `06-05-PLAN.md`).

## Why it was disabled — diagnosed, not guessed

Verified 2026-07-21:

- **Dependencies are all present.** `pubspec.yaml:61` `mockito: ^5.0.0`, `:63` `build_runner: ^2.4.9`,
  and `packages/local_secure_storage/` exists.
- **The missing piece is generated code.** The file imports `local_wallet_storage_test.mocks.dart`,
  which does not exist anywhere in `test/` and was never committed. It is a `build_runner` artifact.
- So the likely history is: someone hit an unresolvable import, commented the file out to make the
  run quiet, and it was never regenerated.

**A real bug in the annotations, to fix while restoring:**

```dart
@GenerateMocks([Web3])
@GenerateMocks([MockFlutterSecureStorage])   // <-- generating a mock OF A MOCK
```

The second asks mockito to generate `MockMockFlutterSecureStorage`. Whatever was intended, this is
not it — it should almost certainly target the real `FlutterSecureStorage` (or whatever concrete
type `LocalSecureStorageBase` depends on). **Do not uncomment and regenerate without resolving this**,
or the generated mocks will not match what the tests actually stub.

Note also it imports `package:local_secure_storage/src/local_secure_storage_base.dart` — a reach into
another package's `src/`, which is private by convention. Check whether that type is exported
publicly and prefer the public import if so.

## Solution

1. Uncomment the file.
2. Fix the `@GenerateMocks` annotations (see above) against the types the tests actually stub.
3. Run `build_runner` to generate `local_wallet_storage_test.mocks.dart`:
   `flutter pub run build_runner build --delete-conflicting-outputs`
   (toolchain: `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat`).
4. **Commit the generated mocks file** — its absence is the whole reason this went dark. Check
   whether `.gitignore` excludes `*.mocks.dart`; if it does, that is the root cause and the ignore
   rule needs narrowing, not just a one-off commit.
5. Run `flutter test test/local_wallet_storage_test.dart` and fix what genuinely fails. **Expect real
   failures** — this code has been unexercised for the whole milestone and the surrounding code has
   moved. A test that has been dark this long is an assertion about a codebase that no longer exists;
   read each failure before "fixing" it, since some may be the test being stale rather than the code
   being wrong.
6. Then run repo-wide `flutter test` and confirm the count rises from 14.

**Do not simply delete the file to make the run green.** It is the only PIN/secure-storage coverage
in the project, on the highest-consequence code path in a crypto wallet.

Related: `.planning/STATE.md` Blockers (the corrected harness claim),
`.planning/phases/06-onboarding/06-05-PLAN.md` (the live PIN defect).
