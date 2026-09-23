# Roadmap: GeniusWallet

> **2026-09-16 — Milestone v2.0 (Squid Router integration), phases 26-30, appended at the end of this file (search `# Milestone v2.0`).** The v1.0 roadmap above stands unchanged.

## Overview

This milestone lands the `ui-redesign-3.514` design on `develop` **incrementally, layer by layer**,
on branch `ui-redesign-port` (`branching_strategy: none` — phases land on the current branch, not
per-phase branches). The `.planning/` GSD setup itself shipped on `develop` via PR #207 (`12fd40d`) before the
numbered phases below began.

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
claim is **FALSE** — measured, the suite runs at **248 pass / 1 fail** (re-measured 2026-07-25) (the 1 fail is the fully
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

- [x] **Phase 2: Design tokens & verification loop** - Redesign token vocabulary lands invisibly; debug-build loop and dev-gating established (completed 2026-07-16)
- [ ] **Phase 3: gw_* component library** - The 82 additive primitives + design gallery + gap treatment decided
- [x] **Phase 4: Navigation shell & chrome** - Shell, header chrome, Settings and SDK account manager wear the redesign (7/7 plans; 04-VERIFICATION.md = passed 6/6, 2026-07-18)
- [x] **Phase 5: Dashboard** - Balances, holdings, transactions, markets, news (completed 2026-07-21)
- [x] **Phase 6: Onboarding** - Create, import, recovery phrase, verify, legal, select-wallet-type (completed 2026-07-23 — 6/6 plans; fresh-install walk PASSED all 4 criteria)
- [ ] **Phase 7: Token screens** - Token info, send, receive, address book, charts
- [x] **Phase 8: Swap & bridge** - Squid Router and GNUS bridge (completed 2026-07-27)
- [x] **Phase 9: Banxa** - Buy, KYC, checkout, order history/details (completed 2026-07-27)
- [ ] **Phase 10: dApp connectivity** - Reown/WalletConnect
- [ ] **Phase 11: Functional closeout** - Every reachable feature works or is honestly unavailable (walk script: `11-WALK.md`)

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
| Web tab (in-app browser chrome — address bar + tabs) | **Phase 18** | new surface; not owned by any prior phase |
| Feedback tab (`/logs`) — the composer card | **Phase 19** | new surface; not owned by any prior phase |
| Feedback tab (`/logs`) — the page frame around it | **Phase 20** | supersedes ONLY Phase 19's "centered `GWPageHeader`" clause |
| Drawer chrome + content patterns (all ~19 `ResponsiveDrawer` instances) | **Phase 21** | extends Phase 7 (07-06 shipped the shell header); each drawer's MECHANICS stay with its owning phase (8 swap, 9 Banxa, 10 Reown, 12/15 transactions) |
| Token detail, send, receive, address book | **Phase 7** | market data → 16; chart re-skin → 5 (inherited) |
| Token-detail chart (`crypto_live_chart`) | **Phase 5** (quick `260721-dws`) | Phase 7 inherits; only the finding-24 lifecycle fix is Phase 7's |
| Swap & bridge | **Phase 8** | page frame already unified by `99a8913` (don't re-do) |
| Banxa | **Phase 9** | — |
| dApp / Reown | **Phase 10** | — |
| Shared `gw_*` primitives + tokens | **Phase 3** (extensions signed off in **Phase 11**) | 16/17 added hoverLift, GWSearchField, empty-state anchor |

## Phase Details

### Phase 2: Design tokens & verification loop

**Goal**: The redesign's visual vocabulary is on develop and every later phase can be checked by running the app
**Depends on**: Nothing (first phase)
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

**Plans**: 8 plans (3 original + 5 gap-closure from the 07-03 walk)

- [x] 07-01-PLAN.md — re-skin token-detail (ActionButton, Info/Convert cards, both drawers) + lock finding 37 + light-QR (executed 2026-07-23, `639fe60`/`c3141f6`/`dc0b705`, analyze 61 baseline)
- [x] 07-02-PLAN.md — finding-24 chart lifecycle mounted guards (no re-skin) (executed 2026-07-23, `35fef28`, verify PASS)
- [x] 07-03-PLAN.md — human walk: dark+light fidelity, QR phone-scan, disabled states, clean console (executed 2026-07-24; result gaps_found → 5 fixes below)
- [ ] 07-04-PLAN.md — [gap 1,2] token-detail responsive layout to sketch 152 (768 switch, Convert below chart on mobile) + read-only Convert price (wave 1)
- [ ] 07-05-PLAN.md — [gap 3] Receive QR to sketch 034-A2 (contained ~60%, network chip above, chunked copy-only address; finding-16/6 white backing kept) (wave 1)
- [ ] 07-06-PLAN.md — [gap 4] shared ResponsiveDrawer header to sketch 030-B1 quiet band (compact, left title, small top-right ✕, 1px brand hairline; safe for all ~19 callers) (wave 1)
- [ ] 07-07-PLAN.md — [gap 5] populate More → Bridge Tokens drawer body; keep finding-37 + /bridge behavior (wave 2, after 07-04)
- [ ] 07-08-PLAN.md — [gap 6] re-walk: confirm gaps 1–5 + finding-24 in dark+light, QR scan, non-GNUS More-disabled; flip 07-VERIFICATION only when earned (blocking human-verify, wave 3)

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
  5. `GlobalSwapFabHost` is mounted and the app starts with no `!_dirty` red screen when the initial route resolves mid-mount — the `7a63b4f` carry from Phase 4 lands here (NAV-02)

**Plans**: 7/7 plans complete
**UI hint**: yes
**Findings**: 21, 22, 28.
**Carries (accepted 2026-07-25)**: `7a63b4f` (`!_dirty` guard + `GlobalSwapFabHost`) — deferred out of Phase 4 "to the swap-FAB phase"; Phase 8 is that phase and now owns it explicitly (criterion 5). **This is a PORT, not a build:** `lib/components/overlay/global_swap_fab_host.dart` (143 lines, with the fix already applied) exists on branch `ui-redesign-3.514-develop` at `7a63b4f` and is absent on `ui-redesign-port`. Port it and preserve the `if (!_ready) return;` guard and its comment verbatim — that comment records why the obvious `schedulerPhase` check does NOT catch the startup case (initial mount runs under `attachRootWidget`, phase `idle` not `persistentCallbacks`). See `lib/components/splash.dart:57` for the live trace of the same condition.

Plans:

- [x] 08-01-PLAN.md — Swap-family primitives: page-header subtitle, SwapField (38px/MAX/USD), seam flip control, paint-only route card + golden figure test (criterion 1)
- [x] 08-02-PLAN.md — `GlobalSwapFabHost` port from `7a63b4f` (AI-FAB half stripped) + mount in main.dart + `_ready`-gate test (criterion 5)
- [x] 08-03-PLAN.md — Swap tab to sketch 105 A1, unit-tested CTA ladder, D-09 route-error state (criterion 2)
- [x] 08-04-PLAN.md — Bridge screen to sketch 120 B1 (swap-twin) with every on-chain argument preserved
- [x] 08-05-PLAN.md — Swap result onto the 031-B receipt, three superseded drawers deleted, dev bubble repointed, Swap Settings drawer re-skinned (criterion 3)
- [x] 08-06-PLAN.md — Bridge result: toast + 031-B receipt via a synthesized display-only Transaction (criterion 4)
- [x] 08-07-PLAN.md — Human walk: all 5 criteria + WCAG AA in both modes; records 08-VERIFICATION.md

### Phase 9: Banxa

**Goal**: The fiat on-ramp wears the redesign and keeps develop's rework
**Depends on**: Phase 4
**Requirements**: SCR-05, GAP-05
**Success Criteria** (what must be TRUE):

  1. Buy, KYC, checkout and order history/details render in the redesign skin and a buy flow runs end to end
  2. Completing KYC pops the webview and returns success to the caller — the redirect matches `BanxaApiService.redirectUrl`, not a placeholder (finding 1 — a blocker)
  3. The checkout QR scans in both light and dark appearance (finding 6), and opening Banxa KYC on Linux falls back to the browser instead of crashing (finding 7)
  4. The develop-only Banxa additions (`banxa_orders_history.dart`, `banxa_payment.dart`, `banxa_buy_screen.dart`) wear the extended design language per the Phase 3 treatment

**Plans**: 7/7 plans complete

Plans:

- [x] 09-01-PLAN.md — Wave-0 test floor (`test/banxa/` fixtures + two-mode pump helper) and the one shared 4-bucket order-status ladder
- [x] 09-02-PLAN.md — Orders history + order card: GWCard, semantic status pill, GWErrorState/GWEmptyState
- [x] 09-03-PLAN.md — Buy screen GWButton CTA ladder, plus the D-08 dead-code quote-card re-skin and its todo
- [x] 09-04-PLAN.md — Order details card + page: the missing error branch, the tinted severity banner, twin button swap
- [x] 09-05-PLAN.md — Checkout QR (white backing preserved) and the D-07 checkout options sheet
- [x] 09-06-PLAN.md — Payment and KYC webview hosts: shared Linux-fallback layout, redirect logic provably untouched
- [x] 09-07-PLAN.md — Standing literal gate over all ten in-scope files, and `09-OUTSTANDING.md`

**UI hint**: yes
**Findings**: 1, 6, 7. **Covers GAP-05**.
**Scope note (09-CONTEXT D-01/D-02/D-03)**: planned as a RE-SKIN ONLY. Criterion 1 closes PARTIAL,
criteria 2 and 3 are NOT ADDRESSED. SCR-05 cannot be marked complete by this phase — its wording
includes the KYC redirect, which D-02 defers. See `09-OUTSTANDING.md` (written by 09-07).

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

### Phase 11: Functional closeout

**Goal**: Every feature a user can reach either works, or is honestly unavailable
**Depends on**: Phases 5-10, 12-17

> **REFRAMED 2026-09-16.** This phase used to ask "did the redesign land without regressing?".
> That question is answered. The open question is whether the app *does* anything: a code sweep
> on 2026-09-16 found Swap fabricates a success receipt without calling Squid, Send is a disabled
> stub, dApp connect cannot initialize on Windows, and both Banxa webviews have no Windows
> implementation. The walk script is `11-WALK.md`.

**Requirements**: BEH-01
**Success Criteria** (what must be TRUE):

  1. Every row in `11-WALK.md` is marked works, or accepted in writing with a reason
  2. No screen reports success for something that did not happen
  3. A single walk from cold start through onboarding, dashboard, bridge and a compute job
     completes with no runtime exception

  4. Windows debug and release both build and `flutter analyze` reports 0 errors

**Plans**: TBD — written from the findings the walk produces

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

**Redesign track (Phases 12-20)** — landed on this same branch in parallel with the official track
above; tracked separately (see the per-phase detail sections below):

| Phase | Plans Complete | Status | Committed |
|-------|----------------|--------|-----------|
| 12. Transactions redesign | 5/6 | Executed — 12-06 walk next | `8cb4222` |
| 13. Boot & loading sequence | 2/5 | 13-01/02/03 committed; 13-04/05 outstanding | `29b183b` |
| 14. Compute panel & job flow | 7/8 | 01-04/07's lib/ work committed under one squashed message (`21a7f4f`); 04's own test landed 2026-07-30 (`25ee51a`); 05/06 have SUMMARYs and are reflected in the tree (`deeba91` etc.); 14-08 (compute-panel wiring) not yet executed | `21a7f4f` |
| 15. Transactions tab | 5/6 | Executed — 15-06 walk next | `8cb4222` |
| 16. Markets page (H1) | ahead-of-plan | Implemented & committed; walk + verification outstanding | `aa78eec` |
| 17. News page (B2) | ahead-of-plan | Implemented & committed; walk + verification outstanding | `651541c` |
| 18. Web tab chrome | 0/TBD | Sketched (035-B/036-A/037-B); not planned | - |
| 19. Feedback tab (card, 150-D) | 1/1 | ✓ Complete (19-VERIFICATION passed 6/6, walk 4/4) | 2026-07-25 |
| 20. Feedback page frame (153-B) | 1/1 | Complete    | 2026-07-30 |
| 21. Drawer language rollout | 6/6 | Complete    | 2026-07-30 |

> **This table is stale and was NOT repaired wholesale on 2026-08-06.** Verified against
> `.planning/phases/*/` on that date: every phase dir has plans == summaries and a VERIFICATION.md,
> and the only phase genuinely open is **14** (`gaps_found`, 1/8 must-haves, 14-08 never executed).
> Rows above claiming 12 = 5/6, 15 = 5/6 and 13 = 2/5 are wrong; those three are `passed`.
> Phases 1, 10 and 11 have no phase directory at all and were never started.
>
> **Phase 18 is NOT open**, despite `18-VERIFICATION.md`'s body still reading `gaps_found` at
> 10/11. That gap was the orphaned `webTabCanClose()`, deleted on 2026-07-25 by `cccd20c` after the
> verification itself ratified reset-on-close as an accepted override. The document is stale, not
> the code — a first pass on 2026-08-06 read it and wrongly reported 18 as outstanding.
>
> The 2026-08-06 mobile work on `/transactions` was run as a **quick task**, not a phase —
> `.planning/quick/260806-hfe-transactions-at-phone-width/`. It extends Phases 12+15's surface at
> sub-768 only and does not reopen them.

> **Two approved designs are queued as extensions of their owning phases, not as new phases**
> (2026-07-31). The surface ownership map above is the binding rule: a new phase for either would
> create the second owner it exists to prevent.
>
> - **Sketch 165 (coin page Synthesis)** → **Phase 7**, which owns "Token detail". Touches
>   `token_info_screen.dart`, plus an additive 24h low/high footer in `crypto_live_chart.dart`
>   (Phase 5's surface, inherited by Phase 7 - already the documented arrangement).
>   Approved 2026-07-30, decision and rejected alternatives in
>   `.planning/sketches/165-coin-page-schemes/DECISION.md`.
> - **Sketch 166 (compute panel honesty, board F)** → **Phase 14**, which owns the
>   "Compute / wallet-overview first card". Strictly additive to the P1/F1 choices Phase 14 already
>   executed against. Approved 2026-07-30, decision in
>   `.planning/sketches/166-compute-missing-screens/DECISION.md`.
>
> Phase 24 stays retired and is not reused for either: it held the architecture work removed on
> 2026-07-30 to `.planning/backlog/`, and passages below still cite "Phase 24's routing work" as the
> reason `GWAppBar` and the `GWScreen` sweep were deferred.

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

**Plans:** 7/7 plans complete

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

**Plans:** 7/8 executed — **CLOSED WITH GAPS 2026-07-30** (`14-VERIFICATION.md`: `gaps_found`, 1/8
must-haves verified). The compute panel is built, height-measured and contrast-proven, and **nothing
under `lib/` renders it** — `ComputePanel` is referenced only by its own two test files. The phase
goal ("the dashboard's first section stops lying") is NOT met, because the dashboard's first section
is unchanged. Closed in this state at the developer's explicit instruction, not because it was done.

Plans:

- [x] 14-01-PLAN.md — compute state model and the nine-state ladder
- [x] 14-02-PLAN.md — the panel's twin-tile layout (016-B2) inside the 276px budget
- [x] 14-03-PLAN.md — dot+label status component (017-A); the determinate ring is refused
- [x] 14-04-PLAN.md — `AccountDrawer.show` public entry point. Its lib work shipped inside `21a7f4f`,
      a commit that never names 14-04; its SUMMARY and test landed 2026-07-30 (`25ee51a`, `cce8154`)
      after three executor agents died on a `testWidgets`/Hive hang, closed by hive_ce's in-memory backend

- [x] 14-05-PLAN.md — submit-job cubit, CTA state ladder, error taxonomy
- [x] 14-06-PLAN.md — the step drawer (018-A) and the `/submit_job` full-screen host
- [x] 14-07-PLAN.md — job step list and step bodies
- [ ] 14-08-PLAN.md — **NEVER EXECUTED.** The integration: render the panel in the dashboard's first
      card, wire the switch-wallet and retry affordances, delete the three superseded widgets, add
      `compute_panel_wiring_test.dart`. This is the single plan between the phase and its users

**Known-shipping consequences of closing here** (all five phase bugs still ship — see
`14-VERIFICATION.md`): `ComputeLink.switchWallet` is produced at `compute_state.dart:290` and
labelled `'Switch wallet ›'` with no host handling it, so it is a dead affordance in the live UI;
`RetryProcessingStatus` has a correct, unit-tested handler at `app_bloc.dart:314` and **zero dispatch
sites**, so the fix is inert; and `SGNUSConnectionStatusWidget` is still live at three call sites, two
of them (`wallets_overview.dart:125`, `wallet_information.dart:106`) outside 14-08's declared fence.
One accidental partial win: the rewritten five-step `/submit_job` flow IS reachable, because the old
`SubmitJobDashboardButton` still pushes that route (`submit_job_dashboard_button.dart:36`).

**CMP-01..CMP-10 were never written to `REQUIREMENTS.md`** — the whole compute requirement family is
orphaned, and this phase has no closeout plan that would have caught it.

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

Suite at **248 passing / 1 failing** (re-measured 2026-07-25); the failure is the pre-existing, entirely
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

### Phase 18: Web tab chrome — in-app browser address bar + tab strip (sketches 035-B, 036-A, 037-B)

**Goal:** Re-skin the in-app browser (Web tab) chrome to sketch **037-B** — the consolidated winner of
**035-B** (unified omnibox toolbar) + **036-A** (always-visible horizontal tab strip). Replace the two
crude pieces the tab renders today:

- **`_buildSearchBar`** — a full-width unstyled strip bolted under the redesigned navbar → becomes a
  single omnibox toolbar: back/forward nested into the field's left edge, favicon + secure lock + host,
  refresh at the right edge, ⋯ menu alongside. Brand focus ring on focus.

- **`_buildTabManager` + the `1` counter** — a full-screen manager of upside-down thumbnails
  (`Matrix4.rotationX(pi)` bug) → becomes an always-visible horizontal tab strip: favicon + title + ×,
  active tab = surface-elevated + 2px brand underline (the navbar's active mark), `+` adds a DuckDuckGo tab.

**Canonical owner of the Web tab (2026-07-24):** the Web tab was not previously owned by any redesign-track
phase. All in-app browser chrome work lands here. Redesign-track phase, parallel to 12-17.
**Preserve real mechanics (do not regress):** `_goBack`/`_goForward`/`canGoBack`/`canGoForward` control
states, `_loadUrl` (URL-vs-search fallback → `google.com/search`), `_addNewTab`/`_switchTab`/`_closeTab`,
last-tab-locked rule, `_getFaviconUrl` (`google.com/s2/favicons`), the Uniswap dark-mode/localStorage
injection and banner-hiding JS. Windows path (`web_view_windows.dart`) mirrors the same chrome.
**Target files:** `lib/web/web_view_mobile.dart` (macOS/iOS), `lib/web/web_view_windows.dart` (Windows).
**Design source:** `.planning/sketches/037-web-chrome-combined/` (+ 035, 036 for the per-part rationale).
**Requirements**: TBD (retrofit from sketch READMEs if a formal record is wanted)
**Depends on:** Phase 4 (navigation shell & chrome — the navbar the browser chrome mounts under). Sequenced after Phase 17.
**Plans:** 3 plans

Plans:

- [ ] 18-01-PLAN.md — macOS/iOS omnibox address bar (035-B) + shared web-chrome helpers & test
- [ ] 18-02-PLAN.md — 036-A horizontal tab strip + remove full-screen tab manager & dead Screenshot code
- [ ] 18-03-PLAN.md — Windows omnibox parity (035-B); tab strip is a stretch goal, not attempted

### Phase 19: Feedback tab redesign (sketch 150 variant D)

**Goal:** Re-skin the Feedback tab (`/logs` → `SubmitLogsScreen`, "Send Feedback") onto the shared shell
as a first-class sibling of Transactions/Markets/News — **sketch 150 variant D · Guided receipt** — a
centered `GWPageHeader` + `.surf` card with a Bug/Idea/Question chooser, message field, an "SDK logs
attached automatically" receipt row, and honest states, **without changing the real mechanic**
(`Sentry.captureFeedback` + auto-attached SDK logs).

**Canonical owner of the Feedback tab (2026-07-24):** the `/logs` "Send Feedback" screen was not
previously owned by any redesign-track phase. All Feedback-tab work lands here. Redesign-track phase,
parallel to 12-18.
**Add one honest mechanic:** `scope.setTag('feedback_type', 'bug'|'idea'|'question')` beside the existing
`source`/`platform` tags — one line, makes type a filterable Sentry dimension (chooser also adapts the
field placeholder).
**Preserve real mechanics (do not regress):** `Sentry.captureFeedback(SentryFeedback(message))` at
`level=warning`; auto-attach `sgnslog.log`+`sgnslog2.log` from `geniusApi.jsonFilePath` (whole if ≤1 MiB
else tail-trim via `_readTailBytes`, empty files skipped — user never picks files); the
`!geniusApi.isSdkInitialized` No-SDK guard as its own state; and the **two distinct** unhappy results —
thrown exception vs empty `SentryId` (upload unconfirmed) — kept as separate messages.
**Copy (short hyphens only):** subtitle problem-focused; result labelled **"Reference number"** (not
"Event ID"); attach header "SDK logs attached automatically" · "last 1 MB of each, empty ones skipped".
**Buttons:** "Send feedback" = `GWButton primary` gradient (near-black `#000B18` label, white fails AA);
"Send another" = `GWButton gradientOutline` + refresh icon.
**Target file:** `lib/logs/submit_logs_screen.dart`.
**Design source:** `.planning/sketches/150-feedback-tab/` (winner D + `cta-options.html` +
`send-another-options.html`); full spec in `.planning/todos/pending/2026-07-24-phase-19-feedback-tab-redesign.md`.
**Requirements**: TBD (retrofit from sketch README if a formal record is wanted)
**Depends on:** Phase 4 (navigation shell & chrome — the navbar/`GWPageHeader` this tab mounts under); Phase 3 (`gw_*` primitives — `GWButton`, `GWCard`). Sequenced after Phase 18.
**Plans:** 1 plan — 19-01 (planned, executed, SUMMARY written). Phase VERIFIED **passed 2026-07-25**
(`19-VERIFICATION.md`, 6/6 must-haves = 5 verified + 1 override accepted by Braian; live walk 4/4 PASS
on Windows 11). *This line previously read "0 plans — run /gsd-plan-phase 19"; that was stale
bookkeeping, corrected 2026-07-26. The phase's own artifacts were always the record.*

**⚠ PARTIALLY SUPERSEDED by Phase 20 (2026-07-26).** The clause above reading "a **centered**
`GWPageHeader`" is the one and only part of this goal that Phase 20 reverses — sketch **153-B** puts
the title back on the page frame's left edge, like Transactions / Markets / News. Everything else this
phase delivered (150-D's card: chooser, message, receipt, five honest states, `feedback_type` tag,
button ladder) **stands unchanged and is not reopened.** Phase 19 keeps `status: passed`; its walk
evidence and accepted override remain valid for the card, which Phase 20 does not touch.

Plans:

- [x] 19-01-PLAN.md — Feedback tab re-skin to sketch 150-D (guided receipt card, `feedback_type` tag,
  five states, button ladder) — SUMMARY + VERIFICATION written

### Phase 20: Feedback page frame — 153-B "Focused frame" (left title + receipt rail)

**Goal:** Phase 19 fixed the Feedback **card**. This fixes the **page** it floats in. Today a 560px
column sits inside an `xxl` (1536) page frame, leaving roughly **430px of dead page on each side**, and
the title was pushed inside that column to hide the mismatch. Sketch **153-B** answers it the other way:
the page declares a **narrower frame**, the title returns to the frame's left edge like every other tab,
and a receipt rail fills the width beside the composer. **No new feature, no new data, no new
component** — the rail is a re-arrangement of facts `_probes` already computes.

**Chosen design:** `.planning/sketches/153-feedback-page/index.html#b` — variant **B · Focused frame**
(chosen by Jakub 2026-07-26). Runner-up **A · Sheet** (smallest diff, keeps the centred title);
rejected **E · Wide composer** (a 1400px textarea for a two-sentence report).

**The change, all of it in `lib/logs/submit_logs_screen.dart`:**

1. **Page frame `xxl` → `GeniusBreakpoints.large` (1024)** at `:416`. An **existing** token, and
   640 + 20 + 360 = 1020 fits inside it — the sketch's "1040" is a mockup number, do not introduce a
   new constant for it.

2. **Header leaves the 560 column** (`:430-441`): drop the `Center(ConstrainedBox(maxWidth: 560))`
   wrapper and the `centered: true` argument, so `GWPageHeader` renders its default left-aligned form
   directly in the frame's `Column(stretch)`.

3. **Two columns**: `LayoutBuilder` → at content width ≥ ~1020 a `Row` of
   `SizedBox(width: 640, child: GWCard(composer))` + `space10` + `Expanded(child: GWCard(rail))`;
   below that, a `Column` with the rail under the composer.

4. **New `_buildRail`** — the same probe data as key/value rows (file + size, `TAIL`, struck-through
   `skipped`, `SDK Running/Stopped`, platform) plus the "last 1 MB of each, empty ones skipped" note.

5. **`_buildReceipt` chip strip leaves the composer** (`:596-659`) — its content is now the rail.
6. **Failed-state footer fix (in scope, small):** the status line and the send button share one `Row`
   with `crossAxisAlignment: center`. The empty-event-ID message (`:359`) is 130 characters and wraps
   to several lines in a 640 column, leaving the button hovering in the middle of the block.

**Preserve, do not regress:** everything Phase 19 verified — `Sentry.captureFeedback` at
`level=warning`, the auto-attached `sgnslog.log`/`sgnslog2.log` (whole ≤1 MiB else tail-trim, empties
skipped, user never picks files), the `!isSdkInitialized` No-SDK guard as its own state, the **two
distinct** failure messages, the `feedback_type` tag, "Reference number" wording, and the
primary/gradientOutline button ladder.

**⚠ Reverts an uncommitted in-tree change.** `centered: true` at `submit_logs_screen.dart:440` was
added by a parallel session on 2026-07-26 and is recorded in
`.planning/HANDOFF-swap-feedback-header-and-coin-sketches.md` as a deliberate call. Jakub chose 153-B
on 2026-07-26 knowing this. **The `centered` flag itself stays in `GWPageHeader`** (additive, tested by
`test/components/gw_page_header_centered_test.dart`) and **Swap's own `centered: true` is out of scope
here** — that is Phase 8's call, and this phase must not touch `swap_screen.dart`.

**Finding baked in:** `_candidateLogNames` (`:97`) is a **two-element const**, so the rail can never
show more than two log rows — four rows with the SDK running, two with it stopped. The rail is sized
for that truth; do not design it as if the list grows.

**Test position:** the existing `test/logs/submit_logs_feedback_test.dart` (5 tests) is pure logic —
enum tags, placeholders, dispositions, attachment names — and is **unaffected** by this layout change,
as is `gw_page_header_centered_test.dart`, which pumps the header in isolation. This phase owes **one
new runnable check**: a widget test that the page renders two columns at a wide width and one column
narrow, with the title on the frame's left edge.

**Target file:** `lib/logs/submit_logs_screen.dart` (single file; no new files expected).
**Design source:** `.planning/sketches/153-feedback-page/` (winner **B**; README carries the code-grounded
findings and the full pantry inventory).
**Requirements:** none new — this is a layout change to a shipped surface.
**Depends on:** Phase 19 (the card this page frames); Phase 4 (`GWPageHeader`, navbar); Phase 3
(`GWCard`, `GWButton`).
**Supersedes:** the "centered `GWPageHeader`" clause of Phase 19's goal — and **only** that clause.
**Plans:** 1/1 plans complete

Plans:

- [x] 20-01-PLAN.md - Focused frame: cap at `large`, title back on the frame's left edge, composer +
  receipt rail via `LayoutBuilder`, chip strip retired, Failed-footer fix, and one new page-frame
  widget test (`test/logs/submit_logs_page_frame_test.dart`)

### Phase 22: Codebase hygiene: standards config, dead code deletion, analyzer to zero, CI gates

**Goal:** Make the codebase's own rules mechanically enforceable and get the tree clean under them —
without changing behaviour anywhere. Ends with analyzer at zero, a green test suite, and CI actually
enforcing. Using that enforcement to collapse duplication is Phase 23; state ownership and money
paths were Phase 24, removed from the roadmap 2026-07-30 and parked in
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`.

**Shipped 2026-07-28** — analyzer **0 / exit 0** (from 408), tests **512/0** (from 512/1), brace-less
`if` **0** (from 192), **−1,744 LOC**, CI `quality` job wired and blocking. One caveat: the CI job has
never actually run — it needs a push, which was not authorised.

**Requirements**: ORG-01, ORG-02, ORG-03
**Depends on:** Phase 21
**Plans:** 7/7 plans complete

**Requirement IDs coined for this phase** (ROADMAP said TBD; REQUIREMENTS.md carries no
codebase-quality requirement). ORG-01..03 close in Phase 22; ORG-04..05 close in Phase 23:

- **ORG-01** — the codebase's own rules are mechanically enforced in CI (format, analyze, brace
  rule, raw colours, the three existing security gates, tests, patch coverage)

- **ORG-02** — dead code removed: no never-imported file, no dead dependency, no hand-written
  widget wearing a generated-code filename

- **ORG-03** — `flutter analyze` reports 0 and exits 0, in both packages
- **ORG-04** — one colour source of truth: semantic tokens via `context.gw`, primitives genuinely
  private, both appearance modes correct and WCAG AA

- **ORG-05** — duplicated UI collapsed onto shared `StatelessWidget`s at 3+ call sites

**Why this order.** Research (2026-07-28, 12 parallel audit + research agents) settled the sequence:
lint/format/CI first because `dart fix --apply` turns each newly-enabled rule into a bulk rewriter;
then **theme before components**, so extracted components are born on tokens instead of needing a
second pass. LeanCode's 4-level framework orders it the same way.

The original sequence also placed a golden-test baseline between the two, as the published safety net
for the design-system work. **That step was cancelled** — see `cancelled/22-07-CANCELLED.md`. Phase 23
was re-planned around proofs that do not need it (value equality, compiler enforcement, measured WCAG
ratios), and the extraction work that genuinely required visual diffing was cut or deferred rather
than shipped unverified.

**Measured baseline (2026-07-28, verified not estimated):**

| Metric | Value |
|--------|-------|
| `flutter test` | 512 pass / 1 fail (the fail is a fully commented-out file with no `main`) |
| `flutter analyze --no-pub` | **exit 1**, 408 issues (331 warning / 67 info / 0 error) |
| — of which from one unexcluded generated FFI file | 214 → real signal is **184** |
| Brace-less `if` | 192 across 72 files (`else`/`for`/`while` = 0) |
| Dead code | ~1,400 LOC across 13–14 never-imported files |
| Mode-breaking `Colors.white/black/grey` | 114 sites, ~50 files |
| `GWColors` lookups | 128 sites, 81 files |
| CI quality gates | **zero** — `build.yml` runs no test/analyze/format step |

**Decisions locked (2026-07-28):**

- **Ruleset:** stay on `flutter_lints`, add ~15 targeted rules each justified by a real finding.
  `very_good_analysis` (206 rules) was considered and declined as too large a backlog for this phase.

- **Brace rule enforcement:** CI gate + one-time auto-fix script. **No built-in lint can express this**
  — `curly_braces_in_flow_control_structures` is already enabled and reports 0, because it permits
  omitting braces when the statement fits one line with no `else`; all 192 sit in that carve-out.
  `custom_lint` was declined and is in any case retired (superseded by `analysis_server_plugin`).

- **CI rollout:** exclude generated FFI (408→184) → `dart fix` → hand-fix remainder → gate ON last.
  Nothing is blocked while cleaning.

- **Colours:** do **not** delete `GeniusWalletColors`. Demote it to the private primitive layer and
  keep `GWColors` as the semantic layer (Material 3 primitive→semantic→component model).

- **Coverage:** patch-coverage gating (`project: auto` + `patch: 80%`), not VGV's 100%.

**Planned 2026-07-28 — 15 plans, one wave each (this phase is a chain of whole-repo passes; almost
every plan touches `lib/**`, so genuine parallelism exists only in wave 1).** The five workstreams
below were the input; the decomposition is recorded under "Plans" further down.

**Measured at planning time, against the phase's own numbers:** dead files 14 at zero references
(1,213 LOC) + 3 at one reference (273 LOC); analyzer 319 issues of which 223 have automated fixes and
96 need a human; `GeniusWalletColors` has ~46 public members and **288** call sites outside
`lib/theme/` while `GWColors` has only **21** fields — so the "field-for-field parity" premise
required building the parity layer first (22-09), which is why the theme workstream is four plans and
not one.

**Split, 2026-07-28.** This phase was planned as 15 plans and then split at the planner's own
identified boundary. **Phase 22 is now plans 01–08 — the mechanical-hygiene half, independently
shippable:** it ends with a green CI and zero design-system changes. The consolidation half moved to
**Phase 23** and the architecture work shifted to **Phase 24** (since removed — see the backlog).
Splitting cost ~140 cross-reference
rewrites across already-verified plans; the resulting `depends_on` chains were re-validated
(`verify plan-structure` = valid on all 15).

Plans:

- [x] 22-01-PLAN.md — Deletion pass: 14 never-imported files + 3 adjudicated, the dead test file
      (512/1 → 512/0), the dead font dependency, the duplicate radius alias

- [x] 22-02-PLAN.md — `tool/check_brace_style.sh` with `--count` and `--self-test`, plus
      `.editorconfig`. The self-test is mandatory: a gate that never fails is not a gate

- [x] 22-03-PLAN.md — Rename the 9 hand-written `*.g.dart` widgets, move the shadow guard
      (`verify_additive_boundary.sh` + `shadow-baseline.txt`) with them, retire `GeniusWalletFontSize`.
      **The one sanctioned analyzer rise in this phase** — un-hiding 9 files sets a new ceiling

- [x] 22-04-PLAN.md — Brace auto-fix across `lib/` + `test/` via a `--fix` mode sharing the gate's
      detector; multi-line and `else` cases refused and hand-closed

- [x] 22-05-PLAN.md — `dart fix --apply --code=<rule>`, one rule per commit (~223 issues, 12 commits),
      in **both** packages; residue inventory written for 22-06

- [x] 22-06-PLAN.md — Hand-fix the ~96 remainder → **analyze 0, exit 0**. Risk-stratified:
      `unawaited()` never `await`; `mounted` guards recorded as the one sanctioned semantic delta

- [-] 22-07-PLAN.md — **CANCELLED 2026-07-28.** Golden tests declined twice: first the `alchemist`
      install and the no-dependency fallback at the blocking-human gate, then again after a full
      explanation — *"no need to test it design diff wise."* No replacement test infrastructure
      either, for now. Plan and rationale moved to `cancelled/`. Phase 23 was **re-planned without
      goldens** rather than patched, and cut the extraction work that genuinely needed visual
      diffing. See `cancelled/22-07-CANCELLED.md`.

- [x] 22-08-PLAN.md — CI teeth: a `quality` job in `build.yml` (format, analyze, brace gate, the 3
      existing security gates, tests) -- Codecov removed 2026-07-28. Repointed `depends_on: ["22-06"]`
      (wave 7 → 6) when 22-07 was cancelled. **The job has never run** — proving it needs a push.
      No golden step was added; a CI step running zero golden tests would pass vacuously.

**Phase exit:** analyzer 0 / exit 0, tests 512/0, brace rule enforced at 0, CI gates enforcing,
no design-system file changed. **No golden baseline** — 22-07 was cancelled; see `cancelled/22-07-CANCELLED.md`.

### Phase 23: Design system consolidation: theme tokens and shared components

**Goal:** Collapse the three competing colour sources into one compiler-enforced semantic layer, fix
the mode-breaking colour defects with measured WCAG evidence, and collapse the one duplicated pattern
that can be proven paint-preserving without a visual baseline. Still no behaviour changes.

**Requirements**: ORG-04, ORG-05 (ORG-05 partial by design — see 23-05's extraction audit)
**Depends on:** Phase 22
**Plans:** 6/6 plans complete
PASSED, every gate re-run from a clean tree, ORG-01..05 traceability written)

**Why this is separate from 22.** The parity premise in the original scoping was wrong:
`GeniusWalletColors` has ~46 public members and **288** call sites outside `lib/theme/`, while
`GWColors` has 21 fields. A "mechanical prefix rewrite" only becomes true *after* a parity layer
exists — hence 23-01 as a zero-diff de-risking plan before the codemod can be mechanical rather than
288 judgement calls.

**Measured, and larger than first reported:** raw colour references outside `lib/theme/` total
**525**, not 114. The 114 figure was the `Colors.white/black/grey` subset; the planner measures that
subset at 83. 23-03 fixes the mode-breaking ones with WCAG evidence; 23-04's gate is
directory-scoped with a written widening plan. **Full de-hex of all 525 is bigger than this phase**
and is a candidate for its own.

**What the re-plan cut, and why.** Measurement at planning time refuted three of the original
extraction premises outright. The two timeframe-selector copies are **not** character-identical (four
labels versus five, different track colour, a hairline border in only one) — so the phase's one
sanctioned below-threshold exception is refused by its own rule. There are **two** forked copy-row
widgets, not three — below the Rule of Three floor, and the other clipboard writers are heterogeneous
(a checkout URL, a Sentry event id, a seed phrase behind its own warning, one that *clears* the
clipboard). The change pill resolves to three sites whose colour rule is already uniform, so there is
no correctness value to centralise and reconciling them needs a padding parameter. `GWAppBar` and the
`GWScreen` sweep are deferred: both are layout-visible with no automated proof, and Phase 24's routing
work opens the same files. All verdicts land in `23-05-EXTRACTION-AUDIT.md` with re-runnable evidence.
**Note (2026-07-30):** Phase 24 was removed from the roadmap, so these two deferrals no longer have a
destination phase. They are recorded in
`.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md`; whichever phase
next opens the routing/app-bar files inherits the "extract while the files are open" argument.

Plans:

- [x] 23-01-PLAN.md — `GWColors` extended to field-for-field name parity, seeded from the existing
      primitives; `context.gw` accessor with a fallback; the **parity test that replaces the golden
      baseline** by proving value equality per token in both modes. **Zero call sites changed**

- [x] 23-02-PLAN.md — AST rewriter (`package:analyzer`, already resolvable transitively — **no package
      install, no pubspec change, no blocking gate**) moving ~260 colour reads onto `context.gw`,
      one commit per directory, closing with an eight-screen appearance-toggle walk

- [x] 23-03-PLAN.md — Close the codemod residue; fix `toast_widget.dart`, `gw_button.dart` and
      `lib/reown/`; replace the forked warning widget with `GWWarningNote`. Every touched pair gets a
      **measured WCAG ratio asserted** in the existing `test/theme/theme_contrast_test.dart`

- [x] 23-04-PLAN.md — Demote the primitives via `part`/`part of` so the **compiler** enforces privacy
      (six test files migrated off the legacy palette first); mono type token; de-hex `GWDecorations`;
      `tool/check_raw_colors.sh` scoped to clean directories with a written widening plan

- [x] 23-05-PLAN.md — The extraction adjudication (every candidate re-measured, four refused or
      deferred on evidence), then extract `GWHoverable` — 12 sites, promoted from the private shim
      that already exists in `swap_field.dart`, builder-shaped so each call site's paint moves
      verbatim, with hit area and cursor pinned in an ordinary widget test

- [x] 23-06-PLAN.md — Phase closeout: the fourteen-item human walk (twelve plan items plus 23-05's
      two added sub-items) in both modes and at two widths — ALL PASSED, every gate re-run from a
      clean tree with output quoted, ORG-01..ORG-05 traceability (ORG-05 **partial**), and the
      handover list including the visual-regression gap itself

### Phase 21: Drawer language rollout - the four decided drawer designs, applied to every drawer

**Goal:** Sketches **030 / 031 / 032 / 033 / 034** decided the whole drawer language on 2026-07-23 and
consolidated it in `.planning/sketches/drawers-final/`. **Only the shell header shipped** (Phase 07-06,
`1d43a13`). Every drawer *body* still wears whatever it was born with. This phase applies the four
decided content patterns to all ~19 drawer instances across 15 files, and gives the shared shell the
padded body it was always specified to have.

**Design source:** `.planning/sketches/drawers-final/` (the consolidated five) + `.planning/sketches/154-transaction-details-drawer/`
(variant **A · 031-B1 as decided**, chosen by Jakub 2026-07-26, which is what re-opened this).

**The one shared change (Wave 1, everything else depends on it):** `responsive_drawer.dart` gains an
opt-in **padded body** so 030-B1's 20px body inset finally exists in one place. 07-06 deliberately did
not add it - *"body padding remains each caller's own responsibility; some of the ~19 callers already
pad their own bodies; double-padding would regress them"* (07-06-SUMMARY). That reasoning was correct
and is exactly what this phase resolves: the primitive lands once, and each caller's ad-hoc padding is
removed as that caller is converted. Today the same inset is spelled five different ways -
`EdgeInsets.all(8)`, `all(16)`, `space10`, `space16`, `symmetric(...)` - and in
`showTransactionDetails` it is **absent**, which is the visible defect Jakub reported.

**The four patterns and where each one lands:**

| Pattern | Drawers |
|---|---|
| **031-B1 · Receipt** (identity + amount, status pill, TRANSACTION/NETWORK section cards) | `transaction_displays.dart` (`showTransactionDetails`), `squid_router/swap_success_drawer.dart`, `squid_router/swap_fail_drawer.dart`, `reown/swap_result_drawer.dart`, `banxa/buy_success_drawer.dart`, `banxa/buy_cancelled_drawer.dart` |
| **032-A1 · List picker** (tappable rows, rounded gradient-tint selection + gradient check, no accent bar) | `network_dropdown_selector.dart` ("Select Network"), `squid_router/token_selector_drawer.dart`, `account_dropdown_selector.dart` ("Your Accounts"), `account/sdk_account_manager.dart` ("SDK Accounts"), `dashboard/bridge/bridge_screen.dart` ("Select destination network"), `components/coins/view/coins_screen.dart` ("Assets") |
| **033-B1 · Confirm** (dApp identity borderless, static caution as tint, one merged Details card) | `reown/approve_dapp_connection_drawer.dart`, `reown/approve_transaction_drawer.dart` |
| **034-A2 · Receive** (gap above QR, network chip above QR, 4-char address chunks, copy only) | `coins_screen.dart` ("Receive"), `tokens/token_info_screen.dart` ("Receive {coin}") |

**Drawers that fit none of the four** - they get the shared padded body and nothing else, and the phase
must say so rather than inventing a fifth pattern: `swap_settings_drawer.dart` (a form),
`account_dropdown_selector.dart`'s "Rename Wallet" / "Delete wallet", `network_dropdown_selector.dart`'s
"Network Changed" notice, `coins_screen.dart`'s "No coins yet" empty state.

**Findings that must survive into the plans (from sketch 154's code audit):**

- `_statusPill` (`transaction_displays.dart:49`) already handles **all four** `TransactionStatus`
  states with the right tokens and is **not used in the drawer**. The receipt's pill is a call, not a
  new component.

- `content.valueLine` (fiat) and `content.exactAmount` (unclamped) are **computed on the
  `showTransactionDetails` call and discarded**. This corrects sketch 031's "the receipt has no fiat",
  which was true when 031 was drawn and is not true now.

- Colour rides on **icon + pill + Status row only; the amount stays neutral** (031 round-2 rule).
- A job's hash IS its job reference - one row labelled `Job`, not the same value twice (`:477`).
- An empty explorer URL **suppresses** the footer button (`:509`). A drawer with no footer is a real
  state; no pattern may assume the button is present.

**⚠ Security gate.** `approve_transaction_drawer.dart` and `approve_dapp_connection_drawer.dart` are
**signing-path UI**. This phase is a **re-skin only**: it must not change what is signed, what is
displayed as the amount or recipient, or the approve/reject wiring. 033-B1's caution copy is static by
design - the sketch explicitly rejected an unbacked "new address" claim, because the
"sent-here-before?" scan over the Hive `Box<Transaction>` does not exist. Plans touching these two
files need a threat model.

**Preserve, do not regress:** Phase 07-06's shell header (left title, compact 48 toolbar, top-right ✕
appended after caller actions, 1px hairline) stays exactly as shipped - this phase extends the same
file, it does not re-open that decision. The desktop 420px right-panel / mobile bottom-sheet split and
the appearance-aware surface reads stay untouched.

**Target files:** `lib/components/bottom_drawer/responsive_drawer.dart` (+ the shared content
primitives) and the 15 caller files listed above.
**Requirements:** none new - re-skin of shipped surfaces.
**Depends on:** Phase 07 (07-06 shipped the shell header this builds on); Phase 3 (`gw_*` primitives).
**Surface note:** cuts across surfaces owned by Phases 8 (swap drawers), 9 (Banxa), 10 (Reown) and
12/15 (transactions). Phase 21 owns **drawer chrome and content pattern** only; each drawer's
mechanics stay with its owning phase.
**Plans:** 6/6 plans complete
it actually stood; the originals are in `superseded-stale-file-inventory/` with a README recording
the measured drift. The design contract (030/031/032/033/034 + 154-A) was NOT re-opened - only the
file inventory and the task breakdown. Waves: **1** is the four remaining patterns in parallel
(21-02..21-05, zero file overlap); **2** is the invariant sweep (21-06).

**Planning corrected the inventory above — twice.** `coins_screen.dart` has no "Assets" list drawer
(that is an inline `GWSectionTitle`), and three of D-09's four "fits none" entries are not drawers at
all - Rename/Delete are `GWDialog`, "Network Changed" is a toast, "No coins yet" is an inline empty
state. The two undocumented drawers are in `wallet_information.**dart**` - a live, hand-written file
on the dashboard route, not the generated `.g.dart` the first pass assumed - and one of them is a
**third** Receive drawer. `token_info_screen.dart`'s "More Options" drawer no longer exists (Bridge
replaced it). Two 031-B1 targets, `squid_router/swap_success_drawer.dart` and `swap_fail_drawer.dart`,
were deleted by `9ff7c04` and repointed at the shared receipt, which satisfies D-02 for them by the
strongest available means. Measured totals at HEAD `08f6df5`: **4 receipt · 5 list · 2 confirm ·
3 receive · 4 unpatterned = 18 call sites across 17 files.** Full census lands in `21-06-SUMMARY.md`.

**Already complete before the re-plan, verified in code:** `showTransactionDetails` (full 031-B1 —
pill, section cards, fiat line, exact amount, 154-D copy rows) and four of the five list pickers
(Select Network, Your Accounts, SDK Accounts, the token picker).

Plans:

- [x] 21-01-PLAN.md — Wave 1: `GWDrawerStatusPill` + `GWDrawerReceiptHead`, mobile-sheet coverage for the already-shipped `bodyPadding`, and the token picker inlined onto `GWSelectRow`
- [x] 21-02-PLAN.md — Wave 1: 032-A1 for the one picker still hand-rolled — the bridge destination list
- [x] 21-03-PLAN.md — Wave 1: 031-B1 for the three remaining result receipts (Reown swap result, Banxa success/cancelled), one status palette via `txStatusColors`, and `lib/banxa/banxa_components` added to the raw-colour gate
- [x] 21-04-PLAN.md — Wave 1: 033-B1 for the two signing drawers, with a threat model and a six-outcome behavioural-identity contract test
- [x] 21-05-PLAN.md — Wave 1: 034-A2 receive — real 4-char chunking, the third Receive caller's ad-hoc wrapper deleted, More Options confirmed inset-only
- [x] 21-06-PLAN.md — Wave 2: the legacy `BottomDrawer` shell deleted and the padding invariant proven across every call site at once

### Phase 24: Mobile nav shell — centre dock, wallet header, two-section accounts sheet

**Goal:** Give the phone a navigation shell of its own instead of a squeezed desktop one: a bottom
bar naming real destinations, a header that fits, and an accounts sheet that distinguishes SDK
accounts from the user's own.

**Sketches:** 171, 172, 173, 174 · **Decisions by:** Jakub, 2026-08-06
**Depends on:** Phase 15 (transactions frame)
**Plans:** 1/1 shipped — `PLAN.md` (unnumbered, single plan)

**Decisions locked:** 171 variant B — the bottom bar is 4 destinations plus a centre dock, not 5
flat tabs. 172 variant A — the dock is **Swap**, reusing `Icons.swap_vert_rounded`. 174 — the
accounts sheet carries two labelled sections, SDK Accounts and Your Accounts.

**Shipped:** merged via PR #225 (`redesign/navigation-260806`). Added
`lib/components/overlay/mobile_header.dart`, `nav_destinations.dart` and `more_sheet.dart`, with a
substantial `responsive_overlay.dart` rework. Covered by
`test/components/mobile_header_brand_and_pill_test.dart` and `mobile_nav_destinations_test.dart`.

> **Artifact gap — trust the code, not this metadata.** Executed by Jakub outside GSD. There is no
> SUMMARY, and `PLAN.md` still reads `status: in-progress`. Completion here is measured from merged
> code on `develop`.

### Phase 25: One scroll on the dashboard — capped sections with View all

**Goal:** Make the dashboard a single scroll by capping each section and moving the overflow behind
a real "View all" destination, which is what forces the Assets page into existence.

**Raised by:** Jakub, 2026-08-06 live iPhone walk · **Scope:** two deliverables, planned as two
plans and executed in parallel
**Depends on:** quick task 260806-wys (dashboard section rhythm), landed 2026-08-07
**Plans:** 2/2 shipped

- [x] 25-01-PLAN.md — capped dashboard sections and the one-scroll page (no SUMMARY written)
- [x] 25-02-PLAN.md — the Assets page the caps require — `25-02-SUMMARY.md` written

**Shipped:** `lib/dashboard/assets/assets_screen.dart`, `assets_sort.dart` and
`assets_market_data.dart`, plus the section caps in `dashboard_screen.dart`. Covered by
`test/dashboard/dashboard_section_caps_test.dart`, `assets_screen_test.dart` and
`assets_sort_test.dart`. Walk evidence in `WALK-260807.md`; open items in `deferred-items.md`.

> **Artifact gap.** `BRIEF.md` still reads `status: ready-to-plan` and 25-01 has no SUMMARY, though
> both plans' code is merged. `deferred-items.md` is unresolved, so milestone close will prompt
> `[R]/[A]/[C]` on it under GSD 1.10.0.

### Phase 31: Send native coins and ERC-20 tokens

**Goal:** A user can send a chain's native coin or an ERC-20 token to an address on any EVM chain
the wallet can sign on, see the fee before approving, and find the send in history labelled with
the right asset and the right chain. Decisions are in the phase's `31-CONTEXT.md`.
**Requirements**: SEND-01, SEND-02, SEND-03, SEND-04, SEND-05, SEND-06, SEND-07
**Depends on:** Phase 30
**Plans:** 5/5 plans executed (sequential waves 1-5)

Plans:
**Wave 1**

- [x] 31-01-PLAN.md — history model: asset vs chain as two Hive fields, chain-keyed explorer, old rows still read (gated by a one-way decision checkpoint)

**Wave 2** *(blocked on Wave 1 completion)*

- [x] 31-02-PLAN.md — native send end to end: /send, SendCubit, EIP-1559 fee with legacy fallback, review drawer, pending then resolved row

**Wave 3** *(blocked on Wave 2 completion)*

- [x] 31-03-PLAN.md — ERC-20 send with a calldata self-check against the app decoder, gas-coin check, MAX for both kinds

**Wave 4** *(blocked on Wave 3 completion)*

- [x] 31-04-PLAN.md — recipient safety: paste, QR scan (hidden on Windows/Linux), self-send and contract-code warnings

**Wave 5** *(blocked on Wave 4 completion)*

- [x] 31-05-PLAN.md — entry points: coin-page Send CTA and dashboard Send with the picker; coin-page test corrected; testnet walk

---

# Milestone v2.0: Squid Router integration

> **Added 2026-09-16 — phases 26-30.** Appended below the live v1.0 roadmap (phases 1-25), which
> stands unchanged: v1.0 is still executing (phase 14 has an unexecuted plan) and nothing in this
> section re-maps or reopens a v1.0 requirement. From here, v2.0 owns `lib/squid_router/` service
> behavior and the Reown approval-path honesty work.

> **Reconciled 2026-09-16 (merge of `origin/develop` into `phase-26-swap-wiring`).** This branch
> had already coined and executed a phase 26, "Swap that actually swaps", against a requirement
> `SWAP-01` — written before milestone v2.0 existed. It is the SAME work, so it is folded in here
> rather than left in the v1.0 list where its number would collide. Its phase directory is
> `.planning/phases/26-swap-that-actually-swaps/`, and its plans deliver **v2.0 phases 26, 27 and
> 28**. Phases 29 and 30 are untouched by it and remain genuinely unstarted.
>
> Plans landed on the branch (commits `4d102d28`..`27677fcb`, not pushed, no PR). Every box below
> is code-and-tests complete, and **all eight were walked on Base mainnet 8453 on 2026-09-17** —
> a real swap executed (hash in `26-06-SUMMARY.md`), an underfunded send named itself and stored
> nothing, and the three recovery states were checked in both appearances. Six defects the walks
> surfaced are in `26-FINDINGS.md`; `26-VERIFICATION.md` passed 33/33. **Phases 27 and 28 below
> are collapsed into 26** — this note is the record of why the numbering skips from 26 to 29.
>
> - [x] 26-01-PLAN.md — wire the `squidrouter` submodule; integrator ID via `--dart-define`; an unconfigured build reports swap unavailable (wave 1)
> - [x] 26-02-PLAN.md — ERC-20 `allowance`, `approve` and `rawBalanceOf` on Web3, plus the exact-amount approval rule (wave 1)
> - [x] 26-03-PLAN.md — live `quoteOnly` `/v2/route`; base-unit conversion; the route card reads the real estimate (wave 2)
> - [x] 26-04-PLAN.md — live token catalogue and real balances; `SwapToken` replaces `lib/squid_router/models/` (wave 3)
> - [x] 26-05-PLAN.md — the swap orchestrator: route, approval, send, status polling; no-hash-no-side-effects is structural (wave 4)
> - [x] 26-06-PLAN.md — delete the fabricated transaction and wire `_submitSwap` to the outcome; first real swap (wave 5)
> - [x] 26-07-PLAN.md — a distinct message per failure, and no stored row on any of them (wave 6)
> - [x] 26-08-PLAN.md — the three money-moved-but-not-as-asked states made legible and filterable (wave 7)
>
> Three facts the original v2.0 details assumed are settled differently on the branch:
> `squid_token_service.dart` no longer exists (deleted in 26-04, the catalogue lives behind
> `SwapProvider`); the quote debounce is **1000ms, not 500ms** (the measured free-tier ceiling is
> 1 RPS and 500ms trips it); and the integratorId loads from `--dart-define-from-file=squid.local.json`.

## Overview (v2.0)

**Goal:** Make swapping real — the `/swap` tab executes live Squid Router quotes for major tokens
with honest recording and a ~3% integrator fee, and the dApp path shows what it's signing.

**Provenance:** the 2026-09-16 explore session —
`.planning/notes/2026-09-16-swap-architecture-archaeology.md`. When the milestone was drafted the
`/swap` tab was a polished Phase-8 skin over mocks (a `squid_token_service.dart` returned hardcoded
data; `_submitSwap()` was a `TODO` that recorded a fake `completed` transaction with `hash: ""`),
while the finished Squid v2 Dart client (2025-05) sat unwired in the `squidrouter/` submodule.
**Phase 26 replaced all of that on 2026-09-16/17** — see its section below. Live swap execution via
the dApp path (Reown/WalletConnect) still blind-signs; that is Phase 30.

### Why this order

A dependency chain plus one independent subsystem:

| Order | Phase | Why here |
|-------|-------|----------|
| 26 | Swap that actually swaps | Client, catalogue, live quotes and real execution are one end-to-end promise (SWAP-01) and were built as one phase of eight plans: nothing live exists before a configured client, quoting is one pipeline behind a 1000ms debounce, and honest recording is meaningless until money actually moves. Originally drafted as three phases (26-28); collapsed once the work had shipped. |
| 29 | Integrator fee | The fee is configured on the integratorId and shows in route details, but can only be *verified* against really-executed routes — after 26. |
| 30 | Reown calldata decoding | Independent subsystem (`lib/reown/`); touches no Squid code. Numeric order places it last, but it may execute in parallel with 26-29. |

### Grounding facts (re-verified in the codebase 2026-09-17, after Phase 26)

- The swap tab is `lib/squid_router/swap_screen.dart` (route `/swap`). Everything it needs from
  Squid arrives through one seam, `SwapProvider` (`lib/swap/swap_provider.dart`), whose only
  implementation is `SquidSwapProvider` (`lib/squid_router/squid_swap_provider.dart`). The
  orchestrator is `executeSwap` in `swap_execution.dart`: route → allowance → exact-amount
  approval → send → status poll, behind a sealed `SwapOutcome` where only a hash-bearing shape
  may cause a side effect. There is no `squid_token_service.dart`, no `lib/squid_router/models/`,
  and no fabricated transaction; `grep -rn 'hash: ""' lib/` and `grep -rn 993.72 lib/` are gates.

- The `squidrouter/` git submodule is **auto-generated, DO NOT modify** (AGENTS.md). Its spec has
  drifted from the live API in **five** measured places, so the adapter reads `/v2/sdk-info`,
  `/v2/route` (quote AND executable) and `/v2/status` **raw off the generated client's own dio**
  — base path, timeouts and the integrator-ID interceptor reused, only the deserialization
  bypassed. Squid also sends `value`, `gasLimit` and both fee fields as DECIMAL strings while the
  signer parses hex; the adapter converts. Every drift is recorded where it was found
  (`26-05-SUMMARY.md`, `26-FINDINGS.md`, the 2026-09-16 handoff).

- integratorId: loads from `--dart-define-from-file=squid.local.json` (gitignored via
  `*.local.json`) into `kSquidIntegratorId`; an unconfigured build reports swap unavailable rather
  than sending 401s. Squid free tier: 1 RPS dev / 10 RPS prod; the tab debounces quote fetches at
  **1000ms** (500ms was measured to trip the dev ceiling) and reads the catalogue once a session.

- The D-09 route-error contract (error → `—` + red "not current" notice + Retry; never a silently
  stale quote) survived the mock→real switch, and a completed swap now clears its spent quote too.

- Slippage (`swap_settings_drawer.dart`) feeds the live route request.
- Fee plumbing for Phase 29: the route's `estimate.feeCosts[]` and `estimate.gasCosts[]` are read
  by `squidQuoteFromJson` into a single `SwapQuote.feesUsd` / `gasUsd` pair, which
  `RouteDetailsCard` sums again into one Fees row — so each entry's `name` is discarded at the
  adapter and two unlike costs display as one number. There is no `squid_fee_cost.dart`. Each
  `feeCosts[]` entry carries `name`, `description`, `amount`, `amountUsd` and a `token`.
  `FeeType` admits exactly eight names; `"Integrator fee"` and `"Service fee"` are both legal, and
  Squid's docs say integrator and platform fees may be **aggregated into `"Service fee"`** — so
  match names case-insensitively and render what arrives, never look up a fixed label.

- Reown dApp path: `lib/reown/handle_dapp_requests.dart` (blind-signs; calldata TODO at `:44-46`),
  drawers `approve_transaction_drawer.dart` / `send_transaction_details.dart`. There is no
  built-in calldata decoder in `reown_walletkit` — manual ABI decoding, small testable pure-Dart
  logic.

### Out of scope (v2.0)

- GNUS on any third-party router — the native burn→mint bridge (`lib/dashboard/bridge/`) remains
  GNUS's cross-chain answer (BD-driven on both Squid and Symbiosis; a business workstream, not
  engineering)

- Symbiosis Finance — named once (submodule commit `ee95bf6`), never built; not pursued
- Modifying the `squidrouter/` submodule — consume as-is; regenerate upstream if the API drifts
- Swap analytics beyond honest transaction records
- Enabling the Squid integrator fee — a server-side setting only Squid can apply to our integrator
  ID (`RouteRequest` carries no fee parameter). BD/business, tracked as FEE-01 in the backlog

### Verification reality (v2.0)

`flutter test` works (~754 passing at planning time, including `RouteDetailsCard` figure tests,
`swap_cta_state_test.dart`, `bridge_cta_state_test.dart`) and is the gate wherever behavior can
be asserted; `flutter analyze` 0/0 is a gate, never evidence (BLD-02, standing). Legs that move
money (Phase 26) and legs needing real funds or the live catalogue get a debug-build human walk.

## Traceability (v2.0)

| Requirement | Phase | Status |
|-------------|-------|--------|
| SWAP-01 | Phase 26 — one end-to-end requirement; all 8 criteria delivered and walked on Base mainnet 2026-09-17 | Complete |
| FEE-01 | **Deferred to backlog 2026-09-18** — business item; only Squid can enable it, server-side on the integrator ID | Deferred |
| FEE-02 | Phase 29 — Fee transparency | Complete |
| DAP-01 | Phase 30 — dApp calldata decoding (end blind signing) | Complete |
| DAP-02 | Phase 30 — dApp calldata decoding (end blind signing) | Partial — input side only; the destination is not in the transaction |
| DAP-03 | Phase 30 — dApp calldata decoding (end blind signing) | Complete |

**Coverage:** 5/5 active v2.0 requirements mapped — no orphans, no duplicates. FEE-01 was deferred
to the backlog on 2026-09-18 as a business item (see Out of scope). `SWAP-01` is one end-to-end promise owned by Phase 26 alone (the former 27 and 28 were the same work under three numbers); the drafted `SWP-01..08` that split it were retired into its criteria on 2026-09-16.

## Phases (v2.0)

- [x] **Phase 26: Swap that actually swaps** - Replace the mocked Squid layer with the real v2 API; no success shown for a swap that did not happen (completed 2026-09-17 — 8/8 plans, every one walked on Base mainnet; 26-VERIFICATION.md passed 33/33. Absorbs the former phases 27 and 28.)
- [x] **Phase 29: Fee transparency** - every fee the route charges, named and separate from chain gas, before the user confirms (completed 2026-09-18 — 4/4 plans; FEE-02 closed)
- [ ] **Phase 30: dApp calldata decoding (end blind signing)** - Reown approval drawers decode ERC-20 and known-router calldata; undecodable calls labeled with a visible warning

## Phase Details (v2.0)

### Phase 26: Swap that actually swaps

**Goal**: Replace the mocked Squid layer with the real v2 API; no success shown for a swap that did not happen
**Depends on**: Nothing within v2.0
**Requirements**: SWAP-01 (all eight criteria)
**Success Criteria** (what must be TRUE) — all five VERIFIED 2026-09-17, `26-VERIFICATION.md`:

  1. A swap on a real network moves real funds, and the receipt's hash resolves on the explorer — walked: `0xc74e959425605f69b0782ef5822dfaaa2ad9d9fc416fa01f9b426da9135b27f7`, Base 8453, 12.290107 USDC against a 12.338322 quote, inside slippage
  2. No success toast, receipt or stored transaction unless a hash came back — every side effect sits behind `sideEffectsFor`, exhaustive over a sealed outcome type; `grep 'hash: ""' lib/` is empty
  3. A failed or rejected swap leaves no row in Hive and tells the user what happened — six distinct messages, no default arm; walked with an underfunded send
  4. Quote, rate, price impact and fees come from the live route, not a constant — `/v2/route` read raw; `grep 993.72 lib/` is empty
  5. `SquidTokenService` contains no `mock*` return and no commented-out HTTP — the file is deleted; the catalogue lives behind `SwapProvider`

**Plans**: 26-01 … 26-08, all complete and walked. Directory `.planning/phases/26-swap-that-actually-swaps/`.
**Absorbs the former Phase 27** (live quotes, balances, slippage, rate limits — 26-03, 26-04) **and Phase 28** (real execution and honest recording — 26-05 … 26-08). They were three numbers for one end-to-end promise; keeping them as separate unstarted phases would have had the tooling asking to plan work that has already shipped. The numbering skips from 26 to 29 on purpose.
**Constraint**: do not modify the `squidrouter/` submodule (AGENTS.md — auto-generated). Five live drifts from its spec are worked around in the adapter, each recorded where it was found.

### Phase 29: Fee transparency

**Goal**: Route details name every fee the route charges and keep them separate from chain gas, so the user sees what they are paying before confirming — nothing merged, nothing silently deducted
**Depends on**: Phase 26 (fees are only real against live routes)
**Requirements**: FEE-02
**Success Criteria** (what must be TRUE):

  1. Every entry in the live route's `estimate.feeCosts[]` renders as its own named line with its own amount — the card no longer collapses them. Today a cross-chain route shows Axelar's `"Gas receiver fee"` and chain gas as a single `$0.92` (measured 2026-09-18: $0.91 + $0.01)
  2. Route fees and chain gas are visibly distinct — a user can tell what the network charged from what a service charged; readable in both appearances (widget test plus app-walk)
  3. A route carrying no fee costs reads correctly, with no placeholder and no `$0.00` line — this is the **normal** same-chain swap, which returns `feeCosts: []` (measured 2026-09-18)
  4. Nothing subtracts a fee from `toAmount` anywhere — the receive figure and the fee lines both come straight from the same route response, so the display cannot disagree with what Squid returns (grep-able and testable; it is also what makes netted-vs-on-top a non-question)
  5. No hard-coded fee label and no hard-coded percentage — names are matched case-insensitively and rendered as given, so a renamed or unrecognised fee still appears

**Plans**: 4/4 plans executed — strictly sequential, one wave each (every plan shares files with its predecessor)

- [x] 29-01-PLAN.md
- [x] 29-02-PLAN.md
- [x] 29-03-PLAN.md
- [x] 29-04-PLAN.md

- [x] **Wave 1** — 29-01-PLAN.md — pin how the generated enum exposes a fee name
- [x] **Wave 2** *(blocked on Wave 1)* — 29-02-PLAN.md — tracer: one route fee reaches the screen with its own name (blocking D-04 decision first)
- [x] **Wave 3** *(blocked on Wave 2)* — 29-03-PLAN.md — generic mapping: two-path parity, multi-entry, unknown name, malformed cost
- [x] **Wave 4** *(blocked on Wave 3)* — 29-04-PLAN.md — rendering: the empty case, fee-vs-gas distinctness, both appearances

**UI hint**: yes

**Re-scoped 2026-09-18.** Was "Integrator fee — the ~3% via the integratorId". FEE-01 moved to the
backlog as a business item: Squid sets the integrator fee server-side on the integrator ID, the
`/v2/route` request accepts no fee parameter, and live probes on **both** of our integrator IDs
(`supergenius-*`, `gnus.ai-wallet-*`) show none configured — proven by output amount, not just by
a missing field. Criterion 5 is what makes Squid's eventual switch a no-op in the app.

### Phase 30: dApp calldata decoding (end blind signing)

**Goal**: The Reown approval drawers decode calldata so the user signs with their eyes open — token moves and known-router swaps described in human terms, undecodable calls labeled as exactly that
**Depends on**: Nothing within v2.0 (independent subsystem, `lib/reown/` — may execute in parallel with 26-29; rides the Phase 21 033-B1 confirm-drawer chrome)
**Requirements**: DAP-01, DAP-02, DAP-03
**Success Criteria** (what must be TRUE):

  1. ERC-20 `transfer`/`approve` calldata decode and the approval flow (`handle_dapp_requests.dart` → `approve_transaction_drawer.dart` / `send_transaction_details.dart`) shows the decoded action — token, amount, counterparty — instead of raw or absent calldata (pure-Dart decoder unit tests over method-id + ABI-packed args, plus a drawer widget test)
  2. Known-router swap calls decode to a "swapping X → Y" summary in the drawer, starting with the selector the companion dApp actually uses (Squid/AggregatedRouter, 0x, UniversalRouter — fixtures from real transactions)
  3. Undecodable calldata renders an explicit unknown-contract-call warning — never presented as a plain send (widget test with a garbage/unknown-selector payload)
  4. Decoding is display-only: the transaction payload signed is byte-identical to before — the Phase 21 behavioral-identity contract test for the two signing drawers stays green (decode may not alter what is signed)

**Plans**: 4/4 plans executed

Plans:

- [x] 30-01-PLAN.md — tracer: one ERC-20 transfer decoded end to end, plus the measured branch baseline
- [x] 30-02-PLAN.md — approve, unlimited allowance, and the token this wallet cannot vouch for
- [x] 30-03-PLAN.md — unknown calls, the two sign methods that currently hang the caller, and an honest receipt
- [x] 30-04-PLAN.md — Squid input-side decode, the router allow-list, and the phase gate

**UI hint**: yes
**Security note**: signing-path UI — plans touching the two approve drawers carry a threat model, per the standing Phase 21 gate. Every plan in this phase carries one.

## Progress (v2.0)

**Execution Order:** 26 (complete) → 29 → 30. Phase 30 is independent of 26 and 29 and may run in
parallel with them. 27 and 28 were absorbed into 26 — see the reconciliation note at the top of
this milestone.

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 26. Swap that actually swaps | 8/8 | Complete — every plan walked on Base mainnet; 26-VERIFICATION.md passed 33/33 | 2026-09-17 |
| 29. Integrator fee | 0/TBD | Not started | - |
| 30. dApp calldata decoding (end blind signing) | 3/4 | In progress | - |
