---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 05
subsystem: ui
tags: [flutter, drawers, qr, clipboard, design-tokens]

# Dependency graph
requires:
  - phase: 21-01
    provides: shared drawer primitives (GWDrawerStatusPill, GWDrawerReceiptHead) and the padded-body shell
  - phase: 21-04
    provides: GWWarningNote (already consumed by crypto_address_qr.dart before this plan)
provides:
  - 034-A2's grouped 4-char address chunking, real (not just claimed by the docstring)
  - The third receive drawer (wallet_information.dart) unified with the other two, no fractional-height wrapper
  - One title ("Receive") across all three receive drawers instead of three spellings
affects: [21-06, any future phase touching CryptoAddressQR or wallet_information.dart]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Grouped monospace address block: a Wrap of Text children over pure top-level functions (_addressGroups, _isEmphasised), not a shared helper with transaction_displays.dart's _valueChunks (Rule of Three refusal, honoured per plan instruction)"

key-files:
  created:
    - test/components/crypto_address_chunks_test.dart
  modified:
    - lib/components/qr/crypto_address_qr.dart
    - lib/components/wallet_information.dart

key-decisions:
  - "No footer 'Copy address' CTA added to CryptoAddressQR, despite the sketch drawing one -- the footer belongs to the three callers (two of which this plan does not touch), and a second control for the same action on the same screen is the duplication D-06's 'copy only' exists to avoid. Recorded in the file's own action-block instruction and here."
  - "Token pair for the sketch's 'gap: 6px 10px': no 10px step exists on the 4-pt scale, so GeniusWalletConsts.space4 (8px) stands in for the horizontal gap and space3 (6px, the scale's one documented half-step) is exact for the vertical one."
  - "The More Options drawer (D-09) was measured, not assumed: it carries no ad-hoc inset of its own at HEAD, so it needed zero changes beyond the shared body inset it already had. This is D-09's 'say so out loud', done."
  - "No shared chunking helper extracted between crypto_address_qr.dart and transaction_displays.dart's _valueChunks -- two call sites, Rule of Three refusal honoured per the plan's explicit instruction."

requirements-completed: []

coverage:
  - id: D1
    description: "The address renders as 4-character groups spanning the WHOLE address (no ellipsis/elision), first two and last two groups emphasised (heavier weight, brighter colour)"
    verification:
      - kind: unit
        ref: "test/components/crypto_address_chunks_test.dart#a 42-character address renders as eleven groups, every character present, in order, with no ellipsis anywhere"
        status: pass
      - kind: unit
        ref: "test/components/crypto_address_chunks_test.dart#the first two and the last two groups are heavier and brighter than the middle ones"
        status: pass
    human_judgment: false
  - id: D2
    description: "Tapping the address block copies the FULL address (never the displayed/chunked form), for both a long and a short address"
    verification:
      - kind: unit
        ref: "test/components/crypto_address_chunks_test.dart#tapping the block copies the FULL address, not the displayed groups"
        status: pass
      - kind: unit
        ref: "test/components/crypto_address_chunks_test.dart#an address short enough to need no further grouping still renders whole and still copies whole"
        status: pass
    human_judgment: false
  - id: D3
    description: "The third receive drawer (wallet_information.dart) passes CryptoAddressQR bare, no fractional-height wrapper, retitled 'Receive' matching coins_screen.dart"
    verification:
      - kind: unit
        ref: "flutter analyze lib/components/wallet_information.dart -- 0 issues; grep -c 'size.height * .15' -- 0 occurrences; git diff scoped to only the ResponsiveDrawer.show region"
        status: pass
    human_judgment: false
  - id: D4
    description: "All three receive drawers visually read as one family; QR stays black-on-white in both modes; More Options drawer body alignment"
    verification: []
    human_judgment: true
    rationale: "Executor cannot launch the app (do_not_launch_the_app constraint). Live visual/camera-scan verification requires a running instance; recorded OUTSTANDING below with a verbatim checklist."

# Metrics
duration: 45min
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 05: Grouped receive-address chunking and the third drawer Summary

**`CryptoAddressQR` now renders the whole address as wrapped 4-character mono groups (first/last two emphasised) instead of a middle-truncated pill, and `wallet_information.dart`'s previously-uncounted third receive drawer drops its fractional-window-height wrapper and adopts the same "Receive" title as the other two.**

## Performance

- **Duration:** 45 min
- **Started:** 2026-07-30T16:00:00Z (approx.)
- **Completed:** 2026-07-30T16:37:30Z
- **Tasks:** 2/2
- **Files modified:** 2 (+1 new test file)

## Accomplishments

- Deleted `_shortAddress` (the `0x1234…5678` middle-truncation helper) and its bordered single-line pill entirely; replaced with a borderless `Wrap` of 4-character groups computed by two new pure top-level functions, `_addressGroups` and `_isEmphasised`, matching sketch drawers-final's own `groupAddr()` rule (`ADDR.match(/.{1,4}/g)`, emphasis at index 0, 1, and the final two)
- Fixed the file's docstring, which claimed the chunking had already shipped when the code still middle-truncated — it now describes what the code does and states why the full value must be on screen (this panel exists to be eyeball-compared against another address)
- Copy affordance behaviour preserved byte-for-byte: same `_copyAddress`/`_copied` state machine, same 2-second "Copied" reset, same tap target semantics (now `HitTestBehavior.opaque` on the `GestureDetector` wrapping the whole `Wrap`, so gaps between groups stay tappable)
- Deleted `wallet_information.dart`'s ad-hoc `Container(margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * .15))` wrapper around the receive drawer's `CryptoAddressQR` — the third and last of the three receive call sites still doing this, and the one D-06's roadmap table never counted (it names only `coins_screen.dart` and `token_info_screen.dart`)
- Retitled that drawer `"Receive"`, replacing `"Your ${state.selectedNetwork?.name} address"` — the third spelling of the same drawer for the same wallet address
- Measured the More Options drawer (`wallet_information.dart:207`, D-09) and confirmed it carries no ad-hoc inset of its own — changed nothing, as instructed
- New `test/components/crypto_address_chunks_test.dart`: 4 tests covering whole-address rendering with no elision, full-value clipboard copy on tap, emphasis contrast (fontWeight + colour) between the outer and middle groups, and the single-group short-address edge case

## Task Commits

Each task was committed atomically:

1. **Task 1: The address is chunked, whole, and still copies whole (D-06)** - `69fcdd3` (feat)
2. **Task 2: The third receive drawer, and the More Options drawer (D-01, D-06, D-09)** - `1c65c62` (feat)

_Note: this is a sequential-executor dispatch (see Deviations) — commits landed per-task as normal, not deferred to a parallel-wave merge._

## Files Created/Modified

- `lib/components/qr/crypto_address_qr.dart` - `_shortAddress` and its bordered pill deleted; grouped, wrapped, emphasis-coloured 4-char address block added via `_addressGroups`/`_isEmphasised`; docstring corrected
- `lib/components/wallet_information.dart` - the receive drawer's fractional-height `Container` wrapper deleted, `CryptoAddressQR` now passed bare; title changed to `"Receive"`
- `test/components/crypto_address_chunks_test.dart` (new) - the 034-A2 pattern's one runnable check

## Decisions Made

- **No footer "Copy address" CTA.** The sketch's Receive panel has one; this plan deliberately does not add it. The footer belongs to the three callers (two of which — `coins_screen.dart`, `token_info_screen.dart` — this plan does not touch), and a second control for the same action on the same screen is exactly the duplication D-06's "copy only" instruction exists to avoid. This is a decision on the record, not an omission.
- **Token pair for the sketch's `gap: 6px 10px`.** The 4-pt spacing scale has no 10px step (`space4`=8, `space6`=12). Read `genius_wallet_consts.dart` per the plan's own instruction and picked `space4` (8px, closest to 10) for the horizontal `spacing` and `space3` (6px, the scale's one documented half-step) for the vertical `runSpacing` — exact for the row-gap half of the CSS `gap` shorthand.
- **The More Options drawer needed zero changes.** Measured, not assumed (D-09's explicit instruction): its `Column` body carries no ad-hoc inset today, so the shared body inset from `responsive_drawer.dart` is already all it has. No fifth pattern invented.
- **No shared chunking helper extracted** with `transaction_displays.dart`'s `_valueChunks`. Two call sites is below the Rule of Three floor, and the two solve genuinely different shapes (a wrapping panel vs. a fixed 380px table row that must elide). Per the plan's explicit refusal, this was not extracted, not imported, and no flag was added.

## Deviations from Plan

### Auto-applied dispatch override (not a Rule 1-4 deviation)

**1. This plan's own text says "Do not commit... Wave 1 runs four plans in parallel against one git index" and "Do NOT commit. Leave every change in the working tree."** The dispatch for this session explicitly overrides that: this is a SEQUENTIAL executor on the main working tree (worktree isolation disabled), and the dispatch instructs "you ARE the sequential executor and you DO commit." Followed the dispatch, not the plan text — each task was committed atomically as normal, matching the same override 21-03 and 21-04 recorded in their own summaries for the same reason.

No Rule 1-4 code deviations occurred. The plan's `<action>` blocks were followed as written, including the explicit "do not add a footer CTA" and "do not restyle More Options" instructions.

**Total deviations:** 1 (dispatch-level execution-mode override, consistent with 21-03/21-04 precedent). No auto-fixed bugs, no added functionality beyond what the plan specified.

## Issues Encountered

None. The Wrap-based emphasis test needed an added `tester.pump(const Duration(seconds: 3))` after each clipboard-copy tap to flush the widget's own 2-second "Copied" reset `Future.delayed` before tree disposal — this is a test-authoring detail (the same pattern `transaction_receipt_copy_test.dart` already uses elsewhere in the suite for its own SnackBar timing), not a plan deviation.

## User Setup Required

None - no external service configuration required.

## Human Verification (OUTSTANDING)

The executor did not launch the app (constraint: `do_not_launch_the_app`). None of the following may be marked PASS by this plan; they are recorded verbatim for a live walk:

- [ ] Dashboard → wallet card → **Receive**. The title reads "Receive". The network chip sits above the QR with a real gap under the header — **not** a 150px hole and not pushed below the fold. Resize the window tall and short and confirm the gap does not scale with it.
- [ ] Read the address out loud in groups of four against the address shown on the wallet card. Every character must be present; the first two and last two groups must be visibly brighter and heavier than the middle.
- [ ] Tap the address block. It says "Copied" and reverts after ~2s. Paste somewhere: the **full** 42-character address, not a truncated form.
- [ ] Scan the QR with a phone camera in **dark** mode, then again in **light** mode. Both must resolve.
- [ ] Coins list (empty-wallet footer) → **Receive**, and Coin page → **Receive**. All three receive drawers must now look identical apart from their titles.
- [ ] Dashboard → **More** → confirm the body's left edge lines up with the title's left edge and nothing is double-inset. Nothing else about it should have changed.
- [ ] Repeat the address block in **light** mode — the emphasis contrast between the outer and middle groups is where light mode has historically broken.
- [ ] Narrow below 768 so all three become bottom sheets; confirm the address still wraps cleanly and the QR is fully visible.

## Next Phase Readiness

- All three D-06 receive call sites now converge on one `CryptoAddressQR` implementation with no per-caller wrapper. Plan 21-06 (if it exists) or the phase's final verification can proceed without re-checking these three files for the fractional-height/wrapper defect class.
- Gates at completion: `flutter analyze` 0/0 (root + `packages/genius_api`, verified via real exit code, not piped through `tail`); `flutter test --no-pub` **758/758** (754 baseline + 4 new); `check_brace_style.sh` 0; `check_raw_colors.sh` 0; `check_no_new_key_logging.sh --scan-tree` OK; `check_onboarding_seed_safety.sh` PASSED; `dart format --set-exit-if-changed` exit 0.
- Human visual walk OUTSTANDING (no live app instance this session) — checklist above.

## Self-Check: PASSED

- FOUND: `lib/components/qr/crypto_address_qr.dart`
- FOUND: `lib/components/wallet_information.dart`
- FOUND: `test/components/crypto_address_chunks_test.dart`
- FOUND: `.planning/phases/21-drawer-language-rollout-the-four-decided-drawer-designs-appl/21-05-SUMMARY.md`
- FOUND commit `69fcdd3` (Task 1)
- FOUND commit `1c65c62` (Task 2)

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*
