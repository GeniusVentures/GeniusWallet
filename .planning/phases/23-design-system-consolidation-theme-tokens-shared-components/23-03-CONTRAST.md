# 23-03 Measured Contrast Ratios

Every ratio below uses the same WCAG relative-luminance formula as
`test/theme/theme_contrast_test.dart`'s `contrastRatio()` helper (built on
`Color.computeLuminance`, `(L1+0.05)/(L2+0.05)`) — no second implementation.
Thresholds: **4.5:1** for body text, **3:1** for large text and non-text UI
(icons, borders, focus indicators). Every pair below is also asserted in
`test/theme/theme_contrast_test.dart` (Part 5 and Part 6 for Task 2; the
`GWWarningNote`/reown assertions for Task 3 are listed in their own section).

## Task 2: `toast_widget.dart`

The whole palette was re-derived onto `context.gw`. The card itself is now an
opaque `gw.surfaceElevated` panel (appearance-aware) with a type-coloured
accent (icon + border) and `textPrimary`/`textSecondary` copy — replacing a
fixed `Colors.green.shade50`-style palette that never varied with appearance.

| Component | State | Mode | Foreground | Background | Ratio | Threshold | Verdict |
|---|---|---|---|---|---|---|---|
| Toast card | title | dark | `textPrimary` `#FFFFFF` | `surfaceElevated` `#0C0E14` | 19.29:1 | 4.5:1 | PASS |
| Toast card | title | light | `textPrimary` `#10131A` | `surfaceElevated` `#FFFFFF` | 18.58:1 | 4.5:1 | PASS |
| Toast card | message | dark | `textSecondary` `#8A8F9D` | `surfaceElevated` `#0C0E14` | 5.97:1 | 4.5:1 | PASS |
| Toast card | message | light | `textSecondary` `#5A606E` (AA-divergent light value) | `surfaceElevated` `#FFFFFF` | 6.30:1 | 4.5:1 | PASS |
| Toast success | icon + border | dark | `statusSuccess` `#0AD89C` | `surfaceElevated` `#0C0E14` | 10.39:1 | 3:1 | PASS |
| Toast success | icon + border | light | `statusSuccess` `#07875F` (AA-divergent light value) | `surfaceElevated` `#FFFFFF` | 4.53:1 | 3:1 | PASS |
| Toast error | icon + border | dark | `statusError` `#FF4D4D` | `surfaceElevated` `#0C0E14` | 5.90:1 | 3:1 | PASS |
| Toast error | icon + border | light | `statusError` `#D92D2D` (AA-divergent light value) | `surfaceElevated` `#FFFFFF` | 4.81:1 | 3:1 | PASS |
| Toast warning | icon + border | dark | `statusWarning` `#FFC42E` | `surfaceElevated` `#0C0E14` | 12.11:1 | 3:1 | PASS |
| Toast warning | icon + border | light | local darkened amber `#92400E` (matches `GWWarningNote`, NOT the raw `statusWarning`) | `surfaceElevated` `#FFFFFF` | 7.09:1 | 3:1 | PASS |

All ten pairs asserted in `test/theme/theme_contrast_test.dart` — Part 5,
`ToastWidget clears AA in both appearances`, parametrised over
`GWAppearanceMode.values` x `ToastType.values` (6 `testWidgets` cases, each
asserting title/message/icon identity AND ratio — 24 assertions total for
this group alone once identity checks are counted).

**Structure/timing/animation/dismiss unchanged** — `git diff` on
`toast_widget.dart` is colour + import edits only; `ToastManager`'s overlay
lifecycle, the slide-in animation and the auto-dismiss timer were not touched.

## Task 2: `gw_button.dart`

### Primary / gradient variants (identical treatment, same fix)

`textOnBrand` (`#000B18`, fixed in both modes) painted on the two
`brandCta` gradient stops (`gradientGreen`/`gradientBlue`, also fixed in both
modes) — this pairing does not vary by appearance, so one measurement covers
both modes:

| Foreground | Background stop | Ratio | Threshold | Verdict |
|---|---|---|---|---|
| `textOnBrand` `#000B18` | `gradientGreen` `#0AD89C` | 10.66:1 | 4.5:1 | PASS |
| `textOnBrand` `#000B18` | `gradientBlue` `#0AAEE6` | 7.74:1 | 4.5:1 | PASS |

No code change here beyond the residue access-path move
(`GeniusWalletColors.textOnBrand`/`gradientBlue` → `gw.textOnBrand`/
`gw.gradientBlue`) — both fixed tokens, so the value is unchanged; this was
already correct and is now pinned by Part 6's `primary variant label vs
brand CTA gradient` test (parametrised over both modes, since the assertion
itself is mode-parametrised even though the two colours involved are not).

### Destructive variant — the real fix

**Before this plan:** `background: GeniusWalletColors.statusError` (fixed
`#FF4D4D`), `foreground: gw.textPrimary` (white in dark, ink `#10131A` in
light).

| Mode | Foreground | Background | Ratio | Threshold | Verdict |
|---|---|---|---|---|---|
| dark (before) | `textPrimary` white | `statusError` `#FF4D4D` | 3.27:1 | 4.5:1 | **FAIL** |
| light (before) | `textPrimary` ink `#10131A` | `statusError` `#D92D2D` (via `gw.statusError`, the AA-corrected light value) | 3.86:1 | 4.5:1 | **FAIL** |

Neither white nor ink clears 4.5:1 against either red — `gw.statusError` is
a foreground/icon-tuned token (meant to sit ON a surface), not a fill meant
to have text painted on top of it. `gw.foundationError` (`#920000`) is
already in the palette as the fill-purposed dark-red token (0 call sites
before this plan) and is fixed in both modes:

| Mode | Foreground | Background | Ratio | Threshold | Verdict |
|---|---|---|---|---|---|
| dark (after) | `Colors.white` (documented fixed exception) | `foundationError` `#920000` | 9.45:1 | 4.5:1 | PASS |
| light (after) | `Colors.white` (documented fixed exception) | `foundationError` `#920000` | 9.45:1 | 4.5:1 | PASS |

`Colors.white` here is a deliberate, annotated always-one-mode exception
(the plan's own guidance: "text on a fixed dark scrim" is the documented
case) — `gw.foundationError` does not flip with appearance, so a
mode-following `gw.textPrimary` would go ink-on-dark-red in light mode and
fail (the exact bug this replaces). Asserted in Part 6's
`destructive variant fill + label clear AA`, both modes.

### Disabled state — visibly distinct, not required to hit AA

WCAG 1.4.3 exempts inactive UI components. `disabled` applies `.withAlpha(140)`
(~55% opacity) to both fill and foreground, which is itself the
"still-legible-but-visibly-dimmed" signal. Worked example, destructive
variant, dark mode, backdrop `surfaceBase` `#0B0D12`:

| State | Foreground | Background (composited over `surfaceBase`) | Ratio |
|---|---|---|---|
| enabled | white (opaque) | `foundationError` `#920000` (opaque) | 9.45:1 |
| disabled | white @ 55% → `#B28E8F` | `foundationError` @ 55% → `#550508` | 5.07:1 |

Both clear 4.5:1 even disabled (comfortably above the WCAG floor, though not
required to be); the visible drop from 9.45 → 5.07 plus the desaturated
look is the "reads as disabled" signal `AGENTS.md` asks for — a washed-out
red, not a full-strength one that would look clickable.

### The `.withAlpha(140)` disabled-background bug (Rule 1, found during this task)

`disabled && variant != GWButtonVariant.ghost` gated the background dim —
but `.withAlpha(140)` **replaces** the alpha channel rather than scaling it,
so a `Colors.transparent` background (alpha 0) jumped to alpha 140 (an
opaque-ish **black** wash) on every disabled **`secondary`** button (the
`ghost`-only guard had missed it) and every disabled `gradientOutline`
button. Fixed by gating on `palette.background != Colors.transparent`
instead of enumerating variant names one at a time — closes the gap for
`secondary` and `gradientOutline` in the same fix as `ghost`.

### `gradientOutline`'s raw white — a documented, correct exception

`foreground`/`border` stay `Colors.white` in both modes: these are pre-mask
placeholders, painted then recoloured by a `BlendMode.srcIn` `ShaderMask`
that reads only the destination alpha and repaints every opaque pixel with
the brand gradient. The literal RGB value never reaches the screen — a
token here would be inert. Comment strengthened in-file to say so
explicitly (this plan's own acceptance criterion: "a documented
always-one-mode exception carrying an inline comment naming why it must be
fixed regardless of appearance").

### Other variants (secondary / tertiary / ghost / icon) — unchanged, already covered

`secondary`'s `foreground`/`border` (`gw.brandPrimaryOnSurface`) is already
asserted for identity + ratio against `surfaceElevated`/`surfaceMenu`/
`surfaceBase` by the pre-existing Part 3 group and the pre-existing
`GWButton secondary` group — not re-measured here since nothing about that
pairing changed. `tertiary`/`icon` (`gw.textPrimary` on `gw.surfaceElevated`)
and `ghost` (`gw.textPrimary` on whatever it sits atop) are the app's most
common text/surface pairing (near-white on near-black, or near-black on
white) and clear AA by a wide margin in both modes — no new failure found.

## Task 3: `lib/reown/` re-measured raw-colour count

`grep -vE '^\s*//' lib/reown/*.dart lib/reown/**/*.dart | grep -cE 'Colors\.[a-zA-Z]|Color\(0x'`
went from a heavy fixed-palette concentration (every approve/reject drawer,
the tx-details card and the session-request fallback content painting
`Colors.white`/`white70`/`grey` regardless of appearance) to **12**, every
one of which is a documented always-one-mode exception with an inline
comment, or a `GWColors.dark()`-fallback false positive the grep's regex
also matches (it contains the substring `Colors.dark`):

| File | Survivor | Reason |
|---|---|---|
| `approve_dapp_connection_drawer.dart` | `Colors.black` (Allow label) | fixed black clears 4.5:1 against BOTH `statusSuccess` values (measured below); a mode-following `gw.textPrimary` would not |
| `approve_transaction_drawer.dart` | `Colors.black` (Approve label) | same as above |
| `handle_dapp_requests.dart` | `Colors.white70` (params card row) | `deepBlueCardColor` is a fixed dark fill |
| `send_transaction_details.dart` (x2) | `Colors.white70`/`Colors.white` (`_fieldRow`) | same fixed-dark-fill card |
| `swap_result_drawer.dart` (x2) | `Colors.white70`/`Colors.white` (tx-hash card) | `deepBlueMenu` is a fixed dark fill |
| `reown_connect_button.dart` (x2) | `GWColors.dark()` | fallback-pattern false positive, not a literal colour |
| `reown_connect_button.dart` | `Colors.white` (QR background) | scannability requirement (quiet zone), not a style choice |
| `reown_connect_button.dart` | `Colors.transparent` (button bg) | carries no colour decision |
| `reown_connect_button.dart` | `Colors.white` (ShaderMask text) | `BlendMode.srcIn` pre-mask placeholder — RGB never reaches the screen |

### Approve/Allow button fill + label (new pairing, replaces `Colors.greenAccent`/`Colors.black`)

| Mode | Foreground | Background | Ratio | Threshold | Verdict |
|---|---|---|---|---|---|
| dark | `Colors.black` (fixed) | `statusSuccess` `#0AD89C` | 10.66:1 | 4.5:1 | PASS |
| light | `Colors.black` (fixed) | `statusSuccess` `#07875F` | 4.64:1 | 4.5:1 | PASS |

Not asserted in `theme_contrast_test.dart` (no public widget boundary to
pump without a live `ReownWalletKit`/`GeniusApi` — see
`url_bar_focus_remount_test.dart`'s header comment for the same limitation
on this package's dApp-adjacent widgets) — recorded here as the by-hand
evidence instead, per this plan's own note that the missing golden baseline
costs nothing where a measured ratio is the deliverable.

## Task 3: the forked warning widget (`swap_settings_drawer.dart`)

The private `_Message` class (three tones: error/warning/ok) re-derived the
warning tone from the raw, un-fixed `statusWarning` token instead of reusing
`GWWarningNote`'s documented light-mode amber (`gw_warning_note.dart:17-21`).
Replaced: the warning tone now renders `GWWarningNote(state.message!)`
directly; error/ok keep a small inline `_SlippageStatusRow` (neither needs
the amber workaround — `statusError`/`textSecondary` are already
appearance-aware). `GWWarningNote` gained no new parameter.

| State | Foreground | Background | Ratio | Threshold | Verdict |
|---|---|---|---|---|---|
| Before (light) | raw `statusWarning` `#FFC42E` | `surfaceElevated` `#FFFFFF` (156-A drawer panel) | 1.59:1 | 3:1 | **FAIL** |
| After (light) | `GWWarningNote`'s local amber `#92400E` | `surfaceElevated` `#FFFFFF` | 7.09:1 | 3:1 | PASS |
| After (dark) | `GWWarningNote`'s `gw.statusWarning` `#FFC42E` | `surfaceElevated` `#0C0E14` | 12.11:1 | 3:1 | PASS |

Asserted end-to-end in `test/theme/theme_contrast_test.dart` Part 7: drives
the real `SwapSettingsDrawer.show` with `initialSlippage: 10.0` (above
`kSlippageWarnAbove`), confirms exactly one `GWWarningNote` renders, and
asserts both icon-colour identity and ratio against the painted drawer
panel, in both modes.

**On the live walk this plan asks for:** this executor has no interactive
device/screen-control tool -- the environment brief for this run explicitly
prohibits spawning a new `flutter run`/`flutter build windows` (a
`genius_wallet.exe` is already running under the orchestrator's control, and
a second build fails on the DLL lock). No human clicked through the app
during this task. What WAS done, stated per surface rather than "looks
fine":

- Swap settings drawer, light mode: `test/theme/theme_contrast_test.dart`
  Part 7 drives the real `SwapSettingsDrawer.show` end to end with
  `initialSlippage: 10.0` (above `kSlippageWarnAbove`), pumps the actual
  widget tree, and reads the ACTUAL painted `Icon.color` off it -- not a
  value asserted from source. Measured 7.09:1 (light) / 12.11:1 (dark)
  against the drawer's own painted panel colour, vs. 1.59:1 before this fix.
- dApp connect flow (`ApproveDappConnectionDrawer`/`ApproveTransactionDrawer`):
  no live widget test was added (both need a `ReownWalletKit`/`GeniusApi`
  instance to reach via their real call sites, which no existing test in
  this repo constructs -- the same limitation
  `url_bar_focus_remount_test.dart`'s own header comment names for
  `WebViewMobile`). Verified instead by `flutter analyze`/`flutter test`
  (compiles, no raw-colour literal escapes the documented-exception list
  above) and the by-hand ratio table for the Allow/Approve button.
  **This is the gap in this plan's evidence** -- a human walk of this
  specific flow (both modes) is the one verification this task could not
  perform and should be the first thing checked live before this plan is
  considered fully proven.
- `lib/reown/`'s known x64 WalletConnect architectural finding (WalletConnect
  disabled via an arch-based skip on x64 desktop) was left untouched -- out
  of this plan's scope, as the plan requires.
