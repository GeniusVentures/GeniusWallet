# 027 · Gap between the navbar and the page title

**Design question:** the title stays — only the vertical gap between the 68px navbar and the 28px
page title. Today it is cramped.

**Status:** four gaps, awaiting Jakub's pick.
**Recommendation:** **32px (`space16`)**, applied to Transactions, Markets and News together.

## Grounded

- Navbar height is `appBarHeight = 68` (`responsive_overlay.dart:184`).
- The gap today is `vertical: 8` (`transactions_screen.dart:66`) — `space4`. That is why the title
  reads glued to the nav.
- **Shared:** Markets (`markets_screen.dart:68`) and News (`crypto_news_screen.dart:44`) use the
  same 8. So this is an app-alignment decision, not a Transactions-only tweak — change one and it
  diverges from its siblings; change all three and the app keeps one rhythm.

## Options (all 4-pt tokens, no off-grid values)

| Gap | Token | Verdict |
|---|---|---|
| 8 | `space4` | Today — cramped, title glued to the nav. |
| 24 | `space12` | Correct and safe; echoes `GWSectionTitle`'s own title→content gap. |
| **32** | **`space16`** | **Recommended.** The 4-pt grid's "new region" step; at a 28px title it lands as deliberate whitespace, and the title reads as a page heading rather than a caption. Best balance of air and laptop economy. |
| 40 | `space20` | Spacious; only if maximum breathing room matters more than laptop vertical space. |

## Recommendation

**32 (`space16`), applied to all three sibling tabs** so Transactions, Markets and News keep one
rhythm. If the sibling tabs should not move yet, 32 on Transactions alone is fine and the others can
follow later — Jakub to say whether it is 24 or 32, and whether it lands app-wide or Transactions-only.

## Process note (for future sketches)

Jakub flagged that 023–026 had regressed to tiny `transform: scale()` mockups, "impoverished" vs the
earlier ones (011/014/021/022). This sketch returns to the richer format he approved: **real-size
render, real navbar, a measured ruler on the actual thing, 4-pt-token annotations, provenance from
the codebase, one recommendation with its cost.** Keep this bar for every sketch going forward — no
scaled thumbnails when the decision is about pixels.
