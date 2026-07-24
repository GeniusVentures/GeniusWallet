---
sketch: 151
name: news-search-refresh
question: "How should the News search bar + refresh/freshness stamp look when composed as one header pair?"
winner: null
tags: [news, search, refresh, header, re-skin]
---

# Sketch 151: News — Search + Refresh (header pair)

## Design Question
Both controls are real and wired in `lib/dashboard/news/view/crypto_news_screen.dart`:
- **Search** — `GWSearchField`, a debounced (220ms) local filter over the fetched
  list; gradient CTA focus ring, `search` prefix, clear ✕ suffix.
- **Refresh** — `_UpdatedStamp`, a re-fetch button paired with an "Updated Xm ago"
  freshness stamp (own 30s ticker; "Updating…" until first fetch).

So this is a **re-skin, not a rebuild** — nothing here removes functionality.
Sketch 031 shipped them **split** (search full-width under the title, refresh
top-right). 031 never composed the two *together*. This sketch does, across a
boldness gradient.

## How to View
open .planning/sketches/151-news-search-refresh/index.html

Click a field → gradient focus ring (real `brandCta` stops). Click ⟳ → spins +
resets the stamp. Toggle Dark/Light top-right.

## Variants
- **A: Polished split** *(safe · least code)* — today's layout kept
  (`GWPageHeader.trailing` + `GWSearchField` below); adds a live freshness dot.
  Pure style pass; does **not** move the pair together.
- **B: One toolbar line** *(medium)* — search grows to fill, refresh pill docked
  at the right end of the **same row**; staleness stamp stays up by the title.
- **C: Docked** *(bold · one unit)* — refresh + green age ("3m ⟳") live **inside**
  the search field's trailing slot, past a hairline divider. Frees the title row.
- **D: Command bar** *(boldest)* — search + a **live pulsing status chip** +
  refresh in one elevated gradient-ringed pill; reads like a command palette.

## What to Look For
- Does the pair read as **one thing** (B/C/D) or is split (A) actually fine?
- Density: C and D pack search + clear + refresh into one control — too crowded?
- The **live pulsing dot** (D) is portable — worth stealing into B or C.
- D is intentionally loud: does it fight the photo magazine below it?

## Recommendation
**B** — fixes exactly what was flagged (pair now sits together) with almost no new
code; keeps the staleness stamp where the eye lands first. **C** if you want the
tightest single-control feel. **A** as fallback if split was fine. **D** to see how
far bold goes (probably too loud, but borrow its live dot).
