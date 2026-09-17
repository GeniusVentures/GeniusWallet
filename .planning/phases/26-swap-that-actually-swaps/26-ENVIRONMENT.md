# Phase 26 — execution environment

Shared by every plan in this phase. Referenced from each `<context>` block.

- **Flutter is NOT on PATH.** Prefix every session:
  `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"`.
  Omitting it yields "command not found", which has previously been misread as a compile failure.
- **`flutter analyze` exits non-zero on infos.** Intentional (`fatal-infos`). Check `$?`, not the
  tail — it can exit 1 while the output looks clean.
- **Run analyze in both trees**: the repo root AND `packages/genius_api`. The nearest
  `analysis_options.yaml` wins, and the root's excludes do not cover `packages/`.
- **Never edit anything under `squidrouter/`** — generated submodule, per AGENTS.md. Root
  `analysis_options.yaml` already excludes it.
- **A running `genius_wallet.exe` locks the DLL** and fails the next Windows build. Kill it first;
  this is an infrastructure error that reads like a code error.
- **Measure the entering baseline yourself and quote real output.** Last recorded 2026-08-08:
  788 pass / 0 fail, analyzer 0 in both packages. Plans rot — re-measure, never assert.
- **Do not create git commits** unless the executing workflow is the one making them (AGENTS.md).

## Money

Plans 01–05 need no funds. Plan 06 spends real funds; plan 07 needs dust. Use **Base mainnet, chainId 8453** and a throwaway wallet holding a few dollars — Squid is mainnet-only and never had a
testnet. Never a wallet that holds anything.

## Credential

`--dart-define=GW_SQUID_INTEGRATOR_ID=<id>`. Plans 01, 02 and 05 do not need it. Plans 03, 04, 06 and 07 need it for
their live half only; their automated tests run without it.
