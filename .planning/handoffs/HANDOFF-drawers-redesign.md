# HANDOFF — Drawers Redesign (design session, 2026-07-23)

**Session role:** DESIGN (sketch). No commits, no `lib/` edits, no `flutter run`. All output is under
`.planning/sketches/`. MANIFEST touched (see caveat at bottom).

## One-line summary
Surveyed every drawer in the app, found they all share one presenter with a real padding bug, and
produced a full set of redesign sketches → user picked five winners → delivered them consolidated in a
single reviewed file with all refinements applied.

## What was done today
1. **Inventory** — every slide-in panel (~19) routes through **one** presenter:
   `ResponsiveDrawer.show()` (`lib/components/bottom_drawer/responsive_drawer.dart`); desktop = 420px
   right-edge panel, mobile = bottom sheet. Plus a few center dialogs and one Banxa bottom sheet.
2. **Root-cause of the "Escrow released" squish** (the screenshot): the shell is fine — callers pass
   bodies with **no shared padding convention**. The tx-detail drawer passes a bare `ListView` with
   **zero horizontal padding** → values slam the window edge. Fix belongs in the shell + shared
   content primitives, which repairs all ~19 at once. Source: `transaction_displays.dart:329-420`
   (`showTransactionDetails`) + `_buildDetailsCard`/`_buildRow`.
3. **Sketches** — 5 archetypes, `.planning/sketches/030-034`:
   030 shell · 031 receipt · 032 list-picker · 033 confirm-action · 034 receive-qr. Round 1 (A/B/C
   each) → **data/logic audit** → Round 2 fine-tunes.
4. **Consolidated deliverable** (the thing to build from):
   **`.planning/sketches/drawers-final/index.html`** + `README.md` — all five chosen designs in one
   file, switchable, dark+light, live.

## The five chosen designs (final)
| Drawer | Pick | Notes |
|--------|------|-------|
| 030 Shell | **B1 Quiet band** | left title + close top-right, faint **gradient** hairline, 20px body padding, header-sep→first-content gap = 32px (> amount→section 20px). |
| 031 Receipt | **B1 Pill + sections** | 4 real `TransactionStatus` states (Completed/Pending/Failed/**Cancelled=slate**); colour on icon+pill+status **only, amount stays neutral**; short minus `−`. |
| 032 List | **A1 Comfortable** | rounded **gradient-tint** selection + gradient check, **no accent bar**, gap under separator matched to title→separator. |
| 033 Confirm | **B1 Static caution** | borders reduced (see below); static caution (no unbacked "new address" claim); fiat marked `*` = not wired. |
| 034 Receive | **A2 Grouped address** | chip above QR, 4-char grouped address (no "Your address" label), **Copy only**. |

## Design-system decisions locked this session
- **Brand accent = gradient, never flat blue.** `--brand-cta-b #0AAEE6 → --brand-cta-a #0AD89C` (the real
  `brandCta`, NOT brandPrimary/brandSecondary). Applies to: active states, list selection+check, GNUS
  avatar, header hairline, CTAs, toast accent. Coin/dApp brand colours (ETH #627EEA, Uniswap pink) kept.
- **Buttons:** primary CTA = **filled gradient** (`Copy address`, `Approve`); secondary = **gradient
  OUTLINE** (1.5px gradient border, panel-surface fill — no grey border) (`View on Explorer`, `Reject`).
- **Fewer borders:** Confirm collapsed from 5 bordered boxes → borderless dApp id + borderless
  Sending-to + tint-only caution + **one merged Details card** (Network + expandable gas). Receive
  network chip is **borderless**.

## Data / logic readiness (audited against real code)
- **Ready, zero new logic:** 030, 031 (all fields on `Transaction`, `packages/genius_api/.../transaction.dart`),
  032 (`Network` list + chainId selection), 034 (`qr_flutter ^4.1.0` + `CryptoAddressQR` + `CopyButton`).
- **Small wire needed:** 033 fiat line — CoinGecko exists (`_fetchMarketData`) but not wired to the approve
  drawer (currently shown with `*`).
- **Roadmap (not this ship):** 033 "sent-here-before?" recipient-history scan over the Hive
  `Box<Transaction>` (`recipients`) — would upgrade the static caution to a real new-address warning.
- **Respected gaps (don't add):** 034 has no Share (only `CopyButton` exists) and no "set default receive
  address" (real More Options = Submit Job + Delete Wallet).

## Open decisions for the user (not yet answered)
1. **Reject button** — currently gradient outline for consistency; may want neutral/ghost (gradient reads
   as "go/approve"). Flagged, not decided.
2. **Receipt two cards** (TRANSACTION / NETWORK) — approved earlier, left as-is; user's "too many borders"
   *might* extend here. Offered to flatten to one section; awaiting word.

## Port target (for the execution session)
Land the shell decisions in `lib/components/bottom_drawer/responsive_drawer.dart` + a small set of shared
content primitives (padded scroll body, `detail-row` label→value, `status pill`, `section card`,
`gradient-outline secondary button`). That fixes the padding bug and applies these designs across all
~19 drawers at once. Banxa drawers are auto-generated — design only, no code edits there.

## Verification state
030/031/032/034 round-2 + the consolidated file were browser-verified via screenshots earlier today.
The **final border-reduction + gradient-button pass on Confirm/Receive was verified by code inspection
only** (grep: no orphaned classes, all handlers wired) — the browser action classifier was temporarily
unavailable when those last edits landed, so a fresh screenshot pass is still owed.

## Caveats
- **Nothing committed** (per project rule — commits gated on explicit user authorization).
- **MANIFEST collision:** a parallel session added a second `030` row (`transactions-status-placement`).
  My rows are `030-034 = drawer-shell/receipt/list-picker/confirm-action/receive-qr`; directories on disk
  are intact. The duplicate `030` number in the table is cosmetic (distinct Name column).
- Preview server was on `localhost:8777` (throwaway). Open the deliverable directly:
  `open .planning/sketches/drawers-final/index.html`.
