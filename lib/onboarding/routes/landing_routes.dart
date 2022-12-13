import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/create_passcode_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/confirm_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/create_pin_screen.dart';
import 'package:genius_wallet/onboarding/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

import '../new_wallet/view/recovery_phrase_screen.dart';

class LandingRoutes {
  List<GoRoute> get landingRoutes => <GoRoute>[
        GoRoute(
          path: '/landing_screen',
          builder: (context, state) {
            return const LandingScreen();
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
          path: '/legal',
          builder: (context, state) {
            return const LegalScreen();
          },
        ),
        GoRoute(
          path: '/create_passcode',
          builder: (context, state) {
            return const CreatePasscodeScreen();
          },
        ),
        GoRoute(
          path: '/import_wallet',
          builder: (context, state) {
            return const ImportWalletScreen();
          },
        ),
        GoRoute(
          path: '/import_security',
          builder: (context, state) {
            return const ImportSecurityScreen(
              walletType: '',
            );
          },
        ),
        GoRoute(
          path: '/create_pin',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => PinCubit(
                  pinMaxLength: 6, geniusApi: context.read<GeniusApi>()),
              child: const CreatePinScreen(),
            );
          },
        ),
        GoRoute(
          path: '/confirm_pin',
          builder: (context, state) {
            return const ConfirmPinScreen(
              pinToConfirm: '',
            );
          },
        ),
      ];
}
