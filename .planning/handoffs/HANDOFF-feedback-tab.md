# HANDOFF — Feedback tab redesign sketched (150, uncommitted)

**Session, 2026-07-23.** DESIGN/SKETCH session (NOT the executor). Sketched a first-class
redesign of the Feedback tab (`/logs` → `SubmitLogsScreen`, "Send Feedback") — today a bare
Material form while Transactions / Markets / News are full pages. No `lib/` edits, no app run,
no commit (CLAUDE.md: "Do not create commits"), no `STATE.md` / `ROADMAP.md` touched.

## What was produced

- **`.planning/sketches/150-feedback-tab/index.html`** — one sketch, 3 variants, all interactive.
  Toolbar cycles 5 states (Ready / Sending / Success / No-SDK / Failed), toggles Phone width,
  flips Light/Dark. Verified in-browser: all 3 variants + both themes + state machine render, no
  console errors. (Extension blocks `file://` — served via `python3 -m http.server` from `sketches/`.)
- **`.planning/sketches/150-feedback-tab/README.md`** — design question, variant descriptions,
  provenance/gaps.
- **`.planning/sketches/MANIFEST.md`** — row 150 appended (executor-owned file; edited but NOT
  committed — see bookkeeping).

Used design-lane **B** (150-199) to stay clear of lane A's 100-104 (news/markets pages).

## The variants (pick still open)

- **A · Composer card** *(recommended, smallest diff)* — the form lifted into one centered `.surf`
  card; message + auto-attach chip strip + status + gradient CTA; success collapses in place.
- **B · Context rail** — Transactions' two-column shape: composer left, a "What gets sent" panel
  right (attachments, SDK Running/Stopped, Platform, the 1 MiB note). Stacks on narrow.
- **C · Guided / typed** — Bug / Idea / Question chooser up top (would map to a Sentry tag).

Common thread: every variant promotes the buried "SDK logs attach automatically" line into real UI
(chips showing `sgnslog.log 312 KB`, `sgnslog2.log 1.0 MB · TAIL`) and keeps all 5 states honest.

## Mechanic that must survive any build (from `submit_logs_screen.dart`, verbatim)

- `Sentry.captureFeedback(SentryFeedback(message))`, `level=warning`, tags `source` + `platform`.
- Auto-attached `sgnslog.log` + `sgnslog2.log`: read whole if ≤ 1 MiB, else **tail-trimmed** to the
  last 1 MiB; **empty files skipped**. Result = event ID + Copy.
- **SDK-not-initialised guard** = its own state (No-SDK), not a post-hoc error.
- The code distinguishes a thrown exception from an **empty event ID** (upload unconfirmed) — the
  sketch folds both into one Failed state; a build should keep the two messages distinct.

## Deliberately NOT done

- No winner marked (awaiting Jakub's pick). No round-2 refinement.
- **C's type chooser has no backing** — `_submitFeedback` sends a flat message; wiring it needs a
  `scope.setTag('feedback_type', …)`. Flagged `new` in the README, not assumed.
- No `lib/` port, no test, no `flutter analyze/run` (this is a paper sketch, not a build).

## For the executor (day summary + bookkeeping)

- Row 150 is already in `MANIFEST.md` (uncommitted). When you commit the day's planning docs,
  include `.planning/sketches/150-feedback-tab/` + the MANIFEST row.
- Suggested commit (when authorized): `docs(sketch-150): feedback tab as a first-class sibling tab
  — 3 variants, pick pending`.
- Not yet a phase/roadmap item. If Jakub picks a variant, the natural next step is a
  `/gsd-plan-phase` for porting `SubmitLogsScreen` onto the shared shell — the mechanic block above
  is the non-negotiable spec.
