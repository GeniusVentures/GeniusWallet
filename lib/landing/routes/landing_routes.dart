import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/landing/existing_wallet/view/create_passcode_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/landing/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';
import 'package:genius_wallet/landing/view/confirm_pin_screen.dart';
import 'package:genius_wallet/landing/view/create_pin_screen.dart';
import 'package:genius_wallet/landing/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/landing/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/landing/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

class LandingRoutes {
  List<GoRoute> get landingRoutes => <GoRoute>[
        GoRoute(
          path: '/wallet_creation',
          builder: (context, state) {
            return const WalletCreationScreen();
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
              create: (context) => PinCubit(pinMaxLength: 6),
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
