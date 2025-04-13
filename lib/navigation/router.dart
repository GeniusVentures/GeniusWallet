import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/components/splash.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/web/web_view_screen.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_navigator_observer.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final toastManager = ToastManager();

final geniusWalletRouter = GoRouter(
  navigatorKey: navigatorKey,
  observers: [
    ToastNavigatorObserver(toastManager),
  ],
  redirect: (context, state) {
    final appBloc = context.read<AppBloc>();

    if (appBloc.state.subscribeToWalletStatus == AppStatus.initial) {
      appBloc.add(SubscribeToWallets());
      appBloc.add(StreamSGNUSTransactions());
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
      path: '/import_existing_wallet',
      builder: (context, state) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state.loadUserStatus == AppStatus.loading) {
              return const CircularProgressIndicator();
            } else if (state.loadUserStatus == AppStatus.loaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => ExistingWalletBloc(
                      geniusApi: context.read<GeniusApi>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) => NewPinCubit(
                      api: context.read<GeniusApi>(),
                    ),
                  ),
                ],
                child: const ExistingWalletFlow(),
              );
            }
            return const Center(
              child: Text('Something went wrong! Please reload the app.'),
            );
          },
        );
      },
    ),
    GoRoute(
      path: '/create_wallet',
      builder: (context, state) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            /// Wait until we know if the user is new
            if (state.loadUserStatus == AppStatus.loading) {
              return const CircularProgressIndicator();
            } else if (state.loadUserStatus == AppStatus.loaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => NewWalletBloc(
                        api: context.read<GeniusApi>(),
                        wallet: context.read<GeniusApi>().createNewWallet()),
                  ),
                  BlocProvider(
                    create: (context) => NewPinCubit(
                      api: context.read<GeniusApi>(),
                    ),
                  ),
                ],
                child: const NewWalletFlow(),
              );
            } else {
              return const Center(
                child: Text('Something went wrong! Please reload the app.'),
              );
            }
          },
        );
      },
    ),
    GoRoute(
      path: '/dashboard',
      builder: ((context, state) {
        return const ResponsiveOverlay();
      }),
    ),
    GoRoute(
      path: '/token-info',
      builder: (context, state) {
        final extra = state.extra != null
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};
        final walletDetailsCubit =
            extra["walletDetailsCubit"] is WalletDetailsCubit
                ? extra["walletDetailsCubit"] as WalletDetailsCubit
                : null;
        return TokenInfoScreen(
            walletDetailsCubit: walletDetailsCubit,
            securityInfo: extra["securityInfo"],
            transactionHistory: List<String>.from(extra["transactionHistory"]),
            isGnusWalletConnected: extra["isGnusWalletConnected"],
            marketData: extra["marketData"]);
      },
    ),
    GoRoute(
      path: '/transactions',
      builder: ((context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.transactions,
        );
      }),
    ),
    GoRoute(
      path: '/bridge',
      builder: (context, state) {
        final cubit = state.extra as WalletDetailsCubit;
        return BlocProvider.value(
          value: cubit,
          child: BridgeScreen(fromToken: cubit.state.selectedCoin),
        );
      },
    ),
    GoRoute(
      path: '/submit_job',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => SubmitJobCubit(
              geniusApi: context.read<GeniusApi>(),
              gnusCubit:
                  GnusCubit(CoinService(), state.extra as WalletDetailsCubit),
              walletDetailsCubit: state.extra as WalletDetailsCubit),
          child: const SubmitJobScreen(),
        );
      },
    ),
    GoRoute(
      path: '/markets',
      builder: (context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.markets,
        );
      },
    ),
    GoRoute(
      path: '/news',
      builder: (context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.news,
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
              url: extras.url, includeBackButton: extras.includeBackButton);
        }),
      ),
    ...LandingRoutes().landingRoutes,
  ],
);
