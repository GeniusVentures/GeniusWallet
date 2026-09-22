---
status: complete
---

# Quick task 260922-ftu: fix the two order-dependent test failures

Two independent within-file races, both root-caused and fixed with test-only
changes; no `lib/` file touched, no assertion value changed.

**Task 1** — `mobile_header_brand_and_pill_test.dart`: the Inter-font
hypothesis was wrong (each test file gets its own `flutter_tester` process).
Real cause: `Image.asset(height: 28)` with no `width` measures 0 wide until
decoded, so a first-run measuring test caught the mark mid-decode. Fixed by
`precacheImage` through `tester.runAsync()` in `_pumpHeader`.

**Task 2** — `job_flow_test.dart:737`: `DevMockJob` was ruled out
(`kShowDevTools` is false with no `--dart-define`). Real cause:
`SubmitJobCubit`'s background `_initialize()` calls the real
`GnusCubit.fetchGnusInfo()`/`fetchGnusBalance()`, which fail asynchronously
against the test fixture's asset-less network and clobber `costError` after
the seeded state was already read — a genuine unfaked async gap `_SeededGnusCubit`
never insulated against. Fixed by overriding both fetch methods to answer
synchronously from the seed (the pattern `submit_job_errors_test.dart`
already uses).

**Task 3** — proven at seeds 1049166414, 2784491144, 2469443488, and a
fresh random draw (3861745802): `flutter test` 1550/5/0 at all four,
shuffled and in file order. `flutter analyze`, `dart format`,
`check_brace_style.sh`, `check_raw_colors.sh` all clean; no stray CRLF.

## Deviations

None. Task 2's root cause is distinct from the `DevMockJob` lead named in the
brief; the brief anticipated this and that escape path was followed.

## Commits

- `437024bf` fix(test): decode the brand mark before measuring the header lockup
- `b48b133e` fix(test): seed GnusCubit's fetches so job_flow's background init can't race
- `005c05c2` docs(todo): close both order-dependent test flakes, proven across 4 seeds
