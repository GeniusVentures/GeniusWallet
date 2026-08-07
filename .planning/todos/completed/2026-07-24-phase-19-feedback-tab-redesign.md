# Phase 19: Feedback tab redesign (sketch 150, variant D)

**Queued by a DESIGN session 2026-07-24** as a single todo (not a ROADMAP edit) because Phase 18 is
in-progress in another session that holds the executor role + `ROADMAP.md`. **Executor: promote this
to ROADMAP as Phase 19** (number reserved at Jakub's request; 18 is taken).

## Goal

Port `SubmitLogsScreen` (`/logs`, "Send Feedback") from a bare Material form onto the shared shell so
it reads as a first-class sibling tab (like Transactions / Markets / News), **without changing the
real Sentry mechanic**. Winner = **sketch 150, variant D · Guided receipt** (single centered column).

Design source of truth: `.planning/sketches/150-feedback-tab/` (index.html winner D + README +
`cta-options.html` + `send-another-options.html`).

## Locked design decisions (from the sketch session)

- **Layout D:** one centered column (~640px) on `GWPageHeader` + `.surf` card: chooser → message
  field (2000 char cap) → "SDK logs attached automatically" row (log chips + `TAIL` badge + neutral
  `SDK ● Running` / platform chips) → divider → status + CTA.
- **Type chooser is IN:** Bug / Idea / Question segmented control (app's segmented language,
  mint-tinted active). Wire `scope.setTag('feedback_type', 'bug'|'idea'|'question')` beside the
  existing `source` / `platform` tags in `_submitFeedback` — one line, makes type a *filterable*
  Sentry dimension. Chooser also adapts the field placeholder.
- **CTA "Send feedback":** unchanged — canonical `GWButton(variant: primary)` gradient (green→blue,
  near-black `#000B18` label; white fails WCAG AA per `gw_button.dart`).
- **"Send another" (Success state):** `GWButton(variant: gradientOutline)` + a refresh/rotate icon —
  the gradient-border twin. It's the only action in Success, so ghost was too quiet.
- **Copy (short hyphens only — no em dashes):**
  - Subtitle: "Describe what's happening in as much detail as you can - the more specific, the faster we can help."
  - Attach header: "SDK logs attached automatically" · hint "last 1 MB of each, empty ones skipped"
  - Success title "Feedback sent" · sub "Thanks for your feedback - every bit helps us make GeniusWallet better."
  - Result label **"Reference number"** (NOT "Event ID") + Copy; hint "Keep it handy in case you follow up with support."
  - Unit: display **MB** everywhere (chips + hint) for consistency; code trims to 1 MiB (1,048,576 B) — cosmetic rounding, not a mechanic change.

## Mechanic that MUST survive the port (from `submit_logs_screen.dart`, verbatim)

- `Sentry.captureFeedback(SentryFeedback(message))`, `level = warning`, tags `source` + `platform`
  (+ new `feedback_type`).
- Auto-attach `sgnslog.log` + `sgnslog2.log` from `geniusApi.jsonFilePath`: read whole if
  ≤ 1 MiB, else tail-trim to last 1 MiB (`_readTailBytes`), **empty files skipped** (0-byte
  attachment breaks Android's native envelope). User never picks files.
- **SDK-not-initialised guard** (`!geniusApi.isSdkInitialized`) = its own honest state (No-SDK):
  attachments unavailable, CTA disabled ("Start the SDK to send").
- **Two distinct unhappy results** — keep both messages, don't fold into one:
  1. thrown exception → "Failed to send feedback: <e>"
  2. empty `SentryId` (upload unconfirmed) → "Sentry did not confirm feedback upload (empty event ID)…"

## States to build (all shown honest in the sketch)

Ready · Sending ("Sending feedback with N log attachment(s)…") · Success (Reference number + Copy +
Send another) · No-SDK · Failed-exception · Failed-emptyId.

## Success criteria

- `/logs` renders on the shared shell (navbar active-tab gradient underline, 28px title, 64px
  navbar→title gap) — visually a sibling of Transactions/Markets/News.
- All 6 states render honestly; No-SDK disables send; both Failed messages distinct.
- `feedback_type` tag lands in Sentry; `Sentry.captureFeedback` + auto-attach + tail-trim +
  empty-skip behaviour unchanged.
- CTA = GWButton primary gradient; Send another = GWButton gradientOutline.
- `flutter analyze` clean + the debug-build verification loop (per phase convention) + one runnable
  check on the non-trivial bit (`feedback_type` mapping / attachment prep).

## Next step for executor

`/gsd-plan-phase 19` — this file is the spec; the mechanic block above is non-negotiable.

---

**CLOSED 2026-08-07**, verified against the tree at `e1d66b2`, not against the 2026-08-05 triage.
Phase 19 is complete — verification passed and the walk is recorded in its phase directory.
