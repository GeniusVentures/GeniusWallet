# Handoff: v3.0 child wallets PR #261 and phase 39 Banxa (2026-09-30)

## Where things are

- **PR #261** (draft, base develop, branch `gsd/v3.0-child-wallets`, worktree `../GW-child`): phases 34-38. 10 Codex rounds; CI green and Codex +1 on `f5b45f09`, all threads resolved. Still draft until the live walks (UAT files in phases 34-38). Four registry edge cases deferred to `.planning/todos/pending/2026-09-30-child-op-registry-edge-cases.md` until the walk against a real node.
- **Phase 39 Banxa** (branch `gsd/v3.0-banxa-hardening`, stacked on the child-wallets branch, worktree `../GW-v3`, NOT pushed): 13/13 plans executed, 13 review warnings fixed, verification `human_needed`. 2360 tests pass, analyze clean. UAT items in `39-UAT.md`.
- **Phase 40** (always-available Bridge button): added to the roadmap, not planned.
- Main checkout `GeniusWallet` is on `develop`.

## Blocked on others

- Banxa does not list GNUS for partner `gnus`, in production or sandbox (checked 2026-09-30; sandbox answers with 159 coins / 32 fiats). Blocks the full sandbox buy and the return-URL gate. Ask Banxa to list GNUS and name the delivery chain.
- Rotate the leaked production Banxa key (still in git history) and add `BANXA_API_KEY` as a GitHub Actions secret.
- Sandbox key: Braian has it; pass only as `--dart-define=GW_BANXA_API_KEY=...` with `--dart-define=GW_BANXA_SANDBOX=true`. Never commit it.

## Next

1. Windows sandbox walk of the Banxa branch (UAT items 1-3).
2. Push `gsd/v3.0-banxa-hardening` and open a draft PR stacked on #261.
3. `/gsd-plan-phase 40`.
4. Mark #261 ready once the child-wallet live walks pass.
