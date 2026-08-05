> ✅ RESOLVED 2026-07-23 — this handoff is HISTORICAL. 13-01/02/03 shipped in 29b183b; 13-04/13-05 remain outstanding. Do NOT treat this as "everything uncommitted." Kept for history.

# HANDOFF — Phase 13 (Boot & loading sequence), session B

**Written:** 2026-07-22 · **Branch:** `ui-redesign-port`
**Status:** 2 of 5 plans closed · 13-03 **code-complete, walk not closed** · 13-04/13-05 not started
**Everything uncommitted**, per `./CLAUDE.md` ("Do not create commits").

> Session A owns Phase 12 (transactions) in this same tree — see
> `HANDOFF-phase12-transactions.md`. **Never `git add -A`, `git add .`, or
> `git commit -a`.** Four independent change sets live here.

---

## Where it stands

| Plan | Status |
|------|--------|
| 13-01 single-flight `initSDK` + truthful `getCoins()` | ✅ closed, SUMMARY written |
| 13-02 CoinGecko timeout + `BootSequence` engine | ✅ closed, SUMMARY written |
| 13-03 Signal Edge boot screen | ⏸ **code complete, walk NOT closed, no SUMMARY** |
| 13-04 one shared gate + per-section loaders removed | ⏳ not started |
| 13-05 cleanup + full-phase walk (network down, both themes) | ⏳ not started |

**13-04 is the original ask.** Jakub's opening request was that the dashboard stop
assembling itself section by section. The boot screen is built; the section
loaders in `coins_screen.dart:209` and `crypto_live_chart.dart:523`/`:310` are
still there. Do not let the phase read as "done" before that lands.

---

## Files this session owns — do not revert or stage these

**Modified**
- `packages/genius_api/lib/src/genius_api.dart` — `initSDK()` memoised
  (`_initFuture ??= _doInitSDK()`); the double-dispatch `LateInitializationError`
  is gone
- `lib/wallets/cubit/wallet_details_cubit.dart` — `getCoins()` now awaits its own
  fetch and settles `coinsStatus` on every exit path
- `lib/services/coin_gecko/coin_gecko_api.dart` — one `requestTimeout` (3 s)
  chained onto the three `http.get()` call sites
- `lib/screens/splash.dart` — the Signal Edge boot screen
- `lib/components/effects/gw_mesh_background.dart` — **additive** `dimAlpha`
  parameter (nullable; `null` reproduces the old `38 * intensity` exactly, so
  onboarding and the gallery render unchanged)
- `lib/main.dart` — removed `await fetchAllCoinGeckoCoins()` from before `runApp()`
- `lib/hive/init.dart` — adapters registered up front, boxes opened concurrently
- `macos/Runner/MainFlutterWindow.swift` — window background pinned to the boot
  canvas colour
- `tool/verify_additive_boundary.sh` — `LOADING_CANONICAL_EXPECTED` 19 → 18
  (splash no longer imports `Loading`)

**New**
- `lib/screens/boot_sequence.dart` — plain-Dart sequencer, no Flutter import
- `test/boot_sequence_test.dart` — 6 tests, part of the normal suite
- `.planning/phases/13-*/` — CONTEXT, RESEARCH, 5 plans, 2 summaries
- `.planning/sketches/015-boot-loading-sequence/`, `020-boot-mesh-depth/`
- `.planning/spikes/` (001, 002)
- `.planning/todos/pending/2026-07-22-boot-shows-an-empty-window-*.md`

**Deleted:** `tool/boot_sequence_check.dart` (moved into `test/`)

---

## Measured facts that must not be re-litigated

- **The main isolate is frozen ~9.6 s** during `GeniusSDKInitWithMnemonic`.
  Nothing can animate before it lifts.
- **Moving that init to `Isolate.spawn` does NOT help** — spike 001, INVALIDATED.
  A control run whose timer touched no SDK logged **zero ticks**, and all 41
  bindings are non-leaf. Do not re-attempt from Dart.
- **The SDK stalls at 52.5%** on `"Initializing blockchain service"` — 161 polls
  across 40 s, never reaches 100%. **Never gate the dashboard on
  `getInitializationStatus()`.** An earlier draft recommended exactly that; it
  would have hung the app permanently.
- **Dashboard data is ready at 141 ms** (wallets 0, transactions 140, balances
  141). The only real wait is the freeze.
- **`getCoins()`'s own work is ~476 ms connected / 137 ms offline.** The
  9.2–9.6 s figures from 13-01 were freeze-dominated. It needs **no** separate
  timeout.
- **`flutter test` WORKS** — 193 passing, 1 failing. `13-RESEARCH.md` and
  `ROADMAP.md` "Verification reality" both claim it does not compile; that is
  **false**. The 1 failure is inherited (`test/local_wallet_storage_test.dart`,
  fully commented out, fails at load). Do not fix it, do not report it.
- Baselines: `flutter analyze` **409** repo / **61** `lib`, 0 errors.
  `verify_additive_boundary.sh` Check 1 clean; **Check 2 already failed before
  this phase** (pre-existing `_Section` duplicate in `lib/dev/`), and 13-03 added
  a second benign private-name collision (`_SplashState`, also declared in the
  dead shadow `lib/components/splash.dart`). Both are library-private; no real
  risk. Scope any gate to Check 1.

---

## Boot screen — final values, and why the sketch cannot be trusted

```dart
const Color  _kBootCanvas         = Color(0xFF06070B);
const double _kBootMeshIntensity  = 0.40;
const int    _kBootMeshDim        = 235;   // NOT sketch 020's 120
```

**Sketch 020's numbers are wrong.** Its CSS blobs were far more contained than
`_MeshPainter`'s, which uses a radius of `maxDim * 0.95` and fills the whole
rect — so the mock rendered much darker than the app at identical values. Every
variant in that sketch understates real brightness. `dimAlpha: 235` was settled
on the live app. **Trust `splash.dart` over that sketch.** (The sketch is kept
for the reasoning trail, with the discrepancy noted in-file.)

Also note `intensity` alone cannot darken this background: in `_MeshPainter` it
scales the blob alpha (`110 ×`) **and** the black overlay (`38 ×`) together, so
lowering it yields a paler field, not a deeper one. That is why `dimAlpha` exists.

---

## Open for review / discussion

1. **Close 13-03's walk.** Needs a human on a real build: does the frozen window
   read as *waiting* or *hung*; is the `STATUS` kicker (`white @ 38%`) legible
   over the mesh; **both themes**; narrow window; and **H3 — does
   `GWMeshBackground`'s 36 s drift controller visibly jump when the freeze lifts?**
   (It advances ~27% in one frame on resume; predicted to be masked by the
   handover, **unverified**.) No SUMMARY can be honestly written without this.
2. **13-04** — the original ask. Watch the two traps the planner found: the gate
   must be a **first-paint latch** (or pull-to-refresh blanks the dashboard), and
   `crypto_live_chart.dart` has **two** loading cues, not one.
3. **13-05** — full-phase walk including a genuine network-down cold start.
   Note CoinGecko was rate-limiting (HTTP 429) throughout this session from
   repeated launches; let it cool down first or the result is meaningless.
4. **Black screen before the splash** — deferred by Jakub, likely Brian's.
   Measurements and the proposed fix are in
   `.planning/todos/pending/2026-07-22-boot-shows-an-empty-window-*.md`.

---

## Mistakes made this session — recorded so they are not repeated

- **Clobbered session A's row 019 in `.planning/sketches/MANIFEST.md`** with a
  read-modify-write. Restored from their sketch's frontmatter. **Append to that
  file only.**
- **Sketch 020 misrepresented the mesh** (see above), which sent the colour
  choice around C → G → diagnostic → C → G before landing.
- **Reported the wrong value back to Jakub**: the build he approved as "properly
  dark" was the `dimAlpha: 235` diagnostic, and it was then "restored" to G's
  120 — brighter than what he had signed off. Cost a full round trip.
- **Asked Jakub to switch off Wi-Fi** while the assistant needs the network to
  run. Fixed with a script that waits for the network to drop, then launches.
- **Wrong hypothesis on Hive**: parallelising the box opens was expected to
  recover seconds; it recovered ~125 ms. The real cost is
  `Hive.initFlutter()` at 1.25 s.
