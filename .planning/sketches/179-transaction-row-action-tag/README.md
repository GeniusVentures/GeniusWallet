# Sketch 179 - the transaction row's action tag

http://localhost:8899/179-transaction-row-action-tag/

Jakub, 2026-08-07, looking at the Transactions page on his iPhone:

> "chcialbym zebys mi zre-designowal lekko Transaction Page, bo na przyklad wszystkie te tagi:
> Processing, Send, Receive, Purchase sa uciete. Zastanawiam sie czy faktycznie jest to niezbedne
> zebysmy to tam mieli? Czy wystarcza te male ikonki przy logo i to jest domyslnie OK? Jaka jest
> Twoja optyka na to?"

Two questions in one: **fix the truncation**, and **should the action word exist at all** now that the
badge already sits on the coin logo. Four whole schemes plus the current state, all clickable, all at
390x844 at 1:1, all shown across the **full nine-kind badge vocabulary** with a long-token-name row and
the `Processing job` row included.

## What the code actually says (verified 2026-08-07, re-read, not taken on trust)

**The truncation is a layout defect, not evidence the label is surplus.**
`transaction_displays.dart:366-405` - the title line is a `Row` with **two `Flexible` children**, the
token title and the action chip. Flutter's `Row` gives each flex child an equal share of the free space
and does not hand the leftover back when a loose child turns out narrower, so the chip is capped at
half the line whatever its word is.

The arithmetic at 390pt is exact:

| Step | px |
| --- | --- |
| Window | 390 |
| Page gutter both sides (`transactions_screen.dart`, `fromLTRB(12, space32, 12, space8)`) | -24 |
| Row padding both sides (`space6`) | -24 |
| Row content box | **342** |
| Time 44 + `space6`, identity 40 + `space6`, `space4` before the amount | -116 |
| Free space for the two `Expanded` (middle column, amount column) | 226 |
| Middle column | **113** |
| Less `space4`, split between two `Flexible` | 52.5 each |
| Less the chip's `space2` horizontal padding twice | **44.5 for the word** |

**Measured live in the sketch, not estimated:** 6 of the 8 strings `_actionFor` can return are clipped.
Only `Sent` (31px) and `Minted` (46px) fit in 53. `Received` 56, `Swapped` 56, `Purchased` 61,
`Processing job` 84, `Escrow locked` 85, `Escrow released` 93.

**A second, quieter waste in the same `Row`:** the amount column is also `Expanded` with flex 1, so it
claims 113px for content that needs about 90. That 23px never reaches the words that need it.

**Nine badge kinds, six fills.** `transaction_badge.dart:9-19`: `sent, received, mint, job, escrow,
swap, purchase, pending, failed`, each an 18px circle with an **11px** knocked-out glyph. `#64748B`
carries sent + escrow + swap; `#0AD89C` carries received + purchase. So colour can never be the
discriminator and the 11px glyph is the entire signal.

**The finding that decides the whole question.** In `txRowContent` the badge is chosen **status first**:
pending wins, then failed/cancelled, then type. So on any row that is not the happy path the badge has
already spent itself on the status and **the type is drawn nowhere**. A pending mint shows a clock. A
failed swap shows a cross. Delete the word and exactly the rows a user opens the page to investigate
stop saying what was attempted.

**And the chip is duplicating the line beneath it.** Comparing `_actionFor` against the subtitle switch:
mint says `Minted` over `Minted to wallet`, escrow `Escrow locked` over `Locked in escrow`,
escrowRelease `Escrow released` over `Released from escrow`, purchase `Purchased` over `Card purchase`,
process `Processing job` over `Job 0x…`. **Five of eight restate the line 4px below them**, clipped, in
a 44.5px box, while a 113px line says it in full. The action word is not the problem. Its position is.

## The schemes

| Scheme | Idea | Measured, 11 rows | Verdict |
| --- | --- | --- | --- |
| Today | two `Flexible`, two `Expanded` | 6 actions + 2 titles clipped (red), 3 contexts (amber) | the defect |
| A | chip stops flexing, title absorbs all shrink; optional reserved amount column | 4 titles clipped (red), 3 contexts | runner-up |
| B | Jakub's: delete the chip, badge carries the kind | 0 red, 3 contexts | **rejected** |
| **C** | action leads the subtitle, never shrinks; context ellipsises | **0 red**, 8 contexts | **★ recommended** |
| D | action becomes the headline, token drops to line two | 0 red, 11 of 11 contexts | rejected |

The readout under each phone splits clipping by **severity** rather than counting it flat, because a
flat count would say C is worse than today. Red = the row stops saying what happened (action, token,
status). Amber = an already-abbreviated address or qualifier loses a character or two, with the full
value one tap away in the drawer.

## RECOMMENDATION: ★ C - the action leads the subtitle

The title line becomes the token alone. The subtitle becomes three pieces with three layout rules:
**action** `flex: 0 0 auto` (never shrinks), **context** `Expanded` (ellipsises), **status**
`flex: 0 0 auto` (never shrinks). Where the subtitle already carried the action the copy is
deduplicated rather than doubled, and the fixed/flexible boundary falls inside the phrase - the verb
(`Minted`, `Locked`, `Released`) never shrinks, the qualifier (`to wallet`, `in escrow`) may.

Why C and not the others:

- It is the only scheme where the action word **cannot be clipped in any state**, because it is the one
  piece on its line with no flex.
- The word survives in all three places B loses it: the kinds with no learnable icon (mint, job,
  escrow), the `escrowRelease` type that has **no badge of its own at all**, and every pending or
  failed row where the status has already spent the badge.
- It costs nothing structurally. `TxRowContent` already carries `action`, `subtitleBase` and `status`
  as three separate fields - which is exactly the three-piece subtitle C needs.
- It deletes a container measuring **1.13:1** against its own canvas.
- **It fixes a truncation nobody has reported yet.** Today `Minted to wallet · Pending` is about 172px
  on a 113px line, so the app is already clipping the word "Pending" off the one row where it matters
  most. C pins the status to the right edge and lets the qualifier give way instead.

**Runner-up: A.** If the answer has to be one line of Dart this week, delete the chip's `Flexible` and
stop. Every action word becomes readable, which is the literal complaint. But A creates no width, it
only chooses a different victim - and it chooses the token headline that 010-A deliberately put first.
The sketch shows this happening with **short** token names, not only long ones: at 84-93px the job and
escrow chips reduce a four-character `GNUS` to an ellipsis.

**Rejected: B.** Not because the instinct is wrong - the instinct that the row says too much is right,
and B's phone is the calmest of the five. Rejected on arithmetic: nine kinds, six fills, an 11px glyph,
no convention for a pickaxe or a server rack, no glyph at all for `escrowRelease`, and a status-first
badge rule that hides the type on exactly the rows that matter. **D** is rejected more firmly: it works,
but it silently reverses 010-A's locked token-first decision, it costs the token scan column, and it
clips 11 of 11 subtitles because that line now carries token + context + status in 113px.

## The accessibility position, stated precisely

**SC 1.4.1 Use of Color is not the operative criterion** and it would be sloppy to claim it is - the
badges differ by *glyph*, not by colour alone. What 1.4.1 does catch is the fill collision: six fills
for nine kinds means colour is never sufficient here, so the 11px glyph is load-bearing and may never be
degraded to a coloured dot.

**SC 1.1.1 Non-text Content is the one that applies, and B already passes it.** `TransactionBadge`
wraps itself in `Semantics(label: spec.label)`, so VoiceOver announces "Mint". B is therefore
**conformant and still wrong** - the cost is comprehension for sighted users, which no success criterion
measures. If B ships anyway the visible text equivalent has to live somewhere, and the honest place is
the subtitle, which is scheme C. The detail drawer does not count: a label you must tap a row to read is
not a label on the row.

## Contrast, computed from the shipped tokens

| Pairing | Where | Ratio | |
| --- | --- | --- | --- |
| `#8A8F9D` on `#171A21` | **chip label on the chip fill** - the pairing to check hardest | 5.30 | PASS |
| `#8A8F9D` on `#0B0D12` | the same label with no chip (B, C, D) | 6.01 | PASS |
| `#8A8F9D` on `#0C0E14` | the same label on a carded surface | 5.97 | PASS |
| `#8A8F9D` on `#06080C` | the same label on `surfaceSunken` | 6.20 | PASS |
| `#FFFFFF` on `#0B0D12` | the token title | 19.41 | PASS |
| `#171A21` vs `#0B0D12` | **the chip's fill against the row canvas** | **1.13** | invisible |

The chip's label is fine; the chip is not. Removing the box makes the label **better** (6.01), so no
scheme here is blocked on contrast and the case for keeping the `surfaceMenu` container is down to 1.13:1
of nothing. Badge glyph-vs-fill ratios (`badgeGlyphColor` computes white-vs-ink per fill rather than
hardcoding) run 4.75 to 12.43 - all clear AA. The badge's limit is 11px, not contrast.

## What building C touches

| File | Change |
| --- | --- |
| `transaction_displays.dart` | title line drops the chip child; the subtitle `Text` becomes a three-child `Row` - fixed action, `Expanded` context, fixed status |
| `transaction_utils.dart` | five deduplicated subtitle strings so mint / escrow / escrowRelease / purchase / process do not say it twice; `action` and `subtitleBase` stay separate fields, which is what makes the three-piece row possible |
| the WIDE page | unchanged in structure - it keeps its status pill, so C's third piece is simply absent there and `subtitleBase` is already the field it reads |
| tests | the row's golden; subtitle assertions move from "context only" to "action, context" |

**Settle before building:** on the wide page the status pill and the subtitle are both present, so C's
third piece must be suppressed there exactly as `subtitleBase` already is - otherwise the status is
stated twice, which is the defect the `subtitle` / `subtitleBase` split exists to prevent. The rule is
already written in that field's doc comment; C only has to obey it.

## Still open

The optional mitigation for C's address clipping - a **3+3** hex abbreviation instead of today's 4+4,
so the address gives back the characters the action just took. There is a toggle on C's phone for it.
`WalletUtils.getAddressForDisplay` is the single place that decides it, so it is one constant, not a new
rule per surface. Not recommended either way yet; it depends on whether the double ellipsis
(`0x7a3f…9c2…`) actually bothers Jakub on the device.

## Provenance

Tokens verbatim from `genius_wallet_colors.dart` / `genius_wallet_consts.dart` /
`genius_wallet_typography.dart`. Phones are 390x844 at 1:1 with the real shipping geometry - 60px
visible bottom bar, 64px dock with a 26px overhang, 84px dock slot, 44px time column, 40px identity,
18px badge with an 11px glyph, `space6`/`space4` row padding. The phone element is 408x862 because
`box-sizing: border-box` plus a 9px bezel would otherwise make the inner viewport 372, and the
scrollbar is hidden rather than thinned so it steals no content width - every measurement on the page
depends on the inner viewport being exactly 390. Row arithmetic is exact; **which words fit is measured
in the browser after layout**, not asserted, via `scrollWidth > clientWidth`, with the visible prefix
recomputed on a canvas using each element's own computed font. Contrast ratios computed from the hexes
above. Simplification worth naming: the swap row draws one coin circle rather than `_identity`'s two
overlapped sub-icons - it does not affect any width on the title line. `node --check` clean; div balance
0; no em dashes.
