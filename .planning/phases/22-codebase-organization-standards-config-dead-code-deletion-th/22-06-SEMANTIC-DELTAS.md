# 22-06 Semantic Deltas

Every change in this plan that is not strictly behaviour-identical, per the plan's
`use_build_context_synchronously` and `avoid_dynamic_calls` acceptance criteria. Nothing in
`unawaited_futures` appears here as a delta (no `await` was added; every site got `unawaited()`),
except where a site looked like it genuinely should be sequenced -- those are called out as Phase 23
candidates below, still wrapped in `unawaited()` for now per the plan's instruction.

## `mounted` / `context.mounted` guards added (`use_build_context_synchronously`, 5 sites)

Each guard's only observable effect is on the path where the widget/State was disposed while an
`await` was in flight -- previously a throw, now a silent skip of the guarded UI-only statement(s).
No guard skips a wallet-affecting network/protocol call; each was placed to protect only the
BuildContext-touching statement, not the surrounding side effects.

| # | File:Line | Awaited operation | Guard form | What it protects | What still runs if unmounted |
|---|---|---|---|---|---|
| 1 | `lib/banxa/banxa_orders_history.dart:53` | `showDateRangePicker(...)` | `if (!context.mounted) { return; }` (added; `context` is a method parameter here) | `setState` for the picked date range + `context.read<OrdersCubit>().applyFilters(...)` | Nothing further in this branch -- the whole `if (picked != null)` body is UI-state-only, so returning early is safe |
| 2 | `lib/network/network_dropdown_selector.dart:73-75` | `ResponsiveDrawer.show<Network>(...)` | `if (!mounted) { return; }` (added; `context` here is `State.context`, a getter -- `context.mounted` alone did not satisfy the analyzer's flow check on a getter-based context, see note below) | `setState`, `widget.onNetworkSelected` callback, `walletCubit.selectNetwork(selected)`, the `ToastManager` toast, and the two `Hive` persistence writes | Nothing -- if unmounted the whole network-switch side effect (including the Hive persist) is skipped. This is a wider skip than a narrowly-scoped guard would give, but the widget being disposed mid-pick means the user navigated away from the selector entirely; the persisted network write is not safety-relevant (no key material), so the wider skip was accepted rather than fragmenting the guard around each statement |
| 3 | `lib/onboarding/new_wallet/view/recovery_phrase_screen.dart:192-194` | `FlutterClipboard.copy(words.join(' '))` | `if (!context.mounted) { return; }` (pre-existing guard used `mounted` bare, checking the **enclosing State's** mounted flag while the actual context in scope was `BlocBuilder`'s own closure-local `context` parameter -- the analyzer correctly flagged this as an unrelated check; changed to `context.mounted` referencing the same local `context` used two lines later) | `ScaffoldMessenger.of(context).showSnackBar(...)` | N/A -- this statement was the only thing in the branch |
| 4 | `lib/reown/reown_connect_button.dart:165-171` | `ApproveDappConnectionDrawer.show(...)` | `if (mounted) { showAppSnackBar(...); }` (added, wrapping only the snackbar) | The "DApp connection was rejected" toast | **`walletKit.rejectSession(...)` still runs unconditionally** -- deliberately NOT gated on `mounted`, because skipping the WalletConnect protocol response would leave the dApp's connection request hanging with no reply. Only the UI toast (which cannot render on a disposed widget regardless) is skipped |
| 5 | `lib/reown/reown_connect_button.dart:418-420` | `_tryPair(Uri.parse(input))` | `if (!mounted) { return; }` (added, placed after `_didManualPair = true;`) | `Navigator.of(context).pop()` on the connect dialog | `_didManualPair = true` is set before the guard, so that bookkeeping happens regardless of mount state; only the dialog-pop navigation is skipped |

### Note on `context.mounted` vs bare `mounted` for `State`-owned context

During this task an inconsistency surfaced in how the analyzer's flow-sensitive check works: when
`context` is a **State's own getter** (re-evaluated on each access, e.g. `_showNetworkDrawer` and the
`reown_connect_button.dart` handler closures), `if (!context.mounted) { return; }` was **not**
recognized by the analyzer as guarding a later `context` use -- it reported "guarded by an unrelated
'mounted' check" even though the guard and the use both read `context`. Switching to the bare
`if (!mounted)` (State's own boolean field) resolved it. Conversely, when `context` is a **local
parameter or closure argument** (e.g. `_pickDateRange(BuildContext context)`, or a `BlocBuilder`'s
`builder: (context, state) => ...`), the analyzer wants `context.mounted`, not bare `mounted` -- using
bare `mounted` there checks the wrong (enclosing State's) object relative to the local context
actually used, and gets flagged as "unrelated" for the opposite reason. The rule applied throughout
this plan: match the guard to whichever `context` binding is actually used at the site --
`context.mounted` when `context` is a local/parameter, bare `mounted` when `context` is `State`'s own
getter.

## `avoid_dynamic_calls` -- parse sites needing deliberate failure-behaviour preservation

See the Task 3 commit for the full retyping; the sites below are the ones that needed active
thought to avoid changing what happens on a malformed payload (all preserved: silent null/empty
fallback, no new throw introduced).

(Filled in as Task 3's dynamic-calls work proceeds -- see commit messages for the final list.)

## Phase 23 candidates (sites that looked like they should be sequenced, left `unawaited()` for now)

(Filled in as Task 3's `unawaited_futures` work proceeds.)
