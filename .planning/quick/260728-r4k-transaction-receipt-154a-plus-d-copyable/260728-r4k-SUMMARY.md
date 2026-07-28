---
quick_id: 260728-r4k
status: complete
date: 2026-07-28
commit: none - CLAUDE.md forbids commits
sketches: [154-A, 154-D]
files_modified:
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/components/cards/gw_detail_grid.dart
  - test/dashboard/transaction_receipt_copy_test.dart
gates:
  analyze_lib: 59
  analyze_baseline: 59
  flutter_test: 339 pass / 1 fail
  flutter_test_baseline: 334 pass / 1 fail
verification: WALKED by Jakub 2026-07-28 - two corrections applied; second walk pending
---

# Quick 260728-r4k - SUMMARY

The transaction receipt, built on the drawer language that landed the same day (quick 260728-q7c).
Jakub: *"bazując na base komponentach i SWAP SETTING, popraw design transaction drawer, wybraliśmy
wcześniej D copyable"*.

Sketch 154 picked **A** on 2026-07-27 and left one thing open - *"whether D's tap-to-copy rows and
4-character address chunks ride along with A. Recommended yes."* They do now.

## What the drawer was throwing away

Every field below is computed on this exact call and was being dropped. Restoring them is most of
154-A:

| field | now |
|---|---|
| `content.valueLine` - fiat, or `Not charged`, or null | the line under the amount; null still prints nothing rather than a fabricated `$0.00` |
| `_statusPill` - written, correct for all four states, used only on wide rows | centred under the fiat line |
| `content.exactAmount` - the unclamped value | an `Exact amount` row, which appears **only** when the headline lost precision |

The amount stays neutral. Colour rides on the icon badge, the pill and the Status row - the 031
round-2 rule, kept.

## Sections: bare first, then the grid Jakub asked for

154-A groups the rows into filled TRANSACTION / NETWORK cards. The first pass dropped them, on
sketch **067**'s measurement of that idea against the panel 156-A had just shipped:

| boundary | on the 156-A panel #0C0E14 |
|---|---|
| `GWCard` fill `surfaceElevated` | **1.00:1** - the identical colour |
| sunken card `surfaceSunken` | 1.04:1 |
| hairline `borderSubtle` 12% | 1.36:1 |
| first edge that passes 1.4.11 | white **36%** |

So a card here is either invisible or a visibly grey frame that is louder than `View on Explorer`.
067's decision was `A · Kicker only` for Swap Settings, with the explicit note that **B (kicker with
a rule) returns as a candidate for the receipt, where there are two sections**.

It shipped bare on that reasoning and Jakub walked it: *"tej siatki nie ma - chciałbym ją mieć, więc
sprawdź komponenty bądź zbuduj taki szczególnie dla drawerów transakcyjnych"*. He is right, and the
reasoning above was over-applied.

**067's arithmetic covers a box around a FORM, not a read-only table.** A form's frame is part of
identifying the control inside it, so 1.4.11 asks it for 3:1. A receipt's rules carry no information
at all - every row is fully readable with them removed and the text clears AA on its own - which
makes them decorative separators, the same category as the drawer header's own hairline that
`responsive_drawer.dart` already documents as *"not a WCAG 1.4.11 graphical-object"*. So
`borderSubtle` is the correct weight here, and white 36% would have been wrong: it would make the
table's frame louder than its contents.

Built as **`GWDetailGrid`** (`lib/components/cards/gw_detail_grid.dart`): one `surfaceSunken` well,
`borderSubtle` outline, hairline rules between rows, `clipBehavior: antiAlias` so the rules do not
paint over the rounded corners, and `SizedBox.shrink()` on an empty list so a type with no rows in a
section does not show an empty frame.

The fill is not doing the separating - `surfaceSunken` is 1.04:1 on this panel and the hairline does
the work. It is there so the group reads as recessed rather than as a card floating on a card, which
is the same call the drawer's input fields took the same day.

**`kGWDetailRowPadding` lives on the component but is applied by the rows, not by the grid.** If the
grid padded its children, a copy row's tappable area would stop 12px short of the cell it appears to
fill - the kind of miss nobody reports and everybody feels.

## D · Copyable - and the width that forced a decision

Every mono value is a tap-to-copy row. Two details are worth recording because they were decided,
not defaulted:

**The row prints a short form, the clipboard gets the whole value.** `0x1234·5678 … cdef·0123` - the
first eight and last eight characters in 4-character groups, with the two outer groups emphasised
(034-A2's eyeball-verify treatment). That is 8 + 8 verifiable characters against
`getAddressForDisplay`'s 6 + 4, in the unit the eye actually compares.

It is not the full address, and that is arithmetic rather than laziness: 42 characters chunked is
~398px of monospace and this panel's content width is 380 - and a hash is 66 characters, which no
single row holds at any size. Sketch 154 anticipated it: chunking is *"worth it for an address and
arguable for a 64-character hash"*. **`getAddressForDisplay` is no longer called on the way in** -
it would have truncated the value before the clipboard ever saw it.

**The copy glyph is present at rest, not on hover.** D says "a copy glyph on hover"; an affordance
nobody can see until they hover over it is not an affordance, and reserving its space avoids the row
reflowing. Hover only brightens it. The whole 380px row is the tap target
(`HitTestBehavior.opaque`), not the 14px glyph.

A swap's From / To are amounts, not addresses, so they stay plain rows - there is nothing to copy.

## The check, and the trap it caught

One test: open the real receipt, assert the full address and the full hash are **not** on screen,
then tap each row and assert the clipboard holds them. Both halves matter - without the first, the
copy assertion would pass for the wrong reason the day the row stops abbreviating.

It caught a real testing trap on the way: the copy confirmation is a `SnackBar`, which parks over
the bottom of the panel - exactly where the Hash row sits. The first version tapped the SnackBar and
passed while asserting nothing. It now waits the SnackBar out and `ensureVisible`s each row, because
at the test window's 600px the Network section is below the fold and a tap there silently misses.

## Follow-up

- **Walk it again.** Especially whether the short chunked form reads as something you can verify
  rather than as decoration, and whether the grid's `surfaceSunken` well is visible enough on the
  156-A panel - it is 1.04:1, so the hairline is carrying it alone.
- The receipt now holds **two** of the app's ten hand-rolled `Clipboard.setData` call sites' job in
  one widget. `_CopyRow` is private; if a third consumer appears (the Receive drawer, 159-A) that is
  the moment to promote it, not before.

## Second walk - the status colour was not connected

*"status completed brakuje im kolorów - powinien być przez komponent połączony"*.

It was two rules for one fact: a `switch` inside `_statusPill`, and twenty lines away
`isDead ? gw.statusError : null` on the Status row. They disagreed exactly as you would expect - the
pill coloured all four states, the row coloured only `failed` and `cancelled` - so a **Completed**
receipt showed a green pill above a plain white "Completed", and Pending showed an amber pill above
a white "Pending".

Now one function, `txStatusColors(status, gw) -> (fg, wash)`, and both consumers read it. `isDead` is
gone with it.

**The check writes itself, because the pill and the row print the same word.** Four tests, one per
`TransactionStatus`: `find.text('Completed')` must return exactly two Texts, and their colours must
be equal. Exactly two, not "at least" - if it ever finds one, a consumer was dropped rather than
recoloured.

## Gates after the walks

- `flutter analyze lib` = **59**, baseline 59.
- `flutter test` = **339 / 1**, baseline 334/1. Five new passes: one copy test, four status-colour
  tests. The failure is the inherited `local_wallet_storage_test.dart` (no `main()`).
- Hot-reloaded live.
- **No commit** - `CLAUDE.md`.
