import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// App theme. Re-evaluated whenever [GWAppearance] changes (main.dart wraps
/// MaterialApp in a ValueListenableBuilder), so the appearance-aware tokens
/// resolve for the active mode.
ThemeData getThemeData() {
  final isLight = GWAppearance.isLight;
  final colorScheme = isLight
      ? ColorScheme.light(
          primary: GeniusWalletColors.brandPrimary,
          onPrimary: GeniusWalletColors.textOnBrand,
          secondary: GeniusWalletColors.brandSecondary,
          onSecondary: GeniusWalletColors.textOnBrand,
          tertiary: GeniusWalletColors.brandTertiary,
          onTertiary: GeniusWalletColors.textPrimary,
          surface: GeniusWalletColors.surfaceElevated,
          onSurface: GeniusWalletColors.textPrimary,
          surfaceContainerHighest: GeniusWalletColors.surfaceMenu,
          error: GeniusWalletColors.statusError,
          // Kept as develop's original literal value (not Alex's
          // GeniusWalletColors.foundationWhite, which does not exist in this
          // codebase and would be a new token addition outside this
          // theme-only plan's file scope) -- functionally identical: white
          // text always reads on the saturated error red in both modes.
          onError: Colors.white,
          outline: GeniusWalletColors.brandPrimary,
          outlineVariant: GeniusWalletColors.surfaceMenu,
        )
      : ColorScheme.dark(
          primary: GeniusWalletColors.brandPrimary,
          // textOnBrand (near-black), matching the light scheme — white on the
          // bright brand fill failed WCAG AA for Material widgets in dark mode.
          onPrimary: GeniusWalletColors.textOnBrand,
          secondary: GeniusWalletColors.brandSecondary,
          onSecondary: GeniusWalletColors.textOnBrand,
          tertiary: GeniusWalletColors.brandTertiary,
          onTertiary: GeniusWalletColors.textPrimary,
          surface: GeniusWalletColors.surfaceElevated,
          onSurface: GeniusWalletColors.textPrimary,
          surfaceContainerHighest: GeniusWalletColors.surfaceMenu,
          error: GeniusWalletColors.statusError,
          onError: Colors.white,
          outline: GeniusWalletColors.brandPrimary,
          outlineVariant: GeniusWalletColors.surfaceMenu,
        );

  return ThemeData(
    useMaterial3: true,
    brightness: isLight ? Brightness.light : Brightness.dark,
    // Solid canvas for interior screens (black in dark mode, white in light).
    // Auth / Landing wrap the body in GWMeshBackground for the branded mesh.
    scaffoldBackgroundColor: GeniusWalletColors.surfaceBase,
    primarySwatch: Colors.blue,
    colorScheme: colorScheme,
    // GWColors ThemeExtension -- makes the appearance-aware tokens available
    // via Theme.of(context).extension<GWColors>() so `const` widgets that
    // read it register an InheritedWidget dependency and rebuild on a live
    // appearance toggle (fixes the const-rebuild bug the 04-01 D-02 re-walk
    // surfaced; see .planning/todos/pending/2026-07-18-const-widgets-do-not-
    // re-skin-on-live-appearance-toggle.md). MUST be present for BOTH modes
    // in this single ThemeData return -- getThemeData() re-runs per toggle,
    // so this one conditional entry covers both; a missing attachment would
    // leave consumers on their fail-soft `?? GWColors.dark()` default, which
    // is dark-only, silently rendering the app dark in light mode too.
    extensions: <ThemeExtension<dynamic>>[
      isLight ? GWColors.light() : GWColors.dark(),
    ],
    textTheme: GeniusWalletTypography.toMaterialTextTheme(),
    // Not const: the on-surface brand getter below is appearance-aware, not
    // a compile-time constant. Light was 1.96/1.74/1.48:1 on
    // surfaceElevated/surfaceMenu/surfaceBase (AA fail); the token clears
    // 6.30/5.61/4.76:1. Dark moves brandPrimary -> brandPrimaryStrong,
    // 9.86 -> 7.54:1, still well clear.
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: GeniusWalletColors.brandPrimaryOnSurface,
    ),
    tabBarTheme: TabBarThemeData(
      unselectedLabelStyle: GeniusWalletTypography.titleMd,
      labelStyle: GeniusWalletTypography.titleMd,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: GeniusWalletColors.textPrimary,
      dividerColor: Colors.transparent,
      unselectedLabelColor: GeniusWalletColors.textSecondary,
      // Light was 2.56/2.28/1.93:1 (AA fail); the token clears
      // 6.30/5.61/4.76:1. Dark byte-identical (token = brandPrimaryStrong).
      indicatorColor: GeniusWalletColors.brandPrimaryOnSurface,
    ),
    datePickerTheme: DatePickerThemeData(
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GeniusWalletColors.brandPrimary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: GeniusWalletColors.brandPrimary,
            width: 1,
          ),
        ),
      ),
      backgroundColor: GeniusWalletColors.surfaceElevated,
      headerBackgroundColor: GeniusWalletColors.brandPrimaryStrong,
      // theme.dart:36-38 already rejects white-on-brandPrimaryStrong for
      // ColorScheme.onPrimary (2.56:1, AA fail); this header foreground had
      // the same defect. The near-black on-brand foreground below moves it
      // 2.56 -> 7.74:1 in dark, 7.26 -> 7.74:1 in light.
      headerForegroundColor: GeniusWalletColors.textOnBrand,
      todayBorder: const BorderSide(
        color: GeniusWalletColors.brandPrimary,
        width: 2,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GeniusWalletColors.brandPrimaryStrong;
        }
        return GeniusWalletColors.brandPrimary.withAlpha(33);
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          // theme.dart:36-38 already rejects white-on-brandPrimaryStrong for
          // ColorScheme.onPrimary (2.56:1, AA fail); the selected day label
          // had the same defect. The near-black on-brand foreground below
          // moves it 2.56 -> 7.74:1 in dark, 7.26 -> 7.74:1 in light.
          // Disabled/default branches below sit on a transparent cell over
          // surfaceElevated and stay as-is.
          return GeniusWalletColors.textOnBrand;
        }
        if (states.contains(WidgetState.disabled)) {
          return GeniusWalletColors.textTertiary;
        }
        return GeniusWalletColors.textPrimary;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GeniusWalletColors.brandPrimaryStrong;
        }
        if (states.contains(WidgetState.dragged)) {
          return GeniusWalletColors.brandPrimary.withAlpha(51);
        }
        return Colors.transparent;
      }),
      rangeSelectionBackgroundColor: GeniusWalletColors.brandPrimary.withAlpha(
        38,
      ),
      rangeSelectionOverlayColor: WidgetStateProperty.all(
        GeniusWalletColors.brandPrimary.withAlpha(51),
      ),
    ),
    appBarTheme: AppBarTheme(
      iconTheme: const IconThemeData(size: 24),
      titleTextStyle: GeniusWalletTypography.titleLg,
      titleSpacing: GeniusWalletConsts.space4,
      centerTitle: true,
      surfaceTintColor: GeniusWalletColors.surfaceElevated,
      backgroundColor: GeniusWalletColors.surfaceElevated,
    ),
    // --- Preserved from develop (absent from Alex's reference; each has a
    // live consumer in this repo per 04-RESEARCH.md §1) -----------------
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: GeniusWalletConsts.space8,
        ),
        textStyle: GeniusWalletTypography.titleMd,
        // develop hardcoded Colors.white (only ever rendered against the old
        // permanently-dark theme); made appearance-aware here so
        // sdk_account_manager.dart's two footer OutlinedButton.icon widgets
        // (which set no inline style) stay legible in light mode too (D-03).
        foregroundColor: GeniusWalletColors.textPrimary,
      ),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      borderRadius: BorderRadius.circular(
        GeniusWalletConsts.borderRadiusButton,
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: GeniusWalletConsts.space8,
        ),
        textStyle: GeniusWalletTypography.titleMd,
      ),
    ),
    dialogTheme: const DialogThemeData(
      actionsPadding: EdgeInsets.all(GeniusWalletConsts.space6),
    ),
    // --- end preserved section -------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => Colors.transparent,
        ),
        surfaceTintColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => Colors.transparent,
        ),
        textStyle: WidgetStatePropertyAll(GeniusWalletTypography.titleMd),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space8,
            vertical: GeniusWalletConsts.space10,
          ),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: GeniusWalletColors.brandPrimary, width: 1),
            borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.radiusLg),
            ),
          ),
        ),
        backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return GeniusWalletColors.textTertiary;
          }
          return GeniusWalletColors.textPrimary;
        }),
        iconSize: const WidgetStatePropertyAll(20),
        iconColor: WidgetStatePropertyAll(GeniusWalletColors.textPrimary),
      ),
    ),
    // Not const: the on-surface brand getter below is appearance-aware, not
    // a compile-time constant.
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(GeniusWalletConsts.space10),
      focusedBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(
          Radius.circular(GeniusWalletConsts.radiusLg),
        ),
        // Widest blast radius in this task -- every TextField/TextFormField
        // app-wide. Light was 2.56/2.28/1.93:1 (AA fail); the token clears
        // 6.30/5.61/4.76:1. Dark byte-identical.
        borderSide: BorderSide(color: GeniusWalletColors.brandPrimaryOnSurface),
      ),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.radiusLg),
        ),
      ),
      // finding 36 / UI-SPEC §1.2: Alex's reference drops this entirely --
      // must survive the reconcile explicitly, every TextField/TextFormField
      // app-wide depends on labels staying pinned above the field.
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(GeniusWalletTypography.titleMd),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space12,
            vertical: GeniusWalletConsts.space10,
          ),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.radiusLg),
            ),
          ),
        ),
        backgroundColor: WidgetStateProperty.resolveWith<Color?>(
          (states) => GeniusWalletColors.btnFilter,
        ),
        foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
          if (states.contains(WidgetState.disabled)) {
            return GeniusWalletColors.textTertiary;
          }
          return GeniusWalletColors.textPrimary;
        }),
        iconSize: const WidgetStatePropertyAll(16),
        iconColor: WidgetStatePropertyAll(GeniusWalletColors.textPrimary),
      ),
    ),
    searchBarTheme: SearchBarThemeData(
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space6),
      ),
      textStyle: WidgetStatePropertyAll(GeniusWalletTypography.bodyLg),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(GeniusWalletConsts.radiusXs),
          ),
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(
        GeniusWalletColors.surfaceElevated,
      ),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: GeniusWalletColors.brandPrimary,
      selectionColor: GeniusWalletColors.textSecondary,
    ),
    dropdownMenuTheme: DropdownMenuThemeData(
      textStyle: GeniusWalletTypography.bodyLg,
      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(
          GeniusWalletColors.surfaceElevated,
        ),
      ),
      // Not const: the on-surface brand getter below is appearance-aware,
      // not a compile-time constant.
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(GeniusWalletConsts.radiusPill),
          ),
          // Light was 2.56/2.28/1.93:1 (AA fail); the token clears
          // 6.30/5.61/4.76:1. Dark byte-identical.
          borderSide: BorderSide(
            color: GeniusWalletColors.brandPrimaryOnSurface,
          ),
        ),
        contentPadding: const EdgeInsets.only(left: GeniusWalletConsts.space10),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(GeniusWalletConsts.radiusPill),
          ),
        ),
      ),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: GeniusWalletColors.surfaceElevated,
      indicatorColor: Colors.transparent,
      selectedLabelTextStyle: const TextStyle(
        color: GeniusWalletColors.brandPrimaryStrong,
      ),
      labelType: NavigationRailLabelType.none,
      useIndicator: false,
      selectedIconTheme: const IconThemeData(
        color: GeniusWalletColors.brandPrimaryStrong,
        size: 30,
      ),
      unselectedIconTheme: IconThemeData(
        color: GeniusWalletColors.textPrimary,
        opacity: 1,
        size: 30,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      elevation: 0,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: GeniusWalletColors.brandPrimaryStrong,
      selectedIconTheme: const IconThemeData(
        size: 35,
        color: GeniusWalletColors.brandPrimaryStrong,
      ),
      unselectedIconTheme: IconThemeData(
        size: 35,
        color: GeniusWalletColors.textPrimary,
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      // Not const: the on-surface brand getter below is appearance-aware,
      // not a compile-time constant. Light was 1.96/1.74/1.48:1 (AA fail);
      // the token clears 6.30/5.61/4.76:1. Dark moves brandPrimary ->
      // brandPrimaryStrong, 9.86 -> 7.54:1, still well clear.
      side: BorderSide(color: GeniusWalletColors.brandPrimaryOnSurface),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        // theme.dart:36-38 already rejects white-on-brandPrimaryStrong for
        // ColorScheme.onPrimary (2.56:1, AA fail); the checkmark had the
        // same defect. The near-black on-brand foreground below moves it
        // 2.56 -> 7.74:1 in dark, 7.26 -> 7.74:1 in light.
        return GeniusWalletColors.textOnBrand;
      }),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return GeniusWalletColors.brandPrimaryStrong;
      }),
    ),
    // Preserved from develop (absent from Alex's reference) -- settings_screen.dart
    // (and 6 other files) call bare Divider(); Alex leaves this unset, which
    // would fall back to Material 3's colorScheme.outlineVariant default.
    dividerTheme: DividerThemeData(color: colorScheme.surfaceContainerHighest),
    // The container for every `MenuAnchor` overflow menu -- the wallet drawer's
    // per-row "..." and the SDK drawer's.
    //
    // `backgroundColor` moved here 2026-07-28: both call sites were passing
    // their own `MenuStyle(backgroundColor:, shape:)` under a comment claiming
    // "the reconciled theme no longer supplies menuTheme", which was **false** --
    // this entry has been here the whole time and its own comment says it was
    // kept for exactly those two menus. Two files were duplicating a style on a
    // premise the file below them contradicted.
    //
    // `surfaceMenu` is what the token is named for: a menu floats ABOVE a
    // panel, and after 156-A that panel is `surfaceElevated`, so a menu painted
    // the same value would have no edge.
    menuTheme: MenuThemeData(
      style: MenuStyle(
        // surfaceContainerHighest is where the scheme maps `surfaceMenu` (see the
        // ColorScheme above); `surfaceContainer` is an M3-derived value and would
        // not be our token.
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.surfaceContainerHighest,
        ),
        // M3 tints an elevated surface with the primary colour. The menu's
        // colour is a decision, not a derivation, so the tint is off.
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard),
            ),
          ),
        ),
      ),
    ),
    // The menu ITEM, which nothing was styling. `MenuItemButton` renders its
    // label in `textTheme.labelLarge` -- and `toMaterialTextTheme()` does not
    // map `labelLarge`, so every menu row in the app was rendering in Material's
    // default typography (Roboto 14/w500/0.1) instead of Inter. That is the
    // "font się nie zgadza" a walk picks up without being able to name it.
    //
    // Fixed HERE rather than by mapping `labelLarge` globally: that slot also
    // drives every bare TextButton and SnackBarAction, so re-typing it app-wide
    // is its own decision with its own walk. A todo is filed.
    menuButtonTheme: MenuButtonThemeData(
      style: ButtonStyle(
        textStyle: WidgetStatePropertyAll(GeniusWalletTypography.bodySm),
      ),
    ),
    buttonTheme: const ButtonThemeData(padding: EdgeInsets.zero),
  );
}
