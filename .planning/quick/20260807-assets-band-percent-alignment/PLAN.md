# Assets total band: centre the 24h percentage on the total

Slug `260807-pct` · branch `redesign/navigation-260806` · 2026-08-07

## The request

Jakub, on device, reported in English:

> With Assets and the amounts below it, the percentage change is not centred.
> It is not aligned with the amount on the left, so he wants it sitting on
> that amount's exact middle. On the right-hand side as it is now, of course,
> just raised up a touch.

The Assets total band (sketch 178 scheme A, shipped hours ago) puts the
portfolio total on the left and the 24h percentage to its right. The
percentage reads LOW against the total. It stays on the right; it needs
raising to the total's optical middle.

## Where

`lib/components/coins/view/coins_screen.dart`, `_AssetsTotalBand` - a `Row`
at `CrossAxisAlignment.baseline` / `TextBaseline.alphabetic`. Total is
`numericHeadline` (24 / 32 line box, w700). Percentage is `labelMd`
(13 / 18 line box, w500).

Baseline alignment is exactly what causes the complaint: it pins a small
label's baseline to a big number's baseline, so the small label's ink sits
in the bottom half of the big one's line box.

## What to do

1. Measure the current defect with real Inter loaded and real painted ink,
   not from typographic assumption. A harness font lies about digit metrics
   (precedent: `compute_balance_unit_track_test.dart`, digits ~1.7x wide).
2. Try `CrossAxisAlignment.center` first - line-box centre to line-box
   centre - and MEASURE the residual rather than declaring it fixed.
3. If `center` leaves a visible residual, state it with numbers and close it
   with a token, with the reason written down. No hand-tuned literal offsets;
   an untokened value in this repo is a design decision needing a reason.
4. Pin the result in `test/components/assets_header_scheme_a_test.dart`.

## Constraints

- Must NOT change the total's size, the band's 32px height, or the section's
  94px header cost. If the band height moves: STOP and report.
- 4-pt grid, tokens from `genius_wallet_consts.dart` only (`space3` = 6 is
  the one documented exception).
- Mobile first, dark mode. No em dashes. No commits (AGENTS.md).
- Nothing under `/banxa` or `/squid_router`.
- FILE FENCE: own `coins_screen.dart` + `assets_header_scheme_a_test.dart`
  only. Hands off `transaction_displays.dart`, `transaction_utils.dart`,
  `mobile_header.dart`, `responsive_overlay.dart`, `lib/dev/`.

## Gates

- `flutter analyze` 0 issues repo-wide. Measured baseline: **No issues found**.
- `flutter test` baseline measured before touching anything: **+1157, 0
  failing**. Nothing may break, no assertion may be relaxed.
