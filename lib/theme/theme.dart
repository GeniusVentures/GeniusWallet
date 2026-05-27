import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

ThemeData getThemeData() => ThemeData(
      brightness: Brightness.dark,
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: GeniusWalletColors.lightGreenPrimary),
      tabBarTheme: const TabBarThemeData(
        unselectedLabelStyle: TextStyle(fontSize: 16),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 16),
        labelColor: GeniusWalletColors.lightGreenPrimary,
        dividerColor: Colors.transparent,
        unselectedLabelColor: GeniusWalletColors.gray500,
        indicatorColor: GeniusWalletColors.lightGreenPrimary,
      ),
      datePickerTheme: DatePickerThemeData(
        inputDecorationTheme: const InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: GeniusWalletColors.lightGreenPrimary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: GeniusWalletColors.lightGreenPrimary,
              width: 1,
            ),
          ),
        ),
        backgroundColor: GeniusWalletColors.deepBlueCardColor,
        headerBackgroundColor: GeniusWalletColors.lightGreenPrimary,
        headerForegroundColor: Colors.black,
        todayBorder: const BorderSide(
          color: GeniusWalletColors.lightGreenPrimary,
          width: 2,
        ),
        todayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeniusWalletColors.lightGreenPrimary;
          }
          return GeniusWalletColors.lightGreenPrimary.withValues(alpha: 0.15);
        }),
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.black;
          if (states.contains(WidgetState.disabled)) return Colors.grey;
          return Colors.white;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GeniusWalletColors.lightGreenPrimary;
          }
          if (states.contains(WidgetState.dragged)) {
            return GeniusWalletColors.lightGreenPrimary.withValues(alpha: 0.2);
          }
          return Colors.transparent;
        }),
        rangeSelectionBackgroundColor:
            GeniusWalletColors.lightGreenPrimary.withValues(alpha: 0.15),
        rangeSelectionOverlayColor: WidgetStateProperty.all(
          GeniusWalletColors.lightGreenPrimary.withValues(alpha: 0.2),
        ),
      ),
      appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(size: 24),
          titleTextStyle: TextStyle(fontSize: 18, color: Colors.white),
          titleSpacing: 10,
          centerTitle: true,
          surfaceTintColor: GeniusWalletColors.deepBlueCardColor,
          backgroundColor: GeniusWalletColors.deepBlueCardColor),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            textStyle: const TextStyle(fontSize: 16),
            foregroundColor: Colors.white),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            textStyle: const TextStyle(fontSize: 16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
            shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                side: BorderSide(
                    color: GeniusWalletColors.lightGreenPrimary, width: 1),
                borderRadius: BorderRadius.all(
                    Radius.circular(GeniusWalletConsts.borderRadiusButton)))),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set states) {
                if (states.contains(WidgetState.disabled)) {
                  return GeniusWalletColors.gray600;
                }
                return GeniusWalletColors.deepBlueCardColor;
              },
            ),
            foregroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set states) {
                if (states.contains(WidgetState.disabled)) {
                  return GeniusWalletColors.gray500;
                }
                return Colors.white;
              },
            ),
            iconSize: const WidgetStatePropertyAll(20),
            iconColor: const WidgetStatePropertyAll(Colors.white),
            padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0))),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        contentPadding: EdgeInsets.all(20),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)),
            borderSide: BorderSide(color: GeniusWalletColors.gray500)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)),
            borderSide:
                BorderSide(color: GeniusWalletColors.lightGreenSecondary)),
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
                  EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0)),
              shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusButton)))),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set states) {
                  if (states.contains(WidgetState.disabled)) {
                    return GeniusWalletColors.gray500;
                  }
                  return Colors.white;
                },
              ),
              iconSize: const WidgetStatePropertyAll(16),
              iconColor: const WidgetStatePropertyAll(Colors.white))),
      searchBarTheme: const SearchBarThemeData(
          padding: WidgetStatePropertyAll(EdgeInsets.only(left: 15, right: 15)),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
          backgroundColor:
              WidgetStatePropertyAll(GeniusWalletColors.deepBlueCardColor)),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: GeniusWalletColors.gray500),
      dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.white),
          menuStyle: MenuStyle(
              backgroundColor: const WidgetStatePropertyAll(
                  GeniusWalletColors.deepBlueTertiary),
              padding: WidgetStatePropertyAll(EdgeInsets.all(16.0))),
          inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusButton)),
                  borderSide: BorderSide(
                      color: GeniusWalletColors.lightGreenSecondary)),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(
                      GeniusWalletConsts.borderRadiusButton))))),
      navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
          indicatorColor: Colors.transparent,
          selectedLabelTextStyle:
              TextStyle(color: GeniusWalletColors.lightGreenSecondary),
          labelType: NavigationRailLabelType.none,
          selectedIconTheme: IconThemeData(
            color: GeniusWalletColors.lightGreenSecondary,
            size: 30,
          ),
          unselectedIconTheme:
              IconThemeData(color: Colors.white, opacity: 1, size: 30)),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.transparent,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: GeniusWalletColors.lightGreenSecondary,
          selectedIconTheme: IconThemeData(
              size: 30, color: GeniusWalletColors.lightGreenSecondary),
          unselectedIconTheme: IconThemeData(size: 30, color: Colors.white)),
      checkboxTheme: CheckboxThemeData(
          side: const BorderSide(color: GeniusWalletColors.lightGreenPrimary),
          checkColor: WidgetStateProperty.resolveWith((states) {
            if (!states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return GeniusWalletColors.btnText;
          }),
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (!states.contains(WidgetState.selected)) {
              return Colors.transparent;
            }
            return GeniusWalletColors.lightGreenPrimary;
          })),
      scaffoldBackgroundColor: GeniusWalletColors.deepBlueTertiary,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
        ),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
            shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard)),
          ),
        )),
      ),
      colorScheme: const ColorScheme.dark(
        primary: GeniusWalletColors.lightGreenPrimary,
        onPrimary: GeniusWalletColors.btnText,
        secondary: GeniusWalletColors.lightGreenSecondary,
        onSecondary: GeniusWalletColors.btnText,
        surface: GeniusWalletColors.deepBlueCardColor,
        onSurface: Colors.white,
        outline: GeniusWalletColors.lightGreenPrimary,
        error: GeniusWalletColors.red,
        onError: Colors.white,
      ),
    );
