#!/usr/bin/env bash
#
# tool/check_agent_rules_sync.sh
#
# WHAT THIS IS FOR
# ----------------
# The team drives this repo with four different AI coding agents, and they do
# not all read the same file:
#
#   Claude Code            CLAUDE.md, which is one line: `@AGENTS.md`
#   opencode               AGENTS.md natively (it prefers AGENTS.md over
#                          CLAUDE.md when both exist)
#   Copilot coding agent   AGENTS.md natively
#   Copilot in VS Code     .github/copilot-instructions.md
#   Copilot for Xcode      .github/copilot-instructions.md
#
# Three of those read AGENTS.md already. Only Copilot's editor integrations do
# not: AGENTS.md support in VS Code is experimental and off by default, while
# .github/copilot-instructions.md is picked up automatically. So exactly ONE
# file has to be kept in step with AGENTS.md, and this script is what keeps it
# honest.
#
# WHY A SCRIPT AND NOT A PACKAGE
# ------------------------------
# Ruler, rulesync, AgentSync and friends all solve this, and all of them are
# the wrong size for it here: they add a Node dependency and a generate step to
# produce ONE derived file. This repo already has five shell gates in tool/ and
# no JS toolchain. If the team later adds Cursor, Cline or Gemini -- each with
# its own directory format -- revisit that decision; two or three targets is
# where a package starts paying for itself.
#
# WHY NOT A SYMLINK
# -----------------
# A symlink would need no script at all, but it needs core.symlinks and, on
# Windows, Developer Mode. A checkout without those turns the link into a text
# file containing a path, which Copilot would read as the literal string
# "../AGENTS.md" and silently apply no rules at all. A copy plus a check fails
# loudly instead.
#
# USAGE
# -----
#   bash tool/check_agent_rules_sync.sh          # verify; exit 1 on drift
#   bash tool/check_agent_rules_sync.sh --fix    # regenerate, then verify
#
# Run --fix after editing AGENTS.md. AGENTS.md is the ONLY file anyone edits by
# hand; .github/copilot-instructions.md is generated and carries a header
# saying so.

set -uo pipefail
cd "$(git rev-parse --show-toplevel)" || exit 1

SOURCE="AGENTS.md"
GENERATED=".github/copilot-instructions.md"

if [ ! -f "$SOURCE" ]; then
  echo "FAIL: $SOURCE is missing -- it is the single source of truth for every agent."
  exit 1
fi

# The generated file is the header plus AGENTS.md verbatim. Verbatim matters:
# a transform (section filtering, reformatting) would mean the rules an agent
# reads are not the rules a human reviewed.
render() {
  cat <<'HEADER'
<!--
  GENERATED FILE - DO NOT EDIT.

  Source: AGENTS.md at the repo root. Edit that, then run:
      bash tool/check_agent_rules_sync.sh --fix

  This copy exists because GitHub Copilot's editor integrations (VS Code and
  Copilot for Xcode) read .github/copilot-instructions.md automatically, while
  their AGENTS.md support is experimental and off by default. Claude Code and
  opencode read AGENTS.md directly and need no copy.

  See docs/ai-agents.md for the full picture.
-->

HEADER
  cat "$SOURCE"
}

if [ "${1:-}" = "--fix" ]; then
  mkdir -p "$(dirname "$GENERATED")"
  render > "$GENERATED"
  echo "Regenerated $GENERATED from $SOURCE."
fi

if [ ! -f "$GENERATED" ]; then
  echo "FAIL: $GENERATED is missing. Run: bash tool/check_agent_rules_sync.sh --fix"
  exit 1
fi

if ! diff -q <(render) "$GENERATED" >/dev/null 2>&1; then
  echo "FAIL: $GENERATED has drifted from $SOURCE."
  echo ""
  echo "  Copilot users (VS Code, Xcode) are reading different rules from"
  echo "  everyone else. Fix with:"
  echo ""
  echo "      bash tool/check_agent_rules_sync.sh --fix"
  echo ""
  echo "Difference (expected vs actual):"
  diff <(render) "$GENERATED" | head -40 | sed 's/^/    /'
  exit 1
fi

echo "PASS: $GENERATED is in step with $SOURCE."
exit 0
