---
name: open-pr
description: Use when opening a pull request on GeniusWallet — covers branching, commit shape, the verification that must pass first, and how the PR description should read.
---

# Opening a PR

## Branch

Branch off `develop`, never `main`. `main` is the release branch; `develop` is
where work integrates.

```
git checkout develop && git pull && git checkout -b <type>/<short-description>
```

Check `git config user.email` resolves to the account that owns the work.
GitHub attributes commits by email, not by name — an inherited identity
credits the wrong person, and a protected branch can make that unfixable.

## Before you open it

All of these, actually run, output quoted — not assumed:

```
dart format lib test
flutter analyze                               # exits non-zero on infos, by design
flutter test
bash tool/check_brace_style.sh
bash tool/check_raw_colors.sh
bash tool/check_onboarding_seed_safety.sh
bash tool/check_no_new_key_logging.sh --scan-tree
bash tool/check_agent_rules_sync.sh
```

The Flutter SDK is not on `PATH` by default in this repo's environment.

Never claim a baseline you did not run. If something fails, say so with the
output.

## Commits

One commit per concern, each standing on its own. The message says what
changed for a user and why, not which files moved — `git diff` already knows
the files.

No tool attribution: no `Co-Authored-By` trailers for AI assistants, no
"generated with" footers, no bot emoji. This applies to commit messages, PR
descriptions, PR comments and release notes.

## The description

Written for a reviewer deciding whether to trust the change, not for a machine
summarising it.

- **Lead with what a user hits.** "The order list could never show anyone
  their orders" beats "refactored OrdersCubit".
- **One short verification section.** Test count, analyzer state, gates.
- **A "deliberately not here" list.** What you found and chose not to fix, with
  the reason. This is what stops a reviewer hunting for something you already
  considered.
- No walls of implementation detail. If a decision needs three paragraphs, it
  belongs in a code comment or the commit message.

## Open it as a draft

```
gh pr create --draft --base develop --title "<title>" --body-file <file>
```

Draft by default. Mark it ready when CI is green and you have re-read the
diff yourself. Opening non-draft is the exception, not the norm.

Do not open a PR without the author's explicit go-ahead.
