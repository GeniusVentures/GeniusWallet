# 22-05 Residue: The Non-Automatable Analyzer Tail

Written at the end of 22-05, after every rule with an associated `dart fix` was applied (12
rule-commits from the plan's own list, plus 2 more the plan didn't name but that `dart fix --dry-run`
still reported: `deprecated_member_use` and `sized_box_for_whitespace`).

**`dart fix --dry-run` reports zero available fixes in both packages** (verified 2026-07-28,
immediately before writing this document):

```
$ dart fix --dry-run                              # repo root
Computing fixes in geniuswallet (dry run)...
Nothing to fix!

$ cd packages/genius_api && dart fix --dry-run
Computing fixes in genius_api (dry run)...
Nothing to fix!
```

**`flutter analyze --no-pub` total: 101 issues, 0 errors** (down from the 22-04 baseline of 344 —
a 243-issue drop, well inside the plan's "~100 or fewer" target for the non-automatable tail).

Every remaining issue is grouped below by rule, with per-file counts and a one-line
mechanical-vs-judgement note so 22-06 can execute directly from this document without
re-deriving the analysis.

---

## `avoid_dynamic_calls` — 20 occurrences, 8 files — **judgement**

| File | Count |
|---|---|
| `lib/assets/read_asset.dart` | 5 |
| `lib/banxa/banxa_model.dart` | 5 |
| `lib/services/coin_gecko/coin_gecko_api.dart` | 6 |
| `lib/hive/models/coin_gecko_market_data.dart` | 1 |
| `lib/providers/network_tokens_provider.dart` | 1 |
| `lib/reown/handle_dapp_requests.dart` | 1 |
| `test/banxa/checkout_options_sheet_test.dart` | 1 |

**Judgement:** every site is a call on a value typed `dynamic` (mostly `jsonDecode` results and
FFI/JS-bridge returns). Fixing requires typing the boundary — a model class, a cast with a runtime
`is` check, or a `Map<String, dynamic>` accessor helper — chosen per call site, not a mechanical
rewrite. 22-06 needs to decide, per file, whether to introduce a typed decode step or leave a
narrow, justified cast.

## `unawaited_futures` — 17 occurrences, 11 files — **judgement**

| File | Count |
|---|---|
| `lib/account/sdk_account_manager.dart` | 1 |
| `lib/banxa/banxa_api_services.dart` | 1 |
| `lib/components/wallet_information.dart` | 1 |
| `lib/reown/handle_dapp_requests.dart` | 2 |
| `lib/services/coin_gecko/coin_gecko_api.dart` | 2 |
| `lib/submit_job/cubit/submit_job_cubit.dart` | 2 |
| `lib/web/web_utils.dart` | 1 |
| `lib/web/web_view_mobile.dart` | 2 |
| `lib/web/web_view_windows.dart` | 1 |
| `test/boot_sequence_test.dart` | 1 |
| `test/components/global_swap_fab_host_test.dart` | 3 |

**Judgement:** each site needs a human call on whether the future should be `await`ed (changing
control flow / adding an `async` keyword upstream) or deliberately fire-and-forget (wrapped in the
`unawaited()` helper from `dart:async` to document intent). Not safe to blanket-`await` — some of
these are genuinely detached (e.g. analytics/logging calls) and forcing `await` would change
sequencing.

## `avoid_print` — 11 occurrences, 3 files — **mechanical, but scoped choice needed**

| File | Count |
|---|---|
| `lib/banxa/banxa_order/create_order_cubit.dart` | 1 |
| `lib/tokeninfo/token_info_loader.dart` | 2 |
| `lib/web/web_view_mobile.dart` | 8 |
| `lib/web/web_view_mobile.dart` (`[DEBUG]`-prefixed lines) | (subset of the 8) |

**Note:** mechanical in the sense that every site is a straight `print()` → structured-logger
swap, but 22-06 needs a project decision first: which logger (`dart:developer`'s `log()`, a
package logger, or the existing Sentry breadcrumb path) replaces `print` repo-wide. Once that
choice is made, the individual replacements are mechanical. `lib/web/web_view_mobile.dart`'s 8
sites are all `[DEBUG]`-prefixed diagnostic prints in the WebView navigation-delegate closures
touched by this plan's `unnecessary_non_null_assertion` fix (Task 1) — worth doing together since
22-06 will already be in that file.

## `library_private_types_in_public_api` — 10 occurrences, 10 files — **judgement**

| File | Count |
|---|---|
| `lib/components/continue_button/isactive_false.dart` | 1 |
| `lib/components/continue_button/isactive_true.dart` | 1 |
| `lib/components/custom/genius_back_button_custom.dart` | 1 |
| `lib/components/custom/isactive_false_custom.dart` | 1 |
| `lib/components/custom/isactive_true_custom.dart` | 1 |
| `lib/components/custom/wallet_agreement_custom.dart` | 1 |
| `lib/components/genius_back_button.dart` | 1 |
| `lib/components/incorrect_pin.dart` | 1 |
| `lib/components/recoveryword.dart` | 1 |
| `lib/components/registration_header.dart` | 1 |

**Judgement:** every site is a public `StatefulWidget`'s `createState()` returning a private
`State` subclass (`_FooState`) as its declared return type. The standard fix is to make the
`State` return type `State<Foo>` instead of the private class name — a one-line signature change
per file, but it is a public-API surface edit (return type of a public method), not something
`dart fix` offers a fixer for, so it needs a human to apply and re-verify each site individually
rather than a blanket sweep.

## `depend_on_referenced_packages` — 10 occurrences, 6 files — **mechanical, all inside `packages/genius_api`**

| File | Count | Missing dependency |
|---|---|---|
| `packages/genius_api/lib/controllers/sgnus_connection_controller.dart` | 1 | `rxdart` |
| `packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` | 1 | `rxdart` |
| `packages/genius_api/lib/extensions/extensions.dart` | 1 | `ffi` |
| `packages/genius_api/lib/src/genius_api.dart` | 4 | `convert`, `ffi`, `path_provider`, `rxdart` |
| `packages/genius_api/lib/tw/hd_wallet.dart` | 1 | `convert` |
| `packages/genius_api/lib/tw/mnemonic_impl.dart` | 1 | `ffi` |
| `packages/genius_api/lib/tw/string_util.dart` | 1 | `ffi` |

**Note (mechanical, but needs a `pubspec.yaml` edit, not a source edit):** `packages/genius_api`
transitively resolves `rxdart`, `ffi`, `convert`, and `path_provider` today (they're dependencies
of the root app's `pubspec.yaml`, in the same workspace), but `packages/genius_api/pubspec.yaml`
itself never lists them as direct dependencies — it is relying on the workspace's flattened
resolution. The fix is adding 4 lines to `packages/genius_api/pubspec.yaml`'s `dependencies:`
block, then `dart pub get` in that package. Sits entirely inside `packages/genius_api/`, which is
easy to forget when working from the repo root — flagged per the plan's read_first note.

## `strict_top_level_inference` — 10 occurrences, 2 files — **mechanical, all inside `packages/genius_api`**

| File | Count |
|---|---|
| `packages/genius_api/lib/src/genius_api.dart` | 3 |
| `packages/genius_api/lib/tw/stored_key_wallet.dart` | 7 |

**Note:** every site is a top-level function/method parameter or return type inferred instead of
written explicitly. Mechanical in the sense that the fix is "write down the type the analyzer
already inferred" — but doing that correctly requires reading each signature to state the type by
hand (no auto-fixer offered), and a couple of these are FFI-adjacent (`stored_key_wallet.dart`)
where getting the annotation exactly right matters for correctness, not just style.

## `deprecated_member_use` — 6 occurrences, 3 files — **mechanical**

| File | Count | Deprecated member → replacement |
|---|---|---|
| `lib/components/inputs/gw_switch.dart` | 1 | `activeColor` → `activeThumbColor`/`activeTrackColor` |
| `lib/components/string_button.dart` | 1 | `textScaleFactor` → `textScaler` |
| `lib/services/coin_telegraph/coin_telegraph_api.dart` | 4 | `.text` (XML node) → `.value`/`.innerText` |

**Note:** all 3 are direct, unambiguous renames with no behavior nuance beyond the deprecation
notice itself (Flutter SDK API migrations). `dart fix` does not offer fixers for these specific
three yet (unlike the one `deprecated_member_use` site this plan already fixed via `dart fix` in
Task 3 — `gw_select.dart`'s `value`→`initialValue`, which did have a fixer). Straightforward
one-line-per-site hand edits for 22-06.

## `unintended_html_in_doc_comment` — 3 occurrences, 1 file — **mechanical**

| File | Count |
|---|---|
| `lib/hive/models/historical_price_cache_entry.dart` | 3 (lines 15, 15, 26) |

**Note:** doc-comment text contains bare `<...>` that the analyzer's doc-comment renderer
interprets as HTML. Fix is to escape the angle brackets (e.g. `Map<String, dynamic>` →
`` `Map<String, dynamic>` `` inside backticks, or HTML-entity-escape) in the doc comment. Zero
behavior risk — comment-only.

## `use_build_context_synchronously` — 5 occurrences, 4 files — **judgement**

| File | Count |
|---|---|
| `lib/banxa/banxa_orders_history.dart` | 1 |
| `lib/network/network_dropdown_selector.dart` | 1 |
| `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart` | 1 |
| `lib/reown/reown_connect_button.dart` | 2 |

**Judgement:** each site uses a `BuildContext` after an `await`, guarded by a `mounted` check the
analyzer doesn't consider sufficiently tight (either the check is on an unrelated
object/StatefulWidget, or it's missing the exact adjacency pattern the lint wants). Fixing means
verifying, per site, that the guard is real and either tightening it or restructuring so the
`BuildContext` use sits immediately after the check. This is exactly the class of finding
22-04's `SEMANTIC-DELTAS.md` already investigated for the mounted-guard bracing work — 22-06
should treat these as the same hazard category and apply the same rigor, not a rubber-stamp.

## `unused_field` — 2 occurrences, 1 file — **mechanical, but confirm dead before deleting**

| File | Count |
|---|---|
| `lib/squid_router/squid_token_service.dart` | 2 (`_baseUrl`, `_testNetBaseUrl`) |

**Note:** both fields are private and genuinely unread per the analyzer. Deleting is mechanical,
but 22-06 should grep for any reflective/string-based access (unlikely here, plain Dart fields)
before removing, consistent with the phase's general dead-code-deletion caution.

## `unused_local_variable` — 2 occurrences, 2 files — **mechanical**

| File | Count |
|---|---|
| `test/theme/nav_chip_style_test.dart` | 1 (`gw`, line 97) |
| `test/token_info_loader_test.dart` | 1 (`tokens3`, line 137) |

**Note:** test-only, both are assigned but never read. Straightforward deletion or, if the
variable exists for readability/documentation of intent, a `// ignore:
unused_local_variable` with a reason — 22-06's call per site.

## `non_constant_identifier_names` — 2 occurrences, 1 file — **judgement**

| File | Count |
|---|---|
| `packages/genius_api/lib/ffi_bridge_prebuilt.dart` | 2 (`tw_lib`, `sgns_lib`) |

**Judgement:** these are top-level variable names in snake_case rather than lowerCamelCase.
Mechanical rename (`tw_lib` → `twLib`, `sgns_lib` → `sgnsLib`), but they're FFI library-loading
globals — 22-06 should confirm no external tooling or generated code references these exact
names by string before renaming.

## `constant_identifier_names` — 1 occurrence, 1 file — **mechanical**

| File | Count |
|---|---|
| `lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart` | 1 (`SELECT_WORD_COUNT`, line 161) |

**Note:** `SCREAMING_CASE` constant → `lowerCamelCase` per Effective Dart. Straightforward rename;
confirm no other file references the same identifier by name before renaming (a quick grep).

## `unused_element` — 1 occurrence, 1 file — **mechanical, but confirm dead before deleting**

| File | Count |
|---|---|
| `packages/genius_api/lib/src/genius_api.dart` | 1 (`_mapProcessingStatus`, line 1231) |

**Note:** private top-level/class declaration never referenced. Same caution as `unused_field`
above — confirm no reflective access, then delete.

## `directives_ordering` — 1 occurrence, 1 file — **out of scope, generated file**

| File | Count |
|---|---|
| `lib/hive_registrar.g.dart` | 1 |

**Note:** this file matches the root `analysis_options.yaml`'s `lib/**/*.g.dart` exclude glob in
principle, but the live `flutter analyze --no-pub` run for this plan still reports one
`directives_ordering` diagnostic against it. `dart fix --dry-run` did **not** offer a fix for it
(confirmed clean in the final dry-run above), which is consistent with the exclude applying to
the *fixer* but not fully suppressing this one diagnostic in this analyzer version, or a caching
artifact. 22-06 should not hand-edit a `.g.dart` file (regenerated by `build_runner`, would be
silently overwritten); if this persists, the right fix is in the generator invocation or the
exclude glob, not the generated output. Flagging rather than resolving.

---

## Rule-count sanity check

`20 + 17 + 11 + 10 + 10 + 10 + 6 + 3 + 5 + 2 + 2 + 2 + 1 + 1 + 1 = 101` — matches
`flutter analyze --no-pub`'s reported total exactly.

## Cross-cutting note for 22-06

- 10 of the 101 (`depend_on_referenced_packages`) + 10 of the 101 (`strict_top_level_inference`)
  = 20 issues, essentially 1/5 of the whole tail, sit entirely inside `packages/genius_api/`.
  That package needs its own dedicated pass, starting with the `pubspec.yaml` dependency edit
  (which unblocks nothing else, but is the fastest single commit available in the residue).
- `use_build_context_synchronously` (5) and `library_private_types_in_public_api` (10) are the two
  rule groups most likely to need real per-site judgement rather than a rename; budget time there
  accordingly.
- `avoid_print` (11) is blocked on one small upstream decision (which logger) before any of its
  11 sites can move.

## Verification snapshot (2026-07-28, end of 22-05)

```
dart fix --dry-run                          # repo root:        Nothing to fix!
dart fix --dry-run                          # packages/genius_api: Nothing to fix!
flutter analyze --no-pub                    # 101 issues found, 0 errors
flutter test --no-pub                       # All tests passed! (512/0)
dart format --output=none --set-exit-if-changed lib test   # exit 0
bash tool/check_brace_style.sh --count      # 0
```
