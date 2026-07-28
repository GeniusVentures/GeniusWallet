# Phase 22: Research

**Researched:** 2026-07-28
**Method:** 6 parallel research agents against official docs, pub.dev live data, and published
practitioner writeups. Every claim below carries a source. Items marked ⚠ were flagged by the
researching agent as unverified or contradicted, and are recorded as such rather than smoothed over.

---

## 1. The brace rule cannot be linted. This is settled, not an opinion.

`curly_braces_in_flow_control_structures` **is already enabled** — `flutter_lints 6.0.0` →
`lints/recommended.yaml` → `lints/core.yaml:17` — and a real `flutter analyze` run reports **0**
violations of it.

The rule has a documented carve-out: braces may be omitted when the flow-control statement fits on
one line **and** there is no `else`. All 192 violations in this repo sit exactly inside that
carve-out. The team requirement is therefore strictly stronger than any first-party Dart lint.

**Do not propose "just turn the lint on" — it is on.**

Enforcement options and their 2026 status:
- `custom_lint` (Invertase) — **retired.** README: *"This package is no longer under active
  development… the official `analysis_server_plugin` is now the recommended approach."* Rémi
  Rousselet, issue #379, 2026-02-06: *"I would advise migrating your lints to the official
  solution."* Root cause was version coupling — `custom_lint` 0.8.1 pins `analyzer: ^8.0.0` while
  `analyzer` is now at 14.1.0.
- `analysis_server_plugin` (first-party, `tools.dart.dev`) — the modern path, shipped in Dart 3.10.
  Still lacks user-configurable rules, assists, and the `TypeChecker` utility.
- **CI regex gate — chosen.** Unglamorous and what most teams actually ship.
  ⚠ No authoritative published guidance exists for this pattern in Dart specifically; it is
  widespread folklore, not documented practice.

Sources: [lints/core.yaml](https://github.com/dart-lang/lints) ·
[dart_custom_lint](https://github.com/invertase/dart_custom_lint) ·
[issue #379](https://github.com/invertase/dart_custom_lint/issues/379) ·
[analysis_server_plugin](https://pub.dev/packages/analysis_server_plugin) ·
[dart.dev/tools/analyzer-plugins](https://dart.dev/tools/analyzer-plugins)

---

## 2. Lint rulesets — live comparison (pulled 2026-07-28)

| Package | Maintainer | Latest | Rules | Note |
|---|---|---|---|---|
| `lints` | dart.dev | 6.1.0 | core 34 / recommended 91 | |
| `flutter_lints` | flutter.dev | 6.0.0 (2025-05-27) | **100** | 14 months stale; the *floor* |
| `very_good_analysis` | VGV | **10.3.0** (2026-06-18) | **206** | strict superset, actively maintained |
| `lint` (passsy) | Pascal Welsch | 2.8.0 | 171 | **abandoned** — last commit 2025-02-24 |
| `solid_lints` | Solid Software | 0.3.3 | — | niche, 4.3K downloads |

`flutter_lints` adds only ten Flutter rules over `lints/recommended`. `very_good_analysis` is a
strict superset (+106, zero dropped) and additionally enables `strict-casts`, `strict-inference`,
`strict-raw-types` — arguably worth more than the 106 rules combined.

**Decision taken: stay on `flutter_lints` + targeted additions.** VGA's style group
(`prefer_single_quotes` ~1105 sites, `require_trailing_commas`, `sort_constructors_first`) is pure
churn against this phase's goals. Revisit after the backlog clears.

`dart_code_metrics` is **confirmed discontinued** (frozen at 5.7.6, 2023-07-16). Successor DCM is
commercial; free tier is 1 seat / ≤50k LOC / 100 rules — this repo would fit.
⚠ No good free replacement exists for its unused-code detection.

Sources: [pub.dev](https://pub.dev) live queries · [VGA analysis_options.10.3.0.yaml](https://github.com/VeryGoodOpenSource/very_good_analysis/blob/main/lib/analysis_options.10.3.0.yaml) ·
[dart_code_metrics](https://pub.dev/packages/dart_code_metrics) · [dcm.dev/pricing](https://dcm.dev/pricing/)

---

## 3. CI gates — exact commands, and one critical default

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze lib test
flutter test --coverage
```

**`flutter analyze` already treats infos AND warnings as fatal.** From flutter_tools source:
`argParser.addFlag('fatal-infos', …, defaultsTo: true)` and the same for `fatal-warnings`. This is
the opposite of `dart analyze`, where infos are non-fatal and you need `--fatal-infos`.

*Verified directly in this repo on 2026-07-28: `flutter analyze --no-pub` → **exit code 1**.* One
audit agent reported "exit 0"; that was wrong and was corrected by direct measurement.

Known wart: `--no-fatal-infos` still treats `@Deprecated` as fatal
([flutter#154922](https://github.com/flutter/flutter/issues/154922)) — which is why that CI-rollout
option was rejected, given the theme migration plans to use `@Deprecated`.

`dart format --set-exit-if-changed` is the documented CI idiom, per dart.dev.

**Very Good Ventures' reference workflow** (`very_good_workflows/flutter_package.yml`) runs, in
order: checkout → flutter-action → `very_good packages get --recursive` → format check → analyze →
`bloc lint .` → `very_good test -j 4 --optimization --coverage --min-coverage 100 --report-on lib
--show-uncovered --test-randomize-ordering-seed random`.

Worth stealing regardless of coverage stance: **`--test-randomize-ordering-seed random`** (catches
inter-test state leakage) and **`--report-on lib`** (coverage measured on source, not tests).

**Coverage:** VGV defaults to 100% and publishes the rationale. The counterweight is Google's
60/75/90 framing. The dominant 2026 pattern for an *existing* codebase is patch-coverage gating:

```yaml
coverage:
  status:
    project: { default: { target: auto, threshold: 1% } }   # no regressions
    patch:   { default: { target: 80% } }                    # new code must be tested
```

**Pre-commit hooks:** `lefthook` (Go binary, v2.1.10) is the current cross-language favourite.
⚠ The **pub.dev `lefthook` wrapper is dead and Dart-3-incompatible** — install the Go binary.
Recommended shape is fast-at-commit (`dart format` on staged files) / slow-at-push (analyze + test).
Hooks are locally bypassable via `--no-verify`, so they are convenience; CI is the boundary.

Sources: [dart.dev/tools/dart-format](https://dart.dev/tools/dart-format) ·
[dart.dev/tools/dart-analyze](https://dart.dev/tools/dart-analyze) ·
[flutter_tools analyze.dart](https://raw.githubusercontent.com/flutter/flutter/master/packages/flutter_tools/lib/src/commands/analyze.dart) ·
[very_good_workflows](https://github.com/VeryGoodOpenSource/very_good_workflows) ·
[codecov.yml reference](https://docs.codecov.com/docs/codecovyml-reference)

---

## 4. Design tokens and the colour migration

Official Flutter guidance on design tokens is **thin**: the `ThemeExtension` API docs are complete,
but neither the themes cookbook nor the architecture recommendations mention design tokens or where
a design system should live. Everything past the API contract is community convention.

**Token layering — Material 3's model, which the whole ecosystem copies:** reference/primitive
(raw values, no meaning) → system/semantic (`surface`, `onSurfaceVariant`) → component. Flutter's own
framework implements this in `dev/tools/gen_defaults/`, generating Material defaults from JSON token
files with system tokens prefixed `sys.`.

**This is why `GeniusWalletColors` is demoted, not deleted.** It becomes the primitive layer;
`GWColors` stays semantic. Primitives should be private to the token layer — the value of the split
is lost if screens can import the raw palette.

**`context.gw` is an established pattern, not an anti-pattern.** There is no official position, but
`theme_tailor` generates exactly such accessors, and open Flutter issue
[#160597](https://github.com/flutter/flutter/issues/160597) requests `ThemeExtension.of<T>(context)`
in the framework. The real anti-pattern is *caching* the result in a long-lived object — that leaves
a screen rendering the previous brightness after a mode switch. RydMike's guidance: always provide
fallback values in the accessor so widgets survive a missing extension rather than crashing on `!`.

**No off-the-shelf lint can ban hardcoded colours.** Checked: Dart linter rules — nothing; DCM's 514
rules — nothing; `design_system_lints` has exactly the right rules but is v0.1.3, ~2 years stale,
8 likes, unverified uploader, incomplete pub analysis — **not adoptable**. A CI grep gate is the
practical answer, same conclusion as the brace rule.

**Two footguns — both checked against this repo:**
1. Extensions must be registered on **both** `theme` and `darkTheme`; Flutter does not warn.
   *Not applicable here* — `main.dart:362` sets only `theme:`, swapping the whole `ThemeData` via
   the `GWAppearance` notifier instead. Legitimate alternative approach.
2. `ThemeData.copyWith` **replaces the extensions list wholesale rather than merging**.
   *Verified clean* — `theme.dart:70` sets `extensions:` once, and there is no `ThemeData.copyWith`
   in the file.

**Migration mechanics** (⚠ synthesized — no authoritative published migration guide exists; agent
found only "it's straightforward" assertions):
keep the static class as the primitive layer and make it private → create the extension with
**field-for-field name parity** so call sites change only in prefix → register seeded from the
existing palette so light mode is byte-identical (the no-op de-risking commit) → add the accessor
with a fallback → migrate leaf-first, both accessors live → land the CI gate **last**, scoped to
migrated directories and widened as you go, otherwise it blocks its own migration → delete the old
accessors only when the gate covers `lib/` entirely.

Watch for: stale `const` contexts holding old colours, colours captured in non-widget classes
(controllers, painters built outside `build`).

Sources: [ThemeExtension API](https://api.flutter.dev/flutter/material/ThemeExtension-class.html) ·
[M3 design tokens](https://m3.material.io/foundations/design-tokens) ·
[M3 token update](https://docs.flutter.dev/release/breaking-changes/material-design-3-token-update) ·
[RydMike adaptive theming](https://rydmike.com/blog_adaptive_theming_guide.html) ·
[flutter#160597](https://github.com/flutter/flutter/issues/160597) ·
[design_system_lints](https://pub.dev/packages/design_system_lints)

---

## 5. Component extraction — when NOT to extract

**Rule of Three is the published standard.** Two occurrences do not justify extraction; three do.
Sandi Metz: *"Duplication is far cheaper than the wrong abstraction."*

Concrete stop-signals: you can't name it clearly; the abstraction needs boolean/flag parameters to
serve both callers; you're doing it because "Clean Code." Also noted: LOC is a poor maintainability
metric — a smaller shared library that is wrong is a net loss.

**This directly cut the extraction list.** `GWPriceBlock` and `GWStatRail` (2 sites each) are
deferred. `GWTimeframeSegment` (2 sites) is kept as a named exception because it is a
character-identical 150-line duplicate — there is no abstraction to guess at, only two differing
values.

**Extract as a `StatelessWidget`, not a `_buildFoo()` helper.** A helper method forces the whole
enclosing widget to rebuild; a real widget gets `const` construction, granular rebuilds, correct
disposal, working hot reload, DevTools inspector visibility, and better error messages. This is the
single highest-value mechanical rule for the extraction pass.

Sources: [Rule of Three](https://understandlegacycode.com/blog/refactoring-rule-of-three/) ·
[Flutter Community — helper methods vs separate widgets](https://medium.com/flutter-community/widget-refactoring-in-flutter-helper-methods-vs-separate-widgets-fd0b09c49bc5)

---

## 6. Golden tests as the safety net

Goldens are the published answer for verifying visual equivalence after extraction — they catch
spacing, alignment, and theme drift that assertion-based widget tests cannot see. LeanCode's
enterprise refactoring framework pairs "UI audit & design system" with "implementing golden tests for
visual regression prevention" at the same level.

**`golden_toolkit` is confirmed discontinued** — pub.dev carries the discontinued flag, last release
0.15.0 ~3 years ago, and eBay's 2024-09-12 notice names **no successor**.

**`alchemist` is the de-facto replacement** — 0.14.0, verified publisher Betterment, MIT, built with
VGV. Its decisive feature for this repo: **CI goldens render text as Ahem-font coloured blocks**, so
output is platform-independent and Windows-vs-CI font rendering cannot flake. Platform goldens (real
text) are generated locally, should **not** be committed, and should be disabled in CI.

**Scope discipline:** goldens on design-system *primitives*, not full screens. VGV explicitly warn
that components still in active iteration generate noise rather than signal, so golden generation
should be opt-in per component.

Anti-flake preconditions consistently listed: bundle fonts, pin theme, fixed surface size and
devicePixelRatio, disable animations.

⚠ No first-party Flutter endorsement of any third-party golden package exists; the Alchemist
recommendation is VGV/Betterment/community.

Sources: [alchemist](https://pub.dev/packages/alchemist) ·
[golden_toolkit (discontinued)](https://pub.dev/packages/golden_toolkit) ·
[flutter_glove_box notice](https://github.com/eBay/flutter_glove_box) ·
[LeanCode goldens](https://leancode.co/glossary/golden-tests-in-flutter) ·
[VGV Figma-to-Flutter](https://verygood.ventures/blog/figma-to-flutter-claude-code-skill-golden-tests/)

---

## 7. Automation — what can safely be mechanized

**`dart fix`** applies fixes only where `dart analyze` reports a diagnostic that has an associated
quick-fix. Its real leverage: **enabling a lint retroactively turns it into a bulk rewriter** — turn
on a rule, `dart fix --apply`, commit.

*Measured in this repo, 2026-07-28:* 181 of the 319 outstanding issues are auto-fixable —
`prefer_final_locals` 48, `directives_ordering` 48, `prefer_const_constructors` 47,
`use_super_parameters` 15, plus a tail.

⚠ A research agent claimed `dart fix` has **no `--code` flag**. That is wrong — verified directly:
`dart fix --apply --code=<rule>` works and is printed by `dart fix --dry-run` itself.

**`Workiva/dart_codemod`** (pub: `codemod`) is the right tool for bulk call-site rewrites like
`GeniusWalletColors.foo` → `context.gw.foo` — AST-based via `package:analyzer`, Dart 3 compatible,
with `runInteractiveCodemod()` for per-patch accept/reject. Prefer *unresolved* AST suggestors where
type information isn't needed; resolved-AST tests need `PackageContextForTest` setup.

**`@Deprecated('use X')`** on old APIs is the recommended human-scale complement — the analyzer nags
on every touch instead of a big-bang cutover.

⚠ `fix_data.yaml` (data-driven fixes, which could rewrite renamed APIs automatically) has
**conflicting sources** on whether non-Flutter package authors can use it. Cheap to test
empirically; verify before planning around it.

Sources: [dart.dev/tools/dart-fix](https://dart.dev/tools/dart-fix) ·
[SDK dart-fix.md](https://github.com/dart-lang/sdk/blob/main/pkg/dartdev/doc/dart-fix.md) ·
[Workiva/dart_codemod](https://github.com/Workiva/dart_codemod)

---

## 8. The standards config itself — what the evidence says works

**AGENTS.md** was donated by OpenAI to the Linux Foundation's Agentic AI Foundation (formed
2025-12-09; platinum members include AWS, Anthropic, Google, Microsoft, OpenAI). 60,000+ repos.
⚠ There is **no formal spec** — `agents.md/spec` 404s; the site says *"AGENTS.md is just standard
Markdown."*

**Claude Code does NOT read AGENTS.md natively.** ⚠ agents.md claims it does; Anthropic's own docs
contradict this: *"Claude Code reads `CLAUDE.md`, not `AGENTS.md`."* Trust Anthropic. The prescribed
bridge is a `CLAUDE.md` containing `@AGENTS.md`. On Windows, use the import — symlinks need
Admin/Developer Mode.

*This repo's `CLAUDE.md` contained the bare text `AGENTS.md`, which is not an import and loaded
nothing. Fixed this session.*

**Does markdown actually change behaviour? The strongest study says: only partly.**
ETH Zurich (arXiv 2602.11988, 138 tasks / 12 repos, Claude Code + Codex + Qwen) found context files
**do not generally improve task success** while adding >20% inference cost. LLM-generated files
scored **−0.5% / −2%**; developer-written files **+4%** on one benchmark. Critically, instructions
*were* followed — named tools got used 1.6–2.5× more — the content was simply redundant with what
the agent could already infer. Explicit finding: *"repository overviews, although popular and
recommended by model providers, are not helpful."*
⚠ The abstract and body disagree on whether the +4% developer-written result holds; read it as small
and single-benchmark. ⚠ A conflicting smaller study (arXiv 2601.20404) reports the opposite on cost.

**Mechanical enforcement is the backstop.** ActPlane analyzed 64 repos / 2,116 instruction
statements: 64% are policies, and **74% depend on context that cannot be statically pre-defined**.
Anthropic reaches the same conclusion: CLAUDE.md *"is not a hard enforcement layer"* — hooks and
`permissions.deny` are what the client actually enforces.

**Structure rules** (Anthropic official): under 200 lines per file; markdown headers and bullets, not
paragraphs; specific over vague (*"Use 2-space indentation"* beats *"Format code properly"*); avoid
contradictions because *"Claude may pick one arbitrarily"*; reserve `IMPORTANT`/`YOU MUST` for one
or two rules. The pruning test: *"For each line, ask: Would removing this cause Claude to make
mistakes? If not, cut it."*

**Anti-patterns:** too long; restating what's discoverable (the measured failure mode); LLM-generated
content; contradictions across files; duplication across tool-specific files that then diverge;
staleness.

**Verdict applied:** the markdown moves tooling and command choices; the linter and CI move
invariants. Write the rule once in `AGENTS.md` **and** make it mechanically checkable.

Sources: [agents.md](https://agents.md/) ·
[Claude Code memory](https://code.claude.com/docs/en/memory) ·
[Claude Code best practices](https://code.claude.com/docs/en/best-practices) ·
[arXiv 2602.11988](https://arxiv.org/abs/2602.11988) ·
[arXiv 2606.25189 ActPlane](https://arxiv.org/html/2606.25189v2) ·
[Linux Foundation / AAIF](https://www.linuxfoundation.org/press/linux-foundation-announces-the-formation-of-the-agentic-ai-foundation)

---

## 9. Sequencing — the one thing research changed

LeanCode's 4-Level Flutter Refactoring Framework orders it: **Level 1** lint/format/metrics →
**Level 2** design system + golden tests + codemods → **Level 3** architectural (state management) →
Level 4 beyond. State-management migration is explicitly placed *after* the design system.

**This inverted the draft plan.** The original ordering had component extraction before theme
consolidation. Correct order is **theme first**, so extracted components are born on tokens rather
than needing a second migration pass.

Applies to Phase 23, recorded here so it is not lost: the published triage is that state needed by
exactly one widget is *correctly* `setState`. The audit confirmed hover/press `setState` in this repo
is correct usage — so raw setState counts are an upper bound, not a conversion list.

⚠ There is **no published, numbers-backed case study** of a setState→Cubit migration at ~40k LOC.
The LeanCode framework is the strongest practitioner source; everything else is generic legacy-code
theory or tutorial-grade.

Sources: [LeanCode 4-Level Refactoring Framework](https://leancode.co/blog/flutter-refactoring-framework) ·
[Flutter app architecture](https://docs.flutter.dev/app-architecture)

---

## Validation Architecture

Behaviour preservation is the phase's one hard invariant, and it is checkable at three levels:

1. **Test suite** — `flutter test` must stay at or above 512 passing. After deleting the dead test
   file, the target is **512/0 green**. Any drop is a regression, full stop.
2. **Golden baseline** — Alchemist CI goldens captured *before* the theme and extraction work, and
   re-run after. Expected diff: **zero**. This is the only mechanism that catches spacing, alignment
   and theme drift introduced by extraction.
3. **Analyzer** — `flutter analyze` monotonically decreasing from 319 → 0. Never allowed to rise.

Additional gates specific to this phase:
- `tool/check_brace_style.sh` must report 0 after the auto-fix, and must fail on an injected
  violation (test the gate itself, not just its output — a gate that never fails is not a gate).
- The three existing `tool/*.sh` security gates must pass once wired into CI.
- Light **and** dark mode must both be verified for every touched widget; the repo's history is that
  light mode is where breakage hides.
