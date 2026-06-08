import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

ThemeData getThemeData() {
  const colorScheme = ColorScheme.dark(
    primary: GeniusWalletColors.lightGreenPrimary,
    onPrimary: GeniusWalletColors.btnText,
    secondary: GeniusWalletColors.lightGreenSecondary,
    onSecondary: GeniusWalletColors.btnText,
    tertiary: GeniusWalletColors.mutedGreen,
    onTertiary: GeniusWalletColors.btnText,
    error: Colors.red,
    onError: Colors.white,
    errorContainer: GeniusWalletColors.foundationError,
    onErrorContainer: Colors.white,
    surface: GeniusWalletColors.deepBlueCardColor,
    onSurface: Colors.white,
    surfaceDim: GeniusWalletColors.deepBlueTertiary,
    surfaceContainerHigh: GeniusWalletColors.deepBlueMenu,
    surfaceContainerHighest: GeniusWalletColors.deepBlue,
    onSurfaceVariant: Colors.grey,
    outline: GeniusWalletColors.lightGreenPrimary,
    outlineVariant: Colors.grey,
    scrim: Color(0xff000000),
  );

  return ThemeData(
    brightness: Brightness.dark,
    progressIndicatorTheme:
        ProgressIndicatorThemeData(color: colorScheme.primary),
    tabBarTheme: TabBarThemeData(
      unselectedLabelStyle: TextStyle(fontSize: 16),
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: TextStyle(fontSize: 16),
      labelColor: colorScheme.primary,
      dividerColor: Colors.transparent,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
    ),
    datePickerTheme: DatePickerThemeData(
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: 1,
          ),
        ),
      ),
      backgroundColor: colorScheme.surface,
      headerBackgroundColor: colorScheme.primary,
      headerForegroundColor: Colors.black,
      todayBorder: BorderSide(
        color: colorScheme.primary,
        width: 2,
      ),
      todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.primary.withValues(alpha: 0.15);
      }),
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.black;
        if (states.contains(WidgetState.disabled)) return Colors.grey;
        return Colors.white;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        if (states.contains(WidgetState.dragged)) {
          return colorScheme.primary.withValues(alpha: 0.2);
        }
        return Colors.transparent;
      }),
      rangeSelectionBackgroundColor:
          colorScheme.primary.withValues(alpha: 0.15),
      rangeSelectionOverlayColor: WidgetStateProperty.all(
        colorScheme.primary.withValues(alpha: 0.2),
      ),
    ),
    appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(size: 24),
        titleTextStyle: TextStyle(fontSize: 18, color: Colors.white),
        titleSpacing: 10,
        centerTitle: true,
        surfaceTintColor: colorScheme.surface,
        backgroundColor: colorScheme.surface),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          textStyle: const TextStyle(fontSize: 16),
          foregroundColor: Colors.white),
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
        borderRadius:
            BorderRadius.circular(GeniusWalletConsts.borderRadiusButton)),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
          textStyle: const TextStyle(fontSize: 16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              side: BorderSide(color: colorScheme.primary, width: 1),
              borderRadius: BorderRadius.all(
                  Radius.circular(GeniusWalletConsts.borderRadiusButton)))),
          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set states) {
              if (states.contains(WidgetState.disabled)) {
                return Colors.grey.shade900;
              }
              return colorScheme.surface;
            },
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color?>(
            (Set states) {
              if (states.contains(WidgetState.disabled)) {
                return colorScheme.onSurfaceVariant;
              }
              return Colors.white;
            },
          ),
          iconSize: const WidgetStatePropertyAll(20),
          iconColor: const WidgetStatePropertyAll(Colors.white),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard)),
          borderSide: BorderSide(color: colorScheme.outlineVariant)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard)),
          borderSide: BorderSide(color: colorScheme.secondary)),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard))),
      hintStyle: TextStyle(color: Colors.grey),
      floatingLabelBehavior: FloatingLabelBehavior.always,
    ),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0)),
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusButton)))),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set states) {
                if (states.contains(WidgetState.disabled)) {
                  return colorScheme.onSurfaceVariant;
                }
                return Colors.white;
              },
            ),
            iconSize: const WidgetStatePropertyAll(16),
            iconColor: const WidgetStatePropertyAll(Colors.white))),
    searchBarTheme: SearchBarThemeData(
        padding: WidgetStatePropertyAll(EdgeInsets.only(left: 15, right: 15)),
        textStyle: WidgetStatePropertyAll(
            TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
        backgroundColor: WidgetStatePropertyAll(colorScheme.surface)),
    textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white,
        selectionColor: colorScheme.onSurfaceVariant),
    dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white),
        menuStyle: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceDim),
            padding: WidgetStatePropertyAll(EdgeInsets.all(16.0))),
        inputDecorationTheme: InputDecorationTheme(
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusButton)),
                borderSide: BorderSide(color: colorScheme.secondary)),
            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusButton))))),
    navigationRailTheme: NavigationRailThemeData(
        backgroundColor: colorScheme.surface,
        indicatorColor: Colors.transparent,
        selectedLabelTextStyle: TextStyle(color: colorScheme.secondary),
        labelType: NavigationRailLabelType.none,
        selectedIconTheme: IconThemeData(
          color: colorScheme.secondary,
          size: 30,
        ),
        unselectedIconTheme:
            IconThemeData(color: Colors.white, opacity: 1, size: 30)),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.secondary,
        selectedIconTheme:
            IconThemeData(size: 30, color: colorScheme.secondary),
        unselectedIconTheme: IconThemeData(size: 30, color: Colors.white)),
    checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: colorScheme.primary),
        checkColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colorScheme.onPrimary;
        }),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return colorScheme.primary;
        })),
    dividerTheme: DividerThemeData(color: colorScheme.surfaceContainerHighest),
    scaffoldBackgroundColor: colorScheme.surfaceDim,
    menuTheme: const MenuThemeData(
      style: MenuStyle(
          shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(GeniusWalletConsts.borderRadiusCard)),
        ),
      )),
    ),
    colorScheme: colorScheme,
  );
}
