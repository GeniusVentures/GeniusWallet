# Five Material text slots are unmapped, so anything unstyled falls back to Roboto

**Found:** 2026-07-28, auditing the drawer overflow menus. Jakub, on a walk: *"sprawdź ten dropdown
czy tam font i reszta się zgadza"*. The font did not.
**Type:** typography gap. Real and visible, but only where a widget is not explicitly styled.

## What is mapped, and what is not

`GeniusWalletTypography.toMaterialTextTheme()` fills **10 of Material's 15** slots:

```
displayLarge  displayMedium  headlineLarge  headlineMedium
titleLarge    titleMedium    bodyLarge      bodyMedium
bodySmall     labelMedium
```

Unmapped: **`displaySmall`, `headlineSmall`, `titleSmall`, `labelLarge`, `labelSmall`.**

`ThemeData` merges the supplied `TextTheme` over the platform default, so an unmapped slot keeps
Material's own typography - **Roboto**, at Material's size/weight/tracking. Every mapped token is
Inter (`GeniusWalletTypography._inter`), and `ThemeData` sets no global `fontFamily`, so there is
nothing else catching the gap.

## Where it actually showed

**`labelLarge` is the button/menu label slot.** `MenuItemButton` renders its child in it, so every
overflow menu in the app - the wallet drawer's per-row "..." and the SDK drawer's - was drawing its
labels in Roboto 14/w500/0.1 next to Inter everywhere else. Close enough to look merely "off"
rather than obviously wrong, which is why it survived.

Also on `labelLarge`: bare `TextButton` / `OutlinedButton` / `ElevatedButton` labels (the seven
drawers still shipping raw `OutlinedButton` footers), and `SnackBarAction`.

## What was done instead, and why not this

Quick 260728-s9k fixed the menus **locally**, via a new `menuButtonTheme` in `theme.dart` carrying
`GeniusWalletTypography.bodySm`. That was deliberate: mapping `labelLarge` globally also re-types
every bare text button and snackbar action in the app, which is a change that deserves its own walk
rather than riding along with a drawer fix.

## What the work is

1. Decide the token for each of the five. `labelLarge` is the only one with an obvious answer
   (a 14/w500 Inter style); `titleSmall`, `labelSmall`, `headlineSmall` and `displaySmall` have no
   existing token and may want new ones - or may want to stay unmapped deliberately, which is a
   valid answer as long as it is written down.
2. Map them, then walk the surfaces that use them - buttons, snackbars, list tiles, chips.
3. If a slot is intentionally left unmapped, say so in a comment in `toMaterialTextTheme()`, so the
   next person auditing a font does not have to re-derive this.

## Related

- `lib/theme/theme.dart` `menuButtonTheme` - the local fix, with the reasoning in place.
