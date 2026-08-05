# AI coding agents in this repo

The team uses four different agents. This page says which file yours reads and
where to put a new rule.

## One source of truth

**`AGENTS.md` at the repo root.** It is the only rules file anyone edits by
hand.

| Agent | Who | Reads |
|---|---|---|
| Claude Code | Braian | `CLAUDE.md`, which is one line: `@AGENTS.md` |
| opencode | Eduardo, Henrique | `AGENTS.md` directly (it prefers `AGENTS.md` over `CLAUDE.md`) |
| Copilot coding agent / code review | — | `AGENTS.md` directly |
| Copilot in VS Code | Justin | `.github/copilot-instructions.md` |
| Copilot for Xcode | Ken | `.github/copilot-instructions.md` |

Three of those read `AGENTS.md` already. Only Copilot's **editor**
integrations do not — `AGENTS.md` support in VS Code is experimental and off
by default, while `.github/copilot-instructions.md` is picked up
automatically.

So `.github/copilot-instructions.md` is a **generated copy** of `AGENTS.md`.
It carries a do-not-edit header.

### Adding or changing a rule

```
# 1. edit AGENTS.md
# 2. regenerate the Copilot copy
bash tool/check_agent_rules_sync.sh --fix
# 3. commit both
```

`tool/check_agent_rules_sync.sh` (no argument) fails if the two have drifted.
Run it with the other gates before opening a PR.

## Skills

`.claude/skills/<name>/SKILL.md`. **Claude Code and opencode both read that
path natively** — opencode loads `.claude/skills/*/SKILL.md` alongside its own
`.opencode/skills/`. Copilot's agent mode reads `SKILL.md` too. One directory,
no sync.

Currently:

| Skill | For |
|---|---|
| `open-pr` | Branching, commit shape, the checks that must pass, how the description should read, opening as a draft |
| `merge-pr` | Rebase-first merging and the cases where it is the wrong tool |
| `review-pr` | What a reviewer checks, hardest consequence first |

A skill here must be **self-contained** — no references to files outside the
repo. A skill that reads `$HOME/...` works on one machine and silently does
nothing on everyone else's.

## What is deliberately not here

- **No rules-sync package.** Ruler, rulesync and AgentSync all solve this, and
  all are the wrong size for one generated file in a repo with no JS
  toolchain. Revisit if the team adds Cursor, Cline or Gemini, each of which
  brings its own directory format.
- **No vendored GSD skills.** 59 of the 69 load workflows from
  `$HOME/.claude/gsd-core/`, so copying them here produces skills that break
  on every machine but the one they came from. Anyone who wants that workflow
  installs GSD themselves.
- **Nothing for Xcode's built-in Coding Intelligence.** It has no repo-level
  rules convention. Ken is covered because Copilot for Xcode reads the file
  above.

## Models

The models in use — DeepSeek, GLM, Xiaomi MiMo, Claude — do not affect any of
this. Rules files are read by the **harness**, not the model. Pointing
opencode at a different provider changes nothing here.
