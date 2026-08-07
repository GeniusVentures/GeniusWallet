---
created: 2026-08-07T00:00:00.000Z
title: The transaction row's narrow amount column clips ordinary amounts on a phone
area: ui
files:
  - lib/dashboard/home/widgets/transaction_displays.dart
---

## Problem

Found while measuring for sketch 179-C (`.planning/quick/20260807-tx-row-action-leads-subtitle/`).
Nobody reported it and no test covers it, which is exactly why it is invisible.

On the NARROW presentation - the dashboard Transactions panel and the phone
`/transactions` route - the amount column is an `Expanded` that receives **113.0px** at
390pt. Measured with the shipped Inter at `numericBody` 16 / w600, ordinary amounts run:

| Amount string | px |
| --- | --- |
| `+ 0.42 ETH` | 86.5 |
| `+ 100 USDC` | 95.5 |
| `− 250 GNUS` / `+ 500 GNUS` | 96.3 |
| `− 12.5 GNUS` | 100.6 |
| `− 0.0021 ETH` | 107.2 |
| `+ 476.18 USDC` | 120.5 |
| `− 1.25 WSTETH` | 123.6 |
| `+ 2,400.75 GNUS` | 136.0 |

So `+ 476.18 USDC` (120.5) and `− 1.25 WSTETH` (123.6) already ellipsise on a phone
today, and a four-figure amount loses several digits. The column has no slack at all: it
is 7 to 23px SHORT for perfectly ordinary values.

## What must NOT be done about it

Sketch 179 offered a toggle that RESERVES this column at 96px, on the estimate that it
"claims 113px for content that needs about 90". That estimate is wrong in the wrong
direction - reserving 96 would clip most rows rather than fewer. The suggestion should be
treated as retired, not as an open option.

Sketch 179-C deliberately left the column alone for the same reason. The subtitle line is
7px short of holding a pending mint's verb, its ellipsis and its status tail
(`Minted` 47.7 + `…` 12.3 + space2 4 + `Pending` 55.9 = 119.9 against 113.0), and taking
that 7px from the amount would buy a marginal subtitle by damaging the one string on the
row that must never be wrong.

## The real shape of a fix

The width is not there to be redistributed; it has to come from somewhere else on the
row, or the amount has to need less. Candidates, none costed yet:

- Drop the fixed 44px time column on the narrow presentation (the day group header
  already states the date) and give the row 44 + space6 = 56px back.
- Move the fiat value line under the amount onto the same line, or drop it on narrow.
- Abbreviate the magnitude above some threshold (`2.4K GNUS`), which trades precision the
  `exactAmount` tooltip already preserves.

Whatever is chosen needs a real-font width test in the shape of
`test/dashboard/transaction_row_subtitle_test.dart`, because the existing
`transaction_row_test.dart` runs under the harness's one-em-per-character fallback font
and cannot see a clip of this kind at all.
