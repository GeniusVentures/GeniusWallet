---
phase: quick-260720-dty
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dev/dev_tools_bubble.dart
  - lib/test/test_transaction_button.dart          # deleted (orphaned after inline)
  - lib/reown/test/test_swap_buttons.dart          # deleted (orphaned after inline)
  - lib/reown/test/test_buy_buttons.dart           # deleted (orphaned after inline)
autonomous: false
requirements:
  - 260720-dty
user_setup: []

must_haves:
  truths:
    - "Expanded dev bubble shows four collapsible sections — MOCK, TEST FLOWS, NAVIGATE, APPEARANCE — each with a tappable chevron header that toggles its body"
    - "MOCK and APPEARANCE are expanded on first open; TEST FLOWS and NAVIGATE are collapsed on first open"
    - "Every section header, label and button is legible (WCAG AA) on the light gw.surfaceMenu panel AND on dark"
    - "Each existing Test tx / swap / buy action is reachable as one labeled compact button that runs the SAME flow as before (drawer opens / tx injected / toast shows)"
    - "The 4 mock scenario buttons, the Tokens/Gallery pushes, and the light/dark toggle behave exactly as before"
    - "The top drag-handle row, viewport clamp/scroll, and the live-flip ValueListenableBuilder<GWAppearanceMode> wrapper still work"
  artifacts:
    - "lib/dev/dev_tools_bubble.dart (reworked: _Section + _devButton helpers, 4 per-section expand bools, inlined test-flow actions)"
  key_links:
    - "context.read<WalletDetailsCubit>() mock wiring UNCHANGED"
    - "GWAppearance.instance.setMode() appearance toggle UNCHANGED"
    - "inlined test-flow onPressed bodies are byte-equivalent to the deleted Test* widgets' handlers"
---

<objective>
Sectionize the expanded dev-tools bubble into four collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) and make every control legible in BOTH light and dark modes.

Purpose: The current expanded panel is a flat stack of Wraps that (a) is over-populated and hard to scan, and (b) renders the Test tx/swap/buy actions as icon-only buttons hardcoded to `Colors.greenAccent/yellowAccent/redAccent/blueAccent/green`, which are illegible on the light `gw.surfaceMenu` panel. This reorganizes the panel body into tappable collapsible sections and relabels the Test* actions into compact, gw-token-styled TEXT buttons that read in both modes — without changing any mock/test flow behavior.

Output: A reworked `lib/dev/dev_tools_bubble.dart` with a private `_Section` collapsible helper, a `_devButton` helper, four per-section expand bools, and the three now-orphaned `Test*` widget files removed after their flows are inlined verbatim.
</objective>

<context>
@.planning/STATE.md
@lib/dev/dev_tools_bubble.dart
@lib/test/test_transaction_button.dart
@lib/reown/test/test_swap_buttons.dart
@lib/reown/test/test_buy_buttons.dart
@lib/theme/gw_colors.dart
@lib/theme/genius_wallet_colors.dart
@lib/theme/genius_wallet_consts.dart
</context>

<constraints>
- Primary file: `lib/dev/dev_tools_bubble.dart`. Keep changes concentrated there.
- Reuse `GWColors` (Theme extension) / `GeniusWalletColors` status getters / `GeniusWalletConsts` tokens. NO raw hex, NO raw px — use `space*` / `radius*` tokens.
- Do NOT change what any mock or test-flow action DOES. Reuse the exact `onPressed` bodies.
- Do NOT regress: drag handle, viewport clamp/scroll, `ValueListenableBuilder<GWAppearanceMode>` live-flip wrapper, the 4 mock scenario buttons + their `DevMockHoldings`/`WalletDetailsCubit` wiring, the `GWAppearance.instance.setMode()` toggle.
- Dev-gating is already handled at the mount site (`kDebugMode && kShowDevTools`) — no gating change.
- A debug build is ALREADY RUNNING. Do NOT run `flutter build` / `flutter run`. `flutter test` does not compile — do not use it.
- Automated gate: `flutter analyze <changed files>` reports 0 errors. Final acceptance is a human walk in BOTH light and dark.
- Windows env. Explicit-path staging only (README.md is dirty — never `git add -A`). Do NOT commit docs or touch ROADMAP.md.
- OUT OF SCOPE: new mock injectors; the separate top-bar action-widget light-mode regression.
</constraints>

<tasks>

<task type="auto">
  <name>Task 1: Add _Section + _devButton helpers and reorganize the panel body into 4 collapsible sections</name>
  <files>lib/dev/dev_tools_bubble.dart</files>
  <action>
Rework only the expanded-panel body of `_DevToolsBubbleState`. Preserve untouched: the top-level `build()`, `ValueListenableBuilder<GWAppearanceMode>` wrapper, `Positioned`/clamp math, `_dragBy`, `_buildCollapsedBubble`, and the outer `Material > ConstrainedBox > Container(gw.surfaceMenu) > SingleChildScrollView > Column` shell of `_buildExpandedPanel` including the drag-handle Row (drag icon + 'Dev' label + close X).

1. Add four expand-state bools to the State class with these defaults (per D-01): `_mockExpanded = true`, `_testFlowsExpanded = false`, `_navigateExpanded = false`, `_appearanceExpanded = true`.

2. Add a private stateless helper widget `_Section` at the bottom of the file. It takes: a `String label`, a `bool expanded`, a `VoidCallback onToggle`, a `GWColors gw`, and a `List<Widget> children`. It renders a `Column(crossAxisAlignment: start)` of: a tappable header (`InkWell`/`GestureDetector` wrapping a compact `Row`) containing a chevron `Icon` (`Icons.expand_more` when expanded, `Icons.chevron_right` when collapsed) tinted `gw.textSecondary` at size 18, a `space2` gap, and the section `label` as a small uppercase-style `Text` (`gw.textSecondary`, fontSize 12). When `expanded`, render the `children` below the header inside a small top-padded container (use `space2`/`space4` tokens); when collapsed, render only the header. Keep vertical rhythm compact.

3. Add a private helper method `_devButton(String label, VoidCallback onTap, {Color? accent})` returning a compact button (a `TextButton` with tightened `padding`/`visualDensity`, or an `InkWell`+`Container` with `space2`/`space4` padding). Its child is a `Row(mainAxisSize: min)`: if `accent != null`, a small ~8px circular dot `Container` (`BoxDecoration(color: accent, shape: circle)`) + a `space2` gap; then `Text(label, style: TextStyle(color: gw.textPrimary, fontSize: 12))`. The LABEL text ALWAYS uses `gw.textPrimary` (matches the existing Tokens/Gallery/mock pattern) so it stays WCAG AA on both canvases; the `accent` color is only ever the small non-text dot. This keeps text legibility independent of the semantic hue.

4. Replace the flat body (the three Wraps/Row between the drag handle and the panel end) with four `_Section` widgets IN THIS ORDER, wired to `setState` toggles:
   - `_Section('MOCK', _mockExpanded, () => setState toggle, gw, children: [...])` — move the FOUR existing scenario buttons here UNCHANGED: Populated (`loadPopulated`), Long / extreme (`loadExtreme`), Missing icon (`loadMissingIcon`), Clear (`clear` + `clearMock`), each keeping its exact `DevMockHoldings.instance.*` + `context.read<WalletDetailsCubit>().injectMockCoins(...)`/`clearMock()` body. Re-express them as `_devButton(label, onPressed)` (no accent) OR leave as the existing compact TextButtons wrapped in a Wrap — behavior/wiring must be identical.
   - `_Section('TEST FLOWS', _testFlowsExpanded, ..., children: [...])` — for THIS task only, place the existing `const TestTransactionButton()`, `const TestSwapButtons()`, `const TestBuyButtons()` inside a `Wrap` here so the file stays compiling and analyze-clean. (Task 2 replaces this section's contents and deletes those widgets.)
   - `_Section('NAVIGATE', _navigateExpanded, ..., children: [...])` — the Tokens (`context.push('/dev/token-probe')`) and Gallery (`context.push('/design_gallery')`) buttons, re-expressed via `_devButton`, behavior unchanged.
   - `_Section('APPEARANCE', _appearanceExpanded, ..., children: [...])` — the existing light/dark toggle Row (`GWAppearance.instance.setMode(...)`, icon + 'Light'/'Dark' label) UNCHANGED.

Use `space4` gaps between sections (matching the existing `SizedBox(height: space4)` rhythm). No raw hex/px anywhere — chevron/dot sizes may be literal doubles (18, 8) as they are icon/graphic dimensions, but spacing/radius must use `GeniusWalletConsts` tokens.
  </action>
  <verify>
    <automated>flutter analyze lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>Analyze reports 0 errors. Expanded panel renders four `_Section`s (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) with chevron headers; MOCK/APPEARANCE default-open, TEST FLOWS/NAVIGATE default-closed; toggling a header flips its bool via setState. Drag handle, clamp/scroll, ValueListenableBuilder wrapper, mock wiring, and appearance toggle are byte-for-byte behavior-preserved.</done>
</task>

<task type="auto">
  <name>Task 2: Inline the Test tx/swap/buy flows as legible gw-styled buttons and delete the orphaned Test* widgets</name>
  <files>lib/dev/dev_tools_bubble.dart, lib/test/test_transaction_button.dart, lib/reown/test/test_swap_buttons.dart, lib/reown/test/test_buy_buttons.dart</files>
  <action>
Replace the TEST FLOWS section's temporary `Test*` widgets (from Task 1) with inlined `_devButton` calls, one per existing action, reusing each action's EXACT handler body. Map every action found in the three source widgets (do NOT drop or merge any):

- From TestTransactionButton: **Add tx** → the `getSGNUSTransactionsController()` + `getFakeTransaction(true)` + `addTransaction(fakeTx)` + `ToastManager.instance.showToast(...success...)` body. accent = `GeniusWalletColors.statusSuccess`.
- From TestSwapButtons (6):
  - **Approve conn** → `ApproveDappConnectionDrawer.show(...)` (uniswap args verbatim). accent = `GeniusWalletColors.statusWarning`.
  - **Swap OK** → `SwapResultDrawer.show(isSuccess: true, txHash, coinSymbol 'ETH')`. accent = `statusSuccess`.
  - **Swap fail** → `SwapResultDrawer.show(isSuccess: false, ...)`. accent = `GeniusWalletColors.statusError`.
  - **Approve swap** → `ApproveTransactionDrawer.show(... const SendTransactionDetails(...) ...)` verbatim. accent = `GeniusWalletColors.statusInfo`.
  - **Swap success** → `SwapSuccessDrawer.show(context, fromAmount/toAmount/symbols/iconUrls/chain)` verbatim. accent = `statusSuccess`.
  - **Swap failed** → `SwapFailDrawer.show(context, ...)` verbatim. accent = `statusError`.
- From TestBuyButtons (2):
  - **Buy OK** → `BuySuccessDrawer.show(context)`. accent = `statusSuccess`.
  - **Buy fail** → `BuyCancelledDrawer.show(context)`. accent = `statusError`.

Render these as a `Wrap` (spacing/runSpacing = `space2`) of `_devButton(label, onTap, accent: ...)` inside the TEST FLOWS `_Section`. The status accents are the ONLY use of the hue — every label stays `gw.textPrimary` (Task 1's helper), so all read on the light panel; the accent dot is decorative. This is the load-bearing light-mode fix (D-03): no `Colors.*Accent` reaches the panel.

Add the imports the inlined bodies need, copied from the source widgets: the six reown/squid/banxa drawer classes (`approve_dapp_connection_drawer`, `approve_transaction_drawer`, `send_transaction_details`, `swap_result_drawer`, `swap_success_drawer`, `swap_fail_drawer`, `banxa_components/buy_success_drawer`, `banxa_components/buy_cancelled_drawer`), plus `package:genius_api/genius_api.dart` (GeniusApi), `genius_wallet/test/dev_overrides.dart` (getFakeTransaction), and `genius_wallet/components/toast/toast_manager.dart` (ToastManager/ToastType/ToastKind). Remove the now-unused `TestTransactionButton`/`TestSwapButtons`/`TestBuyButtons` imports.

`context.read` note: the bubble already imports `flutter_bloc`, which re-exports provider's `context.read` extension used for `context.read<GeniusApi>()` — do NOT add a separate `package:provider` import unless analyze reports an unresolved `read`; if analyze reports an AMBIGUOUS extension for `read`, hide one via `import '...' hide ReadContext;` or `show`. Let `flutter analyze` arbitrate.

Then delete the three orphaned widget files. First confirm the bubble is their only importer (the grep gate below); once the bubble no longer references them, remove:
`lib/test/test_transaction_button.dart`, `lib/reown/test/test_swap_buttons.dart`, `lib/reown/test/test_buy_buttons.dart`. Deleting them removes the hardcoded `Colors.greenAccent/yellowAccent/redAccent/blueAccent/green` from the tree entirely, completing D-03.

Stage ONLY these four explicit paths (never `git add -A`; README.md is dirty).
  </action>
  <verify>
    <automated>bash -c 'other=$(grep -rl -e test_transaction_button -e test_swap_buttons -e test_buy_buttons lib/ 2>/dev/null); if [ -n "$other" ]; then echo "STILL REFERENCED: $other"; exit 1; fi; for f in lib/test/test_transaction_button.dart lib/reown/test/test_swap_buttons.dart lib/reown/test/test_buy_buttons.dart; do if [ -e "$f" ]; then echo "NOT DELETED: $f"; exit 1; fi; done; if grep -Eq "greenAccent|yellowAccent|redAccent|blueAccent" lib/dev/dev_tools_bubble.dart; then echo "ACCENT COLOR STILL IN BUBBLE"; exit 1; fi; echo OK'</automated>
    <automated>flutter analyze lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>Analyze reports 0 errors. TEST FLOWS section shows one labeled compact button per original action (Add tx, Approve conn, Swap OK, Swap fail, Approve swap, Swap success, Swap failed, Buy OK, Buy fail), each running its original flow via a verbatim handler. No `Colors.*Accent` remains anywhere in `lib/`. The three `Test*` files are deleted and no source references them. Only the four intended paths are staged.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>The dev-tools bubble now opens into four collapsible sections (MOCK, TEST FLOWS, NAVIGATE, APPEARANCE) with tappable chevron headers, and the Test tx/swap/buy actions are compact gw-styled text buttons that read in light mode. The already-running debug build can exercise this without a rebuild if hot-reloaded.</what-built>
  <how-to-verify>
On the running `GW_DEV_TOOLS=true` build (hot-reload if needed — do NOT start a fresh build):
1. Open the dev bubble (tap the bug FAB). Confirm four sections appear: MOCK + APPEARANCE OPEN by default; TEST FLOWS + NAVIGATE COLLAPSED by default.
2. Tap each section header — chevron flips and the body expands/collapses. Toggle all four both ways.
3. Use the APPEARANCE toggle to switch to LIGHT mode. Confirm EVERY section header, every button label, and the drag-handle 'Dev'/close X are clearly legible on the light panel (no near-invisible text, no neon-on-white). Switch back to DARK and confirm the same.
4. In MOCK: run Populated, Long/extreme, Missing icon, Clear — dashboard reacts exactly as before.
5. In NAVIGATE: Tokens opens the token-probe screen; Gallery opens the design gallery.
6. In TEST FLOWS: tap each button (Add tx, Approve conn, Swap OK/fail, Approve swap, Swap success/failed, Buy OK/fail) — each opens the same drawer / injects the tx + toast as before.
7. Confirm the bubble still DRAGS and stays clamped within the viewport (below the header, no edge overflow) in both collapsed and expanded states.
  </how-to-verify>
  <resume-signal>Type "approved" (both modes legible, all sections + flows working) or describe issues.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| (none new) | Dev-only widget, gated by `kDebugMode && kShowDevTools`; renders in debug builds only, takes no external/network input, ships nothing to production. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-dty-01 | Information Disclosure | dev-tools bubble leaking into a release build | low | accept | Mount site remains gated by `kDebugMode && kShowDevTools`; this plan changes no gating. No new packages installed (no supply-chain vector). |
</threat_model>

<verification>
- `flutter analyze lib/dev/dev_tools_bubble.dart` → 0 errors after each task.
- Grep gate: no `Colors.*Accent` in `lib/dev/dev_tools_bubble.dart`; the three `Test*` files deleted and unreferenced across `lib/`.
- Human walk (Task 3): four collapsible sections with correct default open/closed state; all controls legible in BOTH light and dark; all mock/test/nav/appearance behaviors preserved; drag + clamp/scroll intact.
</verification>

<success_criteria>
- Expanded bubble body is four tappable collapsible sections in order MOCK, TEST FLOWS, NAVIGATE, APPEARANCE with the D-01 default states.
- Every Test tx/swap/buy action is a labeled compact `_devButton` running its original flow verbatim; no hardcoded accent colors remain.
- All controls pass a human legibility check in both modes; no behavior regressions to mock wiring, appearance toggle, drag, or clamp/scroll.
- `flutter analyze` clean; only the four intended paths staged.
</success_criteria>

<output>
Human-verify walk is the final acceptance. Record the outcome via the quick-task workflow; do NOT commit docs or update ROADMAP.md.
</output>
