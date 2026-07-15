# GeniusWallet

## What This Is

GeniusWallet is a Flutter/Dart self-custody crypto wallet targeting Windows, mobile, and web. It manages EVM wallets and integrates the native GeniusSDK (SGNUS) over Dart FFI, alongside fiat on-ramp (Banxa), cross-chain swaps (Squid Router), and dApp connectivity (Reown/WalletConnect). It is a mature, in-production codebase; GSD is being adopted onto it to structure ongoing work.

## Core Value

Users can safely custody their keys and reliably perform core wallet actions (create/import wallet, view balances, send/receive, swap, buy) — correctness and key safety come before everything else.

## Requirements

### Validated

<!-- Inferred from the codebase map (.planning/codebase/) — existing, relied-upon capabilities. -->

- ✓ Wallet onboarding: create new wallet, import existing, recovery-phrase backup/verify, PIN/keystore — existing (`lib/onboarding`)
- ✓ Dashboard: balances, holdings, transactions, markets, news — existing (`lib/dashboard`, `lib/wallets`)
- ✓ Fiat on-ramp via Banxa buy flow + order history/details — existing (`lib/banxa`, `lib/screens`)
- ✓ Cross-chain swaps via Squid Router — existing (`lib/squid_router`)
- ✓ dApp connectivity via Reown/WalletConnect — existing (`lib/reown`)
- ✓ SGNUS / GeniusSDK integration over FFI (init status, processing, connection stream) — existing (`packages/genius_api`)
- ✓ Token info + market data (CoinGecko), charts — existing (`lib/tokens`, `lib/tokeninfo`, `lib/chart`)
- ✓ go_router navigation shell with responsive overlay + bottom nav — existing (`lib/navigation`, `lib/components/overlay`)
- ✓ Brand design system / theme tokens — existing (`lib/theme`)

### Active

<!-- Current near-term scope. Kept thin per "minimal GSD infra" milestone. -->

- [ ] Adopt GSD workflow for the project (this branch: `chore/adopt-gsd`)
- [ ] Complete & harden the UI-redesign forward-port onto `develop` (branch `ui-redesign-3.514-develop`): remaining low-priority develop drops, `import_wallet_screen.dart` re-skin, visual/UAT pass on the nav shell, then merge to `develop`

### Out of Scope

- Broad new-feature milestones (staking, new chains, etc.) — deferred until GSD infra is in place and the redesign forward-port lands
- Re-architecting develop's structure — the forward-port deliberately keeps develop's structure/logic and applies the redesign skin on top
- Big-bang merge of `origin/ui-redesign-3.514` into develop — rejected after analysis (115 conflicts, structural collisions); the manual forward-port is the chosen path

## Context

- **Brownfield adoption.** GSD is being layered onto an existing app. See `.planning/codebase/` for architecture, stack, conventions, testing, integrations, and concerns.
- **UI-redesign forward-port in flight.** A designer's redesign (`origin/ui-redesign-3.514`, based on an April-2026 develop snapshot) is being re-applied onto current `develop` via a clean rewrite on `ui-redesign-3.514-develop` (~87% done, 0 analyze errors). A fidelity audit (2026-07-15) confirmed it faithful: 8 minor develop-logic drops, 0 high-severity; the 3 medium drops (`network_page` SDK-init polling, `sgnus_connection_widget` init-progress polling, `image_utils` null-guard) are already ported and pushed.
- **Branching for this adoption.** `.planning/` scaffolding is isolated on `chore/adopt-gsd` (off `develop`) as its own PR, to keep the redesign PR clean.

## Constraints

- **Tech stack**: Flutter pinned to **3.41.9** / Dart ~3.11 — the native deps and pubspec require it; do not bump casually.
- **Native build**: Windows build is CMake-driven and pulls prebuilt GeniusSDK/thirdparty binaries from GitHub releases (no checksum pinning). Requires VS Build Tools ≥14.40 + ATL, Developer Mode on.
- **Analysis gap**: `analysis_options.yaml` excludes `lib/**/*.g.dart` — the compiler, not `flutter analyze`, is the real gate for generated widgets.
- **Testing**: no working test harness — `flutter test` does not compile on the forward-port branch. Verification leans on `flutter analyze` + build + manual UAT.
- **Security**: crypto wallet — seed/key handling, FFI boundary, and WalletConnect sessions are sensitive. See `.planning/codebase/CONCERNS.md`.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Manual forward-port over merging `ui-redesign-3.514` | 7-agent analysis: merge yields 115 conflicts incl. structural modify/delete collisions; both paths need the same ~106 semantic calls, but the manual branch already made them and compiles | ✓ Good |
| Isolate GSD `.planning/` on `chore/adopt-gsd` (own PR, off develop) | Keeps the redesign PR focused; `.planning/` is project infra for the whole team | — Pending |
| Interactive mode (not YOLO) | GSD config is committed to the shared repo, so a conservative, approval-gated mode is safer for team-shared automation | — Pending |
| Minimal first milestone (adopt infra only) | Establish a usable `.planning/` now; defer broad milestone planning until the forward-port lands | — Pending |

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
*Last updated: 2026-07-15 after initialization*
