---
phase: 19-feedback-tab-redesign-sketch-150-variant-d
plan: 01
subsystem: feedback-tab
status: complete
tags: [feedback, logs, submit-logs, sentry, re-skin, sketch-150, variant-d]
requires:
  - GWPageHeader, GWCard, GWButton (primary + gradientOutline) primitives
  - GWColors / GeniusWalletColors / GeniusWalletConsts / GeniusWalletTypography tokens
  - GeniusApi (isSdkInitialized, jsonFilePath) + Sentry.captureFeedback
provides:
  - Feedback tab re-skinned onto the shared shell (sketch 150 variant D · Guided receipt)
  - FeedbackType enum + attachmentDispositionFor/attachmentNameFor pure helpers
affects:
  - lib/logs/submit_logs_screen.dart
tech-stack:
  added: []
  patterns:
    - "Pure Flutter-free top-level helpers imported directly by a plain flutter_test file (markets_sort_test idiom)"
    - "Single disposition helper is the source of truth for BOTH the send path and the Ready-state receipt chips"
key-files:
  created:
    - test/logs/submit_logs_feedback_test.dart
  modified:
    - lib/logs/submit_logs_screen.dart
decisions:
  - "feedback_type IS wired (scope.setTag beside source/platform) — the one honest new dimension"
  - "Segment active label uses gw.textPrimary (not brand mint) so the mint-tinted active holds WCAG AA in both themes; the mint identity comes from the fill + border"
  - "Success CTA copy trimmed to 'Feedback sent.' on the status line; the full Success state owns the check badge + Reference number + Send another"
metrics:
  completed: 2026-07-24
status-note: "No commits created (session is a design/executor run in the MAIN tree with commits gated)."
---

# Phase 19 Plan 01: Feedback tab redesign (sketch 150 variant D) Summary

Re-skinned the Feedback tab (`/logs` → `SubmitLogsScreen`, "Send Feedback") from a bare Material form onto the shared shell as sketch 150 variant D · Guided receipt — a centered `GWPageHeader` + `.surf` `GWCard` with a Bug/Idea/Question chooser, an honest auto-attach receipt row, and the brand CTA — while preserving the `Sentry.captureFeedback` mechanic exactly and adding one honest dimension (`feedback_type` tag).

## What shipped

**Task 1 — pure helpers + wiring + runnable check**
- Added Flutter-free top-level declarations above the widget: `enum FeedbackType { bug, idea, question }` with `tag` (`'bug'|'idea'|'question'`), `label`, and a distinct `placeholder` per kind; `enum AttachmentDisposition { whole, tail, skipEmpty }` + `attachmentDispositionFor({size, maxBytes, payloadLength})` and `attachmentNameFor(name, disposition)`.
- Refactored the `_submitFeedback` per-file loop to route through those helpers with zero behavior change (same 1 MiB threshold, same `_readTailBytes` tail read, same 0-byte skip, same `<name>.tail.log` naming, same `SentryAttachment.fromUint8List(contentType:'text/plain')`).
- Added exactly one line inside the existing `withScope` block: `scope.setTag('feedback_type', _selectedType.tag)` beside `source`/`platform`. Every other tag/context/attachment is byte-identical.
- Created `test/logs/submit_logs_feedback_test.dart` (plain `flutter_test`, no pump/Hive/fixtures) asserting the tag map, distinct labels/placeholders, whole/tail/skipEmpty, and the tail rename.

**Task 2 — build() onto the shared shell (Ready state)**
- `Align(topCenter)` → `SingleChildScrollView(fromLTRB(16, space32, 16, 16))` → `ConstrainedBox(maxWidth: GeniusBreakpoints.small = 640)` → `Column` with `const GWPageHeader(title: 'Send Feedback')` then a single default-`.surf` `GWCard`.
- Card body order (D-01): Bug/Idea/Question segmented chooser (mint-tinted active fill/border, label on the primary text ladder for AA) → locked subtitle → `TextField` (minLines 4 / maxLines 8 / `maxLength: 2000`, hint driven by `_selectedType.placeholder`) → receipt row → `Divider(gw.borderSubtle)` → status line + `GWButton` primary "Send feedback".
- Receipt row (D-03): header "SDK logs attached automatically" + hint "last 1 MB of each, empty ones skipped", then a `Wrap` of chips built from `_probeAttachments()` (run in `initState`, re-run on reset) that lists the same two candidate logs, reads each length, and asks `attachmentDispositionFor` what would happen — each log chip shows `name  <size MB/KB>` with a `TAIL` badge when tail-trimmed and struck "skipped (empty)" when zero-byte. Plus neutral meta chips `SDK Running/Stopped` (green dot when running) and the platform (`Platform.operatingSystem`, e.g. macOS). No file picker.

**Task 3 — the 6 honest states**
- Ready (chooser + field enabled, neutral status, CTA enabled), Sending (`isLoading`, "Sending feedback with N log attachment(s)…" / "…without SDK log attachments"), Success (check badge + "Feedback sent" + sub + **"Reference number"** value + Copy + hint + `GWButton(gradientOutline)` "Send another" with `Icons.refresh` that resets to Ready and re-probes), No-SDK (receipt shows "Attachments unavailable - SDK stopped", CTA disabled via `_canSend`, dedicated neutral note), and the two distinct failures kept as separate strings — `Failed to send feedback: <e>` vs the more-specific empty-event-ID message. Failure lines render in `gw.statusError`; the composer stays intact so the user can retry without losing their message.

## Deviations from Plan

- **[Rule 3 - blocking] `const BoxDecoration` on the success check badge failed `invalid_constant`.** `GeniusWalletColors.brandSecondaryMuted` is a runtime `withAlpha(61)` value, not a compile-time const. Dropped `const` on that one decoration (commented why). No behavior impact.
- **Layout: `SingleChildScrollView` instead of a bare `ConstrainedBox`.** The card is now taller than the old form (chooser + receipt + states); scroll prevents clipping on a short window or with the keyboard up. Same topCenter + space32 gap, so the sibling-tab framing is unchanged.
- **Copy control label snackbar** changed from "Copied Sentry event ID." to "Copied reference number." to match the locked "Reference number" language (plan left the copy wording discretionary).

## Non-negotiable mechanic — preserved

`Sentry.captureFeedback(SentryFeedback(message:))`, `scope.level = warning`, `source`/`platform` tags, `feedback`/`sdk_logs` contexts, `scope.addAttachment(...)` per prepared attachment, whole-≤-1 MiB / tail-else / skip-empty, and the two distinct unhappy results are all unchanged (M-01). Only additions: the `feedback_type` tag (fixed enum, never free text — T-19-03) and the receipt row (which reduces surprise, T-19-01).

## Verification

- `flutter analyze lib/logs/submit_logs_screen.dart test/logs/submit_logs_feedback_test.dart` → **No issues found!**
- `flutter test test/logs/submit_logs_feedback_test.dart` → **+5 All tests passed!** (pure file, no Hive — did not contend on the app's container lock; `flutter run` and the full suite were NOT run, per session constraint).

## Scope

Touched only `lib/logs/submit_logs_screen.dart` and its new test. No `gw_*` primitive, token, navbar, `lib/web/*`, other tab, or planning file (outside phase 19) was modified. No git commits created (session rule).

## What a human should walk (debug build, executor/human only)

1. Open `/logs` — confirm it reads as a sibling of Transactions/Markets/News: navbar active-tab gradient underline, 28px "Send Feedback" title, space32 navbar→title gap, `.surf` card.
2. Toggle Bug/Idea/Question — the message-field placeholder swaps; confirm `feedback_type` lands in Sentry (or via the one-line tag wiring).
3. Receipt row shows real log chips (name + MB size), a `TAIL` badge on any over-1 MB log, and `SDK Running/Stopped` + platform meta chips.
4. Cycle all 6 states: Ready, Sending (N-count), Success (Reference number + Copy + Send another gradient-outline + refresh), No-SDK (send disabled, attachments unavailable), Failed-exception, Failed-emptyId (two distinct messages).
5. Light mode: confirm the mint-tinted active segment + chips + status colors still hold AA (defer any light-only-specific issue to the app-wide light pass).

## Self-Check: PASSED
- `lib/logs/submit_logs_screen.dart` — FOUND (analyzes clean)
- `test/logs/submit_logs_feedback_test.dart` — FOUND (5 tests pass)
- No commits expected/made (session rule); nothing to verify in git log.
