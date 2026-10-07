---
phase: 39-banxa-integration-hardening
verified: 2026-09-30T21:00:00Z
status: human_needed
score: 14/14 requirements verified in code; 3 carry a live or external part that cannot be proven here
behavior_unverified: 0
overrides_applied: 0
gaps: []
deferred: []
external_blockers:
  - "Banxa does not list GNUS in production or sandbox (checked 2026-09-30): sandbox full buy (BUY-06 live part) and GATE A (return URL accepted by Banxa) cannot run"
human_verification:
  - test: "GATE B, sandbox buy (BUY-06): build with GW_BANXA_SANDBOX=true and a sandbox key, pay with the test card, reach complete under Buy orders with one toast"
    expected: "Order completes end to end; Done and the toast appear without the return URL"
    why_human: "Blocked on Banxa listing GNUS in sandbox; needs a sandbox key and a live createBuyOrder"
  - test: "GATE A, return URL: create one order with geniuswallet://banxa/callback"
    expected: "Order is created; return is followed or harmlessly ignored while polling reaches Done. If Banxa rejects it, switch BanxaApiService.redirectUrl to an https page on gnus.ai"
    why_human: "Needs a live createBuyOrder, which needs GNUS listed"
  - test: "Checkout on Windows, macOS, Android (GW_Test AVD) and iOS, including the ID step camera/microphone prompt, Android file upload and the leave prompt; Linux browser flow finishing via polling"
    expected: "Each platform loads checkout in-app (Linux: system browser with waiting screen), prompts are the OS ones, and Done follows the polled status"
    why_human: "Webview, OS permission prompts and file pickers cannot be driven from tests"
  - test: "Buy card, checkout header, result view and Buy orders badge in light and dark, at phone and desktop width"
    expected: "Readable, contrast correct, no overflow"
    why_human: "Visual review"
  - test: "Build without the key, and a production build while GNUS is unlisted"
    expected: "Reads \"Buying isn't set up in this build\" and \"GNUS isn't on Banxa yet\" respectively"
    why_human: "Needs real builds"
  - test: "Rotate the production Banxa key in the Banxa dashboard and set BANXA_API_KEY in the repository Actions secrets"
    expected: "Old key (still in git history and old binaries) is dead; CI builds get the new key masked"
    why_human: "Dashboard and GitHub settings actions, outside the code"
---

# Phase 39: Banxa integration hardening - Verification Report

**Phase Goal:** Buying GNUS feels like one step; Buy page rebuilt around GNUS only with the Selected wallet's address, one "you get X GNUS" figure, checkout that returns to a tracked order; key supplied at build time and never committed or logged; KYC inside Banxa's checkout; finished orders read as finished; a sandbox build can complete a whole buy.
**Verified:** 2026-09-30 at HEAD a131cc68 (worktree GW-v3, branch gsd/v3.0-banxa-hardening)
**Status:** human_needed
**Re-verification:** No, initial verification

ROADMAP.md lists no success-criteria array for phase 39, only the goal, so the 14 BUY requirements (REQUIREMENTS.md lines 202-215) plus the plan must_haves were used as the contract.

## Observable Truths

| # | Requirement | Status | Evidence |
|---|-------------|--------|----------|
| BUY-01 | Compact card, locale fiat, presets, one "You get ~X GNUS" with Rate / Banxa processing fee / Network fee, auto-refreshing quote | VERIFIED | `lib/screens/banxa_buy_screen.dart` (`_YouGet`, `_QuoteRows` lines 840-870, `_PresetChips`, `_FiatPill`); `BuyGnusCubit` 10 s refresh, 600 ms typing delay, generation guard; `defaultFiatCode(Platform.localeName)`; `hasManyMethods` gates the method row. `buy_gnus_cubit_test`, `buy_defaults_test`, `buy_card_test` pass |
| BUY-02 | Address is the Selected wallet's at tap, "To" row with Change to account switcher, no address field | VERIFIED | `_openBuy` passes `wallets.state.selectedWallet` to `createOrder` at tap (line 1139); `_ToRow` uses `AccountDrawer.show`; quote call sends no address; no address state in `BuyGnusState` |
| BUY-03 | Watch-only disabled with reason | VERIFIED | `BuyGnusState.blockedReason`, `ctaFor` returns disabled, `createOrder` returns early for `WalletType.tracking`; card test covers it |
| BUY-04 | GNUS only; unlisted / no key shows "not available" | VERIFIED | Cubit picks `GNUS` only, emits `notListed` / `notConfigured` without a quote call; screen copy "GNUS isn't on Banxa yet" / "Buying isn't set up in this build". Live builds pending human |
| BUY-05 | Key via `--dart-define`, header only, never logged | VERIFIED | `banxa_env.dart` `String.fromEnvironment`; `x-api-key` set in one place (`banxa_api_services.dart:49`); old key value searched in `git grep HEAD`: zero hits; no `print`/`debugPrint` in `lib/banxa` or the Buy screen; `BanxaRequestException` carries status only; no Sentry calls in `lib/banxa`; `no_banxa_secret_test` and `check_no_new_key_logging.sh --scan-tree` (exit 0); `build.yml` passes `secrets.BANXA_API_KEY` on all 5 build lines with the base64 form masked. Rotation and secret setup pending human |
| BUY-06 | Sandbox switch, sandbox marker on Buy and checkout, sandbox build completes a whole buy | PARTIAL | Switch and markers verified (`kBanxaSandbox`, `banxaApiBase`, "Sandbox . no real money" on card line 249 and checkout header line 377, tests). The "completes a whole buy" part is blocked on Banxa not listing GNUS in sandbox (GATE B) |
| BUY-07 | Full-screen checkout, Order > Pay > Done, menu with Pay on another device and Open in browser; webview on Android/iOS/macOS, WebView2 on Windows, browser on Linux; KYC inside checkout | VERIFIED in code | `checkout_screen.dart` (`checkoutHostKind`, `CheckoutProgress`, `CheckoutQrBody`, `_openInBrowserNow`), `checkout_webview.dart`, `checkout_webview_windows.dart` (registered with `WindowsWebViewShutdown`); KYC screen, route and `user_kyc/` deleted; camera/microphone declared in AndroidManifest, iOS and macOS plists, macOS entitlements; no locked version moved. Platform walks pending human |
| BUY-08 | Done from polled status; return URL only speeds it up; https Banxa URLs only | VERIFIED in code | `checkout_screen.dart:218` Done on `isPaid`/`isFinal`; `_onReturn` only calls `refreshOrder`; `isBanxaReturn` matches scheme/host/path in main frame; `isTrustedCheckoutUrl` requires https, plain-DNS host, dot-bounded Banxa suffix, and the screen refuses to load an untrusted URL. Whether Banxa accepts the custom-scheme return URL is GATE A, blocked |
| BUY-09 | One status model, 11 statuses plus `coinTransferred`/unknown, tones | VERIFIED | `banxa_order_status.dart`: `complete` only success, `paymentReceived` not final, declined error, expired/cancelled/refunded/unknown neutral; no `'completed'` literal left in `lib`; table test passes |
| BUY-10 | One app-level poller, refetch on wallet switch, late response dropped, non-final only, stops, pauses in background | VERIFIED | `OrdersCubit` (main.dart provider, wallet subscription, `_fetchGeneration`, `_openIds`, `_syncTimer`, `setForeground` wired by `BuyOrderToasts` lifecycle listener). Behavioral tests in `orders_poller_test` (12) and `orders_wallet_scope_test` (6) exercise these and pass in the full run. Expired orders stay polled 60 min by design |
| BUY-11 | Orders in Transactions behind Buy orders chip with open count, `?filter=purchase`, drawer with copyable id, next action, support link | VERIFIED | `transactions_slim_view.dart` (`purchase('Buy orders')`, count badge), router redirect `/banxa/callback` to `/transactions?filter=purchase`, `OrderDrawerFooter` (Complete payment, Continue verification, Try again, Contact Banxa support, trusted URL only); `buy_orders_filter_test`, `order_drawer_footer_test` pass |
| BUY-12 | One toast with View order on final status | VERIFIED | `BuyOrderToasts` mounted in `main.dart`, listens to `justFinished`, `showOrderDetails` on View order; skipped only while checkout itself is on screen; `buy_order_toasts_test` passes |
| BUY-13 | Buy GNUS from Home, Assets, GNUS page, Transactions; Buy page links to Buy orders | VERIFIED | `/buy` pushed with origin HOME (`wallet_information.dart`, `coins_screen.dart`), ASSETS, GNUS (`token_info_screen.dart`), TRANSACTIONS (`transactions_screen.dart`); Buy page header `context.go('/transactions?filter=purchase')`; `buy_entry_points_test` incl. 360 px overflow passes |
| BUY-14 | Dead Banxa code removed, tests rewritten | VERIFIED | Ten named files/dirs confirmed absent; grep for `submitKYC`, `generateHmacSignature`, HMAC, `yourapp://`, `banxa-callback`, sandbox-KYC host finds nothing in `lib` (one historical comment in `dev_banxa_fixtures.dart`); no prints; one `BanxaApiService()` construction, in `main.dart` |

**Score:** 14/14 requirements implemented and test-backed; BUY-06 live buy, BUY-07 platform behaviour and BUY-08 return-URL acceptance are open only for external or human reasons.

## Requirements Coverage

All 14 IDs (BUY-01 to BUY-14) are claimed by at least one plan's `requirements:` frontmatter (01: 10,11; 02: 08,14; 03: 05,06,14; 04: 09-12; 05: 09,11; 06: 01-04,06; 07: 06-08; 08: 01-04,06,13; 09: 07; 10: 07; 11: 11; 12: 14; 13: 13,05,06,08). No orphaned requirement. REQUIREMENTS.md still shows all 14 as `[ ]` / Pending; that needs updating at phase close, and BUY-06 should stay open until GATE B.

## Behavioral Spot-Checks (run by verifier)

| Check | Result |
|-------|--------|
| `flutter analyze` | exit 0, no issues |
| `flutter test` (full, once) | exit 0, 2360 passed, 6 skipped |
| `tool/check_brace_style.sh`, `check_raw_colors.sh` | exit 0 |
| `tool/check_no_new_key_logging.sh --scan-tree` over sdk_account_manager and all `lib/banxa` files | exit 0 |
| `tool/verify_additive_boundary.sh` | exit 1, pre-existing and identical on develop, non-blocking in CI |
| Old key literal in HEAD tree (`git grep`) | none |
| Claude/Co-Authored-By trailers in 59 phase commits | 0 |
| TBD / FIXME / XXX / TODO / HACK in phase files | none |

## Anti-Patterns / Notes

| Item | Severity | Note |
|------|----------|------|
| `subPartnerId: 'macOS-app'` sent on every platform (`buy_gnus_cubit.dart`) | Info | Cosmetic attribution label, now wrong on Windows/Android/iOS |
| WR-01 gate: Buy orders stay empty until the first-buy disclaimer is accepted | Info | Deliberate privacy trade-off, documented in 39-REVIEW-FIX.md |
| Key stays in the shipped binary and old key remains in git history | Warning | Accepted by D-01; rotation is a human task (listed above) |
| Sandbox "159 coins, GNUS absent" claim | Info | Recorded in 39-VALIDATION.md; not re-checked here (no Banxa API calls allowed) |

## Gaps Summary

No code gaps. The phase goal is met at code level, but it cannot be observed end to end today: in production and sandbox the Buy card will correctly show "GNUS isn't on Banxa yet" until Banxa lists GNUS. Status is human_needed for the items in the frontmatter: the two Banxa-dependent gates (A and B), the platform and visual walks, and key rotation plus the CI secret. Re-query `/v2/crypto/buy` for partner `gnus` once Banxa lists GNUS, then run GATE A and GATE B before calling BUY-06 and BUY-08 closed.

---

_Verified: 2026-09-30_
_Verifier: Claude (gsd-verifier)_
