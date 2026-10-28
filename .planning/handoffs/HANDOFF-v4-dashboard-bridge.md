# Handoff: v4.0 processing dashboard bridge (wallet side), 2026-10-28

Branch `claude/gsd-dashboard-bridge-milestone-b6a5e7`, draft PR #294, based on develop `7b0d7a1a`.
Phases 42-47 and 44.1 are executed. Phase 48 (device walks) is unplanned and needs hardware and hosting.
All commits are authored braianwegmann@gmail.com with no Claude attribution.

## What is built

- 42: one job-submission owner (`lib/submit_job/`), SDK cost and process calls run off the UI isolate.
- 43: the `gnus_*` handler (`lib/gnus_bridge/`), Hive job record, idempotency, one-burn lock.
- 44: per-origin connect, native spend confirm, one open prompt wallet-wide plus 3 per minute per origin,
  connected sites in Settings, secret-leak test, GNUS BRIDGE section in the dev bubble. Reviewed, 2 critical fixed.
- 44.1: `bridge_out_abi.dart` picks the 5-arg or 3-arg `bridgeOut` per chain; `-32013` where neither exists.
- 45: hardened transports on five web views (top frame only, origin from the platform sender).
- 46: in-wallet dashboard screen ("Jobs and earnings" on the Earning panel), origin pin, navigation lock,
  Android Back and file picker, system-browser fallback without WebKitGTK.
- 47: dashboard over WalletConnect through the same handler, unsignable wallets refused, account and
  network events, `tx.from` check. Reviewed with 45-46: 12 of 18 findings fixed (`.planning/phases/47-*/47-REVIEW.md`).
- Linux link break fixed in `df4b9793` (`webkit_policy_error_quark` resolved at runtime).

## Numbers

Full suite 3200 passed, 10 skipped, 0 failed at the last full run, plus a few small commits after it.
Analyze, format and the brace, raw-colour and key-logging checks were exit 0 at each phase gate.

## Walks

Linux on the slave box, 2026-10-28, passed.
- In-app: connect, reject, approve, revoke, redirect lock; the estimate shows price unavailable (SDK-CA).
- Over WalletConnect from Chromium: pair, gnus connect, header, disconnect.
- Not walked: Windows (debug build only), Android (Kotlin compiled, no APK), iOS and macOS (Swift never
  compiled, Tart VM was unreachable), a live spend, the no-WebKitGTK fallback, a wallet switch over WalletConnect.

## Open items

1. Cloudflare account and domain for the hosted dashboard. Until then the pinned origin is
   `https://gnus-dashboard-staging.invalid` and the release entry stays hidden.
2. Reown dashboard project id for the dashboard's WalletConnect client (gnus-dashboard handoff has the steps).
3. SDK asks for SuperGenius, written up at https://claude.ai/artifact/MpV91q6AHVqZh2Nwuk5K3T:
   SDK-CA (cost always 0), SDK-COSTERR, SDK-JOBID, SDK-STATUS, SDK-RESULT, SDK-EARNINGS, SDK-PAYOUT.
   Until SDK-CA lands, every live estimate is `-32010` and no live spend can be walked.
4. The chainstack RPC keys for Amoy and BNB Testnet are expired (HTTP 401); publicnode stands in for now.
   Replace them in the wallet's chain config.
5. iOS and macOS commit signal (47 WR-05): WKWebView reports at provisional start, so a download or 204
   can drop a reply. Needs the Swift side, so it waits for a Mac build. Also 47 IN-01 (Apple scripts
   injected on every origin) and IN-08 (Linux `window.open`), both in the review.
6. One real Sepolia burn with the 5-argument form (44.1 criterion 5). Sepolia accepts the call read-only;
   the receipt, selector `0xa5a5aa20` and relayer credit are unrecorded. Steps are in `44.1-02-SUMMARY.md`.
7. SuperGenius cross-node mint dedup: `MintFunds` dedups on chainId+hash, and the wallet and the relayer pass
   different chain ids, so a 3-arg burn minted by both is unconfirmed (`research/v4.0-bridge-abi.md`).
   Needs an answer from SuperGenius; if the relayer starts handling 3-arg events the wallet's crediting rule changes.

## Next

Plan phase 48 once a Tart VM, the GW_Test AVD and a hosted dashboard exist. Windows can be walked now.
Do not dispatch `build.yml` to get an APK; merge, then take the develop build.
