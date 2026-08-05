---
quick_id: 260721-bxr
type: execute
status: complete
date: 2026-07-21
files_modified:
  - lib/components/overlay/responsive_overlay.dart
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
commit: (uncommitted — CLAUDE.md forbids commits)
verification: flutter analyze clean (3 files, "No issues found!")
walk: PENDING
---

# Quick 260721-bxr — Nav tab design "C" + unified section-title header height

Two locked, approved desktop-dashboard UI fixes. `flutter analyze` clean on all
three touched files; **no commit** (CLAUDE.md gate). Walk pending.

## TASK A — Nav tab "C" (underline CLOSE to label + active tab shows NO hover box)

**File:** `lib/components/overlay/responsive_overlay.dart` (`_DesktopTopBar`)

Two changes, both driving the sketch-C contract (`.planning/sketches/002-top-navbar/nav-tab-alignment.html`, `[data-v="C"]`: 44px inset box, label centered, gradient underline 4px up from the label):

1. **Active tab paints no hover box.** Added to the `InkWell`:
   ```dart
   overlayColor: isSelected
       ? const WidgetStatePropertyAll(Colors.transparent)
       : null,
   ```
   `WidgetStatePropertyAll<Color?>(transparent)` blanks the splash across the hovered/pressed/focused states, so hovering the active tab only changes the cursor — the underline stays the sole active accent. Non-active tabs keep `null` → the default inset hover box inside the 44px box. No persistent active background was added.

2. **Underline grouped tight to the label.** Replaced the old `Stack[ Center(Row), Positioned(bottom:0, AnimatedContainer) ]` with a single centered Column that binds the label + a 4px gap + the underline as one block:
   - Shrank the inset box height from `appBarHeight - space4*2` (= 68 − 16 = **52**) to a fixed **`44.0`** — the compact box makes the slight above-center shift from grouping imperceptible (matches sketch C's "44 in 68 → 12 top/bottom").
   - Inside the horizontal-12 `Padding` + `IntrinsicWidth`:
     ```dart
     Center(
       child: Column(
         mainAxisSize: MainAxisSize.min,
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Row(min, spacing: 6, [Icon(size 23), if(!hideLabels) Text(label)]),
           const SizedBox(height: 4),
           AnimatedContainer(underline),
         ],
       ),
     )
     ```
   - The underline **dropped its explicit width** (`Positioned(left:0,right:0)` is gone). `CrossAxisAlignment.stretch` inside the `IntrinsicWidth` makes it track the icon+label content width exactly — same content-tracking as before ("Transactions" long, "Swap" short, icon-only when `hideLabels`).
   - **Preserved everything else on the underline:** `duration: 200ms`, `height: 3`, `gradient: isSelected ? GeniusWalletGradient.brandCta : null`, `color: isSelected ? null : Colors.transparent` (the gradient-XOR-color BoxDecoration guard), `borderRadius: BorderRadius.vertical(top: Radius.circular(3))`, and the `brandPrimaryStrong @0.5` `blurRadius: 10` glow when selected.
   - **Preserved the rest of the tab:** `color = isSelected ? gw.textPrimary : gw.textSecondary` (white active text/icon), `_kIconSize` (23), `spacing: 6`, the `hideLabels` icon-only branch, the brandCta gradient, rounded top, and the logo/gaps outside the tab.

**Glow spill:** With the 4px gap the underline no longer sits at the box's very bottom, so the 10px glow has vertical room above the 44px box bottom. I did **not** add a `ClipRect` — the geometry gives clearance and reducing the glow was explicitly off-limits. If the walk still shows spill below the box bottom, the fix is to wrap the `Column` in `ClipRect` (cheapest, glow untouched) — noted as walk-tunable, not applied.

## TASK B — Identical section-header height in GWSectionTitle + drop Assets call-site reservation

**Files:** `lib/components/cards/gw_section_title.dart`, `lib/components/coins/view/coins_screen.dart`

Goal: every panel's title area reserves the SAME height so title→top padding AND title→first-row gap are identical across Assets / Markets / Transactions / Bitcoin-Chart.

1. **`gw_section_title.dart`:** Wrapped the existing `Row` in
   ```dart
   ConstrainedBox(constraints: const BoxConstraints(minHeight: 44), child: Row(...))
   ```
   44 = the height the 2-line Assets total needs (amount ~20/26 + 24h-change ~13/18 ≈ 44; matches the old 45 call-site reservation, rounded to the shared header the component now owns for ALL panels). Kept the Row's `crossAxisAlignment: CrossAxisAlignment.center` so the title (and single-line trailings) center vertically in the reserved height. Left untouched: the outer `Padding(fromLTRB(space4, 2, space4, space8))`, the 18px `titleLg` style, `letterSpacing: -0.2`, and the optional `?trailing`. Updated the doc comment to state the component now reserves a shared ~44px header min-height for all four panels and that call sites must not set their own.

2. **`coins_screen.dart` (Assets header):** Removed the now-redundant `ConstrainedBox(constraints: const BoxConstraints(minHeight: 45))` wrapper and passed the inner `Column` (total + conditional 24h-change) **directly** as `trailing`. The Column is unchanged: `mainAxisAlignment: center`, `crossAxisAlignment: end`, `mainAxisSize: min`, fontSize-20 / w700 total, and the `if (total > 0)` 24h-change line. Empty↔funded two-line stability is preserved — the reserved height now comes from the component, and the center-aligned end-column keeps the amount vertically centered in both states.

**No-code-change panels confirmed to center cleanly in the reserved height** (per contract, not touched): Markets (single-line `Text('Top n · 24h')`), the Transactions `FittedBox` trailing, and the title-only Bitcoin-Chart case. All are `< 44px` tall so `minHeight` only reserves space; `CrossAxisAlignment.center` centers them — no clipping, no overflow.

## Scope discipline

Did NOT touch: panel bodies, Markets rows (1nk), Assets rows (vwj), `/banxa`, `/squidrouter`, `*.g.dart`. No regression to 0ze / 1nk / vwj / baz. ROADMAP.md not updated (per task constraints).

## Verification — REAL `flutter analyze` output

```
$ flutter analyze lib/components/overlay/responsive_overlay.dart \
    lib/components/cards/gw_section_title.dart \
    lib/components/coins/view/coins_screen.dart
Analyzing 3 items...
No issues found! (ran in 4.4s)
```

Clean — zero warnings/errors across all three modified files. Note: `flutter analyze` is a gate, not evidence of visual correctness (STATE.md standing blocker: no working automated test harness; every criterion is walk-observable). The manual desktop walk remains PENDING:
- Nav: active tab underline close to the label; hovering active = no box (cursor only); hovering non-active = inset box; gradient/glow/white-active text/icons intact; no glow spill below the 44px box.
- Panels: Assets / Markets / Transactions / Bitcoin-Chart headers share identical title→top and title→first-row spacing; Assets total stable empty↔funded, no clipping/overlap onto the first coin row.

## Deviations

None — plan executed exactly as written. No `ClipRect` added (geometry gives clearance; left as documented walk-tunable). Light-mode: both changes are structure/geometry only and inherit existing theme tokens; no separate handling — any glow/contrast nit found on the walk is a deferral, not an inline fix.

## Self-Check

- `responsive_overlay.dart`, `gw_section_title.dart`, `coins_screen.dart` — all present, edited, unstaged.
- No commit made (CLAUDE.md gate honored; `git status` shows the three files modified/untracked, none staged).

---

## Correction (2026-07-21) — nav tab icon+label vertical centering

Targeted follow-up. The icon+label read ~3.5px too HIGH in the 44px hover box (more space at top than bottom). Root cause: the icon+label Row, a `SizedBox(4)` gap, and the underline were grouped in one `Center(Column(min, stretch, ...))`, so the WHOLE [text + underline] block was centered as a unit — pushing the text above the true box center by half the underline+gap height (~3.5px).

**FIX 1 — text centered independently of the underline.** Replaced the grouped `Center(Column[...])` with a `Stack`:
- `Center(child: Row(min, spacing:6, [Icon(23,color), if(!hideLabels) Text]))` → icon+label at the TRUE box center (equal top/bottom margin).
- `Positioned(bottom:4, left:0, right:0, child: AnimatedContainer(...))` → the underline (unchanged: 3px brandCta gradient, blur-10 brandPrimaryStrong glow @ alpha .5, `Radius.circular(3)` rounded top, gradient-XOR-color state guard) rides ~3-4px beneath the centered text and still tracks the icon+label content width. Positioned children don't contribute to `IntrinsicWidth`, so the box width still resolves from the Row (icon-only when `hideLabels`).
- Preserved: box height 44, white active text/icon (`gw.textPrimary`), icon 23, `overlayColor: isSelected ? transparent : null` (active-no-box), outer `Padding(vertical: space4)` inset, logo(40)/gaps(15).
- **No `ClipRect` added.** With the underline at `bottom:4` the blur-10 glow has ~4px box clearance and bleeds ~6px below the box — but that lands on the 12px of `surfaceElevated` bar beneath the box (stays inside the bar) and matches the prior shipped layout, which also spilled (old underline had 7px clearance vs blur 10). A `ClipRect` at the box edge would clip the underline's HORIZONTAL glow too and regress it, so it was deliberately omitted (documented inline).

**FIX 2 — box vertical centering in the 68px bar (verified, no change).** Outer nav `Row` uses default `crossAxisAlignment: center`; no ancestor forces top/bottom alignment. Measured: `tabButton` = `Padding(vertical: space4=8)` + `SizedBox(44)` = **60px**, centered in the 68px bar → **4px top + 4px bottom** → the 44px box sits **12px from the bar top AND 12px from the bar bottom** (equal). The box→dashboard-content gap below the whole navbar is the dashboard's own top padding (separate surface) — untouched.

**Verification (real output):**
```
$ flutter analyze lib/components/overlay/responsive_overlay.dart
Analyzing responsive_overlay.dart...
No issues found! (ran in 4.3s)
```

**Scope/commit:** Only `lib/components/overlay/responsive_overlay.dart` touched. Not committed (CLAUDE.md gate); `git status` shows ` M lib/components/overlay/responsive_overlay.dart` (modified, unstaged). Walk still PENDING — confirm icon+label symmetric in the box and underline glow does not read as spilling below the bar.
