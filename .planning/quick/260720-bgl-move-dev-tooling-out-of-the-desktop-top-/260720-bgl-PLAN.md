---
phase: quick-260720-bgl
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/dev/dev_tools_bubble.dart
  - lib/components/overlay/responsive_overlay.dart
autonomous: false
requirements: [QUICK-260720-bgl]
user_setup: []

must_haves:
  truths:
    - "The desktop top bar (`_DesktopTopBar`) holds only real product widgets (network/SDK/account selectors, Reown connect, Buy GNUS) and no longer RenderFlex-overflows at ~1240px."
    - "With GW_DEV_TOOLS=true in a debug build, a small draggable dev bubble is overlaid on the app; it can be dragged to any corner and occupies zero layout space in the chrome under test."
    - "Tapping the collapsed bubble expands a panel exposing Test transaction, Test swap, Test buy, Tokens (→/dev/token-probe), Gallery (→/design_gallery), and a light/dark appearance toggle."
    - "The appearance toggle flips GWAppearance and live-re-skins the whole app (same setMode mechanism the dev Gallery/token-probe use)."
    - "Without GW_DEV_TOOLS (or in release), the bubble is absent everywhere — gated `kDebugMode && kShowDevTools`."
  artifacts:
    - lib/dev/dev_tools_bubble.dart
  key_links:
    - "DesktopOverlay/MobileOverlay body wrapped in a Stack with the gated `DevToolsBubble` as a Positioned/overlaid child."
    - "`DevToolsWidget` removed from `_buildActionRowWidgets` and its import removed from responsive_overlay.dart."
    - "Bubble reads GWColors ThemeExtension + wraps content in ValueListenableBuilder<GWAppearanceMode> so it re-skins live."
---

<objective>
Move the dev affordances out of the top-bar action row (`_buildActionRowWidgets`) into a NEW floating, draggable, dev-only bubble overlaid on top of the app. The dev tooling must occupy ZERO layout space in the chrome under test so `_DesktopTopBar` stops RenderFlex-overflowing at ~1240px and phase-05 dashboard walks are clean.

Purpose: The `DevToolsWidget` Row is prepended to the real action row for BOTH desktop and mobile chrome; at ~1240px it overflows `_DesktopTopBar`'s `Row`, pushing the real action widgets off-screen. Relocating it to an overlaid bubble removes it from layout entirely.

Output: A `DevToolsBubble` widget (collapsed FAB → expanded panel with the same dev actions plus a light/dark appearance toggle), wired into both overlays behind `kDebugMode && kShowDevTools`, with `DevToolsWidget` removed from the action row.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md

@lib/components/overlay/responsive_overlay.dart
@lib/test/dev_tools_widget.dart
@lib/dev/dev_flags.dart
@lib/theme/gw_appearance.dart
@lib/theme/gw_colors.dart
@lib/theme/genius_wallet_consts.dart
</context>

<constraints>
- Do NOT change the behavior of the individual dev buttons (TestTransactionButton / TestSwapButtons / TestBuyButtons) or the Tokens/Gallery `context.push` targets or the appearance mechanism — only relocate and regroup them.
- Reuse the existing appearance API: `GWAppearance.instance.setMode(...)` + `GWAppearance.isLight` (the same one the dev Gallery/token-probe use). Do NOT invent a new appearance mechanism.
- Gate the bubble `kDebugMode && kShowDevTools` at the insertion site so it can NEVER ship in a release build and never appears without GW_DEV_TOOLS.
- Dev-only chrome: keep it lean, but prefer existing tokens (GWColors ThemeExtension fields, GeniusWalletConsts radius/space) over raw hex/px where a token exists.
- OUT OF SCOPE: the separate "top-bar action widgets render black in light mode" re-skin regression — do NOT touch it here.
- Automated gate is `flutter analyze <files>` (0 errors). `flutter test` does NOT compile — do not rely on it.
- Do NOT commit docs artifacts or update ROADMAP.md.
</constraints>

<tasks>

<task type="auto">
  <name>Task 1: Create the draggable dev-only DevToolsBubble overlay widget</name>
  <files>lib/dev/dev_tools_bubble.dart</files>
  <action>
Create a new `DevToolsBubble` StatefulWidget (const default constructor, no params). It renders itself as a `Positioned` child intended to live inside a `Stack` that fills the overlay body, so the caller (Task 2) supplies the Stack.

State: an `Offset _position` (initialise near a corner, e.g. bottom-left-ish inset using GeniusWalletConsts space tokens) and a `bool _expanded` (default false).

Wrap the built content in a `ValueListenableBuilder<GWAppearanceMode>` listening to `GWAppearance.instance` so the bubble re-skins live and the appearance-toggle affordance reflects the current mode (this is the same live-rebuild pattern TokenProbeScreen uses — setMode persists but does not repaint the const subtree on its own). Inside the builder, read appearance-aware tokens via `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` (the 04-02 fail-soft pattern).

Return `Positioned(left: _position.dx, top: _position.dy, child: ...)`.

Collapsed state (`_expanded == false`): a small circular FAB-style bubble — a `GestureDetector` whose `onPanUpdate` updates `_position` by `details.delta` (clamp within `MediaQuery.sizeOf(context)` so it cannot be dragged fully off-screen) and whose `onTap` sets `_expanded = true`. Fill it with `gw.surfaceElevated`, a `gw.borderStrong`/`borderSubtle` border, a circular shape, and a dev glyph (e.g. Icons.developer_mode or Icons.bug_report) tinted `gw.textPrimary`.

Expanded state (`_expanded == true`): a `Material`-wrapped panel (`Container` with `color: gw.surfaceMenu` or `surfaceOverlay`, a `gw.borderSubtle` border, `BorderRadius.circular(GeniusWalletConsts.radius2xl)`, padding from the space scale) containing, top to bottom:
  - A header row that is itself the drag handle: a `GestureDetector` with the same `onPanUpdate` position logic, showing a drag-handle icon + a "Dev" label styled `gw.textSecondary`, and a trailing collapse IconButton (Icons.close / Icons.remove) that sets `_expanded = false`.
  - The reused dev actions, laid out compactly (a Wrap or Column of Rows): `const TestTransactionButton()`, `const TestSwapButtons()`, `const TestBuyButtons()`, a TextButton "Tokens" → `context.push('/dev/token-probe')`, a TextButton "Gallery" → `context.push('/design_gallery')`. Import these from the same paths dev_tools_widget.dart uses (`package:genius_wallet/reown/test/test_buy_buttons.dart`, `.../test_swap_buttons.dart`, `package:genius_wallet/test/test_transaction_button.dart`) — reuse the widgets, do not reimplement them.
  - An appearance toggle row: a labelled control (IconButton with a sun/moon icon, or a SwitchListTile) whose onChanged/onPressed calls `GWAppearance.instance.setMode(GWAppearance.isLight ? GWAppearanceMode.dark : GWAppearanceMode.light)`. Label/icon reflect the current `GWAppearance.isLight`.

Do NOT gate inside this widget — gating is applied at the insertion site in Task 2. Do NOT add any new appearance state; read/write only through `GWAppearance.instance`. Use tokens for colours/radii/spacing; do not hardcode raw hex or arbitrary px where GWColors / GeniusWalletConsts provides a value.
  </action>
  <verify>
    <automated>flutter analyze lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>lib/dev/dev_tools_bubble.dart exists; `flutter analyze` reports 0 errors for it; the widget exposes collapsed(drag+tap-to-expand) and expanded(dev actions + appearance toggle) states, reuses the existing test buttons + Tokens/Gallery push targets, and toggles appearance solely via GWAppearance.instance.setMode.</done>
</task>

<task type="auto">
  <name>Task 2: Wire the bubble into both overlays and remove DevToolsWidget from the action row</name>
  <files>lib/components/overlay/responsive_overlay.dart</files>
  <action>
In lib/components/overlay/responsive_overlay.dart:

1. Remove `DevToolsWidget` from `_buildActionRowWidgets` — delete the `if (kDebugMode && kShowDevTools) const DevToolsWidget(),` entry and its two-line explanatory comment (currently lines 98-100). The helper must return only the real product widgets (NetworkDropdownSelector, SDKAccountManagerButton, AccountDropdownSelector, ReownConnectButton). The "Buy GNUS" ElevatedButton stays where it already is in `_DesktopTopBar`.

2. Remove the now-unused import `import 'package:genius_wallet/test/dev_tools_widget.dart';` (line 15) to avoid an unused-import lint. Do NOT remove the `flutter/foundation.dart` (kDebugMode) or `dev/dev_flags.dart` (kShowDevTools) imports — they are still needed at the new insertion sites. Add `import 'package:genius_wallet/dev/dev_tools_bubble.dart';`.

3. In `DesktopOverlay.build`, wrap the Scaffold `body` in a `Stack` so the bubble overlays the app content:
   - child 0: the existing `BlocBuilder<AppBloc, AppState>(builder: (context, state) => child)`.
   - child 1: `if (kDebugMode && kShowDevTools) const DevToolsBubble()`.

4. In `MobileOverlay.build`, wrap the Scaffold `body: child` in a `Stack`:
   - child 0: the existing `child`.
   - child 1: `if (kDebugMode && kShowDevTools) const DevToolsBubble()`.

Leave lib/test/dev_tools_widget.dart in place (it remains analyze-clean and its child buttons are reused directly by the bubble via their own imports; deleting it is out of this lean scope). Do NOT alter the appearance-black-in-light-mode behaviour of the real action widgets — that is a separate todo.
  </action>
  <verify>
    <automated>flutter analyze lib/components/overlay/responsive_overlay.dart lib/dev/dev_tools_bubble.dart</automated>
  </verify>
  <done>`_buildActionRowWidgets` returns only the real product widgets; the dev_tools_widget.dart import is gone and dev_tools_bubble.dart is imported; both DesktopOverlay and MobileOverlay overlay a `const DevToolsBubble()` behind `kDebugMode && kShowDevTools`; `flutter analyze` on both files reports 0 errors.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>DevToolsWidget removed from the top-bar action row; dev affordances relocated to a draggable, dev-only overflow bubble overlaid on both desktop and mobile overlays, gated kDebugMode && kShowDevTools, with a light/dark appearance toggle.</what-built>
  <how-to-verify>
1. Run a debug build with the dev flag: `flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true`.
2. Resize the window across ~1240px width — confirm the top bar shows ONLY the real action widgets (network/SDK/account selectors, Reown connect, Buy GNUS) and no RenderFlex overflow stripes; the real widgets stay on-screen.
3. Confirm a small dev bubble is overlaid on the app. Drag it to a different corner — it should move and stay where dropped, without affecting page layout.
4. Tap the bubble — a panel expands with: Test transaction, Test swap, Test buy, Tokens, Gallery, and a light/dark appearance toggle.
5. Tap Tokens → lands on /dev/token-probe; back, tap Gallery → lands on /design_gallery. Confirm Test transaction/swap/buy still behave as before.
6. Flip the appearance toggle — the whole app re-skins light↔dark live, and the bubble itself re-skins too.
7. (Optional) Run once WITHOUT `--dart-define=GW_DEV_TOOLS=true` — confirm no bubble appears anywhere.
  </how-to-verify>
  <resume-signal>Type "approved" or describe issues (overflow still present, bubble not draggable, an action broken, toggle doesn't flip, or bubble visible without the flag).</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| build-mode → shipped binary | Dev affordances must never cross into a release build. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-bgl-01 | Elevation of Privilege | DevToolsBubble insertion sites in DesktopOverlay/MobileOverlay | medium | mitigate | Gate every insertion `kDebugMode && kShowDevTools`; `kShowDevTools` is `bool.fromEnvironment('GW_DEV_TOOLS')` (default false) and `kDebugMode` strips the branch in release — the bubble (and its test-transaction/mock affordances) can never render in a shipped build. |
</threat_model>

<verification>
- `flutter analyze lib/dev/dev_tools_bubble.dart lib/components/overlay/responsive_overlay.dart` → 0 errors.
- Human walk (checkpoint above): no top-bar overflow, bubble draggable, all dev actions reachable, appearance toggle live-flips, bubble absent without GW_DEV_TOOLS.
</verification>

<success_criteria>
- Dev affordances occupy zero layout space in the chrome under test; `_DesktopTopBar` no longer overflows at ~1240px.
- Draggable dev-only bubble exposes the same dev actions plus a light/dark appearance toggle, gated kDebugMode && kShowDevTools.
- Individual dev button behaviour and the appearance mechanism are unchanged — only relocated/regrouped.
</success_criteria>

<output>
Commit code changes with atomic messages. Do NOT commit docs artifacts or update ROADMAP.md.
</output>
