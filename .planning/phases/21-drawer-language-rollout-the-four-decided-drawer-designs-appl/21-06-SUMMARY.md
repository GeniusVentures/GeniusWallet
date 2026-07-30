---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 06
subsystem: ui
tags: [flutter, drawers, design-system, invariant-test, source-scanning-gate]

# Dependency graph
requires:
  - phase: 21-01
    provides: "responsive_drawer.dart's default-padded, EdgeInsets.zero-to-opt-out bodyPadding mechanism"
  - phase: 21-02
    provides: "bridge_screen.dart's destination picker as the fifth ownsScrollingViewport call site"
  - phase: 21-03
    provides: "the three converted result drawers (Reown swap result, both Banxa outcomes) as shellInset call sites"
  - phase: 21-04
    provides: "the two converted signing drawers as shellInset call sites"
  - phase: 21-05
    provides: "wallet_information.dart's third receive drawer, measured and left correct, as a shellInset call site"
provides:
  - "test/components/drawer_padding_invariant_test.dart -- the standing 4-test census gate over all 17 files / 18 ResponsiveDrawer.show call sites in lib/"
  - "Deletion of lib/components/bottom_drawer/bottom_drawer.dart -- the legacy pre-07-06 shell, its one consumer re-pointed at the real shell"
  - "The phase's closing census: every ResponsiveDrawer.show call site, its title, its pattern, and where it was converted"
  - "A consolidated, de-duplicated, screen-organised human walk checklist covering 21-01 through 21-06"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Source-scanning completeness gate (census map + tree-walk diff), modelled structurally on test/banxa/banxa_reskin_literals_test.dart -- a hand-written const collection, not a glob, diffed against a live tree-walk so drift in EITHER direction (new unclassified call site, or a censused path that stopped existing) fails loudly"

key-files:
  created:
    - test/components/drawer_padding_invariant_test.dart
  modified:
    - lib/dev/design_gallery_screen.dart

key-decisions:
  - "The gallery's Drawer demo now passes title: 'Drawer demo' straight to ResponsiveDrawer.show and a plain ListView with bodyPadding: EdgeInsets.zero -- the exact shape the five list pickers already use -- rather than inventing a sixth pattern for a dev-only demo"
  - "Discovery in the invariant test walks lib/ recursively (Directory.listSync(recursive: true)) to find the TRUE set of call sites for the diff -- this is NOT the prohibited 'glob as the census': the census itself (_census, a hand-written const Map) never changes as a result of the walk; only the DIFF against it can fail a test, which is the enforcement the plan's Test 1/Test 2 explicitly ask for"
  - "Call-site regions are extracted by balancing parens from each ResponsiveDrawer.show( match to its closing paren, over comment-stripped source, so Test 3/4's checks never look inside the WRONG call site in a file that holds two (wallet_information.dart)"
  - "handle_banxa_drawer.dart's showCheckoutOptionsSheet was NOT added to the census and NOT converted -- it calls raw showModalBottomSheet, not ResponsiveDrawer.show, by a Rule-4-class architectural decision recorded in its own file (adopting the shell would silently turn it into a centred desktop dialog, a presentation change outside a re-skin-only phase's fence) -- see Findings below"

requirements-completed: []

# Coverage metadata
coverage:
  - id: D1
    description: "Every ResponsiveDrawer.show call site in lib/ either takes the shared body inset or appears on a written exception list with a stated reason, and a new drawer that does neither fails a test rather than shipping unpadded"
    verification:
      - kind: unit
        ref: "test/components/drawer_padding_invariant_test.dart#every ResponsiveDrawer.show call site in lib/ is in the census -- a new, unclassified drawer fails this instead of shipping unpadded"
        status: pass
      - kind: unit
        ref: "test/components/drawer_padding_invariant_test.dart#the census is not stale in the other direction -- every path it names still contains at least one real call site"
        status: pass
      - kind: unit
        ref: "test/components/drawer_padding_invariant_test.dart#[17 per-path] -- every call site matches its census classification"
        status: pass
    human_judgment: false
  - id: D2
    description: "No drawer body in the app is padded twice, and no drawer renders a second header inside the shell's"
    verification:
      - kind: unit
        ref: "test/components/drawer_padding_invariant_test.dart#[11 shellInset paths] -- a shellInset call site does not wrap its child in a duplicating Padding/Container"
        status: pass
      - kind: other
        ref: "grep -rn 'BottomDrawer' lib/ test/ -- zero live callers remain after Task 1's deletion (two pre-existing prose mentions in sdk_account_manager.dart comments, one new prose mention this plan added)"
        status: pass
    human_judgment: false
  - id: D3
    description: "The drawers that fit none of the four patterns got the shared inset and nothing else -- recorded as a measured census, not assumed"
    verification:
      - kind: other
        ref: "swap_settings_drawer.dart and job_drawer.dart (D-09) measured: both are shellInset with no ad-hoc wrapper, matching their pre-existing correct state; see the closing census table"
        status: pass
    human_judgment: true
    rationale: "The classification is proven mechanically (no bodyPadding argument, no duplicating wrapper), but whether these two drawers actually READ as correctly inset next to the eighteen others is a visual judgment this session cannot make -- no live app instance. Recorded OUTSTANDING in the consolidated walk checklist."
  - id: D4
    description: "The legacy BottomDrawer shell is deleted; exactly one shell exists in the app"
    verification:
      - kind: other
        ref: "test ! -f lib/components/bottom_drawer/bottom_drawer.dart; flutter analyze --no-pub exit 0 (catches a missed import)"
        status: pass
    human_judgment: false

# Metrics
duration: ~35min (estimate -- PLAN_START_TIME was not captured with an instrumented epoch call at session start, matching the same gap every other 21-0N summary recorded)
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 06: The invariant census, and the legacy shell's deletion Summary

**A hand-written, tree-walk-verified census of all 17 files / 18 `ResponsiveDrawer.show` call sites in `lib/` now backs a 4-test source-scanning gate, and the legacy `BottomDrawer` shell (its own centred title, left-side close X, one live consumer) is deleted -- closing 21-01's third OUTSTANDING item.**

## Performance

- **Duration:** ~35 min (estimate; `PLAN_START_TIME` was not captured with an instrumented epoch call at session start)
- **Completed:** 2026-07-30T16:51:48Z (last task commit)
- **Tasks:** 2/2
- **Files modified:** 3 (1 deleted, 1 edited, 1 new test file)

## Accomplishments

- Verified the deletion's premise first, by grep, before touching anything: `BottomDrawer`'s only references in the whole tree were its own file, `design_gallery_screen.dart`'s one import + one call site, and two prose mentions inside comments in `sdk_account_manager.dart`. No live consumer this plan did not measure.
- `design_gallery_screen.dart`'s Drawer demo re-pointed onto the shell's own vocabulary: `title: 'Drawer demo'` passed straight to `ResponsiveDrawer.show`, body is a plain `ListView` carrying `bodyPadding: EdgeInsets.zero` + its own `space10` inset -- the exact shape the app's five list pickers already use. This closes 21-01-SUMMARY.md's third OUTSTANDING visual item: the gallery's `BottomDrawer` usage WAS double-padded when opened through `ResponsiveDrawer.show()` (a second header inside the shell's own header), and the answer, now, is that the widget doing the double-painting no longer exists.
- Deleted `lib/components/bottom_drawer/bottom_drawer.dart` (95 lines) and its one import. `flutter analyze` stayed 0 across the whole root package -- the check that would have caught a missed import.
- Built `test/components/drawer_padding_invariant_test.dart`, a source-scanning Dart test modelled structurally on `test/banxa/banxa_reskin_literals_test.dart`: a hand-written `const Map<String, _Inset>` census (17 paths, 18 call sites) diffed against a live recursive walk of `lib/`. Four groups of assertions: (1) no undiscovered call site is missing from the census, (2) no censused path has gone stale, (3) every call site's actual `bodyPadding` argument matches its classification, (4) no `shellInset` call site wraps its child in a duplicating `Padding`/`Container`. 30 test cases total, all passing.
- Measured, not assumed, that the census matches reality exactly: every file the tree-walk discovers is one of the 17 the plan's own pre-wave-1 table named, with the exact same classification split (6 `ownsScrollingViewport`, 11 `shellInset`, `wallet_information.dart` correctly holding 2 call sites under one classification).

## Must-Have Truths -- verdicts

1. **"Every `ResponsiveDrawer.show` call site in `lib/` either takes the shared body inset or appears on a written exception list with a stated reason, and a new drawer that does neither fails a test rather than shipping unpadded."**
   **PASS**, automated. `drawer_padding_invariant_test.dart`'s Test 1 fails the moment an unclassified call site exists anywhere in `lib/`; verified this holds NOW (0 unclassified, discovered set == census keys exactly).
2. **"No drawer body in the app is padded twice, and no drawer renders a second header inside the shell's."**
   **PASS.** Test 4 proves no `shellInset` call site's `child:` opens on a duplicating `Padding`/`Container` (checked across all 11 `shellInset` files, 12 call sites). The second-header case (`BottomDrawer` inside `ResponsiveDrawer.show()`) is closed by deletion, not by a test assertion -- there is exactly one shell left in the app, confirmed by `grep -rn 'BottomDrawer'` returning only prose comments.
3. **"The drawers that fit none of the four patterns got the shared inset and nothing else -- recorded as a measured census, not assumed."**
   **PASS for the measurement.** `swap_settings_drawer.dart` and `job_drawer.dart` (D-09) are both `shellInset`, no ad-hoc wrapper, matching 21-05's own "measured, not assumed" note on the More Options drawer. See the closing census table below for the full accounting, including the three named-but-not-`ResponsiveDrawer` cases (Findings section).

## Task Commits

Each task was committed atomically (sequential executor, per this dispatch's override of the plan's own "Do not commit" text -- see Deviations):

1. **Task 1: Delete the legacy shell and re-point its one demo** -- `268b6bf` (feat)
2. **Task 2: The phase invariant, proven across every call site at once** -- `089cc3a` (test)

**Plan metadata:** (this commit, docs)

## Files Created/Modified

- `lib/components/bottom_drawer/bottom_drawer.dart` -- DELETED. The legacy pre-07-06 shell: centred title, left-side close X, `surfaceMenu` #171A21 fill inside a `surfaceElevated` #0C0E14 panel, its own `space8` body inset. Measured to have exactly one live consumer before deletion.
- `lib/dev/design_gallery_screen.dart` -- `BottomDrawer` import removed; the Drawer demo section now passes `title: 'Drawer demo'` to `ResponsiveDrawer.show` and a plain `ListView` (`bodyPadding: EdgeInsets.zero`, the list's own `space10` padding) with the same 20 generated rows as before; the section's comment rewritten to state what is true now (demonstrates the shipped shell) rather than why the title used to be omitted.
- `test/components/drawer_padding_invariant_test.dart` -- NEW. The census (`_census`, 17 entries), the tree-walk discovery function, the paren-balancing call-region extractor, and 4 groups of assertions (30 total test cases).

## The Phase's Closing Census

Every `ResponsiveDrawer.show` call site in `lib/` at the end of Phase 21, with its title, its pattern, and where it was converted. 17 files, 18 call sites (`wallet_information.dart` holds two).

| Call site | Title | Pattern | Converted in |
|---|---|---|---|
| `lib/account/account_drawer.dart` | "Your Accounts" | 032-A1 (`GWSelectRow`) | Already shipped ahead of GSD tracking (`d7903fc`), confirmed by 21-01 |
| `lib/account/sdk_account_manager.dart` | "SDK Accounts" | 032-A1 (`GWSelectRow`) | Already shipped ahead of GSD tracking, confirmed by 21-01 |
| `lib/network/network_dropdown_selector.dart` | "Select Network" | 032-A1 (`GWSelectRow`) | Already shipped ahead of GSD tracking, confirmed by 21-01 |
| `lib/squid_router/token_selector_drawer.dart` | "Select Token" (default) | 032-A1 (`GWSelectRow`) | Already shipped ahead of GSD tracking; `_TokenRow` wrapper inlined directly onto `GWSelectRow` by 21-01 |
| `lib/dashboard/bridge/bridge_screen.dart` | "Select destination network" | 032-A1 (`GWSelectRow`) | 21-02 -- the fifth and last `GWSelectRow` call site, `_NetworkPickerRow` deleted |
| `lib/dev/design_gallery_screen.dart` | "Drawer demo" (dev-only) | none (scrolling demo) | 21-06 Task 1 -- re-pointed off the deleted `BottomDrawer` shell |
| `lib/dashboard/home/widgets/transaction_displays.dart` | `content.action` (dynamic, e.g. "Transaction Details") | 031-B1 (`GWDrawerReceiptHead`/`GWDrawerStatusPill`) | Already shipped ahead of GSD tracking, confirmed by 21-01 |
| `lib/reown/swap_result_drawer.dart` | `message` (dynamic, e.g. "Swap Complete") | 031-B1 (`GWDrawerReceiptHead`/`GWDrawerStatusPill`) | 21-03 |
| `lib/banxa/banxa_components/buy_success_drawer.dart` | "Purchase complete" | 031-B1 (`GWDrawerReceiptHead`/`GWDrawerStatusPill`) | 21-03 |
| `lib/banxa/banxa_components/buy_cancelled_drawer.dart` | "Purchase cancelled" | 031-B1 (`GWDrawerReceiptHead`/`GWDrawerStatusPill`) | 21-03 |
| `lib/reown/approve_transaction_drawer.dart` | "Transaction Request" | 033-B1 (borderless identity, merged `GWDetailGrid`) | 21-04 |
| `lib/reown/approve_dapp_connection_drawer.dart` | "Connection Request" | 033-B1 (borderless identity, merged `GWDetailGrid`) | 21-04 |
| `lib/components/coins/view/coins_screen.dart` | "Receive" | 034-A2 (grouped address chunking) | Already shipped ahead of GSD tracking; chunking corrected by 21-05 |
| `lib/tokens/token_info_screen.dart` | "Receive" / "Receive {coin}" | 034-A2 (grouped address chunking) | Already shipped ahead of GSD tracking; chunking corrected by 21-05 |
| `lib/components/wallet_information.dart` (Receive call site) | "Receive" | 034-A2 (grouped address chunking) | 21-05 -- the third, previously-uncounted receive drawer; fractional-height wrapper deleted, retitled to match the other two |
| `lib/components/wallet_information.dart` (More Options call site) | "More Options" | D-09 (fits none of the four; shared inset only) | Measured by 21-05 -- already correct, no ad-hoc inset, no change needed |
| `lib/squid_router/swap_settings_drawer.dart` | "Swap Settings" | D-09 (fits none of the four; shared inset only) | Already shipped ahead of GSD tracking (the file the shell's own `kDrawerBodyPadding` default was promoted FROM) |
| `lib/submit_job/view/job_drawer.dart` | "New processing job" | D-09 (fits none of the four; shared inset only) | Measured by this plan (21-06) -- already correct, no ad-hoc inset, no change needed |

**Not in this census -- named, not silently omitted:**

- `lib/banxa/handle_banxa_drawer.dart`'s `showCheckoutOptionsSheet` is a raw `showModalBottomSheet`, not a `ResponsiveDrawer.show` call, so it is out of scope for this census by construction (it takes no `bodyPadding` argument because it has no such parameter at all). Left alone by a recorded Rule-4-class architectural decision, not an oversight: its own file comment and `.planning/todos/pending/2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified.md` explain that adopting `ResponsiveDrawer` would silently turn this bottom sheet into a centred desktop dialog (the shell switches presentation at `GeniusBreakpoints.medium`), which is a restructuring change under `PROJECT.md` §65, not a re-skin -- out of bounds for this phase's fence. The todo explicitly defers the question to a future phase that wants to claim this migration with its own reviewed contract.
- The two Banxa result drawers (`buy_success_drawer.dart`, `buy_cancelled_drawer.dart`) ARE in the census above (they are real `ResponsiveDrawer.show` call sites), but 21-03-SUMMARY.md's own finding stands unresolved: neither has a production caller today, only `lib/dev/dev_tools_bubble.dart`. Recorded again here so this closing census does not silently imply they are reachable from a real purchase flow.

## Decisions Made

See `key-decisions` in frontmatter. In short: (1) the gallery demo now uses the shell's own title + scrolling-list vocabulary rather than inventing anything new; (2) the invariant test's tree-walk discovery is the mechanism that PROVES the hand-written census complete, not a second census -- the census itself never changes as a result of running the test, only the pass/fail does; (3) call-site regions are extracted by paren-balancing so a file with two call sites (`wallet_information.dart`) cannot have Test 3/4 conflate them; (4) `handle_banxa_drawer.dart` was deliberately left out of the census and unconverted, per its own already-recorded architectural reasoning.

## Deviations from Plan

### Dispatch override (not a Rule 1-4 deviation)

**Committed each task, against the plan's own "Do not commit" text.** `21-06-PLAN.md`'s `<constraints>` and `<output>` both say "Do not commit. Leave every change in the working tree" -- written for a parallel wave. This dispatch's own `<sequential_execution>` block explicitly overrides that: this session is the SEQUENTIAL executor on the main working tree (worktree isolation disabled), and the dispatch instructs "you ARE the sequential executor and you DO commit." Followed the dispatch, not the plan text -- each task was committed atomically as instructed, matching the same override 21-02 through 21-05 recorded in their own summaries for the same reason.

No Rule 1-4 code deviations occurred. Both tasks were executed as written: the deletion's premise was grep-verified before touching anything (as instructed), the gallery re-point matched the plan's exact prescription (title passed through, `bodyPadding: EdgeInsets.zero`, the list's own `space10` padding, the same one-line comment style the five pickers carry), and the census matched the plan's own pre-wave-1 measured table exactly once cross-checked against the post-wave-1 tree.

---

**Total deviations:** 1 (dispatch-level execution-mode override, consistent with 21-02/21-03/21-04/21-05 precedent). No auto-fixed bugs, no added functionality beyond what the plan specified.

## Issues Encountered

None. No build errors, no flaky tests, no auth gates, no package-manager installs. The one thing worth recording as a non-issue: the plan's pre-wave-1 census table (measured at HEAD `08f6df5`) turned out to still be byte-accurate after all five wave-1 plans landed -- every file, every classification, matched the tree-walk's discovery exactly on the first run, with zero corrections needed to the table the plan handed down.

## Verification (evidence quoted, not asserted)

```
flutter analyze --no-pub                        -> 0 issues, exit 0
(cd packages/genius_api && flutter analyze --no-pub) -> 0 issues, exit 0
flutter test --no-pub                            -> 788/788 passing, 0 failing (758 baseline + 30 new)
bash tool/check_brace_style.sh                   -> exit 0
bash tool/check_raw_colors.sh                    -> exit 0
bash tool/check_no_new_key_logging.sh --scan-tree -> OK
bash tool/check_onboarding_seed_safety.sh        -> PASSED (all six Section 3 checks)
dart format --set-exit-if-changed lib test       -> exit 0 (346 files, 0 changed after this plan's own formatting pass)
test ! -f lib/components/bottom_drawer/bottom_drawer.dart -> confirmed absent
grep -rn 'BottomDrawer' lib/ test/               -> only prose comments (sdk_account_manager.dart x2, design_gallery_screen.dart x1, all non-code)
```

## No new logging

`grep -n "debugPrint\|print(\|log("` across both modified `lib/` files and the new test file returns nothing beyond pre-existing, unrelated matches outside this plan's edited regions. No request payload, address, or signing data is logged anywhere this plan touched.

## Consolidated Human Walk Checklist (21-01 through 21-06)

The executor cannot launch the app (`do_not_launch_the_app` constraint). Every item below is **OUTSTANDING**, not PASS, per this project's standing no-unearned-PASS rule. This is the ONE walk that closes the phase -- collected from all five prior plans' own OUTSTANDING sections plus this plan's own, de-duplicated, and organised by screen so a walker does not need to read six documents.

### Dev tools / design gallery

1. Dev gallery -> **Open drawer demo**. It now shows the shipped shell's own header: title on the left, X top-right, gradient hairline. Exactly ONE header, and no lighter block inside the panel (this replaces 21-01's open question -- `BottomDrawer` is deleted as of this plan).
2. The demo rows sit inset from the panel edges and scroll with their inset.

### Dashboard / wallet card

3. Wallet card -> **Receive**. Title reads "Receive". The network chip sits above the QR with a real gap under the header -- **not** a 150px hole and not pushed below the fold. Resize the window tall and short and confirm the gap does not scale with it.
4. Read the address out loud in groups of four against the address shown on the wallet card. Every character must be present; the first two and last two groups must be visibly brighter and heavier than the middle.
5. Tap the address block. It says "Copied" and reverts after ~2s. Paste somewhere: the **full** 42-character address, not a truncated form.
6. Scan the QR with a phone camera in **dark** mode, then again in **light** mode. Both must resolve.
7. Wallet card -> **More**. Confirm the body's left edge lines up with the title's left edge and nothing is double-inset. Nothing else about it should have changed.

### Coins list / coin page -> Receive

8. Coins list (empty-wallet footer) -> **Receive**, and Coin page -> **Receive**. All three receive drawers (wallet card, coins list, coin page) must now look identical apart from their titles.
9. Repeat the address-block emphasis-contrast check (item 4) in **light** mode -- this is where light mode has historically broken.

### Bridge tab (destination picker)

10. Bridge tab -> tap the destination chip. In **dark** mode: the currently selected destination shows a rounded gradient tint plus a gradient check; every other row shows neither. No square full-bleed fill, no vertical accent bar, no rectangle border.
11. Repeat in **light** mode. The check glyph must still be the thing that reads first.
12. The rows sit inset from the panel edges and scroll with their inset -- no gap at the top, no double padding, nothing edge-to-edge.
13. Pick a different destination: the drawer closes and the destination chip shows the chain you picked.

### Swap tab (token picker, Swap Settings)

14. Swap tab -> tap either token field. In both **dark** and **light** mode: search field and rows sit inset from the panel edges (not edge-to-edge); a previously-selected token shows the rounded gradient tint + gradient check; an unselected token shows neither; scrolling the list does not reveal any gap or double-padding at top or bottom.
15. Open **Swap Settings** (or any drawer using the shell's default padding) and confirm the body's left edge visually lines up with the title's left edge, on both a wide (desktop-panel) window and a narrow (mobile-sheet) window.

### Account drawers (Your Accounts, SDK Accounts)

16. Open "Your Accounts" and "SDK Accounts": confirm the body's left edge lines up with the title's left edge, same as every other drawer.

### Select Network

17. Open "Select Network": same alignment check as item 16.

### New processing job

18. Open "New processing job" (submit-job flow): confirm the body's left edge lines up with the title's left edge -- this is a D-09 drawer (fits none of the four patterns, gets the shared inset only), measured correct by this plan but never visually walked.

### Transaction receipt

19. Transactions tab -> any row (the transaction receipt). Note its icon size, gap above the pill, and pill geometry for comparison against item 30 below -- if they do not read as one family, that is the phase's own headline claim failing, and is a finding worth filing.

### Reown signing drawers (Connection Request / Transaction Request)

20. Dev bubble -> **Connection Request**. Dark mode: the dApp favicon, name and url sit borderless with one hairline under them; no pill, no box. The question sentence is in the body, not stacked above the buttons.
21. Dev bubble -> **Transaction Request**. One Details card, not five boxes. The amount hero is large, centred and **neutral** -- not green, not red, not brand. The caution reads as generic advice and claims nothing specific.
22. On both: `Approve`/`Allow` is a filled gradient and `Reject`/`Deny` is a gradient outline. **Look at them for two seconds and answer honestly: do they read as equally affirmative?** `drawers-final/README.md` flagged this as open. If the negative still reads as a recommendation, say so -- that is a decision to make, not a bug to hide.
23. Tap the `To` row on the transaction drawer. Paste: the **full** address must arrive, not the truncated display form.
24. Feed a deliberately long dApp name (a few hundred characters) through the dev fixture. Neither drawer's buttons may be pushed off screen or below the fold; the name must ellipsise.
25. Feed a broken `iconUrl`. Nothing must render in the icon's place -- no broken-image glyph, no oversized box, no layout shift.
26. Repeat items 20-22 in **light** mode.
27. Narrow the window below 768 so both become bottom sheets and re-check that the buttons are reachable and the body scrolls.

### Reown swap result + Banxa purchase results (dev tools bubble only -- no production caller for the two Banxa drawers)

28. Dev bubble -> **Buy OK**. Dark mode: title reads "Purchase complete"; one green check glyph; a "Completed" pill under it; the sentence below is quiet grey, NOT green; one filled-gradient "Done" that actually closes the drawer.
29. Dev bubble -> **Buy fail**. Title "Purchase cancelled"; the glyph and pill read **slate**, not red -- a cancellation must not look like an error; the "Close" button is a gradient outline and actually closes the drawer.
30. Dev bubble -> the two swap-result buttons. Success shows a "Completed" pill and a TRANSACTION grid holding one copyable hash row; tapping the row shows the "Transaction hash copied" snackbar. Paste it somewhere and confirm the **full** 66-character hash arrived, not the truncated display form.
31. The failure branch (empty hash) shows no empty grid and no bare kicker floating over nothing.
32. Repeat items 28-30 in **light** mode. The slate cancelled pill is the one most likely to fail here.
33. Put items 28-30's results side by side with item 19's real transaction receipt. Same icon size, same gap above the pill, same pill geometry. If they do not read as one family, that is a finding worth filing -- it is the phase's headline claim.

### Cross-cutting, whole-app pass (this plan's own addition)

34. Open every drawer in one sitting and check the single thing this phase promised: **the body's left edge lines up with the title's left edge, in all of them** -- Receive, Swap Settings, New processing job, More Options, Select Network, Your Accounts, SDK Accounts, the token picker, the bridge destination picker, a transaction receipt, a swap result, both Banxa results, and both signing prompts.
35. The same pass in **light** mode.
36. Narrow below 768 so every drawer becomes a bottom sheet, and spot-check five of them for the same alignment.
37. Any drawer where the alignment is off is a finding worth filing with the file name -- the invariant test proves the mechanism, not the pixels.

## Next Phase Readiness

- The phase's mechanism is now provably complete: `test/components/drawer_padding_invariant_test.dart` fails the moment any future drawer is added without classification, closing the enforcement gap 07-06's honour-system rule left open.
- Exactly one drawer shell exists in the app (`ResponsiveDrawer`). The legacy `BottomDrawer` is deleted with zero live callers remaining.
- The one remaining open architectural question (`handle_banxa_drawer.dart`'s presentation-changing migration) is named and filed, not silently resolved either way -- a future phase can pick it up with its own reviewed contract.
- All 37 items in the consolidated walk checklist above are the single artifact needed to close Phase 21's human-verification debt; no further document needs to be read to run that walk.
- Gates at completion: `flutter analyze` 0/0 (root + `packages/genius_api`, real exit code, not piped through `tail`); `flutter test --no-pub` **788/788** (758 baseline + 30 new); `check_brace_style.sh` 0; `check_raw_colors.sh` 0; `check_no_new_key_logging.sh --scan-tree` OK; `check_onboarding_seed_safety.sh` PASSED; `dart format --set-exit-if-changed` exit 0.

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*

## Self-Check: PASSED

- FOUND: file deleted -- `lib/components/bottom_drawer/bottom_drawer.dart` confirmed absent
- FOUND: `lib/dev/design_gallery_screen.dart`
- FOUND: `test/components/drawer_padding_invariant_test.dart`
- FOUND commit: `268b6bf`
- FOUND commit: `089cc3a`
- `flutter analyze --no-pub` root: 0 issues, exit 0. `packages/genius_api`: 0 issues, exit 0.
- `flutter test --no-pub`: 788/788 passing (758 baseline + 30 new), 0 failing.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0. `bash tool/check_no_new_key_logging.sh --scan-tree`: OK. `bash tool/check_onboarding_seed_safety.sh`: PASSED.
- `dart format --set-exit-if-changed lib test`: exit 0 (346 files, 0 changed).
- `grep -rn 'BottomDrawer' lib/ test/`: only prose comments remain, zero live code references.
