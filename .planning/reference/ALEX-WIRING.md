# WIRING — the only code left to connect

The redesign is prepared so the remaining work is **wiring**, not hunting. Every integration
point is tagged in code with a greppable marker:

```bash
grep -rn "WIRE-" lib/
```

Each `WIRE-N` below maps 1:1 to that marker and gives you the **exact seam** to call, the
**prerequisites**, and whether it is mechanical wiring or a decision you must make.

Read `REVIEW_FINDINGS_REDESIGN.md` first for the safety context. This file is the task list.

**Legend** · 🔌 mechanical (drop in the real call/source) · ⚖️ decision (needs a product / locale /
per-chain choice, not just a call) · 💰 touches money — validate before shipping.

---

## Already handled in this prep pass (so you don't have to)

- ✅ **Swap no longer fabricates/persists a fake completed transaction** — it is now an honest
  `(demo)` like Send/Buy (`lib/squid_router/swap_screen.dart`). See `REVIEW_FINDINGS_REDESIGN.md` finding [21] (the swap-submit demo deviation).
- ✅ **QR address parsing fixed for EIP-681 token-transfer URIs** — `extractWalletAddress`
  (`lib/components/qr_scanner/gw_qr_scanner.dart`) now returns the `?address=` payee, not the token
  contract.
- ✅ **QR scanner shows a recovery UI** on denied/unavailable camera instead of a blank black
  screen (`errorBuilder` added).
- ✅ **Touch & legibility pass** (commits `bc8dd7a`/`254a480`, see `CHANGELOG.md`): type scale bumped
  (bodyMd 14→16, etc.); `GWButton.sm` 36→44, Assets/NFTs tabs + ToggleButtons + flip-FAB → 48;
  `GWSwitch`/`GWCheckbox` keep the 48px tap target.
- ✅ **Button contrast** — filled brand CTAs + dark `onPrimary` now use `textOnBrand` (white failed AA).
- ✅ **Amount-input guard** — `SingleDecimalSeparatorFormatter` on both amount fields blocks junk + a
  second separator (the lone-grouping-comma case is still WIRE-4 below).
- ✅ **pubspec SDK floor** bumped to `>=3.4.0` / Flutter `>=3.22.0`.

---

## The wiring list

### 🔌💰 WIRE-1 — Swap execution (Squid)
- **Where:** `lib/squid_router/swap_screen.dart` (the `Swap` button `onPressed`, ~L391) and
  `lib/squid_router/squid_token_service.dart` (`fetchTokens`/`fetchBalances`/`getRoute` return
  `mock*` — real HTTP calls are commented out).
- **Now:** demo — shows `Swap submitted (demo)`, calls no API; the quote/rate shown is mocked.
- **Do:** restore the real `SquidTokenService` calls (tokens, balances, route/quote), invoke the
  Squid execution API where the demo notice is, and **only on a real success (real tx hash)**
  build the `Transaction` + show `SwapSuccessDrawer.show(...)` + persist via
  `TransactionsCubit.addTransaction` and `TransactionStorageService().addTransaction(...)`.
  Use a **real hash** as the key (the old code used `hash:""`, which collides in Hive).

### 🔌💰 WIRE-2 — Send broadcast
- **Where:** `lib/tokens/send_screen.dart` (review-sheet `Confirm & Send` `onPressed`, ~L335).
- **Now:** demo — `Transaction submitted (demo)` toast, no broadcast.
- **Do:** call `GeniusApi.signAndSendTransaction({required Map<String,dynamic> tx, required String
  rpcUrl, required String address, required int sourceChainId})`
  (`packages/genius_api/lib/src/genius_api.dart:820`). Build `tx`/`rpcUrl`/`sourceChainId` from the
  selected `coin` + `state.selectedNetwork`, `address` from the sender wallet, recipient from
  `_recipient`. Surface success/failure from the returned `ApiResponse<String>`.
- **Prereq:** WIRE-3 (validation) and WIRE-4 (amount parsing) **before** this goes live.

### ⚖️💰 WIRE-3 — Recipient address validation
- **Where:** `lib/tokens/send_screen.dart` `valid` gate (~L73) — currently `recipient.length >= 6`.
- **Now:** no format/checksum/network check; any 6+ char string passes.
- **Do:** validate the recipient for the selected network (e.g. EVM `0x` + 40 hex + EIP-55
  checksum; BTC bech32/base58) before enabling Confirm. `extractWalletAddress` only *normalizes*
  the QR payload — it does **not** validate. Decision: which chains/formats you accept.

### ⚖️💰 WIRE-4 — Locale-aware amount parsing
- **Where:** `lib/tokens/send_screen.dart` (~L70) **and** `lib/tokens/buy_screen.dart` (~L59) —
  both `double.tryParse(text.replaceAll(',', '.'))`.
- **Now:** `SingleDecimalSeparatorFormatter` (`lib/utils/formatters.dart`) already blocks junk + a
  second separator on both fields. Residual: `replaceAll(',', '.')` still mis-reads a lone grouping
  comma — **`"1,000"` → `1.0`** (1000× under-send) — which passes the `amount > 0` check.
- **Do:** finish with locale-aware parsing (`intl` `NumberFormat`) so a single grouping comma is
  disambiguated. Decision: which locale / input rules.
  Consider a shared helper in `lib/utils/formatters.dart` used by both screens.

### 🔌💰 WIRE-5 — Buy checkout (Banxa)
- **Where:** `lib/tokens/buy_screen.dart` (`Confirm purchase` `onPressed`, ~L297).
- **Now:** demo — `Purchase submitted (demo)`, no on-ramp.
- **Do:** hand off to the **existing** Banxa flow rather than building a new one —
  `lib/banxa/banaxa_buy_screen.dart` renders a checkout WebView on `state.checkoutUrl`; the `/buy`
  route + `lib/banxa/handle_banaxa_drawer.dart` already drive it. Pass `coin`, the parsed amount,
  and `GWCurrency.code` as the fiat. Also point the **token picker** at the on-ramp's
  purchasable-token catalogue (you can buy tokens you don't yet hold), not the wallet's coins.
- **Note:** the `dev_logsubmissions` rebase **deletes/refactors several `lib/banxa/*` files** —
  reconcile that first (`REVIEW_FINDINGS_REDESIGN.md` — see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).

### 🔌 WIRE-6 — Buy live quote
- **Where:** `lib/tokens/buy_screen.dart` review row (~L290), `Quote: Shown at checkout`.
- **Do:** fetch and show the real on-ramp quote in that slot (fees + receive amount).

### ⚖️ WIRE-7 — Currency FX conversion
- **Where:** `lib/preferences/gw_currency.dart` (~L27).
- **Now:** display-only — only the **symbol** changes; values stay USD-priced.
- **Do:** add a USD→`code` rate source and convert **every** displayed USD value (home hero
  balance, asset rows, Buy amount). `GWCurrency` carries only `code`/`symbol`/`label` — add a rate
  field/source. Decision: rate provider + refresh cadence.

### 🔌 WIRE-8 — NFT data
- **Where:** `lib/dashboard/home/view/dashboard_screen.dart` `_NftsSliver._items` (~L517).
- **Now:** 6 hardcoded placeholder tiles with gradient art.
- **Do:** replace `_items` with a real NFT source (cubit/provider) and render the NFT image
  instead of the gradient placeholder.

### 🔌 WIRE-9 — Balance 24h delta
- **Where:** `lib/dashboard/home/view/dashboard_screen.dart` `_HeroBalance` (~L150).
- **Now:** `final delta = balance * 0.024;` — a flat fabricated +2.4%.
- **Do:** feed a real 24h price-change source (per-asset change, aggregated).

### 🔌 WIRE-10 — AI processing progress
- **Where:** `lib/ai/ai_processing_status.dart` (`set`, ~L24); the FAB reads it live.
- **Now:** production stays at 0% (a demo sweep runs only with `WALLET_PK`).
- **Do:** call `AiProcessingStatus.instance.set(percent)` from real SGNUS job events (submit-job
  flow / SGNUS transaction events). No marker is needed at the *producer* — wire it wherever your
  job events arrive.

### 🔌 WIRE-11 (minor) — Token-detail "Security" / "Activity"
- **Where:** the placeholder literals `"securityInfo": "Coming Soon"` /
  `"transactionHistory": ["Coming Soon"]` fed into the token-info view from
  `lib/dashboard/home/view/dashboard_screen.dart:662`, `lib/dashboard/chart/markets_screen.dart:172`,
  `lib/dashboard/chart/dashboard_markets.dart:98`.
- **Do:** replace with real security info + transaction history when available. Pure placeholder
  UI — no safety impact.

---

## Not "wiring" but required before production (see REVIEW_FINDINGS_REDESIGN.md)

These are environment/config, not code seams — they won't show up under `grep WIRE-`:

- **Camera permission** (iOS/macOS `NSCameraUsageDescription` + macOS entitlement) — the scanner
  can't open without it. `REVIEW_FINDINGS_REDESIGN.md` (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).
- **`build_runner`** — `dart run build_runner build --delete-conflicting-outputs` to generate
  `token_model.g.dart`, else `flutter analyze`/`test` stay red. (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).
- **Secrets → env** — rotate + move the hardcoded Banxa key (also the HMAC secret) and WC
  `projectId` out of source. (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).
- **`WALLET_PK`** — never ship it; it is the real signing key. (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).
- **Sentry PII / log scrubbing** before any store release. (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).
- **Rebase** onto current `dev_logsubmissions` (now +96 commits, conflicts — incl. Banxa). (see the numbered findings [1]-[37]; the old §A/§B scheme no longer exists).

## Suggested order
1. `build_runner` + rebase (unblocks analyze/test and the Banxa files WIRE-5 depends on).
2. WIRE-4 → WIRE-3 → WIRE-2 (make Send safe, then broadcast). 💰
3. WIRE-1 (Swap), WIRE-5/6 (Buy + Banxa). 💰
4. WIRE-7/8/9/10/11 (display data — no fund risk).
5. Camera permission, secrets, Sentry — before the store build.
