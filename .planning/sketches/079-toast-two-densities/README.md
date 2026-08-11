# 079 · the toast, two densities, safe-area aware

**Asked for:** redesign the toast, and make sure it is actually used across the app — the best
user-friendly way **for mobile specifically**.

**Settled before this sketch** (Braian, 2026-08-08): the toast stays at the **top**, becomes
**safe-area aware**, is dismissed by **swiping up**, and one component carries **two densities**.
This sketch shows what that looks like; it does not re-open those three.

## Recommendation

**A + B together — one `ToastWidget`, a `ToastDensity` enum, card for alerts and compact for
confirmations.** Neither is useful alone: the whole argument for the compact pill is that today's
card is wrong for "Link copied", and the whole argument for keeping the card is that a pill is
wrong for "Verification failed".

## The app ships two notification systems

| | Sites | How it looks |
|---|---|---|
| `ToastManager` | 26 | On-brand; colours re-derived in 23-03 with measured ratios in both modes |
| `showAppSnackBar` helper | 26 | Unstyled Material default |
| Direct `showSnackBar` | 6 | Unstyled Material default |

`snackBarTheme` is **not defined in `theme.dart`** (0 references), so 32 of the app's notifications
are Material's grey pill in Roboto at the bottom of the screen, under the dock.

**The migration is one function.** `showAppSnackBar` is 18 lines serving 26 callers — point its body
at `ToastManager` and 26 sites convert with no call-site churn. Then 6 direct calls by hand.

Two findings that shrink it further:

1. **Zero callers pass an `action`.** The parameter is dead. The toast needs no action slot, and the
   question of how to render one disappears.
2. **4 callers pass `backgroundColor`** — hand-rolling what `ToastType` already encodes.

## What is wrong today, measured

| Defect | Where | Consequence |
|---|---|---|
| No safe-area awareness | `toast_manager.dart:33` | `top: 100.0` is a literal; **zero** references to `MediaQuery.padding` / `viewPadding` / `SafeArea` in the file. On a 14 Pro the top inset is 44–59pt before the 60pt header. |
| Full-bleed | `left: 0, right: 0`, `maxWidth: infinity` | Touches both screen edges — which is why it needs a 2px ring to look contained |
| Close target ~28pt | icon 20 + padding 4 | Below the 44pt adopted for chips in phase 25, and at the top of the screen where a thumb cannot reach |
| **Never announced** | no `Semantics` | VoiceOver/TalkBack say nothing. For an error toast this is an accessibility failure, not a nicety |
| Uncapped stack | `100 + n × 85` | 4th toast at 355px, 6th off screen |
| Raw numbers | 16 / 12 / 8 / 4 / 36 / 2 | Predates the token discipline; `TextStyle(fontSize: 16)` rather than typography tokens |
| One 5s duration | `toast_manager.dart:17` | Too long for "Link copied", too short for a two-line error |
| `SelectableText` | `toast_widget.dart:87` | Selection inside a 5s transient, competing with the dismiss gesture |

## Why two densities

The 26 toast calls are **14 success · 13 warning · 3 error**; the 32 SnackBars are mostly
*"Link copied"*, *"Checkout link copied"*, *"Order ${status}"*. Two different jobs:

- **Ambient** — the user just tapped copy; they already know. A bordered card with a bold title, a
  36px icon and a close button shouts a receipt at them. → compact, ~2s, no close, no title.
- **Alert** — something failed and the user did not ask. → card, dismissible, longer, announced
  assertively.

## Mobile specifics

- **The offset is derived, never guessed:** `padding.top + kHeaderHeight + space4` = 44 + 60 + 8 =
  **112** on a 14 Pro, and correct by construction elsewhere.
- **Swipe up is primary.** The top of a phone is out of thumb reach, so a 44pt button there is still
  a stretch — the gesture carries dismissal, the button is the fallback. A grab handle advertises it.
- **Duration scales with length** — ~2s compact, 5s card.
- **Reduced motion** — the 300ms slide is currently unconditional; cross-fade when the OS asks.
- **Bottom was considered and rejected.** `kMobileBarHeight` 60 + dock overhang + bottom inset means
  a bottom toast either covers the nav or floats ~90px above it, reading as detached. Top also
  matches where iOS puts system banners, which suits a wallet's alerts.

## Colours are not being redesigned

Every value is the shipping token in both modes, from 23-03: success `#0AD89C` / `#07875F`
(4.5:1 on white), error `#FF4D4D` / `#D92D2D` (4.8:1), surface `#0C0E14` / `#FFFFFF`, secondary text
`#8A8F9D` / `#5A606E`. **The accent moves from a 2px full ring to a 4px leading edge — same colour,
less ink.** Title and message stay on the neutral ladder, so the toast never depends on a status
colour for legibility.

## Open for the walk

The compact pill is **centred, auto-width**; the card is **full-width inset**. Deliberate — auto-width
reads ambient, full-width reads alert — but two densities on one stack then do not share a left edge.
Variant C shows exactly that case. Worth seeing on the device before it is built.

## Not decided here

- Whether `ToastType.warning` and `.error` should differ in duration.
- Whether the 4 `backgroundColor` callers map to `warning` or `error` — needs reading each.
