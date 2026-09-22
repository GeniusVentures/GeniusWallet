# job_flow_test.dart:737 raced SubmitJobCubit's own background init

**Seen:** 2026-09-22, alongside the Inter-font order dependency, under the
same reproducing seed `2469443488`. `flutter test --test-randomize-ordering-seed
2469443488 test/submit_job/job_flow_test.dart` failed the "a user holding
exactly the job cost can buy" boundary test at `:737`
(`continueButton.onPressed` expected not-null, was null).

## Root cause

Not a leaked global (`DevMockJob.instance` was the strongest suspect named in
the task brief and is ruled out below). `SubmitJobCubit`'s constructor fires
`_initialize()` in the background, which calls
`gnusCubit.fetchGnusInfo()`/`fetchGnusBalance()` for real. The test fixture's
`_network` carries no `tokensPath`, so the real path hits
`rootBundle.loadString("")` and fails — printing `Unable to load asset: ""`,
observed exactly twice per cubit, matching the two real calls. That failure
resolves asynchronously through a genuine, unfaked async gap (real asset-bundle
I/O), the same class of race `runAsync` exists for in Task 1's image-decode
fix. When it lands, it calls `setCostError('Unable to fetch GNUS balance')`,
which outranks every other CTA rung and disables Continue — clobbering the
test's seeded `jobCost: 10, gnusBalance: 10, costError: ''` sometime after
`_SeededSubmitJobCubit`'s own constructor already emitted it.

`job_flow_test.dart`'s `_SeededGnusCubit` only seeded `tokenInfo` in its
constructor; it never overrode the fetch methods themselves, so the
background calls always ran for real. `pumpAndSettle()` cannot reliably
outrace a real async gap like this — sometimes the widget already rendered
and asserted before the clobber landed (pass), sometimes not (fail). Bisected
by running single-test pairs: the boundary test failed alone, failed after
any unrelated predecessor, but passed after any predecessor that called
`bridgeTokens()` — because that predecessor's own `await` happened to drain
the race first, not because anything was actually fixed. That is exactly what
"order-dependent" means here.

**DevMockJob ruled out with evidence:** `SubmitJobCubit._devJobScenario`
gates on `kShowDevTools`, defined as
`bool.fromEnvironment('GW_DEV_TOOLS')` (`lib/dev/dev_flags.dart`) — false
with no `--dart-define` in `flutter test`, so `_devJobScenario` is null
throughout and every `DevMockJob` branch in `submit_job_cubit.dart` is dead
code for this test file.

## Fix

`_SeededGnusCubit` now overrides `fetchGnusInfo()`/`fetchGnusBalance()` to
answer synchronously from the seed, so `_initialize()`'s background calls
never reach `rootBundle`. This is the same pattern
`submit_job_errors_test.dart`'s `_SeededGnusCubit` already uses — removes the
race instead of out-timing it. No assertion value changed; no `lib/` file
touched.

Proven against seeds `1049166414`, `2784491144`, `2469443488` and a fresh
random draw (`3861745802`): `flutter test` passes 1550/5/0 at all four, both
shuffled and in plain file order. Commit `b48b133e`.
