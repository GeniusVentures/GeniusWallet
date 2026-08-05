# Phase 19 Context: Feedback tab redesign (sketch 150 variant D)

**Source:** sketch session 2026-07-24 (design locked with Jakub) + `.planning/todos/pending/2026-07-24-phase-19-feedback-tab-redesign.md`. Design artifacts: `.planning/sketches/150-feedback-tab/` (winner D + `cta-options.html` + `send-another-options.html`).

## Domain

Port `SubmitLogsScreen` (`/logs`, titled "Send Feedback") from a bare Material form onto the shared
shell so it reads as a first-class sibling tab (Transactions/Markets/News). Single target file:
`lib/logs/submit_logs_screen.dart`. Uses existing `gw_*` primitives (`GWPageHeader`, `GWButton`,
`GWCard`) and design tokens (`GWColors`, `GeniusWalletGradient`, `GeniusWalletConsts`).

## Locked decisions

1. **Layout = variant D · Guided receipt** — one centered column (~640px `ConstrainedBox`, `topCenter`
   like `swap_screen.dart`), `GWPageHeader(title:'Send Feedback')` + a `.surf` card containing, in order:
   Bug/Idea/Question chooser → message field (maxLength 2000) → "SDK logs attached automatically"
   receipt row → divider → status line + send CTA.
2. **Type chooser IS built** — Bug / Idea / Question segmented control (app's segmented language,
   mint-tinted active). Wire `scope.setTag('feedback_type', 'bug'|'idea'|'question')` beside the
   existing `source`/`platform` tags in `_submitFeedback`. Chooser also swaps the field placeholder.
3. **Receipt row** (the transparency): log chips `sgnslog.log 312 KB`, `sgnslog2.log 1.0 MB · TAIL`
   plus neutral chips `SDK ● Running` and platform (`macOS`) — all from data the code already computes
   (`fileSizesByName`, `_readTailBytes`, `isSdkInitialized`, `Platform.operatingSystem`). No file picker.
4. **CTA "Send feedback"** = `GWButton(variant: primary)` — canonical gradient (green→blue,
   near-black `#000B18` label; white fails WCAG AA per `gw_button.dart`). Inline is fine; unchanged.
5. **"Send another" (Success)** = `GWButton(variant: gradientOutline)` + a refresh/rotate leading icon.
6. **Copy — short hyphens only (no em dashes):**
   - Subtitle: "Describe what's happening in as much detail as you can - the more specific, the faster we can help."
   - Attach header: "SDK logs attached automatically" · hint "last 1 MB of each, empty ones skipped".
   - Success title "Feedback sent"; sub "Thanks for your feedback - every bit helps us make GeniusWallet better."
   - Result label **"Reference number"** (NOT "Event ID") + Copy; hint "Keep it handy in case you follow up with support."
   - Unit MB everywhere (chips + hint); code trims to 1 MiB — cosmetic rounding only.

## Non-negotiable mechanic (preserve exactly — from `submit_logs_screen.dart`)

- `Sentry.captureFeedback(SentryFeedback(message: feedbackMessage))`, `scope.level = warning`,
  tags `source='submit_feedback_screen'` + `platform=Platform.operatingSystem` (+ new `feedback_type`),
  contexts `feedback` / `sdk_logs` unchanged, `scope.addAttachment(...)` per prepared attachment.
- Auto-attach `sgnslog.log` + `sgnslog2.log` from `geniusApi.jsonFilePath`: read whole if
  ≤ `_maxAttachmentBytes` (1 MiB), else tail-trim via `_readTailBytes` → `<name>.tail.log`; **skip
  empty (0-byte) files** (breaks Android's native envelope). User never selects files.
- **No-SDK guard** `!geniusApi.isSdkInitialized` = its own state: attachments unavailable, send disabled.
- **Two distinct unhappy results, kept separate:**
  1. thrown exception → "Failed to send feedback: <e>"
  2. empty `SentryId` (`!_isSuccessfulSentryId`) → "Sentry did not confirm feedback upload (empty event ID)…"

## States to build

Ready · Sending ("Sending feedback with N log attachment(s)…") · Success (Reference number + Copy +
Send another) · No-SDK · Failed-exception · Failed-emptyId.

## Success criteria

- `/logs` renders on the shared shell (navbar active-tab gradient underline; 28px title; navbar→title
  gap unified with other tabs) — visually a sibling of Transactions/Markets/News.
- All 6 states render honestly; No-SDK disables send; both Failed messages distinct.
- `feedback_type` tag lands in Sentry; captureFeedback + auto-attach + tail-trim + empty-skip unchanged.
- CTA = GWButton primary gradient; Send another = GWButton gradientOutline.
- `flutter analyze` clean + debug-build verification loop + one runnable check on the non-trivial bit
  (feedback_type mapping and/or attachment prep: whole vs tail vs empty-skip).

## Claude's discretion

- Exact widget decomposition (private widgets vs inline), controller/state management shape, and
  whether the chooser is a `ToggleButtons`/segmented custom — match existing screen idioms
  (`swap_screen.dart`, `transactions_screen.dart`) and `gw_*` primitives.

## Scope fence

- ONLY `lib/logs/submit_logs_screen.dart` (+ its test). Do NOT modify shared `gw_*` primitives, tokens,
  or the navbar. Do NOT touch other tabs. Windows/other-platform variants out of scope unless the file
  already branches.
