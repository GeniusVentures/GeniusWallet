---
phase: 20-feedback-page-frame-153-b-focused-frame-left-title-receipt-r
verified: 2026-07-27T19:07:14Z
walk_performed: 2026-07-30
status: passed
closed_by: developer-walk
score: 6/8 verified automatically; the layout walk closed 2026-07-30; 2 behavior items remain unexercised
behavior_unverified: 2
overrides_applied: 0
resolution_2026_07_30:
  summary: >
    The human walk this report was blocked on was performed by the developer on 2026-07-30 against a
    Windows build of `3017f9f`, and every item reached passed. The layout questions — the ones the
    widget test could establish geometrically but not judge — are now closed. The two behaviour items
    below are NOT closed by this walk and are not claimed to be.
  closed_by_the_walk: >
    The frame reads as one frame at maximised width (title on the frame's left edge at the same X as
    the composer, rail beside it, no leftover band reading as a hole rather than a margin); the rail
    drops under the composer through the ~1020 seam without overflow, RenderFlex stripe or clipped
    row; and the five-state composer flow (chooser / message / send / Success + Copy / Send another)
    still behaves as Phase 19 left it, now inside Phase 20's new frame. The widget test already
    pinned cap=1024, title.dx == composer.dx and card levelling — what it could not do was judge
    whether the leftover space reads as margin, which is the question the walk answered.
  still_unexercised: >
    Both original `behavior_unverified_items` stand, unchanged and unclaimed. (1) The SDK-RUNNING
    branch of `_buildRail` — the `probes != null && probes.isNotEmpty` loop that renders per-probe
    rows — has still never been rendered by any check, automated or human, that this repository has a
    record of; the widget test cannot reach it because `_StoppedSdkApi` always returns
    `isSdkInitialized=false`. (2) The Failed-state footer with its real ~130-character message,
    reachable only via a live Sentry round-trip that throws or returns an empty `SentryId`; test 3
    proved the arrangement with a 78-character stand-in on the same unconditional code path.
  honest_limit: >
    The walker did not enumerate which items were reached, so this records "every item reached
    passed", not "all five were exercised". Items 3 and 4 above require conditions (a running SDK; a
    failing Sentry round-trip) that were not confirmed during the walk. Do not later read this
    closure as coverage of the SDK-running rail.
behavior_unverified_items:
  - truth: "The rail shows at most two log rows plus SDK and Platform, and says why there are no log rows when the SDK is stopped (D-04)."
    test: "Run the app with the SDK actually running and at least one of sgnslog.log / sgnslog2.log present on disk (one whole, one tail-trimmed or empty), then read the rail."
    expected: "Exactly one _railRow per probe (max 2), each showing file name + friendly size, a TAIL badge on the trimmed one, struck-through 'skipped (empty)' on the empty one, followed by SDK / Running and Platform / <os>, followed by the 1MB note."
    why_human: "The widget test's only reachable state is SDK-stopped (_StoppedSdkApi always returns isSdkInitialized=false), so the probes!=null / probes.isNotEmpty branch of _buildRail — the loop that actually renders per-probe rows — has never been exercised by any automated check. The code path is present and reads correctly by inspection, but no test proves it renders without truncation/overflow at the rail's minimum width (360)."
  - truth: "All five states still render (Ready / Sending / Success / No-SDK / Failed) and the two Failed messages stay distinct."
    test: "Drive the composer through Sending -> Success (real Sentry round-trip) and through both Failed variants: (a) throw before/within capture, (b) force an empty SentryId back."
    expected: "Success renders the reference number + Copy + Send another; both Failed variants show their own distinct statusText, right-aligned button below it, never beside a multi-line block."
    why_human: "_submitFeedback's state machine is unchanged and frozen by this phase's anti-goals (confirmed: test/logs/submit_logs_feedback_test.dart is a zero-line diff and still passes), and Phase 19 walked all five states before this phase's layout rewrite — but no automated test and no confirmed fresh walk has driven Sending/Success/Failed through the NEW Column+Align footer and the NEW two-column frame. The 130-character empty-event-ID message — the one D-06 was fixed for — has still never actually been rendered by anyone."
gaps: []
human_verification:
  - test: "Maximised window: compare the Feedback tab against Transactions in the same window."
    expected: "The page reads as ONE frame — title on the frame's left edge at the same X as the composer card, rail beside the composer, no leftover band wider than a page margin."
    why_human: "Whether unused space 'reads as margin' vs 'reads as a hole' is a visual judgment; the widget test proves the geometry (cap=1024, title.dx==composer.dx, cards level) but not how it looks."
  - test: "Drag the window narrow, at and around the ~1020 content-width seam."
    expected: "The rail drops under the composer; nothing overflows, no red RenderFlex stripe, no clipped rail row. Check sgnslog2.log + TAIL + size specifically at the rail's narrowest width (360)."
    why_human: "The widget test proves the stacked geometry and asserts tester.takeException() is null at width 1000, but does not prove legibility of a real (non-stub) file name + size + TAIL badge combination at the rail's actual minimum width."
  - test: "The rail with the SDK running: at most two log rows, plus SDK Running and the platform, plus the 1MB note. The rail with the SDK stopped: no log rows, SDK Stopped, platform, amber-glyph note."
    expected: "Both ends of the rail read as honest, not abandoned or broken."
    why_human: "Same root cause as behavior_unverified_items #1 — the SDK-running branch of _buildRail has never been rendered by any check, automated or human, that this repository has a record of."
  - test: "The footer in the Failed state, reached via a live Sentry round-trip that either throws or returns an empty SentryId."
    expected: "The ~130-character message sits on its own full-width line, the send button sits below it and to the right — never floating beside a multi-line block."
    why_human: "Test 3 proves the arrangement using the No-SDK state's 78-character message as a stand-in (the arrangement is unconditional, single code path — confirmed by reading _buildComposer, no per-state branching in the footer), but the actual 130-character message this fix targets has never rendered in front of anyone since D-06 shipped."
  - test: "Full five-state regression: chooser (all three types swap the placeholder), message field, send, Success (reference number + Copy), Send another -> back to Ready."
    expected: "Nothing Phase 19 verified has moved."
    why_human: "Phase 19's walk (2026-07-25) predates this phase's layout rewrite. The underlying state logic is untouched (anti-goals honored, confirmed by an empty diff on the pure-logic test file), but no walk record exists of these states rendering inside Phase 20's new frame/footer. The session's own .continue-here.md explicitly flags '20-VERIFICATION.md — not started; needs the human walk' and lists this among what remains unseen."
---

# Phase 20: Feedback page frame — 153-B "Focused frame" (left title + receipt rail) Verification Report

**Phase Goal:** Narrow the Feedback page frame from `xxl` (1536) to `GeniusBreakpoints.large` (1024),
return the page title to the frame's left edge (matching Transactions/Markets/News), lay the composer
(640) and a new receipt rail (>=360) side by side above ~1020 of content width and stacked below it,
retire the chip strip in favor of the rail, and fix the Failed-state footer so a long status message
can no longer strand the send button mid-block.

**Verified:** 2026-07-27T19:07:14Z
**Status:** human_needed
**Re-verification:** No — initial verification (no prior `20-VERIFICATION.md` existed).

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | At a window wider than the cap, the page content stops at `GeniusBreakpoints.large` (1024), not `xxl` (D-01) | ✓ VERIFIED | `submit_logs_screen.dart:430-432` — `ConstrainedBox(constraints: BoxConstraints(maxWidth: GeniusBreakpoints.large))`. `grep -c 'GeniusBreakpoints.large'` = 1; no `GeniusBreakpoints.xxl` reference remains in the file. Widget test 1 (`test/logs/submit_logs_page_frame_test.dart`) asserts `GWPageHeader` width `closeTo(GeniusBreakpoints.large, 1)` at a 2000px window (wider than the cap, so it actually binds). |
| 2 | The page title 'Send Feedback' starts at the same X as the composer card's left edge, left-aligned in the frame's `Column(stretch)` (D-02) | ✓ VERIFIED | `submit_logs_screen.dart:433-449` — `GWPageHeader` is the FIRST direct child of `Column(crossAxisAlignment: stretch)`; no `Center`/`ConstrainedBox(560)` wrapper, no `centered:` argument at this call site (`grep -c 'centered'` = 1, and that one hit is a code comment, not an argument). Test 1 asserts `getTopLeft('Send Feedback').dx == getTopLeft(composerCard).dx` within 0.5px. |
| 3 | At a frame content width of 1024 the composer card (640) and the receipt rail card sit side by side with level tops (D-03) | ✓ VERIFIED | `submit_logs_screen.dart:467-476` — `LayoutBuilder` inside the `ConstrainedBox`; wide branch (`constraints.maxWidth >= _twoColumnMin` = 1020) returns a `Row` with `SizedBox(width: _composerWidth=640)` + `space10` + `Expanded(rail)`. Test 1 (2000px window) asserts composer width `closeTo(640,1)`, `composerCard.right < railCard.left`, and level tops within 0.5px. |
| 4 | Below the two-column width the rail card sits under the composer card, both at the same left edge, and nothing overflows (D-03) | ✓ VERIFIED | `submit_logs_screen.dart:480-488` — narrow branch is a `Column(stretch)` of `[composer, gap, rail]`. Test 2 (1000px window, content 976 < 1020) asserts shared left edge, rail.top >= composer.bottom, both widths `closeTo(976,1)`, and `tester.takeException()` is null (catches `RenderFlex overflowed`). |
| 5 | The rail shows at most two log rows plus SDK and Platform, and says why there are no log rows when the SDK is stopped (D-04) | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `_buildRail` (`submit_logs_screen.dart:746-810`) is present and correctly structured by inspection: `!sdkReady` branch renders `'Logs' / 'Unavailable - SDK stopped'` (says why); `sdkReady && probes.isNotEmpty` branch loops `_candidateLogNames` (a 2-element const, so max 2 rows) via `_railRow`. Widget test only reaches the SDK-stopped branch (`_StoppedSdkApi.isSdkInitialized => false`); the multi-row, real-file-probe branch has never been exercised by any check. See `behavior_unverified_items`. |
| 6 | The chip strip is gone from inside the composer — the same facts appear exactly once, in the rail (D-05) | ✓ VERIFIED | `_buildReceipt`, `_logChip`, `_metaChip` do not exist anywhere in the file (`grep -c` = 0). `'Attached automatically'` (the rail's title, successor to 'What gets sent') appears exactly once (`grep -c` = 1). `_tailBadge` is defined once and called once from `_railRow` (`grep -c '_tailBadge'` = 2) — reused, not duplicated. |
| 7 | The send action sits below the status line, never beside a multi-line status block (D-06) | ✓ VERIFIED | `_buildComposer` (`submit_logs_screen.dart:597-610`) is a single, unconditional structure — `Text(statusText)` then `SizedBox(space8)` then `Align(centerRight, GWButton)` — with no per-state branching in the footer's shape (only `statusColor`/`statusText` vary). Test 3 proves `button.top >= status.bottom` using the No-SDK 78-char message; since the structure is unconditional (confirmed by reading the source, not merely asserted by the plan), this generalizes to the Failed state's 130-char message without a state-specific test. |
| 8 | All five states still render (Ready / Sending / Success / No-SDK / Failed) and the two Failed messages stay distinct | ⚠️ PRESENT_BEHAVIOR_UNVERIFIED | `_submitFeedback` (`submit_logs_screen.dart:244-392`) is byte-for-byte frozen per this phase's anti-goals — confirmed via `git diff --stat` empty on `test/logs/submit_logs_feedback_test.dart` (still 5/5 pure-logic tests, untouched) — and the two failure paths remain textually distinct (`:370-372` empty-SentryId vs `:383-386` thrown exception). Phase 19 walked all five states on 2026-07-25, but that walk predates this phase's frame/footer rewrite. No automated test and no confirmed fresh walk has driven Sending/Success/Failed through the NEW layout. See `behavior_unverified_items`. |

**Score:** 6/8 truths verified (2 present + wired, behavior not exercised)

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `lib/logs/submit_logs_screen.dart` | Modified — frame cap, left title, two-column `LayoutBuilder`, receipt rail, chip strip removed, footer fix | ✓ VERIFIED | Read in full; all six roadmap changes present and internally consistent (see truths above). `flutter analyze` reported clean by the executor and by the orchestrator's confirmed current gate (`flutter analyze lib` = 59, at/under the 61 baseline). |
| `test/logs/submit_logs_page_frame_test.dart` | New — the phase's one runnable check | ✓ VERIFIED | Exists, 4 `testWidgets` (3 planned + 1 added for the 064-B label-centering regression, an addition not a subtraction). Pumps the REAL `SubmitLogsScreen` via a `Provider<GeniusApi>` + `_StoppedSdkApi` stub, with `_surface`/teardown idiom copied from `transactions_page_frame_test.dart`. Not independently re-executed in this verification session (`flutter` is not on this shell's PATH); relying on the orchestrator-confirmed current gate (`flutter test` = 464 pass / 1 pre-existing unrelated failure) as the run-time evidence. |

### Key Link Verification

| From | To | Via | Status | Details |
|------|-----|-----|--------|---------|
| `LayoutBuilder` | frame's `ConstrainedBox` | nesting order | WIRED | `LayoutBuilder` is the second child of the `Column` that is itself the child of `ConstrainedBox(maxWidth: large)` — confirmed by reading lines 425-490; `constraints.maxWidth` inside the builder is therefore content width, not window width. |
| `_buildRail(gw, sdkReady)` | both `LayoutBuilder` branches | shared `rail` local | WIRED | `rail` is built once (line 462-465) before the `if`, and referenced in both the `Row` (wide) and `Column` (narrow) return branches — a rail built only in one branch would vanish in the other; it does not. |
| `GWPageHeader` | frame's `Column(stretch)` | direct child, no wrapper | WIRED | Confirmed no `Center`/second `ConstrainedBox` between them (lines 433-449). |
| `GWPageHeader(centered:)` | other callers | flag preserved | WIRED | `lib/squid_router/swap_screen.dart:622-625` still calls `GWPageHeader(..., centered: true)`; `gw_page_header.dart:15` still declares the `centered` field and branches on it. Only the Feedback call site stopped passing it. |
| `_tailBadge` | `_railRow` | reused, not duplicated | WIRED | Defined once (`:858`), called once from `_railRow` (`:840`) — `grep -c '_tailBadge'` = 2. |

### Behavioral Spot-Checks

Step 7b: **SKIPPED** — `flutter` is not reachable on this verification session's PATH (checked via `which`, `cmd.exe /c where flutter`, both empty). Relying instead on the orchestrator-confirmed current gate stated in the verification task: `flutter analyze lib` = 59 (baseline ≤61); `flutter test` = 464 pass / 1 known pre-existing failure (`test/local_wallet_storage_test.dart`, unrelated `main()`-less stub). Test-count sanity check performed statically instead: `grep -c "testWidgets("` on the three named files in the plan's Task 3 gate returns 5 (`submit_logs_feedback_test.dart`) + 2 (`gw_page_header_centered_test.dart`) + 4 (`submit_logs_page_frame_test.dart`, one more than the plan's original 3 — an addition for the 064-B label-centering regression, not a subtraction).

### Probe Execution

Not applicable — no `scripts/*/tests/probe-*.sh` referenced by this phase's PLAN or SUMMARY; this is a Flutter widget-test phase, not a migration/tooling phase.

### Anti-Pattern Scan

Scanned `lib/logs/submit_logs_screen.dart`, `lib/components/inputs/gw_focus_ring.dart`, `test/logs/submit_logs_page_frame_test.dart` for `TBD|FIXME|XXX|TODO|HACK|PLACEHOLDER|coming soon|not yet implemented`. The only case-insensitive hits are the `FeedbackType.placeholder` getter and its call site — a legitimate, pre-existing API name, not a stub marker. **No debt markers found.** No blockers.

### `.continue-here.md` Anti-Pattern Check (item 3 of the task)

The "rounding a value that is also an input" pattern flagged in `.continue-here.md` (`formattedBalance` renders full precision but MAX feeds that exact string into the amount field) is **not a Phase 20 concern** — it does not touch `lib/logs/submit_logs_screen.dart` at all. Checked its actual resolution status in the codebase per the task's own pointer: `lib/squid_router/models/squid_balance.dart` now has a `displayBalance` getter (line 94, read-only, rounded for display) separate from `formattedBalance` (line 53, exact, "Never for MAX" per its own doc comment at line 78-85). **The anti-pattern is structurally resolved**, and it was resolved elsewhere (Phase 8's domain), not by Phase 20 — Phase 20 never needed to touch it and didn't.

### Requirements Coverage

No requirement IDs are mapped to Phase 20 in `.planning/REQUIREMENTS.md` (no match for "Phase 20" or the phase directory name), and the PLAN frontmatter declares `requirements: []` — consistent with the ROADMAP's own line "Requirements: none new — this is a layout change to a shipped surface." No orphaned requirements found.

### Sketch/Bookkeeping Verification

- `.planning/sketches/153-feedback-page/README.md` frontmatter: `winner: "B"` — confirmed set (not `null`).
- `.planning/sketches/MANIFEST.md`: exactly one `| 153 ` row (`grep -c` = 1), recording winner B and Phase 20 as the shipping phase.
- `.planning/sketches/064-feedback-controls/README.md` (built mid-execution per Jakub's request): `winner: "B"` — confirmed, and its "Outcome" section names the exact 3px `brandCta` underline + `brandPrimaryStrong` glow (50%/blur 10, 200ms) + `GWDecorations.hover` recipe. Cross-checked against the actual code at `submit_logs_screen.dart:703-731` and `:671-680` — matches exactly, including the two named traps: the border-inset jitter (avoided — border present in both hover states, only its color changes, confirmed at lines 676-679) and the `Stack`-gives-loose-constraints label-centering bug (avoided — `SizedBox(width: double.infinity)` wraps the label, confirmed at line 687, and a dedicated 4th widget test proves each label's center aligns with its own `InkWell` segment within 1.0px).
- `.planning/sketches/MANIFEST.md`: exactly one `| 064 ` row, recording winner B and Phase 20.

## Gaps Summary

No blocking gaps. Every truth this phase set out to prove about **layout and geometry** is verified by
a passing, content-anchored widget test plus direct source-code inspection: the frame caps at `large`,
the title shares the composer's left edge, the two-column/stacked breakpoint behaves at 1020, the chip
strip is gone in favor of a single rail, and the Failed-footer fix is structurally unconditional (so
proving it in the reachable No-SDK state generalizes).

What remains unverified is **runtime behavior no automated check in this repository can reach without
a live SDK and/or a live Sentry round-trip**: the rail's SDK-running row list (the branch of `_buildRail`
that actually loops over real file probes), and the Failed state's actual 130-character message inside
the new footer. Both are the exact items the phase's own artifacts (`20-01-SUMMARY.md`'s "What the live
walk still owes" and `.continue-here.md`'s "20-VERIFICATION.md — not started; needs the human walk")
flag as outstanding — this verification does not manufacture new doubt, it declines to convert those
self-reported unknowns into an unearned `passed`. Per the task's own framing, this phase is judged the
same way Phase 9 was: `human_needed`, not `passed`, because a walk record is honestly absent rather than
because any code was found to be broken.

## Human Verification Required

See `human_verification` in the frontmatter (5 items, harvested from the PLAN's own `<human-check>`
block plus the two behavior-unverified truths above, deduplicated). Summary:

1. Maximised-window visual read ("one frame", not a hole) vs. Transactions.
2. Narrow-window seam behavior with a real (non-stub) file at the rail's minimum width.
3. The SDK-running rail state — never rendered by any check on record.
4. The Failed-state footer with the actual 130-character message — never rendered by any check on record.
5. A fresh five-state regression walk inside the new layout (Phase 19's walk predates this rewrite).

---

_Verified: 2026-07-27T19:07:14Z_
_Verifier: Claude (gsd-verifier)_
