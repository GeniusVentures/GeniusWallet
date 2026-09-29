# Phase 37: Child write operations & pending model - Context

**Gathered:** 2026-09-29
**Status:** Ready for planning

<domain>
## Phase Boundary

The user can register one of their SDK accounts as a child of a main, fund a child, recover funds from a child, revoke a child, detach a child, and move a child to a new main (CHILD-03..08). When an action must run as the other account the app says so and offers to switch (CHILD-09). Every submitted operation shows as pending until the SDK's observable state reflects it, then done, or "Not confirmed yet" after a timeout (PEND-01); the same operation cannot be resubmitted while pending (PEND-02); the SDK wallet cannot be switched while an operation submitted from it is pending (SWT-06). Dev mocks cover every operation incl. pending and timeout (the rest of VER-01). VER-02 closes here for traceability.

</domain>

<decisions>
## Implementation Decisions

### Who runs what (from the SDK, fixed)
- **D-01:** Main-side operations: fund, recover, revoke. Child-side operations: register, detach, replace-main. `RegisterChild` runs on the child's node. The wallet never lets an operation run from the wrong side.

### Where the actions live
- **D-02:** All actions live on the Phase 36 `/child-wallets` screen (no new route).
- **D-03:** Child rows (the running account is the main) get a row menu: "Fund", "Recover", "Revoke".
- **D-04:** A "This account" card at the top of the screen describes the running SDK account's own position:
  - If it is registered as a child of a main — found by querying `GetRegistrationsForMain` for each of the user's other SDK accounts — it reads "Child of {main}" with actions "Detach" and "Move to another main".
  - If no own account lists it as a child, it reads "Not registered as a child" with the action "Register as a child of…". A main registered by someone else's account is not discoverable (the SDK has no by-child query); the card then offers registration, and a failed or duplicate registration surfaces as "Not confirmed yet".
- **D-05:** The main picker (register, move) lists the user's other SDK accounts by linked wallet name + short address, plus "Enter an address" with validation against the SGNUS address format (length/hex as the SDK expects). The running account itself is never offered.

### Switching to the other side
- **D-06:** When the user starts an action from a surface whose required side is not the account the node runs as, a dialog names the required account and offers "Switch and continue" (dispatches `SelectSDKAccount`, waits for the switch to land, then reopens the action) or "Cancel". The dialog never switches silently. If the SWT-06 lock applies, the switch is refused with its reason instead.

### Amounts and confirmation
- **D-07:** Fund and Recover take a GNUS amount (up to 6 decimals, parsed exactly, no floating point), must be > 0 and ≤ the paying side's balance: the main's GNUS balance for Fund, the child's balance for Recover. The GNUS variants of the SDK calls are used (`FundChildGNUS`, `RecoverFromChildGNUS`).
- **D-08:** Every action opens a confirmation that names both accounts. Revoke, Detach and Move are worded as irreversible for the current registration ("Revoke {child}? It will no longer be a child of {main}."). Fund/Recover confirm amount, from and to.
- **D-09:** Registration metadata is sent as empty strings and `peers_cut = 0` (no consumer, out of scope).

### Pending model
- **D-10:** One app-level pending-operations registry (a cubit provided above the router) owns every in-flight child operation: kind, from-account, target(s), amount, submitted-at, observed baseline. Operations never live only in a screen's State.
- **D-11:** Resolution signals, re-checked on the Phase 36 10-second poll and on demand:
  - Register → the child appears under the chosen main's `GetRegistrationsForMain`.
  - Fund → the child's balance rises by the amount relative to the baseline.
  - Recover → the child's balance falls by the amount relative to the baseline.
  - Revoke / Detach → the child disappears from the main's list.
  - Move → the child disappears from the old main and appears under the new one.
- **D-12:** Timeout: 2 minutes after submission an unresolved operation becomes "Not confirmed yet" (never "done"), stays visible with a "Check again" action, and stops blocking. A non-OK return at submission is an immediate failure with the SDK's reason, not pending.
- **D-13:** Pending state is in memory for the app's lifetime; an app restart forgets it. — `ponytail:` accepted ceiling; upgrade path is persisting the registry (public addresses and amounts only).
- **D-14:** Pending, done and not-confirmed show on the affected child row (and the "This account" card for child-side operations) with the Phase 34 badge pattern (SDK PENDING style) and plain words ("Funding 1.5 GNUS…", "Not confirmed yet").

### Locks
- **D-15:** PEND-02: while an operation of a kind is pending for a target, that action is disabled on that target with the reason ("Already funding this child"). Different targets are independent.
- **D-16:** SWT-06: while any operation submitted from the running SDK account is pending, "Node running as" rows in the switcher are disabled for switching away, with the reason ("Waiting for a child operation from {account} to confirm"). Timed-out operations do not lock. Active-wallet switching is never locked.

### Dev mocks
- **D-17:** `DevMockChildWallets` gains write simulation: submits return OK and the mocked list/balances change after a few seconds (confirming), or never change (timing out), or the submit returns an error — selectable in the CHILD WALLETS bubble section. Real SDK write calls are never made while a mock preset is active.

### Claude's Discretion
- Exact widget/file names; whether the registry lives in `lib/child_wallets/`.
- Timeout constant placement (single named constant).
- Copy wording beyond the examples above, within the UI-SPEC.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope
- `.planning/REQUIREMENTS.md` — `## v3.0 Requirements`: CHILD-03..09, PEND-01..02, SWT-06, VER-02 (and VER-01's write-op part)
- `.planning/ROADMAP.md` — `# Milestone v3.0`, Phase 37 success criteria

### SDK contract
- `C:/Users/User/Documents/Projects/GNUS/GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h` — child functions ~505-720 (fire-and-forget notes ~649-653, ~714-718)
- `.planning/research/FEATURES.md` — who calls what, three levels of "real", no tx hash
- `.planning/research/PITFALLS.md` — switch races during in-flight submissions, double submit, stale balances

### Prior phases
- `.planning/phases/36-child-wallet-bindings-read-only-view/36-CONTEXT.md`, `36-UI-SPEC.md`, SUMMARYs — the screen, cubit, wrappers (`registerChild`, `fundChildGnus`, … with boundary checks), dev mock
- `.planning/phases/35-unified-header-switcher/35-CONTEXT.md` + SUMMARYs — switcher, `SDKAccountRow`
- `.planning/phases/34-account-linking/34-CONTEXT.md` — names, "Unlinked", badges

### Project rules
- `AGENTS.md`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `ChildWalletsCubit`, `/child-wallets` screen, `DevMockChildWallets` (Phase 36).
- `GeniusApi` child wrappers (Phase 36, boundary-checked) and `getChildRegistrations` / `getChildBalanceAll`.
- Phase 34 badge component and "SDK PENDING" wording; `sdkAccountName` / `linkedWallet`.
- "Observe the list, don't trust the call" pattern (`sdk_account_manager.dart` add/delete dialogs).

### Integration Points
- Switcher "Node running as" rows (`lib/account/account_drawer.dart`) — SWT-06 lock.
- App root providers (`lib/main.dart` / router shell) — the pending registry.
- `lib/dev/dev_tools_bubble.dart` CHILD WALLETS section — write-simulation presets.

</code_context>

<specifics>
## Specific Ideas

- "Not confirmed yet" is the only terminal wording for an unresolved operation; nothing ever says "done" without the signal.
- The switch dialog names the account it will switch to.

</specifics>

<deferred>
## Deferred Ideas

- Persisting pending operations across restarts (D-13 upgrade path).
- Discovering a main that belongs to someone else (needs an SDK by-child query).
- Registration metadata UI (game integrations).

</deferred>

---

*Phase: 37-child-write-operations-pending-model*
*Context gathered: 2026-09-29*

## Amendment (after code review, 2026-09-29)

- **D-18 (supersedes D-12's "stops blocking" for fund/recover only):** at most one outstanding balance operation (Fund or Recover, from any account) per child at a time. A timed-out fund/recover shows "Not confirmed yet" but keeps blocking a new fund/recover on that child until its baseline expires (6 minutes) or "Check again" observes it landed. No merging, carrying or cross-account accounting of attempts. Why: three review rounds showed that merging overlapping attempts on one balance keeps producing paths to a false "done"; one-at-a-time makes attribution unambiguous. Register, revoke, detach and move keep D-12 as written.
- **D-19:** a Recover never resolves on a child balance read of 0 (the SDK cannot tell empty from not-synced); a recover that empties the child ends "Not confirmed yet".
- **Known ceiling:** a Fund whose baseline was read as 0 before the child synced can resolve when the real balance appears. `ponytail:` — upgrade path is a per-write tx hash when the SDK offers one.
