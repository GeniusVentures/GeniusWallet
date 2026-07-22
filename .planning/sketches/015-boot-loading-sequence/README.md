---
sketch: 015
name: boot-loading-sequence
question: "What does the boot screen look like during the ~9.6s in which nothing can animate — and how does one gate replace the per-section dashboard loaders?"
winner: "C · Signal Edge (status solid grey, gradient rail, 3-status closing run)"
tags: [boot, splash, loading, progress, gate, dashboard, mode-invariant]
---

# Sketch 015: Boot & Loading Sequence

## Design Question

1. **What does a screen that cannot animate look like, so it doesn't read as broken?**
   The Dart main isolate is frozen for ~9.6 s during `GeniusSDKInitWithMnemonic` (spike 001).
   No spinner, blur, or progress bar can move in that window.
2. **How does one shared loading state replace the per-section dashboard loaders**, so the
   dashboard appears complete rather than assembling itself in front of the user?

## How to View

```
open .planning/sketches/015-boot-loading-sequence/index.html
```

Hit **▶ Play boot** (4× default; switch to **1×** for real time), or scrub the timeline.
**Mesh on/off** isolates what the background contributes.

## Winner — C · Signal Edge

Approved 2026-07-22.

**Composition**
- `GWMeshBackground` (existing, kept by plan 06-01)
- Large centred logo — `logo_and_title.png`, existing asset
- Bottom-left: `STATUS` kicker (uppercase, `letter-spacing .16em`,
  `rgba(255,255,255,.38)`) + status text in **solid grey** `#8A8F9D`
- Full-bleed **gradient** hairline (cyan→mint) across the very bottom edge

**Sequence**

| Window | Status | Rail |
|--------|--------|------|
| 0 → 9.6 s (frozen) | `Preparing your wallet…` | 0% — nothing can move |
| 9.6 s | `Wallets ready` | starts |
| 10.05 s | `Balances ready` | ~33% |
| 10.5 s | `Markets ready` | ~67% |
| 11.1 s | → dashboard | 100% |

The ~1.5 s closing run is the one part of the boot that genuinely animates — by then the
isolate is free.

## Findings

**1 · The boot screen must stay dark in both themes.** `logo_and_title.png` is a white wordmark
that disappears on the light surface. Today's splash already sidesteps this — `splash.dart:24`
uses `GeniusWalletColors.deepBlue`, a `static const`, not a theme getter. Make that implicit
behaviour explicit and pin the dark token set; recommend moving off legacy `deepBlue`
(`#14253D`) to the redesign's `surfaceBase` (`#0B0D12`), which measures better on every pair.

**2 · Contrast, computed.** On `#0B0D12`: status `#8A8F9D` **6.01:1** AA; white **19.4:1**;
cyan `#14C8FF` **9.93:1**; mint `#2BF5B4` **13.6:1**. The `STATUS` kicker at
`rgba(255,255,255,.38)` is the weakest element — acceptable as a decorative label beside text
that carries the meaning, but it is the one pair to re-check on the live mesh, since the mesh
tints the background under it.

**3 · No moving element before 9.6 s.** A spinner promises motion; when it doesn't deliver, the
app reads as hung — today's exact bug. The rail therefore sits at zero rather than pulsing.

**4 · RETRACTED — "readiness must come from `getInitializationStatus()`".** An earlier draft of
this README said exactly that. It is wrong, and following it would have **hung the app forever.**
Measured over 161 polls across 40 s:

```
freeze-lift   t=9594ms
poll#1        t=9847ms   pct=0.20   "Migrating database (step 3 of 5): v3.4.0 -> v3.5.0"
poll#2        t=10097ms  pct=0.25   "Migrating database (step 4 of 5): v3.5.1 -> v3.6.0"
poll#3        t=10346ms  pct=0.30   "Migrating database (step 5 of 5): v3.6.0 -> v3.7.0"
poll#4        t=10597ms  pct=0.525  "Initializing blockchain service"
poll#5..161   …          pct=0.525  "Initializing blockchain service"   ← still stuck at t=49.8s
```

The SDK advances for ~750 ms then stalls at **52.5%** indefinitely. It never reports 100%.
**The dashboard must not wait on it.**

**5 · The dashboard's data is ready at 141 ms.** Same trace: wallets **0 ms**, transactions
**140 ms**, balances **141 ms** — all long before the freeze lifts. There is no data gate to
design; the only real wait is the freeze.

**6 · Therefore the rail is a closing flourish, not a progress bar.** Wired to the SDK number it
would sit half-full forever. It claims nothing while waiting, then sweeps to full as the app
hands over — it reads as *done*, not as *x% complete*.

**7 · The closing statuses are confirmations, not progress claims.** "Wallets ready" rather than
"Loading wallets", because they genuinely finished at 141 ms — each line is true at the moment
it is shown, even though the pacing is staged. "Loading wallets" nine seconds after they loaded
would simply be false.

**8 · The closing run is not pure theatre — and it costs ~1.5 s.** It covers the markets/chart
fetch, which is real network work of variable length. Treat 1.5 s as a **minimum hold**: if
markets run longer the sequence stretches; if they fail it ends on cached data. Be clear-eyed
that this adds ~1.5 s to an already-9.6 s boot, bought in exchange for a resolution beat instead
of an abrupt cut.

**9 · The network leg needs a timeout.** One run was captured with DNS down (`Failed host lookup:
api.coingecko.com`) where the app booted only because markets fail soft onto cache. Whatever
folds into the gate needs a timeout with a cached-data fallback.

**10 · `GWMeshBackground` is animated** (36 s drift loop, `gw_mesh_background.dart:41-48`), so it
freezes too. At that cycle length the motion is imperceptible, so a frozen mesh looks identical
to a static one — but on resume the controller jumps ~27% of its cycle in one frame. Probably
masked by the simultaneous handover to the dashboard; **unverified**, and worth one look during
the walk.

## Provenance

| Tag | Element | Source |
|-----|---------|--------|
| Existing | Logo | `logo_and_title.png`, already on the splash |
| Existing | Mesh background | `GWMeshBackground`, kept by plan 06-01 |
| Existing | Colour + type tokens | `GeniusWalletColors`, `GeniusWalletTypography` |
| Existing | Cyan→mint gradient | sketch-008 active-chrome standard (rail fill) |
| Adapted | Splash layout | `screens/splash.dart` keeps logo+centre, swaps `Loading()` for the STATUS line |
| Adapted | Dashboard gate | `dashboard_screen.dart:70` already gates on wallets+account; widen it |
| New | `STATUS` kicker + status line | bottom-left composition |
| New | Gradient closing rail | bottom-edge hairline + sweep |
| New | Closing-run sequencer | 3 confirmations over a ~1.5 s minimum hold |

## Rejected Alternatives

Kept so the reasoning stays inspectable:

- **A · Steady Mark** — logo + one status + a determinate rail. Superseded: the rail's data source
  is unusable (finding 4).
- **B · Boot Ledger** — 5-step checklist with live %. **Withdrawn after measurement.** Jakub asked
  whether the statuses would last long enough to switch, or whether it was overkill. The data
  answered it: ~750 ms of real transitions, then a permanent stall on step 4 of 5.
- **D · Single Status** — one line, no progress UI at all. Honest and cheapest, but the closing
  run was preferred for the resolution beat.
- **Status under the logo** — tried as a light redesign of C; the bottom-left placement was kept.
- **C2 · gradient status text** — cyan→mint on the status itself. Rejected: it puts brand colour
  on the one *informational* element and competes with the logo. Gradient stays on the rail.

## Note on Language

The app ships entirely in English (`"Something went wrong!"`, `"No market data available"`), so
the copy is English despite the Polish discussion. Polish copy / i18n is separate scope.
