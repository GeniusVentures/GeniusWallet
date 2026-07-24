# HANDOFF — Feedback tab: design LOCKED + Phase 19 planned (uncommitted)

**Session 2026-07-24.** DESIGN session (NOT executor). Continued sketch 150, locked variant D with
Jakub, then queued + planned Phase 19. No `lib/` edits, no `flutter run`, no commit, no STATE.md.
Another session actively owns Phase 18 + is writing ROADMAP.md concurrently (confirmed: it wrote 18's
3 plans mid-session) — this session kept all writes to its own files.

## What was decided (sketch 150 → winner D · Guided receipt)

Single centered column: Bug/Idea/Question chooser → message → "SDK logs attached automatically"
receipt row (log chips + TAIL + `SDK ● Running`/platform) → status + CTA. Round-2 synthesis of C's
guided feel + B's transparency, one column, ports easiest.

- **`feedback_type` IS in** (reversed round-1 "too new"): `scope.setTag('feedback_type', …)` — one
  line beside existing `source`/`platform` tags; makes type filterable in Sentry. (Fallback: prefix to
  message.) Chooser also adapts placeholder.
- **CTA "Send feedback"** unchanged = `GWButton(primary)` gradient (near-black `#000B18` label; white
  fails AA per `gw_button.dart`).
- **"Send another"** = `GWButton(gradientOutline)` + refresh icon (it's the only Success action; ghost
  was too quiet). Options in `send-another-options.html`; CTA options in `cta-options.html`.
- **Copy — SHORT HYPHENS ONLY, no em dashes** (Jakub's standing rule, saved to memory
  `no-em-dashes.md`): subtitle problem-focused; result labelled **"Reference number"** (not "Event
  ID" — user audience); "SDK logs attached automatically" · "last 1 MB of each, empty ones skipped";
  success "Thanks for your feedback - every bit helps us make GeniusWallet better." MB everywhere.

Design files: `.planning/sketches/150-feedback-tab/` (index.html winner D + ★, README updated,
cta-options.html, send-another-options.html). README frontmatter `winner: "D"`.

## Non-negotiable mechanic (from `submit_logs_screen.dart`) — must survive the port

captureFeedback @ warning + tags/contexts; auto-attach `sgnslog.log`+`sgnslog2.log` (whole ≤1 MiB else
tail-trim `_readTailBytes`, **empty skipped**, user never picks); No-SDK guard = own state; **two
distinct** Failed results (thrown exception vs empty `SentryId`) kept separate.

## Phase 19 — planned (in ROADMAP, plan written)

- **ROADMAP.md:** `### Phase 19: Feedback tab redesign (sketch 150 variant D)` block added (after 18).
  Parser confirms `roadmap.get-phase 19` = found.
- **`.planning/phases/19-feedback-tab-redesign-sketch-150-variant-d/`**: `19-CONTEXT.md` (locked
  decisions) + `19-01-PLAN.md` (gsd-planner: 1 plan, 3 tasks, all in `lib/logs/submit_logs_screen.dart`
  + a pure `flutter_test` check `test/logs/submit_logs_feedback_test.dart` for feedback_type mapping +
  attachment disposition; STRIDE threat register included).
- **Full spec:** `.planning/todos/pending/2026-07-24-phase-19-feedback-tab-redesign.md`.

## For the executor (deferred, left untouched to avoid ROADMAP/STATE collision with the 18-session)

1. ROADMAP Phase 19 "Plans:" line still says "TBD (run /gsd-plan-phase 19)" → point it at `19-01-PLAN.md`.
2. Requirements `TBD` → `FEEDBACK-TAB-19` (already in plan frontmatter; ROADMAP line not updated).
3. STATE.md "Roadmap Evolution" note for Phase 19; commit the planning docs.
4. Optional before build: `gsd-plan-checker` (read-only gate) — not run this session.
5. Build: `/gsd-execute-phase 19` (executor role — touches `lib/` + commits).
