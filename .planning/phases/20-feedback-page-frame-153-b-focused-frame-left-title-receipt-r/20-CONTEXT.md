# Phase 20 Context: Feedback page frame - 153-B "Focused frame"

**Source:** sketch session 2026-07-26 (variant chosen by Jakub in-conversation, no separate
discuss-phase run). Design artifact: `.planning/sketches/153-feedback-page/` (winner **B · Focused
frame**; the README carries the code-grounded findings and the full "pantry" inventory).
**Predecessor:** Phase 19 (150-D) built the **card**. This phase builds the **page** around it.

## Domain

`lib/logs/submit_logs_screen.dart` only. Today the composer sits in a 560px `Center(ConstrainedBox)`
inside an `xxl` (1536) page frame, with the title pushed inside that column (`centered: true`), leaving
roughly 430px of dead page on each side. 153-B narrows the **frame** instead of the content, puts the
title back on the frame's left edge like Transactions / Markets / News, and fills the width beside the
composer with a receipt rail built from data the screen already computes.

## Locked decisions

1. **Layout = 153-B · Focused frame.** Page frame `ConstrainedBox(maxWidth: GeniusBreakpoints.xxl)`
   (`:416`) becomes **`GeniusBreakpoints.large`** (1024). Use the existing token - 640 + `space10`
   (20) + 360 = 1020 fits. **Do not introduce a new 1040 constant**; the sketch's 1040 is a mockup
   number.
2. **Title returns to the left.** Delete the `Center(ConstrainedBox(maxWidth: 560))` wrapper and the
   `centered: true` argument (`:430-441`) so `GWPageHeader` renders its default left-aligned form
   directly inside the frame's `Column(crossAxisAlignment: stretch)`. Subtitle text unchanged.
3. **Two columns above ~1020px content width, stacked below.** `LayoutBuilder`:
   `Row(crossAxisAlignment: start, children: [SizedBox(width: 640, child: GWCard(composer)),
   SizedBox(width: space10), Expanded(child: GWCard(rail))])`; narrow → `Column` with the rail under
   the composer, both full width.
4. **New receipt rail.** The same probe data as key/value rows, not chips: file name + friendly size,
   `TAIL` badge on a tail-trimmed file, struck-through `skipped` for an empty one, `SDK Running` /
   `SDK Stopped`, platform string, plus the note "Only the last 1 MB of each log is read, so large
   files stay light. Empty logs are skipped." No-SDK state keeps SDK + platform rows and swaps the
   note for the warning-toned "Logs are collected by the SDK. Start it and they attach here
   automatically."
5. **The chip strip leaves the composer.** `_buildReceipt` (`:596-659`) and its `_logChip` /
   `_metaChip` helpers are replaced by the rail; their content moves, it is not duplicated in both
   places.
6. **Failed-state footer fix is IN scope.** The status line and the send button share one `Row` with
   `crossAxisAlignment: center` (`:511-530`). The empty-event-ID message (`:359`) is ~130 characters
   and wraps to several lines in a 640 column, leaving the button floating mid-block. Fix it; the
   sketch's A/C/D variants show the shape (status on its own line above the action).
7. **Copy is unchanged.** Every user-visible string in this screen was locked in Phase 19 and walked
   on 2026-07-25. Short hyphens only, no em dashes. The rail's own labels ("What gets sent", "SDK",
   "Platform") follow the same rule.

## Non-negotiable mechanic (preserve exactly - Phase 19 verified all of it)

- `Sentry.captureFeedback(SentryFeedback(message))` at `scope.level = warning`; tags `source`,
  `platform`, `feedback_type`; contexts `feedback` / `sdk_logs`; `scope.addAttachment(...)`.
- Auto-attach `sgnslog.log` + `sgnslog2.log` from `geniusApi.jsonFilePath`: whole if ≤ 1 MiB, else
  tail-trim via `_readTailBytes` → `<name>.tail.log`; **empty files skipped**. The user never picks
  files.
- `!geniusApi.isSdkInitialized` No-SDK guard as its own state, send disabled.
- The **two distinct** unhappy results stay distinct: thrown exception vs empty `SentryId`.
- `_probeAttachments` / `attachmentDispositionFor` / `attachmentNameFor` / `_friendlySize` /
  `FeedbackType` keep their current signatures - the four pure helpers are what
  `test/logs/submit_logs_feedback_test.dart` tests.

## Findings that constrain the design

- **`_candidateLogNames` (`:97`) is a two-element const.** The rail can therefore show at most two log
  rows: four rows with the SDK running, two with it stopped. Size it for that; do not build it as a
  list that grows.
- Nothing persists `_lastEventId` beyond the session, and there is no feedback history anywhere in the
  app. **No variant may add a "recent reports" surface** - it would be fiction.

## Scope fence

- **ONLY** `lib/logs/submit_logs_screen.dart` and its test.
- **Do NOT touch `lib/squid_router/swap_screen.dart`.** Swap's own `centered: true` is Phase 8's call.
- **Do NOT remove the `centered` parameter from `GWPageHeader`.** It is additive, it stays, and
  `test/components/gw_page_header_centered_test.dart` must keep passing untouched.
- Do not modify shared `gw_*` primitives, tokens, the navbar or any other tab.
- Light mode: dark-first per project rule; do not stall on light-only issues.

## ⚠ Reverts an uncommitted in-tree change

`centered: true` at `submit_logs_screen.dart:440` was added by a parallel session on 2026-07-26 and is
recorded as a deliberate call in `.planning/HANDOFF-swap-feedback-header-and-coin-sketches.md`. Jakub
chose 153-B on 2026-07-26 with that conflict on the table. Removing it **for this screen** is the
phase's job; the flag itself and every other caller stay.

## Success criteria

- At a wide window the page reads as one frame: title on the frame's left edge at the same X as the
  composer card, composer and rail side by side, no dead band wider than the page margin.
- Below the breakpoint the rail stacks under the composer and nothing overflows.
- All five states still render honestly (Ready / Sending / Success / No-SDK / Failed), and the two
  Failed messages stay distinct.
- The rail is honest at both ends: two log rows maximum, and the No-SDK state says why there are none.
- The Failed footer no longer leaves the button floating beside a multi-line status.
- `flutter analyze` clean on the touched file; `test/logs/submit_logs_feedback_test.dart` and
  `test/components/gw_page_header_centered_test.dart` pass **unchanged**.
- **One new runnable check**: a widget test proving two columns at a wide width, one column narrow,
  and the title on the frame's left edge. Follow the arithmetic-on-geometry idiom of
  `gw_page_header_centered_test.dart` - no goldens, no new fixtures.

## Claude's discretion

- Whether the rail is a private widget or an inline builder; the exact breakpoint constant used inside
  `LayoutBuilder`; the row/label decomposition inside the rail - match the idioms already in this file
  and in `transactions_screen.dart`.
