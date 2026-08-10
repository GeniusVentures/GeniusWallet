# Continue here · paused 2026-07-30

**Branch:** `ui-redesign-port`. 59 commits this session, **nothing pushed, no PR open.**
626 commits ahead of `origin/develop`, 2 behind.

**Why this file and not `.continue-here.md`:** that slot holds Jakub's 2026-07-29 handoff from
`redesign/jakub-260728`. Overwriting it would destroy another session's record — the exact
one-slot-two-sessions collision AGENTS.md documents. Per AGENTS.md, each session writes its own
`HANDOFF-<topic>.md`. `.planning/HANDOFF.json` carries the machine-readable state and points here.

---

# BLOCKING CONSTRAINTS — read before anything else

Each was found through actual failure this session. **All three produce silently wrong results** —
nothing errors, nothing warns.

- [ ] **`flutter analyze | tail` hides the exit code.** A pipeline returns *tail's* status. An
      executor read a 1-exit as clean and reported a broken gate as "pre-existing".
      → `flutter analyze --no-pub >/dev/null 2>&1; echo $?`
- [ ] **`phase.complete` corrupts two things silently.** It ticks EVERY requirement ID mapped to the
      phase — including ones the phase's own verification argues must stay open (4 occurrences today:
      ORG-05 twice, then SCR-05 and GAP-05 together) — and it advances `current_phase` to the next
      NUMERIC phase even when that phase already closed.
      → After every `phase.complete`: `git diff .planning/REQUIREMENTS.md`, and check whether
      `current_phase` names a finished phase.
- [ ] **A plan's `files_modified` goes stale because work lands outside GSD.** Phase 21's 21-04
      planned to convert two files commit `9ff7c04` deleted a whole phase earlier.
      → Re-measure every target at execution time. Adapting in-flight is right when drift means
      "already done"; it is **wrong** when drift means "the files are gone" — that needs a re-plan.

## Critical Anti-Patterns

| Pattern | How it manifested | Severity | Prevention |
|---|---|---|---|
| Piped exit code | A failing analyzer read as clean | blocking | Redirect output, read `$?` |
| `phase.complete` blind tick | 4 requirement ticks had to be reverted | blocking | Diff REQUIREMENTS.md before committing |
| `phase.complete` numeric advance | STATE named a phase closed hours earlier | blocking | Compare against `init.progress` after closing |
| `state.validate` false green | Returns `valid: true, drift: {}` — checks schema, not truth | advisory | Not a correctness check |
| `state.update` misses frontmatter | Reports YAML fields "not found" while they sit two lines above | advisory | Edit frontmatter directly |
| Stale `files_modified` | 5 of 6 plans invalid before execution | blocking | Open every path first; re-plan if gone |
| Backgrounded test runs | Real Hive I/O in `testWidgets` hung the suite with ZERO output, killed three executors | advisory | Foreground + `timeout 900`; zero output = kill. Root cause fixed with hive_ce's in-memory backend (`Hive.openBox(name, bytes: Uint8List(0))`) — **not** `tester.runAsync`, which cannot drive frame scheduling |
| Root `pub get` ≠ sub-package | `packages/genius_api` left unresolved, analyzer exit 1 | advisory | `flutter pub get` INSIDE `packages/genius_api` |

---

## Where this stopped

**No active phase. 19 of 23 complete, 106/107 plans (99%).** Working tree clean.

Verified baseline at HEAD: `flutter analyze` **exit 0** both packages · `flutter test` **798/798** ·
brace 0 · raw-colour 0 · both security gates pass · format clean.
Every planning doc understates the count (512/682/693/707/722/732/758) — **use 798**.

### Closed this session

| Phase | Result |
|---|---|
| 23 | verification **passed** 5/5 (`2110316`) |
| 22 | closed; ORG-01 on developer judgement, CI gap left standing (`6bcc146`) |
| 09 | closed; Banxa walk, 2 of 7 human items closed (`f81e015`) |
| 20 | closed; Feedback frame walk closed the layout questions (`9345ed4`) |
| 21 | **re-planned mid-flight**, 6/6 executed, verification passed (`262a13d`) |
| 14 | closed **WITH GAPS** (`1e06904`) |
| 24 | **removed to backlog** (`2be45ce`) |

Out of phase: reown 1.4.0 (`3017f9f`) · WalletConnect pairing-URI logging removed, carries `symKey`
(`0bde805`) · reown money-math tests (`2a3e14a`) · CI Flutter pin (`c9831a0`) · STATE drift
(`0b4f90b`).

## Remaining work

- **14-08 — the highest-value single plan in the project.** The compute panel is built,
  height-measured, contrast-proven and **rendered nowhere**: `grep -rn "ComputePanel" lib/` returns
  only its own class declaration. One plan renders it, wires switch-wallet + retry, deletes three
  superseded widgets, adds the wiring test. Roughly 2,500 lines of built-and-tested code no user can
  see.
- **Phases 1, 10, 11** — original port track, never started, 0 plans each.
- **reown** — `handle_dapp_requests`'s dispatch and `reown_connect_button`'s pairing are untested.
  The dispatch is the gate every dApp request passes before any drawer is drawn.
- **GWAppBar / GWScreen sweep** — filed as todos; both need a functional test net first.
- **71 pending todos**; `discuss-phase` matches them automatically.

## Blockers

- **The CI `quality` job has never executed once.** `build.yml` triggers only on push/PR to
  `develop`/`main`. First signal arrives at the develop PR. **Do NOT `workflow_dispatch`** — that
  path deletes and recreates a GitHub release.
- **Compute panel invisible to users** (see 14-08 above).

## Human decisions pending

1. The two Banxa result drawers are re-skinned but have **no production caller** — only
   `dev_tools_bubble.dart`. Wire, keep dev-only, or remove?
2. Does `Reject`/`Deny` read as equally affirmative as `Approve`/`Allow` on the signing drawers?
   `drawers-final/README.md` flagged it open. The phase 21 walk reported no failure, which is **not**
   the same as answering it.
3. A PR into develop, to give the CI job its first run.

## Required reading (in order)

1. `.planning/phases/14-*/14-VERIFICATION.md` — why 14 closed with gaps, and what shipping costs
2. `.planning/phases/21-*/superseded-stale-file-inventory/README.md` — how plans rot when commits
   land outside GSD; the lesson generalises
3. `.planning/todos/pending/2026-07-30-*.md` — four filed today
4. `.planning/backlog/architecture-state-ownership-layering-routing-genius-api-split.md` — removed
   phase 24 and its four unsettled questions

## Infrastructure

- **Flutter SDK NOT on PATH:** `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"`
- Local Flutter **3.41.9** (detached checkout at that tag); CI now pins the same. **No pin file
  exists** — no fvm, no `.flutter-version`; `pubspec`'s `sdk: ^3.10.0` constrains Dart. The workflow
  was the only place a Flutter version was written down, which is how the two drifted.
- No app running. A live `genius_wallet.exe` locks the DLL and fails the next build.
- Worktrees auto-degrade to sequential (HEAD diverged from `origin/HEAD`). The repo **does** have git
  submodules — repo-root `banxa/`, `squidrouter/`, `tokeninfo/`. Those are what AGENTS.md fences;
  `lib/banxa/` is app code and editable.
- `lib/reown/` is **not** covered by `tool/check_raw_colors.sh` — 3 known offenders remain. A green
  gate does not mean that directory is clean.

## Context

The most valuable output here is probably not the five closed phases but the three tooling bugs
above. Everything else is recoverable from git; a falsely-ticked requirement is not, because the next
planner reads the checkbox before the prose beside it.

One theme recurred across 14, 21, 22 and 23: something claimed complete that was not. A panel built
and never rendered. Plans naming deleted files. A CI gate wired and never run. A requirement ticked by
a tool. Each was caught by measuring rather than reading — worth carrying forward.

Also worth carrying: I closed three loose items inline rather than through GSD. The commits are sound
but carry no plan, executor or verification record. `/gsd-quick` is the right tool for that shape of
work, and using it would have kept the record whole — which is the same failure mode as the stale
plans above, at smaller scale.

## Next action

`/gsd-progress`. If picking up code: **14-08**.
