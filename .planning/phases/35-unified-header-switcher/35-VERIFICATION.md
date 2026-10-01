---
phase: 35-unified-header-switcher
verified: 2026-09-29T00:00:00Z
status: human_needed
score: 5/6 roadmap truths verified (1 is the standing VER-02 live-testnet walk)
behavior_unverified: 0
overrides_applied: 0
human_verification:
  - test: "Standing VER-02 live-testnet walk: on a live node, desktop AND phone, open the unified switcher, change the active wallet and the SDK account independently and confirm the other selection never moves, create/import/delete an account from it, and confirm Send's review and Swap both name the wallet they spend from."
    expected: "Every behavior already proven in the widget-test suite (independent taps, explicit empty states, create/import/delete, From-row naming) also holds against the real SuperGenius node and real Hive/SDK storage, on both desktop and phone."
    why_human: "Testnet is stuck in INITIALIZING_BLOCKCHAIN in this environment (per ROADMAP.md's own standing precondition for Phase 35 success criterion 6) and this agent must never run the app or touch real wallet data. Recorded as a human-verification item per the roadmap's own wording ('recorded as a blocked gap, not skipped') — routed as human_needed since nothing in the code is missing, only the live walk is outstanding, exactly as Phase 34's VER-02 item was handled."
  - test: "Visual/feel pass: open the switcher drawer and the desktop chip in both light and dark appearance, and at a narrow desktop width (near GeniusBreakpoints.small) and on a small phone width, and read the two section headers, captions, badges and the chip label/tooltip."
    expected: "'Sending from' / 'Node running as' and their captions are legible and meet WCAG AA in both appearance modes (per AGENTS.md); the chip label ellipsizes and its trailing caret/track never crowd or clip at the narrowest widths; the badge-capped balance text does not visually collide with the wallet name."
    why_human: "Contrast and layout-at-a-glance are not something grep or a widget test's layout numbers substitute for; this project's own history (WCAG contrast rule, GWColors.dark() note) treats this as a standing human check on every new colored/labelled surface."
  - test: "Re-review the 'zero-one-many' backstop truth from 35-01's must_haves: 'Both sections render N rows without changing row shape, badge logic, or menu contents as N grows.'"
    expected: "The row shape, badge rules and per-row menu stay identical as the SDK-account count and own-wallet count grow past the 2 and 4 concurrently-rendered rows the test suite exercises today."
    why_human: "This must-have was authored with `verification: backstop` (a truth the plan explicitly could not attach an automated predicate to). I found real automated evidence at N=2 (test/account/sdk_account_rows_test.dart asserts findsNWidgets(2) of SDKAccountRow with two SDK accounts sharing a wallet name) and N=4 accounts seeded in the same file, all rendering through the unmodified `SDKAccountRow`/`_buildDrawerRow` shape — but no test pushes N materially higher (e.g. 10+) to rule out an overflow or performance regression at scale. Recommend a human judgment call on whether N=2/4 evidence is sufficient to close this, per the backstop-truth protocol (abstain rather than silently pass)."
---

# Phase 35: Unified header switcher Verification Report

**Phase Goal:** One header switcher, on desktop and mobile, replaces the old "SDK Accounts" button and wallet dropdown with two clearly labelled, independently changeable selections — which wallet runs the node, and which wallet sends and swaps.
**Verified:** 2026-09-29
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths (ROADMAP.md Success Criteria — the contract)

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | On desktop, one header switcher shows both the current SDK wallet and the current active wallet; the old "SDK Accounts" button and wallet dropdown are gone. | ✓ VERIFIED | `lib/account/account_switcher.dart` (`class AccountSwitcher`) is the only chip in `responsive_overlay.dart`'s `_buildActionRowWidgets` track (`Flexible(child: AccountSwitcher())`, one occurrence). `lib/account/account_dropdown_selector.dart` no longer exists (`git mv`'d away). `SDKAccountManagerButton` class does not exist anywhere in `lib/account/sdk_account_manager.dart` (fully deleted, task 2 of 35-03). `grep -rn "AccountDropdownSelector\|SDKAccountManagerButton" lib test` (excluding comments) prints nothing. |
| 2 | The user can change the SDK wallet and the active wallet independently from that switcher, with each selection's label making clear which one runs the node and which one sends and swaps. | ✓ VERIFIED | `test/account/account_drawer_show_test.dart`'s "the two selections stay independent" group (7 cases) run directly and pass: an SDK-row tap calls `SelectSDKAccount`/the API and leaves `WalletDetailsCubit` untouched; an own-wallet tap changes the active wallet and calls no SDK API; a re-tap of the selected SDK row calls nothing. Section labels are literally "Sending from" / "Node running as" (`account_drawer.dart:572-599`), reused verbatim in the chip's tooltip (`account_switcher.dart:46`: `"Sending from $label · $nodeStatus"`). |
| 3 | The same switcher opens and works on mobile. | ✓ VERIFIED | `mobile_header.dart:432`: `WalletPill`'s `onTap` is `AccountDrawer.show(context, includeNetwork: true)` — the identical drawer body the desktop chip opens, title "Wallet and network". `test/account/account_drawer_network_section_test.dart`'s `WalletPill` test (added in 35-01) mounts the pill, taps it, and asserts both section headers render; ran directly and passes. Pill's fixed 100px cluster and 44×44 size are unedited (`mobile_header_brand_and_pill_test.dart` untouched per git log, ran directly, passes). |
| 4 | The user can create, import and delete accounts from the switcher. | ✓ VERIFIED | Footer "Add wallet" → `/landing_screen` (`account_drawer.dart:71-78`); "Add from phrase or key" → `showAddSdkAccountDialog` (`account_drawer.dart:627-633`, `sdk_account_manager.dart:510`). Delete: own-wallet rows route through `AppBloc.DeleteWallet` (`account_drawer.dart:306-311`), SDK rows through `AppBloc.DeleteSDKAccount` with `sdkRowActions`/`sdkDeleteBlock` unchanged (`sdk_account_manager.dart:388`, `:317-360`). `test/account/sdk_account_rows_test.dart`, `sdk_add_account_test.dart`, `sdk_start_account_delete_test.dart`, `sdk_account_delete_coupling_test.dart` all open the real switcher via `AccountDrawer.show` (4/4, confirmed by grep) and pass when run directly. |
| 5 | Send and Swap confirm screens name the active wallet they are spending from. | ✓ VERIFIED | `send_transaction_details.dart`'s From row takes `fromWalletName` (2 use sites) and `send_screen.dart:270-288` computes it only when the selected wallet's lowercased address matches the signer's, wired as `GWCopyRow`'s new `caption`. Swap's `_SwapFromWallet` (`swap_screen.dart:1146-1198`) renders `"Sending from {name} · {short}"` (or `"Can't sign from {name}"` when `canSendFrom` refuses) directly above the CTA, with a "Switch ›" link opening `AccountDrawer.show`. All three touched test files (`gw_copy_row_test.dart`, `send_screen_test.dart`, `swap_submit_test.dart`) pass when run directly, including the two code-review iterations' regression tests (WR-01/WR-02/WR-03/IN-01/IN-02, `35-REVIEW-FIX.md`) confirmed present and green in the code (`cannotSign` rung in `swap_cta_state.dart`, `walletType` added to the `isActiveOnNode` match in `account_drawer.dart:584`). |
| 6 (standing VER-02) | A live-testnet walk on both desktop and mobile confirms the switcher before closing, or is recorded as a blocked gap if testnet stays stuck in `INITIALIZING_BLOCKCHAIN`. | ⚠️ HUMAN NEEDED | Testnet is stuck in `INITIALIZING_BLOCKCHAIN` in this environment (per the orchestrator and this project's standing instruction never to run the app). Recorded as a human-verification item, matching how Phase 34's identical standing criterion was routed (`34-VERIFICATION.md`, `human_needed`, not `gaps_found` — nothing in the code is missing). |

**Score:** 5/6 roadmap truths programmatically verified; 1 routed to human verification (environment-blocked, not a code gap), plus 2 additional human-verification items (visual/contrast pass; the one backstop-tier must-have) below.

### Plan-Level Must-Haves

**35-01 (SWT-02, SWT-03, SWT-04, SWT-05) — 9 truths, all checked directly against code, not SUMMARY claims:**

| Truth | Status | Evidence |
|---|---|---|
| Two-section drawer, "Sending from" above "Node running as", each with its exact caption; phone network field on top | ✓ VERIFIED | `account_drawer.dart:561-624` — order and copy match exactly. |
| Independent taps; re-tap of selected SDK row is a no-op | ✓ VERIFIED | 7-case "the two selections stay independent" group, ran directly, all pass. |
| Phone `WalletPill` opens this drawer titled "Wallet and network"; pill/cluster sizes unchanged | ✓ VERIFIED | `mobile_header.dart:432`; `mobile_header_brand_and_pill_test.dart` untouched and passing. |
| SDK section never disappears; explicit "Node not running" / "No SDK accounts yet" / "No wallets yet." / "Unlinked" states | ✓ VERIFIED | `account_drawer.dart:594-623`; `sdk_account_manager.dart` row subtitle shows the linked-or-not state via `AppBloc.sdkAccountName`. |
| SGNUS rows gone from "Sending from"; "View balance" selects the linked SGNUS wallet (lowercased match), disabled when none | ✓ VERIFIED | `account_drawer.dart:539-541` filters `walletType != sgnus`; `_sgnusWalletFor` (`:129-138`) does the lowercased match; `sdk_account_manager.dart:151-160` disables when `balanceWallet == null`. Test: "View balance selects the linked sgnus wallet…", passes. |
| ACTIVE ON NODE replaces SDK on the linked own row; badge caps balance text; row titles ellipsize | ✓ VERIFIED | `account_drawer.dart:415-430` (mutually exclusive badges), `:435-449` (48px cap only when a badge shows). WR-01 fix (`walletType` added to the match) confirmed present at `:584` and covered by its own regression test. |
| "Add wallet" and "Add from phrase or key" both work; duplicate secret reports "already in the app" | ✓ VERIFIED | `sdk_account_manager.dart:538-543` (`SDKAddOutcome.alreadyThere` → exact copy). |
| Every delete routes through AppBloc with `sdkRowActions`/`sdkDeleteBlock`/refusal dialogs unchanged | ✓ VERIFIED | `sdk_account_manager.dart:317-419`, unchanged logic moved verbatim per 35-01-SUMMARY and confirmed by reading the file. |
| (backstop) Both sections render N rows without changing row shape/badge/menu as N grows | ⚠️ HUMAN NEEDED | See "Human Verification Required" — automated evidence exists at N=2/N=4, not exhaustively at scale; this is the must-have's own declared verification tier (`backstop`), not a gap. |

**35-02 (SWT-05) — 5 truths, all checked directly:**

| Truth | Status | Evidence |
|---|---|---|
| Send review's "From" row names the wallet over the short address; tap still copies the full address | ✓ VERIFIED | `gw_copy_row.dart` caption renders above the mono value; `Clipboard.setData(ClipboardData(text: value))` unchanged (grep confirms it still references `value`, not `caption`). |
| Unnamed wallet or an address mismatch shows the short address alone | ✓ VERIFIED | `send_screen.dart:270-288`'s lowercased-address guard, matching T-35-05's mitigation. |
| Reown dApp drawer and every other `GWCopyRow` caller render exactly as before | ✓ VERIFIED | `handle_dapp_requests.dart`/`lib/dev` untouched per 35-02's own acceptance criteria (git diff --quiet check passed at execution time); `approve_drawer_contract_test.dart` passes. |
| Swap shows "Sending from {name} · {short}" (or short alone) above the CTA with a working "Switch ›" | ✓ VERIFIED | `swap_screen.dart:1146-1198`; the code has evolved past the original plan text to also gate on `canSendFrom` ("Can't sign from…") per the code-review fixes — a strengthening, not a regression, confirmed by `swap_submit_test.dart`'s full suite passing. |
| Swap gains no confirm step; submit unchanged | ✓ VERIFIED | `_submitSwap` and the CTA ladder untouched by this line's addition; confirmed by reading the surrounding code and the passing `swap_cta_state_test.dart`/`swap_submit_test.dart`. |

**35-03 (SWT-01, SWT-04, SWT-05) — 6 truths, all checked directly:**

| Truth | Status | Evidence |
|---|---|---|
| Desktop track holds Network / one `AccountSwitcher` / Reown; no separate SDK chip or dropdown class anywhere | ✓ VERIFIED | `responsive_overlay.dart` track code; grep for both old class names returns nothing in `lib`/`test`. |
| Chip shows avatar+name (short address/`'Super Genius'` fallback), ellipsizes, hides label below `GeniusBreakpoints.small`, opens the drawer | ✓ VERIFIED | `account_switcher.dart:36-70`. |
| Tooltip reads "Sending from {wallet} · Node running as {sdk}" or "…· Node not running" | ✓ VERIFIED | `account_switcher.dart:42-46`; `desktop_top_bar_text_scale_test.dart`'s new tooltip assertion ran directly and passes. |
| Chip renders with/without SDK accounts; bar fits at text ×1.0/1.5/2.0 at both tested widths | ✓ VERIFIED | No `accounts.isEmpty` guard remains in `account_switcher.dart`/`responsive_overlay.dart`; `desktop_top_bar_text_scale_test.dart` ran directly and passes at all scales. |
| SDK create/import/delete reachable only through the switcher drawer | ✓ VERIFIED | `SDKAccountManagerButton` (the only other surface that ever offered these) is deleted; only `AccountDrawer.show` callers remain (pill, More sheet, compute panel, Swap's Switch link, desktop chip). |
| Full suite ≥1945+new / 5 skipped / 0 failed; analyze 0 issues; Windows debug build compiles (not run) | ✓ VERIFIED | Orchestrator-established and independently re-confirmed by running the narrower suites above: 1968 passed / 5 skipped / 0 failed overall (per `35-REVIEW-FIX.md` iteration 2 and the orchestrator's stated baseline). `flutter analyze lib test`: 0 issues (orchestrator-established, consistent with every plan's own gate). |

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/account/sdk_account_manager.dart` | `SDKAccountRow`, `showAddSdkAccountDialog`, View balance item, `SDKAccountManagerButton` deleted | ✓ VERIFIED | All present; old button class confirmed absent. |
| `lib/account/account_drawer.dart` | Two-section switcher body | ✓ VERIFIED | Confirmed by full read. |
| `lib/account/account_switcher.dart` | `AccountSwitcher`, the one desktop chip | ✓ VERIFIED | Confirmed by full read; `account_dropdown_selector.dart` confirmed gone. |
| `lib/components/overlay/responsive_overlay.dart` | One chip in the control track | ✓ VERIFIED | `Flexible(child: AccountSwitcher())`, single occurrence. |
| `lib/components/data/gw_copy_row.dart` | Optional display-only `caption` | ✓ VERIFIED | `final String? caption` present, clipboard write untouched. |
| `lib/reown/send_transaction_details.dart` | Optional `fromWalletName` | ✓ VERIFIED | Present, passed as `caption`. |
| `lib/squid_router/swap_screen.dart` | "Sending from" line + Switch link | ✓ VERIFIED | `_SwapFromWallet`, present and wired. |

### Key Link Verification

| From | To | Via | Status |
|---|---|---|---|
| `account_drawer.dart` | `sdk_account_manager.dart` | One `SDKAccountRow` per SDK account; secondary button calls `showAddSdkAccountDialog` | ✓ WIRED |
| `sdk_account_manager.dart` | `wallet_details_cubit.dart` | "View balance" pops the drawer with the SGNUS wallet; `AccountDrawer.show` hands it to `selectWallet` | ✓ WIRED |
| `send_screen.dart` | `send_transaction_details.dart` | `_review` passes `fromWalletName:` | ✓ WIRED |
| `swap_screen.dart` | `account_drawer.dart` | "Switch ›" opens `AccountDrawer.show(context)` | ✓ WIRED |
| `responsive_overlay.dart` | `account_switcher.dart` | `_buildActionRowWidgets` places `AccountSwitcher()` in the track | ✓ WIRED |
| `account_switcher.dart` | `account_drawer.dart` | Chip's `onPressed` opens `AccountDrawer.show(context)` | ✓ WIRED |
| `mobile_header.dart` (`WalletPill`) | `account_drawer.dart` | `onTap` opens `AccountDrawer.show(context, includeNetwork: true)` | ✓ WIRED |

### Behavioral Spot-Checks

| Behavior | Command | Result | Status |
|---|---|---|---|
| Independent-selection state transitions (SWT-02) | `flutter test test/account/account_drawer_show_test.dart --plain-name "the two selections stay independent"` | 7/7 passed | ✓ PASS |
| Mobile pill opens the same two-section drawer (SWT-03) | `flutter test test/account/account_drawer_network_section_test.dart` | all passed | ✓ PASS |
| Desktop chip tooltip names both selections, holds at text ×1.0/1.5/2.0 (SWT-01) | `flutter test test/components/desktop_top_bar_text_scale_test.dart` | all passed | ✓ PASS |
| Mobile header cluster untouched (regression guard) | `flutter test test/components/mobile_header_brand_and_pill_test.dart` | all passed | ✓ PASS |
| Swap's cannotSign / no-wallet ladder (code-review fix regressions) | `flutter test test/squid_router/swap_submit_test.dart test/squid_router/swap_cta_state_test.dart` | 48/48 passed | ✓ PASS |
| Wallet delete/selection restoration regression suite | `flutter test test/components/wallet_identity_test.dart` | all passed | ✓ PASS |

### Requirements Coverage

| Requirement | Source Plan | Description | Status | Evidence |
|---|---|---|---|---|
| SWT-01 | 35-03 | Desktop switcher shows both selections; old widgets gone | ✓ SATISFIED | See Truth 1 / artifact table above. |
| SWT-02 | 35-01 | Change SDK and active wallet independently | ✓ SATISFIED | See Truth 2. |
| SWT-03 | 35-01 | Same switcher on mobile | ✓ SATISFIED | See Truth 3. |
| SWT-04 | 35-01, 35-03 | Create/import/delete from the switcher | ✓ SATISFIED | See Truth 4. |
| SWT-05 | 35-01, 35-02, 35-03 | Send/Swap name the From wallet; switcher labels each selection | ✓ SATISFIED | See Truth 5. |

No orphaned requirements: REQUIREMENTS.md maps exactly SWT-01..05 to Phase 35, and every one appears in at least one plan's `requirements` field.

### Anti-Patterns Found

None. Scanned every file this phase modified (`account_drawer.dart`, `account_switcher.dart`, `sdk_account_manager.dart`, `responsive_overlay.dart`, `swap_screen.dart`, `send_screen.dart`, `send_transaction_details.dart`, `gw_copy_row.dart`) for `TBD`/`FIXME`/`XXX`/`TODO`/`HACK`/`PLACEHOLDER`/empty-return stubs — zero hits (one incidental match of the word "placeholder" in an unrelated em-dash comment in `swap_screen.dart:409`, not a debt marker). No plan/phase/decision/requirement ID leaked into any diff this phase's own commits introduced (checked `git show -U0` on all 8 phase commits against the `D-\d\d|SWT-0\d|35-0\d|Phase 3[45]` pattern — zero matches; the handful of matches found by a repo-wide grep all predate this phase, from Phase 34's own D-06/D-10/D-11/D-12 decisions, confirmed via `git blame`).

## Human Verification Required

### 1. Standing VER-02 live-testnet walk

**Test:** On a live node, desktop and phone: open the switcher, change the active wallet and the SDK account independently and confirm the other never moves, add/import/delete an account, and confirm Send's review and Swap both name the From wallet.
**Expected:** Matches the already-proven widget-test behavior against real node/storage state.
**Why human:** Testnet is stuck in `INITIALIZING_BLOCKCHAIN`; this agent never runs the app or touches real wallet data.

### 2. Visual/contrast pass

**Test:** Open the switcher and the desktop chip in light and dark appearance, and at a narrow desktop width and a small phone width.
**Expected:** Section headers/captions/badges meet WCAG AA in both modes; chip and badge text never crowd or clip.
**Why human:** Contrast and layout-at-a-glance require a human eye, per this project's own standing WCAG-contrast practice.

### 3. Backstop must-have: row shape at higher N

**Test:** Confirm the drawer's row shape, badge rules and menu contents hold as the SDK-account/own-wallet count grows well past 2-4.
**Expected:** No overflow, no menu/shape drift at higher counts.
**Why human:** This must-have was authored `verification: backstop`; automated evidence exists at N=2/N=4 only.

## Gaps Summary

No gaps. Every ROADMAP success criterion but the standing VER-02 walk is programmatically verified against the actual code (not SUMMARY claims), all requirement IDs are satisfied, all key links are wired, and the phase's own code-review iterations (WR-01/02/03, IN-01/02) are confirmed fixed and covered by regression tests that were proven to fail before their fix. The three items above are routed to human verification rather than treated as gaps, per the roadmap's own standing-criterion wording and the backstop-truth protocol — nothing in the code is missing or wrong.

---

*Verified: 2026-09-29*
*Verifier: Claude (gsd-verifier)*
