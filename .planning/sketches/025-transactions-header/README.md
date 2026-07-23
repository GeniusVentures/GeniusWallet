# 025 · Transactions — header placement

**Design question:** a lone `Transactions` word floating top-left over a 1600px page reads as
unfinished. Where should the title sit, and what fills the header row?

**Status:** five treatments, awaiting Jakub's pick.
**Recommendation:** **B · Title + toolbar actions** (optionally with **C · subtitle**).

The rail+list beneath is held identical across all five; only the header changes.

| Option | Header row | Provenance | Cost |
|---|---|---|---|
| **A** | title only — today | — | reads stranded, 90% empty |
| **B** *(rec)* | title left, actions right (Receive · Send · Export · view toggle) | **Existing** — `GWPageHeader` already has a `trailing` slot; Markets fills it with a search icon (`markets_screen.dart:75`) | none; the open question is *which* actions |
| **C** | B plus a quiet subtitle line (active wallet / date range / "All activity") | Adapted — a subtitle line on `GWPageHeader` | one line; pairs with B |
| **D** | title aligns to the LIST card, rail gets its own `Filters` head | New | header rework; title leaves the true page-left edge |
| **E** | title + actions inside a full-width surface band | New | diverges from every other tab (Markets/News/Swap all use a bare header) — an app-wide decision, not this page's |

## Why B

It is the only option that is **both already-built and consistent with the sibling tabs**, and it
fixes the exact complaint — the empty header row — by putting the toolbar the old design floated over
the panel (Receive/Send/export/view-toggle, visible in the pre-redesign screenshots) where a
scanning eye expects it: title left, actions right, the Markets shape.

**The open question B leaves is content, not layout: which actions belong up there.** Default
proposal: Receive, Send, Export, and a list/compact view toggle. That is a separate small decision —
each action needs a real destination, and a header action with nowhere to go is worse than no action.

## Why not the others

- **D** labels each column, which is tidy, but it pulls the title off the page-left edge so it no
  longer lines up with the navbar's left — a misalignment some will read as a bug.
- **E** has the strongest presence but adds a third surface tone above two cards and makes
  Transactions the only tab with a banded header. If the whole app ever moves to banded headers it
  becomes the right answer; alone it is inconsistency.

## Contrast

No new colour decisions — every treatment uses existing tokens (`textPrimary` title, `textSecondary`
subtitle and icon glyphs, `surfaceMenu` icon buttons). The action pills reuse the border/menu
surfaces the rail and chips already use, so AA is inherited, not re-derived.
