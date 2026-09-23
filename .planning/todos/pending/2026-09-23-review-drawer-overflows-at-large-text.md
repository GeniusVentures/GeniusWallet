---
created: 2026-09-23T23:30:00.000Z
title: The transaction review drawer overflows on a small screen with large text
area: accessibility
severity: major
files:
  - lib/reown/send_transaction_details.dart
---

## Problem

At 320x480 with text scaling 2.0, `SendTransactionDetails` overflows: the column at
`send_transaction_details.dart:51` by ~939px vertically and rows at `:128` by 170px / 85px
horizontally. Measured 2026-09-23 while making the Send form scroll. The drawer is shared by the
Send review and every dApp approval, so a user with large text may not reach Approve/Send.

## Fix direction

Make the drawer body scroll and let the detail rows wrap (label above value when narrow). Needs a
widget test at 320x480 / textScaler 2.0 for both the Send review and a dApp request.
