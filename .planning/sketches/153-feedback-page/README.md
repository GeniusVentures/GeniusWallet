---
sketch: 153
name: feedback-page
question: "The Feedback tab ships a 560px card on a 1536px frame. What whole-page shape does it deserve, using only what the screen already has?"
winner: "B"
tags: [feedback, logs, submit-logs, page-layout, page-frame, gw-page-header, data-honesty, follows-150]
lane: B
---

# Sketch 153: Feedback page

Continuation of **150** (which decided the *card*: D · Guided receipt, shipped). This sketch decides
the **page** around it.

## Design Question

150-D shipped. The card is fine. The page is not: a 560px column sits in an `xxl` (1536) page frame,
so on a maximised window roughly **430px of nothing sits on each side**. An uncommitted change in the
tree then pulled the title *inside* that 560 column (`centered: true`), which fixes the floating title
by making Feedback and Swap their own header family - and leaves the emptiness untouched.

**What shape should the whole page be - without inventing a single feature?**

## The pantry - everything the screen actually has

Verified in `lib/logs/submit_logs_screen.dart`. No variant uses anything outside this list.

| Element | Source |
|---|---|
| Bug / Idea / Question chooser, mint-tinted active | `_buildTypeChooser`, `:535-594`; ships as `scope.setTag('feedback_type', …)` `:331` |
| Per-type placeholder strings (used verbatim in the sketch) | `FeedbackType.placeholder`, `:55-64` |
| Message field, `minLines:4 / maxLines:8 / maxLength:2000` | `:494-505` |
| Log chips with real size + `TAIL` badge + `skipped (empty)` | `_logChip` `:661`, `attachmentDispositionFor` `:76` |
| `SDK Running` / `SDK Stopped` dot, platform string | `_metaChip` `:627-634`, `Platform.operatingSystem` |
| One status line, four distinct strings | `_buildComposer` `:467-479`, `:359`, `:373` |
| Send button + loading state | `GWButton`, `:523-528` |
| Success: check badge, reference number, Copy, Send another | `_buildSuccess` `:752-844` |

**What does NOT exist, and therefore appears nowhere:** past feedback history, ticket/reply status,
an email or contact field, a screenshot or file picker, a category taxonomy beyond the three types,
a draft store. Nothing persists `_lastEventId` past the session - the reference number is gone the
moment you leave the tab. Any "recent reports" rail would be a lie, which is the same trap sketch
041/1 · Desk fell into on Swap (`mockSquidBalances`).

## How to View

```
open .planning/sketches/153-feedback-page/index.html
```

Deep links: `index.html#b` opens one shape directly, `index.html#b+phone` opens it at the narrow width.

Top bar: six page shapes, the five real states (Ready / Sending / Success / No-SDK / Failed), a Phone
width, Light/Dark, and an **Empty-space marks** toggle that paints the dead page red so the argument
is visible rather than described. Sending auto-advances to Success after 1.4s, like the real
round-trip. The chooser really does swap the placeholder to the three shipped strings.

## Variants

- **0 · Today** - what is in the tree right now, with the dead space marked. Reference point, not a proposal.
- **A · Sheet** - keeps the 560 column and the centred title, but re-proportions the card as a sheet:
  32px vertical padding, taller message field, receipt demoted to a quiet strip, CTA full-width at the
  bottom instead of squeezed beside the status line. Owns the narrowness; changes nothing structural.
- **B · Focused frame ★** - the page declares a **narrower frame (1040, centred)**. Title returns to
  the **top-left of that frame** like Transactions / Markets / News; composer 640 + receipt rail 380
  fill it edge to edge. What is left over reads as page margin, not as a hole.
- **C · Split card** - same 1040 frame and left title, but **one surface**: a single card split by a
  hairline. Left = what you write, right = what leaves the machine, with the status line and CTA at
  the foot of that same pane.
- **D · Steps** - one axis: title on the **left edge of the 640 column**, so title and card agree on
  exactly one X (040-B's "one axis" applied here). The card becomes a numbered procedure - 1 pick a
  kind, 2 write it, 3 check what rides along - which is what the three existing blocks already are,
  just labelled.
- **E · Wide composer** *(shown to be argued against)* - the card takes the whole 1536 frame. Nothing
  is empty any more, and that is the problem.

## Recommendation

**★ B · Focused frame.** It is the only variant that answers both open questions at once. The
emptiness goes away without inventing content, because the frame - not the content - is what shrinks;
and the title goes back to the left edge, which is where the last thing Jakub actually asked for on
Swap put it ("tytuł w page tam gdzie inne strony mają"). The rail is the four facts the probe already
computes, in the shape sketch 150-E already drew and Jakub already liked the feel of. Cost: one
`ConstrainedBox` value and a `Row`.

**Runner-up: A · Sheet.** The smallest diff by a wide margin - spacing, order, and one `block` button
- and the only variant that keeps Feedback in the same header family as Swap's current
`centered: true`. Pick this if the answer to the header question turns out to be "centred, and the
empty page is fine".

**Rejected: E · Wide composer.** A 1400px-wide text box for a two-sentence bug report is a stadium
with one chair; the line length blows past every other card in the app, and a full-bleed card breaks
the card rhythm the other tabs established. It fills the page by making the page worse. Included so
the option is visibly dead rather than quietly untried.

## ⚠ Blocked on a decision Jakub owns

**B, C, D and E all put the title back on the left.** That reverts `centered: true` in
`submit_logs_screen.dart:440`, which another session added to the tree today (uncommitted) and which
`HANDOFF-swap-feedback-header-and-coin-sketches.md` records as a deliberate call. **A keeps it.**
The `centered` flag in `GWPageHeader` is additive and survives either way. Do not un-pick someone
else's work off this sketch - resolve the header family first, then read this sketch's answer.

## Findings from the code, not from opinion

1. **The receipt is thinner than it looks.** `_candidateLogNames` is a two-element const
   (`sgnslog.log`, `sgnslog2.log`) - the third "skipped" chip in the sketch is drawn to prove the
   `skipEmpty` disposition renders, but **the real screen can only ever show two log chips**. So a
   receipt rail is 4 rows on a good day and 2 rows with the SDK stopped. B and C are sized for that
   truth; anything wider starves.
2. **The status line and the CTA share a `Row` with the CTA fixed-width.** The empty-event-ID copy
   (`:359`) is 130 characters. In a 560 column it wraps to about 5 lines, and `crossAxisAlignment:
   center` leaves the button floating in the middle of that block. A/C/D dodge it by putting the
   status above a full-width CTA; B keeps the row and inherits the problem. Worth a look in the
   Failed state.
3. **The success state has no exit but "Send another".** No back-to-Wallet, no dismissal - and the
   reference number is not stored anywhere, so leaving the tab loses it. Not a layout problem and not
   in scope here, but it is the reason no variant offers a "your reports" surface.
4. **`GWCard` padding is `space12` (24px)** on a 560 card, while `pad-lg` in variants A/D uses 32/24.
   That is a real 4-pt-grid step, not a tweak - flag it if A or D wins.

## MANIFEST row

This was a **design session**, so per `CLAUDE.md` it did not write `.planning/sketches/MANIFEST.md`
(executor-only, and the file is already dirty in the tree). Row to append when an executor next
touches it:

```
| 153 | feedback-page | 150 decided the Feedback *card*; this decides the *page* around it - a 560 column on a 1536 frame leaves ~430px dead on each side. What shape, using only the shipped pantry (type chooser, message, two log probes, SDK/platform, status, send, reference number)? | _pending pick_ (rec **B · Focused frame** - page frame capped at 1040 so leftover reads as margin, title top-left like the other tabs, composer 640 + receipt rail 380; runner-up **A · Sheet** = smallest diff, keeps `centered:true`; **C · Split card** = same frame, one surface; **D · Steps** = one axis at 640, numbered procedure; rejected **E · Wide composer** - full-bleed textarea, line length breaks every other card). ⚠ B/C/D/E revert the uncommitted `centered:true`. Finding: `_candidateLogNames` is a 2-element const, so the receipt can never exceed two log chips. | feedback, logs, submit-logs, page-layout, page-frame, gw-page-header, data-honesty, follows-150 |
```

## Verified

Unlike sketches 040/041, this one **was actually rendered before being handed over** - headless
Chrome for Testing from the Playwright cache
(`~/Library/Caches/ms-playwright/chromium-1228/.../Google Chrome for Testing`), which is the way
around "Chrome is not installed at /Applications" that blocked the previous session. All six shapes
were rendered at 1500px and B was re-rendered at the narrow width to check the stack. One defect was
found and fixed that way: C's left pane ended ~180px short of the right pane, so the message field
now stretches to make the two panes end level. Structure: 147/147 divs, 6/6 sections, script parses,
no Polish characters in the window markup.

## What to Look For

- **Turn the red marks off and on.** Which variants still feel like an unfinished page with the marks
  hidden? That is the whole test.
- **The Failed state** - the long empty-event-ID sentence is the one that breaks footer rows.
- **The No-SDK state in B and C** - the rail loses its log rows and keeps two. Is a two-row rail worth
  the column, or does it look abandoned?
- **Phone width** - A and D are already one column; B and C have to collapse. Check the seam.
- **Light mode** is togglable but per the dark-first rule it is not the deciding view.
