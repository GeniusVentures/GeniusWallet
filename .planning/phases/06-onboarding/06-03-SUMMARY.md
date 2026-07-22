---
phase: 06-onboarding
plan: 03
subsystem: ui
tags: [flutter, onboarding, seed-phrase, key-safety, gw_button, gw_decorations, freeze-rule, responsive, walked-dark-only]

# Dependency graph
requires:
  - phase: 06-onboarding
    plan: 02
    provides: "The space8-outside-ConstrainedBox gutter pattern, and the walk discipline of confirming routing/behaviour rather than appearance alone"
  - phase: 03-gw-component-library
    provides: "GWButton, GWDecorations.surface, GWColors extension"
provides:
  - "Re-skinned recovery_phrase_screen.dart — token typography, GWDecorations.surface grid container, token tile borders, deliberately-kept JetBrainsMono word tiles, token-coloured Copy/hide actions, gradient Continue; read-only display, visible-by-default toggle and the finding-19 mounted guard all preserved and re-verified live"
  - "Re-skinned verify_recovery_phrase_screen.dart — five tile states re-tokenised to brandPrimaryStrong / brandGreen / borderSubtle / surfaceSunken; all word-assignment logic and every snackbar string byte-identical"
  - "Both seed screens made freeze-rule clean — FittedBox removed from both, replaced by discrete breakpoint-stepped typography"
  - "Both seed screens made mobile-safe — page gutter, 2-column grid, full-width CTAs, scrollable content"
affects: [06-04, 06-05, 06-06]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Discrete breakpoint-stepped typography as the sanctioned replacement for FittedBox/AutoSizeText: `(isNarrow ? bodySm : bodyLg).copyWith(...)`. A bounded set of two tokens satisfies the freeze rule; a computed size does not."
    - "Grid density as a discrete function of breakpoint: `crossAxisCount: isNarrow ? 2 : 3` with `childAspectRatio` raised in step so row-count growth does not translate into height growth."
    - "_CopyAndToggleActions — a private layout-only widget taking pre-built buttons, so a responsive Row/Column branch cannot accidentally relocate the copy handler's `mounted` guard out of the State that owns it."

key-files:
  created: []
  modified:
    - lib/onboarding/new_wallet/view/recovery_phrase_screen.dart
    - lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart
    - .planning/todos/pending/2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md

key-decisions:
  - "FittedBox removed from BOTH files as an authorised Rule-1 deviation. The plan (2026-07-21) locks structure; test/freeze_rule_test.dart (2026-07-22) bans FittedBox as one of exactly two continuously-sizing widgets. The plan simply predates the rule. Left in place, walk step 2 — which instructs dragging the window narrow — would have been the freeze repro itself."
  - "The dashboard's fix (fixed style + TextOverflow.ellipsis) was deliberately NOT copied here. Ellipsising a recovery word makes it unreadable, and this is the one screen where that is unacceptable. No ellipsis is set on either grid; the size steps down instead."
  - "ActionChip: KEEP the themed Material default. Judged live during the walk and it reads as part of the design system; the plan's pre-authorised explicit brand override (brandPrimaryStrong alpha-51 fill / 1.5px border) was available and NOT applied."
  - "Verify-screen tiles were left-aligned for consistency with the phrase grid, though only the phrase grid was asked for. Confirmed acceptable in the walk (step 7 offered 'left-aligning the verify tiles looks wrong' as an explicit answer and it was not chosen)."
  - "Screenshot / screen-recording protection: this phase adds NONE and claims none. develop has no secure-window flag on any onboarding screen and this re-skin neither adds nor removes that exposure. Stated plainly rather than implied away — accepted risk T-06-03-06, follow-up owned by 06-06."

requirements-completed: [SCR-02]

coverage:
  - id: D1
    description: "recovery_phrase_screen.dart re-skinned and made mobile-safe, with every §3 security property preserved"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze — 1 info, use_build_context_synchronously, PROVEN pre-existing by stashing the change and re-analyzing HEAD (identical info at :106 before, :193 after)"
        status: pass
      - kind: other
        ref: "plan verify gate: bool _isVisible = true verbatim; `if (!mounted) return;` within 2 lines of FlutterClipboard.copy; JetBrainsMono kept; GWColors read; GWDecorations.surface; no SelectableText/TextFormField/FilledButton/headlineLarge/LayoutBuilder; safety-critical body copy verbatim; check_no_new_key_logging.sh clean"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 walk 2026-07-22 (dark): steps 2,3,4,6 PASS — see Walk Record"
        status: pass
    human_judgment: true
    rationale: "Read-only-ness, the toggle default, and the dismiss-mid-copy race are behavioural properties a grep cannot establish. All three were exercised live."
  - id: D2
    description: "verify_recovery_phrase_screen.dart's five tile states re-tokenised with all assignment logic byte-identical"
    requirement: "SCR-02"
    verification:
      - kind: other
        ref: "flutter analyze — 1 info, SELECT_WORD_COUNT naming, PROVEN pre-existing by the same stash-and-compare method"
        status: pass
      - kind: other
        ref: "plan verify gate: brandPrimaryStrong and brandGreen present, flat brandPrimary absent, JetBrainsMono and ActionChip( kept, 2 GWColors reads, zero raw Colors.*/grayPrimary on non-comment lines, all three snackbar strings and numpadEnter present"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 walk 2026-07-22 (dark): steps 7,8,9,10 PASS — including BOTH validation-failure snackbars"
        status: pass
    human_judgment: true
    rationale: "Whether the five states read as distinct, and whether assign/un-assign/Enter still behave after a colour edit, require a human at the screen."

duration: ~2h (2 auto tasks + walk with 6 walk-driven fix rounds)
completed: 2026-07-22
status: complete
---

# Phase 06 Plan 03: Seed-phrase screens Summary

**Both seed screens re-skinned and walked. All 10 dark-mode walk steps PASS, console clean. Six defects were found BY the walk and fixed during it. Plan CLOSED.**

This is the highest-consequence surface in the milestone — the only place a 12-word recovery phrase exists in plaintext on screen — and the plan carried a 7-entry STRIDE register. Every security property was re-verified against the finished diff and then against the running app, not assumed.

## Security properties — re-read against the FINISHED file, as the plan requires

**§3.2 — `_isVisible` default.** `bool _isVisible = true;` is byte-identical. The phrase is SHOWN on arrival. Confirmed live (walk step 4): visible on arrival, masks to bullets, label flips, words restore.

**§3.4 / finding 19 / ROADMAP criterion 3 — the lifecycle guard.** The finished copy handler, quoted verbatim:

```dart
onPressed: () async {
  await FlutterClipboard.copy(words.join(' '));
  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Recovery phrase copied to clipboard!"),
    ),
  );
},
```

`if (!mounted) return;` still sits between the awaited copy and the `ScaffoldMessenger` call, unmoved. **Grep proves position; the walk proves behaviour.** Walk step 6 ran the actual race — copy, then dismiss before the snackbar settled — and nothing threw. The normal path still confirms and pastes the 12 space-separated words. Both halves required, both passed.

**§3.1 — read-only, under active attack.** Walk step 3 attempted click-drag across the grid, double-click on a word, long-press on a tile, and right-click. **None produced a text selection, selection handle, caret, or copy/paste context menu.** No `SelectableText`, `TextField` or `TextFormField` exists in either file. The Copy button remains the only sanctioned clipboard route.

**§3.3 — no seed in console.** Scanned the full run log across the whole seed sequence (arrive → toggle hide → toggle show → copy → continue → assign four words → submit → both failure paths):

| Scan | Result |
|---|---|
| `NewWalletState(` dumps | **0** |
| `recoveryWords` / `mnemonic` tokens | **0** |
| Bracketed word lists | **0** |
| Bloc transition / `onChange` / `BlocObserver` logging | **0** |
| `EXCEPTION CAUGHT` | **0** |
| `RenderFlex overflowed` | **0** |
| Lifecycle "deactivated widget" / "used after disposed" | **0** |

No `BlocObserver` is registered anywhere in the app and this plan introduced none.

**§3.5 — screenshot / screen-recording exposure.** **This phase adds NO screenshot or screen-recording protection and claims none.** develop has no secure-window flag on any onboarding screen; this re-skin neither adds nor removes that exposure. Accepted risk T-06-03-06, stated plainly. Follow-up owned by 06-06.

## Task 3 Walk Record — 2026-07-22, DARK ONLY

| Step | Result |
|---|---|
| 1 Pre-load / loading state | **not observable** — the phrase loads instantly. Recorded as not-observable, NOT as a pass. |
| 2 All 12 tiles at default + narrow | ✅ after the 2-column fix |
| 3 Read-only under active attack | ✅ no selection by any of four gestures |
| 4 Hide-toggle, visible-by-default | ✅ |
| 5 Console seed scan | ✅ clean (table above) |
| 6 Copy race + normal copy | ✅ both halves |
| 7 Five tile states distinct | ✅ |
| 8 Assign / un-assign / Enter + BOTH error snackbars | ✅ |
| 9 ActionChip judgement | ✅ **keep the themed default** |
| 10 Live appearance flip, both screens | ✅ everything re-skins instantly |

### Deliberately NOT walked

The plan's recipe asks for both appearance modes (its steps 10, 11). **Only dark was walked**, per the app-wide light-mode backlog policy adopted 2026-07-22 — the same call made for 06-02. Step 11's light-mode AA judgement was **not performed and is not recorded as passing**; it belongs to the single dedicated light pass. Step 10 (live flip) still ran, because it tests a mechanism — that no static getter is read where the `GWColors` extension should be — rather than an appearance.

## Deviations from Plan

### 1. [Rule 1 — authorised] FittedBox removed from both files

The plan locks structure (§1) and does not mention `FittedBox`. But `test/freeze_rule_test.dart` bans it as one of exactly two continuously-sizing widgets, and **both target files used `FittedBox(fit: BoxFit.scaleDown)`**. The plan was written 2026-07-21; the freeze rule landed 2026-07-22. They aren't flagged today only because the guard scans dashboard-reachable dirs and onboarding isn't one.

This was not theoretical: **walk step 2 instructs dragging the window narrow — the exact freeze repro.**

Replaced with a discrete breakpoint step, `(isNarrow ? bodySm : bodyLg)` — a bounded set of two tokens. **The dashboard's fix (fixed size + ellipsis) was deliberately not copied**: truncating a recovery word makes it unreadable.

### 2–7. [Rule 1 — walk-driven] Six defects found BY the walk

| # | Defect | Fix |
|---|---|---|
| 2 | Long words clipped at narrow width — the font step alone wasn't enough | Grid drops to **2 columns** below 640px; `childAspectRatio` 3.0→4.5 in step so six rows don't grow the grid vertically |
| 3 | Copy/Hide buttons **overflowed** instead of wrapping | Full-width stacked on mobile, desktop keeps `spaceBetween`; extracted to `_CopyAndToggleActions` so the branch cannot relocate the `mounted` guard |
| 4 | **No page gutter** — content ran to the window bezel | `Padding(horizontal: space8)` outside the `ConstrainedBox`, both screens — the 06-01 `67e2821` pattern |
| 5 | **Vertical overflow** once the grid went 2-column | `Scrollbar` + `SingleChildScrollView`. develop shipped this screen with no scroll view at all; the verify screen already had one, so this makes the pair consistent |
| 6 | Stacked buttons had **no gap** | `spacing: space4` on the mobile Column |
| 7 | **`Scrollbar` had no `ScrollController`** — threw on every paint | Explicit controller shared with the scroll view, disposed in `dispose()` |

Also: words **left-aligned** in the tile (`Alignment.centerLeft`, padding 4→8), applied to both grids for one visual language.

**Defect 7 is the one worth remembering.** The walker reported "scrolls cleanly" and was correct — scrolling worked. The `Scrollbar` was asserting on every paint attempt (`Scrollbar's ScrollController has no ScrollPosition attached`) because `PrimaryScrollController` is not attached on desktop for a vertical ScrollView. **Only the console showed it.** A walk that trusts the screen alone would have shipped it.

## Corrections made to existing planning docs

`2026-07-21-systemic-mobile-gutter-missing-on-onboarding-breakpoint-cons.md` left an open question about these two screens — they were breakpoint-constrained but had *some* inset, so it said they "need a per-screen check rather than assuming either way." **The check was done: they needed the fix.** Their inset was inner-widget padding (`EdgeInsets.all(8.0)` on the grid, `horizontal: 4.0` on tiles), which never reaches the page edge.

That todo also listed both files under `existing_wallet/`; they live under `new_wallet/`. **A grep driven by the recorded paths would have found nothing and wrongly concluded they were clean.** Both corrected.

Still open from that todo: `import_security_screen.dart` (06-04) and `pin_screen.dart` (06-05).

## Baselines

- `flutter analyze lib` = **61**, exactly the project baseline. Both per-file infos proven pre-existing by stashing the changes and re-analyzing HEAD — not assumed.
- `flutter test --concurrency=1` = **222 passing / 1 failing**, the documented baseline. The failure is `local_wallet_storage_test.dart`, entirely commented out, failing at load. Pre-existing.
- `test/freeze_rule_test.dart` passes.
- Both files are now freeze-rule clean: every size input is a discrete literal (2 or 3 columns, 3.0 or 4.5 ratio, 16 or 14 px).

## Next Phase Readiness

**06-04 is next.** ⚠️ **It must be amended before it executes** — `06-04-PLAN.md:99-100` is superseded: the repo has zero IME hardening (grep = 0 matches), and the plan prescribes 2 of the 4 needed flags for 1 of the 3 key-bearing files. `enableIMEPersonalizedLearning` is the one that maps to Android's `IME_FLAG_NO_PERSONALIZED_LEARNING`.

06-04 also owns `import_security_screen.dart`, which still carries the gutter defect — apply the pattern proactively rather than rediscovering it in a fourth walk.

**The wallet-less profile SURVIVED this walk** (`wallet.hive` 0 bytes, zero `SuperGNUSNode.Node.*`) — verification was exercised including its failure paths, but onboarding was never completed through to a created wallet. Verify with step 0 of `.planning/reference/FRESH-INSTALL-RECIPE.md` before relying on it.

---
*Phase: 06-onboarding*
*Completed: 2026-07-22. Tasks 1-2 auto; Task 3 walked dark-only, 10/10 steps PASS, 6 walk-driven fixes landed during the walk.*
