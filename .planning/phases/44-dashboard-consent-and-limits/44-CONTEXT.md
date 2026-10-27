# Phase 44: Dashboard consent and limits - Context

**Gathered:** 2026-10-27 (with Braian; D-01..D-08 are his answers, D-09..D-12 are Claude's, marked (D))
**Status:** Ready for planning

<domain>
## Phase Boundary

Consent inside the transport-independent `GnusRpcHandler` (phase 43): a connect prompt the first time an
origin calls, a native confirm on every `gnus_submitJob` (replacing `rejectGnusConfirm`), prompt limits,
a Settings list of connected sites with revoke, and a secret-leak test over every method. No WebView,
no WalletConnect transport (phases 45-47). Prompts and the list are driven from the dev tools bubble.

</domain>

<decisions>
## Implementation Decisions

### Connect prompt
- **D-01:** Declining the connect prompt returns `4001` (contract section 6, like `eth_requestAccounts`). The roadmap's "declining returns 4100" is corrected to match.
- **D-02:** A connection lasts until the user revokes it. Persisted in Hive through a repository (same pattern as `GnusJobStore`), survives restarts.
- **D-03:** A connection is per origin (exact scheme+host+port), not per origin and wallet. A connected origin sees wallet switches through `gnus_accountsChanged` without a new prompt.
- **D-09 (D):** Revoking forgets the origin, so its next call prompts again (roadmap success criterion 1). `4100` means an origin outside the allowlist, or a call that was in flight when the user revoked. The contract's "revoked returns 4100 until it connects again" is reworded to match; the dashboard's 4100 row ("Allow this site in GeniusWallet", action connect) already fits.
- **D-10 (D):** Every method needs the connection first, `gnus_getAccounts` included. The handler checks it after param validation and before readiness, so an unconnected page learns nothing, not even `4900`.

### Spend confirm
- **D-04:** The confirm reuses `ApproveTransactionDrawer` (`lib/reown/approve_transaction_drawer.dart`) with job-specific content: origin, cost, bridge gas, paying wallet, node account. Amounts are shown formatted from the base-unit strings with `unit.decimals`; addresses in full or with a copy affordance, never only truncated.
- **D-05:** No PIN on approve, same as Send and WalletConnect today.
- **D-11 (D):** The connect prompt uses the same drawer, with the origin as the title. Not a third component (Rule of Three).
- `kGnusConfirmTimeout` (10 min, then reject) stays as built in phase 43.

### Prompt limits
- **D-06:** At most 3 prompts per minute per origin (connect and spend confirm both count, an expired or declined one too). The 4th gets `-32005` `data.reason: rate_limited` with no dialog.
- **D-07:** A call that needs a prompt while that origin's prompt is open gets `-32005` `data.reason: confirm_open` at once. Nothing queues. Reads from a connected origin are not prompts and pass.

### Connected sites list
- **D-08:** Own section in Settings, "Connected sites": one row per origin with when it connected, a revoke button on each row. Separate from WalletConnect sessions.
- **D-12 (D):** Empty state reads "No sites connected". No revoke-all (one origin per network is the expected case).

### Secret-leak test (CNS-04)
- One test seeds known key and mnemonic fixtures, calls every `gnus_*` method through the handler, and fails if any result, error, emitted event, `debugPrint` line or captured Sentry event contains a fixture or its hex/base64 forms.

### Claude's Discretion
- Hive box shape for connections, the rate-limit window implementation, how prompts reach a navigator when no dashboard screen is open, the dev bubble entries, copy wording within the earn terminology rule.

</decisions>

<canonical_refs>
## Canonical References

- `.planning/research/v4.0-gnus-rpc-contract.md` — section 6 (permission rules), error table (4001, 4100, -32005 reasons)
- `.planning/ROADMAP.md` § Phase 44; `.planning/REQUIREMENTS.md` CNS-01..04
- `.planning/phases/43-gnus-rpc-handler-and-job-record/43-CONTEXT.md` — handler shape, confirm seam, submit order
- `lib/gnus_bridge/gnus_rpc_handler.dart` — `GnusConfirm`, `rejectGnusConfirm`, `kGnusConfirmTimeout`
- `lib/reown/approve_transaction_drawer.dart` — the drawer to reuse
- `AGENTS.md` — wallet safety, layering, tokens and WCAG AA in both modes

</canonical_refs>

<code_context>
## Existing Code Insights

- `lib/main.dart` ~line 540: `GnusRpcHandler` wiring, confirm still at its rejecting default.
- `lib/gnus_bridge/gnus_job_store.dart`: Hive repository pattern for the connections store.
- `lib/settings/settings_screen.dart`: `_SettingsSectionCard` sections; add "Connected sites".
- `lib/dev/dev_tools_bubble.dart`: fixture sections (MOCK, JOB, TEST FLOWS) to extend with prompt triggers.
- `lib/reown/handle_dapp_requests.dart`: how the drawer is shown for WalletConnect today.
- The PIN screen is used only in onboarding; no spend is PIN-gated today.

</code_context>

<deferred>
## Deferred Ideas

- PIN or biometric on approving spends: wallet-wide, its own phase (Send would need it too).
- Per-origin spend cap.
- One list merging connected sites and WalletConnect sessions.
- Pending todos matched by keyword only (light-mode backlog, type scale, checkout sheet contract, bridge home, Android WorkManager init): reviewed, not folded.

</deferred>
