# Order-dependent failure: mobile_header_brand_and_pill_test measures the wrong Inter face

**Seen:** 2026-09-21, CI quality job on PR #235 tip `a8b3f9c8` (run 35640128505),
`flutter test --test-randomize-ordering-seed random` drew seed `1049166414`.

**Failure:** `test/components/mobile_header_brand_and_pill_test.dart:423` —
`lockup` expected 106.06 ±0.05, actual 84.693359375. Reproduces locally with
`flutter test --test-randomize-ordering-seed 1049166414` on that tip; the file
alone passes. Neither that file nor `lib/components`/`lib/theme` is touched by
the branch; both suspect files are byte-identical to develop.

**Hypothesis (not confirmed):** six test files register faces under the family
`Inter` with `FontLoader`, and `test/dashboard/compute_balance_unit_track_test.dart`
registers Bold only. Running that pair in order with `--concurrency=1` does NOT
reproduce it, so the interaction is with some other file in the shuffled order,
or with concurrency. Bisect with the seed above.

**Fix shape:** one shared loader in `test/support/` that registers all four
weights, used by every file that needs real Inter — or give the family a
per-file name. Not done on #235: out of that PR's scope.
