---
quick_id: 260721-e3r
subsystem: dashboard-ui
tags: [empty-state, layout, overflow, LayoutBuilder, tokens, GWButton]
status: awaiting-verification
dependency-graph:
  requires:
    - 260720-uhe (LayoutBuilder + isHeightBounded + named-threshold + assert precedent, in crypto_live_chart.dart — copied structurally)
  provides:
    - "GWEmptyState is now adaptive: a shape-aware LayoutBuilder threshold selects a compact layout only when the incoming slot cannot fit the full one — closes the Phase 05 criterion-5 RenderFlex overflow in TransactionsSlimView"
  affects:
    - lib/components/feedback/gw_empty_state.dart
    - Phase 6 onboarding empty/error states (the action-button code path this fix makes safe is currently latent — no call site uses it yet)
tech-stack:
  added: []
  patterns:
    - "Shape-aware adaptive threshold: the compact-mode height threshold is computed per widget instance (base + optional action-block cost) rather than a single fixed constant, so an optional-prop shape (action button) cannot silently under-threshold and produce a false-negative compact selection"
key-files:
  created: []
  modified:
    - lib/components/feedback/gw_empty_state.dart
decisions:
  - "Reused the exact CryptoLiveChart (260720-uhe) precedent shape: LayoutBuilder -> isHeightBounded -> named threshold constant(s) with arithmetic in a comment -> ponytail: comment naming ceilings -> load-bearing constant-relation assert."
  - "Threshold made shape-aware mid-execution (see Deviations): base 192 (title+message) plus _actionBlockHeight (64 = space8 + GWButton md height 48) when actionLabel/onAction are both set, computed as a per-instance local rather than a second static constant, since it depends on the widget's own fields."
  - "Compact mode does NOT shrink the action button itself (GWButton stays at its GWButtonSize.md height, 48px, in both branches) — only the surrounding gap shrinks (space8 -> space4). This is now the honestly-documented remaining ceiling in the ponytail: comment, not silently absorbed into the threshold math."
metrics:
  duration: ~20min
  completed: 2026-07-21
---

# Quick Task 260721-e3r: Fix the GWEmptyState RenderFlex overflow Summary

`GWEmptyState` now wraps its content in a `LayoutBuilder` and switches to a compact layout (space6 padding, 48px icon circle/24px glyph, space4/space2 gaps, title capped at 1 line, message capped at 2 lines) only when its incoming slot is height-bounded and below a threshold — 192px for the title+message shape, or 256px when an action button is also present. Wherever the slot has room (or is unbounded), the widget renders byte-identically to before: 72px circle, 32px glyph, space12 padding, unbounded title/message wrapping. **Task 1 (the `auto` task) is complete; Task 2, the blocking human walk, is OUTSTANDING** — this quick task cannot be marked fully complete until that walk is performed and approved.

## What changed

### Task 1 — `lib/components/feedback/gw_empty_state.dart`

- `build()` now returns `LayoutBuilder(builder: (context, constraints) { ... })` wrapping the existing `Center` (LayoutBuilder sits OUTSIDE `Center`, not between `Center` and `Padding` — layout-neutral, adopts its child's size).
- `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` stays exactly where it was, ABOVE the `LayoutBuilder` — the 04-04 live-appearance-toggle rebuild dependency is preserved.
- New private static consts on the class:
  - `_iconBoxFull = 72`, `_iconGlyphFull = 32` — today's values, extracted from the inline literals.
  - `_iconBoxCompact = 48`, `_iconGlyphCompact = 24`.
  - `_compactHeightThreshold = 192` — the FULL layout's minimum for the tightest title+message shape (space12x2 + 72 + space8 + 24 + space4 + 24 = 192), with the arithmetic written in a source comment.
  - `_compactLayoutHeight = 156` — the WORST-CASE compact height with the message at its bounded 2-line maximum (space6x2 + 48 + space4 + 24 + space2 + 48 = 156).
  - `_actionButtonHeight = 48`, `_actionBlockHeight = space8 + 48 = 64`, `_compactActionBlockHeight = space4 + 48 = 56` — added mid-execution, see Deviations below.
- Inside the builder: `isHeightBounded = constraints.maxHeight != double.infinity`; `hasAction = actionLabel != null && onAction != null`; a per-instance `compactHeightThreshold = _compactHeightThreshold + (hasAction ? _actionBlockHeight : 0)`; `isCompact = isHeightBounded && constraints.maxHeight < compactHeightThreshold`.
- A load-bearing `assert` immediately after, now covering both shapes: `_compactLayoutHeight + (hasAction ? _compactActionBlockHeight : 0) < compactHeightThreshold` — a pure constant/instance-field relation that never reads `constraints`, so it cannot fire from any real window resize, only from a future edit that breaks the design invariant.
- `iconBox`, `iconGlyph`, `outerPadding` (space6/space12), `iconToTitleGap` (space4/space8), `titleToMessageGap` (space2/space4) are all `isCompact ? compact : full` locals; the action-button gap reuses `iconToTitleGap`, matching the plan.
- `Container(width:/height:)`, `Icon(size:)`, the `Padding`, and the two `SizedBox(height:)` all take the derived values (now non-const, as expected).
- Title `Text` gets `maxLines: isCompact ? 1 : null` / `overflow: isCompact ? TextOverflow.ellipsis : null`; message `Text` gets `maxLines: isCompact ? 2 : null` with the same overflow ternary — both resolve to `null` (today's unbounded default) on the full path.
- Structurally untouched: `mainAxisSize: MainAxisSize.min`, `textAlign: TextAlign.center`, `GWDecorations.surfaceSheen`, `gw.borderSubtle`/`gw.textSecondary`, the `if (message != null)` / `if (hasAction)` guards, the `GWButton` branch, and the public constructor (no API change).
- `flutter analyze lib` was run twice (once before, once after the mid-execution deviation) and held at **61 issues, 0 errors** both times.
- `git diff --stat` confirms exactly one file changed: `lib/components/feedback/gw_empty_state.dart`.

Do NOT edit `transactions_slim_view.dart`, `coins_screen.dart`, or `design_gallery_screen.dart` — none were touched. No `LayoutBuilder`-intrinsic-dimensions throw was observed or reported by any call site during this write-and-verify pass (that check is deferred to the human walk, since it can only surface at runtime).

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Made `_compactHeightThreshold` shape-aware to cover the action-button case**

- **Found during:** Task 1, after initial implementation — flagged by the coordinator's diff review, not self-discovered before that review.
- **Issue:** The plan's single fixed `_compactHeightThreshold = 192` is derived for the title+message shape only (space12x2 + 72 circle + space8 + 24 title + space4 + 24 message). `GWEmptyState` also has `actionLabel`/`onAction` in its public API; when set, the full layout additionally renders `SizedBox(iconToTitleGap)` + a `GWButton` (default `GWButtonSize.md`, height read from `gw_button.dart`'s `_height` getter — confirmed 48px, a simple constant, not conditional on anything else relevant here — rather than assumed on the coordinator's say-so). An action-bearing full layout therefore needs roughly 192 + 16 + 48 = 256px, not 192. With the original single-constant threshold, a bounded slot of e.g. 220px satisfies `220 >= 192`, so `isCompact` is **false**, the full layout renders, and it needs 256px — a **36px overflow**. This is a false negative: the guard that exists to prevent exactly this bug class doesn't fire, precisely because the slot is too *big* for an under-scoped threshold. A false negative is strictly worse than the title-only false positive the original `ponytail:` comment already (correctly) documented as harmless. No current call site passes `actionLabel` (verified: `transactions_slim_view.dart:126`, `coins_screen.dart:214`, `design_gallery_screen.dart:757` — none do), so this was **latent, not live** at execution time, but the widget is shared and Phase 6 (onboarding) is about to add empty/error states where an action button ("Create wallet" / "Import") is an obvious, likely addition — exactly the case the original guard would have silently missed. Worth noting: the plan-checker independently verified the 192 arithmetic and it is correct **for the shape it was scoped to**; neither the plan-checker nor the initial implementation cross-checked that arithmetic against the widget's own optional `actionLabel`/`onAction` parameters, which is the actual gap.
- **Fix:** Read `GWButton._height` directly from `gw_button.dart:77-87` and confirmed `GWButtonSize.md` (the default, and the size this widget's `GWButton(...)` call uses with no `size:` override) returns a simple `48`, not derived from anything variable. Added `_actionButtonHeight = 48`, `_actionBlockHeight = space8 + 48 = 64` (full-layout cost — the action gap reuses `iconToTitleGap`, which is space8 when not compact), and `_compactActionBlockHeight = space4 + 48 = 56` (compact-layout cost — same gap reused, but it's space4 when compact; the button itself does NOT shrink). The threshold is now computed per build-instance: `compactHeightThreshold = _compactHeightThreshold + (hasAction ? _actionBlockHeight : 0)`. The `assert` was updated to the corresponding two-shape relation: `_compactLayoutHeight + (hasAction ? _compactActionBlockHeight : 0) < compactHeightThreshold` — verified algebraically: non-action case `156 < 192` (unchanged, holds); action case `156 + 56 = 212 < 192 + 64 = 256` (44px headroom, holds). The `ponytail:` comment was rewritten to drop the stale "no current call site is height-bounded in that band" framing (which was true but no longer the salient risk) and instead name the real remaining ceiling honestly: compact mode does not shrink the action button itself, so an action-bearing empty state below roughly 212px still cannot fit even in compact, and there is no third, button-shrinking tier; the upgrade path now also mentions considering `GWButtonSize.sm` for that tier.
- **Files modified:** `lib/components/feedback/gw_empty_state.dart` (same single file — no scope change).
- **Verification:** `flutter analyze lib` re-run after the fix → still **61 issues, 0 errors** (delta 0). `git diff --stat` still shows exactly one file. Arithmetic re-derived independently against the real token values in `genius_wallet_consts.dart` (space4=8, space6=12, space8=16, space12=24) and the real `GWButton._height` getter in `gw_button.dart` — not taken on trust from the plan or the coordinator's estimate.
- **Committed in:** not committed (per this task's explicit no-commit policy — left in the working tree, uncommitted, for the orchestrator to batch-commit).

---

**Total deviations:** 1 auto-fixed (Rule 1 — a defect in the plan's threshold arithmetic, found during execution via coordinator review, not by the plan or the plan-checker, which had verified the 192 arithmetic correctly for the shape it checked but not against the widget's own optional parameters).
**Impact on plan:** Necessary for correctness — closes a latent false-negative overflow path in a shared widget, ahead of Phase 6 onboarding work that is likely to exercise exactly the action-button shape. No scope creep: same single file, no new tokens, no call-site edits, no public API change.

## Issues Encountered

None beyond the deviation above.

## Verification

- `flutter analyze lib` → **61 issues, 0 errors** — matches the stated baseline exactly, both before and after the threshold fix. Delta: **0**.
- `grep -nE "isHeightBounded|_compactHeightThreshold|_compactLayoutHeight|ponytail:|assert\(" lib/components/feedback/gw_empty_state.dart` → all five present (guard, both original named constants, the ponytail comment, and the assert), plus the new `_actionBlockHeight`/`_compactActionBlockHeight` constants.
- `grep -cE "_iconBoxFull = 72|_iconGlyphFull = 32|GeniusWalletConsts.space12" lib/components/feedback/gw_empty_state.dart` → **3** — the full-size 72/32 values and the `space12` padding token all survive; the non-compact branch still carries today's exact metrics.
- `git diff --stat` → exactly one file changed: `lib/components/feedback/gw_empty_state.dart`.
- `flutter test` was NOT run — it does not compile on this branch (documented project-wide blocker, matches the plan's own verification note); `flutter analyze` and the in-widget `assert` are the gates, not `flutter test`.
- No commits created — nothing staged, nothing committed (per this task's explicit no-commit policy); confirmed via `git status --short`.

## Known Stubs

None. No hardcoded empty values, placeholder text, or unwired data introduced.

## Threat Flags

None. Pure layout/sizing logic inside one shared presentational widget's `build()` — no new network endpoints, auth paths, file access, or schema changes at a trust boundary.

## Self-Check: PASSED

- `lib/components/feedback/gw_empty_state.dart` — FOUND, modified as described (both the plan's original adaptive rewrite and the mid-execution shape-aware-threshold deviation).
- No commits created — nothing staged, nothing committed (verified via `git status --short` and `git diff --stat`).

## Outstanding — Task 2 (blocking human walk), NOT performed

Task 2 is `type="checkpoint:human-verify" gate="blocking"` with `autonomous: false` — per this execution's explicit scope and the coordinator's instructions, it was NOT attempted and is NOT marked complete. The developer must run the walk before this quick task can be considered done, before
`.planning/todos/pending/2026-07-21-gwemptystate-overflows-in-transactions-slim-view.md` can be marked resolved, and before the walk is recorded against Phase 05 criterion 5 in `05-VERIFICATION.md`.

**How to verify** (from the plan, unchanged by the threshold deviation — the action-block fix only affects a currently-unused code path, so the visible walk surface is identical):

Run the Windows debug build with `GW_DEV_TOOLS=true`. Use the dev bubble's **MOCK -> Clear** button to empty the wallet. Then, in **BOTH** appearance modes:

1. **The fix — Transactions panel (the failing case).** Dashboard, empty wallet, default window size: the Transactions panel's "No transactions yet" empty state should show no yellow/black overflow stripes, no clipped text, the full message readable and not ellipsised, and no `RenderFlex overflowed` console line.
2. **Resize to at least two more shapes** — one clearly shorter, one clearly narrower than default — re-checking the console at each; also widen past the 3-column breakpoint and confirm the icon grows back to the large circle there. Watch for the documented pop between full and compact at the boundary (expected, not a bug).
3. **The regression gate — Assets panel and gallery must be UNCHANGED.** The Assets panel ("No coins yet") must stay at full size (72px circle, space12 padding) at every window size, since its slot is derived at 276px against the 192px threshold. The design-gallery demo (unbounded height) must be pixel-identical to before.
4. **Release check** if convenient — release clips silently where debug paints stripes.

If everything reads correctly, mark Task 2 approved and this quick task complete; STATE.md, the quick-tasks table, the pending todo, and `05-VERIFICATION.md` have NOT yet been updated to reflect completion, pending that approval.
