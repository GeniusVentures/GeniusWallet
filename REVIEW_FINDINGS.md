# Pre-Production Review — Findings & Handoff Addendum

**Read this alongside `HANDOFF.md` before merging or shipping `ui-redesign-3.514`.**

`HANDOFF.md` is an accurate and unusually thorough *integration* guide. This document is its
*safety* companion: it (a) corrects claims in `HANDOFF.md` that have gone stale or were wrong,
(b) adds the one demo flow the handoff omits, and (c) supplies the Security, Build/Test, and
integration-seam information a developer needs but the handoff does not contain.

| | |
|---|---|
| **Branch / HEAD** | `ui-redesign-3.514` @ `1b83a67` |
| **Base (merge-base)** | `0495436` on `dev_logsubmissions` |
| **Reviewed** | 2026-06-29 |
| **Method** | `flutter analyze` (pinned 3.32.5) + multi-agent code/doc audit, each finding adversarially verified against the source |
| **Analyzer result** | 11 errors (ALL pre-existing codegen in `lib/tokeninfo/` + its test) + 327 warnings; **0 new errors/warnings from the redesign** — confirms `HANDOFF.md` §7 |
| **`flutter test`** | **RED — does not compile** (see §C5) |

Severity legend: 🔴 **blocker** (ships a bug / loses funds / actively misleads) · 🟠 **high** (will cost the dev real time or break the rebase) · 🟡 **medium** · ⚪ **low / polish**

---

## 0. Do-not-ship red list (the short version)

1. ✅ ~~**Swap confirm fabricates and persists a fake "completed" transaction in production**~~ — **FIXED** in this branch (now an honest "(demo)" notice, no persistence). Real Squid wiring still pending. (§B1)
2. 🔴 **`WALLET_PK` is the *real* signing key**, not a mock — any build carrying it signs/broadcasts. (§C1)
3. 🔴 **Send has no recipient-address validation** and the QR parser mis-reads EIP-681 transfer URIs — fund-loss the moment Send is wired to a real broadcast. (§C2)
4. 🟠 **`HANDOFF.md` §8 rebase guidance is now false** — the rebase is *not* conflict-free. (§A1)
5. 🟠 **`flutter test` does not compile** and there is zero coverage of any new screen. (§C5)

---

## A. Corrections to `HANDOFF.md` (claims that are now stale or wrong)

### A1. 🟠 §8 "Rebase & PR" is no longer true
`HANDOFF.md` §8 states `dev_logsubmissions` "added **4 commits** since the fork — all config/build … **Zero UI overlap** … `git merge-tree` reports the rebase as **conflict-free**."

**Reality as of 2026-06-29:** the merge-base is still `0495436`, but `origin/dev_logsubmissions`
has moved **+96 commits** (not 4), and `git merge-tree --write-tree origin/dev_logsubmissions
ui-redesign-3.514` exits non-zero with **115 conflict lines**. Conflicts span `lib/banxa/*`,
`lib/chart/*`, `lib/account/*`, `lib/components/overlay/*`, `lib/components/coins/*` and more —
including several **`modify/delete`** conflicts where upstream *deleted* Banxa files this branch
still modifies (e.g. `lib/banxa/banaxa_buy_screen.dart`, `banxa_components/order_filter.dart`).

> This is especially important because §B/§E tell the dev to wire **Buy** into the Banxa flow —
> but the Banxa layer was refactored upstream. Reconcile the rebase **before** wiring Buy.

**Action:** re-run `git merge-tree` / a trial rebase against current `origin/dev_logsubmissions`,
resolve the Banxa + chart conflicts deliberately, and treat §8's "auto-merges" claim as void.

### A2. 🟠 §3 `splash.dart` — undocumented 2-second watchdog (behavior change)
§3 describes the `splash.dart` change as *only* "the `BlocListener`'s `context.go(...)` is now
deferred to a post-frame callback." The diff also converts `Splash` to a `StatefulWidget` and
adds, in `initState`:

```dart
Future.delayed(const Duration(seconds: 2), () {
  ... context.go('/landing_screen');
});
```

This **is** a behavior change (§3 claims "none of these change behavior in the normal async
flow"). On a slow-but-valid native cold start that takes >2 s to reach `loaded`, the watchdog can
pre-empt it and route a returning user to `/landing_screen` (onboarding) instead of `/dashboard`.

**Action:** verify the 2 s timeout cannot fire ahead of a legitimate native cold start; tune or
gate it on the real SDK timing, and document it in §3.

### A3. 🟡 §5a iOS — a dead camera key already exists in the project
§5a tells the dev to "add `NSCameraUsageDescription` to `ios/Runner/Info.plist`" (correct action),
but does not mention that `ios/Runner.xcodeproj/project.pbxproj` **already** carries three
`INFOPLIST_KEY_NSCameraUsageDescription` build-setting entries. They are **inert**: the project
uses a traditional `INFOPLIST_FILE` (there is no `GENERATE_INFOPLIST_FILE`), so the build-setting
copies never reach the runtime plist — and `ios/Runner/Info.plist` itself has **no**
`NSCameraUsageDescription`. A dev who greps the pbxproj may wrongly conclude it's handled.

**Action:** add a real `<key>NSCameraUsageDescription</key><string>…</string>` to
`ios/Runner/Info.plist`; optionally delete the misleading dead pbxproj keys.

### A4. 🟡 §1 metrics are stale
§1 says "44 commits … ~169 files, +8.6k/−3.1k." Actual `0495436..HEAD`: **69 commits**, ~184
files, ≈ +11.9k/−3.7k. The doc was written around commit #45 and its content was updated for later
work (AI-FAB, Buy, appearance, hardening) but the headline numbers were not. Add an "as-of"
commit/date, or cite the command (`git rev-list --count 0495436..HEAD`) instead of a frozen number.

---

## B. The flow `HANDOFF.md` §6 omits

### B1. 🔴→✅ Swap "Confirm" fabricates + persists a completed transaction — in production
> **STATUS: FIXED (2026-06-30).** The Swap confirm now shows an honest `Swap submitted (demo)`
> notice and navigates to the dashboard — it no longer builds a `Transaction`, shows
> `SwapSuccessDrawer`, or persists anything (matching the Send/Buy demo pattern). The dangerous
> fabrication/persistence is gone; what *remains* is the legitimate pending work: wire the real
> Squid execution + restore the success/persist path on a real tx hash, and restore the real
> `SquidTokenService` calls (the quote is still mocked). Analyzer: 0 new issues. The original
> defect is documented below for context.

`lib/squid_router/swap_screen.dart:391-491` (before the fix). The Swap button's `onPressed`:

- contains `// TODO: invoke Squid API` (`:398`) and **calls no swap/broadcast API**;
- **unconditionally** shows `SwapSuccessDrawer.show(...)` (`:436`);
- builds `Transaction(hash: "", transactionStatus: TransactionStatus.completed, type:
  TransactionType.swap, …)` (`:412-434`) and persists it:
  `transactionsCubit.addTransaction(...)` (`:485`) **and**
  `TransactionStorageService().addTransaction(walletAddress, transaction)` (`:489`).

Unlike the Send/Buy demos there is **no `(demo)` label** and **no `WALLET_PK` gate** — so in a
real production build a user taps Swap, sees a success drawer, and a "completed" swap appears
permanently in their on-device activity ledger although **nothing happened**. Because
`TransactionStorageService.addTransaction` does `box.put(tx.hash, tx)` and `hash` is `""`, every
fake swap also overwrites the same Hive entry. The flow is reachable from **every** authenticated
screen via the global Swap FAB (`HANDOFF.md` §2 presents that FAB as a finished feature).

Supporting mock (also undocumented): `lib/squid_router/squid_token_service.dart` returns
`mockTokens` (`:14`), `mockSquidBalances` (`:36`) and `mockSquidRoute` (`:60`) — the real HTTP
calls are commented out — so the **exchange rate/quote the user reviews is fabricated**
(`mockSquidRoute` hardcodes `toAmount: '995000'`, rate `'993.72'`).

**Action (release blocker):** disable/gate Swap in production until Squid is wired; do not show
`SwapSuccessDrawer` and do not persist a transaction unless a real swap returns a real hash;
restore the real `SquidTokenService` calls. Add a Swap bullet to §6 with the same prominence as
Send/Buy.

---

## C. Security, build & test (no section for these exists in either doc)

A keyword scan of `HANDOFF.md` + `DESIGN_SYSTEM.md` for security/privacy/secret/PII returns
nothing. Several items below are **pre-existing** (not caused by the redesign) — but a *production*
handoff must surface them, and §6 actively tells the dev to wire Send/Buy on top of them.

### C1. 🔴 `WALLET_PK` dart-define is the real signing key
`packages/genius_api/lib/test/dev_overrides.dart` returns the raw
`String.fromEnvironment('WALLET_PK')`, and `packages/genius_api/lib/src/genius_api.dart:829` uses
it as the literal signing key: `final privateKey = getDevPrivateKey() ?? web3.getPrivateKeyStr(wallet);`.
Any build that bakes in or passes `WALLET_PK` will **sign and broadcast with it**, overriding the
user's actual wallet. `HANDOFF.md` §6/§9 recommend `WALLET_PK` as the QA bypass without this warning.
**Action:** document it as a debug-only override; never set it in a release/CI artifact.

### C2. 🔴 No recipient validation + EIP-681 mis-parse (fund-loss once Send broadcasts)
- `lib/tokens/send_screen.dart:73` gates validity on `_recipient.text.trim().length >= 6` only —
  **no** `0x[0-9a-fA-F]{40}` / checksum / network check. A malformed or truncated address passes.
- `extractWalletAddress` (`lib/components/qr_scanner/gw_qr_scanner.dart:15-26`) strips the scheme
  then cuts at the first of `@ ? /`. For a standard EIP-681 token-transfer QR
  `ethereum:0xTOKEN/transfer?address=0xPAYEE&uint256=N` it returns **`0xTOKEN` (the contract)**,
  not `0xPAYEE` — silently the wrong recipient. It also performs no validation of the result.

**Action:** add real address validation (and EIP-681 `?address=` handling) **before** wiring the
§E1 broadcast. These are latent today only because Send is a demo.

### C3. 🟠 Sentry sends PII with no scrubbing; raw SDK logs uploaded
`lib/main.dart:83` sets `options.sendDefaultPii = true` with `tracesSampleRate = 1.0`; the
`beforeSend` (`:84-104`) performs **no** redaction (it only decides whether to attach logs). The
manual log-submission flow (`lib/logs/submit_logs_screen.dart`) uploads up to 1 MiB of raw
`sgnslog*.log` to Sentry, which may contain addresses/balances. Pre-existing.
**Action:** review for GDPR / app-store data-declaration before any store release; scrub or gate.

### C4. 🟠 Hardcoded Banxa key (= HMAC secret) + WalletConnect projectId in source
`lib/banxa/banaxa_api_services.dart:14` hardcodes `_apiKey = 'b8282030…e346'`, which is both sent
as `x-api-key` **and** used as the HMAC-SHA256 signing secret (`generateHmacSignature`, `:27-32`).
`lib/reown/reown_walletkit_instance.dart:12` hardcodes the WalletConnect `projectId`. Both are in
git history. Pre-existing. **Action:** move to `--dart-define`/secure config and rotate the Banxa
credential (treat as compromised).

### C5. 🟠 `flutter test` is red; zero coverage of new screens
`flutter test` **fails to compile**: `test/token_info_loader_test.dart` imports
`lib/tokeninfo/token_model.g.dart`, which is never generated (same root cause as the 11 analyzer
errors — see C6); `test/local_wallet_storage_test.dart` is fully commented out. There are **no**
unit/widget tests for any redesigned screen (Send, Buy, Swap, QR, address book, appearance,
preferences, FABs). **Action:** state this in the handoff; run codegen (C6) to unbreak the build;
add smoke tests for the money screens before shipping.

### C6. 🟡 Real build needs `build_runner` (and the native stack)
`HANDOFF.md` §9 honestly notes the team only stub-built. Two things the dev still needs:
1. `dart run build_runner build --delete-conflicting-outputs` to generate
   `lib/tokeninfo/token_model.g.dart` — **without it, both `flutter analyze` and `flutter test`
   stay red** (the 11 errors and the test compile failure).
2. Discard the uncommitted UI-only stub first: `git checkout -- macos/ linux/ pubspec.lock` and
   remove the untracked `"* 2"` duplicate files, then build the real `libGeniusWallet` / GeniusSDK
   / zkLLVM per `INSTALL.md`. (The stub hacks are confirmed working-tree-only — nothing harmful
   was committed.)

---

## D. Integration seams for the documented wiring (so §6 is executable cold)

`HANDOFF.md` §6 names the *mock site* but rarely the *real target*. The seams already exist:

- **D1 — Send:** replace the demo `onPressed` (`lib/tokens/send_screen.dart:~335`) with
  `GeniusApi.signAndSendTransaction({tx, rpcUrl, address, sourceChainId})`
  (`packages/genius_api/lib/src/genius_api.dart:820`). Amount/recipient/network are already in
  scope. Fix C2 first.
- **D2 — Buy:** a complete Banxa flow **already exists** — `BanxaBuyScreen`
  (`lib/banxa/banaxa_buy_screen.dart`) with `MakeOrderCubit.getQuote()/createOrder()` and a
  checkout WebView on `state.checkoutUrl`. Route the new Buy CTA into it (or reuse
  `MakeOrderCubit`) instead of building a new integration. Note the route split: `BuyScreen` (the
  new demo) is `/buy-tokens` (`router.dart:215`), `OrdersPage` is `/buy` (`router.dart:95`). See
  also the §A1 Banxa rebase conflicts.
- **D3 — Currency FX:** `GWCurrency` (`lib/preferences/gw_currency.dart`) carries only
  code/symbol/label — there is **no rate field or rates fetch anywhere**. Wiring FX means adding a
  USD→code rate source *and* converting every displayed USD value, not just the symbol.
- **D4 — NFTs / balance delta:** `_NftsSliver._items` and `_HeroBalance`'s `balance * 0.024` live
  in `lib/dashboard/home/view/dashboard_screen.dart` (≈ `:517` and `:150`) — the §6 paths omit the
  `home/view/` segment.

---

## E. Smaller quality items (worth a line in the handoff)

- ⚪ **E1 — Inter fetched from Google's CDN at runtime** (`lib/theme/genius_wallet_typography.dart:28`,
  `GoogleFonts.inter`) — no bundled fallback, no `allowRuntimeFetching = false`. For an
  offline-first, privacy-sensitive wallet, bundle the Inter `.ttf` and disable runtime fetching.
- 🟡 **E2 — `pubspec.yaml:6` `environment.sdk: ">=3.0.0"`** understates the real toolchain (the
  branch builds on Flutter 3.4x / Dart 3.9+, and `mobile_scanner 5.2.3` itself needs Dart ≥3.4).
  Bump the floor and pin the real Flutter/Dart minimums (ideally an `.fvmrc` / CI matrix).
- 🟡 **E3 — QR scanner has no permission-denied/error UI** (`lib/components/qr_scanner/gw_qr_scanner.dart:118`,
  `MobileScanner` with no `errorBuilder`) → blank black screen on denied/unavailable camera. Add an
  `errorBuilder` with a message + Settings deep-link.
- 🟡 **E4 — `GWButton` filled variants** render white text on bright brand fills in the default dark
  mode (`lib/components/buttons/gw_button.dart:104-105,143-144`), ~1.9–3.3:1 — fails WCAG AA on
  **every** money CTA. The design system already defines `textOnBrand` (#000B18) for exactly this;
  switch filled-on-bright foregrounds to it. (`textSecondary` likewise fails AA on the light
  canvas; the DESIGN_SYSTEM §8 contrast figures predate the v1.3 black/white canvases and should be
  recomputed.)

---

## F. What is solid (so the dev knows where *not* to spend time)

- Redesign code is **analyzer-clean** — 0 new errors/warnings; all 11 errors are pre-existing
  `tokeninfo` codegen.
- **Cold-start fixes (§3) are sound** — Hive boxes (`addressBook`, `preferences`) are opened before
  any read; `GlobalSwapFabHost` defers router reads past the first frame; appearance/currency load
  before `runApp`.
- **Dev bypasses are correctly compile-gated** — `WALLET_PK` / demo-QR / demo AI-sweep all key off
  `String.fromEnvironment` (empty in release) and `kDebugMode`; no mock path leaks into production
  (the Swap flow in §B1 is the **exception** — it is not a `WALLET_PK` path).
- **Native deps** (`mobile_scanner 5.2.3`, `google_fonts`, `shimmer`) satisfy the repo's
  `minSdkVersion 29` / iOS 13 targets; the texture asset is present and declared.
- The **stub hacks are uncommitted** and nothing harmful was committed (confirms §9).

---

## G. Priority checklist before merge → production

| # | Item | Sev | Ref |
|---|------|-----|-----|
| 1 | ✅ done — Swap no longer fabricates/persists a tx (now demo-honest); real Squid wiring still pending | 🔴→✅ | B1 |
| 2 | `WALLET_PK` never in a release/CI artifact; document as debug-only | 🔴 | C1 |
| 3 | Real address validation + EIP-681 parse before wiring Send broadcast | 🔴 | C2 |
| 4 | Re-do the rebase against +96-commit `dev_logsubmissions` (Banxa conflicts) | 🟠 | A1 |
| 5 | Unbreak tests (`build_runner`) + add money-screen smoke tests | 🟠 | C5, C6 |
| 6 | Sentry PII/scrubbing + rotate hardcoded Banxa/WC secrets | 🟠 | C3, C4 |
| 7 | Wire Send/Buy/Currency to the real seams (D1–D3) | 🟠 | D |
| 8 | iOS/macOS camera permission (incl. the dead pbxproj key) | 🟡 | A3 |
| 9 | splash 2 s watchdog; refresh §1/§8 metrics | 🟡 | A2, A4 |
| 10 | Fonts/SDK-floor/QR-error-UI/button-contrast polish | 🟡/⚪ | E |

*Each item above is backed by a verified file:line in this document.*
