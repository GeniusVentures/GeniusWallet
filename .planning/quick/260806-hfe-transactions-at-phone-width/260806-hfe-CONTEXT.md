# Quick Task 260806-hfe: Transactions at phone width - Context

**Gathered:** 2026-08-06
**Status:** Complete

<domain>
## Task Boundary

`/transactions` rendered below 768px, plus the frame values it shares with every other page that
mounts a `GWPageHeader`. First screen of a mobile pass across the app.

**Out of scope:** `_page`'s desktop two-card rail, every filter/amount/badge *rule*, light mode
(deferred project-wide since Phase 08), and every other screen's content.

</domain>

<decisions>
## Implementation Decisions

### Design approach — LOCKED
- **No sketch, no new design.** Braian, verbatim: *"we dont need to do a sketch because we should
  reuse the same components and just make them looking good."*
- No design contract of its own; it inherits Phases 12+15's. Every component already ships:
  `GWSectionTitle`, `_TransactionFilterBar`, `TransactionRow`, `GWEmptyState`,
  `DashboardScrollContainer`.
- **Layout may change. Rules may not.**

### Ownership — LOCKED
- Phases 12+15 stay canonical for the transactions surface and are **not reopened**. Touching only
  the sub-768 branch is what keeps this from becoming the second owner the roadmap's surface
  ownership map exists to prevent.

### Mobile-only — LOCKED (corrected mid-task)
- Every change gates on `!GeniusBreakpoints.useDesktopLayout(context)`. Desktop, including the
  dashboard's transactions panel, keeps every original value.
- Braian caught the first pass leaking into desktop: *"you are changing the font sizes and not
  letting them as it was in desktop fix that all our changes are for mobile."*

### Verification method
- Resize the Windows debug build. **Accepted limitation:** `isMobileApp()` is false on Windows, so
  this exercises the **width branch only** — safe-area insets and real touch behaviour are not
  verified. `android/` and `ios/` exist but have never been built here.
- Widget tests cover the two branches a live walk kept missing.

</decisions>

<canonical_refs>
## Canonical References

- `lib/dashboard/home/widgets/transactions_slim_view.dart` — `_page`/`_panel`, the filter bar
- `lib/dashboard/home/widgets/transaction_displays.dart` — `TransactionRow`
- `lib/dashboard/transactions/transactions_screen.dart` — page frame
- `lib/utils/breakpoints.dart` — `pageTitleGap` / `pageGutter`
- `.planning/phases/15-transactions-tab/deferred-items.md` — the overflow table this task closes
- `AGENTS.md` — brace rule, widgets-not-helpers, tokens-only colours

**Constraint:** freeze rule (`37639d5`, `test/chart/compact_price_font_size_test.dart`) — no
dimension derived continuously from constraints. `FittedBox`/`AutoSizeText` barred.

</canonical_refs>

<deferred>
## Deferred

- The remaining screens of the mobile pass — the shared `pageTitleGap`/`pageGutter` helpers already
  reach all seven page-header screens, so their *frames* are done; their content is not.
- The desktop dashboard panel's tag truncation — same shared `TransactionRow` narrow branch, left
  alone because this task is mobile-only.
- 48dp Android touch targets (44pt iOS is met).
- Light mode.

</deferred>

---

*Quick task: 260806-hfe*
