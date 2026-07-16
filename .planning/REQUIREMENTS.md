# Requirements: GeniusWallet

**Defined:** 2026-07-15
**Re-scoped:** 2026-07-16 — whole-branch forward-port superseded by an incremental component port
**Core Value:** Users can safely custody their keys and reliably perform core wallet actions.

## v1 Requirements

Scope: land the `ui-redesign-3.514` design on `develop` incrementally, at low risk, without losing
develop's behavior — and extend the design language to the features develop gained after the
designer forked.

**Why incremental:** the designer forked at `0495436` (2026-04-30). develop has +127 commits since,
and **128 of the design's 172 changed files are files develop also changed** (74% overlap). The
whole-branch approaches (merge, then forward-port) each had to reconcile all 128 at once with no way
to verify a slice — the forward-port compiled cleanly and still dropped 37 develop behaviors,
3 of them blockers.

### Tooling (GSD)

- [x] **GSD-01**: `.planning/` GSD infrastructure established and committed — shipped on `develop` via PR #207 (`12fd40d`)

### Build & Verification (BLD)

- [x] **BLD-01**: Windows debug builds link and run, with hot reload and the Dart debugger — prerequisite for verifying any UI work (`4395da7`, on develop)
- [x] **BLD-02**: Each port phase is verified by running the app (debug build + visual walk), not by `flutter analyze` alone — analyze-clean is what masked the forward-port's 37 regressions
- [x] **BLD-03**: Dev-only affordances stay out of normal builds — the `Dev` header row and the onboarding `Mock` button (which injects a fake wallet + 20 fake transactions) are gated behind an opt-in flag

### Design System (DS)

The design's 82 new files are mostly `gw_*` primitives. They are additive to develop (new files, no
collisions), so they carry the lowest risk and everything else depends on them.

- [x] **DS-01**: Redesign theme tokens (colours, typography, spacing, decorations) live on `develop` and coexist with develop's existing theme without breaking un-ported screens
- [ ] **DS-02**: The `gw_*` component library is ported to `develop` (buttons, cards, inputs, feedback states, token/wallet rows, mesh background, icons)
- [ ] **DS-03**: A developer can view every ported primitive in one place to confirm fidelity against the design (`/design_gallery`)
- [ ] **DS-04**: Redesign assets referenced by the design system are declared and bundled (e.g. `assets/images/textures/`, whose omission broke the mesh background on the forward-port)

### Navigation Shell (NAV)

- [ ] **NAV-01**: The app shell wears the redesign skin (desktop rail + mobile bottom nav) on develop's `go_router` config, with every existing route still reachable
- [ ] **NAV-02**: The shell survives startup and navigation without runtime exceptions — including the `!_dirty` crash the forward-port hit when the initial route resolved mid-mount

### Screen Areas (SCR)

One phase per area. Each lands on the already-ported design system, keeps develop's logic, and is
verified by running the flow.

- [ ] **SCR-01**: Dashboard (balances, holdings, transactions, markets, news) wears the redesign and keeps develop's behavior — pull-to-refresh, error/empty states, poll intervals, accountStatus gating
- [ ] **SCR-02**: Onboarding (create, import, recovery phrase, verify, legal) wears the redesign and keeps develop's behavior — including the seed-phrase read-only/hide-toggle and no seed logging
- [ ] **SCR-03**: Token screens (token info, send, receive, address book, market data) wear the redesign
- [ ] **SCR-04**: Swap (Squid Router) wears the redesign and keeps develop's route/fee/slippage logic
- [ ] **SCR-05**: Banxa (buy, KYC, checkout, order history/details) wears the redesign and keeps develop's rework — including the real KYC redirect URL
- [ ] **SCR-06**: dApp connectivity (Reown/WalletConnect) wears the redesign and keeps develop's idempotent init guard — the forward-port's arch check killed WalletConnect on all x64 desktop

### Design Gaps (GAP)

develop added 12 files the design has never seen. They have no mockup, no `DESIGN_SYSTEM.md` entry
and no implementation on Alex's branch.

**Decision (2026-07-16, user):** these surfaces DO get re-skinned — the line is re-skin vs
restructure, not designed vs undesigned.

- **In scope (no product decision needed):** apply the tokens and `gw_*` primitives to the widgets
  that are already there. The surface keeps its exact structure, item order, wording, and behavior —
  it just wears the new colours, type, spacing, radius and components. This is a mechanical
  translation of an existing layout into the design language.
- **Out of scope (product decision required):** moving or reordering items, changing information
  architecture, merging/splitting screens, adding or removing capability, or inventing a surface Alex
  never drew. If applying the design language *requires* one of these to look right, stop, leave that
  part as-is, and record it for product rather than deciding it here.

Rationale: re-skinning to an adopted design system is a translation with a right answer; restructuring
is a product judgement with no owner in this milestone. Shipping an invented structure nobody signed
off is worse than an obvious gap product can prioritise.

- [ ] **GAP-01**: Every develop surface with no Alex design is inventoried, and each is split into
      what can be re-skinned mechanically vs what would need a structural/product decision. The
      inventory, its evidence, and any deferred structural questions are written down for product
- [ ] **GAP-02**: Settings screen (`lib/settings/settings_screen.dart`) — re-skinned in place; structure/rows unchanged
- [ ] **GAP-03**: SDK account manager (`lib/account/sdk_account_manager.dart`) — re-skinned in place; structure unchanged
- [ ] **GAP-04**: Select-wallet-type onboarding step (`lib/onboarding/existing_wallet/view/select_wallet_type_screen.dart`) and `wallet_routes.dart` — re-skinned in place; flow and routing unchanged
- [ ] **GAP-05**: Banxa additions (`banxa_orders_history.dart`, `banxa_payment.dart`, `screens/banxa_buy_screen.dart`) — re-skinned in place; structure unchanged
- [ ] **GAP-06**: Misc develop additions (`components/wallet_overview.dart`, `components/loading.dart`, `dashboard/home/widgets/transaction_displays.dart`) — re-skinned in place; structure unchanged

GAP-02..06 are satisfied when the surface wears the design language AND a before/after comparison
shows the same items, in the same order, doing the same things. Any structural question these raise
is recorded for product, not answered here.

### Alex's Demo Stubs and New Features (WIRE)

**Decision (2026-07-16, user):** take Alex's **visual** only. Never port a feature his branch
implements that develop doesn't already have, and never port a `WIRE-N` stub over develop's working
code.

Alex's `.planning/WIRING.md` (in the reference worktree) documents **11 `WIRE-N` markers** — surfaces
that look finished but return mock data or do nothing. Six are marked 💰 *touches money*. His branch
is a design prototype, not a working app. Verified examples:

| Marker | Alex's branch | develop |
|--------|---------------|---------|
| WIRE-2 | Send shows `Transaction submitted (demo)` — **no broadcast** | real `GeniusApi.signAndSendTransaction` |
| WIRE-3 | recipient validation is `recipient.length >= 6` — any 6+ chars passes | — |
| WIRE-4 | `"1,000"` parses to `1.0` — a **1000× under-send** | — |
| WIRE-1 | Swap quote/rate is mocked; `squid_token_service` returns hardcoded `mock*` | real Squid calls |
| WIRE-9 | dashboard 24h delta is `balance * 0.024` — a fabricated +2.4% | — |
| WIRE-8 | NFT list is 6 hardcoded tiles | — |
| WIRE-7 | currency picker changes the symbol only; values stay USD | — |

Porting these would regress working, money-handling features into demos and show users invented
numbers. The whole-branch forward-port did exactly this and accepted it (finding 21).

- [ ] **WIRE-01**: No `WIRE-N` stub from Alex's branch reaches develop. Before any screen phase lands,
      `grep -rn "WIRE-" ` over the ported surface returns nothing, and the screen still calls
      develop's real implementation. Where Alex's version is a demo and develop's is real,
      **develop's logic wins and only the skin is taken**
- [ ] **WIRE-02**: Alex-only features that develop does not have are OUT of scope for this milestone —
      `lib/ai/` (AI FAB + processing status, WIRE-10), `lib/preferences/` (currency picker, WIRE-7),
      `lib/tokens/address_book.dart`, `lib/tokens/convert_section.dart`, the NFTs tab (WIRE-8). They
      are new capability, mostly demo-backed, and need product decisions about whether the feature
      should exist at all. Recorded for product; not built here

### Behavior Preservation (BEH)

- [ ] **BEH-01**: The 37 findings in `.planning/REVIEW_FINDINGS_REDESIGN.md` are used as a checklist — each is confirmed non-regressed as its component lands (they were found the hard way once already)
- [ ] **BEH-02**: The 3 remaining fix commits on `ui-redesign-3.514-develop` are ported with their components: `7a63b4f` (`!_dirty` guard → NAV), `f3fd16f` (dev-tools gating → BLD-03), `d8db88c` (assets/textures → DS-04)

## v2 Requirements

Deferred to future milestones.

### App

- **APP-01**: Broader feature roadmap (new chains, staking, etc.) — scoped in a later milestone
- **APP-02**: Establish a working automated test harness (`flutter test` does not compile; the
  `!_dirty` bug could not be reproduced under `pumpWidget` because it mounts during a frame while
  `runApp` does not — the class of bug a harness would need to catch)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Alex's `WIRE-N` demo stubs (all 11) | His branch is a design prototype: Send doesn't broadcast, Swap quotes are mocked, the 24h delta is `balance * 0.024`. develop's real implementations win — we take the skin, not the behavior. See WIRE-01 |
| Alex-only features develop lacks (`lib/ai/`, `lib/preferences/`, address book, convert section, NFTs tab) | New capability, mostly demo-backed, needs a product decision on whether it should exist. Recorded for product. See WIRE-02 |
| Restructuring any surface (moving/reordering items, changing IA, splitting/merging screens) | Product judgement with no owner in this milestone. Re-skin in place; record structural questions for product |
| Big-bang merge of `origin/ui-redesign-3.514` | Rejected after analysis — 115 conflicts, structural collisions |
| Whole-branch forward-port (`ui-redesign-3.514-develop`) | Superseded 2026-07-16 — compiled clean but dropped 37 develop behaviors; kept as read-only reference |
| Re-architecting develop's structure | The port keeps develop's structure/logic and applies the skin on top |
| Porting the redesign's `hive` (classic) usage | develop uses `hive_ce`; develop's data layer wins |
| New feature milestones | Deferred until the port lands |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| GSD-01 | Phase 1 — Adopt GSD | ✓ Complete (PR #207, `12fd40d`) |
| BLD-01 | Phase 1 — Adopt GSD | ✓ Complete (`4395da7`) |
| DS-01 | Phase 2 — Design tokens & verification loop | Complete |
| BLD-02 | Phase 2 — Design tokens & verification loop | Complete |
| BLD-03 | Phase 2 — Design tokens & verification loop | Complete |
| DS-02 | Phase 3 — gw_* component library | Pending |
| DS-03 | Phase 3 — gw_* component library | Pending |
| DS-04 | Phase 3 — gw_* component library | Pending |
| GAP-01 | Phase 3 — gw_* component library | Pending |
| NAV-01 | Phase 4 — Navigation shell & chrome | Pending |
| NAV-02 | Phase 4 — Navigation shell & chrome | Pending |
| BEH-02 | Phase 4 — Navigation shell & chrome | Pending |
| GAP-02 | Phase 4 — Navigation shell & chrome | Pending |
| GAP-03 | Phase 4 — Navigation shell & chrome | Pending |
| SCR-01 | Phase 5 — Dashboard | Pending |
| GAP-06 | Phase 5 — Dashboard | Pending |
| SCR-02 | Phase 6 — Onboarding | Pending |
| GAP-04 | Phase 6 — Onboarding | Pending |
| SCR-03 | Phase 7 — Token screens | Pending |
| SCR-04 | Phase 8 — Swap & bridge | Pending |
| SCR-05 | Phase 9 — Banxa | Pending |
| GAP-05 | Phase 9 — Banxa | Pending |
| SCR-06 | Phase 10 — dApp connectivity | Pending |
| BEH-01 | Phase 11 — Port closeout | Pending |

**Cross-cutting requirements — where they close:**

- **BEH-02** spans three fix commits but *closes* in Phase 4, where the last of them lands.
  Phase 2 carries `f3fd16f` (dev gating → BLD-03), Phase 3 carries `d8db88c` (textures → DS-04),
  Phase 4 carries `7a63b4f` (`!_dirty` guard → NAV-02). See ROADMAP.md Overview.

- **BEH-01** is enforced continuously — each phase confirms its own subset of the 37 findings
  non-regressed (per-phase assignment table in ROADMAP.md) — but *closes* in Phase 11, where the
  full set is signed off by a whole-app walk.

- **BLD-02** (verify by running the app, not by analyze) is *established* in Phase 2 and is a
  standing condition of every later phase's success criteria; it is not re-mapped per phase.

**Coverage:**

- v1 requirements: **24 total** — corrected 2026-07-16; the previous "22" miscounted
  (1 GSD + 3 BLD + 4 DS + 2 NAV + 6 SCR + 6 GAP + 2 BEH = 24)

- Complete: 2 (GSD-01, BLD-01 — Phase 1)
- Mapped to phases: **24/24 ✓** — every v1 requirement maps to exactly one phase; no orphans, no duplicates
- Phases: 11 (1 complete, 10 remaining)
- Removed 2026-07-16: RFP-01..04 (whole-branch forward-port) — superseded along with old Phases 2–4

---
*Last updated: 2026-07-16 — traceability mapped to the incremental port roadmap*
