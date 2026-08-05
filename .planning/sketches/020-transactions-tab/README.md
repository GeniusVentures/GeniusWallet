# 020 · Transactions TAB — page layout, filter placement, empty states

**Design question:** the Transactions tab is a full page, but it renders the dashboard *panel*. What
should the page be — and where should the empty state sit, in both the page and the panel?

**Status:** 3 variants + 3 empty-state treatments, awaiting Jakub's pick.
**Recommendation:** **B · Filter rail** for the tab, **E3 · Anchored + a way out** for both empty states.

---

## The finding that reframes the request

This is not "the tab looks weak". `transactions_screen.dart:26-33` is:

```dart
Center(child: Padding(padding: EdgeInsets.all(16), child: TransactionsStream()))
```

…and `TransactionsStream` mounts `TransactionsSlimView`, which is a **panel**: it caps itself at
`GeniusBreakpoints.medium` (768) at `transactions_slim_view.dart:177` and heads itself with
`GWSectionTitle` — the 18px panel header with the shared 44px min-height, built to sit inside a card
beside Assets and Markets.

Compare the sibling tab, `markets_screen.dart:66-73`: `Center → Padding → ConstrainedBox(maxWidth:
xxl /* 1536 */) → Column [GWPageHeader(24px), grid whose column count scales with width]`.

So there are four concrete defects, not one impression:

| # | Defect | Evidence |
|---|--------|----------|
| 1 | Page capped at **768px**, ~630px dead on each side of a 2000px window | `transactions_slim_view.dart:177` |
| 2 | Page titled with an **18px panel header** instead of the 24px `GWPageHeader` every other page uses | `transactions_slim_view.dart:192` vs `markets_screen.dart:73`, `crypto_news_screen.dart:50`, `swap_screen.dart:228` |
| 3 | List sits on **raw `surface-base`** — the dashboard wraps the identical widget in `DashboardScrollContainer` | `dashboard_screen.dart:322` |
| 4 | Empty state pinned to the **vertical midpoint** of a ~1400px slot | `gw_empty_state.dart:129` (`Center`) fed an `Expanded` at `transactions_slim_view.dart:208` |

Plus one behavioural bug visible in the empty screenshot: **the filter bar renders on a wallet with
zero transactions** — five controls offering to filter nothing. The branch that knows this is already
there (`transactions_slim_view.dart:246`, `scoped.isEmpty`); it just doesn't reach the header.

---

## The variants

### A · Page frame — the honest minimum

Stops chasing width. Settles the list at `GeniusBreakpoints.large` (1024) and *frames* it in the same
card the dashboard uses, so the surrounding space reads as margin rather than abandonment.
`GWPageHeader` replaces `GWSectionTitle`; the filter bar rides in its trailing slot, where Markets
puts its search.

- **Existing, unchanged:** row, badges, filter bar, dividers, day labels, footer count.
- **Adapted:** `GWPageHeader` + `DashboardScrollContainer` at a new call site; one width constant.
- **New:** nothing.
- **Cost:** ~15 lines, `transactions_screen.dart` only. No test churn.

### B · Filter rail — recommended

The `⋯` overflow menu exists *only* because a 376px panel cannot show nine filters. A page can. The
rail **is** that menu, unrolled: `_menuItem` (`transactions_slim_view.dart:498`) already renders
exactly glyph + label + live count at a 40px row, so the rail is those same rows in a Column instead
of a popup. The width goes to something actionable rather than to a gap between a hash and a number.

- **Existing:** row, badges, dividers, day labels, `filterCounts()`, `badgeGlyph()`, the menu-item anatomy.
- **Adapted:** `GWPageHeader`, `DashboardScrollContainer`.
- **New:** one private `_FilterRail` (~60 lines).
- **Cost:** A plus ~60 lines. Row untouched.
- **Named risk:** two filter presentations then exist — chips on the panel, rail on the page. That is
  the standard responsive answer, but it *is* a divergence and should be a deliberate decision.

### C · Wide table

The only variant that actually spends 1536px: at ≥1280 the row's stacked title/subtitle unstacks into
real columns (Time · Asset · Type · Detail · Amount · Value · Status) with a header rule.

- **Cost:** a second row layout in `transaction_displays.dart`, a column-header row, a status pill,
  and tests pinning both layouts.
- **Named risk:** breaks Phase 12's just-locked *one anatomy for all seven types*, and the detail
  drawer would disagree with the row it was opened from. Right answer for a different product.

---

## Empty states — the page and the panel share one disease

`GWEmptyState` centres in whatever slot it is given, and both slots are tall.

- **E1 · Centred** — today. In the ~1400px panel the icon lands 700px down with ~260px of visible
  void above and below, and branch 1 is a dead end with no action.
- **E2 · Anchored** — the block sits where the first row would sit. One property inside
  `GWEmptyState`: `Center` → `Align(topCenter)` plus `space16`. Plus hiding the filter bar when
  `scoped.isEmpty`.
- **E3 · Anchored + a way out** — **recommended.** E2 plus real next steps: `Receive` (primary) and
  `Buy GNUS` (secondary). `GWEmptyState` already supports one action (`actionLabel`/`onAction`); a
  second slot is the only addition.

**Branch 2 is deliberately untouched.** A filter that matched nothing keeps "Show all" and must never
say Buy GNUS — that wallet is not empty. The rule is already written at
`transactions_slim_view.dart:255` and stays.

---

## Recommendation

**B for the tab, E3 for both empty states.** B is A with ~60 extra lines and is the only cheap variant
that turns the width into something usable. If the two-filter-presentation divergence is unwelcome, A
ships in twenty minutes and nothing is lost — **B is a strict superset of A**.

C is not recommended: it costs the one-anatomy rule Phase 12 just paid for.
