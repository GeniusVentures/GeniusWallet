import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_orders_history.dart';
import 'package:genius_wallet/banxa/banxa_payment.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_service.dart';
import 'package:genius_wallet/banxa/banxa_order/polling_order_cubit.dart';
import 'package:genius_wallet/banxa/checkout_qr.dart';
import 'package:genius_wallet/banxa/user_kyc/kyc_registration.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_navigator_observer.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/dashboard/chart/markets_screen.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/news/view/crypto_news_screen.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/network/network_page.dart';
import 'package:genius_wallet/onboarding/routes/wallet_routes.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/screens/order_details_page.dart';
import 'package:genius_wallet/screens/splash.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/squid_router/swap_screen.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
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
      path: '/buy',
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
          child: NetworkStatusPage(
            geniusApi: context.read<GeniusApi>(),
          ),
        );
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
        GoRoute(
          path: '/dashboard',
          builder: (_, __) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/transactions',
          builder: (_, __) => const TransactionsScreen(),
        ),
        GoRoute(
          path: '/swap',
          builder: (_, __) => const SwapScreen(),
        ),
        if (!Platform.isLinux)
          GoRoute(
            path: '/web',
            builder: ((context, state) {
              final WebViewExtras extras = state.extra != null
                  ? state.extra as WebViewExtras
                  : WebViewExtras();
              return WebViewScreen(
                  url: extras.url, includeBackButton: extras.includeBackButton);
            }),
          ),
        GoRoute(
          path: '/markets',
          builder: (_, __) => const MarketsScreen(),
        ),
        GoRoute(
          path: '/news',
          builder: (_, __) => const CryptoNewsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/token-info',
      builder: (context, state) {
        final extra = state.extra != null
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};

        final marketDataRaw = extra["marketData"];
        final CoinGeckoMarketData? marketData;
        if (marketDataRaw == null) {
          marketData = null;
        } else if (marketDataRaw is CoinGeckoMarketData) {
          marketData = marketDataRaw;
        } else if (marketDataRaw is Map<String, dynamic>) {
          marketData = CoinGeckoMarketData.fromJson(marketDataRaw);
        } else {
          marketData = null;
        }

        return TokenInfoScreen(
            walletDetailsCubit: context.read<WalletDetailsCubit>(),
            securityInfo: extra["securityInfo"],
            transactionHistory: List<String>.from(extra["transactionHistory"]),
            isGnusWalletConnected: extra["isGnusWalletConnected"],
            marketData: marketData);
      },
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
              walletDetailsCubit: walletCubit),
          child: const SubmitJobScreen(),
        );
      },
    ),
    ...WalletRoutes().landingRoutes,
  ],
);
