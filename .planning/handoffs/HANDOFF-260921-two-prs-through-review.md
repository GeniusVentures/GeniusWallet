# Handoff — 2026-09-21 — #234 merged, #235 merge-ready, v2.0 has no PRs left

Executor session. Branch ended on `phase-30-calldata-decoding`, tree clean apart from
the pre-existing untracked `squid.local.json`.

## What happened

- **#233 (phase 26) merged into develop** at 13:08Z by henriqueaklein.
- **#234 (phase 29)** rebased onto that develop (clean), retargeted, CI'd for the first
  time, taken through two Codex rounds (6 threads, all fixed and resolved), and
  **merged by Braian at 17:07Z**.
- **#235 (phase 30)** rebased twice (after #233, then after #234), taken through three
  Codex rounds (12 threads: 11 fixed and resolved, one deferred by decision), CI green
  8/8 on `cc6c83c5`, out of draft, mergeable. **The live walk is done** — Braian ran
  both flows in both appearances on 2026-09-21. Verification addendum in
  `30-VERIFICATION.md`. Nothing blocks the merge.

## The one open thread on #235, and why

Codex P1 "build token receipts from the decoded transfer": `Transaction.coinSymbol` is
the model's only unit, and history renders the amount, the Network Fee *and* the
Network row from it. A token transfer is mislabelled whichever coin it is filed under.
Braian chose to leave it as is; it is recorded in the phase's `deferred-items.md` next
to the explorer-link item, which needs the same asset-vs-chain split. That is a Hive
schema change across every transaction display — a phase, not a review fix.

## Traps found this session

- **A CRLF Dart file passes `tool/check_brace_style.sh` locally and fails it on CI.**
  Ubuntu's mawk sees `) {\r` and prints every correctly-braced `if` in the file as a
  violation, so the log lists good code. Both PRs hit it (`handle_dapp_requests.dart`,
  `route_details_card_test.dart`). Check `git ls-files --eol lib test | grep i/crlf`
  before pushing; only two pre-existing test files are CRLF on develop.
- **The same flip on `.planning/STATE.md` makes a 9-line change a whole-file rebase
  conflict.** Rebuild from develop's LF copy and re-apply the branch's own edits as a
  patch (`git diff <old-base> <old-tip> -- file | git apply -3`) — taking `--theirs`
  wholesale drops the sibling phase's close-out.
- **`build.yml` fires `pull_request` only on `develop`/`main`**, so a stacked PR gets no
  CI and a base retarget alone does not trigger one; close/reopen does.
- **Dependency downloads flake.** `Failed to download SuperGenius/GeniusSDK: "HTTP
  response code said error"` and a corrupt Android SDK zip took out different platforms
  on consecutive attempts; every job passed on `gh run rerun --failed` with no code
  change. Check the control case (develop's own run) before reading it as code.
- In this Git Bash, `git show rev:path` needs `MSYS_NO_PATHCONV=1`, and Python does not
  see MSYS `/tmp` — use the scratchpad path.

## Numbers — do not read these against each other

- develop after #234: the phase-30 branch's suite on top of it is **1539 / 5 skip / 0**.
- Codex's three rounds on #235 added 26 tests; the two on #234 added 9.

## Next

Merge #235 (`gh pr merge 235 --rebase --delete-branch` per the merge-pr skill; #233 and
#234 landed as merge commits, so either is defensible). After that v2.0 has no open
phases and no open PRs; the deferred items are the asset-unit model change and the
explorer-by-chainId fix, both in phase 30's `deferred-items.md`.
