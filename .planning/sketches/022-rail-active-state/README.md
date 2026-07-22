# 022 · Filter rail — how the active row is marked

**DECIDED 2026-07-22: B2 · Underline only.** Jakub: *"to jest obecny standard na navigation bar i to
powinnismy miec"* — which is exactly the argument. The active rail row wears the navbar's active-tab
mark copied outright: label w700 `textPrimary` (never recoloured), 2px gradient rule beneath it, glyph
untouched. Hover stays the sketch-008 "lift chip". Nothing else on the row changes with selection.

## Locked

| Decision | Value |
|---|---|
| Layout | **B · Filter rail** — page at `xl` 1280, `GWPageHeader`, list + rail in cards |
| Empty state | **anchor c** — centred within the first 480px; no action buttons; filter control hidden when there is nothing to filter |
| Empty-state icon | **4 · Two-way arrows** (`Icons.sync_alt`) |
| Amounts | **the real number, always** — Failed and Computing print the amount normally; the status carries the truth |
| Active rail row | **B2 · Underline only** — navbar's active-tab mark, copied outright |

## Amounts — Jakub overruled the recommendation, and the override holds

Sketch 021 recommended dropping the `−` on a failed row so the amount could not claim the balance
changed. Jakub chose: print it normally, let the status say Failed.

**That works, and the value line is why.** With `− 0.75 ETH` at full weight the row needs
`Not charged` underneath, or a wallet that never lost 0.75 ETH reads as if it did. With that line
kept, the failed row states three unambiguous facts — **0.75 ETH · Not charged · Failed** — and on the
homepage panel, where there is no Status column, the red `failed` badge on the coin plus `· Failed` in
the subtitle carry the state. The objection is answered by the value line, not by the sign.

**Do not drop `Not charged` when implementing this.** It is load-bearing.

## The five active-row marks

All five share identical rest and hover states (`_menuItem` geometry; sketch 008 "lift chip" hover)
and all five leave the **glyph untouched** — the rule locked at `transactions_slim_view.dart:525`.

| | Mark | Provenance | Verdict |
|---|---|---|---|
| **A** | 2px gradient bar on the left edge + gradient label | navbar indicator, **rotated** to vertical, + `_activeLabelShader` | Fine. But rotating a horizontal mark only because the list is vertical is the weakest kind of precedent, and the bar sits outside the row padding so it reads as margin ornament. |
| **B** | gradient label + 2px gradient underline **under the label** | navbar active tab, unrotated, **plus** the menu's gradient label | Second choice. Says "selected" twice, and adds a light-mode text degradation that must stay in sync with the underline's. |
| **B2** | **underline only** — label goes w700 `textPrimary`, never recoloured | navbar active tab, **copied outright** | **Ship this.** |
| **C** | plain w700 label; the **count** takes the gradient | none — the app has never marked state on a numeral | **No.** `filterCounts()` is computed over the *unfiltered* list on purpose, so the counts do not change when you filter — a gradient number promises motion that never comes. Also the quietest option at the moment you need the loudest. |
| **D** | B + C: gradient label, underline and count | navbar + `_activeLabelShader` + new numeral treatment | Only if B proves too quiet in the live app. Three marks for one boolean; inherits C's problem. |
| **E** | low-alpha `brandCta` wash on the row background, w700 label | none — 020's rejected `brand-fill` with a gradient in it | **Not alone.** ~1.3:1 against the card, far under the 3:1 WCAG 1.4.11 wants for a UI-state boundary, so the w700 would be doing the real work. It also collides with the hover surface — hover fills the row too, so hover and active become one gesture in two tints. |

**Why B2, and why it replaced B as the recommendation.** Jakub asked to see the underline without the
recoloured text, and the request is right for a reason worth writing down: **look at the navbar.** The
active tab is white and bold with a gradient rule under it — *the label itself is not gradient.* So B2
is the navbar's mark copied outright, while B is the navbar's mark plus a second gradient the navbar
never had.

It is also the same argument that rejected D. If the underline already says "selected", a gradient
label says it a second time — redundant state marking. By that reasoning B2 beats B, and I had missed
it.

B2 has one fewer moving part in light mode too: the label is never brand-coloured, so there is no text
degradation that has to stay in sync with the underline's.

Shared cost of B and B2: the underline tracks the word, so the mark's length varies row to row.

## Contrast, measured

> **CORRECTED 2026-07-22 after the plan-checker measured against the real code.** The HTML mockup
> paints its gradients with the sketch-theme tokens `--brand-primary #14C8FF` / `--brand-secondary
> #2BF5B4`. Those are real tokens (`brandPrimary`, `brandSecondary`) — but they are **not the stops
> `brandCta` actually uses.** `GeniusWalletGradient.brandCta` is `[gradientGreen #0AD89C,
> gradientBlue #0AAEE6]` (`genius_wallet_gradient.dart:16-23`). The table below is the measured
> truth; the mockup's colours are brighter and cyaner than what the app paints. The **conclusion is
> unaffected** — the underline still fails 1.4.11 on white and still needs the degradation — but do
> not copy the mockup's hexes into source. See
> `.planning/todos/pending/2026-07-22-sketch-theme-gradient-mismatch.md`.

| Mark | Dark (on `#181B24` / `#0C0E14`) | Light | Gate |
|---|---|---|---|
| Plain w700 label (B2, E) — `#FFFFFF` / ink | 15.9:1 | 16.4:1 on `#FFFFFF` | AA text 4.5:1 ✓ — and nothing to degrade |
| `brandCta` stop `#0AD89C` | 9.27:1 · 10.39:1 | 1.86:1 on white — degrades to `#0A6885` → 6.30:1 | AA text 4.5:1 ✓ after degradation |
| `brandCta` stop `#0AAEE6` | 6.72:1 · 7.54:1 | **2.56:1** on white — same degradation | AA text 4.5:1 ✓ after degradation |
| 2px bar / underline (A, B, B2, D) | 6.72:1 worst-case vs the card ✓ | worst stop is **2.56:1 ✗** — must reuse the `_activeLabelShader` degradation to `#0A6885` → 6.30:1 / 5.87:1 ✓ | 1.4.11 non-text 3:1 |
| Wash (E) | ~1.3:1 | ~1.2:1 | 1.4.11 3:1 **✗** |

Measured against **both** sheen endpoints, not the flattering one: `GWDecorations` paints a two-stop
gradient (`#181B24 → #0C0E14` dark, `#FFFFFF → #F5F7FA` light), so the worst case is the lighter
endpoint in dark and the darker endpoint in light.

**Implementation note:** the underline is not a separate colour decision. It must be painted through
`_activeLabelShader` — the same function the popup menu's active label uses — so light mode cannot
drift out of sync with dark. Under B2 that shader has exactly one consumer left in the rail (the
underline), which is one of the reasons B2 is the simpler build.

## Recorded, not re-litigated: the icon collision

`Icons.sync_alt` is two horizontal opposed arrows; `Icons.swap_horiz_outlined` — the Swap tab's glyph
in the navbar — is also two horizontal opposed arrows. At 32px inside a circle the empty Transactions
page can read as "go to Swap". Jakub picked it knowing this (flagged in 021 §4), so it ships. Logged
here so a later walk does not report it as a surprise.

If the meaning is ever wanted without the collision: `Icons.swap_vert` — arrows up and down — reads as
"in and out of this wallet" and shares no silhouette with the Swap tab. One-word change.
