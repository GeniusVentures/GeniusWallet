# Roadmap: GeniusWallet

## Overview

This milestone lands the `ui-redesign-3.514` design on `develop` **incrementally, layer by layer**,
on branch `ui-redesign-port` (`branching_strategy: none` — phases land on the current branch, not
per-phase branches). Phase 1 (Adopt GSD) shipped on `develop` via PR #207.

### Why this order

The designer forked at `0495436` (2026-04-30); develop has **+127 commits** since. **128 of the
design's 172 changed files are files develop also changed (74% overlap).** Landing it in one step
means reconciling all 128 collisions at once with nothing verifiable in between.

The sequence is therefore **by dependency, not by subject** — each layer lands on a layer that
already exists and has already been looked at:

| Order | Layer | Why here |
|-------|-------|----------|
| 2 | Design tokens | Nothing can be skinned before the vocabulary exists. Tokens coexist with develop's theme, so this lands invisible — zero risk to un-ported screens. Also establishes the debug-build verification loop (BLD-02) that every later phase depends on — analyze-clean says nothing about runtime behavior, and there is no test harness. |
| 3 | `gw_*` primitives | The design's 82 new files are **additive** (new files, no collisions) → lowest risk of the whole port. Every screen imports them, so they must exist and be reviewed before any screen lands. The gallery (DS-03) makes them reviewable without a screen. |
| 4 | Nav shell & chrome | The frame every screen mounts into. Must be stable before screens land, and it has never been visually walked. |
| 5–10 | Screen areas | One area per phase, each landing on primitives that already exist and have been reviewed. |
| 11 | Closeout | Full-app walk confirming all 37 findings non-regressed. |

### Granularity note

`granularity: standard` (4–6 phases) is compression guidance, not a cap. Compression was applied
where it was safe: tokens + dev-gating + verification merged into one foundation phase; the shell
absorbed Settings and the SDK account manager rather than getting a thin phase of their own; GAP-01
rides in the component-library phase instead of a standalone inventory phase; each GAP feature rides
in the phase that owns its surface. Compression was **not** applied across screen areas — merging
them rebuilds the reconcile-everything-at-once problem this ordering exists to avoid, and every
phase must be independently landable on develop (no phase may leave develop half-skinned or
broken).

### GAP treatment decision

Instruction: inventory as an early phase, or handle per-area. **Both, split by kind.** GAP-01 (the
inventory + treatment decision) rides in Phase 3, because "extend the design language to features
with no mockup" is a design-system question — it decides which primitives the library must grow, so
it must be answered *while* the library is being built and *before* any screen lands. GAP-02..06
(the actual un-designed features) ride in the phase that owns their surface, so each is skinned in
the same slice as its neighbours and is verified by the same walk.

### BEH-02 — the 3 verified fixes

Each is attached to the phase that owns its component:

| Commit | Fix | Phase |
|--------|-----|-------|
| `f3fd16f` | Dev-tools gating (Dev header row, onboarding Mock button) → BLD-03 | Phase 2 |
| `d8db88c` | `assets/images/textures/` declared + bundled → DS-04 | Phase 3 |
| `7a63b4f` | `!_dirty` guard (crash when initial route resolves mid-mount) → NAV-02 | Phase 4 |

BEH-02 is *mapped* to Phase 4 because that is where the last of the three lands and the requirement
closes; Phases 2 and 3 carry the other two.

### BEH-01 — the 37 findings as a per-phase checklist

`.planning/REVIEW_FINDINGS_REDESIGN.md` records 37 evidenced defects in the design-vs-develop
surface, each with a file:line and a fix; 3 are blockers. Every finding is assigned to the phase
that owns its file; each phase confirms its subset non-regressed as it lands, and Phase 11 signs off
the whole set.

| Phase | Findings | Count |
|-------|----------|-------|
| 2 — Design tokens | 36 | 1 |
| 3 — `gw_*` library | 13, 15, 16, 25, 26 | 5 |
| 4 — Shell & chrome | 2, 4, 5, 11, 12, 23, 27, 35 | 8 |
| 5 — Dashboard | 8, 9, 10, 14, 17, 18, 29, 30, 31, 32, 33, 34 | 12 |
| 6 — Onboarding | 19 | 1 |
| 7 — Token screens | 24, 37 | 2 |
| 8 — Swap & bridge | 21, 22, 28 | 3 |
| 9 — Banxa | 1, 6, 7 | 3 |
| 10 — dApp connectivity | 3, 20 | 2 |
| **Total** | | **37** |

### Verification reality

There is **no working test harness** (`flutter test` does not compile; APP-02 defers fixing that).
Every success criterion below is a TRUE/FALSE statement observable by **running the app** — debug
build + visual walk. `flutter analyze` is a gate, never evidence.

Reference material: worktree `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514`
(original design branch, builds and runs as a Release exe — the visual source of truth) and branch
`ui-redesign-3.514-develop`, which exists only as the source of the 3 verified fixes in BEH-02.

## Phases

**Phase Numbering:**

- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [x] **Phase 1: Adopt GSD** - Establish and commit `.planning/` infrastructure (shipped, PR #207)
- [x] **Phase 2: Design tokens & verification loop** - Redesign token vocabulary lands invisibly; debug-build loop and dev-gating established (completed 2026-07-16)
- [ ] **Phase 3: gw_* component library** - The 82 additive primitives + design gallery + gap treatment decided
- [ ] **Phase 4: Navigation shell & chrome** - Shell, header chrome, Settings and SDK account manager wear the redesign
- [ ] **Phase 5: Dashboard** - Balances, holdings, transactions, markets, news
- [ ] **Phase 6: Onboarding** - Create, import, recovery phrase, verify, legal, select-wallet-type
- [ ] **Phase 7: Token screens** - Token info, send, receive, address book, charts
- [ ] **Phase 8: Swap & bridge** - Squid Router and GNUS bridge
- [ ] **Phase 9: Banxa** - Buy, KYC, checkout, order history/details
- [ ] **Phase 10: dApp connectivity** - Reown/WalletConnect
- [ ] **Phase 11: Port closeout** - Full-app walk; all 37 findings signed off

## Phase Details

### Phase 1: Adopt GSD

**Goal**: A committed, usable GSD setup on `develop`
**Depends on**: Nothing (first phase)
**Requirements**: GSD-01, BLD-01
**Success Criteria** (what must be TRUE):

  1. `.planning/` contains PROJECT.md, config.json, codebase map, REQUIREMENTS.md, ROADMAP.md, STATE.md — ✓
  2. The setup is merged into `develop` — ✓ PR #207 (`12fd40d`)
  3. A Windows debug build links and runs — ✓ `4395da7` (cherry-picked to develop)

**Plans**: 1/1 complete
**Status**: ✓ COMPLETE

Plans:

- [x] 01-01: Finalize and commit `.planning/` scaffolding

### Phase 2: Design tokens & verification loop

**Goal**: The redesign's visual vocabulary is on develop and every later phase can be checked by running the app
**Depends on**: Phase 1
**Requirements**: DS-01, BLD-02, BLD-03
**Success Criteria** (what must be TRUE):

  1. A Windows debug build launches from `ui-redesign-port`, hot reload applies a token edit without a restart, and the Dart debugger attaches and hits a breakpoint
  2. Every existing screen renders exactly as it did before the token layer landed — walking the app top to bottom shows no visual change and no startup exception (tokens coexist; nothing is skinned yet)
  3. The new token set resolves at runtime and flips correctly with light/dark appearance, demonstrable on a probe surface without touching an un-ported screen
  4. In a normal build the `Dev` header row and the onboarding `Mock` button are absent; with the opt-in dev flag on, both appear and `Mock` still injects its fake wallet + 20 fake transactions
  5. Form-field labels stay pinned above the field on every existing TextField (finding 36 — `floatingLabelBehavior: always` survives the theme rewrite)

**Plans**: 5/5 plans complete
**UI hint**: yes
**Carries**: `f3fd16f` (dev-tools gating). **Findings**: 36.
**Design contract**: `02-UI-SPEC.md` (approved 6/6 checker dimensions) — the coexistence mechanism
(§1) governs the whole phase: additive-only, `theme.dart` untouched, `appBarHeight` excluded.

Plans:

- [x] 02-01-PLAN.md — Appearance singleton, its Hive box, and the `google_fonts` dependency (DS-01)
- [x] 02-02-PLAN.md — Dev-tools gating: port `f3fd16f`'s `kShowDevTools` + its one live call site (BLD-03)
- [x] 02-03-PLAN.md — **The crux**: append the new tokens to the 3 colliding theme files without repointing a single existing symbol (DS-01)
- [x] 02-04-PLAN.md — Port the 6 remaining additive theme files: typography, elevation, motion, decorations, font sizes, copy (DS-01)
- [x] 02-05-PLAN.md — Token probe surface + route, then run and record the BLD-02 verification protocol (DS-01, BLD-02)

### Phase 3: gw_* component library

**Goal**: Every redesign primitive exists on develop and can be inspected for fidelity before any screen depends on it
**Depends on**: Phase 2
**Requirements**: DS-02, DS-03, DS-04, GAP-01
**Success Criteria** (what must be TRUE):

  1. `/design_gallery` opens in a debug build and renders every ported primitive (gw_button, gw_card, gw_token_row, gw_wallet_card, gw_error_state, gw_empty_state, gw_loading_state, gw_mesh_background, gw_icon, gw_checkbox, bottom_drawer, app_screen_view …), each visually matching the Release exe at `GeniusWallet-3514`
  2. `gw_mesh_background` renders its texture rather than a blank fill — the `assets/images/textures/` declaration resolves at runtime (a known omission — carried as `d8db88c`)
  3. Every gallery entry renders correctly in both light and dark appearance, and no QR surface renders dark-on-dark (findings 16 and 6 — QR backgrounds stay light in both themes)
  4. A drawer opened from the gallery mounts over the whole app, can be swiped down to dismiss, and switches to the desktop side-dialog at 768px — not 800 (findings 13, 25, 26)
  5. Every un-ported screen still renders and behaves as before — the library is additive and nothing consumes it yet
  6. `.planning/` records a treatment decision (extend the design language / keep develop's UI / defer) for each of the 12 develop features the design never saw, and every primitive those decisions call for exists in the gallery

**Plans**: 7/10 plans executed
**UI hint**: yes
**Carries**: `d8db88c` (assets/textures). **Findings**: 13, 15, 16, 25, 26.
**Design contract**: `03-UI-SPEC.md` (approved 6/6 checker dimensions) — the additive-only mechanism
(§1) governs the whole phase. Scope reconciles exactly against the diff: **60 additive − 9 nav-shell
(Phase 4) − 1 `gw_ai_fab.dart` (WIRE-02) = 50 files**, distributed 12+6+14+9+9 across plans 03-02..03-06.
**Planning found a hazard the UI-SPEC missed:** the `Loading` duplicate (§2.4) is one of **three**
shadow-name pairs — `Splash` (boot path) and `WalletsOverview`/`WalletsOverviewState` (analyzer-blind
`.g.dart` over GAP-06's file) also collide. See `03-SHADOW-NAMES.md` and `tool/verify_additive_boundary.sh`.

Plans:

- [x] 03-01-PLAN.md — Dependencies, the `noise.png` texture asset (carries `d8db88c`), and the shadow-name guard (DS-04, DS-02)
- [x] 03-02-PLAN.md — Core primitives: icon API, buttons, cards, inputs, animated number — 12 files (DS-02)
- [x] 03-03-PLAN.md — Feedback states, mesh background, and the `Loading` shadow — 6 files (DS-02)
- [x] 03-04-PLAN.md — The 9 generated widgets, their custom siblings, and the compile canary — 14 files (DS-02)
- [x] 03-05-PLAN.md — Layout, screen wrappers, `BottomDrawer` chrome, overlays — 9 files (DS-02)
- [x] 03-06-PLAN.md — Specialist: QR scanner, dropdowns, SGNUS, and the `Splash` shadow — 9 files (DS-02)
- [x] 03-07-PLAN.md — Design gallery port, dev-gated route, and `GWCanvasBackground`'s first instantiation (DS-03, DS-04)
- [ ] 03-08-PLAN.md — GAP-01: whole-app inventory and treatment decision (GAP-01)
- [ ] 03-09-PLAN.md — Gallery extension: the missing primitives, light/dark, drawer + QR + error state (DS-03)
- [ ] 03-10-PLAN.md — No-visual-change walk and the phase verification record (DS-02, DS-03, DS-04, GAP-01)

### Phase 4: Navigation shell & chrome

**Goal**: The frame every screen mounts into wears the redesign and survives startup
**Depends on**: Phase 3
**Requirements**: NAV-01, NAV-02, BEH-02, GAP-02, GAP-03
**Success Criteria** (what must be TRUE):

  1. The app starts, reaches the shell, and navigates every existing `go_router` route with no runtime exception — specifically no `!_dirty` crash when the initial route resolves mid-mount (`7a63b4f`)
  2. The shell wears the redesign skin — desktop rail and mobile bottom nav — and every route reachable before the port is still reachable, including the Web tab landing on the screen develop shipped (finding 27)
  3. Stored wallets are present on the dashboard immediately after a cold start (finding 2 — `loadStoredWallets()` at boot)
  4. From the account drawer a user can rename and delete a wallet, the keep-at-least-one guard fires, a deleted selected wallet re-selects another, and the drawer's rows update live while open (findings 4, 5, 23); switching networks shows the "Network Changed" toast (finding 35)
  5. Settings and the SDK account manager open from the shell and wear the extended design language per the Phase 3 treatment decision, with develop's behavior intact
  6. A build-time exception renders the branded recovery screen with its Go-to-Dashboard button rather than the red error box, and closing the window shuts the SDK down on every platform (findings 11, 12)

**Plans**: TBD
**UI hint**: yes
**Carries**: `7a63b4f` (`!_dirty` guard). **Findings**: 2, 4, 5, 11, 12, 23, 27, 35.

### Phase 5: Dashboard

**Goal**: The dashboard wears the redesign and keeps every behavior develop shipped
**Depends on**: Phase 4
**Requirements**: SCR-01, GAP-06
**Success Criteria** (what must be TRUE):

  1. Balances, holdings, transactions, markets and news all render in the redesign skin and match the Release exe at `GeniusWallet-3514`
  2. Pull-to-refresh works on the dashboard, the transactions list and the news feed, and each reloads its data (findings 10, 17, 18)
  3. When wallet or account load fails the dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 15, 29)
  4. Market data refreshes once a minute, not every 20 seconds (finding 14 — the 20s interval risks CoinGecko 429s)
  5. Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34)

**Plans**: TBD
**UI hint**: yes
**Findings**: 8, 9, 10, 14, 17, 18, 29, 30, 31, 32, 33, 34. **Covers GAP-06**: `wallet_overview.dart`, `loading.dart`, `transaction_displays.dart`.

### Phase 6: Onboarding

**Goal**: A new user can create or import a wallet through the redesigned flow with no loss of key safety
**Depends on**: Phase 4
**Requirements**: SCR-02, GAP-04
**Success Criteria** (what must be TRUE):

  1. Create-wallet, import-wallet, recovery-phrase, verify and legal screens all render in the redesign skin and complete end to end on a fresh install
  2. The recovery phrase stays read-only, the hide-toggle works, and no seed phrase appears in debug console output at any point in the flow
  3. Copying the recovery phrase on desktop shows its confirmation without throwing after the screen is dismissed mid-copy (finding 19 — missing `mounted` guard)
  4. The select-wallet-type step (develop-only, no mockup) wears the extended design language per the Phase 3 treatment and still routes correctly through `wallet_routes.dart`

**Plans**: TBD
**UI hint**: yes
**Findings**: 19. **Covers GAP-04**: `select_wallet_type_screen.dart`, `wallet_routes.dart`.

### Phase 7: Token screens

**Goal**: Token detail, send, receive and address book wear the redesign
**Depends on**: Phase 5
**Requirements**: SCR-03
**Success Criteria** (what must be TRUE):

  1. Token info, send, receive, address book and market data render in the redesign skin and match the Release exe reference
  2. A send completes end to end and a receive QR scans with a real phone camera in both light and dark appearance
  3. Tapping "More" on a non-GNUS token does nothing (the button is disabled) rather than opening an empty drawer (finding 37)
  4. Leaving a token chart mid-fetch, or while its refresh timer is running, throws no `setState after dispose` (finding 24)

**Plans**: TBD
**UI hint**: yes
**Findings**: 24, 37.

### Phase 8: Swap & bridge

**Goal**: Swap and bridge wear the redesign and keep develop's route/fee/slippage logic
**Depends on**: Phase 7
**Requirements**: SCR-04
**Success Criteria** (what must be TRUE):

  1. The swap screen renders in the redesign skin and a quote returns with develop's route, fee and slippage figures unchanged
  2. A failed route fetch shows the user an error notice — the "You Receive" field never just goes stale in silence (finding 22)
  3. Submitting a swap produces develop's outcome (toast + success drawer + a transaction recorded and persisted), or the deliberate deviation is re-confirmed and written down as a decision — not left as a demo snackbar by accident (finding 21)
  4. A bridge result shows its success/error toast alongside the result dialog (finding 28)

**Plans**: TBD
**UI hint**: yes
**Findings**: 21, 22, 28.

### Phase 9: Banxa

**Goal**: The fiat on-ramp wears the redesign and keeps develop's rework
**Depends on**: Phase 4
**Requirements**: SCR-05, GAP-05
**Success Criteria** (what must be TRUE):

  1. Buy, KYC, checkout and order history/details render in the redesign skin and a buy flow runs end to end
  2. Completing KYC pops the webview and returns success to the caller — the redirect matches `BanxaApiService.redirectUrl`, not a placeholder (finding 1 — a blocker)
  3. The checkout QR scans in both light and dark appearance (finding 6), and opening Banxa KYC on Linux falls back to the browser instead of crashing (finding 7)
  4. The develop-only Banxa additions (`banxa_orders_history.dart`, `banxa_payment.dart`, `banxa_buy_screen.dart`) wear the extended design language per the Phase 3 treatment

**Plans**: TBD
**UI hint**: yes
**Findings**: 1, 6, 7. **Covers GAP-05**.

### Phase 10: dApp connectivity

**Goal**: Reown/WalletConnect wears the redesign and initializes everywhere develop did
**Depends on**: Phase 4
**Requirements**: SCR-06
**Success Criteria** (what must be TRUE):

  1. The connect button and session UI render in the redesign skin
  2. A dApp pairing completes on x64 Windows desktop — WalletKit initializes rather than being skipped by an architecture check (finding 3 — a blocker)
  3. Pressing connect twice concurrently initializes WalletKit exactly once (develop's idempotent Completer guard, not an arch check)
  4. When init has failed, pressing connect retries it and, if it fails again, tells the user to restart the app rather than failing silently (finding 20)

**Plans**: TBD
**UI hint**: yes
**Findings**: 3, 20.

### Phase 11: Port closeout

**Goal**: The redesign is confirmed landed and non-regressive across the whole app
**Depends on**: Phases 5, 6, 7, 8, 9, 10
**Requirements**: BEH-01
**Success Criteria** (what must be TRUE):

  1. Every one of the 37 findings in `.planning/REVIEW_FINDINGS_REDESIGN.md` is confirmed non-regressed by running the app, each with a recorded observation — or consciously accepted with a written reason
  2. A single walk from cold start through onboarding, dashboard, token, swap, Banxa and dApp connect completes with no runtime exception and no screen still wearing develop's old skin
  3. Windows debug and release builds both succeed and `flutter analyze` reports 0 errors

**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11

Phases 5–10 depend only on Phase 4 and are independent of each other; numeric order reflects risk
sequencing (biggest surface first, most-collided integrations once the design system has settled),
not a hard dependency chain. Each is independently landable on develop.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Adopt GSD | 1/1 | ✓ Complete | 2026-07-15 (PR #207) |
| 2. Design tokens & verification loop | 2/5 | In Progress | - |
| 3. gw_* component library | 0/10 | Planned | - |
| 4. Navigation shell & chrome | 0/TBD | Not started | - |
| 5. Dashboard | 0/TBD | Not started | - |
| 6. Onboarding | 0/TBD | Not started | - |
| 7. Token screens | 0/TBD | Not started | - |
| 8. Swap & bridge | 0/TBD | Not started | - |
| 9. Banxa | 0/TBD | Not started | - |
| 10. dApp connectivity | 0/TBD | Not started | - |
| 11. Port closeout | 0/TBD | Not started | - |
