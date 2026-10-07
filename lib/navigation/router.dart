import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/checkout/checkout_screen.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_navigator_observer.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart'
    show filterFromQuery;
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/dev/design_gallery_screen.dart';
import 'package:genius_wallet/dev/token_probe_screen.dart';
import 'package:genius_wallet/logs/submit_logs_screen.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/network/network_page.dart';
import 'package:genius_wallet/onboarding/routes/wallet_routes.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/screens/splash.dart';
import 'package:genius_wallet/send/send_screen.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/settings/settings_screen.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/web/web_view_screen.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final toastManager = ToastManager.instance;

final geniusWalletRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [
    ToastNavigatorObserver(toastManager),
    GlobalSwapFabHost.popupRoutes,
  ],
  redirect: (context, state) {
    final appBloc = context.read<AppBloc>();

    if (appBloc.state.sdkStatus == AppStatus.initial) {
      appBloc.add(InitializeSDK());
    }

    if (appBloc.state.subscribeToWalletStatus == AppStatus.initial) {
      appBloc.add(LoadWallets());
      appBloc.add(StartSGNUSTransactionsStream());
    }

    if (appBloc.state.accountStatus == AppStatus.initial) {
      appBloc.add(FetchAccount());
    }

    if (appBloc.state.loadUserStatus == AppStatus.initial) {
      appBloc.add(CheckIfUserExists());
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Splash();
      },
    ),
    GoRoute(
      // Banxa or anyone can open this link, so its query is ignored; the
      // polled order status says what happened.
      path: '/banxa/callback',
      redirect: (_, _) => '/transactions?filter=purchase',
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final screen = CheckoutScreen(
          orderId: args['orderId'] as String? ?? '',
          checkoutUrl: args['checkoutUrl'] as String? ?? '',
          isSandbox: context.read<BanxaApiService>().isSandbox,
        );
        if (!GeniusBreakpoints.useDesktopLayout(context)) {
          return MaterialPage(key: state.pageKey, child: screen);
        }
        // Desktop: a dialog over the dimmed app, not a full-window page.
        return CustomTransitionPage(
          key: state.pageKey,
          opaque: false,
          barrierColor: context.gw.surfaceOverlay,
          child: screen,
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
        );
      },
    ),
    GoRoute(
      path: '/network',
      builder: (context, state) {
        return BlocProvider.value(
          value: context.read<WalletDetailsCubit>(),
          child: NetworkStatusPage(geniusApi: context.read<GeniusApi>()),
        );
      },
    ),
    GoRoute(
      path: '/child-wallets',
      builder: (context, state) {
        final appBloc = context.read<AppBloc>();
        final extra = state.extra;
        final mainAddress =
            (extra is String ? extra : null) ??
            appBloc.state.selectedSDKAccount ??
            '';
        return BlocProvider(
          create: (_) => ChildWalletsCubit(
            api: context.read<GeniusApi>(),
            readAppState: () => appBloc.state,
            mainAddress: mainAddress,
          ),
          child: const ChildWalletsScreen(),
        );
      },
    ),
    GoRoute(
      path: '/dev/token-probe',
      builder: (context, state) {
        return const TokenProbeScreen();
      },
    ),
    GoRoute(
      path: '/design_gallery',
      builder: (context, state) {
        return const DesignGalleryScreen();
      },
    ),
    ShellRoute(
      builder: (context, state, child) {
        if (!GeniusBreakpoints.useDesktopOverlay(context) ||
            GeniusBreakpoints.isMobileApp()) {
          return MobileOverlay(child: child);
        } else {
          return DesktopOverlay(child: child);
        }
      },
      routes: [
        GoRoute(path: '/dashboard', builder: (_, _) => const DashboardScreen()),
        GoRoute(
          path: '/transactions',
          builder: (_, state) => TransactionsScreen(
            initialFilter: filterFromQuery(state.uri.queryParameters['filter']),
          ),
        ),
        // The dashboard's Assets `View all` destination (phase 25). INSIDE the
        // shell is load-bearing: outside it the page would replace the bottom
        // bar and the wallet header with its own chrome, which is the defect
        // `/token-info`'s own move into the shell records below.
        //
        // Assets IS a nav tab as of 2026-08-07 (sketch 182 scheme S7): the
        // phone bar reads Home / Assets / dock / Activity / News. It was not
        // one before, which is why the dashboard's `View all` link used to call
        // `context.push('/assets')`; that link now calls `context.go`, the same
        // call `transactions_slim_view.dart:363` already makes for
        // `/transactions`, so both entrances to this route behave alike. Two
        // entrances with different back behaviour reads as randomness.
        //
        // The cost of `go` is that the dashboard is disposed rather than kept
        // mounted, so the ONE market-data refresh timer in the process is torn
        // down and re-armed. That is the trade `/transactions` already made.
        //
        // NOT a member of `allDestinations` (`nav_destinations.dart`), and it
        // cannot become one without adding a NINTH tab to the desktop bar. So
        // the derived More sheet can never catch this route: it is reachable
        // only while it is on the phone bar, plus that one `View all` link.
        // `kNonDerivableMobilePaths` records exactly that, and a test fails if
        // a future tab-set change strands it.
        GoRoute(path: '/assets', builder: (_, _) => const AssetsScreen()),
        GoRoute(
          path: '/swap',
          builder: (context, state) {
            // `extra` carries an optional coin to seat, sent by a coin page's
            // Swap button. Absent for every other entry point (nav bar, FAB),
            // which is why both fields are nullable rather than defaulted.
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : const <String, dynamic>{};
            return SwapScreen(
              preselectSymbol: extra['symbol'] as String?,
              preselectChainId: extra['chainId'] as int?,
            );
          },
        ),
        GoRoute(
          path: '/send',
          builder: (context, state) {
            // Same `extra` shape as `/swap` above, plus the token's contract
            // `address`: a ticker alone can name two tokens on one chain.
            final extra = state.extra is Map<String, dynamic>
                ? state.extra as Map<String, dynamic>
                : const <String, dynamic>{};
            return SendScreen(
              preselectSymbol: extra['symbol'] as String?,
              preselectAddress: extra['address'] as String?,
              preselectChainId: extra['chainId'] as int?,
            );
          },
        ),
        if (!Platform.isLinux)
          GoRoute(
            path: '/web',
            builder: ((context, state) {
              final WebViewExtras extras = state.extra != null
                  ? state.extra as WebViewExtras
                  : WebViewExtras();
              return WebViewScreen(
                url: extras.url,
                includeBackButton: extras.includeBackButton,
              );
            }),
          ),
        GoRoute(path: '/markets', builder: (_, _) => const MarketsScreen()),
        GoRoute(path: '/news', builder: (_, _) => const CryptoNewsScreen()),
        GoRoute(
          // The "Buy GNUS" CTAs open the buy card. It moved inside the shell
          // so the nav bar stays mounted, as `/token-info` does.
          path: '/buy',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};

            return BanxaBuyScreen(
              initialFiatCode: args['fiat'] as String?,
              initialAmount: args['amount'] as String?,
            );
          },
        ),
        GoRoute(
          path: '/logs',
          // `extra` carries an optional prefill string, sent by the job
          // flow's `Get help` button on its `bridgedNotProcessed` terminal
          // (`14-09-PLAN.md` Task 3c). Absent for every other entry point
          // (nav bar), which is why it stays nullable rather than
          // defaulted - mirrors `/swap`'s own `state.extra` handling above.
          builder: (_, state) =>
              SubmitLogsScreen(initialMessage: state.extra as String?),
        ),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
        // Moved INSIDE the shell on 2026-07-28 (sketch 071). It was the only
        // screen in the app outside it, which is why it was the only screen
        // with no navigation: from a coin you could not reach News without
        // going back first. Inside the shell it pushes onto the shell's own
        // Navigator, so the overlay stays mounted and `context.pop()` returns
        // to Markets with the chrome never unmounting.
        GoRoute(
          path: '/token-info',
          builder: (context, state) {
            final args = TokenInfoArgs.fromExtra(state.extra);
            final walletCubit = context.read<WalletDetailsCubit>();

            // The route is the ONLY place that decides this flag now - it
            // used to be computed independently at each push site (two of
            // three hardcoded `false`; only the Assets panel got it right).
            // Reading it here instead of threading it through every caller
            // is safe BECAUSE `SGNUSConnectionController` is a
            // `BehaviorSubject.seeded`
            // (`packages/genius_api/lib/controllers/sgnus_connection_controller.dart`):
            // a subscriber that attaches after the connection already landed
            // still receives the CURRENT value on its first event, rather
            // than waiting for a future change that may never come.
            return StreamBuilder<SGNUSConnection>(
              stream: context.read<GeniusApi>().getSGNUSConnectionStream(),
              builder: (context, snapshot) {
                final isGnusWalletConnected =
                    (snapshot.data?.walletAddress ?? false) ==
                    walletCubit.state.selectedWallet?.address;

                return TokenInfoScreen(
                  walletDetailsCubit: walletCubit,
                  args: args,
                  isGnusWalletConnected: isGnusWalletConnected,
                );
              },
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/bridge',
      builder: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();
        return BlocProvider.value(
          value: walletCubit,
          child: BridgeScreen(fromToken: walletCubit.state.selectedCoin),
        );
      },
    ),
    GoRoute(
      path: '/submit_job',
      builder: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();
        return BlocProvider(
          create: (context) => SubmitJobCubit(
            geniusApi: context.read<GeniusApi>(),
            gnusCubit: GnusCubit(CoinService(), walletCubit),
            walletDetailsCubit: walletCubit,
          ),
          child: const SubmitJobScreen(),
        );
      },
    ),
    ...WalletRoutes().landingRoutes,
  ],
);
