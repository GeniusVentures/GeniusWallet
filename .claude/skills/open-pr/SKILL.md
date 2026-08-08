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

A reviewer skims this on a phone before deciding whether the diff is worth
opening. Write for that person, not for a machine summarising the change.

**Shape — roughly this, roughly this long:**

```
One sentence: what someone can now do, or what stopped being broken.

## What changed
Three to six bullets. Each one names a behaviour, not a mechanism.

## Verification
One line: tests, analyzer, gates.

## Deliberately not here
What you chose not to fix, and why. Drop the heading if there's nothing.
```

**A screenful is the budget.** Past ~30 lines you have started explaining the
implementation. Cut until every bullet is something a person could notice while
using the app.

**Behaviour, not mechanism.** The diff already says how. Compare a real one:

> Hero price was a hardcoded `fontSize: 48` — ran the full card width on a
> phone. Its box was 180px and `chartUsesFrame()` needs 220, so it silently
> used the axis-free variant.

against what the reviewer needed:

> On a phone the Markets price was so large it ran the whole width of the card,
> and the chart under it showed no prices and no dates. Both fixed. Desktop is
> untouched.

Same change. Only the second tells anyone what to go and look at.

**Keep out of the summary:** pixel values, function and class names, file paths,
cache keys, widget internals. A number earns its place only when someone will
argue about it — a breakpoint, a threshold. Everything else belongs in the commit
message, where the person who wants that detail is already reading.

**"Deliberately not here" is product writing too.** *"Cards stop at 2 columns;
below 287px the name collapses because the price column is fixed at 142.5px"* is
a note to yourself. *"Cards don't go 3 across — that needs a card redesign, not a
number change"* is a note to your reviewer. Write the second.

**Say what is unverified.** Light mode unchecked, real hardware unwalked, one
platform only — a reviewer can accept a gap they can see, and cannot forgive one
they find themselves.

## Open it as a draft

```
/gsd-ship --draft
```

It pushes the branch and opens the PR against the base it resolves from
`.planning/config.json` (`git.base_branch`, pinned to `develop` — this repo's
GitHub default is `main`, so without that pin ship targets the release branch).
A PR opened against `main` means that key went missing.

**Rewrite the body it generates.** `gsd-ship` assembles it from PLAN.md and
SUMMARY.md, so it arrives as a machine summary of the planning docs — phase
numbers, requirement IDs, task counts. That is the opposite of the section above.
Treat it as raw material: keep the verification numbers, throw away the rest, and
write the description as if no plan existed.

Draft by default. Mark it ready when CI is green and you have re-read the
diff yourself. Opening non-draft is the exception, not the norm.

Do not open a PR without the author's explicit go-ahead.
