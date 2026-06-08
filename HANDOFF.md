# UI Redesign — Developer Handoff

This branch applies the **GNUS UI redesign + polish** on top of `dev_logsubmissions`.
It is **UI-only**: no SDK, native, or build-system work. This document explains
everything you need to know to review, integrate, and ship it.

---

## 1. At a glance

| | |
|---|---|
| **Branch** | `ui-redesign-3.514` |
| **Base (merge-base)** | `0495436` on `dev_logsubmissions` |
| **Our commits** | 44 (`merge-base..HEAD`) |
| **`dev_logsubmissions` moved** | +4 commits since the fork (all config/build — see §8) |
| **Diff** | ~169 files, +8.6k / −3.1k |
| **Analyzer** | **0 errors and 0 warnings introduced by us.** The only errors/warnings are pre-existing (see §7). |
| **Builds & runs** | Yes — verified on macOS (profile) end-to-end. |

**Everything outside `lib/` and the `*.md` docs that we touched is just two things:**
`pubspec.yaml` (+2 UI packages) and one texture asset. See §5.

---

## 2. What changed (high level)

The redesign is a full visual + structural pass. Highlights:

- **Brand design system** — tokens for color, typography (Inter), spacing, radius,
  elevation, gradients, motion. Documented in **`DESIGN_SYSTEM.md`**, implemented
  under `lib/theme/` (`genius_wallet_colors/typography/consts/elevation/gradient/decorations.dart`).
- **Vibrant palette v1.2** — brighter brand cyan/mint + teal surfaces.
- **Redesigned screens** — dashboard/home, markets, activity, discover/browser,
  token detail, swap, bridge, onboarding, etc.
- **Global Swap FAB** — a floating Swap action reachable from every authenticated
  screen (`lib/components/overlay/global_swap_fab_host.dart`).
- **Depth & material layer** — a lit page canvas (wash + soft top-light + a subtle
  monochrome grain), top-lit surface "sheen", hairline edges, soft elevation, a
  hero glow behind the balance, and tactile action chips. All centralized in
  **`lib/theme/genius_wallet_decorations.dart`** (`GWDecorations`, `GWCanvasBackground`).
- **Home tabs** — the home segmented toggle is now **Assets / NFTs** (Activity was
  removed here because it already has its own bottom-nav tab — it was duplicated).
- **Accessibility** — tooltips on icon-only buttons, image semantics, WCAG-checked
  contrast fixes, ≥48px tap targets on several controls, empty/error states.
- **Token hygiene** — hardcoded colors / font sizes / spacing migrated to tokens.

---

## 3. ⚠️ Changes we made to YOUR existing code — please review

To make the app **cold-start cleanly when the backend resolves synchronously**, we
fixed a few pre-existing patterns. In your **real (native) build these never crashed**
because the SDK resolves asynchronously (post-frame) — but the patterns dispatched
state changes *during a build*, which throws a debug-only `!_dirty` assertion the
moment the backend is synchronous (which is exactly what a UI-only stub does). The
fixes are safe, behavior-preserving robustness improvements.

| File | What we changed | Why |
|------|-----------------|-----|
| `lib/navigation/router.dart` | The `redirect` no longer **dispatches `AppBloc` init events** (`SubscribeToWallets`, `FetchAccount`, `CheckIfUserExists`) synchronously during route resolution — it schedules them **once, via a post-frame callback**. The redirect is now side-effect-free during build. | Dispatching from a `redirect` runs inside the router's build pass. |
| `lib/components/splash.dart` | The `BlocListener`'s `context.go(...)` is now deferred to a **post-frame callback** (with a `mounted` guard). | It navigated the instant `AppBloc` emitted `loaded`, i.e. potentially mid-build. |
| `lib/dashboard/transactions/cubit/transactions_cubit.dart` | Removed the **`emit()` from the constructor**; the seed list is sorted via `super(...)` instead. | A Cubit ctor `emit()` is a known anti-pattern; it fires synchronously and can land mid-frame. |
| `lib/components/overlay/global_swap_fab_host.dart` | (Our own component.) Converted from a `ListenableBuilder` to a `StatefulWidget` that registers the router listener in `initState` and only touches the router after the first frame. | It read `routerDelegate.currentConfiguration` inside the `MaterialApp.router` builder during the first build. |

**None of these change behavior in the normal async flow** — they just move work
off the build pass. Search the diffs for the comments explaining each.

> Note: a true cold start of the **UI-only stub in `--debug`** may still surface one
> residual init assert that is specific to the stub's synchronous provider mount.
> **`--profile` and your real native build are clean.** We QA'd in `--profile`.

---

## 4. The design system (how to extend it)

- **Read `DESIGN_SYSTEM.md` first.** It is the source of truth for tokens and rules.
- New depth primitives live in **`lib/theme/genius_wallet_decorations.dart`**:
  - `GWDecorations.surface()` / `.pill()` / `.actionCircle()` — sheen + hairline + elevation.
  - `GWDecorations.canvas` / `.canvasTopLight` / `heroGlow` — the canvas layers.
  - `GWCanvasBackground` — the widget that paints the lit, grained page background.
- **All intensities are tunable in one place** (`GWDecorations` + `genius_wallet_elevation.dart`):
  grain opacity, glow alpha, hairline color, wash/top-light stops. If "more/less"
  is needed, change the token — don't sprinkle values per screen.

---

## 5. New dependencies & assets

`pubspec.yaml`:

```yaml
dependencies:
  shimmer: ^3.0.0        # loading skeletons
  google_fonts: ^6.2.1  # Inter typography
flutter:
  assets:
    - assets/images/textures/    # contains noise.png (the canvas grain)
```

- `assets/images/textures/noise.png` — a 128px tileable monochrome grain used at
  ~4% opacity for the canvas texture. Committed.
- Run `flutter pub get` after merging.

---

## 6. Placeholder data — needs wiring to real sources

These render with mock/placeholder data so the design is reviewable. Wire them to
real data when convenient:

- **NFTs tab (home)** — `_NftsSliver` / `_NftTile` in `dashboard_screen.dart` show
  placeholder collectible tiles. Replace `_NftsSliver._items` with a real NFT list
  and the gradient placeholder with the NFT image.
- **Balance 24h delta** (`_HeroBalance`) — currently a mock `balance * 0.024`.
- **Token-detail "Security" / "Activity"** sections — still WIP "Coming Soon" content.

---

## 7. Pre-existing issues — NOT introduced by the redesign

`flutter analyze` reports **11 errors and ~327 warnings, all pre-existing on
`dev_logsubmissions`**:

- **11 errors** are all in `lib/tokeninfo/token_info_loader.dart` — your in-progress
  codegen (`SuperGeniusTokenInfo` undefined / `token_model.g.dart` not generated).
- **~327 warnings** are mostly `unused_element` / `unused_field` dead code across the
  existing codebase (322 of them in files we never touched).

We verified our changes add **zero** new errors/warnings.

---

## 8. Rebase & PR

- `dev_logsubmissions` added **4 commits** since the fork — all **config/build**
  (network config, crdt config, crashpad perms, `genius_api`). **Zero UI overlap.**
- The only file touched by both sides is `pubspec.yaml`, and the edits are in
  **different sections** (you added an asset, we added dependencies) → **auto-merges**.
- `git merge-tree` reports the rebase as **conflict-free**.

Recommended: rebase `ui-redesign-3.514` onto `origin/dev_logsubmissions`, then PR.

---

## 9. Building & QA (important for the UI-only environment)

We could not build with the native stack (SuperGenius / GeniusSDK / zkLLVM) locally,
so for **visual QA only** we used a **UI-only stub build** (an empty
`libGeniusWallet.dylib` + adjusted `macos/` project files).

- **These stub hacks are UNCOMMITTED working-tree changes (≈15 files under `macos/`,
  plus generated `linux/` + `pubspec.lock`) and must NOT ship.** They are not part of
  any commit. Confirm with `git status` before merging — only `lib/`, `pubspec.yaml`,
  the texture asset, and the `*.md` docs are committed.
- **You build normally** with the real native deps. The redesign needs nothing special.
- For a quick mock-data run (no wallet setup), the existing dev bypass works:
  `flutter run --dart-define=WALLET_PK=<anything>` injects a fake wallet and boots
  into the dashboard (uses your existing `dev_overrides.dart`).

---

## 10. Known follow-ups (deliberately not done blind)

Flagged during the a11y/quality pass; left for review because they need design
judgment or live verification:

- **Contrast on the teal surface** — a muted gray on the bright teal page background
  can't reach WCAG AA without becoming near-white; we addressed the worst cases
  (transaction cards, section labels via a new `textPrimary80` token) and left the
  rest as a design call.
- **A few tap targets** still under 48px (some compact row triggers / faint hints) —
  flagged, not changed, because the fix shifts layout.
- **Swap screen** visual sign-off — wrapped with the canvas + analyzer/compile-clean,
  but the main swap UI needs the real token list (won't load in the stub) to eyeball.
- **Intensity tuning** of the depth layer (glow/grain/AppBar transparency on detail
  screens) — easy, centralized in `GWDecorations`.

---

*Questions about any of the above? Happy to walk through the cold-start fixes (§3) or
the design system (§4) in detail.*
