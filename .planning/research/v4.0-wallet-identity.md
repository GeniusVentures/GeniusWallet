# Two wallets, one dashboard: identity research (2026-10-26)

**Question.** The dashboard can have a wallet connected to it (Web3Modal / WalletConnect), while the GeniusWallet app has its own wallet and runs a node. How does that work, and what breaks?

**Short answer.** Today it does not work as one identity. "Who pays", "who owns the job" and "who earns" are three different accounts, and nothing in either codebase ties them together. To make it work:

- Treat the wallet as the single source of truth for identity.
- Give the dashboard one provider per session.
- Make paying and submitting one atomic wallet call.

Details below. Sources: the dashboard at 707accb, the wallet at develop 7b0d7a1a, and the bridge spike.

## The identities that exist

| # | Identity | Format | Where it lives | What it does |
|---|---|---|---|---|
| 1 | Dashboard-connected wallet | EVM 0x + 40 hex | Web3Modal in the browser (`OrderForm.tsx:23`) | Signs `bridgeOut` on Polygon Amoy and pays ERC1155 id 0 (`OrderForm.tsx:336-341`) |
| 2 | Wallet app "Sending from" wallet | EVM | `WalletDetailsCubit.selectedWallet`, persisted in Hive | Signs sends, swaps and the burn in the wallet's own job flow, and every WalletConnect transaction |
| 3 | Wallet app "Node running as" (earning account) | SDK address, 0x + 128 hex | `getSelectedAccountAddress()`, `AppState.selectedSDKAccount` | Runs `GeniusSDKProcess`, receives bridge mints, earns from processing |
| 4 | Payout address | EVM | `GeniusSDKSetPayoutAddress` on the selected SDK account | Where earnings are paid out. There is no getter, so nothing can read it back |
| 5 | Main / child relation | SDK addresses | `reg/{child}` records, `getChildRegistrations(main)` | A child names one main. Earnings do not roll up to the main automatically |
| 6 | Dashboard server's own SDK key | private key literal | `functions/ipfs/node.ts:139-144` | Every `/api/processing/submitJob` runs as this one account |

Two facts drive most of the edge cases:

- **No conversion from #1/#2 to #3.** The SDK address is derived from the key through an ElGamal signature and a hash. It is not the secp256k1 public key, so you cannot compute an SDK address from an EVM address. The only mapping is the wallet's `sdkAccountLinks` table, and an account can be "Unlinked" there.
- **#2 and #3 differ by design.** Phase 35 has independent "Sending from" and "Node running as" selections. WalletConnect exposes #2, while processing and earnings follow #3.

## How the dashboard works today, and why that is already a two-identity setup

1. The browser connects wallet #1 and calls `/api/processing/getEstimate`, which runs on the server SDK (#6).
2. The browser signs `bridgeOut(amount, 0, destChain)` from #1. The burn has no recipient field.
3. Once there is a tx hash, without waiting for confirmation, the browser posts the same job to `/api/processing/submitJob`. The server runs `GeniusSDKProcess` as #6.
4. Nothing links the burn, the payer or the job. The endpoint has no auth and returns `null` whatever the outcome.

Consequences:

- **Free jobs.** Anyone can call `submitJob` directly and get a job processed on the server account's funds without burning anything.
- **No "my jobs".** No user identity is recorded anywhere.
- **Unknown fate of the user's burn.** It is not clear who mints the burned tokens on the SuperGenius side. The wallet's own bridge flow mints them to the node's selected SDK account.

## Scenarios

### A. Dashboard in a normal browser, connected to GeniusWallet over WalletConnect; the same GeniusWallet runs the node

- The dApp sees #2, as it was at approval time.
- The job runs as #6 (server), or as #3 once the dashboard moves to `gnus_*` methods.
- Paying and processing happen in different places, so the dashboard cannot say which node or account the job belongs to.

### B. Dashboard inside GeniusWallet's WebView, with `window.gnus`

- The bridge answers from #3 (spike: `gnus_getAddress` returns the SDK address).
- The dashboard still mounts Web3Modal (`pages/_app.tsx:57`) and opens the Connect modal on mount if not connected (`OrderForm.tsx:58-83`). The user then gets a second, competing connect flow inside the wallet.
- If the user connects over WalletConnect from inside the wallet, the wallet pairs with itself. The Windows in-app browser also auto-pairs any `wc:` link on the clipboard every 2 s.

### C. Two devices

Phone GeniusWallet over WalletConnect to a desktop browser dashboard (pays), while desktop GeniusWallet runs the node, possibly as a child of the phone's main.

- This is the realistic "earner" setup.
- The dashboard needs both: the payer on the phone, and the node account on the desktop.
- Nothing proves the two belong to the same person.
- A child's earnings stay on the child account (or its payout address). The main's view has to aggregate them through registrations.

### D. MetaMask or Coinbase user with no GeniusWallet at all

- They have no SDK account (#3), so "my node" and "earned" are empty by definition.
- They can only pay. Either the dashboard keeps a hosted node that processes for them (custodial; attribute by burn tx hash), or browser-only users cannot submit.
- This is a product decision.

## Edge cases

### Identity mismatch

1. **Payer and job owner differ.** The burn comes from EVM X, the job runs as SDK account Y, and the mint lands on whatever account is selected when the claim runs. The wallet's own bridge already guards this: the selected wallet must be the earning account's link, and not a child or watch-only (`bridge_gate.dart:76-120`). A dashboard that splits pay (Web3Modal) and submit (`window.gnus`) across providers bypasses that gate.
2. **WalletConnect account is frozen at approval.** The wallet never emits `accountsChanged`. After the user switches wallet, the dApp still shows A, but `eth_sendTransaction` signs with the currently selected wallet B (`handle_dapp_requests.dart:200`, which uses `selectedWallet`) without checking `tx.from`.
3. **WalletConnect can expose an unusable account.** If the selected wallet at approval is an `sgnus` row (128-hex) or a watch-only wallet, the session account is not a valid EVM account or cannot sign. The wallet does not check `walletCanSign` at proposal.
4. **Switch window.** While "Earn with this account" is switching (`switchingSDKAccount` non-null, polled every 3 s), the node still reports the old account. A `gnus_submitJob` or `gnus_estimate` in that window runs as the old account. The submit cubit does not check for this, and neither does the spike.
5. **Unlinked SDK account.** An account imported by key, or one whose wallet was removed, has no EVM link. The dashboard cannot show who pays for it, and the bridge gate blocks it.
6. **Stale fallback.** `nodeWalletAddress ?? connection.walletAddress` falls back to the start wallet while the earning account is null or unlinked. Any dashboard logic built on it inherits the bug.
7. **Same seed on two devices.** Both nodes run as the same SDK account. Not verified what the network does with duplicate identities. The dashboard cannot detect it and would merge both devices' work.

### Format and data

8. **Address formats.** The dashboard validates only EVM addresses (`Search.tsx:14`). The dashboard's koffi `GeniusAddress` struct is 32 chars (`structs.ts:40-44`), while the SDK address is 0x + 128 hex. Address pages, search and "my jobs" filters need both formats, or must key strictly on the SDK address.
9. **Two balances.** ERC1155 id 0 on Polygon (what `bridgeOut` spends) and SGNUS on the SuperGenius chain (what `Process` escrows). They are separate. The dashboard must say which one it shows, and in WebView mode probably both.
10. **Earnings destination.** Earnings accrue to the SDK account, or are paid to the payout address, which nothing can read back. "Earned" cannot be shown reliably until the SDK exposes a payout getter and per-account earnings history.
11. **Children.** "What my node earned" for a main means its own account plus every registered child. The child-side records are written from child nodes, so a phone-only view needs registrations from chain state or an indexer.

### Chain and network

12. **Wrong network in the wallet.** The wallet honours `eth_sendTransaction` only on its own selected network. If that is not Amoy (80002), the dashboard's `bridgeOut` fails with a generic error. The dashboard also checks the chain only on mount, and its cached signer goes stale after a switch.
13. **SDK network mismatch.** The wallet's SDK network (TestNet-Phase-3.1 on Windows here, develop on the slave) must match the dashboard's `destChainID` and contract. Nothing checks this. The spike returns a `network` field in neither path.

### Flow and lifecycle

14. **Burn succeeded, Process failed.** Funds are already burned. The wallet tracks this as `bridgedNotProcessed` with the burn hash. The dashboard shows success as soon as it has a tx hash and never learns the outcome. It needs a recoverable state keyed by burn tx hash.
15. **Retries, reloads and two tabs.** A page reload between burn and submit, or two tabs submitting, can double-burn or orphan a burn. Use the burn tx hash as an idempotency key, and let the wallet own the whole flow.
16. **Wallet not running.**
    - Browser mode over WalletConnect: requests time out when the wallet app is closed or a phone app is backgrounded.
    - WebView mode: SDK not initialized yet, so the bridge answers 4900.
    - The dashboard needs a "wallet offline" state, not a spinner.
17. **No app lock.** The wallet has no unlock or auto-lock (PIN is onboarding only), so a WebView dashboard can call the SDK while the device is unattended. Only the per-call confirm dialog protects spends.

### Security

18. **The dashboard repo has a private key in source.** `functions/ipfs/node.ts:139-140` holds a literal Ethereum private key and the repo is public. Treat it as compromised whatever it was meant for: rotate it and move it to server config.
19. **Unauthenticated processing API.** `/api/processing/*` has no auth, so it is free compute on the server account (see above).

## Recommendation

1. **The wallet owns identity; the dashboard asks.** Add one read call, returning the payer and node identities plus whether a switch is in progress:

   ```
   gnus_getAccounts -> {
     node:  { sdkAddress, linkedEvm|null, role: main|child|none, main?, payoutAddress? },
     payer: { evmAddress|null, canSign },
     switching: bool,
     network
   }
   ```

   Add events `gnus_accountsChanged`, `gnus_networkChanged` and `disconnect`. Reject calls while `switching` is true (4900 or a dedicated busy code).
2. **One provider per session.** If `window.gnus` exists, the dashboard must not mount or open Web3Modal. In a browser, use WalletConnect with GeniusWallet answering the same `gnus_*` methods over the session, rather than mixing `eth_sendTransaction` from the dApp with `gnus_*` calls.
3. **Atomic `gnus_submitJob` inside the wallet.**
   - The wallet estimates, burns, mints/claims and processes, under its existing bridge gate.
   - It returns `{ jobId, burnTxHash, sdkAccount }`.
   - The dashboard never calls `/api/processing/*` in WebView mode, and never calls `bridgeOut` itself when a GeniusWallet provider is present.
4. **Key "my jobs" on the SDK account plus burn tx hash.** Key "earnings" on the SDK account plus its children. Show the EVM payer only as a label.
5. **Wallet-side fixes these depend on** (these are wallet bugs today, regardless of the dashboard):
   - Emit `accountsChanged` on wallet switch.
   - Check `tx.from` against the session account.
   - Refuse to approve a session for watch-only or `sgnus` rows.
   - Guard Process and bridge during an account switch.
6. **SDK asks.** These add to the spike's list (CA path, cost error codes, job id from Process):
   - A payout address getter.
   - Per-account processed-job and earnings history.
   - Confirmation of who may mint a given burn, so the dashboard and wallet agree on which account a payment credits.

## Decisions needed (product)

- Can a browser user with MetaMask and no GeniusWallet submit jobs? If yes, a hosted node processes for them (custodial; attribute by burn tx hash). If no, browser-only users get read-only views.
- Does a main's dashboard aggregate its children's processing and earnings by default?
- Is one human with two devices (phone pays, desktop earns) a first-class case? If yes, the dashboard needs a "link accounts" step, with a signature from each side, since nothing in the SDK ties them together today.

## Phones (added 2026-10-26, from code reading; nothing run on a device)

- **Bridge in the wallet's WebView: works in principle.** Android and iOS use the webview_flutter path written in the spike (`_FlutterBridgeView`). The page must wait for `gnus#initialized`, because webview_flutter has no document-start hook for our shim. Flutter composites platform views on mobile, so the Linux "dialog under the page" problem should not apply. Not verified.
- **Security is weaker than desktop without native work.**
  - Android `addJavaScriptChannel` is `addJavascriptInterface`, which is reachable from every frame, including cross-origin iframes.
  - The iOS plugin injects its channel wrapper with `isForMainFrameOnly: false` (`webkit_webview_controller.dart:494-505`), so it is also reachable from every frame.
  - Neither passes origin or frame to Dart.
  - Production needs `WebViewCompat.addWebMessageListener` with allowed-origin rules on Android (minSdk 29 is fine), and `WKScriptMessage.frameInfo` (`isMainFrame`, `securityOrigin`) on iOS. Both mean plugin patches or a small custom plugin.
- **The node only runs while the app is open.**
  - Android: `MainActivity` keeps the screen on for processing. `FOREGROUND_SERVICE` is declared, but I found no foreground service.
  - iOS: has no background mode for the node.
  - So a phone earns little and intermittently. "Phone pays, desktop earns" is the realistic setup.
  - WebView mode is unaffected, since the app is open while the dashboard is.
- **Mobile browser plus GeniusWallet on the same phone, over WalletConnect.** Every request means switching apps, and the wallet answers only in the foreground; iOS cannot answer from background. In-wallet WebView is the better phone UX. The browser path suits desktop.
- **Dashboard features to check in a mobile WebView:**
  - JSON job upload via `<input type=file>` needs an Android `setOnShowFileSelector` handler (iOS has it natively).
  - Result downloads and `target=_blank` links need handlers.
  - The Android back button must go back in the page before popping the route.
  - Web3Modal must stay unmounted, or it deep-links to other wallet apps from inside our WebView.
- **Dev setup.** A phone cannot reach the PC's `localhost:3000`. Use `adb reverse tcp:3000 tcp:3000` on Android, or a LAN host added to the allowlist. iOS currently sets `NSAllowsArbitraryLoads` = true, which App Review may question. Android blocks cleartext by default except where configured.
