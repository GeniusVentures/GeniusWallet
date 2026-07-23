---
sketch: 033
name: confirm-action
question: "How should an Approve/Reject request drawer present WHO is asking and WHAT is being signed?"
winner: "B"
tags: [drawers, confirm, approve, reject, dapp, reown, security]
---
# Sketch 033: Confirm / Action

## Design Question
This is the security-critical archetype: a dApp asks the user to Approve or Reject
(the drawer returns a bool). The reviewer must, in one glance, trust WHO is asking
and understand WHAT they are about to sign — before their thumb reaches Approve.
How should the drawer lay out identity + payload so approve/reject is safe and legible?

Shell: variant A · Framed (centered title "Transaction Request", close ✕, 20px
padding). The footer here is unusual — TWO buttons side by side: Reject (outline)
+ Approve (gradient).

## How to View
open .planning/sketches/033-confirm-action/index.html

## Variants
- **A · Stacked details** — WHO first (dApp identity block: favicon + name + url +
  verified badge), then WHAT (a details card with the amount as hero, then
  To / Network / Fee rows). The clean, boring baseline.
- **B · Sign-emphasis** — WHAT is the hero: a large amount + fiat dominates, the To
  address gets its own focus block with a copy button, and the dApp shrinks to a
  compact chip. An amber "new address" warning banner communicates risk and can be
  present or not (toolbar toggle to compare both states).
- **C · Split request card** — a single framed request card: dApp row on top, a
  divider, then the payload. A Transaction/Connection mode toggle proves BOTH cases
  are covered — transaction mode shows tx details, connection mode swaps in a
  permissions list. Full-width buttons; Approve fakes a loading→success beat.

## What to Look For
- Does identity read as trustworthy before the amount pulls the eye? (A vs B ordering)
- Is the destination address prominent enough to catch a wrong-recipient mistake? (B)
- Does the risk warning read as a real stop, or is it easy to bulldoze past?
- Reject and Approve are equal-width — is Approve still clearly the affirmative
  (gradient) without being so dominant that Reject is missed?
- C's mode toggle: does one card shape hold both a transaction and a connection grant?

## Interactions
- Variant tabs, Dark/Light theme.
- B: warning banner toggle (toolbar) + its own dismiss ✕.
- C: Transaction/Connection mode toggle (also flips the drawer title).
- Approve → loading spinner → success → toast → slide-out (backend faked).
- Reject / close ✕ → slide-out. Copy → toast.

## Covers
Transaction Request (hero — `lib/reown/approve_transaction_drawer.dart`),
Connection Request (dApp connect / permissions grant —
`lib/reown/approve_dapp_connection_drawer.dart`).

## Round 2 — B fine-tunes (gap-aware)

Winner: **B · Sign-emphasis** — foreground WHAT is being signed (amount hero +
destination address), dApp shrinks to a compact verified chip. Round 2 reuses the
refined **030 · B1 "Quiet band"** shell verbatim (left title, close ✕ top-right,
1px `--brand-primary-subtle` hairline, gradient only on the CTA). Footer is the two
side-by-side buttons: Reject (outline) + Approve (gradient, slightly wider).

### The audit gap this round exists to fix
The round-1 winner leaned on an amber banner reading **"you're sending to a NEW
address."** Audit result: **there is no known/new-address detection anywhere in the
codebase.** There is no address book and no history-lookup. There IS a per-wallet
Hive `Box<Transaction>` (`lib/hive/services/transaction_storage_service.dart`) whose
`Transaction.recipients` could in principle be scanned — but nothing scans it today.
So the banner made a claim the app cannot back. The three fine-tunes are the three
honest ways to handle that gap; the **baseline · chosen B** tab keeps the old banner
for side-by-side comparison of exactly what the audit flagged.

- **B1 · Static caution (ships today, zero new logic).** No "new address" claim. A
  neutral amber info row: *"Double-check the recipient address before approving.
  GeniusWallet can't undo a transfer."* True regardless of history. No backend.
- **B2 · Built-check (REQUIRES new logic — the only variant that does).** Shows both
  resulting states of a would-be "have I sent here before?" lookup via a segmented
  toggle: a warning *"You haven't sent to this address before"* (amber) and a
  reassurance *"You've sent to this address before ✓"* (subtle green). Carries a dim
  honesty label — **"needs: history scan over Hive Transaction box (recipients) —
  not built."** This is a preview of the feature IF built, not a shipped state.
- **B3 · Verify-by-legibility (ships today, zero new logic).** No banner at all.
  Risk is mitigated by making the address human-verifiable: character-grouped mono
  (`0x7a9f · 4b2c · … · 3C21`) with first/last chunks emphasized, a copy button, and
  a "reveal full address" expander that groups all 40 hex chars in fours.

### Data honesty
Real signing fields drawn from `send_transaction_details.dart` (fromAddress,
toAddress, amount, totalGasFee, maxFeePerGas, priorityFee). Gas is collapsed by
default to "Est. network fee 0.0012 ETH" and expands to Gas Fee / Max Fee Per Gas /
Priority Fee. The dApp favicon is a letter-fallback square ("U") — real impl is
`Image.network(peer.metadata.icons[0])` with an errorBuilder fallback, which CSP
blocks here. Fiat "≈ $478.65" carries a dim asterisk and help tooltip: the CoinGecko
feed exists but is **not wired to this drawer**, so it is not presented as live.

### Recommendation
**B1 · Static caution.** It closes the audit gap with zero backend work and never
makes a claim the app can't stand behind — the caution is true on every transfer. B2
is the strongest UX *if and only if* the history scan gets built (a real, bounded
piece of work over the existing Hive box), so keep it on the roadmap, not the
critical path. B3 is an excellent complement to whichever caution ships — grouped
mono + reveal-full is pure legibility with no logic — and its address rendering
should fold into B1. Ship **B1 now, layer B3's address legibility on top, and
promote B2 when the recipient-history scan lands.**
