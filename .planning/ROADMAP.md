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

`.planning/reference/REVIEW_FINDINGS_REDESIGN.md` records 37 evidenced defects in the design-vs-develop
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

**CORRECTION (2026-07-23):** the long-held "`flutter test` does not compile / no working test harness"
claim is **FALSE** — measured, the suite runs at **234 pass / 1 fail** (the 1 fail is the fully
commented-out `test/local_wallet_storage_test.dart`, not a compile failure). Real test gates ARE
available; prefer them where behaviour can be asserted. That said, many success criteria below remain
TRUE/FALSE statements only a **human walk** can settle (visual fidelity, contrast in situ, feel) —
debug build + visual walk. `flutter analyze` is a gate, never evidence.

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
- [x] **Phase 4: Navigation shell & chrome** - Shell, header chrome, Settings and SDK account manager wear the redesign (7/7 plans; 04-VERIFICATION.md = passed 6/6, 2026-07-18)
- [x] **Phase 5: Dashboard** - Balances, holdings, transactions, markets, news (completed 2026-07-21)
- [x] **Phase 6: Onboarding** - Create, import, recovery phrase, verify, legal, select-wallet-type (completed 2026-07-23 — 6/6 plans; fresh-install walk PASSED all 4 criteria)
- [ ] **Phase 7: Token screens** - Token info, send, receive, address book, charts
- [ ] **Phase 8: Swap & bridge** - Squid Router and GNUS bridge
- [ ] **Phase 9: Banxa** - Buy, KYC, checkout, order history/details
- [ ] **Phase 10: dApp connectivity** - Reown/WalletConnect
- [ ] **Phase 11: Port closeout** - Full-app walk; all 37 findings signed off (now also signs off the redesign-track surfaces 12/13/14/15/16/17 + the shadow-name baseline)

### Surface ownership map (2026-07-23 — one surface, one owning phase; no overlap)

After the scope reassignment, **each user-visible surface has exactly one canonical owner.** Where a
redesign-track phase supersedes a Phase 5 first pass, Phase 5's version is historical only.

| Surface | Canonical owner | Superseded / fenced |
|---------|-----------------|---------------------|
| Dashboard shell + holdings/balances (Assets panel only — NOT the hero) | **Phase 5** | — |
| Compute / wallet-overview first card | **Phase 14** | supersedes Phase 5 (05-01/05-02) |
| Transactions (dashboard panel) | **Phase 12** | supersedes Phase 5 (05-06) |
| Transactions (`/transactions` tab) | **Phase 15** (extends 12) | supersedes Phase 5 (05-06, shared `transactions_slim_view`) |
| Markets (`/markets` tab) | **Phase 16** | supersedes Phase 5 (05-04); fenced OUT of Phase 7 |
| News (`/news` tab) | **Phase 17** | supersedes Phase 5 (05-05) |
| Boot / splash / loading | **Phase 13** | — |
| Token detail, send, receive, address book | **Phase 7** | market data → 16; chart re-skin → 5 (inherited) |
| Token-detail chart (`crypto_live_chart`) | **Phase 5** (quick `260721-dws`) | Phase 7 inherits; only the finding-24 lifecycle fix is Phase 7's |
| Swap & bridge | **Phase 8** | page frame already unified by `99a8913` (don't re-do) |
| Banxa | **Phase 9** | — |
| dApp / Reown | **Phase 10** | — |
| Shared `gw_*` primitives + tokens | **Phase 3** (extensions signed off in **Phase 11**) | 16/17 added hoverLift, GWSearchField, empty-state anchor |

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

**Plans**: 10/10 plans executed — phase verification (`03-VERIFICATION.md`) records 2/6 criteria PASS, 3/6 PARTIAL, 1/6 OUTSTANDING (the no-visual-change walk); phase header checkbox stays unchecked until that walk closes
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
- [x] 03-08-PLAN.md — GAP-01: whole-app inventory and treatment decision (GAP-01)
- [x] 03-09-PLAN.md — Gallery extension: the missing primitives, light/dark, drawer + QR + error state (DS-03)
- [x] 03-10-PLAN.md — No-visual-change walk and the phase verification record (DS-02, DS-03, DS-04, GAP-01)

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

**Plans**: 7/7 plans executed — all re-skins walked and PASSED; phase-level verification (goal-backward against criteria 1-6) still to run before the phase header is checked

- [x] 04-01-PLAN.md — Theme-only linchpin: appearance-aware theme.dart, OS-follow first launch, MaterialApp ValueListenableBuilder wrap, gallery revert; ends with the D-02 re-walk gate (D-01/D-02/D-03)
- [x] 04-02-PLAN.md — D-02 corrective: appearance ThemeExtension migration (const components re-skin on live toggle) + bundle Inter (offline fix). D-02 gate CLOSED via re-walk; dark-only count = 3 (disabled checkbox/switch, AppScreenView blank in dark) routed to gap-closure todos
- [x] 04-03-PLAN.md — Nav shell chrome re-skin on develop's ShellRoute (desktop top bar + mobile bottom nav on GWColors, 8 destinations, no Cubit). Shell walk PASSED (flips live, WCAG, all routes) — NAV-01/NAV-02, criteria 1+2. (04-04..07 pre-aligned to GWColors.)
- [x] 04-04-PLAN.md — Wallet drawer re-skin (+ shared card/dialog/drawer chrome to GWColors) + boot/toast verify. Walk PASSED after fixing a dialog-action navigator bug (3457e44). UX polish (row tap-target, address truncation, balance format, padding) captured as todos — NAV-02, criteria 3+4, D-06/D-07
- [x] 04-05-PLAN.md — Settings screen re-skin in place (GWScreen/GWCard/GWColors + config controls). Walk PASSED (skin + controls + both modes). Appearance toggle deferred to a follow-up — GAP-02, criterion 5
- [x] 04-06-PLAN.md — SDK account manager re-skin in place (key-entry dialogs on GWDialog w/ root-navigator pops, no key logging). Walk PASSED. UX polish (add-dialog validation, drawer loading state) captured as todos — GAP-03, criterion 5
- [x] 04-07-PLAN.md — Branded build-time-exception recovery screen (kept static getters — renders above Theme) + SDK-shutdown verify. Walk PASSED: branded recovery in both modes, Go-to-Dashboard escapes, SDK shutdown GENIUS_NODE_RET_OK on close — BEH-02, criterion 6

**UI hint**: yes
**Carries**: `7a63b4f` (`!_dirty` guard) — DEFERRED to the swap-FAB phase per D-08 (its target `GlobalSwapFabHost` is not built this phase; carry-move, not a drop). **Findings**: 2, 4, 5, 11, 12, 23, 27, 35.

### Phase 5: Dashboard

> **SCOPE REASSIGNMENT (2026-07-23) — read before treating any Phase 5 surface as the live version.**
> Phase 5 delivered the FIRST re-skin of every dashboard surface, but four of them were later
> SUPERSEDED by a deeper redesign-track pass. Phase 5's *live* ownership is now narrowed to
> **the dashboard shell + balances (hero/overview after 14) + holdings (Assets panel)**. The rest moved:
> - **Transactions** (05-06) → **superseded by Phase 12** (redesign) + **Phase 15** (tab). Canonical owner: 12/15.
> - **Markets** (05-04) → **superseded by Phase 16** (Markets page). Canonical owner: 16.
> - **News** (05-05) → **superseded by Phase 17** (News page). Canonical owner: 17.
> - **Compute / wallet-overview first section** (05-01/05-02) → **superseded by Phase 14**. Canonical owner: 14.
>
> Phase 5 stays CLOSED as a historical record (its plans/walks happened); do NOT re-open or re-do those
> four surfaces here — edit them in their canonical phase above.

**Goal**: The dashboard wears the redesign and keeps every behavior develop shipped
**Depends on**: Phase 4
**Requirements**: SCR-01, GAP-06
**Success Criteria** (what must be TRUE):

  1. Balances, holdings, transactions, markets and news all render in the redesign skin and match the Release exe at `GeniusWallet-3514`
  2. Pull-to-refresh works on the dashboard, the transactions list and the news feed, and each reloads its data (findings 10, 17, 18)
  3. When wallet or account load fails the dashboard shows an error message with a working retry — never an endless spinner — and the hero balance does not render before the account has loaded (findings 8, 9, 29)
  4. Market data refreshes once a minute, not every 20 seconds (finding 14 — the 20s interval risks CoinGecko 429s)
  5. Walking the dashboard with long values, empty symbols and a filtered transaction list produces no RenderFlex overflow and no crash, and the transaction count footer is present (findings 30, 31, 32, 33, 34)

**Plans**: 8/8 plans complete (05-01..05-06 executed and walked; 05-07 and 05-08 are gap-closure
plans, both executed and walked). **Phase CLOSED 2026-07-21 with 3 explicit user-authorized
overrides** — see `05-VERIFICATION.md`'s `overrides:`/`## Acknowledged Gaps`.

- [x] 05-01-PLAN.md — Shared dashboard chrome: DashboardScrollContainer + shared Loading + FutureStateWidget default states (GAP-06 loading.dart) — criteria 1, 2, 3
- [x] 05-02-PLAN.md — Hero balance / wallet overview re-skin (GAP-06 wallet_overview.dart; wallets_overview.g.dart shadow read-only) — criteria 1, 3
- [x] 05-03-PLAN.md — Holdings list re-skin + verify 1-min market refresh (finding 14) — criteria 1, 4, 5
- [x] 05-04-PLAN.md — Markets re-skin (grid + GWTextField search + sparkline cards, error/retry) — criteria 1, 3, 5
- [x] 05-05-PLAN.md — News feed re-skin (develop's StaggeredGrid kept) — criteria 1, 2
- [x] 05-06-PLAN.md — Transactions re-skin in place (count footer, overflow-safety, SegmentedButton kept) (GAP-06 transaction_displays.dart) — criteria 1, 2, 5
- [x] 05-07-PLAN.md — **Gap closure**: working Retry on the dashboard failure branch — dispatches `FetchAccount()` (the only writer of `accountStatus`) as well as `LoadWallets()`, beside develop's preserved "Something went wrong!" — criterion 3. Walked & approved 2026-07-21.
- [x] 05-08-PLAN.md — **Gap closure**: `WalletsOverview` overflow (B1) fixed via a structural scroll wrapper + a new dev fixture making the SGNUS/processing state reachable for the first time; Markets error/empty branches (B2) routed through `GWErrorState`/`GWEmptyState` inside `DashboardScrollContainer` — criteria 1, 5. Task 4 walked & approved 2026-07-21, closing B1, B2 and the outstanding `260721-e3r` (`GWEmptyState`) re-walk — but surfaced a NEW, distinct third overflow site (`crypto_live_chart.dart:315`, out of this plan's scope) that keeps criterion 5 FAILED.

**UI hint**: yes
**Findings**: 8, 9, 10, 14, 17, 18, 29, 30, 31, 32, 33, 34. **Covers GAP-06**: `wallet_overview.dart`, `loading.dart`, `transaction_displays.dart`.
**Phase sign-off status (CLOSED 2026-07-21):** All 8 plans executed and walked. Criteria 3 and 4
VERIFIED outright. Criteria 1, 2 and 5 close on **explicit user-authorized overrides**, not on
having passed — see `05-VERIFICATION.md`'s `overrides:` frontmatter and `## Acknowledged Gaps`
section for the full reasoning behind each:

- **Criterion 5** ("no RenderFlex overflow") — `crypto_live_chart.dart:315`'s zoom/pan row still
  overflows by 34px, on a single site unrelated to any of this phase's own plans' file scope. The
  user live-inspected the app, confirmed it is a dashboard-card-height limitation (not a component
  defect), and rejected the considered stopgap (`260721-gx1`) as cosmetic. New todo filed:
  `2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`.

- **Criterion 1** (clause 2, "match the Release exe") — code-level gaps all resolved; the
  side-by-side walk itself has never been performed, though the reference exe is now present on
  this machine.

- **Criterion 2** (pull-to-refresh) — wiring confirmed at all three sites; the transactions/news
  reload completion has never been directly observed (dashboard leg is observed).

### Phase 6: Onboarding

**Goal**: A new user can create or import a wallet through the redesigned flow with no loss of key safety
**Depends on**: Phase 4
**Requirements**: SCR-02, GAP-04
**Success Criteria** (what must be TRUE):

  1. Create-wallet, import-wallet, recovery-phrase, verify and legal screens all render in the redesign skin and complete end to end on a fresh install
  2. The recovery phrase stays read-only, the hide-toggle works, and no seed phrase appears in debug console output at any point in the flow
  3. Copying the recovery phrase on desktop shows its confirmation without throwing after the screen is dismissed mid-copy (finding 19 — missing `mounted` guard)
  4. The select-wallet-type step (develop-only, no mockup) wears the extended design language per the Phase 3 treatment and still routes correctly through `wallet_routes.dart`

**Plans**: 6 plans

- [x] 06-01-PLAN.md — Onboarding chrome: `/landing_screen` entry (deepBlue trap killed, GWMeshBackground, 3 GWButton CTAs) + both flow shells' transparent AppBar — criterion 1 — CLOSED 2026-07-21, walked & approved on a genuine fresh install (mesh KEPT after a live light-mode gate; walk-driven Rule-1 narrow-width gutter fix, commit `67e2821`; see `06-01-SUMMARY.md`)
- [x] 06-02-PLAN.md — Shared Legal step + **GAP-04**: wallet-type row → GWWalletCard (1:1 swap, `GWWalletCard`'s first real consumer) and `wallet_routes.dart` typography-only — criteria 1, 4
- [x] 06-03-PLAN.md — Recovery-phrase + verify-recovery-phrase re-skin (security-critical; read-only grid, `_isVisible` default, finding-19 `mounted` guard preserved) — criteria 1, 2, 3
- [x] 06-04-PLAN.md — Import security + PasteField re-skin **+ the §3.6 IME hardening** (`autocorrect`/`enableSuggestions` false on the mnemonic/private-key field — a deliberate, recorded behavior addition) — criterion 1
- [x] 06-05-PLAN.md — Shared `screens/pin_screen.dart` re-skin **+ fixes the invoke-during-build Continue defect** (closure-wrapped `onCompleted`, type tightened to `void Function(String)` so the analyzer guards it) — criterion 1
- [x] 06-06-PLAN.md — Phase close: `tool/check_onboarding_seed_safety.sh` (UI-SPEC §3's six-item gate over the finished tree) + the **fresh-install end-to-end walk of BOTH flows** (no mock injectors — the Phase 05 fixture-blindness lesson) + 5 filed todos for the deliberately-unfixed gaps — criteria 1, 2, 3, 4 (CLOSED 2026-07-23; gate all-six PASS `bec9c03`, todos `3d7aa07`, walk PASSED — see 06-06-SUMMARY.md)

**UI hint**: yes
**Findings**: 19 — **already fixed on develop** (`recovery_phrase_screen.dart:105`); Phase 6 closes criterion 3 by PRESERVATION, not by a fix. **Covers GAP-04**: `select_wallet_type_screen.dart`, `wallet_routes.dart` (closed entirely by 06-02).

### Phase 7: Token screens

**Goal**: Token detail, send, receive and address book wear the redesign
**Depends on**: Phase 5

> **SCOPE FENCE (2026-07-23) — token-detail surfaces ONLY.** To keep this phase non-overlapping:
> - **The Markets *tab* is NOT in scope** — it is **Phase 16** (`markets_screen.dart` + hero/table). "Market
>   data" here means only the token's OWN price/data on the token-detail screen, never the `/markets` page.
> - **The token-detail chart re-skin is already done** — `crypto_live_chart.dart` was re-skinned in Phase 5
>   (quick task `260721-dws`). Phase 7 INHERITS it; do NOT re-skin the chart. Phase 7's only chart work is
>   the finding-24 lifecycle fix below.

**Requirements**: SCR-03
**Success Criteria** (what must be TRUE):

  1. Token info (incl. its own token-level price/data), send, receive and address book render in the redesign skin and match the Release exe reference — **NOT the Markets tab (Phase 16)**
  2. A send completes end to end and a receive QR scans with a real phone camera in both light and dark appearance
  3. Tapping "More" on a non-GNUS token does nothing (the button is disabled) rather than opening an empty drawer (finding 37)
  4. Leaving a token chart mid-fetch, or while its refresh timer is running, throws no `setState after dispose` (finding 24) — the inherited (Phase 5) chart's lifecycle fix, not a re-skin

**Plans**: 3 plans
- [x] 07-01-PLAN.md — re-skin token-detail (ActionButton, Info/Convert cards, both drawers) + lock finding 37 + light-QR (executed 2026-07-23, `639fe60`/`c3141f6`/`dc0b705`, analyze 61 baseline)
- [x] 07-02-PLAN.md — finding-24 chart lifecycle mounted guards (no re-skin) (executed 2026-07-23, `35fef28`, verify PASS)
- [ ] 07-03-PLAN.md — human walk: dark+light fidelity, QR phone-scan, disabled states, clean console (blocking; NEXT)
**UI hint**: yes
**Findings**: 24, 37.
**Inherits from Phase 5**: `lib/chart/crypto_live_chart.dart` was ALREADY re-skinned inside
Phase 5, by quick task 260721-dws (sketch 006 variant A→), which landed in `0bcf3df` via PR
#210. Phase 7 inherits a largely re-skinned chart — do NOT budget for a full re-skin of this
file. The superseded assumption, named so it is not resurrected: the 2026-07-20 Phase 5
verification had deferred the WHOLE chart re-skin to Phase 7, on the grounds that no 05-*
plan touched the file and 8 raw `Colors.white`/`Colors.grey[400]` values survived. Both
grounds are now false; `05-VERIFICATION.md`'s `deferred` block marks that item
`status: superseded`. The residue Phase 7 DOES inherit, re-counted at HEAD 2026-07-21:
exactly 4 raw values survive, all `Colors.white`, all on the zoom/pan `IconButton` row —
lines 455, 463, 471 and 480. Every `Colors.grey[400]` is gone. Tracking todo:
`.planning/todos/pending/2026-07-21-chart-zoom-pan-icons-still-raw-colors-white.md` — the
residue is expected to be closed by the deferred light-mode AA pass, and may be deleted
outright if the zoom/pan controls are removed when real timeframe ranges are wired.

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
**Depends on**: Phases 5, 6, 7, 8, 9, 10 — **and the redesign track 12, 13, 14, 15, 16, 17**

> **EXPANDED SCOPE (2026-07-23).** Beyond the original 37 findings, closeout now also signs off the
> redesign-track surfaces that landed in parallel: **Transactions (12/15), Boot (13), Compute (14),
> Markets (16), News (17)** — including the **outstanding walks for 16/17** and the **incomplete
> 13-04/13-05** — and must **resolve the shadow-name baseline** (`verify_additive_boundary.sh` is red on
> `_TimeframeSegment`/`_SplashState` added by 16/boot). No surface may still wear develop's old skin, old
> OR new track.

**Requirements**: BEH-01
**Success Criteria** (what must be TRUE):

  1. Every one of the 37 findings in `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` is confirmed non-regressed by running the app, each with a recorded observation — or consciously accepted with a written reason
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
| 2. Design tokens & verification loop | 5/5 | ✓ Complete | 2026-07-16 |
| 3. gw_* component library | 10/10 | Executed — walk-gated (03-VERIFICATION 3 PASS / 3 PARTIAL) | - |
| 4. Navigation shell & chrome | 7/7 | ✓ Complete (04-VERIFICATION passed 6/6) | 2026-07-18 |
| 5. Dashboard | 8/8 | ✓ Complete (3 overrides recorded — see 05-VERIFICATION.md) | 2026-07-21 |
| 6. Onboarding | 6/6 | ✓ Complete (fresh-install walk PASSED all 4 criteria) | 2026-07-23 |
| 7. Token screens | 0/TBD | Not started | - |
| 8. Swap & bridge | 0/TBD | Not started | - |
| 9. Banxa | 0/TBD | Not started | - |
| 10. dApp connectivity | 0/TBD | Not started | - |
| 11. Port closeout | 0/TBD | Not started | - |

**Redesign track (Phases 12-17)** — landed on this same branch in parallel with the official track
above; tracked separately (see the per-phase detail sections below):

| Phase | Plans Complete | Status | Committed |
|-------|----------------|--------|-----------|
| 12. Transactions redesign | 5/6 | Executed — 12-06 walk next | `8cb4222` |
| 13. Boot & loading sequence | 2/5 | 13-01/02/03 committed; 13-04/05 outstanding | `29b183b` |
| 14. Compute panel & job flow | 0/TBD | Design-only (sketches 016-018); unplanned | - |
| 15. Transactions tab | 5/6 | Executed — 15-06 walk next | `8cb4222` |
| 16. Markets page (H1) | ahead-of-plan | Implemented & committed; walk + verification outstanding | `aa78eec` |
| 17. News page (B2) | ahead-of-plan | Implemented & committed; walk + verification outstanding | `651541c` |

### Phase 12: Transactions redesign

> **CANONICAL OWNER of the transactions surface (2026-07-23).** Supersedes Phase 5's first-pass
> transactions re-skin (05-06). The dashboard transactions *panel* and (with Phase 15) the `/transactions`
> *tab* are edited here, not in Phase 5.

**Goal:** The transactions surface reads as one system: every one of the seven `TransactionType`
values renders through a single row anatomy, every type and status is reachable by a filter, and a
wallet with no matching rows says which of the two "empty" situations it is in.

**Requirements**: derived from the shipped-panel diagnosis in sketch 010 (see Design contract below)

**Depends on:** Phase 5 (Dashboard) for `GWTokenRow`, `GWSectionTitle`, `GWEmptyState` and the
homepage `Divider` pattern this phase reuses verbatim. Not blocked by Phase 6.

**Design contract:** `.planning/sketches/010-014` — decided and locked 2026-07-22:

- Row hierarchy: **token-first** (010-A) — the asset is the headline, the action a quiet chip.
- Badges (18px, knocked-out glyph on a filled circle): Sent = Slate `#64748B`, Received =
  `statusSuccess`, **Mint = `brandTertiary #C28FFF` with a pickaxe glyph**, **Processing job =
  `brandPrimaryStrong #0AAEE6` with a server glyph**, Escrow = Slate, Pending = `statusWarning`,
  Failed = `statusError`.

- Filters: **F1 two-tier** — title row order is **Sent · Received · Mint · Jobs** (007-C compact
  segmented control); **Escrow**, swap, purchase plus the two statuses move into an overflow menu with
  live counts. Active chip is the **`brandCta` gradient, never flat blue**. Inside the overflow
  menu the active item takes **gradient TEXT on the label only** — the glyph never changes with
  selection, same icon and same colour whether active or not — painted the way the app already
  does it — `ShaderMask(BlendMode.srcIn)` over `GeniusWalletGradient.brandCta`, the same technique
  as `GWButtonVariant.gradientOutline` (`gw_button.dart:299`) and `GWViewAllLink`
  (`gw_view_all_link.dart:65`). Never a flat accent colour. When the active filter
  lives in the overflow menu, the `⋯` trigger itself takes the gradient so an applied filter is
  never invisible. Desktop keeps the animated expand-to-label; **narrow/mobile is icon-only**.

- Fixes carried by the row rewrite: amounts clamped (2 dp ≥1000, else 6) with the exact value
  preserved on hover and tabular figures; fiat value on every row; `Fee:` removed from the resting
  row; repeated relative time replaced by day separators plus a real timestamp; status shown only
  when it is not the happy path; per-row cards replaced by one surface with hairline `Divider`s.

**Known coverage bug this phase closes:** `Filters` (`transactions_slim_view.dart:16`) is
`{all, sent, received, escrow, mint}` while `TransactionType` has seven values — `swap`, `purchase`
and `process` are unreachable by any filter today.

**Plans:** 6 plans

Plans:

- [x] 12-01-PLAN.md — Badge foundation: Slate token, 9-kind glyph/colour table, `TransactionBadge`, pickaxe asset, per-appearance AA test
- [x] 12-02-PLAN.md — Pure derivation in `transaction_utils.dart`: clamped amount + exact-value tooltip + fiat, one row-content record for all 7 types, day grouping
- [x] 12-03-PLAN.md — Collapse 4 row widgets into one `TransactionRow` + one detail drawer; hairline dividers replace per-row cards
- [x] 12-04-PLAN.md — `Filters` coverage fix (swap/purchase/process reachable) + F1 two-tier filter bar with gradient active states
- [x] 12-05-PLAN.md — Panel assembly: day separators, two distinct empty states, fixed-size footer, freeze sweep; extended dev mock batch
- [ ] 12-06-PLAN.md — End-of-phase human walk (dark rows/badges, filters + empty states, light-mode deferral record)

### Phase 13: Boot & loading sequence — Signal Edge splash and one shared dashboard gate

**Goal:** A cold start shows one branded boot screen that never looks hung, then reveals a
*complete* dashboard — no per-section loaders assembling in front of the user.

**Design:** approved in `.planning/sketches/015-boot-loading-sequence/` (winner: **C · Signal
Edge**). `GWMeshBackground` + large centred logo + bottom-left `STATUS` kicker and status text in
solid grey `#8A8F9D` + a full-bleed cyan→mint gradient hairline on the bottom edge. Held line
`Preparing your wallet…` through the frozen window; then a ~1.5 s closing run of three
confirmations (`Wallets ready` → `Balances ready` → `Markets ready`) while the rail sweeps to
full; then the dashboard.

**Measured constraints (spikes 001/002 — these are non-negotiable, not preferences):**

- `GeniusSDKInitWithMnemonic` blocks the Dart main isolate **~9.6 s**. Nothing can animate before
  then — no spinner, blur or progress bar. Moving it to `Isolate.spawn` does **not** help
  (spike 001 INVALIDATED; a control run logged zero timer ticks and the bindings are all
  non-leaf). The rail therefore sits at 0 while frozen.

- The SDK **stalls at 52.5%** on `"Initializing blockchain service"` indefinitely (161 polls
  across 40 s; never reaches 100%). **The dashboard must NEVER gate on
  `getInitializationStatus()`** — doing so would hang the app forever.

- Dashboard data is ready at **141 ms** (wallets 0 ms, transactions 140 ms, balances 141 ms). The
  only real wait is the freeze. The closing run's 1.5 s is a **minimum hold** that also covers the
  markets/chart fetch.

**In scope:**

1. Re-skin `lib/screens/splash.dart` to the Signal Edge composition (swap `Loading()` out).
   **Hazard:** `lib/components/splash.dart` is a same-named SHADOW — the routed file is
   `lib/screens/splash.dart` (`navigation/router.dart:30`). See `03-SHADOW-NAMES.md`.

2. Closing-run sequencer: three confirmation statuses + rail sweep, minimum ~1.5 s hold.
3. Widen the dashboard gate (`dashboard_screen.dart:70`) and remove per-section loaders —
   `coins_screen.dart:209` (`Loading()`) and `crypto_live_chart.dart:523` (`PulsingSkeleton`).

4. Timeout + cached-data fallback on the markets/chart network leg (a live run was captured with
   DNS down; the app only booted because markets fail soft onto cache).

5. Single-flight guard on `initSDK` — it currently runs twice at boot, throwing a caught
   `LateInitializationError: Field '_basePath' has already been initialized`.

6. Move the splash off legacy `deepBlue` (`#14253D`) to `surfaceBase` (`#0B0D12`), keeping it
   **mode-invariant** — the logo is a white wordmark that vanishes on a light surface, and
   `splash.dart:24` already pins a fixed dark background via a `static const`.

**Walk gates:** the `STATUS` kicker is `rgba(255,255,255,.38)` — the weakest pair on the screen
and it sits over the mesh, so verify it live in both themes. Also confirm whether
`GWMeshBackground`'s 36 s drift controller produces a visible jump when the freeze lifts
(it advances ~27% in one frame on resume) — expected to be masked by the handover, unverified.

**Requirements**: BEH — boot must not read as hung; dashboard must present complete.
**Depends on:** Phase 5 (Dashboard — supplies the gate and the sections whose loaders are removed)
**Plans:** 5 plans

Plans:

- [x] 13-01-PLAN.md — Single-flight `initSDK` (E1) + make `getCoins()` a truthful, always-settling Future; one instrumented cold start MEASURES the coins leg (research open question 1)
- [x] 13-02-PLAN.md — Bound all three CoinGecko fetches at a shared 3s timeout (M5/SC3); plain-Dart `BootSequence` closing-run engine + its runnable check (`dart run tool/boot_sequence_check.dart`)
- [ ] 13-03-PLAN.md — Re-skin the ROUTED `lib/screens/splash.dart` to Signal Edge (D1-D8) driving `BootSequence`; boot-screen walk in BOTH themes incl. the kicker over the mesh and the H3 resume jump
- [ ] 13-04-PLAN.md — Widen the dashboard gate as a FIRST-PAINT latch + remove all three per-section loaders (E2, incl. the chart's second, textual cue); dashboard-entry walk
- [ ] 13-05-PLAN.md — Remove the temporary timing instrument; phase walk of SC1-SC5 in both themes and once with the network down

### Phase 14: Compute panel & job flow — the first dashboard section

> **CANONICAL OWNER of the dashboard's compute / wallet-overview first section (2026-07-23).**
> Supersedes Phase 5's hero/wallet-overview re-skin (05-01/05-02) for that first card. Balances/holdings
> elsewhere on the dashboard remain Phase 5's.

**Goal:** The dashboard's first section stops lying. The left card becomes two labelled tiles —
a balance readout and a compute node — one status component tells the truth in all nine states the
node actually enters, and requesting a processing job is a visible flow instead of a flat form
ending in a toast full of hex.

**Requirements**: derived from a read of the shipped code in sketches 016-018 (see Design contract)

**Depends on:** Phase 5 (Dashboard) for `DashboardScrollContainer`, `GWSectionTitle`, `GWButton`
and the `Divider` pattern; `ResponsiveDrawer` (already shipped, used by Receive). **Not** blocked by
Phase 13 — the boot gate and this card do not touch the same code.

**Design contract:** `.planning/sketches/016-018` — decided and locked 2026-07-22:

- **Layout: 016-B2 · Twin tiles.** Balance tile and Compute tile as siblings of equal rank inside
  the existing card; CTA on the card floor below both. Replaces the centred six-widget stack in
  `wallet_overview.dart:108-190`, which has no section title unlike every other dashboard panel.
- **Status: 017-A · Dot + label.** One component replaces the two stacked status widgets
  (`SGNUSConnectionWidget` + `SGNUSConnectionStatusWidget`). A ring is explicitly rejected here:
  its grammar is "this will fill up", which is why the shipped UI cannot render *stalled* or
  *unavailable* without lying. The ring survives only in the 56px `GWAiFab` (design-branch
  component, unported), under the rule **no live percentage → no ring**.
- **Job flow: 018-A · Drawer with vertical steps.** `ResponsiveDrawer` — a 420px right-edge panel
  on desktop, a bottom sheet on mobile. Completed steps collapse to a one-line summary and stay on
  screen, because step 3 asks the user to confirm spending money decided in step 2. `/submit_job`
  is kept as the full-screen host for deep links, rendering the same step bodies.

**Height budget — a hard constraint, not a guideline:** the card is capped at `maxHeight: 300`
(`dashboard_screen.dart:207`) and `DashboardScrollContainer` eats 24px, leaving **276px**. B2 is the
tightest layout of the four sketched: **worst state 261px, +15px headroom.** It fits only because
the centred "why" row merged into the status sub-line (reason and remedy share one line). **Anything
added to the compute block breaks B2 first.** The `+12.4 GNUS earned` readout is excluded and stays
out of scope — it needs a mint/job-reward aggregate no current API exposes.

**Bugs this phase closes (all measured or read out of shipped code):**

1. **The 52.5% lie.** `sgnus_connection_widget.dart:85` draws a determinate ring from
   `getInitializationStatus()`. Measured over 161 polls / 40s: it reaches `0.525` and never moves
   again. Needs a **stall detector** — same percentage across N consecutive polls flips the state.
2. **The silent death.** `app_bloc.dart:193-196` cancels `_processingTimer` **permanently** on any
   exception and emits `isProcessing:false`. Nothing restarts it, so a dead feed is pixel-identical
   to a healthy idle node. Needs a **`RetryProcessingStatus` event** that re-arms the timer, plus a
   state flag separating "unavailable" from "idle".
3. **The vanishing button.** `submit_job_dashboard_button.dart:25` returns `SizedBox.shrink()` when
   the selected wallet is not the SGNUS-linked one — the section's primary action disappears with no
   explanation. It already holds both addresses and discards the information.
4. **Zero balance painted as failure.** `wallet_overview.dart:141-147` renders `'No funds available'`
   in `statusError` red, against this milestone's guiding principle.
5. **Hardcoded `Colors.white`.** `genius_balance_display.dart:80` — the 48px balance is a literal,
   not `gw.textPrimary`, so it vanishes in light mode.

**Affordance audit (from sketch 016's README) — two build items, named so they don't surprise:**

- `switch wallet ›` — the mechanism exists in full
  (`AccountDropdownSelector._showAccountDrawer()` → `ResponsiveDrawer<Wallet>` → `selectWallet()`)
  but is **private** and mounted only in the top-bar action row (`responsive_overlay.dart:103`).
  Extract a public `AccountDrawer.show(context)`. Small, no new UI.
- `View transaction ›` — `showTransactionDetails()` exists
  (`transaction_displays.dart:316`); what is missing is the **association** between a finished job
  and the mint transaction it produced. If the correlation proves expensive, drop this link rather
  than growing the block — see the height budget.
- `Node ›` / `see node status ›` → `/network` (`router.dart:188`), already live. The page is raw
  `ListTile`s with `Colors.green`/`Colors.red`; re-skinning it is **out of scope here** and belongs
  to a follow-up sketch (next free number — 019 is `dashboard-separators`, 022 is the current high
  water mark, so the `/network` re-skin sketch is **023**).

**Known unit clash, accepted:** this card shows `1,204.50 GNUS` (SDK poll, 10s) while the Assets
panel 12px away shows `$312.40` (CoinGecko, 60s) — the same money, two units, two intervals, so they
will routinely disagree. B2 keeps it, mitigated by an `≈ $` subline. Sketch 016-B3 resolves it
outright by adopting fiat and is the recorded fallback.

**Not all nine states are free.** Six are derivable from data that already exists (no wallet, not
linked, initializing, ready, processing, disconnected). Three need new code: *stalled* (detector),
*job complete* (edge-detect on `isProcessing` true→false + tx correlation), *unavailable* (the
restartable timer above).

**Plans:** TBD

Plans:

- [ ] TBD (run /gsd-plan-phase 14 to break down)

### Phase 15: Transactions tab — page frame, filter rail, empty-state anchor, amount honesty

> **CANONICAL OWNER of the `/transactions` tab (2026-07-23), with Phase 12.** Extends Phase 12's row/
> filter rewrite onto the full-page tab. Together, 12 + 15 own the transactions surface; Phase 5's 05-06
> is superseded.

**Goal:** `/transactions` stops being the dashboard panel in a bigger window. It becomes a page with
its own frame and a filter rail that uses the width, its empty state stops drifting to the vertical
midpoint, and the two rows where money did not simply move stop printing a dash where the number
belongs.

**Requirements:** TT-01 (page frame), TT-02 (filter rail), TT-03 (rail states), TT-04 (empty-state
anchor), TT-05 (empty-state icon + filter control hidden when there is nothing to filter), TT-06
(amount honesty) — derived from a read of the shipped route in sketches 020-022 (see Design
contract)

**Depends on:** Phase 12 (all of it — this phase extends `Filters`, `filterCounts()`, `badgeGlyph()`
and `transaction_utils.dart`, and **amends** 12-02's amount rules). Phase 5 for `GWPageHeader`,
`DashboardScrollContainer`, `GWEmptyState`. Not blocked by 13 or 14.

**The diagnosis, from code — four defects, each one line:**

1. **Page capped at panel width.** `transactions_slim_view.dart:177` caps at
   `GeniusBreakpoints.medium` (768) because it is a *panel*; `transactions_screen.dart:26` wraps it
   in a `Center`. On a 2000px window that is a 736px column with ~630px dead on each side. The
   sibling tab `markets_screen.dart:70` caps at `xxl` (1536) and scales with width.
2. **A panel title doing a page title's job.** `transactions_slim_view.dart:192` uses
   `GWSectionTitle` (18px, shared 44px min-height). Every other full page —
   `markets_screen.dart:73`, `crypto_news_screen.dart:50`, `swap_screen.dart:228` — uses
   `GWPageHeader` (24px `headlineLg`).
3. **No surface.** The dashboard wraps the identical widget in `DashboardScrollContainer`
   (`dashboard_screen.dart:322`); the tab wraps it in nothing, so rows hang on `surface-base`.
4. **Empty block pinned to the midpoint.** `gw_empty_state.dart:129` returns a `Center` and both
   call sites hand it an `Expanded` (`transactions_slim_view.dart:208`). In a ~1400px slot the icon
   lands 700px down, below the fold.

Plus one behavioural bug: the filter bar renders on a wallet with **zero** transactions — five
controls offering to filter nothing. The branch that knows this already exists (`:246`).

**Design contract:** `.planning/sketches/020-022` — decided and locked 2026-07-22:

- **Layout: 020-B · Filter rail.** Page at `xl` 1280 with `GWPageHeader`; rail and list each in a
  `DashboardScrollContainer`. The `⋯` overflow menu exists only because a 376px panel cannot show
  nine filters — a page can, so the rail **is** that menu unrolled. **The panel keeps its chips**;
  the rail is page-only. One genuinely new row: `All`, which also absorbs the footer's total count.
- **Rail states — all three traced, none invented.** Rest = `_menuItem` geometry byte for byte
  (`transactions_slim_view.dart:498-551`): glyph `textSecondary` 14px, label `labelMd` 13/w500, count
  `numericBody` 13px tabular, row 40px, pad `space6`. Hover = the sketch-008 "lift chip"
  (`surfaceElevated`, 120ms) — the app-wide standard. **Active = 022-B2 · underline only:** the
  navbar's active-tab mark copied outright — label goes w700 `textPrimary` and is **never
  recoloured**, a 2px gradient rule sits beneath it, and the **glyph never changes** (the rule locked
  at `:525`). Sketch 020's `brand-fill` background was invented and is rejected; so are a gradient
  count (the counts are computed over the *unfiltered* list on purpose, so they never move) and a
  gradient wash (~1.3:1, under the 3:1 WCAG 1.4.11 wants, and it collides with the hover fill).
- **Empty state: 021-c · bounded centre.** `ConstrainedBox(maxHeight: 480)` under
  `Alignment.topCenter`, replacing the bare `Center`. A rule, not a hand-picked offset: in a short
  panel it behaves exactly as today, so nothing regresses; in a 1400px panel it settles ~240px from
  the top instead of 700. **Shared component — Assets and Markets get the same fix.** No action
  buttons. Icon → `Icons.sync_alt`.
- **Filter control hidden entirely when `scoped.isEmpty`** — page rail *and* panel chips.
- **Amounts — amends 12-02 deliberately.** `transaction_utils.dart:356-366` gives both a failed
  transaction and a processing job `amount = '—'`, demoting the real number to the small grey line.
  Both now print the real amount: `process` → `− <fees> <symbol>` with value `<fiat> fee`;
  failed/cancelled → the real signed amount. **The `Not charged` value line is load-bearing and must
  stay** — it is the only thing stopping a full-weight `− 0.75 ETH` from claiming the balance
  changed. On the panel, which has no Status column, the red `failed` badge plus `· Failed` in the
  subtitle carry the state.

**Recorded, not re-litigated:** `Icons.sync_alt` (two horizontal opposed arrows) is close to
`Icons.swap_horiz_outlined`, the Swap tab's navbar glyph. Chosen knowing this; logged so a walk does
not report it as a surprise. `Icons.swap_vert` is the collision-free alternative if ever wanted.

**Freeze rule applies.** Nothing in the rail or the empty state may derive a dimension continuously
from constraints — see commit `37639d5` and `test/chart/compact_price_font_size_test.dart`.

**Plans:** 6 plans — **5 of 6 complete (implementation done; only the human walk remains)**

Plans:

- [x] 15-01-PLAN.md — amount honesty: the job spends its fee, the failed row keeps its number (TT-06)
- [x] 15-02-PLAN.md — GWEmptyState anchored in a bounded 480px search, compact tier intact (TT-04)
- [x] 15-03-PLAN.md — panel: sync_alt icon, filter control hidden on an empty scope, shader hoisted (TT-05)
- [x] 15-04-PLAN.md — `_FilterRail` + the two-card page presentation behind a `page` flag (TT-02, TT-03)
- [x] 15-05-PLAN.md — page frame: GWPageHeader, xl cap, card surfaces, flag plumbed through (TT-01)
- [ ] 15-06-PLAN.md — human verify: walk the tab, the empty states and the amounts — DARK ONLY

**Measured outcome (as of 15-05):** content width **1280.0** at 1600/2000/2560 viewports, against
**736** before — the defect this phase existed to fix. `dashboard_screen.dart` is byte-unchanged, so
the dashboard panel is untouched.

> **SUPERSEDED 2026-07-23 by `99a8913`.** The `xl`/1280 cap above was later replaced by a unified
> **`xxl`/1536** frame across Transactions/Markets/News (so the three page titles land at the same X).
> The shipped code (`transactions_screen.dart` `maxWidth: GeniusBreakpoints.xxl`) now measures **1536**,
> not 1280 — the `1280.0` figure here no longer holds, and the page-frame test was updated to assert
> the xxl cap. Phase 15's *structure* (page header, filter rail, card surfaces, empty-state anchor,
> amount honesty) is unchanged; only the cap number moved.

Suite at **234 passing / 1 failing** (measured 2026-07-23); the failure is the pre-existing, entirely
commented-out `test/local_wallet_storage_test.dart`.

**Deferred to the walk** (`.planning/phases/15-transactions-tab/deferred-items.md`): the
`RefreshIndicator` does not arm over the rail card — 220px of a 1280px page is dead to
pull-to-refresh — and `_panel`'s title row overflows below 413px, which is pre-existing and which
this phase made 8px *better*, not worse. Also for your eye: the B2 underline tracks the word, so its
width ranges **39.75 → 119.25px** across the labels.

### Phase 16: Markets page redesign - H1 native-token hero over sortable All Markets table (sketch 103)

**Goal:** Re-skin `/markets` to sketch 103 **H1** — a native-token hero over a sortable All Markets table.
**Canonical owner of the Markets tab (2026-07-23):** supersedes Phase 5's markets re-skin (05-04) AND
owns the Markets surface that Phase 7 explicitly fences OUT of its scope. All `/markets` work lands here.
**Status:** **IMPLEMENTED AHEAD OF PLAN** — built in a worktree and committed to `ui-redesign-port`
in `aa78eec` (2026-07-23): `markets_hero_card.dart`, `markets_table.dart`, `markets_sort.dart`
(+ `markets_sort_test.dart` 5/5). No GSD PLAN/SUMMARY was authored; verification and the human walk
(dark+light) are **outstanding**, as is a macOS signing fix. Context: `.planning/phases/16-.../CONTEXT.md`.
**Requirements**: TBD (retrofit from CONTEXT if a formal record is wanted)
**Depends on:** Phase 15
**Plans:** none authored (implemented directly); verification/walk outstanding

Plans:

- [ ] 16-VERIFY — human walk (dark+light) + a verification record for the already-committed code

### Phase 17: News page redesign - B2 Hero + Next up band, photo grid, hoverLift cards (sketches 100-102)

**Goal:** Re-skin `/news` to sketch 100-102 **B2** — a lead hero + "Next up" band over an even photo
grid, `GWCard.hoverLift` replacing the old scrim; fix frozen `pubDate`, unrendered `description`, and
the desktop-unreachable refresh; drop `flutter_staggered_grid_view`.
**Canonical owner of the News tab (2026-07-23):** supersedes Phase 5's news re-skin (05-05). All `/news`
work lands here.
**Status:** **IMPLEMENTED AHEAD OF PLAN** — built in a worktree and committed to `ui-redesign-port`
in `651541c` (2026-07-23): `crypto_news_screen.dart` rewrite, `GWCard.hoverLift`, `GWSearchField`
(`gw_text_field.dart`), `news_article.dart` (+ `gw_card_hover_test.dart`, `news_article_short_time_test.dart`).
No GSD PLAN/SUMMARY was authored; verification and the human walk (dark+light) are **outstanding**.
Context: `.planning/phases/17-.../CONTEXT.md`.
**Requirements**: TBD (retrofit from CONTEXT if a formal record is wanted)
**Depends on:** Phase 16
**Plans:** none authored (implemented directly); verification/walk outstanding

Plans:

- [ ] 17-VERIFY — human walk (dark+light) + a verification record for the already-committed code
