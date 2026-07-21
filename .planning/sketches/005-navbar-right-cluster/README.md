# Sketch 005 — Navbar right cluster

**Design question:** How should the top bar's right side read as one cohesive cluster,
on par with the branded left side — instead of the mismatched controls it is today?

Open `index.html` in a browser. Toggle **variant** (A/B/C), **connection state**
(Connected / Connecting / Disconnected), and **theme** (dark/light).

## Why this sketch exists — the current cluster is mismatched by construction

The right cluster is assembled flush (no spacing) in
`lib/components/overlay/responsive_overlay.dart` → `_buildActionRowWidgets()`:

1. `NetworkDropdownSelector` — chain icon + chevron
2. `SDKAccountManagerButton` — gear + `0x…` address (collapses to `SizedBox.shrink()` when no SDK accounts)
3. `AccountDropdownSelector` — wallet avatar + label + chevron
4. `ReownConnectButton` — 5-state Connect (idle outline / connected / connecting / timed-out / retry)
5. `Buy GNUS` — `GWButton` gradient

**Root cause of "weird sizes":** 1–3 are bare `TextButton`s with no explicit height, so they
inherit `theme.dart`'s `textButtonTheme` padding `vertical: space10 (20)` → each renders **~56–60px
tall**, while Buy GNUS is a fixed **48px** `GWButton`. So the cluster is three tall grey `btnFilter`
rounded-rects of unequal width, a transparent/outlined Connect, and a shorter gradient pill — **four
heights, three fill languages, zero gaps.** The only aligned dimension today is the 15px radius.

## The three concepts

| | Concept | Idea | Structural change | Best when |
|---|---------|------|-------------------|-----------|
| **A** | **Context capsule + two actions** | Fold chain + SDK + wallet into ONE segmented pill (hairline dividers); Connect + Buy GNUS as two aligned buttons. One height, one gap, two fills. | Medium — group the 3 selectors into a segmented container | You want the cleanest "selectors are context, actions are actions" split |
| **B** | **Normalized quiet chips** | Keep the controls separate but force identical 40px height / radius-md / quiet menu fill + hairline border on all. Hierarchy by emphasis only: quiet context → outlined Connect → lone gradient Buy. | Minimal — token/size normalization, no new components | You want the **fastest, lowest-risk GSD port** that fixes sizing without restructuring |
| **C** | **Wallet status capsule** | The wallet becomes the hero: pill capsule with chain badge tucked onto the avatar + address + a **live status dot carrying the Reown connection state**. Connect folds into the dot (no separate button); SDK demotes to an icon button; Buy GNUS is the one CTA. | Largest — merges account + network + connection into one control | You want the most modern look, the fewest elements, and connection state always visible |

All three: one consistent height (40px, aligns with a 48→40 Buy GNUS or keeps Buy at its own weight),
consistent radius, real gaps (`space-4`/`space-6`), and they degrade gracefully when the SDK control
is absent (variable item count is a today-bug that A and C absorb structurally).

## Token discipline

Everything uses the shipped tokens via `../themes/default.css` (mirrors
`genius_wallet_colors.dart` / `_consts.dart`, incl. the new `space3` = 6px). No off-token values.
Note the sketch theme **darkens** `text-secondary` / status colors in light mode for AA — the same
correction UI-SPEC §3.1 still needs at source (see the Phase 5 verification finding); a winner that
ports to Flutter must use `textOnBrand`/AA-safe pairings, not the raw brand tokens on light fills.

## Not decided here

Pick a direction (or a hybrid — e.g. **B's** normalization as the floor, **C's** status-dot as an
add-on). Implementation is a **separate GSD task**, not part of this sketch. The connection-state
colors shown are illustrative; the real states come from `ReownConnectButton`'s 5-state machine.
