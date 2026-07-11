import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

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
          onError: GeniusWalletColors.foundationWhite,
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
          onError: GeniusWalletColors.textPrimary,
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
      indicatorColor: GeniusWalletColors.brandPrimary,
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
      headerBackgroundColor: GeniusWalletColors.brandPrimary,
      headerForegroundColor: GeniusWalletColors.textPrimary,
      todayBorder: const BorderSide(
        color: GeniusWalletColors.brandPrimary,
        width: 2,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GeniusWalletColors.brandPrimary;
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
          return GeniusWalletColors.brandPrimary;
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
        borderSide: BorderSide(color: GeniusWalletColors.brandPrimary),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.radiusLg),
        ),
      ),
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
          borderSide: BorderSide(color: GeniusWalletColors.brandPrimary),
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
        color: GeniusWalletColors.brandPrimary,
      ),
      labelType: NavigationRailLabelType.none,
      useIndicator: false,
      selectedIconTheme: const IconThemeData(
        color: GeniusWalletColors.brandPrimary,
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
      selectedItemColor: GeniusWalletColors.brandPrimary,
      selectedIconTheme: const IconThemeData(
        size: 35,
        color: GeniusWalletColors.brandPrimary,
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
        return GeniusWalletColors.brandPrimary;
      }),
    ),
    buttonTheme: const ButtonThemeData(padding: EdgeInsets.zero),
  );
}
