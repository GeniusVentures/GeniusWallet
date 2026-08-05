# Phase 21 Context: Drawer language rollout

**Source:** Jakub, 2026-07-26 - picked **A · 031-B1 as decided** in sketch 154, then chose the full
rollout over the narrow one: *"co najmniej 1 ale potem od razu trzeba przejsc przez wszystkie
drawery, czemu nie atakowac calego jezyka drawerow?"* Design artifacts:
`.planning/sketches/drawers-final/` (the consolidated five, chosen 2026-07-23) and
`.planning/sketches/154-transaction-details-drawer/` (variant A, plus the code audit below).

## Domain

Every drawer in the app routes through `ResponsiveDrawer` (`lib/components/bottom_drawer/responsive_drawer.dart`):
a 420px right panel on desktop, a bottom sheet on mobile. Phase 07-06 re-skinned its **header** to
030-B1 and shipped it for all callers (`1d43a13`). Nothing below the header was touched. This phase
applies the four decided **content** patterns and gives the shell the padded body 030-B1 always
specified.

## Locked decisions

1. **D-01 - One shared padded body, opt-in.** `responsive_drawer.dart` gains a padded body (030-B1:
   20px sides, 8 top, 20 bottom). 07-06 deliberately refused a blanket padding because several callers
   already pad themselves and would double up. That reasoning stands: the primitive lands once, and
   **each caller's ad-hoc padding is deleted in the same commit that converts that caller.** No caller
   may end up padded twice, and none may end up unpadded.
2. **D-02 - Receipt = 031-B1** for: `showTransactionDetails` (`transaction_displays.dart`),
   `swap_success_drawer.dart`, `swap_fail_drawer.dart`, `reown/swap_result_drawer.dart`,
   `buy_success_drawer.dart`, `buy_cancelled_drawer.dart`. Identity + amount centred, status pill under
   the amount, rows in **TRANSACTION** / **NETWORK** section cards with hairline dividers.
3. **D-03 - Colour rides on icon + pill + Status row only. The amount stays neutral.** This is the
   031 round-2 rule and it applies to every receipt, not just the transaction one.
4. **D-04 - List picker = 032-A1** for: `network_dropdown_selector.dart` ("Select Network"),
   `token_selector_drawer.dart`, `account_dropdown_selector.dart` ("Your Accounts"),
   `sdk_account_manager.dart` ("SDK Accounts"), `bridge_screen.dart` ("Select destination network"),
   `coins_screen.dart` ("Assets"). Tappable rows, **rounded** gradient-tint selection + gradient check,
   **no** square full-bleed fill and **no** vertical accent bar.
5. **D-05 - Confirm = 033-B1** for `approve_dapp_connection_drawer.dart` and
   `approve_transaction_drawer.dart`. Borderless dApp identity, borderless amount hero, borderless
   sending-to, caution as an amber **tint with no border**, and **one merged Details card**
   (Network + expandable est. fee) rather than the five separate bordered boxes.
6. **D-06 - Receive = 034-A2** for `coins_screen.dart` ("Receive") and `token_info_screen.dart`
   ("Receive {coin}"). Gap above the QR, network chip **above** the QR, address in 4-char chunks with
   first/last emphasised, **copy only** - no Share, no set-default. QR stays black-on-white in both
   themes.
7. **D-07 - Buttons.** Primary CTA = filled gradient. Secondary = **gradient outline** (1.5px gradient
   border, panel-surface fill, no grey border): `View on Explorer`, `Reject`. `Reject` keeps the
   gradient outline for consistency, as `drawers-final/README.md` records - if it should read cooler,
   that is a separate decision, not a silent change here.
8. **D-08 - No flat blue as an accent.** The brand is the gradient (`--brand-cta-b #0AAEE6` →
   `--brand-cta-a #0AD89C`). Coin and dApp brand colours (ETH #627EEA, Uniswap pink) are kept - they
   are not our accent.
9. **D-09 - Drawers that fit none of the four get the padded body and nothing else**, and each plan
   must say so out loud rather than inventing a fifth pattern: `swap_settings_drawer.dart` (a form),
   `account_dropdown_selector.dart`'s "Rename Wallet" / "Delete wallet",
   `network_dropdown_selector.dart`'s "Network Changed" notice, `coins_screen.dart`'s "No coins yet".

## Findings from the code (sketch 154 audit - do not re-derive)

- **`_statusPill` already exists and is already correct.** `transaction_displays.dart:49-75` handles
  all four `TransactionStatus` states with the right tokens, including `cancelled` → slate. It is
  currently used only on wide rows. The receipt's pill is a call, not a new component.
- **`content.valueLine` (fiat) and `content.exactAmount` (unclamped) are computed on the
  `showTransactionDetails` call and thrown away.** `:432` already passes `livePricesBySymbol()`.
  This **corrects sketch 031's** "the receipt has no fiat", which was true when 031 was drawn.
- **`_buildDetailsCard` (`:421`) has vertical padding only** - that is the reported defect.
- **A job's hash IS its job reference:** `:477-480` already labels it `Job` for
  `TransactionType.process`. Keep it; do not print the same value under two labels.
- **An empty explorer URL suppresses the footer button** (`:509`). A drawer with no footer is a real
  state - no pattern may assume the button is present.
- **`TransactionStatus` has four states** (`pending / cancelled / completed / failed`,
  `packages/genius_api/lib/models/transaction.dart:14`). Today only `failed`/`cancelled` get colour
  (`:452`); `pending` gets none.
- Body padding is currently spelled five different ways across callers - `EdgeInsets.all(8)`,
  `all(16)`, `space10`, `space16`, `symmetric(...)` - and is absent in `showTransactionDetails`.

## ⚠ Security fence - the two signing drawers

`approve_transaction_drawer.dart` and `approve_dapp_connection_drawer.dart` are **signing-path UI**.
This phase is a **re-skin only**:

- Do not change what is signed, what is displayed as the amount, the recipient, the chain or the fee.
- Do not change the approve/reject wiring or their callbacks.
- 033-B1's caution copy is **static by design**. The sketch explicitly rejected an unbacked "new
  address" claim because the "sent-here-before?" scan over the Hive `Box<Transaction>` does not exist.
  Do not add a warning the data cannot back.
- The fiat line in 033 carries a `*` because the price feed exists but is **not wired to that drawer**.
  Either keep the `*` or wire it deliberately as its own task - do not quietly drop the marker.
- Plans touching these two files need a threat model.

## Scope fence

- **Do not re-open Phase 07-06's shell header.** Left title, compact 48 toolbar, top-right ✕ appended
  after caller actions, 1px hairline: all stay exactly as shipped. This phase extends the same file.
- Do not change the desktop 420px / mobile bottom-sheet split, or the appearance-aware surface reads.
- Do not change any drawer's mechanics, data source, or navigation. Phase 21 owns chrome and content
  pattern; mechanics stay with the owning phase (8 swap, 9 Banxa, 10 Reown, 12/15 transactions).
- Do not invent data. No confirmations count, no block number, no gas breakdown, no USD fee, no
  "speed up / cancel", no feedback or transaction history that the model does not carry.
- Light mode: dark-first per project rule; do not stall on light-only issues.

## Success criteria

- Every drawer body has the **same** inset, from **one** source, and no drawer is padded twice.
  `showTransactionDetails` no longer touches the panel edges.
- The six receipts read as one family; the six list pickers read as one family; the two confirms and
  the two Receive drawers match their decided sketches.
- The transaction receipt shows the fiat line and the exact amount, and uses the existing
  `_statusPill`; all four states are visibly distinct and the amount stays neutral in every one.
- The two signing drawers are visually re-skinned and **behaviourally identical** - proven, not
  asserted.
- `flutter analyze` clean on every touched file; existing drawer tests pass unchanged.
- **One runnable check per pattern, not per file**: the cheapest thing that fails if that pattern
  regresses. No goldens, no new fixtures, no new packages.

## Claude's discretion

- Whether the shared primitives live in `responsive_drawer.dart` or a sibling file under
  `lib/components/bottom_drawer/`; how the padded body is exposed (a wrapper widget vs a named
  constructor vs a `padBody` flag) - pick the one that makes the caller diffs smallest.
- Wave shape, as long as the shared primitive lands before the callers that consume it.
- Which drawer inside each pattern is converted first.
