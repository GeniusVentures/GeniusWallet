# 23-04 Gate Scope: Covered vs. Uncovered Directories for `tool/check_raw_colors.sh`

Written at the end of 23-04 Task 3. States plainly what `tool/check_raw_colors.sh`
enforces today, what it does not yet reach, and what closing each remaining
directory would take. This is a tracked backlog with numbers, not a silent
omission — the gate's own header comment points here.

## How this was measured

Every count below is the gate's OWN AWK matcher (`tool/check_raw_colors.sh`'s
`strip_all` + `line_has_flaggable_colors`/hex-literal check), run per-file, summed
per-directory — not a naive `grep`. It strips `//` and `/* */` comments and
single/double-quoted string contents before matching, so a doc comment that
quotes a hex value or names `Colors.white` in prose is not counted. This is
materially lower than earlier, cruder greps in this phase's history: the
2026-07-28 baseline (23-04-PLAN.md's own planning figure) was **525** raw
references outside `lib/theme/`, of which 83 were the mode-breaking
white/black/grey subset. Re-measured today, with the same strip-comments/strings
discipline the gate itself uses, the true remaining count outside `lib/theme/`
is **66** — 23-01 through 23-03's residue-closing work, plus this plan's own Task
1/Task 2 migrations, closed the overwhelming majority of the 525 already. The
525 figure and the 66 figure are not directly comparable methodologies (525 was
almost certainly grep-based and over-counted doc-comment mentions the way
23-02-RESIDUE.md's own reconciliation section describes for the
`GeniusWalletColors.*` codemod count) — treat 66 as the trustworthy number, since
it is produced by the same code path that will gate CI going forward.

Re-run recipe: `bash tool/check_raw_colors.sh --count` (covered directories
only); for the full-tree number quoted above, the per-directory table below was
built by pointing the same AWK matcher at every `lib/` subdirectory in turn (see
git history of this file's authoring commit for the exact loop).

## Covered directories (16 lib/ subdirectories + `lib/main.dart`) — measured 0

| Directory | Count |
|---|---|
| `lib/assets` | 0 |
| `lib/bloc` | 0 |
| `lib/chart` | 0 |
| `lib/dev` | 0 |
| `lib/hive` | 0 |
| `lib/logs` | 0 |
| `lib/navigation` | 0 |
| `lib/onboarding` | 0 |
| `lib/providers` | 0 |
| `lib/services` | 0 |
| `lib/settings` | 0 |
| `lib/squid_router` | 0 |
| `lib/submit_job` | 0 |
| `lib/test` (dev overrides, not the top-level `test/` suite) | 0 |
| `lib/tokeninfo` | 0 |
| `lib/tokens` | 0 |
| `lib/main.dart` (top-level file, not a directory) | 0 |

`lib/theme/` is NEVER covered — raw colours are the primitive layer there and
correct by design (measured 62 references, all legitimate literal token
definitions or the documented findings from Task 1).

## Uncovered directories — measured non-zero, with a closing note

| Directory | Count | Files affected | Closing note |
|---|---|---|---|
| `lib/account` | 1 | 1 | `sdk_account_manager.dart` — one residual site; likely a single missed call site from 23-02/23-03's residue closure. Small, mechanical. |
| `lib/banxa` | 10 | 6 | Spread across the Banxa buy-flow drawers (`buy_cancelled_drawer.dart`, `buy_cancelled_drawer_content.dart`, `buy_success_drawer.dart`, `buy_success_drawer_content.dart`) plus `banxa_helpers.dart` and `checkout_qr.dart`. These are the buy/checkout confirmation screens — a self-contained sub-flow, plausible as a single follow-up plan's scope. |
| `lib/components` | 21 | 10 | The widest surface: `gw_button.dart` (5) and `disclaimer_dialogue.dart` (5) carry the most; the rest (`checkmark_animation.dart`, `x_animation.dart`, `responsive_drawer.dart`, `gw_select_row.dart`, `gw_view_all_link.dart`, `gw_mesh_background.dart`, `crypto_address_qr.dart`, `recoveryword.dart`) are 1-2 each. `gw_button.dart` and `gw_mesh_background.dart` are shared, high-traffic components — closing this directory has the highest de-hex leverage of any uncovered one, but also the highest review cost (every consumer of these widgets is a visual-regression risk). |
| `lib/dashboard` | 6 | 4 | `dashboard_screen.dart` (2), `transaction_badge.dart` (2, likely the `statusNeutral`-adjacent fill logic this plan's Task 2 already partially touched), `markets_table.dart` (1), `transactions_slim_view.dart` (1). |
| `lib/network` | 6 | 1 | All 6 in `network_page.dart` alone — a single-file, single-plan closing candidate. |
| `lib/reown` | 9 | 6 | The dApp-approval surface 23-03 Task 3 already migrated most of (raw-colour count there was re-measured at 12 survivors in 23-03, "all documented exceptions or grep false positives" per that plan's own SUMMARY) — this 9 is presumably that same documented-survivor set, now counted by the stricter comment/string-aware gate matcher instead of 23-03's by-hand review. Re-verify each of the 6 files' survivors before closing rather than assuming they are all still deliberate. |
| `lib/screens` | 4 | 2 | `splash.dart` (3) — plausibly the fixed-white-wordmark-on-dark-splash case AGENTS.md's own light-mode carve-out anticipates (`gw_context_extension.dart`'s doc comment references exactly this shape) — and `banxa_buy_screen.dart` (1). |
| `lib/utils` | 2 | 1 | `image_utils.dart` — likely a non-widget helper needing the same "thread a GWColors/BuildContext parameter through" treatment 23-02-RESIDUE.md's no-context refusals used. |
| `lib/wallets` | 2 | 1 | `genius_balance_display.dart`. |
| `lib/web` | 5 | 1 | All 5 in `web_view_windows.dart` — a single-file, platform-specific (Windows webview) surface. |

**Total: 66 raw references across 29 files in 10 directories.**

## Widening plan

Append a directory to `COVERED_DIRS` in `tool/check_raw_colors.sh` the moment its
own count hits zero — do not widen speculatively ahead of the actual de-hex
work, and do not batch multiple directories into one PR without re-running
`--count` per directory first (a directory's count can drift between this
document's authoring and a future plan actually closing it).

Suggested order (smallest / most self-contained first, matching this project's
established "residue closure" pattern from 23-02/23-03):

1. `lib/network` (6, one file) and `lib/account` (1, one file) — trivial, single-file, likely a direct `context.gw` swap each.
2. `lib/utils` (2), `lib/wallets` (2), `lib/screens` (4) — small, few files, though `screens/splash.dart` may include a deliberate always-dark exception worth checking against `raw-color-ok:` rather than migrating.
3. `lib/web` (5, one file) and `lib/dashboard` (6, four files) — moderate.
4. `lib/reown` (9) and `lib/banxa` (10) — re-verify 23-03's own "documented exception" claims still hold under the gate's stricter matcher before treating these as pure migration work; some may already be `raw-color-ok:`-eligible rather than needing a code change.
5. `lib/components` (21) — last, on purpose: it is the widest-blast-radius directory (shared widgets consumed app-wide), so its de-hex work benefits most from the rest of the app already being clean and the gate already being live in CI to catch a regression during the review.

## Explicitly out of scope

**The full de-hex of every remaining raw colour across `lib/` is larger than
this phase.** 66 references across 10 directories is real, scoped follow-up
work — this plan's own Task 1/Task 2 closed the mono-family and
`GWDecorations` duplication, and Tasks 1-3 together do not claim to have
closed the phase's entire colour surface. The 2026-07-28 measurement of 525
(now 66 by this document's own stricter count) is the reason a repo-wide gate
was rejected as this plan's Task 3 deliverable: enabling it against the full
tree today would fail CI on every one of the 10 directories above,
blocking unrelated work rather than protecting what is already clean.
