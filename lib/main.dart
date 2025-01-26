import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:device_preview/device_preview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = await LocalWalletStorage.create();
  await secureStorage.init();
  final geniusApi = GeniusApi(secureStorage: secureStorage);

  if ((await secureStorage.getWallets().first).isNotEmpty) {
    await geniusApi.initSDK();
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      defaultDevice: Devices.ios.iPhone12,
      builder: (context) => MyApp(
        geniusApi: geniusApi,
      ), // Wrap your app
    ),
  );
}

class MyApp extends StatelessWidget {
  final GeniusApi geniusApi;
  const MyApp({
    super.key,
    required this.geniusApi,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: geniusApi,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AppBloc(api: geniusApi),
          ),
          BlocProvider(
            create: (context) => NavigationOverlayCubit(),
          ),
        ],
        child: MaterialApp.router(
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'Gnus AI',
          theme: ThemeData(
            progressIndicatorTheme: const ProgressIndicatorThemeData(
                color: GeniusWalletColors.lightGreenPrimary),
            tabBarTheme: const TabBarTheme(
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
            inputDecorationTheme: const InputDecorationTheme(
                contentPadding: EdgeInsets.all(20),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)),
                    borderSide: BorderSide(
                        color: GeniusWalletColors.lightGreenSecondary)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(GeniusWalletConsts.borderRadiusCard)))),
            textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                    textStyle:
                        const WidgetStatePropertyAll(TextStyle(fontSize: 16)),
                    padding: const MaterialStatePropertyAll(EdgeInsets.only(
                        left: 24, right: 24, top: 20, bottom: 20)),
                    shape: const MaterialStatePropertyAll(
                        ContinuousRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(
                                GeniusWalletConsts.borderRadiusCard)))),
                    backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return GeniusWalletColors
                              .btnFilter; // Text color for disabled state
                        }
                        return GeniusWalletColors
                            .btnFilter; // Default text color
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color?>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled)) {
                          return GeniusWalletColors
                              .gray600; // Text color for disabled state
                        }
                        return Colors.white;
                      },
                    ),
                    iconSize: MaterialStatePropertyAll(16),
                    iconColor: MaterialStatePropertyAll(Colors.white))),
            searchBarTheme: const SearchBarThemeData(
                padding: MaterialStatePropertyAll(
                    EdgeInsets.only(left: 15, right: 15)),
                textStyle: MaterialStatePropertyAll(TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white)),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)))),
                backgroundColor:
                    MaterialStatePropertyAll(GeniusWalletColors.gray800)),
            textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Colors.white,
                selectionColor: GeniusWalletColors.gray500),
            dropdownMenuTheme: DropdownMenuThemeData(
                textStyle: const TextStyle(color: Colors.white),
                menuStyle: MenuStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color?>(
                    (Set<MaterialState> states) {
                      return GeniusWalletColors
                          .deepBlueTertiary; // Use the component's default.
                    },
                  ),
                ),
                inputDecorationTheme: const InputDecorationTheme(
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusButton)),
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
                    color: GeniusWalletColors.lightGreenSecondary, size: 35),
                unselectedIconTheme:
                    IconThemeData(color: Colors.white, opacity: 1, size: 35)),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Colors.transparent,
                elevation: 0,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                unselectedLabelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                selectedItemColor: GeniusWalletColors.lightGreenSecondary,
                selectedIconTheme: IconThemeData(
                    size: 35, color: GeniusWalletColors.lightGreenSecondary),
                unselectedIconTheme:
                    IconThemeData(size: 35, color: Colors.white)),
            checkboxTheme: CheckboxThemeData(
                side: const BorderSide(
                    color: GeniusWalletColors.lightGreenPrimary),
                checkColor: MaterialStateProperty.resolveWith((states) {
                  if (!states.contains(MaterialState.selected)) {
                    return Colors.transparent;
                  }
                  return GeniusWalletColors.btnText;
                }),
                fillColor: MaterialStateProperty.resolveWith((states) {
                  if (!states.contains(MaterialState.selected)) {
                    return Colors.transparent;
                  }
                  return GeniusWalletColors.lightGreenPrimary;
                })),
            buttonTheme: const ButtonThemeData(padding: EdgeInsets.all(0)),
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: GeniusWalletColors.deepBlueTertiary,
            colorScheme: const ColorScheme
                .dark(), //TODO: replace this once we have theme generated
          ),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
