import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banaxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/deep_link_service.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_cubit.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:genius_wallet/dashboard/browser/services/browser_storage.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/hive/init.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'package:sentry_flutter/sentry_flutter.dart';

// ignore: unused_element
Future<void> _attachSdkLogsToHint(Hint hint) async {
  final docsDir = await getApplicationDocumentsDirectory();
  final logFiles = [
    File('${docsDir.path}${Platform.pathSeparator}sgnslog.log'),
    File('${docsDir.path}${Platform.pathSeparator}sgnslog2.log'),
  ];

  final attachedFileNames = hint.attachments.map((a) => a.filename).toSet();

  for (final file in logFiles) {
    if (!await file.exists()) {
      continue;
    }

    final fileName = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'sdk-log.txt';
    if (attachedFileNames.contains(fileName)) {
      continue;
    }

    final bytes = await file.readAsBytes();

    // Skip empty files — a zero-byte attachment produces a malformed
    // envelope item header that Android's native SDK rejects.
    if (bytes.isEmpty) {
      continue;
    }

    hint.attachments.add(
      SentryAttachment.fromUint8List(
        bytes,
        fileName,
        contentType: 'text/plain',
      ),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://5a5e942557e461b7f464127e987cab08@o4511215700017152.ingest.us.sentry.io/4511215701458944';
      options.tracesSampleRate = 1.0; // Adjust for production
      options.sendDefaultPii = true;
      options.beforeSend = (event, hint) async {
        final isErrorOrFatal = event.throwable != null ||
            event.level == SentryLevel.error ||
            event.level == SentryLevel.fatal;
        final isManualLogSubmission =
            event.message?.formatted == 'Manual SDK log submission';

        if (!isErrorOrFatal || isManualLogSubmission) {
          return event;
        }

        // _attachSdkLogsToHint is disabled until attachment support is verified.
        // if (!kIsWeb && Platform.isAndroid) {
        //   return event;
        // }
        // try {
        //   await _attachSdkLogsToHint(hint);
        // } catch (_) {}

        return event;
      };
    },
    appRunner: () async {
      await initHive();

      final secureStorage = await LocalWalletStorage.create();
      try {
        await secureStorage.init();
      } catch (e) {
        // macOS ad-hoc / unsigned preview builds can't access the keychain
        // (errSecMissingEntitlement -34018). Swallow so the UI still renders —
        // wallet operations will fail later, but the app is navigable for QA.
        debugPrint('secureStorage.init() failed, continuing without it: $e');
      }
      final geniusApi = GeniusApi(secureStorage: secureStorage);

      final networkProvider = NetworkProvider();
      await networkProvider.loadNetworks();

      final networkTokensProvider = NetworkTokensProvider();
      await networkTokensProvider
          .loadTokensForNetworks(networkProvider.networks);

      /// Must come after hive init
      try {
        await fetchAllCoinGeckoCoins().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('fetchAllCoinGeckoCoins failed: $e');
      }

      // SDK initialization moved to AppBloc to show splash screen during init
      // Dev mode bypasses still happen here for initial setup
      try {
        if ((await secureStorage.getWallets().first).isEmpty) {
          byPassSGNUSConnecton(geniusApi);
          byPassWalletCreation(secureStorage);
          addFakeSGNUSTransactions(geniusApi.getSGNUSTransactionsController());
        }
      } catch (e) {
        debugPrint('Bypass init failed: $e');
      }

      /// Initialize window_manager only on **desktop**
      if (!kIsWeb &&
          (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
        try {
          await windowManager.ensureInitialized();
          windowManager.addListener(MyWindowListener(geniusApi));
        } catch (e) {
          debugPrint('windowManager init failed: $e');
        }
      }

      runApp(
        MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => networkProvider),
              ChangeNotifierProvider(create: (_) => networkTokensProvider),
              ChangeNotifierProvider(create: (_) => BrowserStorage()),
              Provider(create: (_) => geniusApi),
              Provider<LocalWalletStorage>(create: (_) => secureStorage),
            ],
            child: AppLifecycleHandler(
              geniusApi: geniusApi,
              child: DevicePreview(
                // Temporarily disabled for macOS debug — was rendering a fully
                // black window.
                enabled: false,
                defaultDevice: Devices.ios.iPhone13,
                builder: (context) => MyApp(geniusApi: geniusApi),
              ),
            )),
      );
      DeepLinkService().startListening(navigatorKey);
    },
  );
}

class MyWindowListener extends WindowListener {
  final GeniusApi geniusApi;
  bool _isClosing = false;

  MyWindowListener(this.geniusApi);

  @override
  void onWindowClose() async {
    if (!Platform.isWindows ||
        !WindowsWebViewShutdown.instance.hasActiveWebViews) {
      return;
    }

    if (_isClosing) {
      return;
    }

    _isClosing = true;

    if (Platform.isWindows) {
      try {
        await WindowsWebViewShutdown.instance
            .disposeAll()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint("Window close: webview dispose timed out/failed: $e");
      }
    }

    // Trigger cleanup when the window is closed
    final result = geniusApi.shutdownSDK();
    debugPrint("Window closed. GeniusApi shutdown: $result");

    await windowManager.destroy();
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
    final result = widget.geniusApi.shutdownSDK(); // Ensure SDK cleanup
    debugPrint("GeniusApi shutdown on dispose: $result");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      debugPrint(
          "---------------------------------------------------------------------------------------------------");
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
          BlocProvider(
            create: (context) => NavigationOverlayCubit(),
          )
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          // Mesh background is intentionally NOT applied app-wide — the
          // brand mesh stays on auth / Landing surfaces; interior screens
          // use a solid dark canvas (cleaner, calmer).
          //
          // GlobalSwapFabHost floats the always-reachable Swap action over
          // every authenticated screen (hidden on auth/onboarding/splash).
          builder: (context, child) => DevicePreview.appBuilder(
            context,
            GlobalSwapFabHost(
              router: geniusWalletRouter,
              child: child ?? const SizedBox.shrink(),
            ),
          ),
          title: 'Gnus AI',
          theme: getThemeData(),
          routerConfig: geniusWalletRouter,
        ),
      ),
    );
  }
}
