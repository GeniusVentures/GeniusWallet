---
phase: 14
name: compute-panel-job-flow
status: draft
sources:
  - .planning/phases/14-compute-panel-job-flow/14-CONTEXT.md
  - .planning/sketches/076-compute-on-base-components/README.md
  - .planning/sketches/077-compute-interactive/README.md
  - .planning/sketches/016-compute-panel-anatomy/README.md
  - .planning/sketches/017-compute-status-states/README.md
  - .planning/sketches/018-job-request-flow/README.md
  - .planning/ROADMAP.md (Phase 14, lines 628-700)
design_locked: P1 twin tiles (016-B2) + dot/label 9 states (017-A) + drawer vertical steps (018-A)
remeasured: 2026-07-29 against the working tree at HEAD (edb4edfd)
---

# Phase 14 UI Spec - Compute panel & job flow

**This document turns already-decided design into an executable contract.** It does not reopen
P1/F1, the dot+label treatment, or any locked decision in `14-CONTEXT.md`. Everything numeric here
was re-derived from source this session; where a planning doc's number was wrong, the correction is
marked **[REMEASURE]** with the file:line that proves it.

---

## 0 · Remeasure log - what changed against the inherited numbers

Braian's standing rule is to re-derive every inherited number. Seven did not survive.

| # | Inherited claim | Where it is written | Measured value | Proof |
|---|---|---|---|---|
| R1 | Usable height **276px** | ROADMAP:663, 076:101, CONTEXT:43, `wallet_overview.dart:55` | **274px** | `DashboardScrollContainer` is a `Container` whose `GWDecorations.surface()` sets `Border.all(width: 1)` (`genius_wallet_decorations.dart:99-102`). `Container` folds `decoration.padding` (= border dimensions) into its own padding, so the border eats **2px** on top of the `EdgeInsets.all(space6)` = 24px. 300 - 2 - 24 = **274**. |
| R2 | `GWSectionTitle` costs **44px** | 076:119-120 | **62px** | `gw_section_title.dart:34-44`: `EdgeInsets.fromLTRB(space4, 2, space4, space8)` + `ConstrainedBox(minHeight: 44)` = 2 + 44 + 16. The rejection is *more* decisive, not less. |
| R3 | `GWKicker` non-dense is **~17px** | 076:123 | **18.0px** | `gw_kicker.dart:54-55`: 13px at `height: 18/13` = exactly 18.0. Dense is 11 at `16/11` = **16.0**, not the 14 assumed in 076's table. |
| R4 | Brand `#0AAEE6` is **3.0:1 on white** | 017 finding 5 | **2.56:1** | See §5. Calibration check: the same routine reproduces `brandPrimaryOnSurface`'s documented 6.30:1 and `GWWarningNote`'s 7.1:1 exactly. The conclusion (label stays `textPrimary`) is unchanged and now has more margin. |
| R5 | Percentage "kept forever" after processing stops | CONTEXT:101-104 | **True, but only on the clean path** | `app_bloc.dart:184-191`: the emit at :185 flips `isProcessing` false, then `if (isProcessing)` at :188 is false so :190 never runs and the old percentage survives. The **exception** path at :192-195 *does* zero it. So `isProcessing:false, processingPercentage:87.0` is reachable via a normal SDK transition, not via a throw. The gating rule stands; the reasoning must be stated correctly or an executor will "fix" the wrong branch. |
| R6 | Zero-balance bug at `wallet_overview.dart:143-145` | CONTEXT:75 | **141-148**, literal at **:145** | `if (balance == 0)` is :141; the `Text` spans :142-147; `GeniusWalletColors.statusError` is :145. |
| R7 | Burned-tokens hole at `submit_job_cubit.dart:195-218` | CONTEXT:88 | **Two distinct branches**, see §7 | :195-204 is *bridge failed, nothing spent*. :210-218 is *bridged, not processed* (the hole). :220-222 is *done*. The three terminal states map one-to-one onto three code branches - this is the most useful correction in this table. |

Confirmed unchanged: `maxHeight: 300` at `dashboard_screen.dart:212` (also :293, :298 in the
one-column layout); `sgnus_connection_widget.dart:89-90`; `submit_job_dashboard_button.dart:25-27`;
`genius_balance_display.dart:79` (48px) and `:81` (`Colors.white`); `submit_job_screen.dart:48-56`
and `:65`.

### Two findings the CONTEXT does not have

**F1 · The SDK ships a human-readable status message and the UI throws it away.**
`GeniusInitStatus` carries `{percentage, message}` (`packages/genius_api/lib/src/genius_api.dart:79-88`,
populated at `:1216-1223`). `sgnus_connection_widget.dart:47-49` reads `.percentage` and discards
`.message`. States 03 and 04 need that string; it already exists.

**F2 · `GeniusProcessingStatus` is a TRI-state collapsed to a bool.**
`genius_api_ffi.dart:1089-1095` defines `DISABLED(0)`, `IDLE(1)`, `PROCESSING(2)`.
`app_bloc.dart:180-182` computes `isProcessing = status == PROCESSING`, so **DISABLED and IDLE
become the same value**. Neither enum member is referenced anywhere in `lib/`. This is a fifth code
delta on top of CONTEXT's four, and it is the cheapest honest source for a distinct
"compute is switched off" reading.

### Two scale traps, stated because they will otherwise be got wrong

- `GeniusInitStatus.percentage` is **0.0 to 1.0** (`genius_api.dart:81`). `0.525` means 52.5%.
- `GeniusProcessingStatusInfo.percentage` is **0.0 to 100.0** (`genius_api_ffi.dart:1116-1118`).

Two different scales, two different feeds. `GWProgressBar` takes 0.0-1.0; the processing feed must
be divided by 100 at the call site, the init feed must not.

---

## 1 · The height budget

### 1.1 The number

```
ConstrainedBox(maxHeight: 300)              dashboard_screen.dart:212
  - DashboardScrollContainer border  2px    genius_wallet_decorations.dart:99-102
  - EdgeInsets.all(space6)          24px    dashboard_screen.dart:342
  = 274px usable                            [REMEASURE R1: was 276]
```

Losing 2px matters because the inherited design had 3px of slack. It no longer does; §1.3 buys it
back with one padding token, and every state is then measured below.

### 1.2 Measured component metrics (all from source, this session)

| Piece | Height | Source |
|---|---|---|
| `GWKicker()` (13px) | **18.0** | `gw_kicker.dart:54-55` |
| `GWKicker(dense: true)` (11px) | **16.0** | `gw_kicker.dart:54-55` |
| `GWStatTile` internal kicker→value gap | **3** | `gw_stat_tile.dart:53` |
| `GWAnimatedNumber` @ `numericDisplay` | **40.0** (32 at 40/32) | `genius_wallet_typography.dart:102-108` |
| `labelMd` line box | **18.0** (13 at 18/13) | `genius_wallet_typography.dart:98-99` |
| `bodySm` / `numericBody` line box | **20.0** (14 at 20/14) | typography `:89-94`, `:117-122` |
| `GWButton(size: sm)` | **44** | `gw_button.dart:86-87` |
| `GWButton(size: md)` | **48** | `gw_button.dart:88-89` |
| `GWCard` border, vertical cost | **+2** | `gw_card.dart:128-135` |
| `GWCard` default padding | `space8` = 16 each side | `gw_card.dart:12` |
| `GWSectionTitle` | **62** | `gw_section_title.dart:34-44` [REMEASURE R2] |

### 1.3 The stack, with the one lever that makes it fit

```
GWKicker('Compute')                                  18
SizedBox(height: space3 = 6)                          6
GWCard  · balance tile                            55 / 77 / 99
SizedBox(height: space6 = 12)                        12
GWCard  · compute tile                            55 / 65 / 77 / 87
SizedBox(height: space6 = 12)                        12
GWButton(size: sm, expand: true)                     44
                                    fixed chrome  =  92
```

Both tiles are:

```dart
GWCard(
  background: gw.surfaceSunken,
  border: Border.all(color: gw.borderSubtle, width: 1),
  elevated: false,
  radius: GeniusWalletConsts.radiusMd,
  padding: const EdgeInsets.symmetric(
    horizontal: GeniusWalletConsts.space6,   // 12
    vertical: GeniusWalletConsts.space4,     // 8   <- THE LEVER
  ),
  child: ...,
)
```

**The lever is `vertical: space4` (8) instead of `space6` (12).** It returns 16px across the two
tiles and it is the only change that buys the budget back without touching a locked decision. Both
values are on the 4-pt grid. With `space6` on both axes the tallest state lands at **284px against
274** - a 10px overflow, which is what the inherited arithmetic was hiding once the real metrics
and the two card borders are counted.

`elevated: false` and the sunken fill are deliberate: 016 rejected B4 because "two elevations inside
one card fight each other", and `GWDetailGrid` already documents this exact recipe (sunken fill +
`borderSubtle` hairline + `radiusMd`) as the right treatment for a recessed group inside a card
(`gw_detail_grid.dart:36-39, 57-62`).

**Not `GWStatTile`.** 076's mapping table sends the compute readouts to `GWStatTile`; that component
is a label over a **String** rendered at `numericBody` 15/w600 (`gw_stat_tile.dart:54-64`). The
balance tile's value is a `GWAnimatedNumber` at 40px and the compute tile's value is a status row.
Neither is a string. Use the same *shape* (dense kicker, 3px gap, value) hand-composed; do not force
the component. This is a fit correction, not a design change.

### 1.4 Per-state height table - all nine, measured

Balance tile: `18 (chrome) + 16 (dense kicker) + 3 + 40 (number) [+ 4 + 18 (≈ $ subline)]`
→ **77** bare, **99** with subline, **55** in the no-wallet placeholder form (18 + 16 + 3 + 18).

Compute tile: `18 (chrome) + 16 (dense kicker) + 3 + 18 (status row) [+ 4 + 18 (subline)] [+ 6 + 4 (bar)]`
→ **55** bare, **65** +bar, **77** +subline, **87** +subline +bar.

| # | State | Balance | Compute | Total | vs 274 |
|---|---|---|---|---|---|
| 01 | No wallet | 55 | 77 | **224** | 50 spare |
| 02 | Not linked | 99 | 77 | **268** | 6 spare |
| 03 | Starting up | 77 (no ≈ $) | 87 | **256** | 18 spare |
| 04 | Still starting up (stalled) | 99 | 77 | **268** | 6 spare |
| 05 | Ready | 99 | 77 | **268** | 6 spare |
| 06 | Processing | 77 (no ≈ $) | 65 | **234** | 40 spare |
| 07 | Job complete | 99 | 77 | **268** | 6 spare |
| 08 | Status unavailable | 99 | 77 | **268** | 6 spare |
| 09 | Disconnected | 99 | 77 | **268** | 6 spare |

**Worst state 268px, headroom 6px.**

The `≈ $` rule is exactly CONTEXT's: **the balance tile drops its `≈ $` subline in the two states
where the compute bar renders (03 and 06)**, which are the only states where the compute tile
carries both a subline and a bar. Expressed as one predicate the executor can hold:
`showFiatSubline = !showBar`.

### 1.5 Height rules the executor cannot skip

1. **Every subline is `maxLines: 1, overflow: TextOverflow.ellipsis`.** A wrap adds 18px and blows
   the budget silently. State 02's subline is the longest.
2. **A subline that carries an inline link is a `Row`**, not a single `Text`:
   `Row([Flexible(Text(reason, maxLines: 1, ellipsis)), SizedBox(width: space3), <link>])`.
   The reason truncates; the affordance never does. This preserves 016-B2's merged why-row.
3. **Keep the `LayoutBuilder` + `SingleChildScrollView` at `wallet_overview.dart:93-105`.** It is
   05-08's shipped safety net, it costs nothing while the content fits (its own comment at :75-81
   proves the gesture arena is untouched at zero scroll extent), and it is what stops a
   `textScaler > 1.0` device from striping the card. Target 268px at scale 1.0; let the scroller
   absorb the rest.
4. **The status row must stay 18px.** That means the label AND the trailing value both render at
   the `labelMd` metric (13 at 18/13). A `bodySm` trailing (20px) silently costs 2px per state.

---

## 2 · The nine compute states - the complete contract

### 2.1 Resolution order (strict, top wins)

An executor that evaluates these in any other order will render the wrong state. In particular
**09 must outrank 02**: `wallet_overview.dart:179` passes `connection?.walletAddress ?? ""` into the
linked-wallet test, so when the node is disconnected *every* wallet tests as "not linked" and the
user is falsely accused.

```
01  selectedWallet == null                                    wallet_overview.dart:120
09  !connection.isConnected                                   sgnus_connection_widget.dart:98
02  connection.walletAddress.isNotEmpty
      && selectedWallet.address != connection.walletAddress   submit_job_dashboard_button.dart:22-23
08  lastProcessingReadThrew == true                           app_bloc.dart:192-195 (NEW state flag)
04  initPercentage < 1.0 && stalled                           NEW stall detector
03  initPercentage < 1.0                                      sgnus_connection_widget.dart:47-50
06  processingStatus == PROCESSING                            genius_api_ffi.dart:1095
07  completedAt != null && now - completedAt < 60s            NEW session-local timestamp
05  otherwise
```

`02` gains the `walletAddress.isNotEmpty` guard; that guard is new and is part of this phase.

### 2.2 The state table

Every label is `gw.textPrimary`. Every subline is `gw.textSecondary`. Every trailing value is
`gw.textPrimary` at the `labelMd` metric with `FontFeature.tabularFigures()`. Only the **dot**
carries hue. This is 017 finding 5 generalised, and it is the reason no per-state label contrast
math is needed.

> **017's `index.html` disagrees with 017's README.** The HTML's `LABEL` map colours the label per
> kind (`ok`→success, `warn`→warning, ...). That map fails in light mode (`statusWarning` is 1.59:1
> on white) and contradicts the README's own finding 5. **The README wins. The HTML LABEL map does
> not ship.**

| # | State | Dot token | Label | Sub-line | Bar? | Trailing | CTA |
|---|---|---|---|---|---|---|---|
| 01 | No wallet | `gw.textSecondary` | `No wallet` | `Select a wallet to use compute` + link `Choose a wallet ›` | no | none | disabled |
| 02 | Not linked | `gw.textSecondary` | `Not linked` | `This wallet is not the one connected to SGNUS` + link `Switch wallet ›` | no | none | disabled |
| 03 | Starting up | `warningAmber` (§5.3) | `Starting up` | `initStatus.message` verbatim | **yes**, `init.percentage` (0-1) | `{pct}%`, 0 decimals | disabled |
| 04 | Stalled | `warningAmber` | `Still starting up` | `initStatus.message` + link `See node status ›` | **no** | none | disabled |
| 05 | Ready | `gw.statusSuccess` | `Ready` | `Node online · waiting for work` | no | `idle` | **enabled** |
| 06 | Processing | `brandPrimaryOnSurface` | `Processing` | none | **yes**, `processingPercentage / 100` | `{pct}%`, 0 decimals | enabled |
| 07 | Job complete | `gw.statusSuccess` | `Job complete` | `Finished · your balance is updating` | no | `just now` | enabled |
| 08 | Status unavailable | `gw.statusError` | `Status unavailable` | `Lost contact with the node` + link `Retry ›` | no | none | enabled |
| 09 | Disconnected | `gw.statusError` | `Disconnected` | `Not connected to the SGNUS network` + link `See node status ›` | no | none | disabled |

### 2.3 The three headline distinctions, spelled out

**05 vs 07** (both green, both idle underneath). Distinct on three of five fields: label
(`Ready` / `Job complete`), sub-line (`Node online · waiting for work` /
`Finished · your balance is updating`), trailing (`idle` / `just now`). State 07 decays to 05 after
the completion window. **Both must never render simultaneously** - 07 outranks 05 in §2.1.

**08 vs 05** - the headline bug. Today both render the grey word `idle`
(`sgnus_connection_widget.dart:125-127`). Here they differ on the dot (`statusError` vs
`statusSuccess`), the label, the sub-line, and 08 alone carries a `Retry ›` link. State 08 is
reachable only once `AppState` carries the new "the last read threw" flag; the flag is what makes
the two states different data, not just different pixels.

**08 vs 05 must not be reachable via the same emit.** `app_bloc.dart:194` currently emits
`isProcessing: false, processingPercentage: 0.0` from the `catch`, which is byte-identical to a
healthy stop. Adding the flag to that emit is the whole fix.

### 2.4 The bar gates on `isProcessing`, never on the percentage

**Say it in the code, not just here.** `app_bloc.dart:184-191` emits the percentage only inside
`if (isProcessing)`. When the SDK reports a clean transition out of PROCESSING, :185 flips the bool
and :190 never runs, so the last percentage survives indefinitely.
**`isProcessing: false, processingPercentage: 87.0` is a reachable, permanent state.**

Three enforcements, in order of strength:

1. **`GWProgressBar` takes a required, non-nullable `double value`.** There is no indeterminate
   mode and no null. If you have no live reading you cannot construct the widget. The API carries
   the rule.
2. The compute tile computes `showBar` from the **state enum only** (03 and 06), never from a
   percentage being non-zero.
3. The trailing `{pct}%` is emitted under the same `showBar` predicate. A percentage without a bar
   is forbidden; a bar without a percentage is impossible.

This also kills the ring for good: 017's rule is **no live percentage → no ring**, and states 04 and
08 are precisely the states with no live percentage. The determinate ring survives only in the 56px
`GWAiFab`, off this surface.

### 2.5 Stall detection - the shape, not the constant

`sgnus_connection_widget.dart:42` polls initialization every **3 seconds**. `app_bloc.dart:138`
polls processing every **1000ms**. The spike figure carried through every planning doc - "161 polls
across 40s" - is ~4 polls/second and matches **neither shipped timer**; it came from the spike's own
loop. So `N consecutive polls` cannot be transcribed from the spike.

Contract: `stalled == (initPercentage unchanged across N consecutive 3s polls)`. Proposal **N = 3**
(9 seconds without movement), because the measured value settles at 0.525 around t = 10.6s and a
9-second freeze after that is already longer than any observed step. **This constant is an OPEN item
(§9.1)** - it is a heuristic over a poll and CONTEXT says so.

State 04's sub-line stays the SDK's own `message`; do not synthesise "2 min" from a timer unless the
elapsed value is genuinely tracked.

---

## 3 · Layout contract - P1 · Twin tiles

### 3.1 Tree

```
DashboardScrollContainer                       (existing, unchanged)
└ LayoutBuilder → SingleChildScrollView        (existing 05-08 net, keep)
  └ Column(crossAxisAlignment: stretch)
    ├ GWKicker('Compute')                                18
    ├ SizedBox(height: space3)                            6
    ├ GWCard · balance tile
    │   └ Column(crossAxisAlignment: stretch)
    │     ├ GWKicker('Balance', dense: true)             16
    │     ├ SizedBox(height: 3)
    │     ├ GWAnimatedNumber(style: numericDisplay,      40
    │     │                  suffix: ' GNUS')
    │     └ if (!showBar) ...[ SizedBox(space2),
    │                          Text('≈ $312.40') ]       22
    ├ SizedBox(height: space6)                           12
    ├ GWCard · compute tile
    │   └ Column(crossAxisAlignment: stretch)
    │     ├ GWKicker('Compute node', dense: true)        16
    │     ├ SizedBox(height: 3)
    │     ├ GWStatusDot(...)                             18
    │     ├ if (subline != null) ...[ SizedBox(space2),
    │     │                           _SublineRow(...) ] 22
    │     └ if (showBar) ...[ SizedBox(space3),
    │                         GWProgressBar(value) ]     10
    ├ SizedBox(height: space6)                           12
    └ GWButton(primary, sm, expand: true)                44
```

### 3.2 Section label - `GWKicker`, not `GWSectionTitle`

CONTEXT locked this on the recommendation; the remeasure makes it decisive.
`GWSectionTitle` costs **62px** (not 44): swapping it in replaces the 24px of kicker+gap and lands
the tallest state at **306px against 274**. It is the correct component for a dashboard panel and it
does not fit. Forcing it means a scroll wrapper this card already had to ship once (05-08 gap B1).

**Record for a later phase:** this card is now the only dashboard panel whose section label is a
kicker rather than a `GWSectionTitle`. The honest fix is more height at the call site
(`dashboard_screen.dart:212`), which is out of this phase's fence.

### 3.3 The `≈ $` subline and the unit clash

CONTEXT keeps 016-B2's unit clash and mitigates it with the fiat subline. Formatting: use the same
`NumberFormat.simpleCurrency().currencySymbol` prefix that `wallet_overview.dart:158` already uses,
so the non-USD locale keeps working. Style:
`numericBody.copyWith(fontSize: 13, height: 18 / 13, color: gw.textSecondary)` - keeps the tabular
figures from `numericBody`, matches the 18px line box the budget assumes, invents no token.

The two feeds still disagree by construction: this card polls the SDK every 10s
(`genius_balance_display.dart:58-61`) and Assets computes from CoinGecko every 60s. 016-B3 (fiat
hero) is the recorded fallback if they visibly diverge in practice.

### 3.4 The CTA

```dart
GWButton(
  variant: GWButtonVariant.primary,      // brandCta gradient fill, gw_button.dart:128-134
  size: GWButtonSize.sm,                 // 44px, the touch floor
  expand: true,
  label: 'New processing job',
  onPressed: ctaEnabled ? () => JobDrawer.show(context) : null,
)
```

**This is the one filled CTA on this surface.** Every other affordance in the card is an inline text
link inside a sub-line. That satisfies the CTA weight rule: fill = commitment (starting a job spends
GNUS irreversibly), outline/link = everything else, max one filled per surface.

`size: md` (48px) would cost 4px and leave 2px of headroom. Use `sm`.

**The button never disappears.** `submit_job_dashboard_button.dart:25-27` returns
`SizedBox.shrink()` when the wallet is not the linked one; it holds both addresses and discards the
information. Here it renders **disabled** in states 01, 02, 03, 04, 09, and the reason plus the way
out live in the compute tile's sub-line. Disabled controls are exempt from WCAG 1.4.3, which is
exactly why the reason must be legible outside the button - it is.

---

## 4 · The four new components

Each entry states what the component owns, what the call site owns, and whether it clears the
promotion bar this repo actually applies (a **third consuming file**, per `gw_kicker.dart:6-13`,
`gw_warning_note.dart:10-13`, `gw_select_row`). Two clear it. Two do not, and saying so is the point.

### 4.1 `GWStatusDot` - CLEARS the Rule of Three

Two shipped forks of this exact atom already exist and are near-identical:

| Fork | Geometry |
|---|---|
| `transaction_displays.dart:99-113` | 6px circle, `SizedBox(width: 5)`, `labelMd.copyWith(w600, color: fg)` |
| `banxa_components/order_status_style.dart:87-99` | 6px circle, `SizedBox(width: 5)`, `labelMd.copyWith(w600, color: fg)` |

The compute status row is the third. **Adopt the shipped geometry verbatim** (6px dot, 5px gap,
`labelMd` w600) - that is what makes this a real extraction rather than a new invention, and it is
also what keeps the status row at 18px (§1.5.4).

```dart
class GWStatusDot extends StatelessWidget {
  const GWStatusDot({
    super.key,
    required this.color,        // dot fill only; the call site picks the semantic token
    required this.label,
    this.labelColor,            // null => gw.textPrimary
    this.trailingValue,         // String?, rendered by the component at the same metric
    this.size = 6,
    this.gap = 5,
  });
}
```

- **Component owns:** the circle, the gap, the label's type (`labelMd` w600), the trailing value's
  type (`labelMd` w600 + `FontFeature.tabularFigures()` so a ticking percentage does not jitter),
  and `mainAxisSize` (`min` when `trailingValue == null`, `max` otherwise - the two pill forks need
  `min`, the compute tile needs `spaceBetween`).
- **Call site owns:** the dot's colour token, any pill wash or padding around it, and the sub-line
  and bar beneath it. **There is no pill in this component.** The two existing forks keep their own
  wash `Container` and pass `labelColor: fg`; the compute tile passes no `labelColor` and gets
  `textPrimary`. That single parameter is what lets one widget serve both a coloured-label pill and
  017-A's neutral-label row.
- **Migration of the two forks is OUT of Phase 14's fence** (transactions is Phase 12/15, Banxa is
  Phase 9). Build the component here with the shipped geometry so those migrations are a
  zero-repaint change later, and file the follow-up.

### 4.2 `GWProgressBar` - does NOT clear the Rule of Three; keep it feature-local

077 says "every bar in the app today is a raw `Container`". Measured: there is exactly one bar-like
thing, `token_info_screen.dart:1284-1308`, and it is a **6px marker positioned on a track**, not a
determinate fill. It cannot migrate to a fill bar. So this phase has **one** consumer.

`GWStatTile`'s promotion at 2 files was an explicit Jakub override on ten instances
(`gw_stat_tile.dart:8-14`). One instance is not that case.

★ **Build it as `_ComputeProgressBar` in the compute panel's own file.** Promote to
`lib/components/data/gw_progress_bar.dart` when a second file needs it. If Jakub prefers the public
component now, that is an override to take explicitly, not by default.

Either way the API is:

```dart
const _ComputeProgressBar({required this.value, this.height = 4});
final double value;   // 0.0-1.0, REQUIRED and non-nullable - see §2.4
final double height;
```

- **Component owns:** clamping to 0-1, the track (`gw.surfaceSunken` + `Border.all(gw.borderSubtle,
  width: 0.5)`, radius `height / 2`), the fill (§5.4), and `SizedBox(height: height, width:
  double.infinity)` so it needs no `LayoutBuilder`.
- **Call site owns:** the decision that a bar renders at all, and the scale conversion (init feed is
  already 0-1; processing feed must be `/ 100`).
- The track recipe is lifted from `token_info_screen.dart:1289-1293` verbatim, so the app has one
  track treatment even though the two bars differ.

### 4.3 `GWCopyRow` - the THIRD consumer of an extraction Phase 23 REFUSED at two

**This is a cross-phase decision. It is raised here, not taken here.**

Phase 23 refused this extraction on a re-measurement (`23-05-PLAN.md:155-166`): the audit claimed
three forks, planning found **two** - `transaction_displays.dart` (`_CopyRow`, :523-600) and
`token_info_screen.dart` (`_CopyAddressRow`, :955-1030) - and two is below the floor. The other
clipboard writers were correctly judged heterogeneous and dangerous to merge (a seed phrase, a
Sentry event id, two checkout URLs, and one site that *clears* the clipboard).

The bridge-hash row in this phase's step 5 is genuinely the same shape as the two forks: label,
truncated mono value, copy glyph, hover, `showAppSnackBar(context, '<label> copied')`. **The premise
of the refusal has changed.**

| Option | Cost | Fence |
|---|---|---|
| **A ★ Build `_JobCopyRow` local to the job flow; file the trigger for Phase 23** | one small widget | clean |
| B Promote `GWCopyRow` now and migrate both forks | touches Phase 12/15 and Phase 7 files | **violates the fence** |
| C Promote `GWCopyRow` now, migrate nothing | a public component with one consumer | half-measure |

★ **A**, defaulting if nobody answers, because CONTEXT:128-132 says the refusal "must be raised, not
silently taken" and B is the option Phase 14 is not allowed to take unilaterally.

API either way:

```dart
const _JobCopyRow({required this.label, required this.value, this.shorten = true});
```

- **Component owns:** the truncation for display (`first 6 … last 6`, per
  `token_info_screen.dart:982-984`), copying the **FULL** value (Phase 23's audited security
  property - `token_info_screen.dart:993` names it), the snackbar, the hover state, the copy glyph,
  and `kGWDetailRowPadding` **inside** the `GestureDetector` so the whole grid cell is the hit target
  (`gw_detail_grid.dart:5-15` explains why the grid does not pad).
- **Call site owns:** wrapping it in `GWDetailGrid(rows: [...])`.
- **Do not import `GWHoverable`.** It is specified in `23-05-PLAN.md` but
  `lib/components/effects/gw_hoverable.dart` **does not exist** in the tree. Roll the `MouseRegion`
  the way both existing forks do.

### 4.4 `GWStepList` - two hosts, not three; keep it feature-scoped

Consumers: the drawer and the `/submit_job` full-screen host. That is two files rendering the same
widget, which is a genuine shared widget but not a `GW*` design-system primitive.

★ **`lib/submit_job/view/widgets/job_step_list.dart`**, feature-scoped, not `lib/components/`.

```dart
class JobStepList extends StatelessWidget {
  const JobStepList({
    super.key,
    required this.steps,
    required this.currentIndex,
    this.onTapStep,          // null => no step is re-openable
  });
}

class JobStep {
  const JobStep({required this.title, this.summary, this.body});
  final String title;      // always shown
  final String? summary;   // the one-line collapse, shown when index < currentIndex
  final Widget? body;      // shown only when index == currentIndex
}
```

- **Component owns:** the index badge (pending / active / done), the vertical connector, the
  collapse rule (`index < currentIndex` → title + summary only), and the fact that **completed steps
  stay on screen** - that is 018-A's entire argument over F2, because step 3 asks the user to confirm
  spending money decided in step 2.
- **Call site owns:** every step body, the footer CTA, and `currentIndex`.
- **Re-opening:** `onTapStep` is non-null only while `currentIndex <= 2` (choose / cost / confirm).
  Once step 4 begins, `bridgeOut` has been dispatched and nothing is re-openable. Pass `null`.

`GWStepBar` (077's fifth "must build") belongs to F2, which was rejected. **Do not build it.**

---

## 5 · Colour and contrast - measured, both themes

Ratios computed with the standard WCAG relative-luminance formula. Calibration: the same routine
reproduces `brandPrimaryOnSurface`'s documented 6.30:1 (`genius_wallet_colors.dart:61-62`),
`GWColors.light()`'s 4.5:1 and 4.8:1 (`gw_colors.dart:115-116`), and `GWWarningNote`'s 7.1:1
(`gw_warning_note.dart:41`) to two decimals.

Surfaces used below:
- **Dark card:** `#0C0E14` (`_surfaceSheenDark`, flat, `genius_wallet_decorations.dart:70-77`).
- **Light card:** gradient `#FFFFFF` → `#F5F7FA` (`:80-84`). Both stops are given; the bottom stop
  is the worst case for dark foregrounds.
- **Tile fill:** `gw.surfaceSunken` - `#06080C` dark, `#CFD4DB` light.

### 5.1 Text - every foreground this spec specifies

| Foreground | Role | On dark card | On light `#FFF` | On light `#F5F7FA` | Verdict |
|---|---|---|---|---|---|
| `gw.textPrimary` (`#FFFFFF` / `#10131A`) | all 9 status labels, trailing values | **19.29:1** | **18.59:1** | **17.32:1** | AA ✓ |
| `gw.textSecondary` (`#8A8F9D` / `#5A606E`) | all sub-lines, `GWWarningNote` body | **5.97:1** | **6.30:1** | **5.87:1** | AA ✓ |
| `gw.textPrimary70` | `GWDetailGrid` row labels | **9.59:1** | **6.90:1** | 6.43:1 | AA ✓ |
| `brandPrimaryOnSurface` (`#0AAEE6` / `#0A6885`) | inline links | **7.54:1** | **6.31:1** | 5.88:1 | AA ✓ |
| `textOnBrand` `#000B18` on `gradientGreen` `#0AD89C` | CTA label, left stop | **10.66:1** | same | same | AA ✓ |
| `textOnBrand` `#000B18` on `gradientBlue` `#0AAEE6` | CTA label, right stop | **7.74:1** | same | same | AA ✓ |

**`brandPrimaryStrong` `#0AAEE6` as a LABEL colour: 2.56:1 on white** [REMEASURE R4 - 017 said 3.0].
`brandPrimary` `#14C8FF` is worse at **1.96:1**. Both fail AA and both fail even the 3:1 large-text
floor. **The processing label stays `gw.textPrimary`; brand paints only the dot and the bar.** That
is 017-A's rule and the remeasure widens its margin.

### 5.2 Status dots - graphical objects, WCAG 1.4.11 floor is 3:1

| Token | Dark value | On dark card | Light value | On light `#FFF` | On light `#F5F7FA` |
|---|---|---|---|---|---|
| `gw.textSecondary` (01, 02) | `#8A8F9D` | 5.97:1 ✓ | `#5A606E` | 6.30:1 ✓ | 5.87:1 ✓ |
| warning amber (03, 04) | `#FFC42E` | 12.11:1 ✓ | **`#FFC42E`** | **1.59:1 ✗** | **1.48:1 ✗** |
| `gw.statusSuccess` (05, 07) | `#0AD89C` | 10.40:1 ✓ | `#07875F` | 4.53:1 ✓ | 4.22:1 ✓ (3:1 floor) |
| `brandPrimaryOnSurface` (06) | `#0AAEE6` | 7.54:1 ✓ | `#0A6885` | 6.31:1 ✓ | 5.88:1 ✓ |
| `gw.statusError` (08, 09) | `#FF4D4D` | 5.90:1 ✓ | `#D92D2D` | 4.81:1 ✓ | 4.48:1 ✓ (3:1 floor) |

The dot is redundant with the label in every state, so 1.4.11 arguably does not bite - but 1.59:1
means the amber dot is *simply not there* on a light card, which is a legibility failure regardless
of which clause applies.

### 5.3 The amber problem - and the fix that already exists

`GeniusWalletColors.statusWarning` `#FFC42E` is a **fill-tuned** token
(`genius_wallet_colors.dart:213`). `GWWarningNote` hit this first and solved it with a local
darkened amber `#92400E` at **7.09:1 on white** (`gw_warning_note.dart:40-42`), and its own
`ponytail` records the ceiling: *"any other consumer of `statusWarning` as a foreground still fails
on light. Upgrade path: an appearance-aware `gw.statusWarning` getter."*

**Phase 14 is that other consumer.**

| Option | Cost | Fence |
|---|---|---|
| **A ★ Add `statusWarning` to `GWColors`** (light `#92400E`, dark `#FFC42E`); fold `gw_warning_note.dart:40-42` into it in the same edit | ~8 lines in `gw_colors.dart` + 2 in the note | touches Phase 3's file - **needs a nod** |
| B File-local `_amber` constant in the compute panel, mirroring the note | 3 lines | clean, but makes it a third hand-derivation of the same value |

★ **A.** It closes a documented ceiling, deletes a duplicate constant rather than adding one, and
`transaction_displays.dart`'s status pill is waiting on the same token (`gw_warning_note.dart:27-29`).
`GWColors` is Phase 3's file with extensions signed off in Phase 11, so **raise it before taking
it** (§9.3). Default to B if the nod does not come; do not ship `#FFC42E` as a light-mode dot.

### 5.4 The progress bar

- **Track:** `gw.surfaceSunken` + `Border.all(gw.borderSubtle, width: 0.5)`, radius `height / 2`.
  Track-vs-card is **1.04:1** dark and **1.49:1** light, so the **hairline is what defines the
  track**, not the fill. That is the same argument `gw_detail_grid.dart:36-39` makes for its own
  well, and it is why `borderSubtle` (not `borderControl`) is right: a decorative separator carries
  no information and has no 1.4.11 threshold.
- **Fill, dark:** `GeniusWalletGradient.brandCta` (`#0AD89C` → `#0AAEE6`). Against the track:
  **10.80:1** and **7.83:1**.
- **Fill, light:** collapse to flat `brandPrimaryOnSurface` `#0A6885`. Against the light track
  `#CFD4DB`: **4.24:1** ✓. The gradient itself would be 1.86:1 / 2.56:1 on a light card - washed
  out and under the 3:1 floor.
- **The collapse is a shipped pattern, not an invention:** `GeniusWalletGradient.brandCtaText()`
  (`genius_wallet_gradient.dart:44-51`) degrades the same gradient to the same token for the same
  reason, and its doc records the same measurements. Reuse the shape:
  `appearanceProxy.computeLuminance() <= 0.5 ? brandCta : flat(brandPrimaryOnSurface)`.

### 5.5 Light-mode items - recorded, not fixed

Dark is this phase's target; light is the dedicated later pass. These do not block:

1. `gw.statusSuccess` light `#07875F` is **4.22:1** on the card's gradient bottom stop `#F5F7FA` -
   under AA **if it is ever used as a label**. This spec never uses it as a label, so it does not
   bite here. Record for the light pass.
2. `gw.statusError` light `#D92D2D` is **4.48:1** on `#F5F7FA` - two hundredths under AA, same
   caveat, same disposition.
3. The amber token (§5.3), which **does** bite and is fixed here.

---

## 6 · The job flow - F1 · Drawer, vertical steps

### 6.1 Host

```dart
ResponsiveDrawer.show<void>(
  context: context,
  title: 'New processing job',
  child: <the step list>,
  footer: <per-step CTA row>,
  // bodyPadding: default kDrawerBodyPadding (20/24/20/20) - the step list is not a
  // scrolling viewport at the panel edge, so the shell's inset is correct.
)
```

420px right-edge panel on desktop, bottom sheet on mobile (`responsive_drawer.dart:98, 104-105`).
The shell owns its insets and the panel is a card (`8044bdb7`); do not re-pad.

**Two provider facts an executor will otherwise get wrong:**

1. `SubmitJobCubit` is created **per route** at `router.dart:299-312`. It is not available anywhere
   on the dashboard.
2. `ResponsiveDrawer.show` uses `useRootNavigator: true` (`:99`). `GeniusApi` and
   `WalletDetailsCubit` do resolve there (`router.dart:302, 305` read them in route builders, which
   sit under the same root), but `SubmitJobCubit` does not.

★ **Create the `SubmitJobCubit` in the dashboard panel's subtree and pass it to the drawer with
`BlocProvider.value`.** Not inside the drawer. The reason is structural: `isDismissible` and
`enableDrag` are fixed at open time (`responsive_drawer.dart:100-101`) and cannot be flipped
mid-flight, so a drawer-owned cubit would be destroyed by a barrier tap during step 4 - which
recreates, exactly, the bug this phase exists to close (the hash becomes unrecoverable). With the
cubit hoisted, dismissing and re-opening returns the user to the result. `/submit_job` keeps its own
route-scoped instance; nothing about that route changes.

### 6.2 The five steps

| # | Step | Body | Footer CTA | Backing call |
|---|---|---|---|---|
| 1 | **Choose a file** | file name once picked; `GWSpinner(size: 20)` + `Preparing your job` while `isFilePickerOpen`; **file errors inline here** | `GWButton(secondary, 'Choose a JSON file')` | `openFilePicker()` `submit_job_cubit.dart:61-116` |
| 2 | **Cost** | `GWDetailGrid` (§6.3) + blocked variants (§6.4) | `GWButton(secondary, 'Continue')`, disabled unless purchaseable | `requestGeniusSDKCost` `:79-81`, `getBridgeOutGasCost` `:118-154` |
| 3 | **Confirm** | one sentence naming irreversibility; step 2's grid stays visible as its collapsed summary | `GWButton(gradient, 'Confirm and pay')` - **the one filled CTA in this drawer** | `bridgeTokens()` `:156` |
| 4 | **In flight** | two labelled operations (§6.5) | **none** | `bridgeOut` `:184-191`, `requestGeniusSDKProcess` `:207-209` |
| 5 | **Result** | one of three terminals (§6.6) | per terminal | `:195-204` / `:210-218` / `:220-222` |

CTA weight across the drawer: steps 1 and 2 are `secondary` (outline - choosing a file and moving on
are not commitments), step 3 is the single `gradient` fill, step 5's terminals each carry at most one
fill. `gradient` pairs with nothing else here, so the `gradientOutline` rule does not apply.

### 6.3 Step 2's cost table

`GWDetailGrid(rows: [...])` - "sunken well, hairline-ruled", exactly its purpose
(`gw_detail_grid.dart:17-21`):

| Label | Value | Source |
|---|---|---|
| `Job cost` | `{jobCost} GNUS` | `state.jobCost` (int) |
| `Bridge gas` | `state.jobGasCost` | already a formatted string, `:146-153` |
| `Your balance` | `{gnusBalance} GNUS` | `state.gnusBalance` (double) |

Row labels `gw.textPrimary70`, values `gw.textPrimary`, both at `bodySm` - mirroring
`transaction_displays.dart:566-571`.

### 6.4 The blocked path, split in two

Today `submit_job_screen.dart:65` computes `isPurchaseable = jobCost != 0 && jobCost < gnusBalance`
and `:167-174` renders one red line for both failure modes. Two bugs in one expression: strictly
`<` blocks a user holding **exactly** the cost, and `jobCost == 0` (cost not yet known) renders
*"You do not have enough GNUS"* - an accusation aimed at a user who has done nothing wrong.

| Condition | Treatment | Copy |
|---|---|---|
| `jobCost == 0` | **Neutral.** `GWSpinner(size: 16)` + a `gw.textSecondary` line. Not amber, not red, no warning frame. | `Working out what this job costs` |
| `jobCost > gnusBalance` | `GWWarningNote` - amber, and it already solved the light-mode `statusWarning` failure | `You need {shortfall} more GNUS to start this job.` |
| `jobCost > 0 && jobCost <= gnusBalance` | CTA enabled | - |

`shortfall = (jobCost - gnusBalance)` formatted to 2 decimals. **The number, not the word "more".**

`jobCost` is `int` and `gnusBalance` is `double` (`submit_job_state.dart:7, 10`), so exact equality
holds for integral balances. A balance that arrives as `4.9999999997` from a unit conversion would
still block a user who has exactly enough - see §9.5.

### 6.5 Step 4 - two operations, because they fail separately

```
●  Bridging GNUS          GWSpinner(size: 16) → check
○  Starting the job       pending → GWSpinner(size: 16) → check
```

`bridgeOut()` (`:184-191`) **spends the money**. `requestGeniusSDKProcess()` (`:207-209`) starts the
work. Only the first is irreversible. Rendering them as one spinner is what let the middle failure
disappear. Copy under the pair: `This can take a minute. Your GNUS is spent once the bridge
completes.`

`GWSpinner` is indeterminate by construction (`gw_spinner.dart:44-52`), which is honest here: the
duration is genuinely unknown. It is **not** a determinate ring, so 017's rule is not violated.

### 6.6 Step 5 - three terminal states, each mapped to a code branch

| Terminal | Code branch | Dot | Title | Body | Footer |
|---|---|---|---|---|---|
| **T1 · Done** | `:220-222` | `gw.statusSuccess` | `Job started` | `GWDetailGrid([_JobCopyRow('Transaction', txHash)])` + `Your balance is updating` | `GWButton(secondary, 'Close')` |
| **T2 · Bridged, not processed** | **`:210-218`** | warning amber (§5.3) | `Tokens sent, job not started` | `GWWarningNote(...)` + `GWDetailGrid([_JobCopyRow('Bridge transaction', bridgeTxHash)])` + the mapped SDK message | `GWButton(gradient, 'Try starting the job again')` + `GWButton(secondary, 'Close')` |
| **T3 · Bridge failed** | `:195-204` | `gw.statusError` | `Nothing was sent` | `The bridge transaction did not go through. No GNUS left your wallet.` + the message | `GWButton(gradient, 'Try again')` + `GWButton(secondary, 'Close')` |

**T2 is the one that matters.** It exists in shipped code today and is thrown away:
`submit_job_cubit.dart:193` binds a **valid, non-null `txHash`**, `:195-204` proves it succeeded, and
then `:211-216` emits `processErrorMessage` **without ever writing the hash to state**. The user
burned GNUS, got a red toast, and has no proof of the burn. The cubit must preserve it - see §8.4.

Two consequences of T2 that are easy to miss:

- `:220`'s `unawaited(fetchGnusBalanceWithDelay())` runs **only on success**. After a burn without a
  job, the displayed balance is stale and nothing refreshes it. **T2 must trigger the same delayed
  refetch** (`:227-230`, the load-bearing hardcoded 5s from 018 finding 4).
- **No result screen may promise a fresh balance before that 5s lands.** T1 and T2 both read
  `Your balance is updating` until the refetch returns; they never show a number that has not
  arrived.

**The result is a step, not a toast.** `submit_job_screen.dart:48-56` calls `resetState()` at :49
*before* raising the toast at :50-55, so the screen empties and the hash lives only in a fading
toast body. `resetState()` moves to the moment the user dismisses step 5.

### 6.7 `/submit_job` as the full-screen host

Kept, per 018-A, for deep links and narrow viewports. **It renders the same `JobStepList` and the
same step bodies** - one widget, two hosts.

```dart
GWScreen(
  maxContentWidth: 640,
  child: Column([GWPageHeader(title: 'New processing job'), JobStepList(...)]),
)
```

**On the deferred `GWScreen` sweep:** 077:70-74 warns that Phase 23 deferred it whole, because
adopting `GWScreen` imposes scroll, a content cap, centring, padding and a background - i.e. it *is*
a layout change. That objection is about screens that do not already impose those. This one does, by
hand: `submit_job_screen.dart:83-88` already builds `ConstrainedBox(maxWidth:
GeniusBreakpoints.large)` + `SingleChildScrollView(padding: EdgeInsets.all(12))` inside an `Align`.
Adopting `GWScreen` here **deletes** that hand-rolled frame; it does not import a new one. Narrow the
cap from `GeniusBreakpoints.large` to 640 because a five-step vertical list at 1200px is a very long
line.

---

## 7 · Copy contract

No em dashes anywhere. Use " - " (space hyphen space). Middle dots (`·`) separate clauses inside a
sub-line and are already used across the app.

### 7.1 Compute panel

| Slot | String |
|---|---|
| Section label | `COMPUTE` (`GWKicker` upper-cases; pass `'Compute'`) |
| Balance tile kicker | `BALANCE` (pass `'Balance'`) |
| Compute tile kicker | `COMPUTE NODE` (pass `'Compute node'`) |
| CTA | `New processing job` (replaces `Create Processing Job`, `submit_job_dashboard_button.dart:32`) |
| 01 label / sub | `No wallet` / `Select a wallet to use compute` + `Choose a wallet ›` |
| 02 label / sub | `Not linked` / `This wallet is not the one connected to SGNUS` + `Switch wallet ›` |
| 03 label / sub | `Starting up` / `initStatus.message` |
| 04 label / sub | `Still starting up` / `initStatus.message` + `See node status ›` |
| 05 label / sub / trailing | `Ready` / `Node online · waiting for work` / `idle` |
| 06 label / trailing | `Processing` / `{pct}%` (0 decimals) |
| 07 label / sub / trailing | `Job complete` / `Finished · your balance is updating` / `just now` |
| 08 label / sub | `Status unavailable` / `Lost contact with the node` + `Retry ›` |
| 09 label / sub | `Disconnected` / `Not connected to the SGNUS network` + `See node status ›` |
| Zero balance | `0.00 GNUS` in normal weight and `gw.textPrimary` - **never** `No funds available` in `statusError` (`wallet_overview.dart:141-148`). A wallet with no funds is not a broken wallet. |

**Percentages render with 0 decimals.** `sgnus_connection_widget.dart:126` prints two decimals on a
number that changes every second; the digits jitter and carry no information.

### 7.2 Job flow

| Slot | String |
|---|---|
| Drawer title | `New processing job` |
| Step 1 title / CTA | `Choose a file` / `Choose a JSON file` |
| Step 1 in progress | `Preparing your job` (replaces `Preparing AI job...`, `submit_job_screen.dart:201`) |
| Step 2 title / CTA | `Cost` / `Continue` |
| Step 3 title / body / CTA | `Confirm` / `This spends {jobCost} GNUS. Bridging cannot be undone.` / `Confirm and pay` |
| Step 4 title / body | `In flight` / `Bridging GNUS` · `Starting the job` · `This can take a minute. Your GNUS is spent once the bridge completes.` |
| Cost unknown | `Working out what this job costs` |
| Not enough GNUS | `You need {shortfall} more GNUS to start this job.` |
| T1 title / row / note / CTA | `Job started` / `Transaction` / `Your balance is updating` / `Close` |
| T2 title / note | `Tokens sent, job not started` / `Your GNUS was bridged but the job did not start. The transaction below is your proof that the transfer happened.` |
| T2 row / CTAs | `Bridge transaction` / `Try starting the job again` + `Close` |
| T3 title / body / CTAs | `Nothing was sent` / `The bridge transaction did not go through. No GNUS left your wallet.` / `Try again` + `Close` |
| Copy confirmation | `Transaction copied` / `Bridge transaction copied` (`showAppSnackBar`, `lib/components/scaffold/scaffold_helper.dart:3`) |

### 7.3 Error titles

`filePickerError` currently carries picker failures, balance failures, token-info failures and
gas-estimate failures, all raised under the toast title **"File Picker Error"**
(`submit_job_screen.dart:32`). Three of the four origins have nothing to do with a file picker. The
split (§8.5) puts each message inline at the step that produced it, so **no title is needed at all**
- the step is the title. The seven mapped SDK process messages
(`submit_job_cubit.dart:258-275`) render verbatim inside T2.

---

## 8 · Non-UI code this design cannot render without

Named here so they land in the plan rather than surfacing mid-execution. Every one is required by a
state or a step above.

| # | Item | Why the UI needs it | Anchor |
|---|---|---|---|
| 8.1 | `AccountDrawer.show(context)` - public entry | State 02's `Switch wallet ›` has no destination otherwise. The mechanism exists in full but is a **private `State` method** with side effects (`setState`, `selectWallet`, a Hive write) at `account_dropdown_selector.dart:165-223`. A public entry must own the cubit + Hive writes and read the current selection from `WalletDetailsCubit` rather than from local state. No new UI. | `:165-223` |
| 8.2 | `RetryProcessingStatus` event + an "unavailable" flag | State 08 cannot exist, and its `Retry ›` cannot be wired. `app_bloc.dart:193` cancels `_processingTimer` **permanently**; nothing restarts it. The flag must be set in the same emit at `:194` that today is byte-identical to a healthy stop. | `:192-195` |
| 8.3 | Stall detector on the init poll | States 03 and 04 are otherwise the same state. Runs on the **3s** timer, not the 1s one. | `sgnus_connection_widget.dart:42` |
| 8.4 | Preserve `txHash` on partial failure | Terminal T2 has nothing to show. The value is bound at `:193` and dropped at `:211-216`. Add a distinct `bridgeTxHash` field so a partial failure is not confused with success (`txHash` non-empty is what `submit_job_screen.dart:48` treats as success). Note `copyWith` cannot null a field (`submit_job_state.dart:43-55`), so `resetState()` must clear it explicitly the way it clears `txHash` at `:239`. | `:193, :210-218` |
| 8.5 | Split the error channels | Each step renders its own failure inline. Minimum split: file/JSON, cost/gas, balance/token-info. | `:37, :54, :89, :104, :110, :131, :149` |
| 8.6 | `jobCost <= gnusBalance`, and `jobCost == 0` as its own state | Success criterion 4; and the false accusation. | `submit_job_screen.dart:65` |
| 8.7 | Surface `GeniusInitStatus.message` | States 03 and 04 have no sub-line otherwise. The SDK already returns it and the widget discards it. **[NEW]** | `sgnus_connection_widget.dart:47-49` |
| 8.8 | Carry the tri-state `GeniusProcessingStatus`, not a bool | `DISABLED` and `IDLE` are currently the same value. **[NEW]** | `app_bloc.dart:180-182`, `genius_api_ffi.dart:1089-1095` |
| 8.9 | Refetch the balance after T2 | The burn happened; only the success path refetches. | `:220` vs `:210-218` |
| 8.10 | Route the 48px balance through the theme | `genius_balance_display.dart:79` (48px default) and `:81` (`Colors.white`). Both close by moving the panel to `GWAnimatedNumber` @ `numericDisplay`, which also returns 8px to the budget. The old widget stays for its other call sites. | `:79, :81` |

---

## 9 · Open items - genuine gaps, not invented answers

1. **Stall detector `N`.** The init poll is 3s; the "161 polls / 40s" figure in every planning doc
   matches no shipped timer. Proposal N = 3 (9s frozen). Needs a decision or a fresh measurement on
   device.
2. **`GWCopyRow` promotion (§4.3).** Cross-phase: Phase 23 refused it at two forks and this is the
   third. Default taken here is the feature-local widget plus a filed trigger. Phase 23's call.
3. **`gw.statusWarning` token (§5.3).** Adding it touches `gw_colors.dart`, which is Phase 3's file
   (extensions signed off in Phase 11). Default if unanswered: file-local constant.
4. **Can `requestGeniusSDKProcess` be re-called after a successful `bridgeOut` without re-burning?**
   T2's `Try starting the job again` CTA depends on it. Nothing in `genius_api.dart` or the FFI
   header answers this. **If the answer is no, T2 loses its CTA and becomes informational only** -
   it still ships, because showing the hash is the point.
5. **Float boundary on `jobCost <= gnusBalance`.** `jobCost` is `int`, `gnusBalance` is `double`. A
   balance that arrives as `4.9999999997` still blocks a user with exactly enough. Round both to the
   same precision before comparing, or compare in the smallest unit.
6. **State 07's window.** How long does `Job complete` persist before decaying to `Ready`? Proposal
   60s, session-local (lost on restart, which is acceptable - it is a transient acknowledgement, not
   a record).
7. **State 06 has no sub-line** because there is nothing honest to put there. 017 proposed
   `style-transfer.json · ~4 min left`: the filename lives in a route-scoped cubit the panel cannot
   read (`router.dart:299-312`) and is wiped by `resetState()` (`:237`); the ETA has no API at all.
   If §6.1's hoisted cubit lands, the filename becomes available and the sub-line can be revisited -
   it costs 22px, and state 06 has 40px spare.
8. **`GeniusInitStatus.message`'s actual strings have never been seen** (nothing reads it today).
   States 03/04's sub-lines are the SDK's words, so verify on device before locking the copy, and
   ship a static fallback for the empty case.
9. **The 2px brand cap on the balance tile while a job runs** (016, carried from B4) is not in
   CONTEXT and not in 076/077. It costs 2px and applies only in state 06, which has 40px spare, so
   it is affordable. **Recorded, not specified** - add it only if asked.
10. **Light-mode margins** in §5.5 items 1 and 2. Deferred to the light pass by the dark-first rule.

---

## 10 · Verification - ordinary `flutter test` only

No goldens, no snapshot or pixel-diff tooling, no `integration_test`, no `patrol`, no Playwright, no
new dependencies. Declined twice, explicitly. Everything below runs in the existing suite in the
existing style, and every technique already has a precedent in this repo.

| # | File | What it proves | Precedent |
|---|---|---|---|
| V1 | `test/dashboard/compute_state_test.dart` | The **pure** `resolveComputeState()` returns the right state for each of the nine triggers **and honours §2.1's precedence** (09 before 02, 08 before 04, 07 before 05). Plus the two traps: `isProcessing:false, processingPercentage:87.0` yields no bar, and `DISABLED` ≠ `IDLE`. | plain unit tests, e.g. `test/markets_sort_test.dart` |
| V2 | `test/dashboard/compute_state_distinct_test.dart` | **Success criterion 1**, without a golden: build the view model for all nine states, collect `(label, subline, trailing, showBar, dotColor)` and assert the nine tuples are **pairwise distinct**. This is a stronger check than a screenshot, because it fails on the *reason* two states look alike. | - |
| V3 | `test/dashboard/compute_panel_height_test.dart` | **Success criterion 2, measured not estimated**: pump the panel for each of the nine states inside `DashboardScrollContainer` inside `ConstrainedBox(maxHeight: 300)` and assert `tester.getSize(...).height <= 274`. | `transactions_page_frame_test.dart:239`, `transaction_filter_rail_test.dart:454` |
| V4 | `test/theme/compute_contrast_test.dart` | Every dot ≥ 3:1 and every text foreground ≥ 4.5:1 against its surface, **in both appearance modes**. Import `contrastRatio` from `test/theme/theme_contrast_test.dart:15-21` - its own doc says *"do not add a second implementation"*. | `test/theme/theme_contrast_test.dart`, `nav_chip_style_test.dart` |
| V5 | `test/submit_job/job_flow_test.dart` | All **three** terminal branches are reachable and each renders its own content; T2 exposes a non-empty bridge hash; the purchaseable boundary allows `jobCost == gnusBalance` and rejects `jobCost == 0` without accusing the user. | cubit tests in the existing style |

**Making V1-V3 possible is a design requirement, not a testing afterthought.** The nine states must
resolve in a **pure function over plain values** (`ComputeState resolveComputeState({...})`) returning
a **plain view model** (`ComputeStatusView { dotRole, label, subline, showBar, barValue, trailing,
ctaEnabled }`). If the state logic lives inside `build()`, none of V1-V3 can be written without the
tooling that was declined. Put the function in its own file with no Flutter import beyond `Color`.

Also unchanged and non-negotiable: `flutter analyze` stays at 0, the suite stays green,
`tool/check_brace_style.sh --count` stays at 0 (every `if` braced, body on its own line).

---

## 11 · Scope fence

**In:** the dashboard's first card; the nine states; the job flow end to end including its three
terminal states; `/submit_job` re-skinned as the full-screen host; §8's ten code items; the five
shipped bugs.

**Out:** `/network` re-skin (sketch 023) · the `+earned` readout (no API) · `View transaction ›` (no
job→tx correlation, and the budget has 6px, not 20) · balances and holdings elsewhere on the
dashboard (Phase 5) · migrating the two `GWStatusDot` forks (Phases 9, 12/15) · migrating the two
copy-row forks (Phase 23) · the `GWScreen` sweep beyond `/submit_job` itself · light-mode-only
issues (dedicated later pass) · the de-hex of the 525 raw colour references · deleting
`GeniusWalletColors` (demote to private primitives only; `GWColors` stays semantic).
