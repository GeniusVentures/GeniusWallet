# Phase 35: Unified header switcher - Context

**Gathered:** 2026-09-29
**Status:** Ready for planning

<domain>
## Phase Boundary

One account switcher, on desktop and mobile, replaces the "SDK Accounts" chip and the wallet dropdown. It holds two independent, clearly labelled selections: the SDK wallet (the account the node runs as) and the active wallet (the one that sends, swaps and shows balances). Create, import and delete live in it. Send and Swap name the wallet they spend from (SWT-01..05). The pending-operation switch lock (SWT-06) is Phase 37; child wallets are Phases 36-37.

</domain>

<decisions>
## Implementation Decisions

### Trigger and placement
- **D-01:** Desktop: one chip replaces `SDKAccountManagerButton` and `AccountDropdownSelector` in the same slot of the action-row track (`responsive_overlay.dart` `_buildActionRowWidgets`), keeping `navContextChipStyle`, the avatar and ellipsizing. It shows the active wallet (avatar + name). Its tooltip names both selections ("Sending from X · Node running as Y").
- **D-02:** Mobile: `WalletPill` in `MobileHeader` stays the trigger and opens the unified switcher instead of today's wallet-only drawer. The header cluster width (fixed 100, load-bearing) does not change.
- **D-03:** Network: desktop keeps the separate `NetworkDropdownSelector` in the track; the mobile switcher keeps the network section it has today (`includeNetwork: true`).
- **D-04:** When the node is not connected or has no SDK accounts, the SDK section still renders with an explicit state ("Node not running" / "No SDK accounts yet") instead of disappearing. The chip is shown even when there are no SDK accounts.

### Switcher layout
- **D-05:** One drawer via `ResponsiveDrawer.show` (desktop side panel, mobile bottom sheet) with two sections, in this order: "Sending from" (the user's key and watch-only wallets) then "Node running as" (SDK accounts). Each section has a one-line explanation under its header ("Sends, swaps and balances use this wallet" / "The GNUS node processes and earns as this account").
- **D-06:** Tapping a "Sending from" row selects the active wallet (`WalletDetailsCubit.selectWallet`); tapping a "Node running as" row selects the SDK account (`SelectSDKAccount`). Neither tap changes the other selection.
- **D-07:** The merged `WalletType.sgnus` rows ("SDK Accounts" section inside today's wallet drawer) move out of the wallet list. Each SDK row's menu gains a "View balance" item that selects that account's sgnus wallet as the active view, so the SGNUS balance and transactions stay reachable.
- **D-08:** Rows reuse `GWSelectRow` and the Phase 34 labels (wallet name, short address, "Default account", SDK / SDK PENDING / ACTIVE ON NODE badges). Promote `_RowBadge`, `_AccountSectionHeader`, `_AccountSectionNote` only if reused across files; otherwise keep them local.

### Account actions
- **D-09:** Footer: one primary "Add wallet" (create/import, `/landing_screen`). The SDK section keeps a secondary "Add from phrase or key" (the existing dialog, which since Phase 34 also saves the wallet).
- **D-10:** Per-row menus stay as today: wallet rows (Copy address, Rename, Delete), SDK rows (Set payout address, Copy recovery phrase, Show recovery QR, Delete account, plus D-07's View balance), gated by `sdkRowActions` and the Phase 34 delete rules, unchanged.
- **D-11:** `SDKAccountManagerButton` and `AccountDropdownSelector` are removed once nothing references them; every `AccountDrawer.show` caller moves to the new switcher. No dead widgets left behind.

### Wrong-account guard
- **D-12:** Send's review drawer "From" row shows the wallet name and short address instead of the raw address alone (`send_screen.dart` / `SendTransactionDetails`).
- **D-13:** Swap has no confirm step. The swap screen names the "From" wallet (name + short address) next to its submit button. Adding a confirm step is out of scope.
- **D-14:** Section labels are exactly "Sending from" and "Node running as"; the same words appear in the chip tooltip, so each selection's role reads the same everywhere.

### Claude's Discretion
- Exact chip layout at narrow desktop widths (label hiding below `GeniusBreakpoints.small` stays).
- Widget/file naming for the new switcher (research suggested `lib/account/account_switcher.dart` + `account_switcher_drawer.dart`).
- Empty-state copy wording within D-04's meaning.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope
- `.planning/REQUIREMENTS.md` — `## v3.0 Requirements`, SWT-01..05
- `.planning/ROADMAP.md` — `# Milestone v3.0`, Phase 35 success criteria

### Prior decisions
- `.planning/phases/34-account-linking/34-CONTEXT.md` — labels, "Default account" wording, delete rules, both entry points kept for this phase to place
- `.planning/phases/34-account-linking/34-0*-SUMMARY.md` — what Phase 34 actually built (badges, `sdkAccountName`, `linkedWallet`, `sdkDeleteBlock`)

### Design history
- `.planning/sketches/174-accounts-sdk-vs-private/README.md` — the two selections are independent axes; section headings with a one-sentence explanation; explicit disconnected-node state
- `.planning/todos/completed/2026-08-07-header-no-longer-identifies-which-wallet-is-live.md` — `WalletIdentityAvatar` header identity (keep it)

### Research
- `.planning/research/ARCHITECTURE.md` §(b)(c) — state shape, new vs modified files
- `.planning/research/PITFALLS.md` — two-selection confusion, WCAG/light-mode regressions

### Project rules
- `AGENTS.md` — widgets not helpers, GWColors tokens + WCAG AA in both modes, no SDK/Hive calls in widgets, no plan/decision numbers in source

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `GWSelectRow`, `GWKicker`, `GWSectionTitle`, `GWCard` (`lib/components/cards/`), `GWControlTrack`, `GWDrawerStatusPill`, `GWCopyRow`, `GWWarningNote`, `GWButton`, `GWDialog`.
- `AccountAvatar` (`account_drawer.dart`), `WalletIdentityAvatar` / `walletMonogram` (`mobile_header.dart`).
- `ResponsiveDrawer.show` (`lib/components/bottom_drawer/responsive_drawer.dart:91`): side panel at `GeniusBreakpoints.medium`+, bottom sheet below.

### Established Patterns
- Header chips use `navContextChipStyle` inside a `Flexible` so they ellipsize; labels hide below `GeniusBreakpoints.small`.
- Drawer rows: `GWSelectRow` with a trailing badge/balance cluster and a ⋮ menu.
- The mobile header cluster lives in the AppBar `title` at a fixed 100px width on purpose.

### Integration Points
- `_buildActionRowWidgets` (`lib/components/overlay/responsive_overlay.dart:22-87`) — desktop slot.
- `WalletPill` (`lib/components/overlay/mobile_header.dart:379-479`) — mobile trigger.
- `AccountDrawer.show` callers; `sdk_account_manager.dart` drawer body and add dialog.
- Send review: `lib/send/send_screen.dart:269`, `lib/reown/send_transaction_details.dart:78`. Swap submit: `lib/squid_router/swap_screen.dart:451,777`.
- Tests that pin today's behaviour: `test/account/account_drawer_show_test.dart` (title "Accounts"), `account_drawer_network_section_test.dart`, `sdk_*` tests, `test/components/desktop_top_bar_text_scale_test.dart`, `mobile_header_brand_and_pill_test.dart`, `wallet_identity_test.dart`, `test/theme/nav_chip_style_test.dart`.

</code_context>

<specifics>
## Specific Ideas

- Section labels "Sending from" / "Node running as".
- Swap names its "From" wallet beside the submit button rather than gaining a confirm step.

</specifics>

<deferred>
## Deferred Ideas

- A confirm step for Swap (would be a new capability).
- Switch lock while an operation is pending: Phase 37 (SWT-06).

</deferred>

---

*Phase: 35-unified-header-switcher*
*Context gathered: 2026-09-29*
