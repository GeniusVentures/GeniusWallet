import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

ThemeData getThemeData() => ThemeData(
      progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: GeniusWalletColors.lightGreenPrimary),
      tabBarTheme: const TabBarThemeData(
        unselectedLabelStyle: TextStyle(fontSize: 16),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontSize: 16),
        labelColor: Colors.white,
        dividerColor: Colors.transparent,
        unselectedLabelColor: GeniusWalletColors.gray500,
        indicatorColor: GeniusWalletColors.lightGreenPrimary,
      ),
      appBarTheme: const AppBarTheme(
          iconTheme: IconThemeData(size: 24),
          titleTextStyle: TextStyle(fontSize: 18),
          titleSpacing: 10,
          centerTitle: true,
          surfaceTintColor: GeniusWalletColors.deepBlueCardColor,
          backgroundColor: GeniusWalletColors.deepBlueCardColor),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return Colors.transparent;
                },
              ),
              surfaceTintColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  return Colors.transparent;
                },
              ),
              textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 20)),
              shape: const WidgetStatePropertyAll(ContinuousRectangleBorder(
                  side: BorderSide(color: Colors.greenAccent, width: 1),
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
              backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return GeniusWalletColors
                        .gray600; // Text color for disabled state
                  }
                  return Colors.white;
                },
              ),
              iconSize: const WidgetStatePropertyAll(20),
              iconColor: const WidgetStatePropertyAll(Colors.white))),
      inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.all(20),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(GeniusWalletConsts.borderRadiusCard)),
              borderSide:
                  BorderSide(color: GeniusWalletColors.lightGreenSecondary)),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                  Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
              textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 20)),
              shape: const WidgetStatePropertyAll(ContinuousRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return GeniusWalletColors
                        .btnFilter; // Text color for disabled state
                  }
                  return GeniusWalletColors.btnFilter; // Default text color
                },
              ),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.disabled)) {
                    return GeniusWalletColors
                        .gray600; // Text color for disabled state
                  }
                  return Colors.white;
                },
              ),
              iconSize: const WidgetStatePropertyAll(16),
              iconColor: const WidgetStatePropertyAll(Colors.white))),
      searchBarTheme: const SearchBarThemeData(
          padding:
              WidgetStatePropertyAll(EdgeInsets.only(left: 15, right: 15)),
          textStyle: WidgetStatePropertyAll(
              TextStyle(fontWeight: FontWeight.normal, color: Colors.white)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4)))),
          backgroundColor:
              WidgetStatePropertyAll(GeniusWalletColors.deepBlueCardColor)),
      textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionColor: GeniusWalletColors.gray500),
      dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: const TextStyle(color: Colors.white),
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color?>(
              (Set<WidgetState> states) {
                return GeniusWalletColors
                    .deepBlueTertiary; // Use the component's default.
              },
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(GeniusWalletConsts.borderRadiusButton)),
                  borderSide: BorderSide(
                      color: GeniusWalletColors.lightGreenSecondary)),
              contentPadding: EdgeInsets.only(left: 20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(
                      GeniusWalletConsts.borderRadiusButton))))),
      navigationRailTheme: const NavigationRailThemeData(
          backgroundColor: GeniusWalletColors.deepBlueCardColor,
          indicatorColor: Colors.transparent,
          selectedLabelTextStyle:
              TextStyle(color: GeniusWalletColors.lightGreenSecondary),
          labelType: NavigationRailLabelType.none,
          useIndicator: false,
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
              size: 35, color: GeniusWalletColors.lightGreenSecondary),
          unselectedIconTheme: IconThemeData(size: 35, color: Colors.white)),
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
      buttonTheme: const ButtonThemeData(padding: EdgeInsets.all(0)),
      primarySwatch: Colors.blue,
      scaffoldBackgroundColor: GeniusWalletColors.deepBlueTertiary,
      colorScheme: const ColorScheme
          .dark(), //TODO: replace this once we have theme generated
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(GeniusWalletConsts.borderRadiusCard)),
      ),
    );
