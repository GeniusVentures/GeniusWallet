# HANDOFF — Phase 14: Compute panel & job flow

**Paused:** 2026-07-22, mid-afternoon · **Resumes:** this evening
**Owner:** Jakub — this is Jakub's task to finish.
**Session type:** design only. **No application code was written or run.**

---

## ▶ The one command to resume

```
/clear
/gsd-plan-phase 14
```

**Answer this before running it** — it changes the plan breakdown:

> **Does `View transaction ›` stay in scope?**
> It needs a job→mint-transaction correlation that does not exist today. `showTransactionDetails()`
> is ready (`transaction_displays.dart:316`); what is missing is knowing *which* mint tx a finished
> job produced. ROADMAP currently records: *if the correlation proves expensive, cut the link rather
> than growing the block* — because B2 has only 15 px of headroom. Decide, then plan.

---

## Scope of this handoff — read this first

This working tree contains **several sessions' work in parallel** (phases 12, 13, 15, boot sequence,
splash, transactions). **This handoff covers only Phase 14 and its sketches.** Everything else in
`git status` belongs to another session and was not touched, not verified, and is not described here.

Files this session actually changed:

| File | Change |
|---|---|
| `.planning/ROADMAP.md` | Added the Phase 14 detail block (design contract, height budget, 5 bugs, affordance audit) |
| `.planning/STATE.md` | One entry under Roadmap Evolution |
| `.planning/sketches/MANIFEST.md` | Rows 016, 017, 018 — winners recorded |
| `.planning/sketches/016-compute-panel-anatomy/` | New — 7 variants, 6 states, live height check |
| `.planning/sketches/017-compute-status-states/` | New — 9 states × 3 treatments |
| `.planning/sketches/018-job-request-flow/` | New — 5 steps × 3 layouts × 3 surfaces |
| `.planning/phases/14-compute-panel-job-flow/` | New, empty — created by `phase.add` |

Nothing was committed. Nothing was pushed. No PR.

---

## What is decided and locked

| Sketch | Winner | The load-bearing reason |
|---|---|---|
| 016 | **B2 · Twin tiles** | Balance and Compute as siblings of equal rank |
| 017 | **A · Dot + label** | The only treatment that stays honest in all 9 states |
| 018 | **A · Drawer, vertical steps** | Step 3 asks you to confirm money decided in step 2 — it must stay on screen |

### The constraint that will bite whoever plans this

The card has **276 px** (`maxHeight: 300` at `dashboard_screen.dart:207`, minus 24 px of
`DashboardScrollContainer` padding). **B2's worst state is 261 px — 15 px of headroom, the tightest
of the four variants sketched.**

B2 did not fit as originally drawn (282 px on *Not linked*). It fits **only** because the centred
"why" row under the CTA was merged into the status sub-line, so reason and remedy share one line:
*"Not the wallet linked to SGNUS · switch wallet ›"*. **Do not un-merge that.** And treat every
addition to the compute block as a budget question first.

`+12.4 GNUS earned` is **already excluded** from that measurement and is out of scope — it needs a
mint/job-reward aggregate no current API exposes.

---

## Deliberately left alone — do not "fix" these

- **`/network` is not re-skinned.** It is raw `ListTile`s with `Colors.green`/`Colors.red`, and it
  looks wrong. It is **out of scope for Phase 14** and belongs to sketch **023** (019 is taken by
  `dashboard-separators`; 022 is the current high-water mark). Phase 14 only needs the route to
  exist, and it does (`router.dart:188`).
- **The unit clash is accepted, not overlooked.** This card shows `1,204.50 GNUS` (SDK poll, 10 s)
  while Assets 12 px away shows `$312.40` (CoinGecko, 60 s) — same money, two units, two intervals,
  so they will disagree in practice. B2 keeps it, mitigated by an `≈ $` subline. Sketch **016-B3**
  resolves it outright by adopting fiat and is the recorded fallback if the drift becomes visible.
- **The ring is rejected on purpose.** A determinate ring's grammar is *"this will fill up"*, which
  is precisely why the shipped UI cannot render *stalled* or *unavailable* without lying. It survives
  only in the 56 px `GWAiFab`, under the rule **no live percentage → no ring**. Do not reintroduce it
  into the panel because it looks richer.

---

## Three states are NOT free — they need bloc work

Six of the nine states in sketch 017 are derivable from data that already exists (no wallet, not
linked, initializing, ready, processing, disconnected). These three are not:

1. **Stalled** — needs a stall detector. `getInitializationStatus()` reaches `0.525` and never moves
   again (measured: 161 polls across 40 s, spike 002 + sketch 015). Same value across N consecutive
   polls flips the state. Cheap — the poll already runs.
2. **Unavailable** — `app_bloc.dart:193-196` cancels `_processingTimer` **permanently** on any
   exception and emits `isProcessing:false`. Nothing restarts it, so a dead feed is pixel-identical
   to a healthy idle node. Needs a `RetryProcessingStatus` event plus a state flag separating
   "unavailable" from "idle". **This is the only affordance in the whole design with no destination
   in the codebase today.**
3. **Job complete** — edge-detect on `isProcessing` true→false, plus the tx correlation above.

Plus one small extraction: `switch wallet ›` needs a public `AccountDrawer.show(context)`. The
mechanism exists in full (`AccountDropdownSelector._showAccountDrawer()` →
`ResponsiveDrawer<Wallet>` → `selectWallet()`, `account_dropdown_selector.dart:161`/`:212`) but is
private and mounted only in the top-bar action row (`responsive_overlay.dart:103`). No new UI.

---

## Verification status — stated plainly

**Nothing here has been verified in the running app, because nothing was built.** The sketches are
HTML mockups. Their height numbers are *derived from the real constraints in the Dart source*, not
measured from a running Flutter layout — **the first plan should confirm the 276 px budget and B2's
261 px against a real build before the layout is finalised.** If the real figures differ, B2 is the
variant with the least room to absorb it.

macOS walk recipe, for when there is something to walk (phase plans were authored on Windows and
still say `flutter run -d windows`):

```bash
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

The dev bubble's SGNUS fixture is what makes the processing state reachable at all — a real SGNUS
wallet is not required to walk states 05/06.

---

## Environment note left for the next session

A `flutter run -d macos` process (PID 72876 at pause time) was **alive and only ~1 minute old** when
this session ended. It was **not started by this session and was deliberately left running** — it
appeared to belong to a concurrent session. If the next cold start opens a silent black window, that
is the Hive container lock at `~/Library/Containers/ai.gnus.GeniusWallet.jakub/` still held by a
stale instance — kill it, it is not a bug in the app.
