---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
verified: 2026-07-30T00:00:00Z
walk_performed: 2026-07-30
status: passed
closed_by: developer-walk
score: 4/6 verified automatically; the two visual truths closed by the developer walk 2026-07-30
behavior_unverified: 2
overrides_applied: 0
resolution_2026_07_30:
  summary: >
    The consolidated 37-item walk — the one this phase was blocked on — was performed by the
    developer on 2026-07-30 against a Windows build of `d3a65ea`, and every item reached passed.
    Both visual truths below are closed by it. The walk was assembled by 21-06 from all six plans'
    OUTSTANDING sections, de-duplicated and organised by screen, so it ran as a single pass rather
    than six.
  what_the_walk_closed: >
    The family claims that no grep or widget test can make: that the six receipts read as one family
    (same icon size, same gap above the pill, same pill geometry), that the five list pickers read as
    one family (rounded gradient tint + gradient check, never a square fill or accent bar), and that
    the two confirms and three Receive drawers match their decided sketches. Also the phase's core
    promise, checked across every drawer in one sitting: the body's left edge lines up with the
    title's left edge — in both appearance modes and below the 768 bottom-sheet breakpoint.
  correctness_items_confirmed: >
    Three full-value clipboard checks were called out to the walker specifically because a
    presentation change is exactly where a truncated copy hides: the receive address (42 chars), the
    signing drawer's To row, and the swap-result hash (66 chars). All reported correct. The QR was
    also checked as scanning in both appearance modes — the white backing is allowlisted by name in
    the raw-colour gate precisely so this keeps working.
  honest_limit: >
    The walker did not enumerate which of the 37 items were reached, so this records "every item
    reached passed", not "all 37 exercised". Several surfaces are dev-bubble-only (both signing
    prompts, both Banxa results) and the QR scan needs a phone camera. Do not later read this closure
    as itemised 37/37 coverage.
  still_open_not_closed_by_this_walk: >
    (1) Item 22's design question — whether `Reject`/`Deny` reads as equally affirmative as
    `Approve`/`Allow` on the two signing prompts — was flagged open in `drawers-final/README.md` and
    is NOT recorded as resolved here; the walker reported no failure, which is not the same as
    answering the question. (2) The product decision on the two orphaned Banxa result drawers, which
    are re-skinned but have no production caller (only `dev_tools_bubble.dart`) and whose sketch
    066-B draws rows no caller supplies. (3) `handle_banxa_drawer.dart`'s `showCheckoutOptionsSheet`
    remains a raw `showModalBottomSheet` by architectural decision, filed as its own todo.
behavior_unverified_items:
  - truth: "Six receipts read as one family; five list pickers read as one family; two confirms and three Receive drawers match their decided sketches"
    test: "Open each converted drawer (dev bubble Buy OK/Buy fail/swap result, a real transaction receipt, the token/network/account/bridge pickers, both signing drawers, all three Receive drawers) in dark and light mode"
    expected: "Same icon size, same gap above the pill, same pill geometry across all receipts; rounded gradient-tint + gradient check (never square fill / accent bar) across all pickers; the two confirms and three Receive drawers match drawers-final's sketches"
    why_human: "Code-level proof (same GWDrawerReceiptHead/GWDrawerStatusPill class or transaction_displays.dart's byte-identical geometry + shared txStatusColors palette; same GWSelectRow class) is verified in this report, but whether the composition actually READS as one visual family is a rendering judgment no grep or widget test can make"
  - truth: "The transaction receipt's four TransactionStatus states are visibly distinct and the amount stays neutral in every one"
    test: "Open a completed, pending, failed and cancelled transaction receipt in both appearance modes"
    expected: "All four status pills read as distinct colours (cancelled must read slate, not red/error); the amount text never takes the status colour in any of the four"
    why_human: "txStatusColors' four-tone mapping and the amount/pill colour separation are proven by source (D-03 guard, result_receipt_family_test.dart), but WCAG-adjacent visual distinctness and 'does the amount look neutral' are rendering judgments"
human_verification:
  - test: "Run the 37-item consolidated human walk checklist in 21-06-SUMMARY.md (section 'Consolidated Human Walk Checklist (21-01 through 21-06)'), covering every converted drawer in both appearance modes and both desktop-panel/mobile-sheet breakpoints"
    expected: "Every item in that checklist passes as described"
    why_human: "No executor session in this phase had a running app instance (do_not_launch_the_app constraint); this is the single outstanding gate before the phase can be marked passed"
  - test: "Decide whether BuySuccessDrawer/BuyCancelledDrawer (re-skinned in 21-03) should be wired to a real Banxa purchase-result callback, or left dev-only, or removed"
    expected: "A developer decision, not an automated check — these two drawers currently have zero production callers (only lib/dev/dev_tools_bubble.dart)"
    why_human: "This is an open product question the phase surfaced rather than silently resolved; no code change is required to close Phase 21 itself, but it should not be forgotten"
---

# Phase 21: Drawer language rollout — the four decided drawer designs, applied to every drawer — Verification Report

**Phase Goal:** Apply the four decided drawer content patterns (031-B1 receipt, 032-A1 list picker,
033-B1 confirm, 034-A2 receive) to every `ResponsiveDrawer` instance in the app, and give the shared
shell the padded body 030-B1 always specified.

**Verified:** 2026-07-30
**Status:** human_needed
**Re-verification:** No — initial verification

## Method note: re-planned mid-flight

21-01 executed against the original plan set. Plans 21-02..21-06 were retired **before execution**
because their file inventories had drifted (work landed outside GSD tracking between planning and
execution — see `superseded-stale-file-inventory/README.md`). Fresh 21-02..21-06 were written against
the live tree and executed. This report treats the **corrected, measured inventory** (17 files / 18
`ResponsiveDrawer.show` call sites, independently re-counted below) as the yardstick, not the original
ROADMAP text's stale file names (`account_dropdown_selector.dart`, a 6th "Assets" list drawer, only 2
Receive drawers) — each of those corrections is itself independently confirmed in this report, not
just asserted by the SUMMARYs.

## Independent census re-count

The phase's own closing claim (21-06-SUMMARY.md) is **17 files / 18 `ResponsiveDrawer.show` call
sites**. Re-counted independently with `grep -rl`/`grep -n` (not by running the invariant test):

| File | Real call sites (comments excluded) |
|---|---|
| `lib/account/account_drawer.dart` | 1 |
| `lib/account/sdk_account_manager.dart` | 1 |
| `lib/banxa/banxa_components/buy_cancelled_drawer.dart` | 1 |
| `lib/banxa/banxa_components/buy_success_drawer.dart` | 1 |
| `lib/components/coins/view/coins_screen.dart` | 1 |
| `lib/components/wallet_information.dart` | 2 |
| `lib/dashboard/bridge/bridge_screen.dart` | 1 |
| `lib/dashboard/home/widgets/transaction_displays.dart` | 1 |
| `lib/dev/design_gallery_screen.dart` | 1 |
| `lib/network/network_dropdown_selector.dart` | 1 |
| `lib/reown/approve_dapp_connection_drawer.dart` | 1 |
| `lib/reown/approve_transaction_drawer.dart` | 1 |
| `lib/reown/swap_result_drawer.dart` | 1 |
| `lib/squid_router/swap_settings_drawer.dart` | 1 |
| `lib/squid_router/token_selector_drawer.dart` | 1 |
| `lib/submit_job/view/job_drawer.dart` | 1 |
| `lib/tokens/token_info_screen.dart` | 1 |

**17 files, 18 call sites — matches the claimed census exactly.** (`lib/components/bottom_drawer/responsive_drawer.dart` itself also matches the literal text `ResponsiveDrawer.show` but only inside a comment, not a call — correctly excluded from both the census and my count.)

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|---|---|---|
| 1 | Every drawer body has the same inset, from one source, no drawer padded twice; `showTransactionDetails` no longer touches panel edges | ✓ VERIFIED | `test/components/drawer_padding_invariant_test.dart` (30 cases, independently re-confirmed the 17/18 census above); `transaction_displays.dart` classified `shellInset`, no `bodyPadding` arg, no duplicating wrapper (spot-checked) |
| 2 | Six receipts / five list pickers / two confirms + three Receive drawers read as one visual family | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | Code-level family proven (shared `txStatusColors` palette + byte-identical pill geometry between `_statusPill` and `GWDrawerStatusPill`; shared `GWSelectRow` class across 5 pickers) — see below. Visual "reads as one family" needs the live walk |
| 3 | Transaction receipt shows fiat + exact amount via `_statusPill`; all four states visibly distinct; amount stays neutral | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `content.valueLine`/`content.exactAmount` confirmed rendered (`transaction_displays.dart:276-283,654-658`) — code half VERIFIED. Visual distinctness/neutrality across appearance modes needs the live walk |
| 4 | Two signing drawers (`approve_transaction_drawer.dart`, `approve_dapp_connection_drawer.dart`) are re-skinned and **behaviourally identical** — proven, not asserted | ✓ VERIFIED | Independently diffed (`git diff af1f5f5^ e56b9a3`): `static Future<bool?> show(...)` signature, `pop(true)`/`pop(false)` call sites, class names, all byte-identical before/after the re-skin. 14-case `test/reown/approve_drawer_contract_test.dart` exercises approve/reject/dismiss × {desktop,mobile} × {both drawers} through real gestures |
| 5 | `flutter analyze` clean on every touched file; existing drawer tests pass unchanged | ✓ VERIFIED | Orchestrator re-run at HEAD `d3a65ea`: `flutter analyze --no-pub` exit 0 (root + `packages/genius_api`); `flutter test --no-pub` 788/788 |
| 6 | One runnable check per pattern, not per file | ✓ VERIFIED | D-01 padding → `drawer_body_padding_test.dart`/`responsive_drawer_body_padding_test.dart`; D-04 list → `gw_select_row_test.dart`; D-02 receipt → `result_receipt_family_test.dart`; D-05 confirm → `approve_drawer_contract_test.dart`; D-06 receive → `crypto_address_chunks_test.dart`; closing census → `drawer_padding_invariant_test.dart` |

**Score:** 4/6 truths verified (2 present + wired, visual behavior not exercised by any test — routed to human verification)

### Per-Pattern Verdicts (not averaged into a percentage)

**031-B1 · Receipt** (ROADMAP named 6: `transaction_displays.dart`, `squid_router/swap_success_drawer.dart`, `squid_router/swap_fail_drawer.dart`, `reown/swap_result_drawer.dart`, `banxa/buy_success_drawer.dart`, `banxa/buy_cancelled_drawer.dart`)

| Drawer | Verdict | Evidence |
|---|---|---|
| `transaction_displays.dart` (`showTransactionDetails`) | already-converted-before | Own bespoke `_statusPill`/`GWKicker`/`GWDetailGrid` implementation shipped by `d7903fc` ahead of GSD tracking. Confirmed: fiat + exact-amount rendered (lines 276-283, 654-658); `_statusPill` geometry (999 radius, space4/3px padding, 6px dot, 5px gap, labelMd w600) is byte-identical to the new `GWDrawerStatusPill`, both driven by the same `txStatusColors` function — genuinely one palette/geometry source, not a coincidence |
| `squid_router/swap_success_drawer.dart` | not-applicable (deleted) | Deleted by `9ff7c04` in Phase 8, before this phase started; repointed to the shared transaction receipt |
| `squid_router/swap_fail_drawer.dart` | not-applicable (deleted) | Same as above |
| `reown/swap_result_drawer.dart` | converted-by-this-phase | 21-03: rebuilt on `GWDrawerReceiptHead`/`GWDrawerStatusPill`/`txStatusColors`; `test/components/result_receipt_family_test.dart` passing |
| `banxa/buy_success_drawer.dart` | converted-by-this-phase, **no production caller** | 21-03: re-skinned onto the shared receipt vocabulary. Independently confirmed via grep: only `lib/dev/dev_tools_bubble.dart:683` calls `BuySuccessDrawer.show` anywhere in `lib/` — this is an open product question, not a phase gap |
| `banxa/buy_cancelled_drawer.dart` | converted-by-this-phase, **no production caller** | Same as above; only `dev_tools_bubble.dart:688` calls it |

**032-A1 · List picker** (ROADMAP named 6, corrected to 5 real drawers)

| Drawer | Verdict | Evidence |
|---|---|---|
| `network_dropdown_selector.dart` ("Select Network") | already-converted-before | `d7903fc`; consumes `GWSelectRow` |
| `squid_router/token_selector_drawer.dart` | already-converted-before | `bd501d7`; row inlined onto `GWSelectRow` directly by 21-01 (`_TokenRow` wrapper deleted) |
| `lib/account/account_drawer.dart` ("Your Accounts") | already-converted-before | `d7903fc`. **Note:** the ROADMAP's original name for this drawer, `account_dropdown_selector.dart`, is a *different* file that has no `ResponsiveDrawer.show` call at all (it is the dropdown-button widget, not the drawer) — confirmed independently by reading both files. This is a corrected inventory item, not a gap |
| `lib/account/sdk_account_manager.dart` ("SDK Accounts") | already-converted-before | `d7903fc` |
| `lib/dashboard/bridge/bridge_screen.dart` ("Select destination network") | converted-by-this-phase | 21-02: `_NetworkPickerRow` class deleted (confirmed absent via grep), replaced by inline `GWSelectRow`; `test/dashboard/bridge/bridge_destination_picker_test.dart` passing |
| `components/coins/view/coins_screen.dart` ("Assets") | not-applicable | Measured (21-02) to be an inline `GWSectionTitle`, not a drawer at all — no `ResponsiveDrawer.show` call exists for this in the file. Correction recorded, not silently dropped |

**033-B1 · Confirm** (2, unchanged from ROADMAP)

| Drawer | Verdict | Evidence |
|---|---|---|
| `reown/approve_transaction_drawer.dart` | converted-by-this-phase | 21-04: borderless identity, one merged `GWDetailGrid`, `GWButton` footers. Behavioral identity independently re-proven (see Truth 4 above) |
| `reown/approve_dapp_connection_drawer.dart` | converted-by-this-phase | Same, independently re-proven the same way |

**034-A2 · Receive** (ROADMAP named 2, corrected to 3)

| Drawer | Verdict | Evidence |
|---|---|---|
| `components/coins/view/coins_screen.dart` ("Receive") | already-converted-before, chunking corrected | 21-05 fixed the middle-truncation defect in the shared `CryptoAddressQR` this caller uses |
| `tokens/token_info_screen.dart` ("Receive {coin}") | already-converted-before, chunking corrected | Same shared component fix |
| `components/wallet_information.dart` (Receive call site) | converted-by-this-phase | 21-05: the third, previously-uncounted receive drawer — fractional-height `Container` wrapper deleted (confirmed: no `size.height * .15` pattern remains), retitled to "Receive" matching the other two |

### Deliberate Skips — the integrity test

All confirmed independently, none silently counted as converted:

| Item | Verdict | Independent confirmation |
|---|---|---|
| `banxa/handle_banxa_drawer.dart`'s `showCheckoutOptionsSheet` | deliberately-skipped-with-reason | `grep -n "showModalBottomSheet"` confirms it calls the raw Flutter API, not `ResponsiveDrawer.show` — adopting the shell would relocate it to a centred desktop dialog at the `GeniusBreakpoints.medium` boundary, a presentation change outside a re-skin-only phase's fence. Recorded in the file's own comment and a pending todo for a future phase |
| `lib/submit_job/view/job_drawer.dart` ("New processing job") | deliberately-skipped-with-reason (D-09) | Census-classified `shellInset`; measured by 21-06 to already carry no ad-hoc wrapper — fits none of the four patterns, gets the shared inset and nothing else, as instructed |
| `wallet_information.dart` "More Options" call site | deliberately-skipped-with-reason (D-09) | Census-classified `shellInset`; measured by 21-05 to already carry no ad-hoc inset |
| `account_drawer.dart`'s "Rename Wallet" / "Delete wallet" | not-applicable | Independently confirmed: `GWDialog.show<String>(...)` — a dialog, not a drawer at all |
| `network_dropdown_selector.dart`'s "Network Changed" | not-applicable | Independently confirmed: `ToastManager.instance.showToast(...)` — a toast, not a drawer |
| `swap_settings_drawer.dart` (a form) | deliberately-skipped-with-reason (D-09) | Census-classified `shellInset`; already correct (the file the shell's own default padding was originally measured from) |

No skip was counted toward a "converted" total in any SUMMARY; each carries its own reason in the closing census table (21-06-SUMMARY.md).

### Required Artifacts

| Artifact | Expected | Status | Details |
|---|---|---|---|
| `lib/components/bottom_drawer/drawer_content.dart` | `GWDrawerStatusPill` + `GWDrawerReceiptHead` primitives | ✓ VERIFIED | Exists, substantive (152+ lines with doc rationale), wired into 3 consumers (swap result, both Banxa results) |
| `lib/components/bottom_drawer/responsive_drawer.dart` | Shared padded body (`bodyPadding`, `kDrawerBodyPadding`) | ✓ VERIFIED | Pre-existing (shipped by `8044bdb` ahead of GSD tracking), confirmed by 21-01's mobile-branch test and this phase's 30-case invariant test |
| `lib/components/bottom_drawer/bottom_drawer.dart` | Legacy shell, superseded | ✓ VERIFIED DELETED | `test ! -f` confirms absence; only prose-comment mentions remain (`sdk_account_manager.dart:81,85`, see Anti-Patterns) |
| `test/components/drawer_padding_invariant_test.dart` | Census gate over all 17 files / 18 call sites | ✓ VERIFIED | Independently re-counted census matches exactly (see above) |
| `test/reown/approve_drawer_contract_test.dart` | Behavioral-identity proof for the two signing drawers | ✓ VERIFIED | 14 cases exist; independently confirmed the underlying claim (byte-identical `show()`/`pop()`) via `git diff`, not just by trusting the test file |
| `test/components/result_receipt_family_test.dart` | D-02/D-03 family + neutral-amount guard | ✓ VERIFIED | Exists; asserts palette source (not a re-derived hex) and a text-walk guard against non-pill status colouring |
| `test/components/crypto_address_chunks_test.dart` | 034-A2 grouped chunking + full-address copy | ✓ VERIFIED | Exists; 4 cases covering whole-address render, full-value copy, emphasis contrast, short-address edge case |
| `test/dashboard/bridge/bridge_destination_picker_test.dart` | Bridge picker's first-ever test | ✓ VERIFIED | Exists; 2 cases (selection wiring, tap-pops-with-network) |

### Key Link Verification

| From | To | Via | Status | Details |
|---|---|---|---|---|
| `ResponsiveDrawer.show(bodyPadding:)` | `_ResponsiveDrawerScaffold` body | Default `kDrawerBodyPadding`, opt-out `EdgeInsets.zero` | ✓ WIRED | 11 `shellInset` files take no argument (default applies); 6 `ownsScrollingViewport` files explicitly pass `EdgeInsets.zero` — spot-checked 2 of each independently, all matched the invariant test's own classification |
| `swap_result_drawer.dart` / Banxa result drawers | `txStatusColors()` | Direct function call, same source `transaction_displays.dart` exports | ✓ WIRED | `grep -rn txStatusColors` confirms both Banxa content files and the Reown result drawer call the identical function `transaction_displays.dart` defines and its own `_statusPill` uses |
| `approve_transaction_drawer.dart` / `approve_dapp_connection_drawer.dart` | Caller (`handle_dapp_requests.dart`) | `show()` signature + `pop(true/false)` | ✓ WIRED, UNCHANGED | Independently diffed — zero signature or return-value drift across the re-skin |
| `bridge_screen.dart` destination picker | `GWSelectRow` | Inline row construction in `ListView.builder` | ✓ WIRED | `_NetworkPickerRow` class confirmed deleted; `GWSelectRow` count = 2 (import + usage) |

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|---|---|---|---|---|
| `lib/account/sdk_account_manager.dart` | 81, 85 | Stale comment describing `BottomDrawer` in the present tense ("it and render `BottomDrawer` inside instead"; "`BottomDrawer` paints itself...") though the class was deleted by this phase (21-06) | ℹ️ Info / minor | Comment-only, no functional impact — but misleading to a future reader who greps for `BottomDrawer` expecting a live class. Not a blocker; worth a one-line fix in a follow-up commit |

No `TBD`/`FIXME`/`XXX` markers found in any file this phase touched. No placeholder returns, no empty handlers, no hardcoded-empty data flowing to render in any spot-checked file.

### Requirements Coverage

None — the phase and all six plans declare `requirements: []`. Confirmed by grepping every `21-0N-PLAN.md`'s frontmatter; no requirement IDs were coined or claimed, matching the ROADMAP's "Requirements: none new — re-skin of shipped surfaces."

### Human Verification Required

1. **The consolidated 37-item walk** (21-06-SUMMARY.md, "Consolidated Human Walk Checklist (21-01 through 21-06)") — covers every converted drawer, both appearance modes, both desktop-panel/mobile-sheet breakpoints. This is the single artifact needed to close the phase's visual claims; no other document needs to be read to run it.
2. **Product decision on the two orphaned Banxa result drawers** — `BuySuccessDrawer`/`BuyCancelledDrawer` were re-skinned but have no production caller (only the dev tools bubble). Not a defect in this phase's work; a decision for the developer on whether/how to wire them to a real purchase flow.

### Gaps Summary

No gaps. Every observable truth is either mechanically VERIFIED against the live tree (re-confirmed independently in this report, not taken on SUMMARY claims alone) or explicitly routed to human verification as a genuinely visual claim no static check can resolve. The two behavior-unverified truths (family read, four-state distinctness) were never claimed PASS by any executor — every SUMMARY recorded them OUTSTANDING, and this report confirms that discipline held.

---

_Verified: 2026-07-30_
_Verifier: Claude (gsd-verifier)_
