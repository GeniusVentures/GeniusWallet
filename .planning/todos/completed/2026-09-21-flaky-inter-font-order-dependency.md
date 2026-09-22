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

## RESOLVED 2026-09-22

The recorded hypothesis was wrong. It is not the `Inter` family leaking across
files — `flutter test` gives each test FILE its own `flutter_tester` process,
so a font registered in one file cannot reach another. Measured instead:
`mobile_header_brand_and_pill_test.dart` fails ALONE under seed `2469443488`,
so the dependency is WITHIN the file, between its own tests.

The real cause: `BrandLockup` renders `Image.asset(..., height: 28)` with no
`width`. Before the PNG decodes, `Image` measures 0 wide, so the enclosing
`Align(widthFactor: 29/38)` contributes 0 instead of `28 * 29/38 = 21.3684`.
Measured deficit: `106.06 - 84.693359375 = 21.3666` — matches to four
significant figures. The test only ever passed because an earlier test in the
file had already warmed the global `imageCache`; the seed put the measuring
test first, catching the mark mid-decode.

No shared `test/support/` Inter loader was built — it would have fixed
nothing broken. Fixed instead in `_pumpHeader`: `precacheImage(...)` through
`tester.runAsync()`, then one more `pump()`, before the widget is measured.
`runAsync` is required because fake async cannot drive the real
`instantiateImageCodec` an `Image.asset` needs to decode.

Proven against seeds `1049166414`, `2784491144`, `2469443488` and a fresh
random draw (`3861745802`): `flutter test` passes 1550/5/0 at all four, both
shuffled and in plain file order. Commit `437024bf`.
