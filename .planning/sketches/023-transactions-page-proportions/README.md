# 023 · Transactions page — vertical fit, fullscreen width, the All row

**Design question:** the page reads badly at fullscreen and the rail's `All` row sits oddly. What is
design, and what is a slip?

**Status:** three questions, awaiting Jakub's picks.
**Recommendation:** **V3** (hug, floored to the rail) · **W1** (keep 1280, re-judge after V3) ·
**R4** (All becomes a summary) — or **R1** if you want the one-line fix.

---

## Both complaints check out against the code, and both are slips

Worth stating up front, because it means the sketch does not have to be re-argued:

| Complaint | Cause |
|---|---|
| Huge empty space below the content, worst at fullscreen | `transactions_slim_view.dart:346` uses `CrossAxisAlignment.stretch`, forcing **both cards to the full window height**. Eleven rows is ~700px of list inside a 1400px card; the rail has ~480px of content in the same box. |
| `All 11` runs straight into the `Type` header with nothing between | Sketch 022 specified `All → rule → Type`. The build goes `row(Filters.all)` directly into `_groupHeader('Type')` with **no rule** — while the `Status` boundary above it **does** have one. Asymmetric by accident. |

---

## 1 · Vertical fit

- **V1 · Stretch** — today. Two tall empty boxes below the content.
- **V2 · Hug content** — one property, `stretch` → `start`. Each card ends where its content ends;
  a long list scrolls the page, which is what a history should do anyway.
- **V3 · Hug, then fill** — **recommended.** V2 plus a floor: the list card never gets shorter than
  the rail beside it.

**Why V3 over V2.** V2 alone leaves a 480px rail next to a 210px list card once you filter down to a
single day — the rail then reads as the main content and the list as a footnote. V3's floor is the
rail's own height, so the pair always reads as one object. Still a bounded literal, not a value
derived from constraints, so the freeze rule (`37639d5`) is untouched.

## 2 · Fullscreen width

**Fix the vertical first and look again.** Much of what reads as "tragic at fullscreen" is the empty
card height, not the side margin.

| Option | At 2560px | Cost |
|---|---|---|
| **W1 · keep 1280** *(rec)* | 640px margin each side | None. The row gains nothing past ~900px — only the gap between the counterparty and the amount grows. Margin is the honest answer to "there is nothing more to show". |
| W2 · raise to `xxl` 1536 | 512px each side | One constant; matches the Markets tab. But it widens the gap *inside* the row, not the content. |
| W3 · widen the rail 220 → 280 | rail grows, list unchanged | Spends width where there is content to spend it on. Cheap follow-up if the pair still reads lopsided. |

## 3 · The All row

- **R1 · Rule after All** — restores what 022 said. Symmetric with the Status boundary that already
  exists. **One `Divider`.**
- **R2 · All inside Type** — simplest structurally, but **All is not a type**; it spans Status too.
  Filing it under Type says something false about what it does.
- **R3 · Its own header** — a `Show` kicker so all three groups are labelled. Consistent, but a
  one-item group reads as a heading looking for company.
- **R4 · Summary, not a filter** — **recommended.** `All` stops being drawn as a tenth peer and
  becomes the rail's total: big number, quiet caption. The rule beneath it then separates a
  *summary* from a *list* — a boundary that explains itself.

**R1 is the safe fix; R4 is the better answer to what actually bothered you.** "All 11" flush above a
group header reads oddly because it is drawn as a tenth filter when it is really the total. R4 removes
the question rather than punctuating it — and since this is also where the footer count went, the
number finally has a shape that says "this is the whole".

---

## Cost

| Question | Take | Cost |
|---|---|---|
| Vertical | **V3** | `stretch` → `start` plus a min-height on the list card |
| Width | **W1**, re-judge after V3 | Nothing. W3 is the cheap follow-up |
| All row | **R4**, or **R1** for the minimum | R1 is one `Divider`. R4 is ~15 lines and one small widget |
