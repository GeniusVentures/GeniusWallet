import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/bloc/existing_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/existing_wallet/routes/existing_wallet_flow.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/select_wallet_type_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

class WalletRoutes {
  List<GoRoute> get landingRoutes => <GoRoute>[
    GoRoute(
      path: '/landing_screen',
      builder: (context, state) {
        final includeBackButton = state.extra;
        return WalletCreationScreen(
          includeBackButton: includeBackButton == null
              ? false
              : includeBackButton as bool,
        );
      },
    ),
    GoRoute(
      path: '/backup_phrase',
      builder: (context, state) {
        return const BackupPhraseScreen();
      },
    ),
    GoRoute(
      path: '/recovery_phrase',
      builder: (context, state) {
        return const RecoveryPhraseScreen();
      },
    ),
    GoRoute(
      path: '/verify_recovery_phrase',
      builder: (context, state) {
        return const VerifyRecoveryPhraseScreen();
      },
    ),
    GoRoute(
      path: '/import_wallet',
      builder: (context, state) {
        return const SelectWalletTypeScreen();
      },
    ),
    GoRoute(
      path: '/import_security',
      builder: (context, state) {
        return const ImportSecurityScreen(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletType: '',
        );
      },
    ),
    GoRoute(
      path: '/import_existing_wallet',
      builder: (context, state) {
        return BlocBuilder<AppBloc, AppState>(
          builder: (context, state) {
            if (state.loadUserStatus == AppStatus.loading) {
              return const Loading();
            } else if (state.loadUserStatus == AppStatus.loaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => ExistingWalletBloc(
                      geniusApi: context.read<GeniusApi>(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) =>
                        NewPinCubit(api: context.read<GeniusApi>()),
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
              return const Loading();
            } else if (state.loadUserStatus == AppStatus.loaded) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(
                    create: (context) => NewWalletBloc(
                      api: context.read<GeniusApi>(),
                      wallet: HDWallet(),
                    ),
                  ),
                  BlocProvider(
                    create: (context) =>
                        NewPinCubit(api: context.read<GeniusApi>()),
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
  ];
}
