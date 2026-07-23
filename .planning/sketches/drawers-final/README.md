---
sketch: drawers-final
name: drawers-final
question: "The five chosen drawer designs, consolidated into one file with round-2 refinements applied."
winner: "030 B1 · 031 B1 · 032 A1 · 033 B1 · 034 A2"
tags: [drawers, final, consolidated, responsive-drawer, gradient]
---

# Drawers — Final Selection (one file)

All five chosen drawer designs in a single `index.html`, switchable from the top bar. Shared shell =
**030 · B1 "Quiet band"** (`ResponsiveDrawer`, 420px right panel; header left title + close top-right +
faint **gradient** hairline; 20px body padding; footer with top border).

## How to View
open .planning/sketches/drawers-final/index.html

Tabs: **Shell · 030 B1** · **Receipt · 031 B1** · **List · 032 A1** · **Confirm · 033 B1** · **Receive · 034 A2**.
Theme toggle (Dark/Light) bottom-right. Everything is live.

## The five picks + round-2 refinements applied

| Drawer | Pick | Refinements in this file |
|--------|------|--------------------------|
| **030 Shell** | B1 Quiet band | Header-separator → coin-icon gap = **32px**, deliberately larger than amount → "TRANSACTION" (20px). Header hairline is a faint **gradient**, not flat blue. |
| **031 Receipt** | B1 Pill + sections | **All 4** `TransactionStatus` states wired (Completed green / Pending amber / Failed red / **Cancelled slate**). Colour is carried by **icon + pill + status row only — the amount stays neutral** (default text). Outbound uses a short minus `−` (not an em dash). No fiat (receipt has none). |
| **032 List** | A1 Comfortable | Selection is **rounded** (gradient-tint row + gradient check) — no square full-bleed fill, **no vertical accent bar**. Gap below the header separator is **matched to the title→separator gap** above it. GNUS avatar is **gradient**; coins keep their real brand colors. |
| **033 Confirm** | B1 Static caution | Caution is static ("Double-check the recipient…") — **no unbacked "new address" claim**. Fiat carries a `*` = price feed exists but is **not yet wired** to this drawer. Collapsible gas (real maxFeePerGas / priorityFee). |
| **034 Receive** | A2 Grouped address | **Gap** added above the QR; **network chip moved above** the QR. Address grouped in 4-char chunks (first/last emphasized) for eyeball-verify — **no "Your GNUS address" label**. **Copy only** — no Share, no set-default (respecting code gaps). QR stays black-on-white in both themes. |

## Global rule applied
**No flat blue as the accent — the brand is the gradient** (`--brand-cta-b #0AAEE6 → --brand-cta-a #0AD89C`).
Active tab, list selection + check, GNUS avatar, header hairline, CTA buttons, toast accent all use the
gradient. Coin/dApp brand colors (ETH #627EEA, Uniswap pink) are kept — they're not our accent.

## Buttons
- **Primary CTA = filled gradient** (`Copy address`, `Approve`).
- **Secondary = gradient OUTLINE** (1.5px gradient border, panel-surface fill, no grey border) —
  `View on Explorer`, `Reject`. Branded but lower-emphasis than the filled primary.
- Note: `Reject` gets the gradient outline for consistency (no grey); if a negative action should read
  cooler, switch it to a neutral/ghost button — flagged for the port.

## Border reduction (Confirm + Receive)
Confirm had 5 separate bordered boxes (dApp pill, address box, caution, Network card, gas card). Reduced to:
dApp identity **borderless** (favicon + name/url + Verified, hairline under it) · amount hero borderless ·
**Sending-to borderless** (emphasized 18px mono + copy) · caution = amber **tint only, no border** ·
**one merged Details card** (Network + expandable Est. fee, was two cards). Receive's network chip is now
**borderless** (avatar + text, no pill). Receipt keeps its two grouped cards (approved) — flag if you want
those flattened too.

## Data / logic readiness (from audit)
- **Ready, zero new logic:** 030 shell, 031 receipt (all fields on `Transaction`), 032 list (`Network` +
  chainId selection), 034 receive (`qr_flutter` + `CryptoAddressQR` + `CopyButton`).
- **Needs small wire:** 033 fiat line (CoinGecko exists, not wired) — currently marked with `*`.
- **Roadmap (not in this ship):** a "sent-here-before?" scan over the Hive `Box<Transaction>` (`recipients`)
  would let 033 upgrade its static caution to a real new-address warning.

## Port target
The shell decisions belong in `lib/components/bottom_drawer/responsive_drawer.dart` + a small set of
content primitives (padded scroll body, detail-row, status pill, section card) so the padding fix and
these decisions land across all ~19 drawers at once.
