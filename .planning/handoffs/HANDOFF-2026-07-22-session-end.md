# HANDOFF — end of 2026-07-22, session A → Braian

**Branch:** `ui-redesign-port` · **HEAD:** `ea33561` · **Everything below is UNCOMMITTED, by Jakub's choice.**

Two Claude sessions worked in this tree today. This is session A's half (Transactions). Session B
owns boot sequence and the compute panel — its own docs are `HANDOFF-phase13-boot.md` and
`HANDOFF-phase14-compute-panel.md`.

---

## THE ONE RULE

**Never `git add -A`, `git add .`, or `git commit -a`.** The tree holds four independent change sets:

1. Session A's Phase 12 + Phase 15 work (listed below)
2. Session B's Phase 13/14 work
3. `cmake/CommonBuildParameters.cmake` + `cmake/DownloadDependencies.cmake` — **Jakub's local-only
   build patches, deliberately never committed**
4. Six `skip-worktree` files carrying Jakub's Apple signing (`git ls-files -v | grep '^S'`)

`./CLAUDE.md` says *"Do not create commits."* Jakub has deferred all commits to the end of his own
work. Stage explicit paths only, and only when he says so.

---

## What shipped today (session A)

### Phase 15 — Transactions **tab** — implementation complete, 5 of 6

The `/transactions` route was mounting the dashboard *panel* verbatim: capped at 768px, titled with
the 18px panel header, sitting on the raw base colour with no card.

**Measured outcome: content width 1280.0 at 1600/2000/2560 viewports, against 736 before.**
`dashboard_screen.dart` is byte-unchanged, so the dashboard panel is untouched.

- `15-01` amount honesty — a processing job prints `− 0.42 GNUS` with a `$0.36 fee` value line
  instead of an em dash; failed/cancelled print the real signed amount and **keep `Not charged`**
- `15-02` `GWEmptyState` anchored — `Align(topCenter)` over `ConstrainedBox(maxHeight: 480)`.
  **Shared component: Assets and Markets changed too.** In a 1400px slot the icon moved 652 → 192px;
  in a 300px slot it is byte-identical to before, by design
- `15-03` panel — `Icons.sync_alt`, filter control hidden when `scoped.isEmpty`, `_activeLabelShader`
  hoisted to file scope
- `15-04` `_FilterRail` — the `⋯` menu unrolled; active row is the navbar's active-tab mark
- `15-05` page frame — `GWPageHeader`, `GeniusBreakpoints.xl`, `page` flag with `false` defaults
- `15-06` **NOT DONE — the human walk. Jakub's, not yours.**

Design contract: sketches **020 / 021 / 022**, each with a README carrying the reasoning and what was
rejected. Locked: **B · Filter rail**, active mark **B2 · underline only**, empty-state anchor **c**,
icon `Icons.sync_alt`, amounts print the real number.

### The freeze — fixed properly this time

**This is the highest-value thing in this document. Read it before touching any layout.**

Commit `37639d5` (already on the branch, from this morning) was an **incomplete fix**. It quantised
the chart's height-derived font size — and the app froze again the same afternoon, on the same
screen, on a drag-resize, with `SkLRUCache<ParagraphCacheKey>::remove` at 1580 samples on top of the
stack. The reason: `AutoSizeText` runs its **own** search to fit the available **width**, which a
drag varies just as continuously. Quantising one input never mattered while the mechanism was intact.

Seven call sites were converted to a fixed style plus `overflow: TextOverflow.ellipsis`:
`crypto_simple_chart.dart` (1), `crypto_live_chart.dart` (1), `coin_card_row.dart` (**3 per row**,
so ×coins), `gw_wallet_card.dart` (1).

**Why the original guard missed it:** `test/chart/compact_price_font_size_test.dart` tests a **pure
function**. It never touches a widget, so it stayed green while the app hung. It tested the fix, not
the bug.

`test/freeze_rule_test.dart` is the replacement. It scans dashboard-reachable sources for
`AutoSizeText(` / `FittedBox(` and fails with a **file:line**. Proved green → red → green.

**Rule: no dimension may be derived continuously from constraints.** Booleans and literals only.
Its stated ceiling: it scans only surfaces where the freeze was *measured*. Onboarding and the
generated `*.g.dart` components still carry ~20 `AutoSizeText` uses and are equally capable of this
hang — widening `_scannedDirs` to `lib/` is the upgrade path.

---

## Files session A owns — do not stage or revert these

**Modified:** `transaction_displays.dart`, `transaction_utils.dart`, `transactions_slim_view.dart`,
`transactions_screen.dart`, `transactions_stream.dart`, `sgnus_transactions_screen.dart`,
`gw_empty_state.dart`, `coin_card_row.dart`, `gw_wallet_card.dart`, `crypto_live_chart.dart`,
`crypto_simple_chart.dart`, `genius_wallet_colors.dart` (**additive only**: `statusNeutral`),
`dev_mock_transactions.dart`

**New:** `transaction_badge.dart`, `assets/images/pickaxe.svg`, `test/dashboard/`,
`test/components/`, `test/freeze_rule_test.dart`, `.planning/phases/12-*`, `.planning/phases/15-*`,
`.planning/sketches/009-014`, `019`, `020-transactions-tab`, `021`, `022`

**Session B's — do not touch:** `boot_sequence.dart`, `test/boot_sequence_test.dart`, `splash.dart`,
`gw_mesh_background.dart`, `hive/init.dart`, `main.dart`, `MainFlutterWindow.swift`,
`.planning/phases/13-*`, `14-*`, `.planning/sketches/015-018`, `020-boot-mesh-depth`,
`.planning/spikes/`

**Uncertain, check before touching:** `coin_gecko_api.dart`, `wallet_details_cubit.dart`,
`packages/genius_api/lib/src/genius_api.dart`, `03-SHADOW-NAMES.md`, `verify_additive_boundary.sh`

---

## Test baseline

**222 passing / 1 failing** as last measured. The failure is `test/local_wallet_storage_test.dart`,
which is **entirely commented out** and fails at load, so the `-1` is carried through the whole run
with no individual test reporting a failure. It is **pre-existing. Do not "fix" it and do not report
it as a regression.** Restoring it is a known outstanding task — it is the only PIN/secure-storage
coverage in the repo.

**Two flakes seen repeatedly, neither a regression.** Under a loaded full-suite run,
`transaction_utils_test.dart`'s job-fee cases and occasionally `transaction_filters_test.dart` go
red; both pass in isolation and under `--concurrency=1`. There is also a `tokens.json` HTTP 404 in
the same runs, which suggests a test reaching the network. **Before calling anything a regression,
re-run serially.** One executor's batch mutation loop also produced two false "survivors" purely
from stale compiles against a file rewritten seconds earlier.

---

## Open — Jakub's decisions, not yours to guess

1. **The brand gradient disagrees in three places.** Sketch mockups paint `#14C8FF → #2BF5B4`; the
   app's `brandCta` is `[#0AD89C, #0AAEE6]`; and `genius_wallet_gradient.dart:15` claims it mirrors
   the website's `#0c91cc → #06aa78`. **Every gradient decision approved off a mockup was approved
   against colours the app does not paint.** Logged in
   `.planning/todos/pending/2026-07-22-sketch-theme-gradient-mismatch.md`. Do not copy hexes out of
   a mockup into source — read them from `lib/theme/`.
2. **Sketch number collision, second occurrence.** Session A has `020-transactions-tab`, session B
   has `020-boot-mesh-depth`, both in `MANIFEST.md`. The same happened at 016. The real problem is
   two sessions drawing from one counter with no coordination — it will happen a third time.
3. The B2 underline tracks its word, so its width ranges **39.75 → 119.25px** across the labels.
   Whether that ragged edge is acceptable, and whether 2px is loud enough, is a walk judgement.

## Open — deferred findings, logged not fixed

- `RefreshIndicator` does not arm over the rail card — the rail's `SingleChildScrollView` fits its
  content, so **220px of a 1280px page is dead to pull-to-refresh**
- `_panel`'s title row overflows below 413px — pre-existing, and Phase 15 made it **8px better**
- A `RenderFlex overflowed by 128 pixels on the right` appears at runtime. The morning's handoff
  recorded an 82px overflow at `responsive_overlay.dart:199` from before Phase 12. **Same widget at a
  different width, or something new? Not investigated — do not assume.**
- The native SDK loops on `Blockchain not fully initialized` every ~5s and starts a new bootstrap
  health check each time without cancelling the last: **92 in 7 minutes.** Not the freeze, but an
  unbounded leak
- Both walks outstanding: Phase 12's `12-06` and Phase 15's `15-06`. **Dark mode only** — light is
  backlog per `.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md`, and a
  light-mode finding is a note in that file, never a blocker

---

## Running the app on macOS

```
flutter run -d macos --dart-define=GW_DEV_TOOLS=true
```

Kill any running instance first — a stale one holds the Hive container lock at
`~/Library/Containers/ai.gnus.GeniusWallet.jakub/` and the next launch dies in `initHive` with
`lock failed … coingeckocache.lock`. That is a stuck process, not a code fault; it cost time today.

**Transactions render empty until the mock injector runs** — the bug icon in the dev panel,
"Mock txns" (11 fixtures covering all 7 types and all 4 statuses).

**If you script the launch:** `setsid` **does not exist on macOS**. Launching detached with a FIFO
for stdin needs a long-lived writer holding the FIFO open, or the open blocks forever:

```sh
mkfifo gw.fifo
nohup sh -c "sleep 86400 > gw.fifo" &                 # keeps the write end open
nohup sh -c "exec flutter run -d macos … < gw.fifo > gw.log 2>&1" &
printf 'R' > gw.fifo                                   # hot restart
```

Never launch `flutter run` as a backgrounded harness task — it dies when the shell is reaped. And do
not run a mutation test against a file while a build of that file is in flight; the build will fail
on your temporary mutation.

---

## One process note worth carrying

Every parallel executor today reported that "a concurrent session" had changed the tree — the test
baseline, `gw_empty_state.dart`, the branch. **In every case it was a sibling from the same wave, or
a stale git snapshot in its own prompt.** The reflog was authoritative and showed no checkout during
any wave. Treat a parallel agent's claim about external interference as a hypothesis, and check
`git reflog` before acting on it.
