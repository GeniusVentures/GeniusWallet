# Sketch 164 · Read-only field + coin-page action icons

**Design question.** Two controls on the coin page do not say what they are.
The Convert card's *Token price* is an input box you cannot type in, wearing a
`READ-ONLY` chip to explain itself. The identity row's *Receive* and *Swap* are
`ghost` buttons - no fill, no border at rest - and Receive's glyph is a QR
matrix rasterised into 20px. Both were caught by eye on the 2026-07-29 walk.

**Source:** Jakub's walk notes, 2026-07-29. **Status:** _pending pick_.

---

## S1 · Read-only Token price

| | variant | what changes | light-mode AA |
|---|---|---|---|
| | Today | box + chip, value at `textPrimary` | pass |
| ★ | **A · Detail row** | stops being a field; becomes a `GWDetailGrid` row like `Total` | **pass** |
| | B · Quiet field | no chip, no edge, value dimmed | **4.23:1 FAIL** |
| | C · Locked field | no chip, lock glyph, value dimmed | **4.23:1 FAIL** |
| | D · Prefixed | no chip, no edge, full-weight value, `· live` label | pass |

**The measurement that shapes this.** "Just grey the value out" is the obvious
move and it is not free: `textSecondary` on `surfaceSunken` is **6.20:1 dark**
but **4.23:1 light**, under the 4.5:1 body floor. Variants that dim the value
(B, C) carry that debt; variants that change the *frame* instead (A, D) do not.

**★ A · Detail row.** The only variant where the control is not an input, which
outranks any label an input can wear. The card already ships that exact row one
line below (`Total`), so it costs no new language. It keeps `textPrimary`, so
no contrast debt. And it removes a wart the code comments already name: a
`readOnly` field still takes focus in Flutter, so today's box can be tabbed
into and lights up promising an edit that cannot happen.

**Runner-up C · Locked field** - keeps the Convert card's two-input symmetry,
which is defensible for a calculator. Needs a light-mode answer first.

**Rejected D · Prefixed** - a box with no tag, no lock and a full-weight value
is close to the state that caused someone to add the chip. Removing the signal
without replacing it re-opens the original defect.

---

## S2 · Receive / Swap action icons

Two independent defects, deliberately separated because fixing one does not fix
the other:

1. **The glyph.** `Icons.qr_code_2` is a finder-square-plus-data-field matrix -
   20-odd sub-3px shapes inside a 20px box. It resolves as noise.
2. **The container.** `variant: ghost` paints nothing at rest, so both actions
   float beside a 26px coin name with no boundary saying they are pressable.

| | variant | container | glyph | colour |
|---|---|---|---|---|
| | Today | ghost (none) | `qr_code_2` | `textPrimary` |
| | A · Contained | `variant: icon` (exists) | unchanged | `textPrimary` |
| ★ | **C · Contained + tint** | `variant: icon` | `call_received` | `brandPrimary` |
| | D · Labelled pills | tertiary + label | any | `textPrimary` |

**★ C.** The container is the half that matters. `GWButton` already has a
`variant: icon` (`surfaceElevated` fill + `borderSubtle` edge), so it is a
one-word change rather than a new component. `brandPrimary` on
`surfaceElevated` measures **9.86:1 dark / 6.30:1 light**, far above the 3:1 a
non-text glyph needs. The tint stays on the glyph - a filled brand button here
would break the CTA weight rule (fill = commitment, one per surface).

**The glyph swap is separable and is Jakub's call, not mine.** `call_received`
resolves at any size because it is two strokes; `qr_code_2` carries the meaning
"there is a code to scan", and the drawer it opens *is* a QR code. Real trade.

**Rejected D** - the most legible option, and still rejected: the identity row
already carries a 26px name, a symbol, a network and a 30px price, and a third
action (Bridge) appears on GNUS coins. Three labelled pills is a toolbar
competing with the heading.

---

## Grounding

- `GWButton` sizes/variants: `lib/components/buttons/gw_button.dart` -
  `md` = 48px box, 20px glyph; `ghost` = transparent + no border;
  `icon` = `surfaceElevated` + `borderSubtle`.
- `GWTextField` read-only call site: `lib/tokens/token_info_screen.dart`.
- Tokens: `lib/theme/genius_wallet_colors.dart`.
- All contrast figures computed against composited values, not quoted.

## Not in scope

The Markets hero chart. It has a measured layout blocker attached (the card
grows by the chart's full delta) so it is a layout decision, not a styling one,
and is written up separately.
