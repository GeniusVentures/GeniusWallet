# Handoff — 2026-09-19 — phase 30 shipped, three PRs open

Executor session. Branch ended on `phase-30-calldata-decoding`, tree clean apart from
the pre-existing untracked `squid.local.json`.

## What happened

- **Phase 29 (fee transparency)** was self-reviewed by four agents, four findings fixed,
  rebased onto the phase-26 tip, and opened as draft **PR #234**.
- **Phase 30 (dApp calldata decoding)** ran end to end — context, research, patterns, four
  plans, four execution waves, verification — and opened as draft **PR #235**. This closes
  the last phase of milestone v2.0.

## The three PRs, and the order they have to move in

| PR | Branch | Base | State |
|---|---|---|---|
| #233 | `phase-26-swap-wiring` | `develop` | Ready. 10/10 checks, 10/10 threads resolved. **Unmerged — this is the bottleneck.** |
| #234 | `phase-29-integrator-fee` | `phase-26-swap-wiring` | Draft. **Gets no CI at all** — `build.yml` only triggers `pull_request` on `develop`/`main`. Retarget to develop once #233 merges. |
| #235 | `phase-30-calldata-decoding` | `develop` | Draft. Cut from develop, independent of the swap stack, so CI runs normally. |

Merging #233 unblocks #234's retarget and its first CI run. Nothing blocks #235.

## Baselines — do not read these against each other

- `phase-26-swap-wiring`: 1366 → after yesterday's fixes, the stack sits higher
- `phase-29-integrator-fee`: **1392** pass / 5 skip / 0 fail
- `phase-30-calldata-decoding`: **1342** pass / 3 skip / 0 fail

30's number is lower because it is cut from develop, which carries neither 26 nor 29.
That is arithmetic, not a regression. This repo has burned a day on exactly this confusion
before.

## Decisions that are settled — do not re-litigate

- **DAP-02 ships PARTIAL and the requirement box stays unticked.** Squid's router is a
  generic multicall: verified against our own recorded response, word 0 is exactly
  `fromToken.address` and word 1 exactly `fromAmount`, but `toToken` appears only nested at
  a route-dependent position and `toAmount` not at all. The drawer says what is being spent
  and states the destination is unreadable. Locating it by scanning the blob is a heuristic
  a hostile payload can seed, on the last screen before a signature.
- **The router allow-list holds one chain (Base 8453).** Ethereum mainnet was dropped
  because only 8453 is evidenced; the chain-1 address came from a docs page that 404'd.
- **Message signing rejects cleanly rather than offering an Approve button** it cannot
  honour. A real EIP-712 renderer is deferred.
- **#233's F4 and N4 are deferred by choice**, not forgotten — cross-chain is a product
  call, the cubit refactor is a refactor. Both have replies on their threads.

## Traps found this session

- **`gsd-tools query state.*` corrupts this repo's STATE.md** — resets `current_phase`,
  invents fields, and rewrites CRLF→LF (1436-line diff for a 12-line edit). Hand-edit the
  frontmatter instead. Same family as the known `phase.complete` bugs.
- **`squid.local.json` is not gitignored on develop.** The `*.local.json` rule exists only
  on `phase-26-swap-wiring` and arrives with #233. Until then, do not `git add -A` on a
  develop-based branch — the file holds the Squid integrator ID.
- `dart format .` over the whole tree is red and always has been (365 generated files under
  `squidrouter/` and `banxa/`). CI gates the scoped `dart format lib test`, which is clean.

## Owed

- **The phase 30 live walk.** A debug build on a real WalletConnect session: one ERC-20
  transfer and one Squid swap, both appearances. Nothing else confirms the relay path, a
  *current* Squid payload, or light-mode legibility on device.
- Six pre-existing decision-ID comments in `lib/reown/` files phase 30 did not touch —
  listed in the phase's `deferred-items.md`. They block that phase's own grep gate.
- A token send now shows **no** explorer link where it previously showed a wrong-chain one;
  `getExplorerUrl` is keyed on coin symbol, which is now correct rather than always "ETH".

## Next

Merge #233, retarget #234, confirm its CI. Phase 30 needs the device walk before #235
leaves draft. v2.0 has no phases left after that.
