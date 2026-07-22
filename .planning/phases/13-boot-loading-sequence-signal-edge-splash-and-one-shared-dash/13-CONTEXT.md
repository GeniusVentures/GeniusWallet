# Phase 13 Context — Boot & Loading Sequence

**Source:** Session 2026-07-22. Design approved by Jakub from sketch 015; technical constraints
measured in spikes 001/002 during the same session. Written directly rather than via
discuss-phase because every decision below was already settled interactively.

## Domain

A cold start currently shows the Genius logo with a loading animation that is **visibly frozen**,
then drops the user onto a dashboard whose sections each flash their own skeleton loaders. Jakub's
goal: one truthful loading state that holds until the app is ready, then a dashboard that appears
complete.

The frozen animation is **not** a broken asset. `lib/components/loading.dart:24` renders
`LoadingAnimationWidget.flickr`, a real `AnimationController`. Nobody is ticking it, because the
Dart main isolate is blocked.

## Locked Decisions

### Measured constraints — non-negotiable, not preferences

**M1 · The main isolate is frozen ~9.6 s at boot.** `GeniusSDKInitWithMnemonic` blocks it
(8.1–8.4 s of native call; 9594 ms from `AppBloc` construction to freeze-lift). A 100 ms heartbeat
timer recorded an 8610 ms gap. **Nothing can animate before the freeze lifts** — no spinner, no
blur, no progress bar.

**M2 · Moving init to another isolate does NOT help.** Spike 001 = **INVALIDATED**. The init runs
correctly inside `Isolate.spawn` (returns OK; the main isolate then reads a valid 130-char address
through its own handle), but the main isolate still stalled 8211 ms. A control run whose timer made
**no SDK call at all** logged **zero ticks**. Bindings are all non-leaf (0 × `isLeaf: true` across
41 `asFunction`), ruling out the leaf-FFI safepoint bug. The block is below Dart. **Do not
re-attempt this.**

**M3 · The SDK stalls at 52.5% forever.** 161 polls across 40 s: it climbs for ~750 ms
(20% → 25% → 30% → 52.5%) then sits on `"Initializing blockchain service"` indefinitely, never
reaching 100%. **The dashboard must NEVER gate on `getInitializationStatus()`** — that would hang
the app permanently. An earlier draft of the design said the opposite; it was retracted.

**M4 · Dashboard data is ready at 141 ms.** Wallets 0 ms, transactions 140 ms, balances 141 ms —
all long before the freeze lifts. There is no data gate to build for these; the only real wait is
the freeze.

**M5 · The network leg can fail entirely.** A full run was captured with DNS down
(`Failed host lookup: api.coingecko.com`). The app booted only because markets fail soft onto
cache. Anything folded into the gate needs a timeout + cached-data fallback.

### Design — approved from sketch 015 (winner: C · Signal Edge)

**D1 · Composition.** `GWMeshBackground` + large centred logo (`logo_and_title.png`) + bottom-left
`STATUS` kicker and status text + full-bleed gradient hairline on the bottom edge.

**D2 · Status text is solid grey** `#8A8F9D` (`textSecondary`), **6.01:1** on `#0B0D12` — AA.
Explicitly NOT gradient: a gradient status was built and rejected because it puts brand colour on
the one *informational* element and competes with the logo.

**D3 · The rail is gradient** cyan→mint (`brandPrimary` → `brandSecondary`), full-bleed, bottom
edge, ~2px.

**D4 · The rail is a closing flourish, not a progress bar.** It holds at 0 through the frozen
window, then sweeps to full as the app hands over. It must NOT be wired to the SDK percentage
(see M3 — it would sit half-full forever).

**D5 · Sequence.**

| Window | Status | Rail |
|--------|--------|------|
| 0 → freeze-lift | `Preparing your wallet…` | 0% |
| freeze-lift | `Wallets ready` | starts |
| +450 ms | `Balances ready` | ~33% |
| +900 ms | `Markets ready` | ~67% |
| +1500 ms | → dashboard | 100% |

**D6 · The closing statuses are confirmations, not progress claims.** "Wallets ready", not
"Loading wallets" — they genuinely finished at 141 ms, so each line is true when shown even though
the pacing is staged. "Loading wallets" nine seconds after they loaded would be false.

**D7 · ~1.5 s is a MINIMUM HOLD, not a fixed delay.** It also covers the markets/chart fetch, which
is real work of variable length. If markets run longer the sequence stretches; if they fail it ends
on cached data rather than waiting.

**D8 · The boot screen is mode-invariant** — pins the dark token set in both app themes. The logo
is a white wordmark that vanishes on a light surface, and `splash.dart:24` already pins a fixed
dark background via `static const deepBlue`. Move to `surfaceBase` `#0B0D12`, which measures better
on every pair (white 19.4:1, caption 6.01:1, cyan 9.93:1, mint 13.6:1 — all AA).

**D9 · Copy is English.** The app ships entirely in English; Polish copy / i18n is separate scope.

### Engineering

**E1 · Single-flight guard on `initSDK`.** It currently runs twice at boot — the router redirect
(`navigation/router.dart:56`) dispatches `InitializeSDK` before `sdkStatus` leaves
`AppStatus.initial`, while `_isSdkInitialized` is only set at the *end* of `_initSDK`. Today this
throws a caught `LateInitializationError: Field '_basePath' has already been initialized`. Store
the in-flight `Future` and return it to concurrent callers.

**E2 · Per-section loaders are removed** — `coins_screen.dart:209` (`Loading()`) and
`crypto_live_chart.dart:523` (`PulsingSkeleton`). Their work folds into the one gate.

## Canonical References

- `.planning/sketches/015-boot-loading-sequence/` — approved design + full findings
- `.planning/spikes/001-sdk-init-off-isolate/` — the INVALIDATED isolate attempt, with evidence
- `.planning/spikes/002-init-progress-polling/` — the 52.5% stall
- `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` — shadow-name hazard, below

## Hazards

**H1 · `Splash` is a shadow-named class.** `lib/components/splash.dart` declares `class Splash`,
the SAME name as `lib/screens/splash.dart`. The **routed** one is `lib/screens/splash.dart`
(`navigation/router.dart:30`). Migrating the boot screen to the shadow is a deliberate act
requiring an update to `03-SHADOW-NAMES.md` and a re-run of `tool/verify_additive_boundary.sh` in
the same commit. Default: re-skin the canonical, leave the shadow dead.

**H2 · `Loading` is also shadow-named.** `lib/components/loading.dart` (canonical, 19 importers)
vs `lib/components/loading/loading.dart` (shadow, only `design_gallery_screen.dart` may import it).
Do not repoint importers.

**H0 · NEVER derive a font size from layout constraints.** Commit `37639d5` fixed a **permanent
app hang**: a compact price font computed as `maxHeight * 0.45` produced a new `TextStyle` on every
frame of a window drag, thrashing Skia's paragraph cache so layout never stabilised, and macOS
locked forever inside `ResizeSynchronizer.beginResize`. Any layout-dependent value that reaches
`fontSize` must come from a **bounded set** (snap to whole pixels, or pick from a fixed ladder).
`AutoSizeText`, `FittedBox(scaleDown)` and `textScalerOf(...).scale(...)` fed into `fontSize` are
all instances of the bad pattern. Binding on 13-03, which adds a new full-screen layout.

*Scope note:* the rail in 13-03 derives a **width** from `constraints.maxWidth`, which is NOT this
pattern — no text shaping is involved and nothing enters the paragraph cache. The prohibition is
specifically about values reaching `fontSize` / `TextStyle`.

**H3 · `GWMeshBackground` is animated** (36 s drift loop, `gw_mesh_background.dart:41-48`), so it
freezes too. At that cycle length the motion is imperceptible, so frozen looks identical to
static — but on resume the controller jumps ~27% of its cycle in one frame. Expected to be masked
by the simultaneous handover to the dashboard. **Unverified — must be checked on the walk.**

## Claude's Discretion

- How the closing-run sequencer is structured (widget-local state vs a small controller)
- Where the minimum-hold timing lives
- The exact timeout value on the markets/chart leg (must exist; value is a judgement call)
- Whether the gate state is expressed in `AppBloc` or locally in the splash

## Scope Fence

**In:** `lib/screens/splash.dart`, the dashboard gate in `dashboard_screen.dart`, the two
per-section loaders (E2), the `initSDK` single-flight guard (E1), markets/chart timeout.

**Out:**
- Any attempt to unblock the native freeze from Dart (M2 — settled, do not retry)
- Native changes to GeniusSDK/SuperGenius (escalation, tracked separately)
- Onboarding screens (Phase 6, in progress — do not touch)
- Transactions (Phase 12)
- Polish copy / i18n (D9)

## Success Criteria

1. On a cold start the boot screen never reads as hung — nothing on screen promises motion it
   cannot deliver during the frozen window.
2. The dashboard appears **complete** — no section renders its own loader on entry.
3. The app opens even with the network down (cached data, timeout honoured).
4. Zero `RenderFlex overflowed`, zero exceptions, and no `LateInitializationError` in the console
   across a cold start.
5. Contrast verified live in both themes, including the `STATUS` kicker over the mesh.
