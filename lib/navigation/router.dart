import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/calculator/view/calculator_screen.dart';
import 'package:genius_wallet/dashboard/cubit/bottom_navigation_bar_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transaction_details_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/view/transaction_information_screen.dart';
import 'package:genius_wallet/dashboard/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/wallets/buy/bloc/buy_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/buy/routes/buy_flow.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/receive/view/receive_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/routes/send_flow.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/not_enough_balance_screen.dart';
import 'package:genius_wallet/dashboard/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/markets/view/markets_screen.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  redirect: (context, state) {
    final appBloc = context.read<AppBloc>();

    if (appBloc.state.subscribeToWalletStatus == AppStatus.initial) {
      appBloc.add(SubscribeToWallets());
    }

    if (appBloc.state.loadUserStatus == AppStatus.initial) {
      appBloc.add(CheckIfUserExists());
    }

    ///TODO: Make sure we're fetching the wallets if they are not cached.
    // final appState = context.watch<AppBloc>().state;
    // if (appState.subscribeToWalletStatus == AppStatus.initial) {
    //   context.read<AppBloc>().add(SubscribeToWallets());
    //   return '/';
    // } else if (appState.wallets.isEmpty && state.subloc != '/landing_screen') {
    //   return '/landing_screen';
    // }
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
        /// TODO: Move the BlocListener logic to redirect,
        /// to clean up '/import_existing_wallet' and '/create_wallet'
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
                    ),
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
        return const DashboardScreen(initialItem: NavbarItem.dashboard);
      }),
    ),
    GoRoute(
        path: '/wallets',
        builder: ((context, state) {
          return const DashboardScreen(initialItem: NavbarItem.wallets);
        }),
        routes: [
          GoRoute(
            path: ':wallet_address',
            builder: (context, state) {
              final id = state.params['wallet_address'];
              final wallet = context
                  .read<AppBloc>()
                  .state
                  .wallets
                  .firstWhere((element) => element.address == id);
              return BlocProvider(
                create: (context) => WalletDetailsCubit(
                  initialState: WalletDetailsState(selectedWallet: wallet),
                  geniusApi: context.read<GeniusApi>(),
                ),
                child: const WalletDetailsScreen(),
              );
            },
          ),
        ]),
    GoRoute(
      path: '/transactions',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.transactions);
      }),
      routes: [
        GoRoute(
          path: ':transaction_id',
          builder: (context, state) {
            final cubit = (state.extra as TransactionDetailsCubit);
            final transaction = cubit.state.selectedTransaction;
            return BlocProvider.value(
              value: cubit,
              child: TransactionInformationScreen(transaction: transaction),
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/trade',
      builder: ((context, state) {
        return const DashboardScreen(initialItem: NavbarItem.trade);
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
                    toAddress: '',
                    amount: '',
                    fees: '',
                    timeStamp: '',
                    transactionDirection: TransactionDirection.sent,
                    coinSymbol:
                        walletCubit.state.selectedWallet!.currencySymbol,
                    transactionStatus: TransactionStatus.pending,
                  ),
                  flowStep: walletCubit.state.selectedWallet!.balance == 0
                      ? SendFlowStep.noFunds
                      : SendFlowStep.enterAddress,
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
      path: '/receive',
      builder: (context, state) {
        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: state.extra as WalletDetailsCubit),
          ],
          child: const ReceiveScreen(),
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
        return const MarketsScreen();
      },
    ),
    GoRoute(
      path: '/calculator',
      builder: (context, state) {
        return const CalculatorScreen();
      },
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
