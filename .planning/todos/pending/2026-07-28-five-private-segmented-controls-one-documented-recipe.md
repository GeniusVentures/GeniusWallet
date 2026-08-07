# Five private segmented controls, one documented recipe, no component

**Found:** 2026-07-28, quick 260728-s9k, while building the add-account method switch.
**Type:** component drift. No user-visible defect - every copy currently follows the recipe.

## The recipe exists and is written down

`.planning/codebase/CONVENTIONS.md` § **Control track (segmented control / filter bar)** fixes it:

| Part | Value |
|---|---|
| Fill | `gw.surfaceSunken` |
| Border | `Border.all(color: gw.borderSubtle)` |
| Radius | `GeniusWalletConsts.radiusPill` |
| Track padding | `EdgeInsets.all(3)` |
| Gap between chips | `SizedBox(width: 2)` |

Its own note says *"the recipe is fixed - partial adoption reads as a different design language on
the same screen"*, and at the time of writing it said **two exist today**.

## Five exist now

| where | what it switches |
|---|---|
| `dashboard/home/view/dashboard_screen.dart:674` `_TimeframeSegment` | 1H / 1D / 1W / 1M / 1Y |
| `dashboard/chart/markets_hero_card.dart:427` `_TimeframeSegment` | the same five, a second copy |
| `dashboard/home/widgets/transactions_slim_view.dart` filter track | transaction filters |
| `squid_router/swap_settings_drawer.dart` `_PresetChip` | 0.1 / 0.5 / 1 % - chips without the track |
| `account/sdk_account_manager.dart` `_AddAccountForm._modeChip` | recovery phrase / private key |

All private, none reachable from another file. Two of them (`_TimeframeSegment`) are the **same
control with the same five labels**, duplicated across two files.

## Why it was not fixed in 260728-s9k

Building `GWSegmentedControl` there would have shipped a component with **one** consumer, which
fails the promotion test the last three components were held to: `GWKicker` was promoted from five
hand-written copies (065), `GWSelectRow` from a fourth consumer (068), and `_CopyRow` was
deliberately **left private** at one consumer (154). Promoting this needs the migration, and the
migration is not a drawer task.

## What the work is

1. `GWSegmentedControl` in `lib/components/inputs/`, built to the CONVENTIONS recipe, taking labels
   and a selected index.
2. The two `_TimeframeSegment`s collapse into it first - they are literally the same control, so
   that alone is the strongest argument for the component.
3. Then the transactions filter track and the SDK method switch.
4. `_PresetChip` is the judgement call: it is chips **without** a track (three separate bordered
   chips, `radiusSm`), so it may be a genuinely different control rather than a fifth copy. Decide
   rather than assume.

## Related

- `.planning/todos/pending/2026-07-28-drawer-input-fields-are-hand-assembled-while-gwtextfield-exists.md`
  - the same shape of finding for input fields, deferred for the same reason.

---

**UPDATE 2026-08-07 — the number in the title is now wrong: three, not five.**

- `dashboard_screen.dart` `_TimeframeSegment` — **gone**, moved onto `GWTimeframeSegment` (PR #221).
- `markets_hero_card.dart` `_TimeframeSegment` — **gone**, deleted by quick `260807-bxs` (`5119d84`);
  the shared component gained optional `labels`/`onChanged` to absorb it.

Still open: `_FilterChip` (`transactions_slim_view.dart`), `_PresetChip`
(`swap_settings_drawer.dart`), `_modeChip` (`sdk_account_manager.dart`).
