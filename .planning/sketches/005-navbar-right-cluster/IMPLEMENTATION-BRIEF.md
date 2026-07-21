# Navbar right-cluster — implementation brief (sketch 005 · winner B)

Hand-off for the **other session** to implement the top-bar right cluster re-skin. Winner is
**concept B — Normalized quiet chips** (see `index.html`, variant B). This is a **re-skin, not a
restructure** — normalize the existing controls; do not delete, reorder, or merge features.

> ⚠️ You already have **~210 uncommitted lines in `responsive_overlay.dart`** plus edits to
> `theme.dart` / `reown_connect_button.dart` in this session. Reconcile this brief with that
> in-progress work — you know what you've already changed. The other session is doing the **Bitcoin
> Chart** (`crypto_live_chart.dart` + `ChartDashboardView` only) and will NOT touch any navbar file,
> so there's no cross-session conflict as long as you stay out of those two.

## The problem (why it looks mismatched today)

The right cluster is assembled flush (no spacing) in
`lib/components/overlay/responsive_overlay.dart` → `_buildActionRowWidgets()`:

1. `NetworkDropdownSelector` (`lib/network/network_dropdown_selector.dart`) — chain icon + chevron
2. `SDKAccountManagerButton` (`lib/account/sdk_account_manager.dart`) — gear + `0x…` (collapses to `SizedBox.shrink()` when no SDK accounts)
3. `AccountDropdownSelector` (`lib/account/account_dropdown_selector.dart`) — wallet avatar + label + chevron
4. `ReownConnectButton` (`lib/reown/reown_connect_button.dart`) — 5-state Connect
5. `Buy GNUS` — `GWButton(gradient, md)` at fixed height 48

**Root cause:** 1–4 are bare `TextButton`s with **no explicit height**, so they inherit
`theme.dart`'s `textButtonTheme` `padding: vertical: space10 (20)` → each renders **~56–60px tall**,
while Buy GNUS is **48px**. Result: 4 different heights, 3 fill languages (grey `btnFilter` / ghost
outline / gradient), and **zero gaps**. The only aligned dimension is the 15px radius.

## The target (concept B)

Make all five controls read as one family:

- **One height: 40px**, explicit, on every control (including Buy GNUS — drop it 48→40 to match, or keep the cluster at 40 and Buy at 40).
- **One radius:** `GeniusWalletConsts.radiusMd (12)` on the context chips (slightly tighter than today's 15 reads cleaner at this size — your call; `radiusLg` is also fine if you prefer to keep 15).
- **One quiet fill for context (1–3):** `gw.surfaceMenu` + `1px gw.borderSubtle`, hover → `gw.borderStrong`. Consistent horizontal padding (`space6 = 12`), consistent internal icon/label/chevron gap (`space4 = 8`).
- **Hierarchy by emphasis, not by size:**
  - context chips (chain / SDK / wallet) = quiet menu fill
  - **Connect** = the secondary — outlined (`brandPrimary` border, `brandPrimary` label), same 40px shell
  - **Buy GNUS** = the **only** gradient — the single primary CTA
- **Real gaps:** add `spacing: GeniusWalletConsts.space4 (8)` to the action `Row` (it's flush today).

## The one implementation trap — do NOT fix this in `theme.dart`

The tempting fix is to drop `textButtonTheme`'s `vertical: 20` padding globally. **Don't** — that
theme is shared by every bare `TextButton` in the app; changing it app-wide will resize unrelated
buttons and regress other screens. Instead give **each of the 4 controls its own
`TextButton.styleFrom` override** (`minimumSize`/`fixedSize` height 40, `padding` symmetric
`space6`, `shape` `radiusMd`, `backgroundColor` `surfaceMenu`, `side` `borderSubtle`). Local
overrides only. (Note `eu9` already made `btnFilter` appearance-aware — keep that; don't revert it.)

## Preserve (re-skin, not restructure)

- All four controls keep their **behaviour and dropdowns** — only chrome changes.
- `SDKAccountManagerButton` still `SizedBox.shrink()`s when empty — the `Row(spacing:)` collapses the
  gap automatically, so the variable item-count stops looking broken.
- `ReownConnectButton` keeps its **5-state machine** (idle/connected/connecting/timed-out/retry) and
  its status colors — just normalize its **shape + height** to the 40px shell so it stops reading as
  a different family. It's intentionally mode-invariant; leave that.
- Labels still drop below the responsive breakpoints (`small`/`xxl`) — keep that.

## Tokens & a11y

Everything from `GeniusWalletConsts` (`space4`, `space6`, `radiusMd`) + `GWColors`
(`surfaceMenu`, `borderSubtle`, `borderStrong`, `textPrimary`, `textSecondary`, `brandPrimary`) via
`Theme.of(context).extension<GWColors>() ?? GWColors.dark()`. **WCAG AA in both modes** — the Connect
outline + label and any on-fill text must clear 4.5:1 (or 3:1 for the non-text border) in light mode;
don't put raw `brandPrimary`/`brandSecondary` as text on a light fill (they're ~2:1 on white).

## Recommended path

Route it through **`/gsd-quick --validate "…"`** (plan-checker + verifier), not a raw edit — two
quick tasks this week (`gzq`, `k81`) silently regressed plan decisions because the fast path skipped
validation and the walk didn't measure. Same reason the chart task is on the validated path.

**No commits** unless Jakub authorizes (CLAUDE.md gate). Stage explicitly by path — never `git add -A`
(six skip-worktree signing files + cross-session work in the tree).

## ADDED 2026-07-21 — Unified hover language (sketch 008 · winner D) + gradient active tab

These belong to YOUR files (`responsive_overlay.dart` nav tabs; `gw_view_all_link.dart` VIEW ALL),
so they ride with your navbar work, not the chart task. The timeframe tab (chart, my lane) already
ships variant D. Make the nav + VIEW ALL match, so all interactive chrome is one system.

**The design-system hover is D · "lift chip"** (see `.planning/sketches/008-hover-language/`):
on hover an unselected element rises onto `gw.surfaceElevated` + `GeniusWalletElevation.card` shadow
+ a 1px upward lift (`Matrix4.translationValues(0,-1,0)`), label → `gw.textPrimary`,
`SystemMouseCursors.click`, ~120ms. Apply to **inactive nav tabs** and **VIEW ALL**.
(`gw_view_all_link.dart` currently uses a *gradient* hover — change it to D so it matches; the
gradient-on-hover was a pre-decision, now superseded.)

**Nav active tab = gradient, not blue.** The active tab currently colors its label
`brandPrimary` (flat cyan). Make the active label the **brand gradient** (green→blue) via a
`ShaderMask` over the text (`GeniusWalletGradient.brandCta` or the nav's existing underline gradient),
so the active label and its underline speak the same gradient. Keep the underline.

**Lower the active underline** so it clears the icon (the reported near-overlap): nudge its `bottom`
down ~2px (sketch 008 uses `bottom: 2px` inset from the tab base).

AA: the D lift keeps an AA-safe label (`textPrimary`) in both modes; a ShaderMask gradient label is
decorative brand color on the *active* tab only — fine, but verify legibility in light mode.

## Walk (macOS)

`flutter run -d macos --dart-define=GW_DEV_TOOLS=true`. Check all five controls read as one 40px
family with even gaps; hover states consistent; Connect's 5 states still fire (dev bubble / disconnect);
SDK-absent case doesn't leave a hole; Buy GNUS is the only gradient; **both light and dark**.
