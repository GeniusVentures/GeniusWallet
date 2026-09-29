# Phase 38: Account tree switcher - Context

**Gathered:** 2026-09-29
**Status:** Ready for planning

<domain>
## Phase Boundary

The switcher's two lists ("Sending from" and "Node running as") become one "Accounts" list. Each wallet row carries its linked SDK account; the user's own children are nested under their main. Two tags mark the two selections, which stay independent: "Selected" (sends, swaps, balances) and "On node" (the account the GNUS node runs as). Child rows get Fund / Recover / Revoke in their menu. Requirement SWT-07. The Child wallets screen stays.

</domain>

<decisions>
## Implementation Decisions

### One list
- **D-01:** One section, "Accounts", replaces "Sending from" and "Node running as". The Network field above it is unchanged.
- **D-02:** One row per account. An SDK account linked to a wallet is shown on that wallet's row, never as a second row. An unlinked SDK account gets its own row ("Unlinked" + short address). A watch-only wallet is a row that never offers "On node".
- **D-03:** Tags on the row: "Selected" and "On node". Both may sit on one row or on two rows. The existing "Default account" marker for the start account stays.

### Actions
- **D-04:** Tapping a row selects it for wallet features ("Selected"). It never changes the node account.
- **D-05:** "Run node as this" lives in the row menu. It is refused with the existing SWT-06 reason while a child operation from the running account is pending, and never changes "Selected". The row menu keeps the existing items (copy address, rename, delete, Child wallets on the running account).
- **D-06:** Child rows' menus add Fund, Recover and Revoke, going through the existing `ChildOperationsCubit` (same locks, pending badges, timeout, switch-and-continue dialog when the main is not the running account).

### Children in the tree
- **D-07:** While the node runs, the switcher reads each of the user's own SDK accounts' registrations when it opens (and on the refresh the Child wallets screen already uses). A child that is one of the user's accounts is moved under its main, not duplicated.
- **D-08:** A child that is not one of the user's accounts is a leaf row (short address, balance if known) that cannot be selected and has only the child-operation menu.
- **D-09:** Nesting follows registrations recursively; each account appears once; a cycle or a second main stops at the first placement. `ponytail:` ceiling is one pass over the user's own accounts; an SDK by-child query would replace it.
- **D-10:** Mains with children are expanded by default with a chevron to collapse; collapse state lives for the switcher's lifetime only.
- **D-11:** With the node down (or registrations failing) the list is flat, with one note: "Child wallets show while the node is running."

### Surfaces and quality
- **D-12:** Desktop and mobile use the same list. Indentation must fit at phone width without horizontal scroll.
- **D-13:** Colours from `GWColors`; both appearance modes meet WCAG AA, including tag chips and disabled menu items.
- **D-14:** Dev-bubble CHILD WALLETS presets drive the tree as they drive the Child wallets screen.

### Claude's Discretion
- Widget and file names; whether the tree model is a pure function (preferred, testable without the SDK).
- Exact copy beyond the words above, within existing UI conventions.

</decisions>

<canonical_refs>
## Canonical References

- `.planning/REQUIREMENTS.md` — SWT-07 (and SWT-01..06, which stay true)
- `.planning/ROADMAP.md` — Phase 38 success criteria
- `.planning/phases/35-unified-header-switcher/` — the switcher being reworked
- `.planning/phases/36-child-wallet-bindings-read-only-view/` — registrations, balances, dev mock
- `.planning/phases/37-child-write-operations-pending-model/37-CONTEXT.md` — pending registry, locks, amendment D-18/D-19
- `AGENTS.md`

</canonical_refs>

<code_context>
## Existing Code Insights

- `lib/account/account_drawer.dart` — current two-section switcher, `SDKAccountRow`, row menus.
- `AppBloc.sdkAccountName` / `linkedWallet`, `walletSDKBadge`.
- `ChildWalletsCubit`, `ChildOperationsCubit`, `DevMockChildWallets`, `GeniusApi.getChildRegistrations`.

</code_context>

<deferred>
## Deferred Ideas

- Register / Detach / Move from the tree (stay on the Child wallets screen).
- Persisting collapse state.

</deferred>

---

*Phase: 38-account-tree-switcher*
*Context gathered: 2026-09-29*
