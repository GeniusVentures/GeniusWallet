import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/deep_link_service.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_tools_host.dart';
import 'package:genius_wallet/hive/init.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:go_router/go_router.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:window_manager/window_manager.dart';

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
      options.tracesSampleRate = 1.0;
      options.sendDefaultPii = true;
      options.beforeSend = (event, hint) async {
        final isErrorOrFatal =
            event.throwable != null ||
            event.level == SentryLevel.error ||
            event.level == SentryLevel.fatal;
        final isManualLogSubmission =
            event.message?.formatted == 'Manual SDK log submission';

        if (!isErrorOrFatal || isManualLogSubmission) {
          return event;
        }

        // Disabled until attachment support is verified on all platforms.
        // try {
        //   await _attachSdkLogsToHint(hint);
        // } catch (_) {}

        return event;
      };
    },
    appRunner: () async {
      await initHive();

      final secureStorage = await LocalWalletStorage.create();
      await secureStorage.init();
      final geniusApi = GeniusApi(secureStorage: secureStorage);

      final networkProvider = NetworkProvider();
      await networkProvider.loadNetworks();

      final networkTokensProvider = NetworkTokensProvider();
      await networkTokensProvider.loadTokensForNetworks(
        networkProvider.networks,
      );

      // REMOVED (Phase 13, walk-driven): `await fetchAllCoinGeckoCoins()` used
      // to sit here, blocking `runApp()` on a NETWORK call — up to the full 3s
      // `requestTimeout` on a cold or expired cache, with nothing on screen but
      // the empty window. That was the "black screen before the logo appears".
      //
      // Safe to drop rather than defer: the function is self-caching and every
      // real consumer already awaits it itself (dashboard_markets_util.dart:71
      // and :87, coins_screen.dart:87, coin_gecko_api.dart:247), so this call
      // only ever pre-warmed. The splash's closing run now warms the same cache
      // (13-03), which makes the prefetch redundant. Firing it unawaited here
      // would instead race the splash into a duplicate fetch — bad while
      // CoinGecko is rate-limiting.

      await geniusApi.loadStoredWallets();

      GWAppearance.instance.load();

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
            child: MyApp(geniusApi: geniusApi),
          ),
        ),
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
    if (_isClosing) {
      return;
    }
    _isClosing = true;

    if (Platform.isWindows &&
        WindowsWebViewShutdown.instance.hasActiveWebViews) {
      try {
        await WindowsWebViewShutdown.instance.disposeAll().timeout(
          const Duration(seconds: 3),
        );
      } catch (e) {
        debugPrint("Window close: webview dispose timed out/failed: $e");
      }
    }

    final result = geniusApi.shutdownSDK();
    debugPrint("Window closed. GeniusApi shutdown: $result");

    await windowManager.destroy();
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
  const MyApp({super.key, required this.geniusApi});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // RECOVERY-SCREEN ROBUSTNESS: ErrorWidget.builder is global and may
    // replace a widget ABOVE MaterialApp/Theme, so no Theme ancestor is
    // guaranteed here. Most of this screen reads through context.gw, whose
    // fail-soft fallback (Theme-extension-or-dark) tolerates a missing
    // ancestor; the one const icon color below instead reads
    // GWColors.fixedStatusError, a static const this screen's own const
    // requirement forces (23-04: the legacy GeniusWalletColors.statusError
    // this replaced is now private to lib/theme/). GWButton below performs
    // its own internal, pre-existing, fail-soft Theme-extension-or-dark-
    // fallback read; that is unchanged by this plan and does not affect
    // this screen's own color access.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return Material(
        color: context.gw.surfaceBase,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(GeniusWalletConsts.space12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const GWIcon.material(
                  Icons.error_outline,
                  color: GWColors.fixedStatusError,
                  size: 64,
                ),
                const SizedBox(height: GeniusWalletConsts.space8),
                Text(
                  'Something went wrong',
                  style: GeniusWalletTypography.titleLg.copyWith(
                    color: context.gw.textPrimary,
                  ),
                ),
                const SizedBox(height: GeniusWalletConsts.space12),
                GWButton(
                  label: 'Go to Dashboard',
                  variant: GWButtonVariant.primary,
                  onPressed: () {
                    if (navigatorKey.currentContext != null) {
                      GoRouter.of(
                        navigatorKey.currentContext!,
                      ).go('/dashboard');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    };

    FlutterError.onError = (FlutterErrorDetails details) {
      // DEBUG ONLY — make every error report its own widget path.
      //
      // `presentError` prints the full block (including "The relevant
      // error-causing widget was: … file:line") only for the FIRST error of a
      // run, collapsing every later one to "Another exception was thrown".
      // In practice the dashboard chart's overflow fires at boot and
      // permanently consumes that one detailed report, so every subsequent
      // overflow is anonymous — which is exactly what stalled three of them
      // during the 08-07 walk. Resetting the counter first makes each error
      // print in full.
      //
      // Costs a noisier debug console and nothing in release: `kDebugMode` is
      // a const, so this is tree-shaken out of profile/release builds.
      if (kDebugMode) {
        FlutterError.resetErrorCount();
      }
      FlutterError.presentError(details);
      debugPrint('FlutterError caught: ${details.exception}');
    };

    return RepositoryProvider.value(
      value: geniusApi,
      child: MultiBlocProvider(
        providers: [
          BlocProvider<TransactionsCubit>(
            create: (_) => TransactionsCubit(), // Or with initial state
          ),
          BlocProvider<OrdersCubit>(create: (_) => OrdersCubit()),
          BlocProvider<MakeOrderCubit>(
            create: (_) => MakeOrderCubit(BanxaApiService()),
          ),
          BlocProvider(
            create: (_) => WalletDetailsCubit(
              geniusApi: context.read<GeniusApi>(),
              networkTokensProvider: context.read<NetworkTokensProvider>(),
            ),
          ),
          BlocProvider(
            create: (context) => AppBloc(
              api: geniusApi,
              transactionsCubit: context.read<TransactionsCubit>(),
              walletDetailsCubit: context.read<WalletDetailsCubit>(),
              networkProvider: Provider.of<NetworkProvider>(
                context,
                listen: false,
              ),
            ),
          ),
        ],
        child: ValueListenableBuilder<GWAppearanceMode>(
          valueListenable: GWAppearance.instance,
          builder: (context, mode, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              locale: DevicePreview.locale(context),
              builder: (context, child) => DevicePreview.appBuilder(
                context,
                // Dev host OUTSIDE the swap host so a debug tool is never
                // occluded by a product affordance, and INSIDE
                // DevicePreview.appBuilder so it stays within the simulated
                // device frame like the FAB does. Defaults `enabled` to
                // kDebugMode && kShowDevTools - see DevToolsBubbleHost's doc.
                DevToolsBubbleHost(
                  router: geniusWalletRouter,
                  child: GlobalSwapFabHost(
                    router: geniusWalletRouter,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
              title: 'Genius Wallet',
              theme: getThemeData(),
              routerConfig: geniusWalletRouter,
            );
          },
        ),
      ),
    );
  }
}
