import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/hive/init.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/test/device_preview_extras.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initHive();

  final secureStorage = await LocalWalletStorage.create();
  await secureStorage.init();
  await secureStorage.deleteAccount();
  await secureStorage.deleteAllWallets();
  final geniusApi = GeniusApi(secureStorage: secureStorage);

  final networkProvider = NetworkProvider();
  await networkProvider.loadNetworks();

  final networkTokensProvider = NetworkTokensProvider();
  await networkTokensProvider.loadTokensForNetworks(networkProvider.networks);

  /// Must come after hive init
  await fetchAllCoinGeckoCoins();

  if ((await secureStorage.getWallets().first).isNotEmpty) {
    await geniusApi.initSDK();
  } else {
    byPassSGNUSConnecton(geniusApi);
    byPassWalletCreation(secureStorage);
    addFakeSGNUSTransactions(geniusApi.getSGNUSTransactionsController());
  }

  /// Initialize window_manager only on **desktop**
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();
    windowManager.addListener(MyWindowListener(geniusApi));
  }

  runApp(
    MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => networkProvider),
          ChangeNotifierProvider(create: (_) => networkTokensProvider),
          Provider(create: (_) => geniusApi),
        ],
        child: AppLifecycleHandler(
          geniusApi: geniusApi,
          child:
              //DevicePreview(
              //  enabled: !kReleaseMode &&
              // (Platform.isMacOS || Platform.isWindows || Platform.isLinux),
              //  builder: (context) =>
              MyApp(
            geniusApi: geniusApi,
          ),
          // tools: const [DevicePreviewExtras(), ...DevicePreview.defaultTools],
          //),
        )),
  );
}

class MyWindowListener extends WindowListener {
  final GeniusApi geniusApi;

  MyWindowListener(this.geniusApi);

  @override
  void onWindowClose() async {
    // Trigger cleanup when the window is closed
    geniusApi.shutdownSDK();
    debugPrint("Window closed. GeniusApi shutdown.");

    exit(0);
  }
}

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  final GeniusApi geniusApi;

  const AppLifecycleHandler({
    Key? key,
    required this.child,
    required this.geniusApi,
  }) : super(key: key);

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    debugPrint(
        "---------------------------------------------------------------------------------------------------");
    widget.geniusApi.shutdownSDK(); // Ensure SDK cleanup
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      debugPrint(
          "---------------------------------------------------------------------------------------------------");
      widget.geniusApi.shutdownSDK(); // Handle app exit
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child; // Pass the wrapped widget tree
  }
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
          BlocProvider<TransactionsCubit>(
            create: (_) => TransactionsCubit(), // Or with initial state
          ),
          BlocProvider(
              create: (_) => WalletDetailsCubit(
                    geniusApi: context.read<GeniusApi>(),
                    networkTokensProvider:
                        context.read<NetworkTokensProvider>(),
                  )),
          BlocProvider(
            create: (context) => AppBloc(
              api: geniusApi,
              transactionsCubit: context.read<TransactionsCubit>(),
              walletDetailsCubit: context.read<WalletDetailsCubit>(),
              networkProvider:
                  Provider.of<NetworkProvider>(context, listen: false),
            ),
          ),
          BlocProvider(
            create: (context) => NavigationOverlayCubit(),
          )
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'Gnus AI',
          theme: getThemeData(),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
