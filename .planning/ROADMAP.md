# Roadmap: GeniusWallet

## Overview

This is a brownfield GSD adoption. The current milestone is intentionally minimal: stand up GSD's `.planning/` infrastructure, then complete and harden the in-flight UI-redesign forward-port (`ui-redesign-3.514-develop`) and land it on `develop`. Broader app roadmapping is deferred to a later milestone once the forward-port ships.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [ ] **Phase 1: Adopt GSD** - Establish and commit `.planning/` infrastructure
- [ ] **Phase 2: Forward-port fidelity** - Reconcile remaining develop-logic drops + re-skin import wallet screen
- [ ] **Phase 3: Visual & UAT hardening** - Eyeball the nav shell and key flows, fix regressions
- [ ] **Phase 4: Merge to develop** - Land the forward-port on develop, analyze-clean + building

## Phase Details

### Phase 1: Adopt GSD
**Goal**: A committed, usable GSD setup on `chore/adopt-gsd`
**Depends on**: Nothing (first phase)
**Requirements**: GSD-01
**Success Criteria** (what must be TRUE):
  1. `.planning/` contains PROJECT.md, config.json, codebase map, REQUIREMENTS.md, ROADMAP.md, STATE.md
  2. The setup is committed and ready to open as its own PR into `develop`
**Plans**: TBD

Plans:
- [ ] 01-01: Finalize and commit `.planning/` scaffolding

### Phase 2: Forward-port fidelity
**Goal**: The forward-port carries every develop behavior worth keeping, plus the last redesign skin gap
**Depends on**: Phase 1
**Requirements**: RFP-01, RFP-02
**Success Criteria** (what must be TRUE):
  1. Each of the 5 low-priority develop drops is either ported or consciously dropped with a note
  2. `import_wallet_screen.dart` is re-skinned to the redesign
  3. `flutter analyze` stays at 0 errors
**Plans**: TBD

Plans:
- [ ] 02-01: Reconcile the 5 low-priority develop-logic drops
- [ ] 02-02: Re-skin `import_wallet_screen.dart`

### Phase 3: Visual & UAT hardening
**Goal**: The redesign is confirmed correct at runtime, not just analyze-clean
**Depends on**: Phase 2
**Requirements**: RFP-03
**Success Criteria** (what must be TRUE):
  1. The nav shell is walked visually (it has never been eyeballed)
  2. Onboarding, dashboard, swap, and Banxa flows are exercised and pass
  3. Any regressions found are fixed
**Plans**: TBD

Plans:
- [ ] 03-01: Build + walk the app, log and fix visual/UAT regressions

### Phase 4: Merge to develop
**Goal**: The forward-port lands on `develop`
**Depends on**: Phase 3
**Requirements**: RFP-04
**Success Criteria** (what must be TRUE):
  1. `flutter analyze` = 0 errors and a Windows release build succeeds
  2. Branch merged into `develop` (via PR)
**Plans**: TBD

Plans:
- [ ] 04-01: Final verification and merge

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Adopt GSD | 0/1 | Not started | - |
| 2. Forward-port fidelity | 0/2 | Not started | - |
| 3. Visual & UAT hardening | 0/1 | Not started | - |
| 4. Merge to develop | 0/1 | Not started | - |
