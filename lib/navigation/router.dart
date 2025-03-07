import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/bloc/overlay/navigation_overlay_state.dart';
import 'package:genius_wallet/app/widgets/overlay/responsive_overlay.dart';
import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/buy/bloc/buy_bloc.dart';
import 'package:genius_wallet/wallets/buy/routes/buy_flow.dart';
import 'package:genius_wallet/wallets/cubit/genius_wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/wallets/send/routes/send_flow.dart';
import 'package:genius_wallet/wallets/send/view/not_enough_balance_screen.dart';
import 'package:genius_wallet/wallets/swap/swap_screen.dart';
import 'package:genius_wallet/wallets/view/genius_wallet_details_screen.dart';
import 'package:genius_wallet/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/widgets/components/toast/toast_manager.dart';
import 'package:genius_wallet/widgets/components/toast/toast_navigator_observer.dart';
import 'package:go_router/go_router.dart';

final toastManager = ToastManager();

final geniusWalletRouter = GoRouter(
  observers: [
    ToastNavigatorObserver(toastManager),
  ],
  redirect: (context, state) {
    final appBloc = context.read<AppBloc>();

    if (appBloc.state.subscribeToWalletStatus == AppStatus.initial) {
      appBloc.add(SubscribeToWallets());
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
      path: '/geniusWallet',
      builder: ((context, state) {
        return BlocProvider(
          create: (context) => GeniusWalletDetailsCubit(
            geniusApi: context.read<GeniusApi>(),
          ),
          child: const GeniusWalletDetailsScreen(),
        );
      }),
    ),
    GoRoute(
        path: '/wallets',
        builder: ((context, state) {
          return const ResponsiveOverlay(
              selectedScreen: NavigationScreen.wallets);
        }),
        routes: [
          GoRoute(
            path: ':wallet_address',
            builder: (context, state) {
              final id = state.pathParameters['wallet_address'];
              final wallet = context
                  .read<AppBloc>()
                  .state
                  .wallets
                  .firstWhere((element) => element.address == id);

              return BlocProvider(
                create: (context) => WalletDetailsCubit(
                    initialState: WalletDetailsState(selectedWallet: wallet),
                    geniusApi: context.read<GeniusApi>(),
                    networkTokensProvider:
                        context.read<NetworkTokensProvider>()),
                child: const WalletDetailsScreen(),
              );
            },
          ),
        ]),
    GoRoute(
      path: '/token-info',
      builder: (context, state) {
        final extra = state.extra != null
            ? state.extra as Map<String, dynamic>
            : <String, dynamic>{};
        final walletDetailsCubit =
            extra["walletDetailsCubit"] as WalletDetailsCubit;
        return BlocProvider.value(
          value: walletDetailsCubit, // Provide the cubit here
          child: TokenInfoScreen(
              securityInfo: extra["securityInfo"],
              transactionHistory:
                  List<String>.from(extra["transactionHistory"]),
              isGnusWalletConnected: extra["isGnusWalletConnected"],
              marketData: extra["marketData"]),
        );
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
      path: '/trade',
      builder: ((context, state) {
        return const ResponsiveOverlay(selectedScreen: NavigationScreen.trade);
      }),
    ),
    GoRoute(
      path: '/send',
      builder: (context, state) {
        final walletCubit = state.extra as WalletDetailsCubit;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => SendCubit(
                geniusApi: context.read<GeniusApi>(),
                initialState: SendState(
                  currentTransaction: Transaction(
                    hash: '',
                    fromAddress: walletCubit.state.selectedWallet!.address,
                    recipients: List.empty(),
                    fees: '',
                    timeStamp: DateTime.now(),
                    transactionDirection: TransactionDirection.sent,
                    coinSymbol:
                        walletCubit.state.selectedWallet!.currencySymbol,
                    transactionStatus: TransactionStatus.pending,
                  ),
                  flowStep:
                      true ? SendFlowStep.noFunds : SendFlowStep.enterAddress,
                ),
              ),
            ),
            BlocProvider.value(
              value: walletCubit,
            ),
          ],
          child: const SendFlow(),
        );
      },
    ),
    GoRoute(
      path: '/buy',
      builder: (context, state) {
        final walletDetailsCubit = state.extra as WalletDetailsCubit;
        return MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => BuyBloc(
                initialState: BuyState(
                  cryptoCurrency:
                      walletDetailsCubit.state.selectedWallet!.currencySymbol,
                ),
                geniusApi: context.read<GeniusApi>(),
              ),
            ),
            BlocProvider.value(value: walletDetailsCubit)
          ],
          child: const BuyFlow(),
        );
      },
    ),
    GoRoute(
      path: '/swap',
      builder: (context, state) {
        return BlocProvider.value(
          value: state.extra as WalletDetailsCubit,
          child: const SwapScreen(),
        );
      },
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
      path: '/not_enough_balance',
      builder: (context, state) {
        return BlocProvider.value(
          value: state.extra as WalletDetailsCubit,
          child: const NotEnoughBalanceScreen(),
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
    GoRoute(
      path: '/events',
      builder: (context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.events,
        );
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.settings,
        );
      },
    ),
    GoRoute(
      path: '/web',
      builder: ((context, state) {
        return const ResponsiveOverlay(
          selectedScreen: NavigationScreen.web,
        );
      }),
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
