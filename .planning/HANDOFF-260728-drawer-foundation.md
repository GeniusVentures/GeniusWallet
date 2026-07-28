# Handoff - 2026-07-28, executor session: the drawer foundation

**Role:** EXECUTOR. `lib/`, `test/`, `.planning/STATE.md`, `MANIFEST.md` all written. **No commits**
(`CLAUDE.md` forbids them; the tree carries three sources' work).

## Where the branch is

PR **#216 merged** into `ui-redesign-port` on 2026-07-27 07:29 by Braian. Local branch
`redesign/jakub-260726b` is 1 behind (that merge commit) and holds nothing unpublished. **A new
branch cut from `origin/ui-redesign-port` is the right move before the next PR** - the current one's
PR is closed.

## What shipped today (uncommitted, in the tree)

| Quick | What |
|---|---|
| **260727-w58** | `GWKicker` (sketch 065-C) + all 5 hand-rolled uppercase labels migrated |
| **260728-0vd** | Drawer shell owns body + footer insets; `✕` on the title axis; `View on Explorer` → `gradientOutline`; CTA-weight rule deleted from `AGENTS.md` + `CONVENTIONS.md` |
| **260728-13f** | Markets hero shadow clearance (gutter moved inside the scroll viewport) |

Gates held all day: `analyze lib` **59** (baseline 59), `flutter test` **332 / 1** - the single
failure is the inherited `test/local_wallet_storage_test.dart`, a file with no `main()`.

## Sketches written today

- **065** kicker-component - winner **C** (two steps, no rule). Built.
- **066** drawer-language - five archetypes for the remaining 14 drawers, accepted. Not built.
  Carries `index-065d.html` as the with-a-rule comparison.
- **067** section-grammar-real-components - winner **A** (kicker only). Not built. Its finding is
  the load-bearing one: **a card on a drawer panel fails on arithmetic** - `GWCard` measures 1.11:1
  today and **1.00:1 after 156-A**, and the first edge to pass WCAG 1.4.11 is white **36%**.

MANIFEST rows appended for 065, 066, 067.

## THE NEXT TASK - agreed with Jakub, in this order

1. **067-A** - Swap Settings' `'Slippage tolerance'` label becomes `GWKicker('Slippage tolerance')`,
   default 13 step. Currently a `Text` with `labelMd`/w600 sentence case in
   `swap_settings_drawer.dart`. **This is one widget.**
2. **156-A · Card canvas** - the bigger half, and it touches all ~19 drawers:
   - panel `gw.surfaceMenu` → `gw.surfaceElevated` in `responsive_drawer.dart` (`:139`, `:58`, `:82`)
   - the field goes **UP** to `surfaceMenu` (it becomes the lighter object on a darker panel)
   - field edge to white 30% - measured at **3.02:1** against the panel, which passes 1.4.11
     (`Border.all` paints INSIDE, so it blends with the field, not the panel - measuring it the
     other way gives 2.63 and is wrong)
   - **Known knock-ons, all named by sketch 156 itself:** `token_selector_drawer.dart`'s selection
     tint sits on this canvas and needs re-measuring; `GWFocusRing` is passed
     `background: gw.surfaceMenu` at **four** call sites of which **two** are in drawers; the
     `brandPrimarySubtle` header hairline (`responsive_drawer.dart:201`) was tuned against `#171A21`.
   - **The one thing only a live look can settle:** once the panel is `#0C0E14` the transaction
     receipt stops being distinguishable from the cards behind it. That is intended ("the drawer
     becomes a card") but it is the change nobody has seen.

## Still unanswered by Jakub

- **154-D** - does the receipt take tap-to-copy rows and 4-char address groups? Recommended yes,
  built as `GWChunkedAddress(address, groups: 4)` so it serves the receipt and the Receive drawer
  (159-A) at once. There are **ten** hand-rolled `Clipboard.setData` call sites and a dead
  `CopyButton` with zero uses.
- **161 / 162 / 163 / 159** - still `winner: null`. **162 withdraws 161's recommendation itself**,
  so taking 162's rule closes both.
- The Markets fix (**13f**) is **unconfirmed on screen** - see its SUMMARY for the fallback
  hypothesis if the card still reads as cut.

## The walk that keeps being deferred

~19 drawers have not been looked at since the shell header change, and today's shell work touched
every one of them again. Jakub's recorded instruction from 2026-07-27 was that the session would
*start* with that walk; three sessions later it still has not happened. Everything above lands on
those same panels.

## Two things worth not re-deriving

- **`AppBar` adds its own 6px to the actions slot.** Pinned by a test, but it will surprise the next
  person who does the arithmetic.
- **A scroll viewport clips.** Both of today's padding bugs - the drawer body and the Markets hero
  shadow - are the same mistake in different clothes: an inset placed outside a clipping viewport
  does nothing for what is inside it.
