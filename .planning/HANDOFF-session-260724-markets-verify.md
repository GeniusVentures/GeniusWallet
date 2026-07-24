# Session handoff — 2026-07-24 (Markets polish + phase closeout)

**Executor session.** Branch `ui-redesign-port`. Nothing committed (CLAUDE.md commit gate held by Jakub).

## Done this session

### Markets tab live polish (all in working tree, analyze-clean, walked "super")
- `markets_table.dart` — sparkline column right-aligned (fixed 72px) for even spacing; gradient sort arrow (`ShaderMask`+`brandCta`); 1h%/7d% honest `-` placeholders.
- `markets_hero_card.dart` — hero chart bottom-aligned to Volume/ATH row via an empty `Spacer` (the SAFE fix; an earlier `Expanded(chart)` under `IntrinsicHeight` froze the embedder — do NOT reintroduce it); hover tooltip on the hero chart (time+price+% vs window start, ported from `CryptoLiveChart`); `RepaintBoundary` around the card to kill a hairline-border scroll flicker.
- `markets_screen.dart` — page vertical scrollbar hidden (`ScrollConfiguration(scrollbars:false)`).
- `dashboard_markets.dart` / `crypto_simple_chart.dart` — homepage Markets ticker + sparkline-last (from earlier). Column-header experiment was tried and REMOVED at Jakub's call.

### Verification closeouts (no-commit; VERIFICATION.md per phase)
- **12** Transactions redesign — PASS 11/11.
- **13** Boot & loading — passed (Jakub human sign-off on 2 deferred walks: light + offline).
- **15** Transactions tab — PASS 6/6.
- **16** Markets — PASS 9/9 + retroactive `16-01-PLAN.md`+`16-01-SUMMARY.md` (shipped `aa78eec`, outside GSD flow).
- **17** News — walk APPROVED + retroactive `17-01-PLAN.md`+`17-01-SUMMARY.md` (shipped `651541c`).
- Minor fixes: removed dead `compact` param from `_TransactionFilterBar`; fixed stale `tool/boot_sequence_check.dart` ref in `boot_sequence.dart` → `test/boot_sequence_test.dart`.

### Env note (saved to memory)
Every `flutter run` MUST include `--dart-define=GW_DEV_TOOLS=true` or the dev-tools bubble (mock transactions) disappears — it is gated by `kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS')`. Relaunch also needs the fifo at `<scratchpad>/gw.fifo` for hot-reload (`echo r > fifo`).

## PENDING — Phase 18 & 19 execution (Jakub's next ask, NOT started)

Blocked mid-session by: **session usage limit (reset 10:50am Europe/Warsaw)** + the `claude-sonnet-5` safety classifier being temporarily unavailable (blocked Bash + Agent spawns). The two `gsd-executor` agents never launched. NOT started = tree is safe (no half-written files).

**Plans are ready:**
- **18 Web tab chrome** — `18-01/02/03-PLAN.md`, design = sketch 037-B (035-B omnibox + 036-A tab strip). Touches `lib/web/web_view_mobile.dart` (primary), `web_view_windows.dart` (secondary). Re-skin ONLY, browser engine wiring untouched. Remove the old full-screen `_buildTabManager` + upside-down thumbnails + dead `Screenshot` machinery.
- **19 Feedback tab** — `19-01-PLAN.md`, design = sketch 150-D. Touches the `/logs`→`SubmitLogsScreen` ("Send Feedback") file. Re-skin onto the shared shell (`GWPageHeader`, `GWButton`, `GWCard`).
- File sets are DISJOINT (web/ vs logs/) → safe to run the two executors in parallel in the MAIN tree.

**Resume recipe:** once the limit resets / classifier recovers, spawn one `gsd-executor` per phase with these HARD constraints: no git commits/staging, no `flutter run`/full test suite (app already running; 2nd instance dies on Hive lock), `flutter analyze <file>` to prove clean, write per-plan SUMMARYs, only touch the phase's own files. Then hot-reload via the fifo and walk with Jakub.

## Uncommitted pile (context)
Large: my Markets/txn work + the parallel design session's output (18/19 plans, sketches 035-037/105-121/150-151, handoffs, `crypto_news_screen.dart` M). Jakub deferred committing. When committing later, separate my code work from the design-session planning files.
