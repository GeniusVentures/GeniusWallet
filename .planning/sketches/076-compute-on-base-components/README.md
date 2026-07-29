---
sketch: 076
name: compute-on-base-components
question: "Sketches 016/017/018 were drawn before the base components existed. What survives, what becomes a component, and what did tonight's code read prove wrong?"
winner: "Re-cut ACCEPTED 2026-07-29 — 016-B2/017-A/018-A stand, rebuilt on base components; the 4 code deltas and the new burned-tokens terminal state are in scope. Variant pick lives in 077."
supersedes_design_of: [016, 017, 018]
tags: [compute, sgnus, submit-job, base-components, phase-14, re-cut]
---

# Sketch 076: Compute, re-cut on the base components

## Why this exists

016/017/018 were drawn **2026-07-22/23**. Every base component they would have used shipped
**2026-07-28**: `GWStatTile`, `GWKicker`, `GWDetailGrid`, `GWWarningNote`, `GWAnimatedNumber`, and
the drawer archetype where the shell owns its insets and the panel is a card (`8044bdb7`).

So the three sketches hand-build things that are now components, and they cite line numbers from
before Braian rewrote 298 files. This sketch re-cuts them and re-measures.

**The three design decisions are NOT reopened.** 016-B2 twin tiles, 017-A dot+label, 018-A drawer
with vertical steps all stand. What changes is what they are made of, plus four things the code
read found that the original design could not have known.

## How to view

```
open .planning/sketches/076-compute-on-base-components/index.html
```

---

## Verification pass on the old findings — 2 of 5 had drifted

Braian's own blocking constraint says to re-measure any count in a planning doc. Done:

| Roadmap claim | Status now | Correction |
|---|---|---|
| `maxHeight: 300` at `dashboard_screen.dart:207` | **ALIVE** | now line **212**; 276px budget holds |
| Zero balance in `statusError` at `wallet_overview.dart:141-147` | **ALIVE** | now **143-145** |
| 52.5% ring at `sgnus_connection_widget.dart:85` | **ALIVE** | now **89** |
| Vanishing button at `submit_job_dashboard_button.dart:25` | **ALIVE** | now **26** |
| `Colors.white` at `components/genius_balance_display.dart:80` | **ALIVE, wrong path** | the file is at `lib/wallets/view/genius_balance_display.dart`, the literal is line **81**, the 48px default line **79** |

All five bugs are real. Two of the five pointers would have sent an executor to a file that does
not exist at that path.

---

## Four things the code read found that 016/017/018 could not know

**1 · The burned-tokens hole is worse than 018 recorded.**
018 finding 2 says "if the second fails, the money is already gone". True, and worse:
`submit_job_cubit.dart:195-218` — when `requestGeniusSDKProcess` fails after a **successful**
`bridgeOut`, the function emits `processErrorMessage` and returns. **The `txHash` is never written
to state.** The user burned GNUS, got a red toast, and has no hash to prove the burn happened.
→ **New terminal state required.** Design change, not a code note.

**2 · The success hash is unrecoverable by construction.**
`submit_job_screen.dart:48-56` calls `resetState()` **before** raising the toast. The screen empties
and the hash lives only in a transient toast body. 018 flagged the raw hash; it did not flag the
ordering, which is what makes it unrecoverable.
→ **The result must be a step in the drawer with a copy row, not a toast.**

**3 · `isPurchaseable` is off by one and doubles as a lie.**
`submit_job_screen.dart:65` — `jobCost < gnusBalance`, strictly less. **Exactly enough GNUS is
blocked.** The same flag also drives the `* You do not have enough GNUS` line, and it is false when
`jobCost == 0` — so "cost not yet known" renders as "you are too poor".
→ **Cost-unknown and insufficient-funds are two states, not one.**

**4 · The percentage goes stale and stays on screen.**
`app_bloc.dart:184-191` — percentage is emitted **only while processing**. When processing stops,
the last value is kept. `isProcessing:false, processingPercentage:87.0` is reachable and permanent.
→ **Any bar or number must gate on `isProcessing`, never on the percentage alone.**

Also carried, unchanged in severity: the error channel. `filePickerError` carries balance failures,
token-info failures, gas-estimate failures **and** "no file selected", all raised under the toast
title **"File Picker Error"**. Three of the four origins have nothing to do with a file picker.

---

## Component mapping — what stops being hand-built

| 016/017/018 drew | Becomes | Note |
|---|---|---|
| "compact `COMPUTE` kicker" | `GWKicker(dense)` | 11px/w600/0.6. Call site owns padding - the component has none |
| balance hero, 48px | `GWAnimatedNumber` @ `numericDisplay` | **32/40 w700.** Drops 16px off the tallest element - the budget gains it |
| compute readouts | `GWStatTile` | kicker + 3px + 15/w600/lh20. Box is composition, not a flag |
| step 2/3 cost table | `GWDetailGrid` | sunken well, hairline-ruled. Exactly its purpose |
| "not enough GNUS" red line | `GWWarningNote` | amber, and it already solved the light-mode `statusWarning` 1.6:1 failure |
| inline blockers | `GWWarningNote` | same |
| CTA row | `GWButton` | CTA weight rule: fill = commitment, max one filled per surface |
| drawer shell | `ResponsiveDrawer` | archetype now owns insets; panel is a card |
| tile containers | `GWCard` | |
| in-flight | `GWSpinner` / `GWLoadingState` | replaces `Loading(text:)` |

---

## The height budget, re-measured with real component metrics

Card `maxHeight: 300` − `DashboardScrollContainer` `EdgeInsets.all(space6)` = **276px usable.**

| Element | Height | From |
|---|---|---|
| Balance tile: pad 12 + kicker 14 + gap 4 + `numericDisplay` 40 + subline 16 + pad 12 | **98** | real component metrics |
| gap `space6` | 12 | |
| Compute tile: pad 12 + kicker 14 + gap 4 + status row 20 + subline 16 + bar 10 + pad 12 | **88** | |
| gap `space6` | 12 | |
| CTA `GWButton` | 44 | |
| **Total** | **254** | **+22px headroom** |

B2 was measured at **261px worst state, +15px headroom** when hand-drawn with a 48px balance.
Moving to `numericDisplay` buys back 7px. **Still the tightest layout of the four, and anything
added to the compute block still breaks it first.**

### The one thing that does NOT fit — a decision for you

The roadmap calls out that this card, alone among dashboard panels, **has no section title**.
Adding `GWSectionTitle` costs **44px** (18px `titleLg` + its own 44px reserved min-height and bottom
gap): 254 + 44 = **298px against 276.** It overflows by 22px.

- ★ **`GWKicker` (non-dense, 13px) instead, ~17px + 8px gap = 25px → 279px.** Still 3px over.
  Recovered by dropping the balance tile's `≈ $` subline **only in the states where compute is
  showing a bar**, which is exactly when the card is tallest.
- Runner-up: **no title at all**, ship 254px, accept the inconsistency the roadmap named.
- Rejected: **`GWSectionTitle`**. It is the correct component and it does not fit. Forcing it means
  either shaving the height budget - which 016 already refused once - or a scroll wrapper, which is
  the workaround 05-08 already had to ship on this same card.

---

## What I changed in the flow (018-A), and why

Steps 1-3 stand as designed. Steps 4-5 change:

**Step 4 · In flight — now two labelled operations, not one spinner.**
The drawer names `Bridging` and `Processing` as separate lines with their own state, because they
fail separately and only the first one spends money. 018 showed the two-operation problem in prose;
this shows it in the widget.

**Step 5 · Result — three terminal states, not one.**

1. **Done** — hash in a `GWDetailGrid` row with a copy affordance. Not a toast. Balance line reads
   *"updating…"* until the hardcoded 5s `fetchGnusBalanceWithDelay` lands, because 018 finding 4 is
   right that no result screen may promise a fresh balance before it does.
2. **Job failed, tokens burned** — **NEW.** The bridge hash is shown and copyable, the job is not
   started, and the copy says exactly that. This is the state `submit_job_cubit.dart:195-218`
   produces today and throws away.
3. **Bridge failed** — nothing spent, retry in place.

**Blocked path — split in two.** `Cost not yet known` (neutral, waiting) and `Not enough GNUS`
(`GWWarningNote`, with the shortfall as a number). Today one flag renders both as the same red line.

And the boundary is `<=` not `<`, so exactly-enough GNUS can buy.

---

## Open questions for you

1. **Section title** — the ★ above, or ship with no title.
2. **Unit clash** — B2 kept `1,204.50 GNUS` next to Assets' `$312.40`, mitigated by an `≈ $` subline.
   That subline is also my proposed 3px release valve. If you want the title, the `≈ $` goes.
   016-B3 (fiat hero) resolves it outright and is still the recorded fallback.
3. **`View transaction ›`** — still needs a job→tx correlation nothing provides. Drop the link rather
   than grow the block?
