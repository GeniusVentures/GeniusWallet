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
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GeniusWalletColors.brandPrimary,
    ),
    tabBarTheme: TabBarThemeData(
      unselectedLabelStyle: GeniusWalletTypography.titleMd,
      labelStyle: GeniusWalletTypography.titleMd,
      indicatorSize: TabBarIndicatorSize.tab,
      labelColor: GeniusWalletColors.textPrimary,
      dividerColor: Colors.transparent,
      unselectedLabelColor: GeniusWalletColors.textSecondary,
      indicatorColor: GeniusWalletColors.brandPrimaryStrong,
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
      headerForegroundColor: GeniusWalletColors.textPrimary,
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
          return GeniusWalletColors.textPrimary;
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
      rangeSelectionBackgroundColor:
          GeniusWalletColors.brandPrimary.withAlpha(38),
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
        textStyle: WidgetStatePropertyAll(
          GeniusWalletTypography.titleMd,
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space8,
            vertical: GeniusWalletConsts.space10,
          ),
        ),
        shape: const WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(
              color: GeniusWalletColors.brandPrimary,
              width: 1,
            ),
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
        iconColor: WidgetStatePropertyAll(
          GeniusWalletColors.textPrimary,
        ),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.all(GeniusWalletConsts.space10),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.radiusLg),
        ),
        borderSide: BorderSide(color: GeniusWalletColors.brandPrimaryStrong),
      ),
      border: OutlineInputBorder(
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
        textStyle: WidgetStatePropertyAll(
          GeniusWalletTypography.titleMd,
        ),
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
        iconColor: WidgetStatePropertyAll(
          GeniusWalletColors.textPrimary,
        ),
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
      inputDecorationTheme: const InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(GeniusWalletConsts.radiusPill),
          ),
          borderSide: BorderSide(color: GeniusWalletColors.brandPrimaryStrong),
        ),
        contentPadding: EdgeInsets.only(left: GeniusWalletConsts.space10),
        border: OutlineInputBorder(
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
      side: const BorderSide(color: GeniusWalletColors.brandPrimary),
      checkColor: WidgetStateProperty.resolveWith((states) {
        if (!states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return GeniusWalletColors.textPrimary;
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
    // Preserved from develop (absent from Alex's reference) -- the
    // account-drawer's per-wallet "..." MenuAnchor/MenuItemButton context menu
    // (and sdk_account_manager.dart) depends on this for its rounded container.
    menuTheme: const MenuThemeData(
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard),
            ),
          ),
        ),
      ),
    ),
    buttonTheme: const ButtonThemeData(padding: EdgeInsets.zero),
  );
}
