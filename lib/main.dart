import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/deep_link_service.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/hive/init.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
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
  final geniusApi = GeniusApi(secureStorage: secureStorage);

  final networkProvider = NetworkProvider();
  await networkProvider.loadNetworks();

  final networkTokensProvider = NetworkTokensProvider();
  await networkTokensProvider.loadTokensForNetworks(networkProvider.networks);

  await fetchAllCoinGeckoCoins();

  await geniusApi.loadStoredWallets();

  if ((await geniusApi.getWallets().first).isEmpty) {
    byPassSGNUSConnecton(geniusApi);
    byPassWalletCreation(geniusApi);
    addFakeSGNUSTransactions(geniusApi.getSGNUSTransactionsController());
  }

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
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
          child: MyApp(
            geniusApi: geniusApi,
          ),
        )),
  );
  DeepLinkService().startListening(navigatorKey);
}

class MyWindowListener extends WindowListener {
  final GeniusApi geniusApi;

  MyWindowListener(this.geniusApi);

  @override
  void onWindowClose() async {
    // Trigger cleanup when the window is closed
    final result = geniusApi.shutdownSDK();
    debugPrint("Window closed. GeniusApi shutdown: $result");

    exit(0);
  }
}

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  final GeniusApi geniusApi;

  const AppLifecycleHandler({
    super.key,
    required this.child,
    required this.geniusApi,
  });

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
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      final result = widget.geniusApi.shutdownSDK(); // Handle app exit
      debugPrint("GeniusApi shutdown on detach: $result");
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
          BlocProvider<OrdersCubit>(
            create: (_) => OrdersCubit(),
          ),
          BlocProvider<MakeOrderCubit>(
              create: (_) => MakeOrderCubit(BanxaApiService())),
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
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
          title: 'Genius Wallet',
          theme: getThemeData(),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
