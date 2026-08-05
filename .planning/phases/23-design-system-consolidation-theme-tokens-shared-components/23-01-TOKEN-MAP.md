# 23-01 Token Parity Map

One row per **public** member of `lib/theme/genius_wallet_colors.dart` (`GeniusWalletColors`).
Drives 23-02's mechanical call-site rewrite. Private primitives (`_xDark`/`_xLight` pairs, `_isLight`)
are the layer being preserved, not migrated — they get no rows.

## Measured counts vs. the plan's reference figures

| Metric | Freshly measured (this task, 2026-07-29) | Reference figure | Discrepancy / explanation |
|---|---|---|---|
| Raw `static` declarations in the file | **76** total (`grep -c 'static'`) | plan: "65 including private `_xDark`/`_xLight` pairs" | The plan's figure does not hold: 76 = 65 public + 11 private (`_isLight`, `_brandPrimaryOnSurfaceLight`, `_surfaceBaseDark/Light`, `_surfaceElevatedDark/Light`, `_surfaceMenuDark/Light`, `_surfaceSunkenDark/Light`, `_inkLight`). The private count is *additional* to 65, not included in it. |
| **Public** members (this map's row count) | **65** | plan objective: "~46 public members" | ~46 was an undercount — it likely excluded the 7 pure value-aliases (`gray500`, `borderBrand`, `statusInfo`, `brandGreen`, `brandGreenStrong`, `brandGreenMuted`, `brandGreenSubtle`) and some of the newer Vibrant v1.2 brand-palette additions (`brandSecondaryBright`, `brandTertiaryMuted/Subtle`, `gradientBlue/Green`). |
| Call sites outside `lib/theme/` (sum across all 65 public names, per-symbol `grep -c` with a word boundary) | **277** | 288 (2026-07-28 context) / 260 (coarser plan-time grep) | Methodology difference: this count is a per-symbol regex (`GeniusWalletColors\.<name>\b`) summed across 65 distinct names, run fresh against the current tree. 288 and 260 were almost certainly a single blanket `GeniusWalletColors\.` grep (which also catches partial/adjacent matches differently) run at two earlier points in time, not a per-symbol sum. 277 is in the same neighborhood as both and is the number 23-02 should trust, since it is reproducible per-name from this table. |

Re-run recipe for any single row: `grep -rn "GeniusWalletColors\.<name>\b" --include='*.dart' lib test | grep -v '^lib/theme/'`.

## GWColors' 21 pre-existing fields (already at parity — no action needed)

`surfaceBase`, `surfaceElevated`, `surfaceMenu`, `surfaceSunken`, `surfaceOverlay`, `textPrimary`,
`textPrimary80/70/60/54/38/30/24/12/10` (9 fields), `textSecondary`, `statusSuccess`, `statusError`,
`borderSubtle`, `borderStrong`, `borderControl`. Two of these (`textSecondary`, and both
`statusSuccess`/`statusError`) are **documented intentional AA divergences** in `GWColors.light()`
from the legacy mode-invariant value — already implemented and already excluded from the existing
value-preservation `assert` in `gw_colors.dart`. Nothing about that changes in this plan.

## New rows (43 fields to add)

| legacy name | GWColors field | already exists? | light value | dark value | appearance-aware? | call sites | const-risk |
|---|---|---|---|---|---|---|---|
| `lightGreenPrimary` | `lightGreenPrimary` | No | `Colors.greenAccent` | `Colors.greenAccent` | No (fixed) | 2 | **Yes** (static const) |
| `lightGreenSecondary` | `lightGreenSecondary` | No | `0xFF54C48E` | `0xFF54C48E` | No (fixed) | 1 | **Yes** |
| `mutedGreen` | `mutedGreen` | No | `0xFF2EBE7B` | `0xFF2EBE7B` | No (fixed) | 0 | **Yes** |
| `deepBlueTertiary` | `deepBlueTertiary` | No | `0xff05090F` | `0xff05090F` | No (fixed) | 2 | **Yes** |
| `deepBlueCardColor` | `deepBlueCardColor` | No | `Color.fromRGBO(10,18,31,1)` | same | No (fixed) | 10 | **Yes** — used in `const BoxDecoration` in `registration_header.dart:48` |
| `deepBlueMenu` | `deepBlueMenu` | No | `0xff0F1B2E` | same | No (fixed) | 1 | **Yes** |
| `deepBlue` | `deepBlue` | No | `Color.fromRGBO(20,37,61,1)` | same | No (fixed) | 2 | **Yes** |
| `grayPrimary` | `grayPrimary` | No | `Color.fromRGBO(21,30,41,1)` | same | No (fixed) | 0 | **Yes** |
| `btnText` | `btnText` | No | `Color.fromRGBO(0,9,20,1)` | same | No (fixed) | 1 | **Yes** |
| `btnDisabled` | `btnDisabled` | No | `Color.fromRGBO(188,188,188,1)` | same | No (fixed) | 1 | **Yes** |
| `btnTextDisabled` | `btnTextDisabled` | No | `Color.fromRGBO(101,101,101,1)` | same | No (fixed) | 2 | **Yes** |
| `foundationError` | `foundationError` | No | `0xff920000` | same | No (fixed) | 0 | **Yes** |
| `btnGradientBlue` | `btnGradientBlue` | No | `Color.fromRGBO(0,104,239,1)` | same | No (fixed) | 0 | **Yes** |
| `btnGradientGreen` | `btnGradientGreen` | No | `Color.fromRGBO(1,221,166,1)` | same | No (fixed) | 0 | **Yes** |
| `btnFilter` | `btnFilter` | No | `0xFFEFF2F6` | `Color.fromARGB(255,19,33,53)` | **Yes** | 0 | No (getter, not const today) |
| `btnFilterSelected` | `btnFilterSelected` | No | `lightGreenPrimary.withValues(alpha:0.1)` | same | No (fixed, derived) | 0 | No (already non-const) |
| `borderGrey` | `borderGrey` | No | `Color.fromRGBO(255,255,255,0.30)` | same | No (fixed) | 1 | **Yes** |
| `brandPrimary` | `brandPrimary` | No | `0xFF14C8FF` | same | No (fixed) | 13 | **Yes** — used in `const SweepGradient` in `gw_spinner.dart:77` |
| `brandPrimaryStrong` | `brandPrimaryStrong` | No | `0xFF0AAEE6` | same | No (fixed) | 22 | **Yes** |
| `brandPrimaryMuted` | `brandPrimaryMuted` | No | `Color(0xFF14C8FF).withAlpha(61)` | same | No (fixed, derived) | 0 | No (already non-const) |
| `brandPrimarySubtle` | `brandPrimarySubtle` | No | `Color(0xFF14C8FF).withAlpha(31)` | same | No (fixed, derived) | 3 | No (already non-const) |
| `brandPrimaryOnSurface` | `brandPrimaryOnSurface` | No | `0xFF0A6885` | `brandPrimaryStrong` (`0xFF0AAEE6`) | **Yes** | 20 | No (getter, not const today) |
| `brandSecondary` | `brandSecondary` | No | `0xFF2BF5B4` | same | No (fixed) | 5 | **Yes** |
| `brandSecondaryStrong` | `brandSecondaryStrong` | No | `0xFF0AD89C` | same | No (fixed) | 4 | **Yes** |
| `brandSecondaryBright` | `brandSecondaryBright` | No | `0xFF5BFFD0` | same | No (fixed) | 2 | **Yes** — used in `const SweepGradient` in `gw_spinner.dart:79` |
| `brandSecondaryMuted` | `brandSecondaryMuted` | No | `Color(0xFF2BF5B4).withAlpha(61)` | same | No (fixed, derived) | 2 | No (already non-const) |
| `brandSecondarySubtle` | `brandSecondarySubtle` | No | `Color(0xFF2BF5B4).withAlpha(31)` | same | No (fixed, derived) | 0 | No (already non-const) |
| `brandTertiary` | `brandTertiary` | No | `0xFFC28FFF` | same | No (fixed) | 3 | **Yes** |
| `brandTertiaryMuted` | `brandTertiaryMuted` | No | `Color(0xFFC28FFF).withAlpha(61)` | same | No (fixed, derived) | 0 | No (already non-const) |
| `brandTertiarySubtle` | `brandTertiarySubtle` | No | `Color(0xFFC28FFF).withAlpha(31)` | same | No (fixed, derived) | 0 | No (already non-const) |
| `gradientBlue` | `gradientBlue` | No | `0xFF0AAEE6` | same | No (fixed) | 3 | **Yes** |
| `gradientGreen` | `gradientGreen` | No | `0xFF0AD89C` | same | No (fixed) | 0 | **Yes** |
| `gray500` | `gray500` | No | `textSecondary` (`0xFF8A8F9D`) | same | No (fixed alias) | 0 | **Yes** (const alias) |
| `textTertiary` | `textTertiary` | No | `Color.fromARGB(255,53,54,61)` | same | No (fixed) | 3 | **Yes** |
| `textDisabled` | `textDisabled` | No | `0xFF2A2B31` | same | No (fixed) | 0 | **Yes** |
| `textOnBrand` | `textOnBrand` | No | `0xFF000B18` | same | No (fixed) | 16 | **Yes** |
| `borderBrand` | `borderBrand` | No | `brandPrimary` (`0xFF14C8FF`) | same | No (fixed alias) | 0 | **Yes** (const alias) |
| `statusWarning` | `statusWarning` | No | `0xFFFFC42E` | same | No (fixed) | 19 | **Yes** |
| `statusInfo` | `statusInfo` | No | `brandPrimary` (`0xFF14C8FF`) | same | No (fixed alias) | 3 | **Yes** (const alias) |
| `brandGreen` | `brandGreen` | No | `brandSecondary` (`0xFF2BF5B4`) | same | No (fixed alias) | 6 | **Yes** (const alias) |
| `brandGreenStrong` | `brandGreenStrong` | No | `brandSecondaryStrong` (`0xFF0AD89C`) | same | No (fixed alias) | 0 | **Yes** (const alias) |
| `brandGreenMuted` | `brandGreenMuted` | No | `brandSecondaryMuted` | same | No (fixed alias, derived) | 0 | No (already non-const) |
| `brandGreenSubtle` | `brandGreenSubtle` | No | `brandSecondarySubtle` | same | No (fixed alias, derived) | 0 | No (already non-const) |

**Total new rows: 43.** Combined with the 21 pre-existing fields, `GWColors` reaches **64** fields
(65 public legacy members minus the 1 explicitly excluded below).

## Excluded — locked pre-existing decision, not a gap

| legacy name | GWColors field | already exists? | note |
|---|---|---|---|
| `statusNeutral` | — (none) | Excluded | `genius_wallet_colors.dart:214-228` carries its own `ponytail:` note, written before this plan: mode-invariant, fill-only, "deliberately NOT added to the GWColors extension" because the transaction badge's glyph colour is *computed from* this fill (`badgeGlyphColor` in `dashboard/home/widgets/transaction_badge.dart`), so adding a second hand-maintained appearance-aware token would duplicate that derivation. Its own upgrade path says "promote to GWColors ... if a text consumer ever appears" — that has not happened. Respecting this existing, reasoned exception rather than overriding it for blanket parity; call sites (3, all fill-only per the note) stay on `GeniusWalletColors.statusNeutral` and are simply not part of 23-02's rewrite. |

## Const-context risk list handed to 23-02

32 of the 43 new fields are `static const` today (flagged **Yes** above) and are therefore usable in
`const` expressions; `context.gw.<field>` is not const, so every const-context call site is a future
"invalid constant value" the codemod must either skip or the surrounding widget must be de-consted.
Cross-checked against the four files 22-05 already flagged:

- `lib/components/loading/gw_spinner.dart:74-80` — `const SweepGradient(colors: [brandPrimary,
  brandSecondary, brandSecondaryBright], ...)`. All three are const-risk fields. Confirmed live risk.
- `lib/components/registration_header.dart:47-49` — `const BoxDecoration(color: deepBlueCardColor)`.
  const-risk field. Confirmed live risk. (Its two `textPrimary` uses at lines 65/83 are the existing
  getter, already non-const, no new risk.)
- `lib/submit_job/view/submit_job_screen.dart` — grepped clean today: no direct
  `GeniusWalletColors.*` reference at all (only `const SubmitJobScreen` / `const GWPageHeader`).
  Recorded as-is rather than guessed at; 22-05's flag for this file may have referred to a
  transitive const subtree (e.g. a const `GWSpinner()` instance elsewhere in its tree) or the file
  has changed since. 23-02 should re-check this file specifically before assuming it is clear.
- `lib/tokens/token_info_screen.dart:845` — `static Color get _glyph =>
  GeniusWalletColors.brandPrimaryOnSurface;` — this is a getter, not a const context; already
  non-const, no new risk from this specific line.
