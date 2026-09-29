---
phase: 34-account-linking
verified: 2026-09-29T00:00:00Z
status: human_needed
score: 3/4 roadmap truths verified (29/29 plan-level truths verified)
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Standing VER-02 live-testnet walk: with the SuperGenius testnet reachable, (a) import a key wallet and confirm its SDK row shows the wallet's name immediately (no 'Super Genius Wallet N'); (b) delete that wallet from the drawer and confirm the SDK row now reads '<name> (wallet removed)'; (c) re-import the same wallet and confirm the SDK row's name comes back; (d) delete an SDK account with a linked wallet and confirm the dialog names the wallet before deleting both; (e) on an install with pre-existing SDK accounts (from before this feature), confirm the ones matching a stored wallet show its name after one app start, and any that cannot be matched read 'Unlinked' rather than being hidden."
    expected: "Every step above matches its D-number/LINK requirement exactly as coded (see Goal Achievement below); no orphan 'Super Genius Wallet N' row appears at any point."
    why_human: "The live testnet is stuck in INITIALIZING_BLOCKCHAIN in this environment (per ROADMAP.md's standing precondition) and this agent must never run the app or touch the real GeniusSDK/wallet directories. This is the roadmap's own standing VER-02 criterion (success criterion 4), explicitly deferred to a live walk, not a gap in the code."
  - test: "Re-review D-15's inference-free claim (34-01 must_haves prohibition, judgment-tier, LINK-01, category transparency): 'MUST NOT record a link that was inferred; this plan records only the single new address an add produced, or the SDK's own start address.'"
    expected: "No code path assigns a link by name, order, recency or any other heuristic outside the diff-based rules the code implements."
    why_human: "Per the judgment-tier prohibition protocol this is a non-authoritative LLM-judge verdict, flagged for human confirmation rather than a hard pass. My own read of the code (genius_api.dart:311-397 for direct capture, :474-529 for backfillLinks) found only two link-producing paths: (1) a clean single-new-address diff after `_initSDK`/`_registerWallet`/backfill's re-add, and (2) `linkExistingSDKAccounts`' one-to-one elimination pair when exactly one re-add no-ops against exactly one leftover SDK address. Both are diff/elimination logic, not likelihood ranking — I found no name-matching, order-based, or recency-based assignment anywhere in the diff. Recommend confirming this reading stands."
---

# Phase 34: Account linking Verification Report

**Phase Goal:** Every SDK account is tied to and labelled with the ETH wallet it came from — no orphan "Super Genius Wallet N" rows, including for accounts that predate this feature.
**Verified:** 2026-09-29
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (ROADMAP.md Success Criteria — the contract)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | Creating or importing a key-backed wallet immediately shows its SDK account linked to that wallet's name — never a bare "Super Genius Wallet N" row. | ✓ VERIFIED | `_initSDK` (genius_api.dart:314-324) and `_registerWallet`'s diff (genius_api.dart:363-381) call `saveSDKAccountLink`; `addWalletFromSecret` (genius_api.dart:946-1020) routes the SDK form through the same path. `_mergeSgnusWallet` (app_bloc.dart:837-857) names every row via `sdkAccountName`. `grep -v '^\s*//' lib/bloc/app_bloc.dart \| grep -c "Super Genius"` = 0. Tests: `sdk_account_links_test.dart` (7 cases), `sdk_add_account_test.dart` (5 cases), `sdk_account_rows_test.dart` — all pass (ran directly, not just per SUMMARY claim). |
| 2 | Every SDK account that existed before this feature shows a linked wallet name wherever a match can be made, and an honest "Unlinked" label — never hidden — where it cannot. | ✓ VERIFIED | `GeniusApi.backfillLinks` (genius_api.dart:478-529, `@visibleForTesting` pure function) links a re-add's single new address, or a one-to-one elimination pair, and stops with no elimination on any wider ambiguity. `linkExistingSDKAccounts` (genius_api.dart:427-468) wires it after SDK start and inside `_registerWallet`. Unmatched accounts fall through `sdkAccountName` to `'Unlinked'` (app_bloc.dart:803) and stay selectable/deletable (`sdkRowActions` untouched). `sdk_link_backfill_test.dart`'s 8 cases (all 6 behaviors from the plan plus 2 wiring cases) pass. |
| 3 | The link is stored and displayed using public addresses only; no key material appears in the link's state, storage, or logs. | ✓ VERIFIED | `typedef SDKAccountLink = ({String walletAddress, String walletName})` (local_secure_storage_base.dart:18) — no key field exists in the type. Every `debugPrint` touching link/account code (genius_api.dart:308,322,379,393,466) is a static, value-free string — `git diff -U0 ... \| grep '^+' \| grep -c 'debugPrint(.*\$'` pattern used at plan time confirms this by construction. `AppState.sdkAccountLinks` (app_state.dart:93) is typed `Map<String, SDKAccountLink>`, same public-only shape. |
| 4 (standing VER-02) | This phase's linked/unlinked labels are confirmed on a live-testnet walk before closing; if testnet stays stuck in `INITIALIZING_BLOCKCHAIN`, the walk is recorded as a blocked gap, not skipped. | ⚠️ HUMAN NEEDED | Testnet is stuck in `INITIALIZING_BLOCKCHAIN` in this environment (confirmed by the orchestrator; this agent never runs the app or touches the real SDK/wallet directories per standing instruction). Recorded as a human-verification item, per ROADMAP.md's own standing-criterion wording ("recorded as a blocked gap, not skipped" — routed here as `human_needed` rather than `gaps_found`, since nothing in the code is missing or wrong; only the live walk is outstanding). |

**Score:** 3/4 roadmap truths programmatically verified; 1 routed to human verification (environment-blocked, not a code gap).

### Plan-Level Must-Haves (all 5 plans, 29 truths total)

All 29 `must_haves.truths` entries across 34-01 through 34-05 were checked against the actual code (not SUMMARY.md claims) and all are ✓ VERIFIED:

| Plan | Truths checked | Result |
|------|----------------|--------|
| 34-01 (link capture, D-15, D-20 rename, AppState) | 6/6 | ✓ VERIFIED — `saveSDKAccountLink` calls at genius_api.dart:316,373,459; `_sdkDefaultWalletKey`/`getSDKDefaultWalletKey`/`saveSDKDefaultWalletAddress`/`sdkDefaultWalletCandidates` renamed cleanly (`grep -rnE "sgnusLinkedAddressKey\|SGNUSLinked\|sgnusLinkCandidates"` = empty); `'__sgnus_linked_address__'` byte-identical (1 occurrence); addresses lowercased in `saveSDKAccountLink`/`getSDKAccountLinks`; 10 emit sites pair `defaultSDKAccount:`/`sdkAccountLinks:` (plan expected 11 — later consolidated by plan 05's `_deleteWallet` extraction, net behavior unchanged, still 1:1 paired) |
| 34-02 (SDK rows, wallet-menu badges, D-20 wording) | 7/7 | ✓ VERIFIED — `_buildAccountRow` titles via `AppBloc.sdkAccountName`, subtitle shows address + " · Active processing account"/" · Default account" (sdk_account_manager.dart:219-226); `WalletSDKBadge`/`walletSDKBadge()`/`_RowBadge` (account_drawer.dart:114-166, 3 uses); selection match is address+type (`grep -c "walletName == _selectedWallet"` = 0); `ComputeState.notDefaultAccount` / "Not the default account" wired |
| 34-03 (provable-only backfill) | 6/6 | ✓ VERIFIED — `backfillLinks` pure function behavior matches all 6 spec'd cases (test run confirms); `linkExistingSDKAccounts` wired at `_registerWallet` and `AppBloc._onInitializeSDK`; already-linked wallets excluded from `unlinked` set before any re-add call |
| 34-04 (SDK form = wallet import) | 6/6 | ✓ VERIFIED — `addWalletFromSecret` routes through `_registerWallet` (no second SDK-add path); `alreadyExists` branch returns `alreadyThere` without a second save and uses the real stored name (WR-03 fix); `_defaultWalletName` extracted and reused (D-03); no `selectGeniusAccountAsync`/`walletDetailsCubit.selectWallet` call in the add path (D-04); `_registerWallet`'s try/catch returns `false` rather than rolling back a save (D-06) |
| 34-05 (delete coupling) | 5/5 | ✓ VERIFIED — `deleteWallet`'s key-wallet branch freezes the link name via `_freezeLinkNames` before deleting, watch-only skips it; `sdkDeleteBlock` returns `defaultAccount`/`activeWallet`/`lastWallet` correctly; `_onDeleteSDKAccount` calls `removeSDKAccountLink` then `_deleteWallet` for a live linked wallet; both `wallet_information.dart` and `account_drawer.dart` dispatch `DeleteWallet` to `AppBloc` (`grep -rn "geniusApi.deleteWallet\|api.deleteWallet" lib --include=*.dart \| grep -v app_bloc.dart` = empty) |

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `packages/local_secure_storage/lib/src/local_secure_storage_base.dart` | `SDKAccountLink`, `getSDKAccountLinks`, `saveSDKAccountLink`, `removeSDKAccountLink`, `__sdk_links__` | ✓ VERIFIED | typedef at :18, key at :34, methods at :395-463, all wired and tested |
| `packages/genius_api/lib/src/genius_api.dart` | `SDKAddOutcome`, `addWalletFromSecret`, `_defaultWalletName`, `backfillLinks`, `linkExistingSDKAccounts`, `_addToSDK`, `Future<bool> _registerWallet` | ✓ VERIFIED | All present, all wired into `_initSDK`/`_registerWallet`/add-form path |
| `lib/bloc/app_bloc.dart` | `linkedWallet`, `sdkAccountName`, `sdkDeleteBlock`, `_deleteWallet`, relabelled `_mergeSgnusWallet` | ✓ VERIFIED | All present (app_bloc.dart:769-835, 690-708, 837-857) |
| `lib/bloc/app_state.dart` | `sdkAccountLinks`, `defaultSDKAccount` | ✓ VERIFIED | Fields, constructor, copyWith, props all updated |
| `lib/account/sdk_account_manager.dart` | row naming, delete confirmation naming the wallet | ✓ VERIFIED | :143-150, 429-522 |
| `lib/account/account_drawer.dart` | `WalletSDKBadge`, `walletSDKBadge`, `_RowBadge` | ✓ VERIFIED | :114-166, 655-667 |
| `lib/components/wallet_information.dart` | Delete Wallet dispatches `DeleteWallet` via AppBloc | ✓ VERIFIED | :230-266 |
| Test files (6 new/extended) | round-trip, matrix, backfill, rows, coupling, add-account coverage | ✓ VERIFIED | All exist; ran directly (51 tests across 5 files + 16 in the first pair), all pass |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `genius_api.dart _initSDK`/`_registerWallet` | `LocalWalletStorage.saveSDKAccountLink` | diff of accounts / start address | ✓ WIRED | genius_api.dart:316,373,459 |
| `app_bloc.dart _mergeSgnusWallet` | `AppBloc.sdkAccountName` | row names | ✓ WIRED | app_bloc.dart:847 |
| `sdk_account_manager.dart` drawer rows | `AppBloc.sdkAccountName` | row title | ✓ WIRED | sdk_account_manager.dart:143 |
| `account_drawer.dart` own-wallet rows | `AppState.sdkAccountLinks` | `walletSDKBadge` | ✓ WIRED | account_drawer.dart:661-665 |
| `AppBloc._onInitializeSDK` | `GeniusApi.linkExistingSDKAccounts` | after the loaded emit | ✓ WIRED | (confirmed via 34-03 test: "runs the backfill pass once after InitializeSDK" passes) |
| `AppBloc._onDeleteSDKAccount` | `AppBloc._deleteWallet` | linked wallet removal | ✓ WIRED | app_bloc.dart:960-967 |
| `wallet_information.dart` Delete Wallet | `AppBloc DeleteWallet` | `context.read<AppBloc>().add` | ✓ WIRED | wallet_information.dart:258-265 |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|----------|---------|--------|--------|
| Link capture + naming matrix | `flutter test test/account/sdk_account_links_test.dart test/account/sdk_link_backfill_test.dart` | 17/17 passed | ✓ PASS |
| SDK row naming, add-account outcomes, delete coupling, wallet-info delete | `flutter test test/account/sdk_account_rows_test.dart test/account/sdk_account_delete_coupling_test.dart test/account/sdk_add_account_test.dart test/local_wallet_storage_test.dart test/components/wallet_information_delete_test.dart` | 51/51 passed | ✓ PASS |
| Raw-colour gate (badge tokens) | `bash tool/check_raw_colors.sh` | exit 0 | ✓ PASS |
| `_RowBadge` reuse count (Rule of Three) | `grep -c "_RowBadge(" lib/account/account_drawer.dart` | 3 | ✓ PASS |
| No direct wallet-delete bypass | `grep -rn "geniusApi.deleteWallet\|api.deleteWallet" lib \| grep -v app_bloc.dart` | empty | ✓ PASS |
| Full suite (orchestrator-supplied, re-confirmed by spot file runs above) | `flutter test` | 1945 passed / 5 skipped / 0 failed | ✓ PASS (per orchestrator facts; not re-run in full here to avoid a second full-suite run per Step 7b constraints) |

### Requirements Coverage

| Requirement | Source Plan(s) | Description | Status | Evidence |
|-------------|----------------|--------------|--------|----------|
| LINK-01 | 34-01, 34-03, 34-04, 34-05 | Record which SDK address came from a key-backed wallet, public addresses only | ✓ SATISFIED | Link capture, backfill, form-as-import, and delete coupling all implement this; no key material found in any link-touching code path |
| LINK-02 | 34-01, 34-02, 34-05 | Every SDK account shows its source wallet's name; "Super Genius Wallet N" gone | ✓ SATISFIED | `sdkAccountName` used everywhere a row is named; zero "Super Genius" string occurrences remain in app_bloc.dart |
| LINK-03 | 34-02, 34-03 | Pre-existing SDK accounts linked best-effort; unlinkable ones shown, never hidden | ✓ SATISFIED | `backfillLinks` + `linkExistingSDKAccounts`; unlinked accounts render as "Unlinked" and remain selectable/deletable |

No orphaned requirements: REQUIREMENTS.md maps exactly LINK-01/02/03 to Phase 34, and all three appear across the five plans' `requirements` frontmatter. REQUIREMENTS.md's checkboxes for LINK-01..03 are still `[ ]` (unchecked) — each plan SUMMARY explicitly notes this was deferred to phase close ("requirements mark-complete skipped... orchestrator closes them at phase end"). This is a bookkeeping step for the orchestrator, not a code gap.

### Anti-Patterns Found

None. Scanned all files modified across the 5 plans (`local_secure_storage_base.dart`, `genius_api.dart`, `app_bloc.dart`, `app_state.dart`, `app_event.dart`, `sdk_account_manager.dart`, `account_drawer.dart`, `wallet_information.dart`, `compute_state.dart`, `compute_panel.dart`, `submit_job_button.dart`) for `TBD|FIXME|XXX|TODO|HACK|PLACEHOLDER` and placeholder-language patterns — zero matches. The one `ponytail:` comment present (genius_api.dart:470-472) is a deliberately-marked, documented ceiling with a named upgrade path, exactly as AGENTS.md's convention requires — not a debt marker.

Code review (34-REVIEW.md, iteration 2) found 0 critical, 0 warning, 1 info (IN-01, an accepted performance ceiling already covered by the `ponytail:` comment above) — status: clean. All iteration-1 findings (CR-01, WR-02, WR-03) were fixed and re-verified; WR-01 was explicitly and reasonably skipped with a documented rationale (34-REVIEW-FIX.md).

### Gaps Summary

No code gaps found. All three requirement IDs (LINK-01, LINK-02, LINK-03) are implemented and tested; all 4 roadmap success criteria's underlying code is either verified or (for the one standing/live-testnet criterion) explicitly deferred by the roadmap's own design to a live walk. The phase is code-complete; what remains outstanding is:

1. The standing VER-02 live-testnet walk (environment-blocked, not a defect).
2. Human confirmation of one judgment-tier prohibition (D-15/LINK-01 "no inferred links") — my own code reading supports the "resolved" claim, but per the judgment-tier routing protocol this needs a human sign-off rather than an automated pass.
3. REQUIREMENTS.md's LINK-01/02/03 checkboxes remain unchecked pending phase close (process step, not a code gap).

---

_Verified: 2026-09-29_
