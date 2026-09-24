# GeniusWallet

## What This Is

GeniusWallet is a Flutter/Dart self-custody crypto wallet targeting Windows, mobile, and web. It manages EVM wallets and integrates the native GeniusSDK (SGNUS) over Dart FFI, alongside fiat on-ramp (Banxa), cross-chain swaps (Squid Router), and dApp connectivity (Reown/WalletConnect). It is a mature, in-production codebase; GSD is being adopted onto it to structure ongoing work.

## Core Value

Users can safely custody their keys and reliably perform core wallet actions (create/import wallet, view balances, send/receive, swap, buy) — correctness and key safety come before everything else.

## Current State

**v2.0 Squid Router integration shipped 2026-09-24** (phases 26, 29, 30, 31; PRs #233-#235, #244): real Squid swaps on the `/swap` tab, every route fee named before confirming, dApp calldata decoded instead of blind-signed, and Send for native coins and ERC-20 tokens. DAP-02 ships the input side only; FEE-01 waits on Squid (business). Archive: `milestones/v2.0-ROADMAP.md`. v1.0 (redesign port) is still executing: phase 11 closeout and phase 14's last plan are open.

## Next Milestone Goals

Not yet defined — start with `/gsd-new-milestone`.

<details>
<summary>v2.0 milestone brief (archived)</summary>

### Milestone: v2.0 Squid Router integration

**Goal:** Make swapping real — the `/swap` tab executes live Squid Router quotes for major tokens with honest recording and a ~3% integrator fee, and the dApp path shows what it's signing.

**Target features:**
- Live Squid integration — **delivered (Phase 26, 2026-09-17)**: `SquidSwapProvider` behind the `SwapProvider` seam reads the live catalogue, balances and route; integratorId via `--dart-define-from-file`, never a literal
- Real submission — **delivered (Phase 26)**: `executeSwap` broadcasts the routed transaction and records the actual outcome behind a sealed `SwapOutcome`; the fake `completed`-with-`hash: ""` transaction is deleted and grep-gated. First real swap executed on Base mainnet 2026-09-17
- Slippage wired — **delivered (Phase 26)**: the settings drawer's slippage value feeds the live route request
- Catalogue-driven pickers — token/chain pickers list what the live catalogue returns, replacing hardcoded mocks
- Honest dApp signing — Reown approval drawers decode swap calldata ("swapping X → Y"), ending blind signing
- Integrator fee — the wallet takes ~3% on swaps routed through Squid (configured on the integratorId; visible in route details)

**Provenance:** decided in the 2026-09-16 explore session — see
`.planning/notes/2026-09-16-swap-architecture-archaeology.md` for the full timeline (Reown is
what shipped as the swap execution path; the Squid client was finished 2025-05 but never wired;
Symbiosis named once, never built) and the go-forward decision.

</details>

## Requirements

### Validated

<!-- Inferred from the codebase map (.planning/codebase/) — existing, relied-upon capabilities. -->

- ✓ Wallet onboarding: create new wallet, import existing, recovery-phrase backup/verify, PIN/keystore — existing (`lib/onboarding`)
- ✓ Dashboard: balances, holdings, transactions, markets, news — existing (`lib/dashboard`, `lib/wallets`)
- ✓ Fiat on-ramp via Banxa buy flow + order history/details — existing (`lib/banxa`, `lib/screens`)
- ✓ Cross-chain swap via Squid Router — `lib/squid_router` — **real since Phase 26 (2026-09-17)**: live catalogue, balances, quotes and execution against Squid v2; a swap executed on Base mainnet. (Corrected 2026-09-16 to "UI only, service mocked"; that correction is itself now history.)
- ✓ dApp connectivity via Reown/WalletConnect — existing (`lib/reown`)
- ✓ SGNUS / GeniusSDK integration over FFI (init status, processing, connection stream) — existing (`packages/genius_api`)
- ✓ Token info + market data (CoinGecko), charts — existing (`lib/tokens`, `lib/tokeninfo`, `lib/chart`)
- ✓ go_router navigation shell with responsive overlay + bottom nav — existing (`lib/navigation`, `lib/components/overlay`)
- ✓ Brand design system / theme tokens — existing (`lib/theme`)

### Active

<!-- v1.0 (redesign port) residue — still worked alongside v2.0, tracked in ROADMAP/todos. -->

- [x] Adopt GSD workflow for the project — shipped on `develop` via PR #207 (`12fd40d`)
- [x] Port the redesign onto `develop` incrementally, layer by layer (branch `ui-redesign-port`) — 21/23 official phases complete 2026-08-06; residue = phase 14 gaps (14-08 unwired), the mobile pass tail, deferred light-mode walks
- [x] Re-skin the surfaces develop gained after the designer forked (Settings, SDK account manager, Banxa rework, select-wallet-type) — done as part of the port above

<!-- v2.0 (current milestone) scope — see "Current Milestone" section above. -->

- [x] Wire the swap to the real `squidrouter/` client: live tokens, balances, route quotes (Phase 26; `SquidTokenService` itself was deleted — the seam is `SwapProvider`)
- [x] Execute real swaps: broadcast the routed transaction, record the actual outcome honestly (Phase 26, walked 2026-09-17)
- [x] Wire slippage settings into the live route request (Phase 26)
- [x] Drive token/chain pickers from the live Squid catalogue (Phase 26)
- [ ] Decode dApp swap calldata in the Reown approval flow (end blind signing)
- [ ] Collect ~3% integrator fee on swaps routed through Squid, visible in route details

### Out of Scope

- ~~Broad new-feature milestones (staking, new chains, etc.) — deferred until the redesign port lands~~ — superseded 2026-09-16: v2.0 (Squid Router integration) was authorized to proceed alongside the redesign tail; staking and other new chains remain deferred
- Re-architecting develop's structure — the port keeps develop's structure/logic and applies the redesign skin on top
- Landing the design in one step — 128 of its 172 files collide with develop's; see Key Decisions
- The designer's `WIRE-N` demo stubs and his branch-only features — see REQUIREMENTS.md (WIRE-01, WIRE-02)

## Context

- **Brownfield adoption.** GSD is layered onto an existing, in-production app. See `.planning/codebase/` for architecture, stack, conventions, testing, integrations, and concerns.
- **The design source.** `origin/ui-redesign-3.514` (Alex Faber) — forked from develop 2026-04-30. It carries the authoritative design system (`DESIGN_SYSTEM.md` v1.0, adopted; `gnus-tokens.json`; `gnus-mockups.html`) and 11 theme files. It is a **design prototype, not a working app**: `.planning/reference/ALEX-WIRING.md` (his own doc) records 11 `WIRE-N` stubs — Send doesn't broadcast, swap quotes are mocked, the dashboard's 24h delta is `balance * 0.024`. Take the visual; develop's logic always wins.
- **Reference material.** Worktree `GNUS-compare/GeniusWallet-3514` builds and runs Alex's branch as a Release exe — the visual source of truth. It shares the Hive data dir with the develop build, so the two cannot run at once.
- **Verification reality.** `flutter test` DOES work (measured 234 pass / 1 fail — the 1 fail is the
  commented-out `local_wallet_storage_test.dart`; the old "does not compile" claim was false, corrected
  2026-07-23). Prefer real test gates where behaviour can be asserted. Windows debug + hot reload
  (`4395da7`) remains the loop for what only a human walk can judge: build, run, edit, reload, look.

## Constraints

- **Tech stack**: Flutter pinned to **3.41.9** / Dart ~3.11 — the native deps and pubspec require it; do not bump casually.
- **Native build**: Windows build is CMake-driven and pulls prebuilt GeniusSDK/thirdparty binaries from GitHub releases (no checksum pinning). Requires VS Build Tools ≥14.40 + ATL, Developer Mode on.
- **Analysis gap**: `analysis_options.yaml` excludes `lib/**/*.g.dart` — the compiler, not `flutter analyze`, is the real gate for generated widgets.
- **Testing**: `flutter test` works (234 pass / 1 fail — the fail is a commented-out file, not a compile error; "does not compile" was a false belief, corrected 2026-07-23). Verification uses real test gates where possible, `flutter analyze` as a gate, plus a debug build and a human walk for visual/feel criteria.
- **Security**: crypto wallet — seed/key handling, FFI boundary, and WalletConnect sessions are sensitive. See `.planning/codebase/CONCERNS.md`.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| **Take Alex's visual, never his behavior or his new features** (2026-07-16) | Alex's own `WIRING.md` documents 11 `WIRE-N` stubs — surfaces that look finished but are demos. Send shows "submitted (demo)" and never broadcasts; Swap quotes are mocked; recipient validation is `length >= 6`; `"1,000"` parses to `1.0` (1000× under-send); the dashboard's 24h delta is `balance * 0.024`. Six touch money. develop has the real implementations. His branch is a design prototype, so porting a screen wholesale would downgrade working money-handling code into a demo. Rule: re-skin develop's screens in place; develop's logic always wins; Alex-only features (`lib/ai/`, `lib/preferences/`, address book, convert section, NFTs tab) are new capability needing product decisions and are out of scope | — Pending |
| **Re-skin, never restructure** (2026-07-16) | Applying an adopted design system to existing widgets is a translation with a right answer; moving items, changing IA or adding capability is a product judgement with no owner in this milestone. Surfaces keep their exact structure, order and behavior — they just wear the new tokens. Structural questions get recorded for product rather than decided here | — Pending |
| **Port the design incrementally, layer by layer** (2026-07-16) | The designer forked 2026-04-30; develop has +127 commits since, and **128 of the design's 172 files are files develop also changed** (74% overlap). Landing it in one step means reconciling all 128 at once with nothing verifiable in between. Layer by layer — tokens → primitives → shell → one screen area per phase — makes each step small enough to check by running the app, and each lands on develop on its own | — Pending |
| **Verify by running the app, never by `flutter analyze` alone** (2026-07-16; harness note corrected 2026-07-23) | Analyze-clean says nothing about runtime behavior. `flutter test` DOES work (234/1) and is now a real gate where behaviour can be asserted; criteria that only a human can observe (visual fidelity, contrast, feel) are still written as app-walk observations. `flutter analyze` is a gate, never evidence | — Pending |
| Fix Windows debug builds first (`4395da7`, on develop) | Debug builds were thought impossible (LNK1319 against `/MT`-only prebuilt native deps). Real cause was `_DEBUG` — not the runtime library — pulling in the debug CRT. Without hot reload, verifying a UI port is impractical; the first debug build immediately surfaced a startup crash that release had hidden for months | ✓ Good |
| Isolate GSD `.planning/` on `chore/adopt-gsd` (own PR, off develop) | Keeps the redesign PR focused; `.planning/` is project infra for the whole team | — Pending |
| Interactive mode (not YOLO) | GSD config is committed to the shared repo, so a conservative, approval-gated mode is safer for team-shared automation | — Pending |
| Close a phase with recorded overrides rather than a cosmetic patch (Phase 5, 2026-07-21) | The dashboard Bitcoin Chart card's zoom/pan row overflowed by 34px because the card has no vertical room at the app's ordinary window size — a genuine layout defect, not a component bug (the same widget is fine on token detail's taller slot). A considered stopgap (hiding the row below a height threshold) would have cleared the overflow while leaving only a 6.5px chart hairline — "a non-overflowing broken card, not a fixed one." The user inspected the app directly, rejected the stopgap, and authorized closing the phase with this and two related unwalked items (Release-exe comparison, transactions/news pull-to-refresh) recorded as explicit, reasoned overrides in 05-VERIFICATION.md instead. Establishes the pattern: an honest, recorded gap beats a cosmetically-clean but substantively-unfixed patch | ✓ Applied — see `05-VERIFICATION.md` `overrides:` |
| **v2.0 swap architecture: major tokens via Squid in-app; GNUS stays on the native burn→mint bridge; Reown stays as general dApp connectivity; ~3% integrator fee** (2026-09-16) | Established in the explore session: the finished-but-unwired Squid client (submodule, 2025-05) + free API is the cheapest real path for listed tokens. GNUS-on-a-router is BD-driven on both Squid (market-maker loan) and Symbiosis ("additional review") — a business workstream, not engineering, so the native bridge remains GNUS's cross-chain answer. Symbiosis was named once (squidrouter commit `ee95bf6`) and never built — not pursued. The `/swap` tab's fake success (mock quote, `TODO` submit, fake `completed` tx) is a user-facing lie and the milestone's driving defect | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-09-16 after milestone v2.0 (Squid Router integration) started*
