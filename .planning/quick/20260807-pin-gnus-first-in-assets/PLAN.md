---
quick_id: 260807-gns
slug: pin-gnus-first-in-assets
date: 2026-08-07
branch: redesign/navigation-260806
status: in-progress
---

# Pin GNUS first in Assets

Jakub, 2026-08-07, asked directly and chose: **pin GNUS first, on both surfaces.**

Restores a rule lost in phase 25. Before 25, the dashboard Assets panel partitioned
GNUS to the front absolutely. When 25-01 adopted 25-02's shared `compareAssetsByValue`,
GNUS was demoted to a tie-break (step 4). On an all-zero wallet every priced row ties at
value 0, so GNUS still appeared first and the reversal was invisible to a walk - it only
shows on a funded wallet, where a larger holding outranks it. `coins_screen.dart:259-265`
flagged the reversal as a real change worth naming; this task is the answer to that flag.

## Scope

Change `compareAssetsByValue` in `lib/dashboard/assets/assets_sort.dart` **only**. Both
consumers - the dashboard panel (`coins_screen.dart`, projection to `AssetRowData`,
`take(5)`) and the `/assets` page (`assets_screen.dart`) - sort through it, so the single
edit moves both surfaces together. That shared authority is the design; keep it.

GNUS becomes an **absolute first-rank key**, ahead of the existing unpriced-vs-priced
tiering, not a tie-break.

## Decision to make and document

What ascending does with the pin. Recommendation carried into the doc comment, with the
rejected alternative named and reasoned. Also document: wallet holding no GNUS, and GNUS
held at zero balance. Verify empty / all-zero render paths before deciding.

## Tasks

1. Reorder `compareAssetsByValue` to put the GNUS check first; rewrite the doc comment
   (ordering steps, ascending decision + rejected alternative, no-GNUS and zero-balance
   GNUS behaviour).
2. Add cases to `test/dashboard/assets_sort_test.dart` for the pin. Additive only - do
   not weaken existing cases.
3. Report any hard-coded expectation elsewhere that encodes the old rule. **Do not edit
   the panel-equals-page-head contract test to make it pass - report instead.**

## Fences

- Do NOT touch `lib/components/coins/view/coins_screen.dart`,
  `lib/components/cards/gw_section_title.dart`, `lib/components/cards/gw_view_all_link.dart`
  (parallel executor owns them). Do NOT touch `lib/dashboard/assets/assets_screen.dart`
  unless the comparator genuinely cannot carry the rule - report first.
- **Do NOT create commits** (standing CLAUDE.md rule, overrides the workflow commit step).
- Mobile only, dark mode first. No em dashes anywhere including comments.
- Nothing under `/banxa` or `/squidrouter`.
- Tree is already dirty from today's work, so `git status` is not a fence check - hash
  fenced files instead.
- Do not kill, restart or hot-reload the running flutter session.

## Gates

- `flutter analyze` ends at **0 issues**.
- `flutter test` baseline measured before starting. Nothing may break.
