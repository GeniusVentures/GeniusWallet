---
name: merge-pr
description: Use when merging or updating a pull request on GeniusWallet — rebase is the default strategy, with the cases where it is not.
---

# Merging

## Rebase first

Rebase is this project's default merge strategy. Keep history linear: a
branch that is behind `develop` gets rebased onto it, not merged from it.

```
git fetch origin
git rebase origin/develop
git push --force-with-lease        # never --force
```

`--force-with-lease` refuses to overwrite work that arrived after your last
fetch. Plain `--force` does not, which is how a teammate's commit disappears.

Merging a PR:

```
gh pr merge <n> --rebase --delete-branch
```

**This is a change from what the history shows.** PRs #217 through #221 all
landed as merge commits (`Merge pull request #NNN from ...`). All three merge
methods are still enabled on the repo, so the setting will not stop anyone —
the convention is what does.

## When rebase is the wrong tool

- **A shared branch.** If anyone else has the branch checked out, rebasing
  rewrites commits under them. Coordinate, or merge instead.
- **A long branch with conflicts in most commits.** Replaying forty commits
  through the same conflict is worse than resolving it once. Merge, and say
  why in the PR.
- **Branches with no shared history.** Rebase cannot help. Cherry-pick onto a
  fresh branch off the target.

State which one applies rather than switching silently.

## Never

- Force-push a branch you do not own without asking its owner.
- Rebase or push anything on `main` or `develop` directly. They take merges
  from PRs only.
- Skip hooks (`--no-verify`) or bypass signing. If a hook fails, fix the cause.
- Merge with a red CI or a failing gate, however unrelated it looks. An
  unrelated failure is still a failure somebody has to explain later.

## Before merging

Re-run the checks on the rebased tip, not on the pre-rebase commits — a clean
rebase can still produce a broken tree when two branches touched the same
behaviour. The list is in the `open-pr` skill.
