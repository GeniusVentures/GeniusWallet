# Superseded: 21-02 through 21-06, retired 2026-07-30

These five plans were retired **before execution**, and replaced by a re-plan against the tree as it
actually stood on 2026-07-30. **The design contract they implement is NOT superseded** — sketches
030/031/032/033/034 in `.planning/sketches/drawers-final/`, the four content patterns, and the
`154-transaction-details-drawer` variant A decision all still stand. What rotted was the *file
inventory* and the task breakdown, not the design.

## Why

Work landed in this repo outside GSD tracking between these plans being written and being run, so
they describe a codebase that no longer exists. Measured 2026-07-30:

| Plan | Drift found |
|---|---|
| 21-02 | 2 of its 4 targets were already converted — `network_dropdown_selector.dart` and `sdk_account_manager.dart` already consume `GWSelectRow`. `account_dropdown_selector.dart` and `bridge_screen.dart` had not been. |
| 21-03 | Substantially done — `transaction_displays.dart` already carried 5 references to `GWKicker`/`GWDetailGrid`. |
| 21-04 | **Substantially invalid.** `lib/squid_router/swap_success_drawer.dart` and `swap_fail_drawer.dart` do not exist: commit `9ff7c04` (`feat(08-05): delete the three superseded swap drawers, repoint dev bubble to the shared receipt (D-06)`) deleted them a whole phase earlier. Meanwhile `buy_success_drawer_content.dart`, which this plan lists as a file to CREATE, already existed. |
| 21-05 | Accurate — the two reown confirm drawers were genuinely untouched. |
| 21-06 | Targets exist; state unverified at retirement time. |

## The same drift hit 21-01, which is why it is NOT here

21-01 executed and shipped (`e108553`, `e752fd4`, `20b85c2`, `cf65879`). Its executor found that
Jakub's direct commits `8044bdb` ("the shell owns its insets, and the panel becomes a card") and
`d7903fc` ("five base components promoted, and two refusals recorded") had already delivered most of
its Tasks 1 and 2 — the shell's padded body as `ResponsiveDrawer.bodyPadding` defaulting to
`kDrawerBodyPadding` (an opt-OUT, better than the plan's proposed opt-IN `padBody` bool), plus
`GWSelectRow`, `GWKicker` and `GWDetailGrid` with consumers and tests already in place.

Rather than rebuild those under the plan's names, it verified each must-have against what shipped and
built only the genuine gaps: mobile bottom-sheet coverage for the already-shipped inset,
`GWDrawerStatusPill` + `GWDrawerReceiptHead`, and inlining the token picker's row wrapper into
`GWSelectRow`. It then explicitly recommended re-checking the later waves before running them. That
recommendation is what produced this directory.

## Lesson worth carrying

A plan's *design decisions* age well; its *file inventory* does not. When a repo takes commits outside
the planning system, re-measure targets at execution time rather than trusting a `files_modified`
list. 21-01's executor did exactly that and was right to.
