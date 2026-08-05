---
sketch: 150
name: feedback-tab
question: "What makes the Send Feedback tab a first-class sibling of Transactions / Markets / News, without changing the real Sentry mechanic?"
winner: "D"
tags: [feedback, logs, submit-logs, page-layout, tab, sentry, states, empty-state]
lane: B
---

# Sketch 150: Feedback Tab

## Design Question

The Feedback tab (`/logs` → `SubmitLogsScreen`, titled "Send Feedback") is the odd one out.
Transactions / Markets / News are full pages built on the shared shell — navbar → `GWPageHeader`
→ centered `ConstrainedBox` → `.surf` cards. Feedback is a bare Material form floating in a
`small`-width column: a subtitle, a `TextField`, an `ElevatedButton`, a status line, and a
`Copy Event ID` button.

**How does it become a sibling tab** — same chrome, same card language, same brand-CTA — **while
keeping the real mechanic honest?** The mechanic is fixed and must show through:

- `Sentry.captureFeedback(SentryFeedback(message))` — one required, non-empty message.
- **Auto-attached SDK logs**: `sgnslog.log` + `sgnslog2.log`, each read fully if ≤ 1 MiB else
  **tail-trimmed** to the last 1 MiB (`_readTailBytes`), and **empty files skipped**. Today this
  trust signal is buried in one grey sentence — every variant promotes it to real UI.
- **SDK-not-initialised guard** (`!geniusApi.isSdkInitialized`) — a distinct, honest state, not an
  error after the fact.
- **Result** = a Sentry event ID + "Copy Event ID". Also the two unhappy results the code already
  distinguishes: a thrown exception (`Failed to send…`) and an *empty* event ID (upload not
  confirmed) — the sketch folds the empty-ID case into the Failed state for now (see Gaps).

## How to View

open .planning/sketches/150-feedback-tab/index.html

(Or serve the `sketches/` dir over http — the extension blocks `file://`:
`python3 -m http.server 8765` then open `http://127.0.0.1:8765/150-feedback-tab/index.html`.)

Top toolbar cycles all five states (Ready / Sending / Success / No-SDK / Failed), toggles a Phone
width (proves B stacks), and flips Light/Dark.

## Variants

- **A · Composer card** *(recommended — smallest diff)** — the existing form, lifted into one
  centered `.surf` card (~600px, near the old `small` cap). Message field + an "Attached
  automatically" chip strip (`sgnslog.log 312 KB`, `sgnslog2.log 1.0 MB · TAIL`) + a status line +
  the gradient CTA. Success collapses the composer in place into a check-badge + event-ID + Copy.
  Closest to today's widget tree; ports with the least code.
- **B · Context rail** — the Transactions page's two-column shape reused: composer on the left, a
  **"What gets sent"** panel on the right (attachments, SDK = Running/Stopped, Platform, and the
  "last 1 MiB / empties skipped" note). Stacks to one column on narrow. Makes the payload fully
  legible — nothing leaves without the user seeing it — at the cost of one more panel to build.
- **C · Guided / typed** — leads with a **Bug / Idea / Question** segmented chooser (mint-tinted
  active, per the app's segmented language), placeholder adapts to the choice, then the same
  composer + attachments + CTA. Most opinionated; the type *could* map to a Sentry tag.

### Round 2 — "keep C's feel, add nothing new" (2026-07-23)

Jakub liked C's guided character but ruled out **any new mechanic** (no `feedback_type` tag). The
resolution: the chooser is legitimate as **input guidance only** — it adapts the placeholder and
frames the message; `SentryFeedback(message)` ships flat either way, so it records nothing new and
needs zero wiring. Round 2 marries that guided feel to B's full payload transparency.

- **D · Guided receipt** *(recommended)* — single centered column (~640px): the Bug/Idea/Question
  chooser (guidance-only) → message → an **"Attached automatically"** row that folds B's whole
  payload into one place (both log chips + `TAIL` badge **plus** neutral dashed meta chips
  `SDK ● Running` and `macOS`) → send. As transparent as B, as guided as C, but one column — ports
  easily and stacks trivially on phone with no rail-collapse. Zero new logic.
- **E · Guided rail** — the same guided chooser on B's two-column shape: chooser + message + send on
  the left, the "What gets sent" receipt rail on the right. For desktop breathing room; stacks on
  narrow. Zero new logic.

### Winner: **D · Guided receipt** (Jakub, 2026-07-24)

Final copy locked in the sketch:
- **Subtitle:** "Bug, idea, or question? Write it below, then see exactly what we attach before it's sent."
- **Attach hint:** "recent SDK logs · last 1 MB of each, empty ones skipped"
- **MiB → MB** unified across chips + hint (code trims to 1 MiB / 1,048,576 B; the UI rounds to a
  friendly "1 MB" to match the `312 KB` / `1.0 MB` chip sizes — cosmetic, not a mechanic change).

**Success-state actions (Jakub, 2026-07-24):**
- **"Send feedback" CTA** stays the canonical GWButton `primary` gradient (green→blue, near-black
  `#000B18` label - white fails AA, per `gw_button.dart`). No change. Options explored in
  `cta-options.html` (A inline / B full-width / C elevated) but the current inline gradient is fine.
- **"Send another"** → **gradient-outline** (GWButton `gradientOutline` twin: gradient border +
  gradient label) with a refresh icon. It's the *only* action in the Success state, so ghost was
  too quiet; the gradient twin gives it presence while keeping brand identity and not competing as a
  filled primary. Options in `send-another-options.html` (A ghost / B gradient-outline / C secondary).

**Reversal of the round-1 call:** the `feedback_type` chooser is IN. It was flagged `new` earlier;
that over-stated the cost — `scope.setTag('feedback_type', type)` is one line beside the existing
`source` / `platform` tags, and it makes type a *filterable* dimension in Sentry (the reason the
chooser earns its place rather than being decorative). Fallback if zero code delta is required:
prepend `[Bug] / [Idea] / [Question]` to the existing `message` string — captured but not filterable.

## What to Look For

- **Does it read as a sibling tab?** Same navbar (active-tab gradient underline, sketch 022),
  same 28px title + 64px navbar gap, same `.surf` card + `--brand-cta` button as the other pages.
- **Is the auto-attach believable?** Chips vs. a rail panel — which makes "we send your logs"
  land without alarming anyone.
- **Do all five states stay honest?** Especially No-SDK (attachments genuinely unavailable) and
  Sending (the "2 log attachment(s)" count the code actually computes).
- **A's centered card vs. B's rail** — is the extra panel worth the build, or is one card enough?

## Provenance / Gaps

- **`rec` A** — path of least resistance; the current form is already a single short column.
- **`new` (C)** — the type chooser has **no backing today**: `_submitFeedback` sends a flat
  message. Wiring it means a `scope.setTag('feedback_type', …)` beside the existing
  `source`/`platform` tags. Cheap, but it's an addition, not a re-skin.
- **Empty-event-ID case** — the code separates "thrown exception" from "empty `SentryId`
  (not confirmed)". The sketch shows one Failed state; a build should keep both messages distinct
  (the empty-ID copy is more specific: "payload dropped or rejected before ingestion").
- Sizes/filenames (`sgnslog.log`, `sgnslog2.log`, 1 MiB tail, macOS platform, warning level) are
  taken from `submit_logs_screen.dart` verbatim.
- Not sketched: the file-count edge cases (0 logs, 1 log, both empty). The copy adapts trivially
  ("without SDK log attachments" vs. "with N") — noted, not drawn.
