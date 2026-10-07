# Handoff: Phase 40, always-available GNUS bridge (2026-10-07)

Worktree `../GW-v3`, branch `gsd/v3.0-banxa-hardening`. Everything is committed locally and not pushed.

## Done
- Phase 40 discussed, researched, UI-SPEC'd, planned and executed: 4 plans, 3 waves.
- Scope cut on 2026-10-07: Bridge is on the GNUS coin page only. The dashboard and /assets placements are deferred to
  `.planning/todos/pending/2026-10-07-find-a-better-home-for-bridge.md`.
  Mockup: https://claude.ai/artifact/WDdsq3ZMHiewdMdbUFX4ko
- Bridge is enabled only for the live earning wallet. Otherwise it is disabled with a one-line reason.
- BridgeScreen refuses at submit when the gate is closed, or when the coin about to be burned is not the coin the gate approved.
- Code review: 4 warnings, all fixed (4fc451b4, 40141001, 706ceec7, 8727ead0).
  - The child check now fails closed.
  - The other-network probe has an 8 second timeout.
  - A failed coins read now gets its own caption, "Couldn't read your GNUS balance."
- Gate results after the fixes:
  - `flutter test`: +2476 ~6, all passed.
  - `flutter analyze`: exit 0.
  - format and brace checks: clean.
  - Windows debug build: compiled. This ran before the fixes.

## Open
- Live walk: `40-UAT.md` has 3 tests. It is blocked on the testnet registry, the same blocker as the phase 34-39 walks.
  None of the tracer human checks were done, because all plans ran in one pass.
- After the walk passes, run `/gsd-verify-work 40`. Tick BRDG-01..08 by hand, since GSD's `phase.complete` mangles STATE.md.
- Bridge internals I found but did not touch. Candidate todos or a follow-up phase:
  - `mintTokens` is fire-and-forget, so a failed mint after a successful burn is silent.
  - The mint is passed `destinationChainId`; confirm whether the SDK wants the source chain id instead.
  - The token id is hardcoded to 0.
  - The `catch` in `executeBridgeOutTransaction` drops its error.
  - `bridge.json` lists only the testnet destination.
- Accepted limits:
  - Child detection only checks mains held in this app.
  - A switch that lands after `bridgeOut` has signed is not caught.
