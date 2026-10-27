# Handoff: v4.0 processing dashboard bridge, overnight run 2026-10-26/27

Branch `claude/gsd-dashboard-bridge-milestone-b6a5e7` (worktree `.claude/worktrees/gsd-dashboard-bridge-milestone-b6a5e7`),
reset onto `origin/develop` 7b0d7a1a at the start (it had been cut from stale `main`; the one `main`-only
commit, 258184a8 "C++ engineering constraints in AGENTS.md", is not on this branch). Nothing pushed, no PR.
All commits authored braianwegmann@gmail.com, no Claude attribution.

Braian asked the session to run GSD overnight in both repos and answer questions itself. Every scoping
choice is marked (D) in STATE.md Decisions, the phase CONTEXT files and the contract. None is reviewed yet.

## What exists now

- Milestone v4.0 in PROJECT.md, REQUIREMENTS.md (27 reqs: RPC, DWV, DWC, CNS, ISO, WALK; SDK-* as
  dependencies), ROADMAP.md (phases 42-48), STATE.md. v3.0 stays open alongside (live walks only).
- Contract: `research/v4.0-gnus-rpc-contract.md` (canonical), mirrored verbatim to the side-session notes
  for the dashboard. Revised several times tonight from the dashboard research (units, version, UA marker,
  idempotency lookup, -32005 reasons, -32015 for switch, WalletConnect expiry and event chain, gas as a
  gwei price, data.reason table, timeouts and job limits).
- Phase 42 (ISO-01) done: `JobSubmission` owner in `lib/submit_job/`, cost and process via `Isolate.run`,
  sync SDK calls deleted. Reviewed (CR-01 + 3 warnings fixed). Verified human_needed: real-SDK
  "keeps animating" check deferred to the phase 48 walk.
- Phase 43 (RPC-01..09) done: `lib/gnus_bridge/` handler, Hive job record, idempotency, one-burn lock in
  `JobSubmission`, accounts/earnings/events, exact unit conversions. Default confirm REJECTS (4001); no
  page can reach the handler yet. Reviewed (CR-01 + 12 warnings fixed, WR-06/WR-08 partial). Verified
  human_needed: live SDK results blocked on SDK-*, real relaunch not walked.
- Tests: full suite 2878 pass / 6 skip / 0 fail (baseline at start 2663/6/0); analyze clean.

## Needs Braian

1. Review the (D) decisions, especially: v4.0 parallel to v3.0; atomic in-wallet submit; pinned https
   origin instead of a bundled export; MetaMask-only users cannot submit.
2. Phase 43 fix WR-01 changed the shared burn in `genius_api` (also used by the token bridge screen): exact
   amount conversion, and it refuses a token whose decimals are not 18 (ponytail). Check that is right for
   every chain GNUS lives on.
3. Phase 44 (consent UI) not started on purpose: it is the first UI a user sees for spends.
4. Contract open questions U1 (SDK cost unit), U5 (can Process be re-run after a burn), payer with no EVM
   address over WalletConnect, deep-link scheme, contract fixtures for the dashboard.
5. SDK asks for SuperGenius: SDK-CA (cost always 0), SDK-COSTERR, SDK-JOBID, SDK-STATUS, SDK-RESULT,
   SDK-EARNINGS, SDK-PAYOUT.

## Next

`/gsd-discuss-phase 44` (consent UI), or `/gsd-plan-phase 45` (transport hardening, no UI) in parallel.
