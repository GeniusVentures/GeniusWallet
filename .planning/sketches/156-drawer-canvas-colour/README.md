---
sketch: 156
name: drawer-canvas-colour
question: "The drawer is the lightest large surface in the app and its input field is painted the same colour as the panel it sits on. What colour is a drawer?"
winner: "A \u00b7 Card canvas - chosen by Jakub 2026-07-27 together with 067-A. BUILT 2026-07-28 (quick 260728-q7c), with three corrections: the field edge is white 36% (3.30:1), not the 30% proposed here (2.63:1); the panel gained a borderStrong hairline because #0C0E14 against the scrimmed page is 1.05:1; and on the live walk the field fill went DOWN to surfaceSunken (this sketch's own scheme C) rather than UP to surfaceMenu - A's 'lighter object on a darker canvas' read as a raised tile, not as an input."
tags: [drawers, colour, surfaces, tokens, contrast, wcag, responsive-drawer, swap-settings, follows-030, follows-063]
lane: B
---

# Sketch 156: What colour is a drawer?

Jakub, 2026-07-27: *"Ten drawer jest ok, ale chodzi mi o kolory... poprobuj cos, wydaje mi sie ze
ciemniejsze trzeba, bardziej kompatybilne z reszta"*.

The **shape** of this drawer is settled - sketch **063-A** (presets + validated custom field, Apply in the
shell footer) shipped on 2026-07-27. Nothing structural moves here. This is a colour question only, and it
turns out to have a measurable answer.

## How to View

```
open .planning/sketches/156-drawer-canvas-colour/index.html
```

Deep links `#a` .. `#e`. Six schemes in the toolbar, each a pure token swap on the same panel. The app behind
is drawn at its real colours, and **Dimmed / Full** toggles the barrier so the panel can be judged both with
and without the scrim flattering it. A measured contrast table sits under the stage.

## Findings from the code

1. **The drawer is the lightest large surface in the app.** `responsive_drawer.dart:139` (and `:58`, `:82`)
   paints the panel `gw.surfaceMenu` = **#171A21**. Every card is `surfaceElevated` **#0C0E14**; the page is
   `surfaceBase` **#0B0D12**. The drawer is roughly two steps lighter than anything it ever opens over, and
   it is the only large surface at that value. That is "niekompatybilne z reszta", in hex.
2. **The field is painted the same colour as its own panel.** `swap_settings_drawer.dart:193` passes
   `background: gw.surfaceMenu` into `GWFocusRing`, and the panel is already `surfaceMenu`. Fill contrast:
   **1.00:1**. The input is not a box, it is a hairline - which is exactly how it reads in the screenshot.
3. **That hairline measures 1.43:1.** `borderSubtle` is white at 12%, compositing to #33363C over #171A21.
   When a hairline is the *only* thing identifying an input, WCAG 1.4.11 asks for **3:1**. Working backwards
   on this canvas, **white at 30%** is the first step that clears it (3.0:1 over #0C0E14).
4. **Two dark fills can never carry an input boundary by themselves.** #171A21 on #0C0E14 is **1.11:1**;
   #06080C on #0C0E14 is 1.04:1. On a dark canvas the border does the identifying and the fill only sets the
   mood. So the answer has to be a pair - darker panel **and** stronger field edge - not either alone.
5. **A darker panel is also a small AA gain.** White text 17.4 to 19.3:1, `textSecondary` 5.4 to 6.0:1.
   Nothing was failing; it is not the argument, but it is not nothing either.

## Schemes

- **0 · Today** - `surfaceMenu` panel, `surfaceMenu` field, 12% hairlines, `black54` barrier.
- **A · Card canvas ★** - panel to `surfaceElevated #0C0E14`, field **up** to `surfaceMenu #171A21`, field
  edge to white 30%. The drawer becomes a card and the field becomes a lighter object on a darker surface,
  which is the direction the rest of the app already reads in.
- **B · Page canvas** - panel to `surfaceBase #0B0D12` plus a left hairline. Deepest; the drawer reads as a
  slice of the app rather than a sheet on top.
- **C · Sunken field** - panel untouched, field to `surfaceSunken #06080C` with a 30% edge. Touches **one
  drawer**, not nineteen.
- **D · Sheen card** - A plus `GWDecorations.surfaceSheen`, the top-lit gradient the tab bar and cards use.
- **E · Scrim first** - the panel is fine, the app behind is not dark enough: `black54` to `black72`.

## Recommendation

**★ A · Card canvas**, taken as a pair: `surfaceElevated` panel **and** a white-30% field edge.

It answers both halves of the request with one move. "Ciemniejsze" is literal - #171A21 to #0C0E14.
"Kompatybilne z reszta" is literal too - the drawer stops being a value that exists nowhere else and becomes
the same colour as every card on the dashboard. And it inverts the field relationship: today the field is the
same as the panel; in A the field is the lighter object, which is how a control on a card reads everywhere
else in this app.

**It is one line in `responsive_drawer.dart`. That is the whole risk.** That line re-skins all ~19 drawers
simultaneously, and ~17 of them have not been looked at since the header change on 2026-07-27 - the walk that
`HANDOFF.json` already lists as the next session's first task. **This should ride that walk, not precede it.**
Concretely: do the walk first with today's colours, record the list, then apply A and re-walk the same list.
Two passes over the same 19 panels, not one blind change.

**If the walk cannot happen tonight, take C.** It is the only scheme scoped to a single drawer, it fixes the
1.00:1 field outright, and it is not a decision that blocks A later - A can absorb it. Its honest limit is
that its 30% edge still lands at 2.8:1, because the panel it sits on stays light; that is precisely the
argument for A.

**D is A plus a decoration** and can be decided after A is live. The one thing to check is that the sheen
falls off over ~180px, not the ~60px it uses on the tab bar - on a full-height 420px panel a short falloff
turns into a visible band.

**B is the most beautiful and the least safe.** A panel the same colour as the page has no depth of its own;
it depends entirely on the scrim and one hairline. Turn **Dimmed** off in the sketch and B and the page merge.

**E is a real observation and the wrong lever.** Darkening the barrier does make the drawer sit better, and
it is one line with zero blast radius, so it is worth trying. But it wins the argument by hiding the rest of
the app rather than by matching it.

## What to Look For

1. **Switch 0 to A and watch the field, not the panel.** The panel change is obvious; the field going from
   invisible to a real box is the bigger improvement.
2. **Turn Dimmed off on every scheme.** The scrim flatters the light panel. Without it, 0 and B are the two
   extremes and A sits where the app already lives.
3. **Compare A and D with the body empty.** The sheen has nothing to fall off against in a short drawer.
4. **C against A.** C is what ships tonight if the walk slips. Is "fixed field, same bright panel" enough?
5. **The preset chips.** Their unselected state is `GWDecorations.hover` at 12% - on a darker panel they get
   quieter. If they read as disabled in A, the chip border wants the same 30% the field got.

## Knock-on to check before executing

- `token_selector_drawer.dart` (032-A1) uses a selection tint over the same canvas; a darker panel changes
  how that tint reads.
- `GWFocusRing`'s `background:` parameter is passed `gw.surfaceMenu` at **four** call sites (swap amount
  card, slippage field, token search, feedback message). Only the two inside drawers are affected by A; the
  other two sit on page canvases and must not be changed with them.
- The `brandPrimarySubtle` header hairline (`responsive_drawer.dart:201`) is tuned against #171A21. On
  #0C0E14 it gets slightly more visible, which is probably an improvement - but it is a change, and the walk
  should confirm it rather than assume it.

## MANIFEST row

Design session, so per `CLAUDE.md` this did not write `.planning/sketches/MANIFEST.md`. Row to append:

```
| 156 | drawer-canvas-colour | The drawer panel is `surfaceMenu` #171A21 - the lightest large surface in the app, two steps lighter than the cards and the page it opens over - and its input field is painted the SAME colour as the panel. What colour is a drawer? | _pending pick_ (rec **A · Card canvas** - panel to `surfaceElevated` #0C0E14, field UP to `surfaceMenu`, field edge to white 30%; answers "ciemniejsze" and "kompatybilne" in one move and is one line in `responsive_drawer.dart` - which is also its whole risk, because that line re-skins all ~19 drawers and ~17 are unwalked. Take **C · Sunken field** instead if the drawer walk slips - single-drawer scope, fixes the field, does not block A. **D · Sheen card** = A + `surfaceSheen`, decide after A. **B · Page canvas** deepest but merges with the page without the scrim. **E · Scrim first** = `black54` to `black72`, real but wins by hiding the app). Measured: field fill vs panel **1.00:1**, field edge vs panel **1.43:1** against WCAG 1.4.11's 3:1, and white-30% is the first step that clears it. | drawers, colour, surfaces, tokens, contrast, wcag, responsive-drawer, swap-settings, follows-030, follows-063 |
```

## Built 2026-07-28 - quick 260728-q7c, with two corrections

**The 30% edge in finding 3 is wrong.** It reads *"white at 30% is the first step that clears it
(3.0:1 over #0C0E14)"*. Measured: **2.63:1**. The slip is instructive rather than careless - 30%
clears 3:1 when composited against the *field*, but `GWFocusRing` does not use a `Border`. It paints
an outer `DecoratedBox` in the edge colour and covers all but 1.5px of it with the field, so **the
visible ring composites over the PANEL**. Sketch 067's contrast table had already reached the right
answer independently: white **36% = 3.30:1**. That is what shipped, as
`GeniusWalletColors.borderControl`.

**Finding 4 applies to the panel too, and this sketch did not notice.** *"Two dark fills can never
carry an input boundary by themselves"* is exactly as true of #0C0E14 against the `black54`-scrimmed
page (**1.05:1** - down from 1.16:1, and the drawer loses its silhouette). So the panel takes a
card's whole recipe, fill **and** hairline: `borderStrong` on the desktop `Container` and on the
mobile sheet's `shape`, at 2.01:1.

**The knock-on list was incomplete.** The three named here (selection tint, `GWFocusRing` call
sites, header hairline) all turned out to be no-ops or near-no-ops. The one that mattered was not
listed: **anything inside a drawer already painted `surfaceElevated` drops to 1.00:1** the moment
the panel takes that colour - `account_dropdown_selector`'s row `tileColor`, `sdk_account_manager`'s
card `background`, and two `MenuAnchor` popups. All moved UP to `surfaceMenu`.

Three things this scheme fixes that nobody had filed: the receipt's action badge, the receipt
avatar's punch-out ring and the bridge network rows were all painted correctly for a card, on a
drawer that was not one.

**The recommendation to ride the ~19-drawer walk was not followed** - the walk still has not
happened. The substitute was reading all nineteen call sites for surface colours rather than looking
at them, which is what found the fourth knock-on. It is not the same thing as a walk, and the walk
is still owed.

## Correction 3, from the live walk - the field goes DOWN, not up

A's second half was *"field **up** to `surfaceMenu`... which is the direction the rest of the app
already reads in"*. Walked on 2026-07-28, it does not: a lighter fill on a darker panel reads as a
raised tile rather than as something you type into. Jakub, live: *"back/fill tego field powinien być
ciemniejszy"*.

The fill went to **`surfaceSunken` #06080C** - which is **this sketch's own scheme C**, and which is
already the app's fill for a recessed control (`pin_screen`, `token_info_screen`'s fields, the
control-track standard, the news and transactions search wells). So A and C ended up splitting the
question between them: A owns the panel, C owns the field.

The edge is unaffected - `GWFocusRing` paints its ring as an outer `DecoratedBox`, so the ring
composites over the panel and never over the fill.

**What this says about the sketch:** the claim that the app "reads" one direction was asserted from
the panel's arithmetic, not from the app's own input treatments, and the app's input treatments said
the opposite. The measurement was right and the reading of it was not.
