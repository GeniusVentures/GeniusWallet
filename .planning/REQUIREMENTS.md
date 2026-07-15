# Requirements: GeniusWallet

**Defined:** 2026-07-15
**Core Value:** Users can safely custody their keys and reliably perform core wallet actions.

## v1 Requirements

Scope of the current (minimal) milestone: adopt GSD and complete/harden the UI-redesign forward-port onto `develop`.

### Tooling (GSD)

- [ ] **GSD-01**: `.planning/` GSD infrastructure established (PROJECT, config, codebase map, roadmap, state) and committed on `chore/adopt-gsd`

### Redesign Forward-Port (RFP)

- [ ] **RFP-01**: Remaining low-priority develop-logic drops on `ui-redesign-3.514-develop` are reviewed and reconciled (port or consciously drop): `dashboard_screen` pull-to-refresh, `crypto_live_chart` window/timestamps, `reown_connect_button` init guard, `crypto_news_screen` retry/refresh, `coins_screen` poll interval
- [ ] **RFP-02**: `lib/onboarding/existing_wallet/view/import_wallet_screen.dart` re-skinned to the redesign
- [ ] **RFP-03**: Nav shell and key flows (onboarding, dashboard, swap, Banxa) pass a visual/UAT review — the nav shell has never been eyeballed
- [ ] **RFP-04**: Forward-port branch merged into `develop` with `flutter analyze` = 0 errors and a successful Windows build

## v2 Requirements

Deferred to future milestones (post-forward-port).

### App

- **APP-01**: Broader feature roadmap (new chains, staking, etc.) — scoped in a later milestone
- **APP-02**: Establish a working automated test harness (`flutter test` currently does not compile)

## Out of Scope

| Feature | Reason |
|---------|--------|
| Big-bang merge of `origin/ui-redesign-3.514` | Rejected after analysis — 115 conflicts, structural collisions |
| Re-architecting develop's structure | Forward-port keeps develop's structure/logic, applies skin on top |
| New feature milestones | Deferred until forward-port lands |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| GSD-01 | Phase 1 | Pending |
| RFP-01 | Phase 2 | Pending |
| RFP-02 | Phase 2 | Pending |
| RFP-03 | Phase 3 | Pending |
| RFP-04 | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 5 total
- Mapped to phases: 5
- Unmapped: 0

---
*Last updated: 2026-07-15 after initialization*
