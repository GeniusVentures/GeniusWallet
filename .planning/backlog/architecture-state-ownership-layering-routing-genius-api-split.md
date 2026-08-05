# Backlog: Architecture — state ownership, layering, routing, genius_api split

**Removed from the active roadmap 2026-07-30** at Braian's request ("delete phase 24 entirely for now").
It was Phase 24, depended on Phase 23, had 0 plans and an empty phase directory, so nothing was
executed and nothing is lost by parking it.

**Why this is preserved rather than deleted.** The six plan sketches below carry measured findings —
exact LOC counts, specific file:line sites, and an alignment argument against Flutter's official
architecture guidance. Every line number in it was re-verified against the tree on 2026-07-30 and
still matched (`router.dart` 51 / 199 / 203). Re-deriving this would mean redoing the audit.

**Open questions never settled** (they were about to be discussed when the phase was pulled):

1. **The crypto/key surface boundary** — the entry itself says "consider leaving key derivation and
   signing entirely alone this cycle." Never decided. Highest-stakes question in the phase.
2. **Phase size** — six plans over ~3,800 LOC of zero-test code plus layering, state, routing, a
   1,257-LOC API split and error handling. Phase 22 was planned at 15 plans and split; this likely
   needed splitting too.
3. **`genius_api` split depth** — "no instance variables on the facade" is an aggressive bar. A
   cheaper stop is dropping the `package:flutter/material.dart` import so the data layer stops
   depending on the UI framework.
4. **Pin-the-bug vs fix-the-bug** — 24-01 pins actual behaviour *including bugs*; 24-06 fixes real
   defects. Those two instructions conflict and needed a rule before planning.

**Decisions that already applied to it, carried from earlier phases:** dev-only code gates as
`kDebugMode && kShowDevTools` (`app_bloc.dart:200`, `banxa_order_cubit.dart:25`; `kDebugMode` is
const so the branch tree-shakes); single-widget `setState` is correct usage, so the setState counts
are an upper bound not a conversion list; `bloc`+`provider` coexisting is not a smell — only the
duplicate `GeniusApi` registration is.

**Requirements were never coined** (`Requirements: TBD`). If this returns, coin ARCH-* IDs up front —
phases 22 and 23 both shipped with untracked IDs and ORG-* had to be written retroactively.

---

## Verbatim roadmap entry as removed

### Phase 24: Architecture: state ownership, layering, routing, genius_api split

**Goal:** Bring the app onto Flutter's officially recommended layering (UI → repository → service)
without changing user-visible behaviour, writing the safety net *before* the change in every case.

**Requirements**: TBD
**Depends on:** Phase 23
**Plans:** 0 plans

**Alignment check.** Flutter's official architecture guidance is MVVM but explicitly
package-agnostic — it names `flutter_bloc` as an acceptable choice — so moving state into cubits is
aligned, not a detour. Three official rules map directly onto findings: *"Views… shouldn't contain
any business logic"*, *"the service is a private member, so that the UI layer can't bypass the
repository"*, and single-source-of-truth. Reference implementation: the Compass app in
`flutter/samples`.

**Scope reducer.** The published triage is that state needed by exactly one widget is *correctly*
`setState`. The audit already confirmed hover/press `setState` in this repo is correct usage. So the
raw setState counts below are an upper bound, not a conversion list — triage first.

**⚠ Crypto constraint (applies to every plan in this phase):** never let a private key or mnemonic
become a field on a Cubit state class — bloc states are equatable, printable, and land in
`BlocObserver` logs by default. BIP-39/BIP-32 ship official spec vectors that serve as free,
externally-authoritative characterization tests; pin them before touching anything crypto-adjacent.
Published guidance is to isolate the signing/key surface rather than modernize it — **consider
leaving key derivation and signing entirely alone this cycle.**

Plans:

- [ ] 24-01 Characterization tests first — `lib/onboarding/` (2,415 LOC, zero tests), `lib/reown/`
      (1,374 LOC, zero tests, dApp transaction approval), `lib/hive/`, and the blocs (zero bloc tests
      today). Approval/golden-master style: document *actual* behaviour including existing bugs

- [ ] 24-02 Layering — 16 widgets reaching past the repository directly into Hive/`File`/HTTP/SDK;
      make services private members behind repositories; adopt the official `Result` pattern for the
      services that currently return `null`/empty on failure

- [ ] 24-03 State ownership — triage then lift genuinely-shared state into cubits (`swap_screen` 15
      setStates, `bridge_screen` 11, `settings_screen` 19, `reown_connect_button` 11); resolve dual
      ownership of network state (`NetworkProvider` vs `WalletDetailsCubit`); de-duplicate the
      `GeniusApi` double registration at `main.dart:157` and `:319` (note: bloc+provider coexisting is
      **not** a smell — `flutter_bloc` depends on `provider`, and Flutter officially recommends
      `provider` for DI; the defect is only the duplicate registration)

- [ ] 24-04 Routing — make `redirect` pure (`router.dart:51-71` currently dispatches 5 AppBloc events
      as a bootstrap side effect on every navigation); route-name constants for 16 hardcoded literals;
      typed route extras; **gate the unguarded dev routes at `router.dart:199,203`** (`TokenProbeScreen`
      and `/design_gallery` are reachable in release and the 44 KB gallery is retained by the route
      table). Contrast: `responsive_overlay.dart:483` gates `DevToolsBubble` correctly

- [ ] 24-05 `genius_api` split — 1,257 LOC mixing FFI, secure storage, web3, protobuf, config file IO
      and pricing, and it imports `package:flutter/material.dart` so the data layer depends on the UI
      framework. Split behind the existing class as a facade (cluster methods by which fields they
      touch); done when the facade holds no instance variables. Callers do not change

- [ ] 24-06 Error handling — `AppBloc` has no try/catch and no error state on 6 handlers in its
      critical boot path; the processing timer permanently cancels itself on one transient failure;
      4 empty catch blocks in `web_view_mobile.dart`; 9 `Future`/`StreamBuilder`s with no `hasError`
      branch

---


---

## Deferrals that were pointing at this phase

Phase 23 refused two extractions **specifically because Phase 24 would open the same files**, so the
argument for deferring them died with the phase. Whichever work next opens these files inherits it:

- **`GWAppBar`** — 16 files contain an app bar; the claimed identical subset is seven, measured against
  a golden baseline that no longer exists. Deferred because the payoff is tidiness while the risk spans
  back-behaviour and custom pop guards across seven screens with no visual net. Evidence:
  `23-05-EXTRACTION-AUDIT.md`.
- **The `GWScreen` sweep** — ~28 files hand-roll a scaffold. `GWScreen` is not a transparent wrapper
  (safe area, scroll view, 1200px cap, centring, fixed padding, background), so adopting it on a screen
  that is not already that shape **is** a layout change. Deferred whole; needs a functional test net
  first. Evidence: `23-05-EXTRACTION-AUDIT.md`, `23-06-CLOSEOUT.md`.

Also orphaned: the **unguarded dev routes** (`TokenProbeScreen` and `/design_gallery` at
`lib/navigation/router.dart:199` and `:203`) were scoped into 24-04. They are reachable in release and
the 44 KB gallery is retained by the route table. `23-.../.continue-here.md:153` calls it "a one-line
fix if wanted sooner" — the established pattern is `kDebugMode && kShowDevTools`, as used at
`app_bloc.dart:200`. That one is cheap enough to do outside a phase.
