---
sketch: 014
name: transactions-final
question: "Consolidated spec — every locked decision in one place, plus the filter structure pick."
winner: "F1 two-tier"
tags: [transactions, spec, filters, badges, gradient]
---

# Sketch 014: Transactions — Final Spec

The consolidated design contract for **Phase 12**. Everything below is decided; this file is the
reference an executor should build from. Full contract also lives in `ROADMAP.md` under Phase 12.

## Row
**Token-first** (010-A): the asset is the headline, the action a quiet chip beside it.
One row skeleton for all seven `TransactionType` values, including `swap` (both tokens in one
identity), `process` and `purchase`, which today render as bare strings without icon or amount.

Built on **existing** components: `GWTokenRow` geometry (40px icon, `space6`/`space4` padding,
`radiusMd` `InkWell`) and the homepage `Divider(height: 1, thickness: 1, color: gw.borderSubtle)` —
straight and full-bleed, never rounded.

## Badges — 18px filled circle, knocked-out glyph
| Type / status | Colour | Glyph |
|---|---|---|
| Sent | Slate `#64748B` *(new token)* | arrow out |
| Received | `statusSuccess` | arrow in |
| Mint | `brandTertiary` `#C28FFF` | **pickaxe** |
| Processing job | `brandPrimaryStrong` `#0AAEE6` | **server** |
| Escrow | Slate `#64748B` | lock |
| Pending | `statusWarning` | clock |
| Failed | `statusError` | cross |

## Filters — F1 two-tier
- Title row, in this order: **Sent · Received · Mint · Jobs** (007-C compact segmented control).
- Overflow `⋯` menu: **Escrow**, Swapped, Purchased, plus Pending and Failed, with live counts.
- Active chip = **`brandCta` gradient**, never flat blue.
- When the active filter lives in the overflow menu, the **`⋯` trigger itself takes the gradient** —
  otherwise the list looks filtered for no visible reason.
- Active menu item = **gradient text on the label only**. The glyph never changes with selection:
  same icon, same colour, active or not.
- Desktop keeps the animated expand-to-label; **narrow/mobile is icon-only**.

Gradient is painted the way the app already does it — `ShaderMask(BlendMode.srcIn)` over
`GeniusWalletGradient.brandCta` (`#0AD89C → #0AAEE6`), as in `gw_button.dart:299`
(`gradientOutline`) and `gw_view_all_link.dart:65`.

## Carried fixes (from the 010 diagnosis of the shipped panel)
- Amounts clamped — 2 dp at ≥1000, else 6 — with the exact value on hover; tabular figures.
  `123456789.12345679 ETH` no longer sets the panel's width.
- Fiat value on every row; `Fee:` removed from the resting row (it repeated on all eight rows).
- Repeated `a day ago` replaced by day separators plus a real timestamp per row.
- Status shown **only** when it is not the happy path; the failed row stops printing `$0.00` twice.
- Per-row cards replaced by one surface with hairline dividers.

## Two empty states, deliberately different
The app shows the same copy for "this wallet has never transacted" and "this filter matched
nothing" — the second reads as a broken load. The filtered empty names the filter, states how many
transactions *do* exist, and offers **Show all** instead of **Buy GNUS**.
