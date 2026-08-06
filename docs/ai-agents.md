# AI coding agents in this repo

Different people here drive this repo with different agents, and they do not
all read the same file. This page says what your agent needs in order to pick
up the project rules, and where to put a new rule.

## One source of truth

**`AGENTS.md` at the repo root.** It is the only rules file anyone edits by
hand.

| Agent | What it reads | What you have to do |
|---|---|---|
| Claude Code | `CLAUDE.md`, one line: `@AGENTS.md` | Nothing. Works on clone. |
| opencode | `AGENTS.md` directly, in preference to `CLAUDE.md` | Nothing. Works on clone. |
| Codex | `AGENTS.md` directly | Nothing. Works on clone. |
| Copilot coding agent, Copilot code review | `AGENTS.md` directly | Nothing. Works on clone. |
| Copilot in VS Code | `.github/copilot-instructions.md`, auto-detected | Nothing. Optionally enable the experimental `AGENTS.md` setting to read the source instead. |
| Copilot for Xcode | `.github/copilot-instructions.md` | Nothing. Same generated file. |
| Cursor, Cline, Gemini CLI, Continue, others | Their own directory formats | Not generated today — see "Adding an agent" below. |

Most agents read `AGENTS.md` already. Copilot's **editor** integrations are the
exception: `AGENTS.md` support in VS Code is experimental and off by default,
while `.github/copilot-instructions.md` is picked up automatically.

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

## Adding an agent

If you start using a tool that reads neither `AGENTS.md` nor
`.github/copilot-instructions.md`:

1. Find the file or directory it expects (e.g. `.cursor/rules/`,
   `.clinerules/`, `.github/instructions/*.instructions.md`).
2. Add it as a second target in `tool/check_agent_rules_sync.sh` — the render
   function emits a header plus `AGENTS.md` verbatim, so a new target is a
   path and a header, not new logic.
3. Run `--fix`, commit the generated file, and note it in the table above.

If the count of generated targets gets past two or three, stop and reach for a
purpose-built tool instead (Ruler, rulesync, AgentSync). One file does not
justify a dependency; four might.

## Skills

`.claude/skills/<name>/SKILL.md`. **Claude Code and opencode both read that
path natively** — opencode loads `.claude/skills/*/SKILL.md` alongside its own
`.opencode/skills/` and `.agents/skills/`. Copilot's agent mode reads
`SKILL.md` too. One directory, no sync, nothing to configure.

If your agent supports skills but looks somewhere else, point it at
`.claude/skills/` rather than copying the files — a second copy is a second
thing to keep in step.

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
  rules convention, so there is no file to generate for it. Copilot for Xcode
  reads the generated file and is covered.

## Models

The models in use — DeepSeek, GLM, Xiaomi MiMo, Claude — do not affect any of
this. Rules files are read by the **harness**, not the model. Pointing
opencode at a different provider changes nothing here.
