# Phase 23: Design system consolidation — Context

**Gathered:** 2026-07-28
**Status:** Ready for re-planning
**Supersedes:** the golden-test assumptions baked into the first cut of these plans (written while
Phase 22's 22-07 golden baseline was still expected to exist).

<domain>
## Phase Boundary

Collapse the three competing colour sources into one semantic layer, and extract the genuinely
duplicated components. **No behaviour changes.**

**Out of scope:** state ownership, layering, routing, the `genius_api` split — all Phase 24.
</domain>

<decisions>
## Implementation Decisions

### NO GOLDEN TESTS — locked, 2026-07-28

Braian's decision, stated twice. The `alchemist` install and the no-dependency `matchesGoldenFile`
fallback were **both** declined at 22-07's blocking-human gate. 22-07 is permanently deferred.

**Do not plan any golden/snapshot/pixel-comparison verification.** Do not plan `test/goldens/`.
Do not reference "byte-identical goldens" as an acceptance criterion — no such artifact exists.

### NO NEW TEST INFRASTRUCTURE EITHER — locked

Braian: *"wait we will not add now I just dont want the golden tests."* This is not an invitation to
substitute a different testing framework. Do **not** plan:
- `integration_test` / `patrol` E2E harnesses
- Playwright or any browser-driver approach (also technically wrong for Flutter — it renders to a
  single `<canvas>`, so there are no DOM nodes to select)
- a widget-tree-assertion test framework as new shared infrastructure

Verification must use **what already exists**. Adding ordinary `flutter test` cases in the existing
style, where a specific change genuinely needs one, is fine and expected — that is normal testing,
not new infrastructure. Building a harness is not.

Future E2E is explicitly a *later* topic: Braian mentioned "playwright or the equivalent" as a
someday item for testing changes functionally. The Flutter-native equivalents are `integration_test`
(in-SDK) and `patrol`. Not now.

### What actually proves each workstream, absent goldens

This is the crux of the re-plan. Ranked by strength:

1. **Value equality (strongest).** The colour parity layer can be proven by a unit test asserting
   every token resolves to an identical `Color` in both modes, old path vs new. If parity holds and
   an AST codemod only rewrites the *access path*, the painted result is provably unchanged. This is
   a **stronger** proof than pixel comparison, not a weaker substitute.
2. **Compiler enforcement.** Demoting primitives via `part`/`part of` makes privacy a compile error,
   not a convention. Binary and unfakeable.
3. **Measured WCAG contrast ratios.** For the mode-breaking fixes, which deliberately *change*
   rendering. Goldens were never the right proof here — they would have had to move anyway.
4. **The existing 512-test suite.** Assertion-based. Catches behaviour, not layout.
5. **Live human walks in light AND dark mode.** Load-bearing rather than confirmatory now. Plans that
   rely on this must say so plainly and give the walker a specific, checkable list — not "look at it."

### Where the residual risk actually sits — say this out loud in the plans

Component extraction (the `GWHoverable` / `GWChangePill` / `GWCopyRow` / `GWAppBar` work) is the one
place where nothing above fully substitutes for visual diffing. A 2px padding drift or a slightly
wrong radius in an extracted component **can ship undetected**.

Do not paper over this. Options the planner should weigh explicitly:
- Assert layout values directly in ordinary widget tests (`tester.widget<Padding>(...).padding`)
  where the component's geometry is worth pinning. Ordinary tests, not a framework.
- Extract fewer components — the Rule of Three floor still applies, and a component whose call sites
  are visually divergent is a bad extraction regardless.
- Sequence extraction so each component's call sites are walked immediately after migration, while
  the change is small enough to eyeball.

### Carried forward from the original planning (still valid)

- **Do NOT delete `GeniusWalletColors`** — demote it to the private primitive layer, keep `GWColors`
  semantic. Material 3 primitive→semantic→component model.
- **Rule of Three.** `GWPriceBlock` and `GWStatRail` stay DEFERRED at 2 call sites.
  `GWTimeframeSegment` is a sanctioned exception (character-identical 150-line duplicate) — and the
  plan must **re-diff the two copies at execution time** and refuse if that premise no longer holds.
- **Extract as real `StatelessWidget`s, never `_buildFoo()` helpers.**
- **`GWScreen` is NOT a transparent wrapper** — it imposes scroll, a 1200px cap, centring, padding
  and background. Blanket migration would be a layout change. Per-site adjudication only.
- Use an AST codemod for bulk call-site rewrites, not regex. `Workiva/dart_codemod` was the
  candidate and carries a blocking-human package gate — **note that Braian has now declined two
  package installs in a row, so plan the no-dependency path (a direct `package:analyzer` script) as
  the default and treat the package as the fallback, not the reverse.**
</decisions>

<canonical_refs>
## Canonical References

- `.planning/phases/22-.../22-07-DEFERRED.md` — the golden decision and its consequences
- `.planning/phases/22-.../22-CONTEXT.md` — the standards decisions still in force
- `.planning/phases/22-.../22-RESEARCH.md` — token layering, Rule of Three, codemod tooling
- `.planning/phases/22-.../22-05-SUMMARY.md` — flags 4 files where `const` is now bound to a colour
  constant (`gw_spinner.dart`, `registration_header.dart`, `submit_job_screen.dart`,
  `token_info_screen.dart`). **`const` contexts are a known hazard for the colour migration** — a
  `const` widget holding an old colour will not rebuild.
- `AGENTS.md` — deletion over addition, no unrequested abstractions, the Dart standards section
- `lib/theme/` — `GWColors` (21 fields), `GeniusWalletColors` (~46 members, 288 call sites outside
  `lib/theme/`), `GeniusWalletConsts`, `GWDecorations`, `GWAppearance`
</canonical_refs>

<specifics>
## Specific Ideas

**Verified baseline entering Phase 23** (Phase 22 shipped 2026-07-28):

| Metric | Value |
|---|---|
| `flutter analyze` | **0 issues, exit 0** |
| `flutter test` | **512 pass / 0 fail** |
| `tool/check_brace_style.sh --count` | **0** |
| `dart format --set-exit-if-changed lib test` | exit 0 |
| CI `quality` job | wired and blocking — but **never actually run** (needs a push) |

**Measured colour scope — larger than the original ROADMAP said:**
- `GeniusWalletColors` call sites outside `lib/theme/`: **288**
- Raw colour references outside `lib/theme/`: **525** total
- Of those, the mode-breaking `Colors.white/black/grey` subset: **83**
- Full de-hex of all 525 is **bigger than this phase** — bound it and say what is left uncovered.

**Worst offenders, in order:** `lib/components/toast/toast_widget.dart` (fully inverted light-mode
palette), `lib/components/buttons/gw_button.dart` (design-system component hardcoding
`Colors.white`), `lib/reown/` (74 violations across 6 files).

**A11y regression to fix:** `swap_settings_drawer.dart:286` forks `GWWarningNote` as a private
`_Message`, losing the documented light-mode amber contrast fix at `gw_warning_note.dart:17-21`.

**Extraction call-site counts:** `GWHoverable` 9 · `GWChangePill` 7 · `GWCopyRow` 3 forks + 8 raw
`Clipboard.setData` · `GWAppBar` 7 identical of 17 · `GWTimeframeSegment` 2 (exception).
`GWScreen` exists and is used exactly once while ~28 screens hand-roll `Scaffold`.

**Environment:** Flutter SDK is OFF `PATH` (`C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin`).
`flutter analyze` exits non-zero on infos. A running `genius_wallet.exe` locks the DLL.
</specifics>

<deferred>
## Deferred Ideas

- Golden / snapshot / visual-regression testing of any kind — declined, see above.
- `integration_test` / `patrol` E2E — a later topic, explicitly not this phase.
- `GWPriceBlock`, `GWStatRail` — below the Rule of Three floor.
- Full de-hex of all 525 raw colour references — larger than this phase.
- `very_good_analysis` adoption.
</deferred>

---

*Phase: 23-design-system-consolidation*
*Context gathered: 2026-07-28*
