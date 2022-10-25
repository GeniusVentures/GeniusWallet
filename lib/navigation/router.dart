import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/bloc/wallets_overview/wallets_overview_cubit.dart';
import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/dashboard/cubit/bottom_navigation_bar_cubit.dart';
import 'package:genius_wallet/dashboard/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/routes/send_flow.dart';
import 'package:genius_wallet/dashboard/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/onboarding/routes/landing_routes.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        // return const DashboardScreen(initialItem: NavbarItem.dashboard);
        return const Splash(
          onCompletion: '/landing_screen',
        );
      },
    ),
    GoRoute(
      path: '/import_existing_wallet',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => ExistingWalletBloc(
            geniusApi: context.read<GeniusApi>(),
          ),
          child: const ExistingWalletFlow(),
        );
      },
    ),
    GoRoute(
      path: '/create_wallet',
      builder: (context, state) {
        return BlocProvider(
          create: (context) => NewWalletBloc(
            api: context.read<GeniusApi>(),
          ),
          child: const NewWalletFlow(),
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
                  ),
                ),
              ),
            ),
            BlocProvider.value(
              value: walletCubit,
            ),
            BlocProvider(
              create: (context) => WalletsOverviewCubit(
                geniusApi: context.read<GeniusApi>(),
              ),
            ),
          ],
          child: const SendFlow(),
        );
      },
    ),
    ...LandingRoutes().landingRoutes,
  ],
);
