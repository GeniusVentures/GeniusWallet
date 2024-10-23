import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final secureStorage = await LocalWalletStorage.create();
  final geniusApi = GeniusApi(secureStorage: secureStorage);

  if ((await secureStorage.getWallets().first).isNotEmpty) {
    await geniusApi.initSDK();
  }
  
  runApp(MyApp(
    geniusApi: geniusApi,
  ));
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
          title: 'Gnus AI',
          theme: ThemeData(
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
            textButtonTheme: const TextButtonThemeData(
                style: ButtonStyle(
                    padding: WidgetStatePropertyAll(EdgeInsets.only(
                        left: 12, right: 12, top: 6, bottom: 6)),
                    shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusButton)))),
                    backgroundColor:
                        WidgetStatePropertyAll(GeniusWalletColors.gray900),
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    iconSize: WidgetStatePropertyAll(14),
                    iconColor: WidgetStatePropertyAll(Colors.white))),
            searchBarTheme: const SearchBarThemeData(
                padding: WidgetStatePropertyAll(
                    EdgeInsets.only(left: 15, right: 15)),
                textStyle: WidgetStatePropertyAll(TextStyle(
                    fontWeight: FontWeight.normal, color: Colors.white)),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4)))),
                backgroundColor:
                    WidgetStatePropertyAll(GeniusWalletColors.gray800)),
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
                useIndicator: true,
                indicatorColor: GeniusWalletColors.blue500,
                minWidth: 70,
                labelType: NavigationRailLabelType.none,
                selectedIconTheme: IconThemeData(color: Colors.white),
                unselectedIconTheme:
                    IconThemeData(color: Colors.white, opacity: 1)),
            bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: GeniusWalletColors.deepBlueCardColor,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                unselectedLabelStyle:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                selectedItemColor: GeniusWalletColors.blue500,
                selectedIconTheme:
                    IconThemeData(size: 24, color: GeniusWalletColors.blue500),
                unselectedIconTheme:
                    IconThemeData(size: 24, color: Colors.white)),
            checkboxTheme: CheckboxThemeData(
                side: const BorderSide(
                    color: GeniusWalletColors.lightGreenPrimary),
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
            scaffoldBackgroundColor: GeniusWalletColors.gray900,
            colorScheme: const ColorScheme
                .dark(), //TODO: replace this once we have theme generated
          ),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
