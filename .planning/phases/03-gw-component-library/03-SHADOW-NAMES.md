# Phase 3 — Shadow Class Names

This document records the phase's central hazard: three files this phase's later plans add
declare a public class whose **name** already exists on develop, at a **different path**. No
compile error and no `flutter analyze` warning results, because Dart resolves imports by path,
not by class name — so a repointed import silently swaps one widget for another. The UI-SPEC
(`03-UI-SPEC.md` §2.4) documents one of these three pairs (`Loading`). The other two
(`Splash`, `WalletsOverview`/`WalletsOverviewState`) are not in the UI-SPEC and are recorded
here for the first time — this document extends the UI-SPEC's coverage, it is not a subset of
it.

`tool/verify_additive_boundary.sh` is the mechanical guard built to enforce the binding rule
below. It exists **before** any of the three shadow files land (this plan, 03-01, is wave 1 —
it gates every later plan in the phase), and it must be re-run by every plan that touches
`lib/components/`, `lib/screens/splash.dart`, `lib/navigation/router.dart`, or
`lib/dashboard/home/view/dashboard_screen.dart`.

## The three shadow pairs

| Shadow class | New path (a later plan in this phase adds it) | Canonical path (develop has today) | Canonical importers (verified on the working tree, 2026-07-16) | Why it matters |
|---|---|---|---|---|
| `Loading` | `lib/components/loading/loading.dart` | `lib/components/loading.dart` | **19 files** (see list below; updated by plan 03-06 -- see note) | Both are `StatelessWidget` with an identical `{String? text}` constructor. Alex's uses Phase 2 tokens (`GeniusWalletColors.brandGreen`, `GeniusWalletConsts.space8`, `GeniusWalletTypography.headlineLg`); develop's uses raw values (`lightGreenPrimary`, a default `TextStyle`). A repointed import compiles cleanly and silently re-skins a loading state anywhere in the app. Detonates in Phases 5/6/9, not here. |
| `Splash` | `lib/components/splash.dart` | `lib/screens/splash.dart` | **1 file**: `lib/navigation/router.dart:30` | Develop's `Splash` is a `StatelessWidget`; Alex's is a `StatefulWidget`. The single importer is the **splash route** — i.e. the app's boot path. Alex deleted `screens/splash.dart` on his branch entirely (`git show origin/ui-redesign-3.514:lib/screens/splash.dart` fails — path does not exist there), so his source presents the shadow as a finished move. A later phase "finishing the move" would swap the startup screen without any diagnostic. |
| `WalletsOverview`, `WalletsOverviewState` | `lib/components/wallets_overview.g.dart` | `lib/components/wallet_overview.dart` | **1 file**: `lib/dashboard/home/view/dashboard_screen.dart:19` | **The most dangerous of the three.** Filenames differ by one letter (`wallets_overview.g.dart` vs `wallet_overview.dart`). The shadow is a `.g.dart` file, so `flutter analyze` is configured blind to it (`analysis_options.yaml:5` excludes `lib/**/*.g.dart`). The canonical file is GAP-06 — Phase 5 will re-skin `wallet_overview.dart` on the dashboard, which is exactly the phase most likely to repoint the import while doing so. The shadow is orphaned dead code even on Alex's own source branch (no importer anywhere in `origin/ui-redesign-3.514`'s `lib/`) — it must never gain a real importer other than plan 03-04's compile canary. |

**Loading's 19 canonical importers** (`grep -rl "package:genius_wallet/components/loading.dart" lib/`, sorted):
`lib/banxa/banxa_orders_history.dart`, `lib/banxa/banxa_payment.dart`, `lib/banxa/checkout_qr.dart`,
`lib/banxa/user_kyc/kyc_registration.dart`, `lib/components/coins/view/coins_screen.dart`,
`lib/components/custom_future_builder.dart`, `lib/components/sgnus/sgnus_connection_widget.dart`,
`lib/components/splash.dart`, `lib/dashboard/chart/markets_search_bar.dart`,
`lib/dashboard/news/view/crypto_news_screen.dart`,
`lib/onboarding/existing_wallet/view/import_security_screen.dart`,
`lib/onboarding/new_wallet/view/recovery_phrase_screen.dart`, `lib/onboarding/routes/wallet_routes.dart`,
`lib/screens/banxa_buy_screen.dart`, `lib/screens/loading_screen.dart`, `lib/screens/splash.dart`,
`lib/squid_router/swap_screen.dart`, `lib/submit_job/view/submit_job_screen.dart`, `lib/web/web_view_windows.dart`.

**Note (plan 03-06):** `lib/components/splash.dart` (the `Splash` shadow, this same table) is
itself a NEW importer of the canonical `Loading`, added when the plan ported `Splash` verbatim.
The reference source imports the `Loading` SHADOW there, which is disallowed (`Loading`'s shadow
path's only permitted importer is `design_gallery_screen.dart`) — so the import was repointed to
the canonical `Loading` instead, which declares an identical `{String? text}` constructor, making
the `const Loading()` call site unchanged. `tool/verify_additive_boundary.sh`'s
`LOADING_CANONICAL_EXPECTED` list and this document were updated in the same commit. See
`03-06-SUMMARY.md` for the full deviation writeup.

## Derivation

The census of the 50 in-scope files came from the same three-way diff `03-UI-SPEC.md` §1.1
establishes:

```
git diff --diff-filter=A --name-only develop..origin/ui-redesign-3.514 -- lib/components/
```

(60 additive files under `lib/components/`, filtered to the 50 in-scope files per UI-SPEC §1.2 —
minus the 9 nav-shell files and `buttons/gw_ai_fab.dart`). For each declared public class name
in that set, `grep -rlE "^(abstract )?class <Name>\b" lib/` was run against develop to find any
existing file declaring the same name at a different path. That mechanical scan found the three
pairs / four class names above — verified independently this session, not copied from a prior
draft:

```
$ git show develop:lib/components/loading.dart | head -6      # class Loading extends StatelessWidget
$ grep -rl "package:genius_wallet/components/loading.dart" lib/ | wc -l   # 18
$ git show develop:lib/screens/splash.dart | grep '^class'    # class Splash extends StatelessWidget
$ grep -rl "package:genius_wallet/screens/splash.dart" lib/   # lib/navigation/router.dart (only)
$ git show origin/ui-redesign-3.514:lib/components/splash.dart | grep -A2 '^class'  # class Splash extends StatefulWidget
$ git show origin/ui-redesign-3.514:lib/screens/splash.dart   # fatal: path does not exist -- confirms the delete
$ git show develop:lib/components/wallet_overview.dart | grep '^class'   # WalletsOverview, WalletsOverviewState
$ git show origin/ui-redesign-3.514:lib/components/wallets_overview.g.dart | grep '^class'  # same two names
$ grep -rl "package:genius_wallet/components/wallet_overview.dart" lib/  # lib/dashboard/home/view/dashboard_screen.dart (only)
```

## Binding rule

**The canonical path wins for every existing caller.** No plan in this phase (or any later
phase) may repoint an existing import from a canonical path to a shadow path as an incidental
edit. Migrating a caller from the canonical path to the (re-skinned, token-driven) shadow is a
deliberate act that must update `tool/shadow-baseline.txt` and this document in the same commit,
with a stated reason — it is not something a later phase's diff should do silently while
touching an unrelated part of the same file.

Until such a deliberate migration happens, each shadow path's only permitted importer is:
- `lib/dev/design_gallery_screen.dart`, for `Loading` and `Splash` (plan 03-09 demos both in the
  gallery as inspectable, unconsumed primitives).
- Nothing, for `wallets_overview.g.dart` — it is dead code preserved for completeness, with one
  narrow exception: plan 03-04's compile canary, `lib/dev/generated_closure_canary.dart`, which
  imports every `.g.dart` file in the set by design (to prove the generated files at least
  compile). If plan 03-04 lands the canary at a different path, `tool/verify_additive_boundary.sh`'s
  `WalletsOverview` allowlist must be updated in that same commit.

## The 4 pre-existing legitimate duplicates (not hazards)

`tool/verify_additive_boundary.sh` Check 2 is a **generic** gate — it re-derives the full set of
duplicated public class names across `lib/` from the working tree every time it runs, and
asserts that set is a subset of a captured baseline (`tool/shadow-baseline.txt`), rather than
hardcoding "these three pairs" as the only thing it looks for. That distinction matters because
**develop's duplicate-class census is not empty today**, before this phase touches anything:

```
$ grep -rhoE "^class [A-Za-z_][A-Za-z0-9_]*" lib/ --include=*.dart | awk '{print $2}' | sort | uniq -d
GoBack
PinConfirmFailed
PinConfirmPassed
PinCreated
```

Each is a **deliberate parallel bloc event**, declared once per onboarding bloc — verified by
direct inspection, not assumed:

- `lib/onboarding/existing_wallet/bloc/existing_wallet_event.dart`: `class PinCreated extends
  ExistingWalletEvent {` (:35), `PinConfirmPassed` (:41), `PinConfirmFailed` (:43), `GoBack`
  (:51).
- `lib/onboarding/new_wallet/bloc/new_wallet_event.dart`: `class PinCreated extends
  NewWalletEvent {}` (:39), `PinConfirmPassed` (:41), `PinConfirmFailed` (:43), `GoBack` (:45).

**These are not hazards and must not be "fixed" or consolidated.** A shadow is dangerous when
two same-named classes are substitutable at the same call site — an import of one could be
silently repointed to the other and still compile, still type-check, and still "work" in the
sense that nothing crashes. These four are not substitutable: different supertypes
(`ExistingWalletEvent` vs `NewWalletEvent`), different files, never imported together in the
same file. A caller in the existing-wallet bloc can only ever mean the existing-wallet event; the
ambiguity that makes `Loading`/`Splash`/`WalletsOverview` dangerous does not exist here. Record
this reasoning here so the next reader does not delete them to make a duplicate-count look
tidy — the baseline exists precisely so that "add it to the baseline" always comes with a
justification a reviewer can check, not so duplicates in general are assumed fine.

**The baseline was derived by running the census against the tree, not by copying the four
names above from a prior draft of this plan** — the derivation command was re-run this session
and returned exactly these four, matching the plan's stated expectation with no surprises.

## Scope honesty — this guard is run-on-demand, not CI-enforced

This repo has no pre-commit hooks. Its only CI workflow, `.github/workflows/build.yml`, is a
build matrix that does not run `flutter analyze` or any other check step. `tool/verify_additive_boundary.sh`
is a script a human or an executor must deliberately run — it does not fire automatically on
commit or push. Every plan in this phase runs it as part of its own `<verify>` block, and plan
03-10 records its final state at the end of the phase. Wiring it into CI is a real option for a
future phase or a standalone infrastructure decision — it is out of this phase's scope, and this
document states that plainly rather than implying the gate is automatic.

## Guard proof (this plan, 03-01)

`tool/verify_additive_boundary.sh` was proven in both directions against the real tree before
this plan's commit:

1. **Exits 0 on the untouched tree today** — before any of the phase's 50 component files land,
   with develop's 4 pre-existing bloc-event duplicates present. This is the half that must hold
   or the guard gets disabled by whoever hits it first, and then a real shadow-name collision
   walks straight through an assertion everyone believes is covering them (see the plan's
   `<threat_model>` T-03-39).
2. **Exits non-zero** both (a) when `lib/navigation/router.dart`'s canonical `screens/splash.dart`
   import is repointed to the shadow `components/splash.dart` path, and (b) when a 5th,
   unforeseen duplicate class (`CanaryDup`) is introduced via a planted `.g.dart` probe file —
   deliberately chosen because the analyzer is configured blind to `.g.dart`, so this is the one
   case only this guard can catch.

Both probes were fully removed afterward; `git status --porcelain lib/` was confirmed empty
before this plan's tasks were committed.
