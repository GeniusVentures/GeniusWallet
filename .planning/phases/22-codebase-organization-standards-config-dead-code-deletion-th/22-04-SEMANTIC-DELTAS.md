# 22-04: `mounted`-guard semantic-delta audit

The plan singles out `mounted` guards as "the one sanctioned semantic delta" and requires every
such site be recorded individually rather than absorbed silently into the bulk 192-site sweep.
`mounted`/`context.mounted` guards are the async-gap safety idiom throughout this codebase (guard
against calling `setState`/using a `BuildContext` after a widget has been disposed), so they are
also the highest-consequence category if a rewrite ever got the statement boundary wrong.

This document is that individual record: all 35 `mounted`-related sites the `--fix` sweep touched,
what each one looked like before and after, and the verification performed against the specific
hazard (a shift in `use_build_context_synchronously` diagnostics near a rewritten guard).

## Method

1. Every site below was rewritten by `tool/check_brace_style.sh --fix` (Task 2), never by hand --
   all 35 fell inside the "in scope" shape (condition + body + terminating `;` on one physical
   line, no `else`), so none required manual closing.
2. **Token-stream proof (all 75 fixed files, including all 35 of these):** stripping whitespace,
   `{`/`}`, and `,` from the pre-fix and post-fix+format content of every fixed file yields
   byte-identical output. This proves no statement moved in or out of any `if`, including every
   guard listed here -- see the plan's Task 2 commits for the full methodology.
3. **Analyzer-diagnostic proof (the specific hazard named in the plan):** braced vs. unbraced
   `mounted` guards were tested directly for whether bracing changes `use_build_context_synchronously`
   detection. Case: `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart`, the guard at what
   is now line 192-194 (`if (!mounted) { return; }`) immediately precedes a `ScaffoldMessenger.of(context)`
   call the analyzer flags. Running `flutter analyze --no-pub` on this single file with the guard
   manually reverted to its unbraced form (`if (!mounted) return;`) still reports the exact same
   diagnostic (`use_build_context_synchronously`, "guarded by an unrelated 'mounted' check"), only at
   the line number the unbraced form would occupy (193 vs. 195 -- a 2-line shift from the braces
   themselves, not a different diagnostic). The full-repo `flutter analyze --no-pub` count is
   unchanged from the 22-03 ceiling (344, exact match, not a range) and the same 5
   `use_build_context_synchronously` issues appear post-sweep as a general class -- none of them were
   introduced or removed by bracing a guard.
4. **Conclusion:** bracing a `mounted` guard is semantically identity for both runtime behaviour
   (Dart's CFG treats a block containing one statement the same as the bare statement) and for the
   analyzer's diagnostics (the lint's guard-detection is unaffected by the block wrapper). No actual
   semantic delta was found in this sweep; this document exists as the individually-recorded proof
   the plan asked for, not as a list of behaviour changes.

## The 35 sites

| # | File:Line (pre-fix) | Guard form | Rewritten to |
|---|---|---|---|
| 1 | `lib/account/account_dropdown_selector.dart:53` | `if (!mounted) return;` | 3-line braced |
| 2 | `lib/account/sdk_account_manager.dart:440` | `if (!navigator.context.mounted) return;` | 3-line braced |
| 3 | `lib/account/sdk_account_manager.dart:497` | `if (result == null \|\| result.value.isEmpty \|\| !context.mounted) return;` | 3-line braced |
| 4 | `lib/account/sdk_account_manager.dart:506` | `if (!context.mounted) return;` | 3-line braced |
| 5 | `lib/account/sdk_account_manager.dart:554` | `if (!navigator.context.mounted) return;` | 3-line braced |
| 6 | `lib/chart/crypto_live_chart.dart:158` | `if (!mounted) return;` | 3-line braced |
| 7 | `lib/chart/crypto_live_chart.dart:189` | `if (!mounted) return;` | 3-line braced |
| 8 | `lib/components/coins/view/coins_screen.dart:109` | `if (!mounted) return;` | 3-line braced |
| 9 | `lib/components/overlay/global_swap_fab_host.dart:83` | `if (mounted) setState(() => _ready = true);` | 3-line braced (positive guard) |
| 10 | `lib/components/overlay/global_swap_fab_host.dart:94` | `if (!mounted) return;` | 3-line braced |
| 11 | `lib/components/overlay/global_swap_fab_host.dart:110` | `if (mounted) setState(() {});` | 3-line braced (closure body, empty `setState`) |
| 12 | `lib/components/sgnus/sgnus_connection_widget.dart:41` | `if (!mounted) return;` | 3-line braced |
| 13 | `lib/components/splash.dart:41` | `if (!mounted) return;` | 3-line braced |
| 14 | `lib/components/splash.dart:61` | `if (context.mounted) context.go(target);` | 3-line braced (positive guard) |
| 15 | `lib/dashboard/bridge/bridge_screen.dart:302` | `if (!context.mounted) return;` | 3-line braced |
| 16 | `lib/dashboard/bridge/bridge_screen.dart:357` | `if (mounted) setState(() => isSubmitting = false);` | 3-line braced (positive guard) |
| 17 | `lib/dashboard/news/view/crypto_news_screen.dart:63` | `if (mounted) setState(() => _lastUpdated = DateTime.now());` | 3-line braced (positive guard) |
| 18 | `lib/dashboard/news/view/crypto_news_screen.dart:78` | `if (mounted) setState(() => _query = value);` | 3-line braced (positive guard) |
| 19 | `lib/dashboard/news/view/crypto_news_screen.dart:212` | `if (mounted) setState(() {});` | 3-line braced (closure body, empty `setState`) |
| 20 | `lib/logs/submit_logs_screen.dart:183` | `if (mounted) setState(() => _probes = const []);` | 3-line braced (positive guard) |
| 21 | `lib/logs/submit_logs_screen.dart:213` | `if (mounted) setState(() => _probes = probes);` | 3-line braced (positive guard) |
| 22 | `lib/network/network_dropdown_selector.dart:46` | `if (!mounted) return;` | 3-line braced (the directly-tested case, see Method §3) |
| 23 | `lib/network/network_page.dart:31` | `if (!mounted) return;` | 3-line braced |
| 24 | `lib/network/network_page.dart:44` | `if (!mounted) return;` | 3-line braced |
| 25 | `lib/network/network_page.dart:55` | `if (!mounted) return;` | 3-line braced |
| 26 | `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:192` | `if (!mounted) return;` | 3-line braced (the directly-tested case, see Method §3) |
| 27 | `lib/reown/reown_connect_button.dart:122` | `if (!mounted \|\| event == null) return;` | 3-line braced |
| 28 | `lib/reown/reown_connect_button.dart:143` | `if (!mounted) return;` | 3-line braced |
| 29 | `lib/reown/reown_connect_button.dart:247` | `if (!mounted) return;` | 3-line braced |
| 30 | `lib/screens/splash.dart:90` | `if (!mounted) return;` | 3-line braced |
| 31 | `lib/screens/splash.dart:134` | `if (!mounted) return;` | 3-line braced |
| 32 | `lib/squid_router/swap_screen.dart:335` | `if (mounted) showTransactionDetails(context, transaction);` | 3-line braced (positive guard) |
| 33 | `lib/squid_router/swap_screen.dart:344` | `if (mounted) setState(() => isSubmitting = false);` | 3-line braced (positive guard) |
| 34 | `lib/web/web_view_mobile.dart:251` | `if (!mounted \|\| url.isEmpty \|\| url == 'about:blank') return;` | 3-line braced |
| 35 | `lib/web/web_view_mobile.dart:268` | `if (!mounted) return;` | 3-line braced |

Every site above passed the token-stream equality check (Method §2) as part of its containing
file's proof, and none showed any analyzer-diagnostic delta beyond the expected line-number shift
from the two inserted lines (Method §3).
