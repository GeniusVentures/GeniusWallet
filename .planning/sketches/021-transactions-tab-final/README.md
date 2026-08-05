# 021 · Transactions tab — FINAL, for approval

Consolidates sketch 020 after Jakub's picks. **Three decisions locked, three still open.**

| Decision | Value | Status |
|---|---|---|
| Layout | **B · Filter rail** — page at `xl` 1280, `GWPageHeader` 24px, list + rail each in a `DashboardScrollContainer` | locked |
| Empty state | **E2 · Anchored**, no action buttons | locked |
| Empty state | **Filter control hidden when `scoped.isEmpty`** — page rail *and* panel chips | locked |
| Amount / Value / Status scheme | rec **S1 · Sign = movement** | open |
| Empty-state anchor | rec **c · centred within the first 480px** | open |
| Empty-state icon | rec **1 · Clock** (`FontAwesomeIcons.clock`) | open |

---

## 1 · The rail's active state — 020 was wrong, and Jakub caught it

Sketch 020 painted the active rail row with a `brand-fill` background. **That colour appears nowhere
in this app's selection language — it was invented.** Corrected here; every state now traces to a
shipped line:

| State | Treatment | Precedent |
|---|---|---|
| Rest | glyph `textSecondary` 14px · label `labelMd` 13/w500 `textPrimary` · count `numericBody` 13px tabular `textSecondary` · row 40px (`space20`), pad `space6` | `_menuItem`, `transactions_slim_view.dart:498-551` — byte for byte |
| Hover | lifts onto `surfaceElevated`, label to `textPrimary`, 120ms | sketch 008 D "lift chip" — the app-wide standard, already in `_FilterChip` and `_TimeframeTab` |
| Active | gradient label + w700, **glyph unchanged**, plus a 2px gradient leading rail | label from `_activeLabelShader` (`:490`) and the locked glyph rule (`:525`); the rail is the navbar's active-tab indicator turned vertical |

**Why the active row needs a second mark.** In a popup the selection is momentary, so a gradient label
suffices. A rail is permanent and sits in peripheral vision — a 13px gradient label alone is too quiet
to answer "is a filter on?" at a glance. The navbar solves that exact problem with a 2px gradient bar,
so the rail borrows it instead of inventing a third answer. It also keeps hover and active visually
distinct, which the `brand-fill` version did not guarantee.

**One genuinely new row: `All`.** `_menuItem` has no "All" — you clear by tapping the active filter
again, which is invisible. A rail has room to say it, and it is the natural home for the total count
that currently lives in the footer.

---

## 2 · Amount · Value · Status where money did not simply move

`transaction_utils.dart:356-366` gives **both** a failed transaction and a processing job
`amount = '—'`, demoting the real number to the small grey line. Jakub called it misleading; it is.

**Computing is not a design choice — Jakub is simply right.** A job spends `tx.fees`, and that GNUS
genuinely leaves the wallet. All three schemes fix it identically: `− 0.42 GNUS` in Amount,
`$0.32 fee` in Value, status Complete.

**The failed row is the real decision, and half of the instruction needs pushing back on.** If a
failed send prints `− 0.75 ETH` at the same weight and colour as a successful one, the row asserts
that 0.75 ETH left the wallet. It did not — anyone scanning or summing the column double-counts money
that never moved. So: show the amount (a dash tells the user nothing), but do not let it claim the
balance changed.

| Scheme | Failed row | Cost |
|---|---|---|
| **S1 · Sign = movement** *(rec)* | `0.75 ETH`, **no sign**, `textSecondary`; Value `Not charged` | none — no strikethrough, no new colour, no new column. `#8A8F9D` on `#0C0E14` = 6.0:1 dark, `#5A606E` on white = 6.3:1 light |
| S2 · Struck attempt | `− 0.75 ETH` struck through and muted | strikethrough is **not announced by screen readers** (needs a `Semantics` restatement); a line through tabular digits at 16px is where `0.75` and `0.15` start to look alike |
| S3 · Quiet money column | keeps `—`; attempted amount moves to Detail | **breaks the two surfaces apart** — the panel has no Detail column, its subtitle already carries the status, so the line becomes `Card purchase · Failed · 0.75 ETH attempted` and truncates |

**The panel has no Status column**, so whatever carries "this did not happen" must survive without one.
S1 does; S3 does not. That is the argument that decides it, not taste.

Pending / escrow-lock is deliberately **unchanged**: money *is* committed, so it keeps the full sign
at full weight.

---

## 3 · E2 anchor

Jakub: the icon and title sat too high. Three anchors in an identical 620px slot:

- **a** · top + `space16` (32px) — what he saw
- **b** · top + `space32` (64px) — lower, but an arbitrary number
- **c** · **centred within the first 480px** — recommended

**Why c.** It is a rule — *centre inside the slot, but never search more than 480px for the middle* —
rather than a hand-picked offset. In a short panel it behaves **exactly as today**, so nothing
regresses where the current layout is already fine; in the 1400px panel it settles at ~240px from the
top instead of drifting to 700. One `ConstrainedBox(maxHeight: 480)` under `Alignment.topCenter`
inside `GWEmptyState` — which fixes Assets and Markets at the same time, since they share it.

---

## 4 · Five empty-state icons

All five already available; the filtered-empty branch keeps `Icons.filter_alt_outlined`, so no
collision.

1. **Clock — `FontAwesomeIcons.clock` — recommended.** The glyph the navbar already gives the
   Transactions tab (`responsive_overlay.dart:51`), so the empty state wears the mark of the place
   you are standing in.
2. Receipt — `Icons.receipt_long_outlined` (today). Paper-ish for a wallet; reads as a note.
3. History — `Icons.history`. Names the concept, but the counter-clockwise arrow reads as
   "undo/restore" as often as "history", and the arrowhead is first to muddy at 32px.
4. Two-way arrows — `Icons.sync_alt`. Literally the message underneath, but it is the Swap tab's mark
   at a glance — the one real collision in this set.
5. Ledger — `Icons.list_alt_outlined`. Safest and least characterful.
