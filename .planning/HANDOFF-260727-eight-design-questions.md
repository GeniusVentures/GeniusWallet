# Handoff - 2026-07-27, design session: eight open questions

**Role:** DESIGN session (not the executor). Nothing under `lib/`, `test/`, `macos/` or `packages/` was
touched. No commit was made. The shared planning files - `ROADMAP.md`, `STATE.md`,
`sketches/MANIFEST.md`, `HANDOFF.json` - were **read and not written**, per the parallel-session rules in
`CLAUDE.md`. Each new sketch carries its own MANIFEST row at the bottom of its README, ready for the
executor to append.

**Lane:** B (150-199). Numbers used: **155, 156, 157, 158, 159**. Nothing in 000-149 was taken.

## What was asked

Jakub, morning of 2026-07-27, eight items with screenshots, plus: *design what can be designed, produce a
status PDF for resuming, work in the background without questions, and change nothing - execution happens in
the evening.*

## What was produced

| New | Subject | Outcome |
|---|---|---|
| **155** assets-balance-value | The Assets panel total (item 1) | 5 variants, rec **A · Value + chip** |
| **156** drawer-canvas-colour | Drawer surface colours (item 4) | 6 schemes, rec **A · Card canvas**, with measured contrast |
| **157** buy-gnus-page | The whole Banxa flow (item 7) | Analysis + 14 defects + 5 variants, rec **A + E** |
| **158** global-fab-placement | The floating swap button (item 8) | 6 placements + 4 skins, rec **P1 + S1/S2** |
| **159** receive-drawer | Receive (item 6) | 5 panels, rec **A · finish 034-A2** |

| Also written | |
|---|---|
| `.planning/STATUS-2026-07-27.pdf` | 8-page status report - the requested resume document. Source HTML beside it. |
| 6 todos in `todos/pending/` | the independently-fixable defects found while reading the code |

Items **2, 3 and 5** needed no new sketch - they were already designed. That is recorded rather than
re-drawn:

- **item 2** (balance + compute panel) - sketches **016-B2 / 017-A / 018-A** are all chosen and **none is
  built**. This is a planning item, and its three sketches name three bloc changes it needs.
- **item 3** (transaction drawer) - sketch **154** exists with five variants; rec **A · 031-B1 as decided**.
- **item 5** (coin page) - **152** decided the inside and is implemented; **061** (the chrome) is open, rec
  **A · In the app frame**.

## The five findings worth not re-deriving

1. **"Buy GNUS" opens the order history.** `coins_screen.dart:349` pushes `/buy`; `router.dart:80` maps
   `/buy` to `OrdersPage`. The buy form is at `/createOrder`, reachable only via a "+ New Order" text action.
   The zero-balance CTA is the only place this button appears, so it fails exactly the users it exists for.
2. **The Banxa order list fetches with `'your-cust-id'`**, hardcoded at two call sites. "Total Orders: 0" is
   a stub, not an empty account - so no design of that list can be judged on real data yet.
3. **The drawer field is painted the same colour as its panel.** Both are `gw.surfaceMenu`; fill contrast
   **1.00:1**, and the 12% hairline that is its only boundary measures **1.43:1** against WCAG 1.4.11's 3:1.
   White at 30% is the first step that clears it. Also: `surfaceMenu #171A21` is two steps lighter than every
   card (`#0C0E14`) and the page (`#0B0D12`) - which is the whole of "niekompatybilne z reszta", in hex.
4. **The FAB's `bottom: 80` clears `_MobileTabBar`, which `DesktopOverlay` never mounts.** 60 of those 80
   pixels avoid nothing on desktop, against a 20px right gap.
5. **The same dollar figure is printed twice on the dashboard's top row, from two sources** -
   `selectedWalletBalance` in the left card and `assetsTotal()` in the Assets header. They agree only because
   `injectMockCoins` sets both.

## Two defects that are one defect each

- **Zero body padding in drawers.** The shell passes `body: child` through and adds none, although 030-B1
  specified 20px. It shows in the transaction drawer (154 finding 1) **and** the Receive drawer (159 drift
  2), and potentially in any of the other seventeen. Fix once in `responsive_drawer.dart`, during the walk.
- **Routes outside `ShellRoute`.** The coin page (061) and all seven Banxa routes (157) have no navbar. One
  edit closes both - todo filed, including which four routes should deliberately **stay** outside.

## Where this lands against what was already queued

`HANDOFF.json` already names the next session's first task: **walk the ~17 drawers nobody has seen since the
shell header change**. Three of today's items (3, 4, 6) land on exactly those nineteen panels. The order that
avoids doing the work twice:

1. walk with today's colours, record the whole list, fix nothing
2. then, together: body padding in the shell, the 156 colour change, 154-A, 159-A
3. re-walk the same list

## Suggested order for the evening (full reasoning in the PDF)

1. Repoint `/buy` - one line, biggest single improvement on the list
2. FAB gutter (158-P1) - one expression, no blast radius
3. The drawer walk
4. The drawer trio (padding + colour + receipt + receive)
5. Assets header (155-A) - self-contained, one call site
6. The `ShellRoute` edit - closes the navbar half of items 5 and 7
7. Buy GNUS and the compute panel are **phases**, not evening tasks

## One question for Braian, not for a pick

Whether `lib/banxa/` is genuinely regenerated by a tool, or whether the `CLAUDE.md` note is stale. It changes
the size of item 7 substantially: if the fence can be lifted for the three widget files, the redesign lands
with a much smaller diff than re-hosting the UI under `lib/screens/`. Sketch 157 section 5 describes both
paths; the layering (models / service / cubits are data, three files are presentation) means the redesign is
possible either way.

## Verification

All five sketches rendered clean in headless Chrome for Testing
(`~/Library/Caches/ms-playwright/chromium_headless_shell-1228/`), checked visually at 1440px, dark. Two
render bugs were found that way and fixed: a CSS class collision that hid the findings text, and inline spans
in 157's flow map. The status PDF is 8 pages, generated with `--print-to-pdf` from the same binary.

Every claim about the code in the sketches, the todos and the PDF cites a file and a line, and was read this
session - none is carried over from an earlier summary.
