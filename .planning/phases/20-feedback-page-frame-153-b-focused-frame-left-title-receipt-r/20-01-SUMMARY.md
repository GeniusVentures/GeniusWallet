---
phase: 20-feedback-page-frame-153-b-focused-frame-left-title-receipt-r
plan: 01
subsystem: ui
tags: [flutter, page-frame, breakpoints, layout-builder, feedback, sentry, gradient-underline, focus-ring]

requires:
  - phase: 19-feedback-tab-redesign-sketch-150-variant-d
    provides: "the composer itself - type chooser, message field, attachment probing, send path. Phase 20 changed the FRAME around it, not the form."
  - phase: 12-transactions-redesign
    provides: "test/dashboard/transactions_page_frame_test.dart - the page-frame test shape this plan's check copies, including the 800x600 harness-surface trap and its teardowns"
provides:
  - "lib/logs/submit_logs_screen.dart at sketch 153-B: frame capped at GeniusBreakpoints.large, title on the frame's left edge, 640 composer beside a >=360 rail, stacking below 1020"
  - "the receipt rail (_buildRail/_railRow) replacing the chip strip - the same facts, one per line, in a card beside the composer"
  - "lib/components/inputs/gw_focus_ring.dart - a GRADIENT focus ring, reusable; no InputBorder can be one"
  - "the feedback type chooser carrying the nav bar's active-tab language (sketch 064-B): 3px brandCta underline + glow, GWDecorations.hover on inactive segments"
  - "test/logs/submit_logs_page_frame_test.dart - 4 checks that pump the REAL screen, not a replica"
affects: [21-drawer-language-rollout, any-future-page-frame-work]

tech-stack:
  added: []
  patterns:
    - "LayoutBuilder INSIDE the frame's ConstrainedBox, never outside it: the two-column decision is a property of the CONTENT width, so measuring the window makes the breakpoint wrong by exactly the gutters."
    - "A borderless field must silence all FOUR InputDecoration border states. theme.dart:242 sets an app-wide focusedBorder and a per-state border always beats the `border` fallback."
    - "Hover that changes only a border COLOUR, never its presence. A BoxDecoration carrying a border insets its child, so animating none->1px twitches the content by exactly the border width."
    - "A gradient accent is a sibling layer (DecoratedBox / Positioned strip), not a BorderSide - BorderSide takes a single Color."

key-files:
  created:
    - test/logs/submit_logs_page_frame_test.dart
    - lib/components/inputs/gw_focus_ring.dart
  modified:
    - lib/logs/submit_logs_screen.dart

key-decisions:
  - "Frame capped at GeniusBreakpoints.large (1024), not xxl (1536). A feedback form has one column of real content; 1536 stranded the composer in the middle of a wide window."
  - "Two-column threshold is _composerWidth + space10 + _railMinWidth = 1020, expressed as a computed constant rather than a literal, so the rail's minimum width and the composer's width cannot drift apart from the threshold that depends on them."
  - "Feedback type chooser = sketch 064 variant B (gradient underline), chosen by Jakub. The old control broke two standards at once: no hover at all (sketch 044 declares one app-wide recipe) and a FLAT mint accent, while drawers-final rules the accent is the gradient."
  - "The Message label moved ABOVE the field. Not taste: GWTextField - the app's own component, used across 7 files - renders labels that way. Feedback used a raw TextField(labelText:), which picks up theme.dart's floatingLabelBehavior: always and notches the label into the outline."
  - "'What gets sent' renamed to 'Attached automatically'. Carries the one thing the user cannot know - that they need do nothing - recovering the sense of the deleted 'SDK logs attached automatically' header without the word SDK, which means nothing to someone reporting a bug."
  - "GWFocusRing rather than an InputBorder. It also reserves its 1.5px in BOTH states, so taking focus never nudges the content it surrounds."
  - "Executed WITHOUT commits (Jakub's call, over the with-commits option). CLAUDE.md forbids them and the tree carried three sources' uncommitted work; an atomic commit would have swept up files this plan does not own."

patterns-established:
  - "Page-frame check pumps the REAL screen. A hand-copied replica cannot fail for the reason the file exists - swapping the cap back to xxl would leave a replica green because no test would ever read submit_logs_screen.dart."
  - "Centring asserted against the label's OWN segment, not against a computed fraction of the strip. The segment is the box the underline spans, so that is the thing that actually has to line up."

requirements-completed: []

coverage:
  - id: D1
    description: "Page frame at sketch 153-B: cap at GeniusBreakpoints.large, title on the composer's left edge, 640 composer with the rail beside it above 1020 of content width and stacked below it"
    verification:
      - kind: unit
        ref: "test/logs/submit_logs_page_frame_test.dart - 'the frame caps at large, the title sits on its left edge, and the rail sits beside the composer' + 'below the two-column width the rail stacks under the composer'"
        status: pass
    human_judgment: false
  - id: D2
    description: "Receipt rail replaces the chip strip - _buildRail/_railRow added, _buildReceipt/_logChip/_metaChip deleted, _tailBadge kept and reused"
    verification:
      - kind: unit
        ref: "test/logs/submit_logs_page_frame_test.dart - the rail card is found by its 'Attached automatically' title, so a deleted rail fails every geometry assertion in the file"
        status: pass
    human_judgment: false
  - id: D3
    description: "Failed-state footer: status line and send button unstacked from one Row, so a 130-character Sentry message can no longer park the button mid-block"
    verification:
      - kind: unit
        ref: "test/logs/submit_logs_page_frame_test.dart - 'the send action sits below the status line, never beside it' (proved in the No-SDK state; the arrangement is unconditional)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Feedback type chooser on sketch 064-B: gradient underline with glow, hover on inactive segments, labels centred in their own segments"
    verification:
      - kind: unit
        ref: "test/logs/submit_logs_page_frame_test.dart - 'the type labels are centred in their segments'"
        status: pass
      - kind: manual_procedural
        ref: "Jakub's walk 2026-07-27 - four issues raised and fixed (hover twitch, labels not centred, bottom spacing, placeholder reading as typed text)"
        status: pass
    human_judgment: true
    rationale: "The underline glow, the hover feel and the placeholder's grey-italic weight are judged by eye in a running app; no assertion captures 'reads as a placeholder rather than typed text'."
  - id: D5
    description: "GWFocusRing - a gradient focus ring wired into the feedback message field (and, in the same session, the Swap amount card, the slippage field and the token search)"
    verification:
      - kind: manual_procedural
        ref: "Jakub's walk 2026-07-27 - confirmed the ring lights on focus and the content does not shift"
        status: pass
    human_judgment: true
    rationale: "A gradient's presence is assertable; that it reads as a focus affordance rather than a decoration is not."
---

## Accomplishments

**Task 1 - the check, written first and watched fail.** `test/logs/submit_logs_page_frame_test.dart`
went RED for three correct reasons before a line of the screen changed: the header measured **560**
where the plan wants 1024, the rail-title finder found **zero** widgets, and the send button sat at
x=758 beside a status line ending at x=842.

**Task 2 - the focused frame.** Frame cap `xxl` -> `GeniusBreakpoints.large`. `GWPageHeader` became a
direct child of the stretching `Column` - no `Center`, no `centered: true` - so the title lands on the
composer's left edge rather than the middle of the window. The `LayoutBuilder` moved INSIDE the
`ConstrainedBox` so it measures content, not window. `_buildRail` / `_railRow` added; `_buildReceipt`,
`_logChip` and `_metaChip` deleted; `_tailBadge` kept and reused by the rail.

**Task 3 - the footer.** Status line and send button were one `Row`; a 130-character Sentry failure
message parked the button mid-block. Now a `Text` followed by `Align(centerRight, GWButton)`.

**Beyond the plan, at Jakub's direction.** Sketch 064 (feedback controls) was built and variant **B**
chosen; the type chooser now carries the nav bar's exact active-tab language. `GWFocusRing` was
written and wired. The Message label moved above the field. The rail title was renamed.

### Final rail row order, per SDK state

The two tail rows are unconditional; only the head varies.

| SDK state | rows, in order |
|---|---|
| stopped | `Logs / Unavailable - SDK stopped` · `SDK / Stopped` · `Platform / <os>` |
| probing | `Logs / Checking...` · `SDK / Running` · `Platform / <os>` |
| running, nothing found | `Logs / None found yet` · `SDK / Running` · `Platform / <os>` |
| running, files found | one row per probe (`<fileName> / <size>`, or `skipped (empty)` struck through, with a tail badge when the file is tailed) · `SDK / Running` · `Platform / <os>` |

Under the rows, a `bodySm` secondary footnote: *last 1 MB of each, empty ones skipped*.

### Footer arrangement chosen

Status `Text` on its own line, then `Align(alignment: centerRight)` holding the `GWButton`. Rejected
the alternative of keeping the `Row` and wrapping the status in `Expanded`: it keeps the button
vertically centred against a block whose height depends on the message, which is the defect in a
subtler form.

## Task Commits

None. This phase executed **without commits** by Jakub's explicit choice - see the key decision
above. Every change is in the working tree.

## Gates (actual output)

```
$ flutter analyze lib/logs/submit_logs_screen.dart test/logs/submit_logs_page_frame_test.dart
Analyzing 2 items...
No issues found! (ran in 4.1s)

$ flutter test test/logs/ test/components/gw_page_header_centered_test.dart
00:01 +11: All tests passed!
```

Whole-suite gate at the end of the session: `flutter analyze lib` = **59** (baseline <= 61) ·
`flutter test` = **323 pass / 1 fail**. The single failure is
`test/local_wallet_storage_test.dart`, a `main()`-less stub inherited from the baseline and untouched
by this phase.

## What the live walk still owes

Jakub walked the Feedback page on 2026-07-27 and raised four issues, all fixed and hot-reloaded. Not
yet seen by anyone:

- **The SDK-running rail rows.** Every test pump has the SDK stopped, so the rail shows its "no logs"
  reason rather than the two probe rows. Reaching the running state needs a real SDK, a real base
  path and files on disk.
- **The Failed status string.** Needs a live Sentry round-trip. Test 3 proves the arrangement in the
  No-SDK state instead; the arrangement is unconditional, so proving it once proves it for Failed -
  but the 130-character message itself has still never been rendered.
- **Light mode.** Deferred per the standing dark-mode-first decision.
- **The send path itself.** Untouched by this phase and unexercised by it.

## Deviations

| Plan said | Shipped | Why |
|---|---|---|
| "Exactly one source file under `lib/` changed" | two: `submit_logs_screen.dart` plus the new `lib/components/inputs/gw_focus_ring.dart` | Jakub asked mid-execution for a gradient focus ring. A `BorderSide` takes a single `Color`, so this could not be a theme change; it had to be a widget. Put in `components/inputs/` rather than inline because the same session wired it into three Swap fields. |
| the plan scoped the FRAME only | the type chooser and the message field's label/placeholder also changed | Requested by Jakub during the walk, backed by sketch 064-B (his pick) and by `GWTextField`'s existing label convention. Recorded as a decision above rather than smuggled in. |
