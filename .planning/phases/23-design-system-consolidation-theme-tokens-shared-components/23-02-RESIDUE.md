# 23-02 Residue: Sites the AST Codemod Refuses, and the Six `test/` Files 23-04 Will Break

Written at the end of 23-02, after `tool/codemod_colors.dart --apply` ran directory-by-directory
over every directory the plan named, plus `lib/main.dart` (a top-level file the plan's directory
list never named — see the SUMMARY's Deviations section).

## Reconciliation

`tool/codemod_colors.dart --dry-run` (default path `lib`, i.e. this plan's actual scope) found
**251 total sites** across the whole tree before any directory was touched: **179 rewritten + 45
const-refused + 27 no-context-refused = 251**. After every directory (+ `lib/main.dart`) was
applied, re-running the same dry-run finds **0 remaining rewritable sites** and the exact same
**72 refusals** (45 const + 27 no-context) — every site that could be rewritten was rewritten, and
every refusal below is a genuine hard case, not a missed opportunity:

```
$ dart run tool/codemod_colors.dart --dry-run
...
Sites rewritten: 0
Sites refused (const): 45
Sites refused (no-context): 27
Total sites seen: 72
```

**Against 23-01-TOKEN-MAP.md's 277 figure:** that count was `lib` **and** `test` combined (its own
re-run recipe explicitly greps both). This plan's scope is `lib/` only — `test/` is 23-04's problem
(see below) — so the right comparison is 277 minus whatever the six `test/` files below contribute
(13 occurrences, tallied below), leaving 264 as the `lib`-only figure the naive grep would report.
The AST tool's 251 is close but not identical to that 264, and the full gap is explained rather
than papered over: a spot-check found roughly a dozen identically-spelled
`GeniusWalletColors.<name>` occurrences sitting inside **doc comments** across `lib/`
(`lib/components/action_button.dart:16`, `lib/components/bottom_drawer/responsive_drawer.dart:81`
and `:89`, `lib/components/feedback/gw_warning_note.dart:16`, `lib/components/loading/loading.dart:8`,
`lib/dashboard/compute/compute_panel.dart:143`,
`lib/dashboard/home/widgets/transactions_slim_view.dart:554`, `lib/screens/pin_screen.dart:94`,
`lib/screens/splash.dart:19`, `lib/submit_job/view/widgets/job_steps.dart:351`, and 2 more in
`lib/banxa/banxa_components/order_status_style.dart` and `lib/squid_router/token_selector_drawer.dart`)
— a regex-based grep cannot tell these from real code and counts them; the AST correctly does not,
because they were never a `PrefixedIdentifier`/`PropertyAccess` node to begin with. This is exactly
the class of over-count the plan's rationale for an AST rewriter over a regex predicted.

## Refusals by reason

### `const` — 45 sites, cannot hold a runtime `context.gw` read

Every site here sits inside an explicit `const` invocation/literal, a `const` variable's
initializer, or (by the codemod's own additional check) a default parameter value — a compile-time
constant is required, and `context.gw.<field>` is a runtime `Theme.of(context)` read. Closing these
means either de-consting the surrounding widget (correct wherever the const-ness wasn't load-bearing)
or leaving the value as a primitive constant deliberately, case by case — a judgement call, not a
mechanical sweep. Grouped by file:

| File | Line(s) | Symbol(s) |
|---|---|---|
| `lib/account/account_drawer.dart` | 326, 331, 405 | `statusError` (x2), `textOnBrand` |
| `lib/components/buttons/gw_swap_fab.dart` | 75 | `textOnBrand` |
| `lib/components/continue_button/isactive_false.dart` | 56 | `btnTextDisabled` |
| `lib/components/continue_button/isactive_true.dart` | 59 | `btnText` |
| `lib/components/custom_future_builder.dart` | 42 | `statusError` |
| `lib/components/feedback/gw_error_state.dart` | 44, 102, 119 | `statusError` (x3) |
| `lib/components/feedback/gw_loading_state.dart` | 28 | `brandGreen` |
| `lib/components/incorrect_pin.dart` | 45 | `statusError` |
| `lib/components/inputs/gw_select.dart` | 53 | `textSecondary` |
| `lib/components/loading/gw_spinner.dart` | 77, 78, 79 | `brandPrimary`, `brandSecondary`, `brandSecondaryBright` (the `const SweepGradient` 22-05 flagged in advance — confirmed live risk) |
| `lib/components/overlay/responsive_overlay.dart` | 205 | `brandPrimaryStrong` |
| `lib/components/registration_header.dart` | 49 | `deepBlueCardColor` (the `const BoxDecoration` 22-05 flagged in advance — confirmed live risk) |
| `lib/components/wallet_information.dart` | 189, 190 | `textSecondary` (x2) |
| `lib/components/wallets_overview.dart` | 94 | `statusError` |
| `lib/dashboard/home/widgets/transaction_badge.dart` | 61, 69, 96 | `brandTertiary`, `brandPrimaryStrong`, `statusWarning` |
| `lib/dev/design_gallery_screen.dart` | 198, 201, 203, 206, 210, 212, 231, 232, 233, 234 | 10 swatches (the design-gallery debug screen enumerates the whole palette as `const` chips) |
| `lib/logs/submit_logs_screen.dart` | 907 | `brandSecondaryStrong` |
| `lib/main.dart` | 265 | `statusError` |
| `lib/reown/reown_connect_button.dart` | 321, 378 | `brandPrimary` (x2) |
| `lib/reown/swap_result_drawer.dart` | 78 | `deepBlueTertiary` |
| `lib/screens/splash.dart` | 276, 277 | `brandPrimary`, `brandSecondary` |
| `lib/squid_router/token_flip_button.dart` | 55 | `textOnBrand` |
| `lib/submit_job/view/widgets/job_step_list.dart` | 200 | `textOnBrand` |
| `lib/web/web_view_mobile.dart` | 728 | `statusSuccess` |
| `lib/web/web_view_windows.dart` | 394 | `statusSuccess` |

**Closing note:** `lib/dev/design_gallery_screen.dart` alone is 10 of the 45 (a debug-only palette
swatch screen, lowest risk to de-const). The remaining 35 need a per-site call on whether the
`const` was load-bearing (a `const` widget subtree that genuinely never needs to rebuild) or just
historical (written when only the static palette existed, `const` was the only option).

### `no-context` — 27 sites, no `BuildContext` reachable

Every site here is a static member, a top-level declaration, a field initializer, or a class that
extends neither `State<...>` nor takes a `context` parameter (controllers, painters, models).
Closing these needs a structural decision per site — thread a `BuildContext` parameter through, or
leave the value on the primitive layer if the call site is genuinely context-free (e.g. a
`CustomPainter`). Grouped by file:

| File | Line(s) | Symbol(s) | Shape |
|---|---|---|---|
| `lib/account/sdk_account_manager.dart` | 291 | `statusError` | no `context` param in scope at this call site |
| `lib/banxa/banxa_components/order_status_style.dart` | 50, 51 | `statusWarning` (x2) | non-widget style-mapping function, no context |
| `lib/components/action_button.dart` | 17 | `brandPrimaryOnSurface` | static field/getter |
| `lib/components/bottom_drawer/responsive_drawer.dart` | 82, 90 | `borderControl` (x2) | no `context` param in scope |
| `lib/components/buttons/gw_button.dart` | 129, 131, 144, 146, 164, 176, 178 | `gradientBlue`, `textOnBrand`, `brandPrimaryOnSurface` (x2), `statusError`, `gradientBlue`, `textOnBrand` | style-lookup helper without a context param |
| `lib/components/effects/gw_mesh_background.dart` | 139, 140, 142 | `brandPrimary`, `brandSecondary`, `brandTertiary` | `CustomPainter`-adjacent, no context |
| `lib/components/inputs/gw_text_field.dart` | 220 | `statusError` | no `context` param in scope |
| `lib/components/loading/gw_spinner.dart` | 70 | `borderSubtle` | `_SpinnerPainter extends CustomPainter` — genuinely no `BuildContext` ever reaches `paint()` |
| `lib/dashboard/compute/compute_panel.dart` | 137, 161 | `brandPrimaryOnSurface`, `statusWarning` | no `context` param in scope |
| `lib/dashboard/home/widgets/transaction_badge.dart` | 126, 128 | `textOnBrand` (x2) | `badgeGlyphColor` helper computed without a context param (see also `statusNeutral`'s own locked exception in this same file, untouched by this plan) |
| `lib/dashboard/home/widgets/transaction_displays.dart` | 61, 62 | `statusWarning` (x2) | no `context` param in scope |
| `lib/reown/handle_dapp_requests.dart` | 99 | `deepBlueCardColor` | non-widget request-handling code, no context |
| `lib/submit_job/view/widgets/job_steps.dart` | 357 | `statusWarning` | no `context` param in scope |
| `lib/tokens/token_info_screen.dart` | 845 | `brandPrimaryOnSurface` | `static Color get _glyph` — the exact site 22-05 flagged in advance as a static getter, confirmed still non-const-but-context-free |

**Closing note:** 12 of the 27 are style/paint helper functions or `CustomPainter`s that structurally
never see a `BuildContext` (`gw_button.dart`'s 7, `gw_mesh_background.dart`'s 3,
`gw_spinner.dart`'s 1, `banxa_components/order_status_style.dart`'s 2) — these need a
`BuildContext`/`GWColors` parameter threaded in from the nearest caller that does have one, which is
a real (if mechanical once decided) refactor, not a rename. The rest are one-line "no `context`
param declared at this call site, but the enclosing widget's `build` has one a few frames up" cases
— closing them is adding a parameter to a private helper method, not a structural change.

## The six `test/` files that read the legacy palette directly (flagged for 23-04, not touched here)

Per the plan: these are 23-04's problem. 23-04 demotes `GeniusWalletColors`'s public members to
private primitives, and every reference below will stop compiling at that point. Listed now with
the exact member each reads so 23-04 doesn't discover this mid-demotion.

| File | Members read (count) |
|---|---|
| `test/banxa/order_card_test.dart` | `statusWarning` (1) |
| `test/banxa/order_details_card_test.dart` | `statusWarning` (1) |
| `test/dashboard/transaction_filter_rail_test.dart` | `surfaceMenu` (1) |
| `test/theme/nav_chip_style_test.dart` | `brandPrimaryOnSurface` (4) |
| `test/theme/theme_contrast_test.dart` | `borderControl` (1), `brandPrimaryOnSurface` (2), `surfaceBase` (1), `surfaceElevated` (1), `surfaceMenu` (1) |
| `test/tokens/coin_page_components_test.dart` | `brandPrimaryOnSurface` (1) |

13 occurrences total across the six files. Every one is a test asserting a token identity (e.g.
"this widget uses the brand colour"), which is a legitimate primitive-layer read today — these are
not migration candidates for 23-02, they are 23-04's compile-break list.
