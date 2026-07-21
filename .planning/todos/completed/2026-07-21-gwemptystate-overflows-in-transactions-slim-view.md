---
created: 2026-07-21T00:00:00.000Z
title: GWEmptyState overflows inside TransactionsSlimView on an empty wallet (19px, then 34px)
area: ui
severity: criterion-blocking
files:
  - lib/components/feedback/gw_empty_state.dart:32
  - lib/dashboard/home/widgets/transactions_slim_view.dart
---

## Problem

Observed live on the 2026-07-21 Windows debug run (`GW_DEV_TOOLS=true`, Flutter 3.41.9) and
confirmed visually by the user. Two `RenderFlex` overflows fire on the dashboard's transactions
panel — **19px** on first layout, then **34px** on a later pass:

```
The relevant error-causing widget was:
  Column  lib/components/feedback/gw_empty_state.dart:32:16

creator: Column ← Padding ← Center ← GWEmptyState ← Expanded ← Column
       ← ConstrainedBox ← TransactionsSlimView
       ← BlocListener<TransactionsCubit, List<Transaction>>
       ← BlocBuilder<TransactionsCubit, List<Transaction>> ← TransactionsStream ← …

constraints: BoxConstraints(0.0<=w<=549.0, 0.0<=h<=125.0)
size:        Size(385.4, 125.0)
direction:   vertical
mainAxisSize: min
```

`GWEmptyState`'s column needs roughly 144px of intrinsic height and is handed 125px, so its
bottom content is cut off. `mainAxisSize: min` means it is already as small as its children
allow — the content genuinely does not fit the slot.

**This directly violates Phase 5 success criterion 5** ("Walking the dashboard … produces no
RenderFlex overflow and no crash"). It fires on an **empty wallet at default window size** —
i.e. the fresh-install state, the first thing a new user sees.

**This is NOT the old 6.3px `crypto_live_chart.dart` overflow.** That one is genuinely fixed
(quick `260720-uhe`'s compact-mode guard, walked and approved). This is a different widget in a
different subtree, and it is newly observed, not a regression of the old fix.

### Why every prior walk missed it

Every dashboard walk to date used the dev bubble's **mock-holdings / mock-transactions
injectors** (quick tasks `cw8` and `jvr`) to get a non-empty wallet — because an empty wallet
was considered the less interesting case to review. A populated transactions list renders rows,
not `GWEmptyState`, so the overflowing widget was never on screen during any walk. The one
configuration nobody walked is the one every new user starts in.

Worth generalising: the injectors made walks *possible*, and simultaneously made one whole
state *invisible*. Any walk protocol that relies on fixtures should explicitly include the
zero-state.

## Solution

Not yet diagnosed — do not assume the fix. Three candidate directions, in rough order of
likely correctness:

1. **Give the slot more height.** `TransactionsSlimView`'s `ConstrainedBox` is what caps the
   panel; the 125px inner constraint is what it leaves after the section title. If the panel
   can afford ~20px more, this is the least invasive fix — but check it against the unified
   `GWSectionTitle` geometry from quick `260721-baz`, which deliberately made all four panel
   headers share one height. Do not silently desynchronise them.
2. **Make `GWEmptyState` adaptive.** Have it drop its body text (or shrink its icon) below a
   height threshold, the way `CryptoLiveChart` already handles its own compact mode via
   `isHeightBounded` + a threshold constant. This is the most reusable fix, since `GWEmptyState`
   is shared and this will recur in any other tight slot.
3. **Let it scroll or clip.** Cheapest, and the worst of the three — it hides the symptom and
   leaves a user-visible truncation. Only acceptable if 1 and 2 are both ruled out, and then it
   must be recorded as a deliberate accepted gap, not a fix.

**Verify in BOTH appearance modes and at more than one window height** — the 19px/34px pair
suggests the deficit varies with layout pass and available space, so a fix that clears it at
one size may not clear it at another. Release builds clip silently where debug paints stripes,
so confirm in a release build too.

Related: `.planning/phases/05-dashboard/05-VERIFICATION.md` (criterion 5),
`.planning/todos/pending/2026-07-20-expand-dev-mock-section-more-injectors.md`.

## RESOLVED 2026-07-21

Fixed by quick task `260721-e3r` (`2e82ec2`) — `GWEmptyState` now adapts to a compact tier below
a finite `constraints.maxHeight` threshold, following the `CryptoLiveChart` compact-mode precedent.
Walked and **APPROVED** as part of `05-08`'s Task 4 Part D (the outstanding e3r walk, folded into
that plan's consolidated checklist rather than left as a second, competing one): on an empty wallet
at default window size, the Transactions empty state rendered with no overflow and a fully readable,
non-ellipsised message; the Assets empty state (pinned at 300px) stayed full-size and visually
unchanged, confirming the regression gate. Console evidence: zero overflow lines on boot, where the
pre-fix 2026-07-20 run logged 19px within seconds under identical conditions. Re-walked across
multiple window shapes per Part D step 15, in both appearance modes.

Release-build verification of this specific site was not separately performed (see the standing
`.planning/todos/pending/2026-07-20-dashboard-live-chart-overflows-by-6px.md`-style release-build
caveat, tracked instead against the chart card's release-build item in `05-VERIFICATION.md`'s
`human_verification`).
