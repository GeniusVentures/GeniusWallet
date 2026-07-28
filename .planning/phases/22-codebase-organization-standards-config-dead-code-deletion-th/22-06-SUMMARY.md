---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 06
subsystem: infra
tags: [flutter-analyze, dart-lints, unawaited-futures, avoid-dynamic-calls, ffi, genius-api, wallet-connect]

requires:
  - phase: 22-05
    provides: "101-issue non-automatable analyzer tail, grouped by rule with per-file counts (22-05-RESIDUE.md)"
provides:
  - "flutter analyze --no-pub reports 0 issues and exits 0 -- first time in project history"
  - "packages/genius_api's own flutter analyze --no-pub also 0 issues"
  - "22-06-SEMANTIC-DELTAS.md: every non-identity change (5 mounted guards, 20 dynamic-call retypes, 17 unawaited() wraps) recorded with reasoning"
  - "precondition satisfied for 22-08 to turn the CI analyze gate on"
affects: [22-07, 22-08]

tech-stack:
  added: []
  patterns:
    - "unawaited() from dart:async for genuine fire-and-forget Futures, never await -- documented per-site in 22-06-SEMANTIC-DELTAS.md"
    - "cast JSON/FFI-bridge boundaries to concrete List<dynamic>/Map<String,dynamic> instead of leaving dynamic method/index calls"
    - "context.mounted vs bare mounted: match the guard to whichever context binding is actually used at the site (local/parameter -> context.mounted; State's own getter -> bare mounted)"

key-files:
  created:
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-06-SEMANTIC-DELTAS.md
  modified:
    - analysis_options.yaml
    - packages/genius_api/pubspec.yaml
    - packages/genius_api/lib/tw/stored_key_wallet.dart
    - packages/genius_api/lib/src/genius_api.dart
    - lib/reown/reown_connect_button.dart
    - lib/reown/handle_dapp_requests.dart
    - lib/services/coin_gecko/coin_gecko_api.dart
    - lib/banxa/banxa_api_services.dart
    - lib/web/web_view_mobile.dart
    - tool/check_onboarding_seed_safety.sh

key-decisions:
  - "context.mounted does not satisfy use_build_context_synchronously when context is a State's own getter (re-evaluated per access) -- bare `mounted` does; the reverse holds when context is a local parameter/closure argument. Documented as a reusable rule, not solved ad hoc per site."
  - "banxa_api_services.dart's pollOrderStatus: confirmed by tracing (not just asserted) that awaiting checkStatus() would arm a live Timer.periodic against an already-resolved Completer, throwing 'Bad state: Future already completed' on the next tick -- unawaited() is load-bearing there, not a style choice."
  - "reown_connect_button.dart's rejection-toast guard is narrowly scoped to the UI statement only; walletKit.rejectSession() stays unconditional so a disposed widget never leaves a dApp's connection request unanswered."
  - "lib/*.g.dart added alongside lib/**/*.g.dart in the exclude glob -- ** does not match a *.g.dart file with zero intervening directories, which is why hive_registrar.g.dart kept reporting directives_ordering despite 'matching' the exclude in intent."
  - "check_onboarding_seed_safety.sh CHECK 4's regex widened to accept an optional <identifier>. prefix before mounted, so context.mounted (required by the analyzer fix in recovery_phrase_screen.dart) satisfies the same lifecycle-guard security intent as the original bare-mounted pattern."
  - "genius_api's four undeclared transitive imports (convert, ffi, path_provider, rxdart) pinned to exact versions already resolved in pubspec.lock, not caret ranges -- a supply-chain-safety choice, confirmed via unchanged pubspec.lock hash after flutter pub get."

patterns-established:
  - "Fire-and-forget Future audit table: for any unawaited_futures fix, name the Future, state why it's detached, and confirm nothing downstream depends on its completion order -- codified per-site in 22-06-SEMANTIC-DELTAS.md."

requirements-completed: [ORG-03]

coverage: []

duration: 3h10m
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 06: Hand-Fix the Non-Automatable Analyzer Tail Summary

**Drove `flutter analyze --no-pub` from 101 issues to "No issues found!" (exit 0) across 13 commits, by hand-typing 20 dynamic-call JSON/FFI boundaries, wrapping 17 genuinely-detached Futures in `unawaited()` with zero new `await`, adding 5 recorded `mounted` guards, and fixing a `**`-glob exclude gap that was hiding a generated file's false-positive lint.**

## Performance

- **Duration:** ~3h 10m
- **Started:** 2026-07-28T13:28:00Z (approx, from baseline read)
- **Completed:** 2026-07-28T16:38:22Z
- **Tasks:** 3 (per plan) executed as 13 atomic commits, one per rule family
- **Files modified:** 51 (49 source/test/tool files + 2 new/updated planning docs)

## Accomplishments

- `flutter analyze --no-pub` (repo root): **101 issues → 0 issues, "No issues found!", exit 0** -- confirmed with a bare `echo $?` after the command, not just eyeballing the tail of the output.
- `cd packages/genius_api && flutter analyze --no-pub`: **0 issues** (this package's own analyzer run, separate from the root).
- `flutter test --no-pub`: **512 passing / 0 failing**, re-verified after every rule-family commit, not only at the end.
- `dart format --output=none --set-exit-if-changed lib test`: exit 0.
- `bash tool/check_brace_style.sh --count`: 0.
- `flutter build windows --debug`: succeeds (`Built build\windows\x64\runner\Debug\genius_wallet.exe`) -- a real compile of every touched file, including the FFI field renames and the `packages/genius_api` type annotations.
- `git diff --unified=0 -- lib/ | grep '^\+' | grep -iE '\bawait\b'` returns nothing: zero new `await` keywords introduced anywhere in `lib/` across the whole plan.
- Rule families closed, by count: `avoid_dynamic_calls` 20, `unawaited_futures` 17, `strict_top_level_inference` 10, `depend_on_referenced_packages` 10, `deprecated_member_use` 6, `use_build_context_synchronously` 5, `library_private_types_in_public_api` 10, `avoid_print` 11, `unused_local_variable` 2, `unused_field` 2, `unused_element` 1, `unintended_html_in_doc_comment` 3, `non_constant_identifier_names` 2, `constant_identifier_names` 1, `directives_ordering` 1 = **101 total, all closed**.

## Task Commits

Each rule family was committed atomically, in dependency order (mechanical/low-risk first, behaviour-adjacent last):

1. `5627643` - refactor: delete `unused_local_variable` in two tests
2. `c3eec8c` - refactor: delete dead symbols (`unused_field`, `unused_element`), fix doc comments, naming lints
3. `0ef89a9` - refactor: widen `createState()` return types off private State names (`library_private_types_in_public_api`, 10 files)
4. `13297c2` - style: `dart format` fix for two of the createState() signature edits
5. `5a4df44` - refactor: `avoid_print` → `debugPrint` across 3 files (11 sites), each reviewed for key/seed content first
6. `587755d` - fix: `depend_on_referenced_packages` -- declare `genius_api`'s 4 transitive imports, version-pinned
7. `3eee750` - refactor: `strict_top_level_inference` -- annotate `genius_api` types (2 files, 10 sites)
8. `5213a2e` - refactor: `deprecated_member_use` -- migrate 6 sites to documented replacements
9. `cc011af` - fix: `use_build_context_synchronously` -- 5 `mounted` guards added, every one recorded in `22-06-SEMANTIC-DELTAS.md`
10. `e351100` - fix: `avoid_dynamic_calls` -- type 20 JSON/FFI-bridge boundary sites across 7 files
11. `3e56ca9` - fix: `unawaited_futures` -- wrap 17 fire-and-forget sites, confirmed zero new `await`
12. `c5c0e30` - fix: analyzer reaches 0 -- fix the `lib/*.g.dart` exclude-glob gap
13. `ff8bbea` - fix: widen `check_onboarding_seed_safety.sh` CHECK 4 for `context.mounted`

**Plan metadata:** (this commit, docs: complete 22-06)

## Files Created/Modified

- `.planning/phases/22-.../22-06-SEMANTIC-DELTAS.md` - every `mounted` guard, every dynamic-call retype's failure-behaviour reasoning, and the full `unawaited_futures` site table with why each is genuinely detached
- `analysis_options.yaml` - added `lib/*.g.dart` alongside `lib/**/*.g.dart` (glob zero-nesting gap)
- `packages/genius_api/pubspec.yaml` - 4 new direct dependencies (`convert`, `ffi`, `path_provider`, `rxdart`), each pinned to the exact version already resolved in `pubspec.lock`
- `packages/genius_api/lib/tw/stored_key_wallet.dart`, `packages/genius_api/lib/src/genius_api.dart` - explicit type annotations (`strict_top_level_inference`)
- `packages/genius_api/lib/ffi_bridge_prebuilt.dart` + 9 `packages/genius_api/lib/tw/*.dart` files - `tw_lib`/`sgns_lib` → `twLib`/`sgnsLib` rename, every call site
- `lib/reown/reown_connect_button.dart`, `lib/reown/handle_dapp_requests.dart` - `mounted` guards and `unawaited()` wraps around dApp-approval UI feedback, with `walletKit` protocol calls kept unconditional
- `lib/services/coin_gecko/coin_gecko_api.dart`, `lib/banxa/banxa_model.dart`, `lib/assets/read_asset.dart`, `lib/providers/network_tokens_provider.dart`, `lib/hive/models/coin_gecko_market_data.dart` - typed JSON-decode boundaries
- `lib/web/web_view_mobile.dart`, `lib/web/web_view_windows.dart`, `lib/web/web_utils.dart` - `print` → `debugPrint`, `unawaited()` on WebView navigation futures
- `lib/banxa/banxa_api_services.dart` - `unawaited(checkStatus())`, confirmed necessary by tracing (see Decisions)
- `tool/check_onboarding_seed_safety.sh` - CHECK 4 regex widened for `context.mounted`
- 10 `lib/components/**` files - `createState()` return-type widening
- `test/theme/nav_chip_style_test.dart`, `test/token_info_loader_test.dart`, `test/banxa/checkout_options_sheet_test.dart`, `test/boot_sequence_test.dart`, `test/components/global_swap_fab_host_test.dart` - dead-local deletion, dynamic-call typing, `unawaited()` on test-only fire-and-forget router pushes

## Decisions Made

- **`context.mounted` vs bare `mounted` is context-binding-dependent, not a style preference.** The `use_build_context_synchronously` analyzer lint requires the guard to reference the *exact same* `context` binding used at the later site: `context.mounted` when `context` is a local parameter or closure argument (e.g. `BlocBuilder`'s `builder: (context, state) => ...`), bare `mounted` when `context` is a `State`'s own getter (re-evaluated per access, e.g. an instance method). Using the wrong form produces "guarded by an unrelated 'mounted' check" even when both expressions read the identical `context` object at runtime. Documented as a reusable rule in `22-06-SEMANTIC-DELTAS.md` rather than solved ad hoc per site.
- **`banxa_api_services.dart`'s `unawaited(checkStatus())` is load-bearing, confirmed by tracing.** Awaiting it would suspend `pollOrderStatus` before `timer = Timer.periodic(...)` is assigned; if the first check already resolved a terminal status, the periodic timer would still get armed unconditionally, and its next tick would call `completer.complete()` a second time on an already-completed `Completer`, throwing uncaught inside the timer callback. This is exactly the class of regression the plan's "never blanket-await" rule exists to prevent -- verified by tracing the control flow, not just following the instruction.
- **`reown_connect_button.dart`'s two `mounted`/`context.mounted` guards are scoped narrowly to UI-only statements.** `walletKit.rejectSession(...)` and `_didManualPair = true` run unconditionally regardless of mount state; only the rejection toast and the dialog-pop navigation are skipped if the widget was disposed. A disposed widget must never leave a dApp's session-approval protocol response unsent.
- **`lib/*.g.dart` added to the exclude glob alongside the existing `lib/**/*.g.dart`.** `**` does not match a `*.g.dart` file sitting directly in `lib/` with zero intervening directories -- a known glob quirk that left `hive_registrar.g.dart` (build_runner-generated, "Do not modify") reporting `directives_ordering` despite matching the exclude in intent, exactly as `22-05-RESIDUE.md` flagged. Fixed the exclude glob, not the generated output.
- **`check_onboarding_seed_safety.sh` CHECK 4's regex widened, not weakened.** The check's security intent (a lifecycle guard within 2 lines of the awaited clipboard copy in the recovery-phrase screen) is unchanged; only the accepted spelling widened to also match `context.mounted`, since that form was now required by the analyzer fix in the same file. Re-ran: all six Section 3 checks pass.
- **`genius_api`'s 4 new direct dependencies are version-pinned exactly, not caret ranges.** `convert: 3.1.2`, `ffi: 2.2.0`, `path_provider: 2.1.6`, `rxdart: 0.27.7` -- each read directly off the already-resolved `pubspec.lock`, then confirmed the lock file's hash was unchanged after `flutter pub get` (no existing package moved version).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] `check_onboarding_seed_safety.sh` CHECK 4 regex broke after the analyzer-mandated `context.mounted` change**
- **Found during:** Task 3 (`use_build_context_synchronously` fix in `recovery_phrase_screen.dart`)
- **Issue:** Fixing the analyzer's `use_build_context_synchronously` warning required changing the copy handler's guard from `if (!mounted)` to `if (!context.mounted)` (see Decisions above for why). This broke `check_onboarding_seed_safety.sh` CHECK 4, a Phase-6-era security gate whose regex only recognized the literal bare-`mounted` spelling.
- **Fix:** Widened the regex to accept an optional `<identifier>.` prefix before `mounted`, so both `mounted` and `context.mounted` satisfy the check. The check's actual security property (a lifecycle guard within 2 lines of the awaited copy, before the context reaches `ScaffoldMessenger`) is unchanged.
- **Files modified:** `tool/check_onboarding_seed_safety.sh`
- **Verification:** `bash tool/check_onboarding_seed_safety.sh` → all six Section 3 checks PASS (previously CHECK 4 failed after the analyzer fix, before this widening).
- **Committed in:** `ff8bbea`

**2. [Rule 3 - Blocking] `hive_registrar.g.dart`'s `directives_ordering` false positive from a glob-matching gap**
- **Found during:** Task 3, final analyzer sweep (this was the last of the 101 issues)
- **Issue:** `lib/hive_registrar.g.dart` is `build_runner`-generated and matches `analysis_options.yaml`'s `lib/**/*.g.dart` exclude in intent, but the live analyzer run kept reporting one `directives_ordering` diagnostic against it -- `**` does not match a file with zero intervening path segments.
- **Fix:** Added `lib/*.g.dart` as an additional exclude entry alongside the existing `lib/**/*.g.dart`, per `22-05-RESIDUE.md`'s explicit guidance not to hand-edit generated output.
- **Files modified:** `analysis_options.yaml`
- **Verification:** `flutter analyze --no-pub` → "No issues found!", exit 0.
- **Committed in:** `c5c0e30`

---

**Total deviations:** 2 auto-fixed (both Rule 3 - blocking issues discovered while closing out the plan's own acceptance criteria)
**Impact on plan:** Both were necessary to reach the plan's literal "0 issues, exit 0" target and to keep every existing security gate green; no scope creep beyond the plan's own stated deliverable.

## Security Findings

**None.** Every `print` statement reviewed before conversion to `debugPrint` (per Task 1's wallet-safety directive) carried only non-sensitive data: a caught Banxa order-creation exception, public GitHub token-list fetch errors, and `[DEBUG]`-prefixed WebView navigation-delegate diagnostics (page URLs already surfaced in the omnibox UI, plus static control-flow strings). Nothing derived from a seed phrase, mnemonic, or private key was found in any log statement touched by this plan. `bash tool/check_no_new_key_logging.sh` was run against every key-material-adjacent file this plan touched (`sdk_account_manager.dart`, all of `packages/genius_api/lib/tw/*.dart`, `genius_api.dart`, `ffi_bridge_prebuilt.dart`, `reown/handle_dapp_requests.dart`, `reown/reown_connect_button.dart`) -- clean on every one.

## Semantic Deltas (full accounting)

Every change that is not strictly behaviour-identical is recorded in
[22-06-SEMANTIC-DELTAS.md](./22-06-SEMANTIC-DELTAS.md):

- **5 `mounted`/`context.mounted` guards added** (`use_build_context_synchronously`) -- each guard's only effect is on the disposed-mid-await path (previously a throw, now a silent skip of the guarded UI statement); no guard skips a wallet-affecting network/protocol call.
- **20 `avoid_dynamic_calls` retypes** -- failure behaviour preserved exactly in every case; the only change in kind is `NoSuchMethodError` (implicit dynamic dispatch) becoming `TypeError`/`CastError` (explicit `as` cast) on malformed data, never a silent-vs-throwing behaviour flip.
- **17 `unawaited_futures` wraps, zero new `await`** -- confirmed via `git diff` grep; one site (`banxa_api_services.dart`) is not just a style choice, traced to be load-bearing for correct `Timer`/`Completer` sequencing.

No Phase 23 candidates surfaced from the `unawaited_futures` work -- every discarded Future was judged genuinely fire-and-forget on inspection, none needed sequencing.

## Issues Encountered

- **`context.mounted` did not satisfy the analyzer for `State`-getter contexts.** Initially assumed `context.mounted` was always the "more correct" form per Flutter's own docs, but the analyzer flagged it as "guarded by an unrelated 'mounted' check" specifically when `context` was a `State`'s own re-evaluated getter (not a local variable/parameter). Root-caused by comparing a working site (`banxa_orders_history.dart`, `context` as a method parameter) against a failing one (`network_dropdown_selector.dart`, `context` as `State.context`) and confirming bare `mounted` resolved the latter. Documented as a general rule rather than a one-off fix.
- **The `check_onboarding_seed_safety.sh` regression was caught immediately** by running all `tool/*.sh` gates as part of the plan's own verification contract, not deferred to a later plan -- exactly the kind of drift the plan's "run all three security gates and report their real status" instruction exists to catch.

## Next Phase Readiness

- **22-07 and 22-08 are unblocked.** The analyzer is provably clean (`flutter analyze --no-pub` exits 0, verified with an explicit `$?` check, not just output inspection), which is the stated precondition for 22-08 turning the CI analyze gate on.
- `tool/verify_additive_boundary.sh` still fails on the same two pre-existing findings 22-03/22-04 already documented (6 duplicate private-class names, one `WIRE-02` prose false-positive in `global_swap_fab_host.dart`) -- neither file was touched by this plan; re-confirmed byte-for-byte identical and logged in `deferred-items.md`. Still recommend a future plan baseline the 6 names or exclude `_`-prefixed classes from Check 2's census regex.
- **Recommend a manual smoke test before merge/ship**, since `lib/reown/` and the CoinGecko/Banxa API clients were both touched: `flutter build windows --debug` succeeds and the full automated test suite (512/0) passes, but exercising one live dApp connect and one market-data load by hand (per the plan's own verification item 8) requires a real WalletConnect-compatible dApp and live network calls that this autonomous execution could not perform. No behaviour change was made to the WalletConnect approval flow or the API response shapes -- only type annotations and `unawaited()` wraps -- so risk is low, but a human click-through is the appropriate final confirmation for money-path code.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*

## Self-Check: PASSED

- FOUND: `22-06-SEMANTIC-DELTAS.md`
- FOUND: `22-06-SUMMARY.md`
- FOUND: all 13 task commits (`5627643`, `c3eec8c`, `0ef89a9`, `13297c2`, `5a4df44`, `587755d`, `3eee750`, `5213a2e`, `cc011af`, `e351100`, `3e56ca9`, `c5c0e30`, `ff8bbea`) present in `git log --oneline --all`
