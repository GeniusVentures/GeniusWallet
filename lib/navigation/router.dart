import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_service.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_orders_history.dart';
import 'package:genius_wallet/banxa/banxa_payment.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/banxa/user_kyc/kyc_registration.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_navigator_observer.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/dev/design_gallery_screen.dart';
import 'package:genius_wallet/dev/token_probe_screen.dart';
import 'package:genius_wallet/logs/submit_logs_screen.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/network/network_page.dart';
import 'package:genius_wallet/onboarding/routes/wallet_routes.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/screens/order_details_page.dart';
import 'package:genius_wallet/screens/splash.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/settings/settings_screen.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
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
  observers: [ToastNavigatorObserver(toastManager)],
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
      // The orders history's own route, now that `/buy` is the buy form.
      // Reached from the buy screen's orders rail ("View all") and from
      // `order_details_page.dart`'s root-fallback back arrow.
      path: '/buy/orders',
      builder: (context, state) {
        return const OrdersPage();
      },
    ),
    GoRoute(
      path: '/createOrder',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};

        return BanxaBuyScreen(
          initialFiatCode: args['fiat'] as String?,
          initialCryptoCode: args['crypto'] as String?,
          initialPaymentMethodId: args['method'] as String?,
          initialAmount: args['amount'] as String?,
          initialWalletAddress: args['wallet'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/orderDetails',
      builder: (context, state) {
        final extra = (state.extra as Map<String, dynamic>?) ?? {};
        final orderId = extra['orderId'] as String? ?? '';
        final checkoutUrl = extra['checkoutUrl'] as String?;
        final redirectUrl = extra['redirectUrl'] as String?;
        return OrderDetailsPage(
          orderId: orderId,
          checkoutUrl: checkoutUrl,
          redirectUrl: redirectUrl,
        );
      },
    ),
    GoRoute(
      path: '/banxa/callback',
      builder: (ctx, state) {
        final qp = state.uri.queryParameters;
        final status = qp['status'];
        final extOrderId = qp['extOrderId'];
        final orderIdFromBanxa = qp['orderId'];

        final effectiveOrderId =
            orderIdFromBanxa ?? OrderLinker.instance.get(extOrderId ?? '');

        if (effectiveOrderId != null && effectiveOrderId.isNotEmpty) {
          return OrderDetailsPage(
            orderId: effectiveOrderId,
            initialStatus: status,
            redirectUrl: state.uri.toString(),
            checkoutUrl: null,
          );
        }

        return const OrdersPage();
      },
    ),
    GoRoute(
      path: '/checkoutQR',
      builder: (context, state) {
        String? checkoutUrl;
        String? orderId;

        final extra = state.extra;
        if (extra is Map) {
          checkoutUrl = extra['checkoutUrl'] as String?;
          orderId = extra['orderId'] as String?;
        }
        checkoutUrl ??= state.uri.queryParameters['checkoutUrl'];
        orderId ??= state.uri.queryParameters['orderId'];

        if (checkoutUrl == null || checkoutUrl.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Missing checkoutUrl')),
          );
        }

        final api = BanxaApiService();

        return BlocProvider(
          create: (_) =>
              PollingCubit(orderId: orderId ?? '', api: api)..startPolling(),
          child: CheckoutQrPage(
            checkoutUrl: checkoutUrl,
            orderId: orderId ?? '',
          ),
        );
      },
    ),
    GoRoute(
      path: '/kyc',
      builder: (context, state) {
        return const BanxaKycScreen();
      },
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>? ?? {};
        final checkoutUrl = args['checkoutUrl'] as String? ?? '';
        final redirectUrl = args['redirectUrl'] as String? ?? '';

        return BanxaPaymentWebView(
          checkoutUrl: checkoutUrl,
          redirectUrl: redirectUrl,
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
          builder: (_, _) => const TransactionsScreen(),
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
          // 09-08: `/buy` is the BUY FORM — the CTA labelled "Buy GNUS"
          // (`wallet_information.dart`, `coins_screen.dart`) must open a page
          // for buying GNUS, not the order history. The history is at
          // `/buy/orders` (still outside the shell, unchanged by this move).
          //
          // Moved INSIDE the shell 2026-07-31 (walk item 1), matching
          // `/token-info`'s own move on 2026-07-28 (sketch 071): it was the
          // only entry point still pushed OUTSIDE the shell that both
          // `wallet_information.dart` and `coins_screen.dart` reach with
          // `context.push('/buy')` from a screen already inside the shell,
          // so it pushes onto the shell's own nested Navigator exactly as
          // `/token-info` does — the app's nav bar stays mounted rather than
          // the screen replacing it with its own back-arrow AppBar.
          path: '/buy',
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};

            // Sensible defaults (walk item 3, 2026-07-31): a blank
            // five-field form reads as broken, not as one waiting for
            // input. USD/GNUS are always-available choices; the wallet
            // address comes from the user's OWN selected wallet
            // (`WalletDetailsCubit`), never a literal. Only applied when the
            // caller didn't already pass one (`args['...']` still wins, so a
            // deep link's own values are never clobbered). Payment method
            // and amount stay blank on purpose: Banxa's available methods
            // and limits depend on the fiat+crypto pair, so neither has a
            // safe default.
            final walletCubit = context.read<WalletDetailsCubit>();

            return BanxaBuyScreen(
              initialFiatCode: args['fiat'] as String? ?? 'USD',
              initialCryptoCode: args['crypto'] as String? ?? 'GNUS',
              initialPaymentMethodId: args['method'] as String?,
              initialAmount: args['amount'] as String?,
              initialWalletAddress:
                  args['wallet'] as String? ??
                  walletCubit.state.selectedWallet?.address,
              // The back link's label (walk item 2, 2026-07-31). Each caller
              // passes its own origin explicitly - never sniffed from the
              // nav stack, which breaks silently on a deep link.
              // `BanxaBuyScreen` falls back to 'BACK' when absent.
              originLabel: args['origin'] as String?,
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
