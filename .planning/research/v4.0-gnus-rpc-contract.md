# gnus_* RPC contract, v1 (draft 2026-10-26)

Owner: the GeniusWallet side, GSD milestone v4.0. Canonical copy: GeniusWallet
`.planning/research/v4.0-gnus-rpc-contract.md` (branch `claude/gsd-dashboard-bridge-milestone-b6a5e7`
until merged). The copy in the side-session notes folder mirrors it for the dashboard session.
gnus-dashboard consumes it. `window.gnus.version` bumps on any breaking change.

Status: DRAFT. Decisions marked (D) were taken by the wallet session overnight on Braian's standing
instruction to answer GSD questions itself; Braian can overturn any of them.

## 1. Shape

One call shape on every transport, EIP-1193 style:

```ts
request({ method: string, params?: object }): Promise<result>
// rejects with { code: number, message: string, data?: object }
on(event: string, handler: (payload) => void): void
removeListener(event: string, handler): void
```

- `params` is always an object (named params), never a positional array.
- Amounts are decimal strings, never JS numbers (u64 and 1e18 values overflow `Number`).
- Addresses are lowercase strings with `0x`. Two formats exist and are never mixed:
  - `sdkAddress`: `0x` + 128 hex. The GeniusSDK account (node identity, earns, owns jobs).
  - `evmAddress`: `0x` + 40 hex. The EVM wallet that pays (burns GNUS via `bridgeOut`).
  An SDK address cannot be derived from an EVM address. The dashboard must key "my jobs" and
  "earnings" on `sdkAddress` and show the EVM payer only as a label.

## 2. Transports and detection

| Where the dashboard runs | Transport | Detection |
|---|---|---|
| Inside GeniusWallet (WebView) | Injected `window.gnus` | `window.gnus?.isGeniusWallet === true` |
| Normal browser | WalletConnect session with GeniusWallet | no `window.gnus` |

Rules:

- (D) One provider per session. If `window.gnus` exists, the dashboard does not mount or open
  Web3Modal/WalletConnect at all, and never calls `bridgeOut` or `/api/processing/*` itself.
- In-wallet readiness: on Android, iOS and macOS the shim can only be injected after page start, so
  the dashboard waits for the `gnus#initialized` window event if `window.gnus` is absent at load,
  for up to 3 s, before falling back to the browser path. Windows and Linux inject at document start.
- `window.gnus.version` = contract version string, `"1"`.
- WalletConnect (D): the `gnus_*` methods and events ride the `eip155` namespace as
  **optional** methods/events, on chain `eip155:80002` (Polygon Amoy, where `bridgeOut` lives)
  plus the wallet's GNUS chains. The wallet approves a session only if the proposal asks for
  `gnus_*` methods it implements. Payload is identical to the injected path:
  `session_request` with `{ method, params }`; events go out as `session_event`.
- Over WalletConnect a request can time out (wallet closed, phone backgrounded). The dashboard shows
  a "wallet offline" state on timeout, not a spinner. Suggested timeout: 60 s for reads, none for
  `gnus_submitJob` (it waits on a human confirm).

## 3. Methods

### `gnus_getAccounts` (read, no prompt)

Params: none. Result:

```json
{
  "node": {
    "sdkAddress": "0x<128 hex>",
    "linkedEvm": "0x<40 hex> | null",
    "role": "main | child | none",
    "main": "0x<128 hex> | null"
  },
  "payer": { "evmAddress": "0x<40 hex> | null", "canSign": true },
  "switching": false,
  "network": { "sdk": "<SDK network name, e.g. staging>", "evmChainId": 80002 }
}
```

- `node` is the account the node runs as ("Earn with this account"). `payer` is the wallet that
  pays ("Sending from"). They can differ by design.
- `payoutAddress` is intentionally absent: the SDK has no getter (SDK dependency SDK-PAYOUT).
- Replaces the spike's `gnus_getAddress`, which is retired.

### `gnus_estimate` (read, no prompt)

Params: `{ "job": <processing-definition object> }`. The job object is the SDK's current
processing-definition schema (`inputs`/`outputs`/`passes`, see SuperGenius
`test/src/processing_schema/posenet-processing-job.json`), passed as an object, not a string. The old
`data/model/input` shape is not accepted.

Result:

```json
{
  "cost": "<decimal string: the exact amount the wallet would burn, SDK units>",
  "gas": { "amount": "<decimal string>", "symbol": "<native coin symbol>" } ,
  "balance": "<decimal string: payer's GNUS balance, same units as cost>",
  "network": { "sdk": "...", "evmChainId": 80002 }
}
```

- `gas` is null when it cannot be estimated (the call still succeeds; `cost` is what matters).
- A zero or failed SDK cost is an error (`-32010`), never `cost: "0"`.
- Open question U1: the wallet burns the SDK cost integer as-is; the current dashboard multiplies the
  estimate by 1e18. Until the SDK documents its unit, the wallet's behaviour (burn as-is) is the
  reference and the dashboard must display `cost` with the wallet's decimals, not re-scale it.

### `gnus_submitJob` (spend, native confirm every time)

Params: `{ "job": <processing-definition object>, "idempotencyKey": "<client uuid>" }`.

The wallet does the whole flow atomically, under its existing bridge gate: estimate, show a native
confirm (origin, cost, gas, payer, node account), burn via `bridgeOut` from the payer, then
`GeniusSDKProcess` as the node account. The dashboard never burns by itself.

Result:

```json
{
  "jobId": "<string | null>",
  "burnTxHash": "0x<64 hex>",
  "sdkAddress": "0x<128 hex>",
  "status": "submitted | bridgedNotProcessed"
}
```

- `jobId` is null until the SDK returns one from Process (SDK dependency SDK-JOBID). Without it,
  `gnus_getJob` cannot work and "my jobs" is keyed on `burnTxHash`.
- `bridgedNotProcessed`: the burn succeeded and Process failed. Funds are spent. The dashboard shows
  a recoverable state keyed by `burnTxHash`; the wallet keeps the record.
- Same `idempotencyKey` within 24 h returns the first call's result instead of burning again (covers
  reloads and double clicks). Two concurrent calls from one origin: the second gets `-32005`.
- Rejected confirm: `4001`.

### `gnus_listJobs` (read, no prompt)

Params: `{ "limit"?: 1-100 (default 20), "cursor"?: string }`. Jobs the wallet submitted for the
current node account (from the wallet's own record until the SDK has a per-account history).

Result: `{ "jobs": [Job], "nextCursor": string | null }`, with

```json
Job = {
  "jobId": "<string | null>",
  "burnTxHash": "0x...",
  "sdkAddress": "0x<128 hex>",
  "origin": "<origin that submitted it>",
  "submittedAt": "<ISO 8601>",
  "cost": "<decimal string>",
  "status": "submitted | queued | processing | completed | failed | bridgedNotProcessed | unknown"
}
```

`status` is `submitted` or `bridgedNotProcessed` until SDK-STATUS lands; then the live states.

### `gnus_getJob` (read, no prompt)

Params: `{ "jobId": string }` or `{ "burnTxHash": string }`. Result: `Job` plus
`{ "result": { "cids": [string], "data"?: object } | null, "error"?: string }`.
Needs SDK-JOBID and SDK-STATUS/SDK-RESULT; until then it returns the wallet's own record with
`result: null`.

### `gnus_getEarnings` (read, no prompt)

Params: `{ "includeChildren"?: false }`. Result:

```json
{
  "sdkAddress": "0x<128 hex>",
  "balance": "<decimal string: node account's SGNUS balance>",
  "processing": { "isProcessing": true, "jobsProcessed": "<decimal string | null>" },
  "earned": { "total": "<decimal string | null>", "history": [ { "at": "...", "amount": "...", "jobId": "..." } ] | null }
}
```

- `balance` and `processing.isProcessing` are available now.
- `jobsProcessed`, `earned.*` are null until SDK-EARNINGS lands. The dashboard must render null as
  "not available yet", never as 0.
- (D) `includeChildren` is accepted but ignored in v1 (returns the node account only). Aggregating
  children waits on SDK-EARNINGS.

## 4. Events

| Event | Payload | When |
|---|---|---|
| `gnus_accountsChanged` | the `gnus_getAccounts` result | node or payer account changed, or `switching` flipped |
| `gnus_networkChanged` | `{ sdk, evmChainId }` | SDK network or EVM chain changed |
| `gnus_jobUpdated` | `Job` | a job's status changed (wallet-polled until SDK pushes) |
| `disconnect` | `{ code, message }` | WebView closing, or WalletConnect session ended |

## 5. Errors

| Code | Meaning |
|---|---|
| 4001 | User rejected the confirm |
| 4100 | Origin not allowed, or permission not granted for this origin |
| 4200 | Method not supported |
| 4900 | Wallet not ready (SDK not initialized) |
| 4901 | Account switch in progress (`switching: true`); retry after `gnus_accountsChanged` |
| -32602 | Invalid params (bad job schema, bad address, out-of-range limit) |
| -32603 | Internal error |
| -32005 | Rate limited, or a confirm for this origin is already open |
| -32010 | Cost unavailable (SDK returned 0 or failed; `data.reason` when the SDK provides one) |
| -32011 | Insufficient GNUS balance for `cost` |
| -32012 | Payer cannot sign (watch-only, `sgnus` row, or child without key) |
| -32013 | Bridge (burn) failed; nothing spent |
| -32014 | Burn succeeded, Process failed; `data.burnTxHash` set (same as `status: bridgedNotProcessed`) |

## 6. Security rules the wallet enforces (dashboard can rely on them)

- Origins: exact scheme+host+port allowlist, one pinned https origin per network in release builds
  (D); `http://localhost:<port>` only in dev builds. The bridge drops any reply whose origin changed
  between request and reply.
- Top frame only. Messages from iframes never reach the bridge.
- Top-level navigation is locked to the allowlist; popups and `target=_blank` open in the system
  browser.
- Per-origin permission: the first call from an origin asks the user to connect (like
  `eth_requestAccounts`). Reads after that need no prompt; every `gnus_submitJob` prompts.
- No method returns keys, mnemonics or anything derived from them.

## 7. SDK dependencies (not wallet work)

| Id | Need | Blocks |
|---|---|---|
| SDK-CA | CA bundle path is the CI runner path baked into the binary, so the price request fails and cost is always 0 | `gnus_estimate`, `gnus_submitJob` live |
| SDK-COSTERR | `GeniusSDKGetCost` returns a bare 0 for every failure; needs error codes | `-32010` `data.reason` |
| SDK-JOBID | `GeniusSDKProcess` returns only a status code; needs a job id | `jobId`, `gnus_getJob` |
| SDK-STATUS | per-job status query (today only node-wide status) | live `Job.status` |
| SDK-RESULT | result query by job id (today `GetTaskResult` takes a task id nobody returns) | `gnus_getJob.result` |
| SDK-EARNINGS | per-account processed-job and earnings history | `gnus_getEarnings.earned`, `jobsProcessed` |
| SDK-PAYOUT | payout address getter | `node.payoutAddress` (future) |
| SDK-ASYNC | async or thread-safe cost/process calls (the wallet will move them off the UI isolate either way) | UI freeze of 100-800 ms per estimate |

## 8. Open questions

- U1: cost units (see `gnus_estimate`).
- U2: can a browser user with MetaMask and no GeniusWallet submit jobs? (D) Not via this contract:
  the dashboard needs a GeniusWallet provider to submit. Browser-only users get read-only views.
- U3: phone pays, desktop earns (two devices). Out of v1; needs an account-link step signed on both
  sides.
- U4: who mints a given burn on the SuperGenius side (which account a payment credits). Today the
  wallet's bridge mints to the node's selected SDK account; the contract assumes that.
