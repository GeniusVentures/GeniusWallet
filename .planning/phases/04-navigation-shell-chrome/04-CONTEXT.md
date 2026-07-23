# Phase 4: Navigation shell & chrome - Context

**Gathered:** 2026-07-17
**Status:** Ready for planning

<domain>
## Phase Boundary

The frame every screen mounts into wears the redesign and survives startup. This phase re-skins the
navigation shell (desktop rail + mobile bottom nav), wires the appearance-aware `theme.dart` that all
screens inherit from, and re-skins Settings + the SDK account manager (GAP-02, GAP-03). It carries
develop's wallet behaviors intact (findings 2/4/5/23/35) and the `7a63b4f` `!_dirty` startup-crash
guard, and it renders a branded build-time-exception recovery screen (findings 11/12).

**Locked by roadmap + milestone rules — NOT open for discussion:**
- Re-skin, never restructure: nav items, routes, and ordering stay exactly as develop has them.
- Take Alex's visual, never his behavior: `theme.dart` is pure visual and adoptable; his wallet-logic
  stubs are not (his `responsive_drawer.dart` is a regression — do NOT port it).
- Carry `7a63b4f`; preserve develop's wallet behaviors.

</domain>

<decisions>
## Implementation Decisions

### theme.dart sequencing
- **D-01:** **Plan 04-01 is theme-only.** Its entire scope is wiring the appearance-aware `theme.dart`
  and wrapping `MaterialApp` in a `ValueListenableBuilder<GWAppearanceMode>` (develop currently applies
  `theme: getThemeData()` at `main.dart:294` with NO ValueListenableBuilder, so the theme never rebuilds
  on toggle). No shell or screen re-skin in 04-01. This is the phase's linchpin: it is the fix for the
  8 findings from Phase 3's gallery walk, and every later plan must build on a theme that actually flips.
- **D-02:** **After 04-01, re-walk the gallery** (`/design_gallery`, both modes) and derive the
  dark-only component COUNT that Phase 3 recorded as NOT DERIVABLE. That count and this re-walk are the
  gate before any shell/screen re-skin begins. Only after the theme is proven to flip does 04-02+ start.

### Default appearance
- **D-03:** **First launch follows the OS light/dark setting.** The in-app toggle (`GWAppearance`)
  overrides thereafter and persists (Hive-backed). NOTE the consequence, which is now a hard Phase 4
  constraint: **light mode is a shipping surface from first launch** for any user on a light-set system.
  Therefore any light-mode BUG must be FIXED before Phase 4 closes — it cannot be deferred. (Deliberate
  dark-only DESIGN choices — see D-06 — remain acceptable; the distinction is bug vs design.)
  - *This reverses the default the analyst recommended (dark). Recorded as the user's explicit call
    2026-07-17. It strengthens D-01's theme-first sequencing rather than conflicting with it.*

### Phase 3 loose ends (resolved at the 04-01 re-walk)
- **D-04:** At the 04-01 re-walk, split Phase 3's carried findings BY TYPE:
  - **BUGS → fix in Phase 4** (they ship now, esp. given D-03): the theme-confound residue (5 findings:
    token-row / wallet-card / empty-error text not flipping, button font, icons); `Screen wrappers`
    blank in DARK mode (unexplained, `app_screen_view.dart` is byte-identical so not a port defect — needs
    a real repro); disabled checkbox invisible in dark (root cause unconfirmed; `btnDisabled` is a
    non-appearance-aware `const`).
  - **DESIGN CHOICES → user decides with the walkable gallery in hand:** canvas grain (`if (!isLight)`),
    mesh blobs over a flipping backdrop, `GWSwitch` disabled==off, `GWSwitch` off-thumb near-black in
    light. All four are byte-identical ports of Alex's deliberate choices.
- **D-05:** The 04-01 re-walk is also when the user's **light-mode grain question** (the folded todo)
  finally gets a real answer — with the theme wired and the gallery walkable, most of the 8 findings
  should evaporate, leaving only the genuine design calls to decide.

### Wallet drawer UX (criterion 4)
- **D-06:** **Delete uses a confirmation dialog (destructive).** CONDITIONAL, and the researcher MUST
  resolve the condition before 04-01/the relevant plan: first determine whether develop ALREADY confirms
  wallet deletion.
  - If develop already confirms → this is a pure re-skin of the existing dialog. No rule tension.
  - If develop does NOT confirm → adding one is a **behavior addition**, which normally violates
    "re-skin, never restructure." It is recorded here as the **ONE sanctioned exception for this phase**:
    a deliberate, user-authorized safety guard on an irreversible action, approved 2026-07-17. It must be
    called out explicitly in the plan and SUMMARY, not slipped in as if it were a re-skin.
- **D-07:** All other criterion-4 behaviors (rename, keep-at-least-one guard, deleted-selected re-selects
  another, live drawer row updates while open, "Network Changed" toast on network switch) are develop's
  existing behaviors — preserve and re-skin, do not redesign.

### Scope boundary — GlobalSwapFabHost / BEH-02 7a63b4f carry (resolved 2026-07-17, post-research)
- **D-08:** **`GlobalSwapFabHost` and the `7a63b4f` `!_dirty` carry are DEFERRED out of Phase 4** to the
  phase that actually lands the swap FAB (likely Phase 8 — Swap & bridge). Rationale, from
  04-RESEARCH.md: the file `7a63b4f` patches does not exist on develop (it was one of Phase 3's 9
  excluded nav-shell files), no Phase 4 criterion or the UI-SPEC mentions it, and Alex's version couples
  it to `GWAiFab` (`lib/ai/`, WIRE-02 — out of scope for the whole milestone), so it would not compile
  verbatim and a de-coupled version would be an invention, not a re-skin.
  - **Criterion 1 is SPLIT accordingly:** its general clause — "app starts, reaches the shell, navigates
    every existing `go_router` route with no runtime exception" — REMAINS in Phase 4 and must be walked.
    Its specific `!_dirty`-via-`GlobalSwapFabHost` sub-clause is **N/A for Phase 4** (the component that
    crashes isn't present) and moves with the carry.
  - **BEH-02's `7a63b4f` line re-homes to the swap-FAB phase.** Flag this to the roadmap as a carry-move,
    not a drop — the fix is still owed, just in the phase that introduces the crashing component.
  - The planner MUST NOT scope any `GlobalSwapFabHost` work into a Phase 4 plan.

### Claude's Discretion
- HOW `theme.dart` is reconciled (line-by-line vs adopt-Alex's-wholesale) is a planner/executor call,
  bounded by "take Alex's visual." Alex's `theme.dart` is 309 lines to develop's 276 (~329 changed
  lines) — a heavy-collision file, the milestone's largest single reconcile. Research (04-RESEARCH.md)
  found it drops SIX live develop `ThemeData` sections that must be preserved through the merge, not
  just `floatingLabelBehavior`: `toggleButtonsTheme`, `filledButtonTheme`, `outlinedButtonTheme`,
  `dialogTheme`, `menuTheme`, `dividerTheme`.
- **D-03 (follow-OS) requires a real `gw_appearance.dart` `load()` change**, not just the MaterialApp
  wrap: research found `load()` defaults to dark unconditionally with no OS-brightness branch. 04-01's
  scope includes adding that branch.
- Desktop rail vs mobile bottom-nav breakpoint logic follows develop's existing
  `GeniusBreakpoints.useDesktopOverlay` / `isMobileApp` in the `ShellRoute` builder — no new breakpoint.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### The theme wiring (04-01's core)
- `lib/theme/theme.dart` (develop, 276 lines) — the file being reconciled; currently `ThemeData(brightness: Brightness.dark)` hardcoded, no `textTheme:`, no `toMaterialTextTheme()`.
- `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514\lib\theme\theme.dart` (Alex, 309 lines, READ-ONLY reference) — the appearance-aware target: `getThemeData()` reads `GWAppearance.isLight`, builds light/dark `ColorScheme`, wires `textTheme: GeniusWalletTypography.toMaterialTextTheme()` and `scaffoldBackgroundColor: surfaceBase`. Note its WCAG choice: `onPrimary: textOnBrand` (near-black), not white.
- `lib/main.dart:294` — where `MaterialApp.router(theme: getThemeData())` is applied; must be wrapped in `ValueListenableBuilder<GWAppearanceMode>` on `GWAppearance.instance`.
- `lib/theme/gw_appearance.dart` — the appearance notifier/toggle (Hive-backed).
- `lib/theme/genius_wallet_typography.dart:133` — `toMaterialTextTheme()`, currently referenced nowhere.

### Phase 3 findings this phase resolves
- `.planning/phases/03-gw-component-library/03-VERIFICATION.md` — the 3 PASS / 3 PARTIAL record; its `behavior_unverified_items` enumerate the exact findings D-04 addresses.
- `.planning/phases/03-gw-component-library/03-09-SUMMARY.md` "Walk result (2026-07-17)" — the 8 findings in full, sorted into the theme-confound / design / unexplained buckets.
- `.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md` — the folded light-mode todo (D-05); its "genuinely open after Phase 4" list is the design-choice set for D-04.

### Shell / nav
- `lib/navigation/router.dart` — develop's `ShellRoute` with `MobileOverlay`/`DesktopOverlay`; the `/design_gallery` dev route (revert its gallery `Scaffold` from `surfaceBase` back to `Colors.transparent` once the theme is wired — see the STATE concern).
- `C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514\lib\navigation\router.dart` (READ-ONLY) — Alex's re-skinned shell (~286 changed lines).
- `.planning/phases/03-gw-component-library/03-GAP-INVENTORY.md` — GAP-02/03 treatment decisions for Settings and the SDK account manager (criterion 5).

### Milestone rules
- `.planning/REQUIREMENTS.md` — NAV-01, NAV-02, BEH-02, GAP-02, GAP-03; the re-skin-vs-restructure test (governs the D-06 exception).
- `.planning/reference/REVIEW_FINDINGS_REDESIGN.md` — findings 2, 4, 5, 11, 12, 23, 27, 35 assigned to this phase.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- The full 50-file `gw_*` component library (Phase 3) — inert until now; Phase 4 is where screens
  begin mounting it. Every primitive the GAP surfaces need was confirmed present (03-GAP-INVENTORY §6).
- `GWAppearance.instance` + `ValueListenableBuilder` — the exact live-rebuild mechanism Phase 2's
  `token_probe_screen.dart` and Phase 3's gallery already use; reuse it verbatim for the MaterialApp wrap.

### Established Patterns
- Sequential executors only (Phase 2's index-race lesson). One plan at a time.
- The additive-boundary guard (`tool/verify_additive_boundary.sh`) and shadow allowlist still apply —
  Phase 4 will mount `Loading`/`Splash`/`WalletsOverview` canonicals; watch that the shadow importer
  counts don't drift.
- `flutter analyze` is a gate, never evidence; `.g.dart` files are analyzer-blind (the canary pattern).

### Integration Points
- `main.dart:294` MaterialApp wrap is the single point that makes appearance reactive app-wide.
- `ShellRoute` builder in `router.dart` is where the rail/bottom-nav re-skin lands.

</code_context>

<specifics>
## Specific Ideas

- The user has an active interest in light-mode polish (the grain question that opened 2026-07-17).
  D-05 routes it to a real answer at the 04-01 re-walk rather than deferring indefinitely.
- Analyst recommended dark default; user chose OS-follow (D-03). Recorded as an explicit, informed
  override, not an oversight.

</specifics>

<deferred>
## Deferred Ideas

- **Wiring `tool/verify_additive_boundary.sh` into CI** — noted in 03-VERIFICATION.md as a real option;
  the guard is not currently enforced by any hook or CI step. Not Phase 4 scope; a later
  infrastructure/closeout decision.
- **The two missing gallery sections** (dropdowns, `wallet_type_icon`) from Phase 3 criterion 6 Part B —
  small; fold into whichever Phase 4 plan touches the gallery, or a Phase 3 follow-up. Not a blocker.

### Folded Todos
- **Design system has no light-mode treatment** (`.planning/todos/pending/2026-07-17-design-system-has-no-light-mode-treatment.md`, matched 0.9) — folded into D-04/D-05. Its "genuinely open after Phase 4" list (canvas grain, mesh, switch disabled==off, switch off-thumb) becomes the design-choice set the user decides at the 04-01 re-walk. The todo's core claim — that this was blocked on `theme.dart` — is exactly what 04-01 unblocks.

</deferred>

---

*Phase: 4-navigation-shell-chrome*
*Context gathered: 2026-07-17*
</content>
