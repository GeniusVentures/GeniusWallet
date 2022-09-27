import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';
import 'package:genius_wallet/landing/view/existing_wallet/create_passcode_screen.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/landing/view/existing_wallet/import_security_screen.dart';
import 'package:genius_wallet/landing/view/existing_wallet/import_wallet_screen.dart';
import 'package:genius_wallet/landing/view/existing_wallet/legal_screen.dart';
import 'package:genius_wallet/landing/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/landing/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/landing/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

final landingRoutes = <GoRoute>[
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
      return const ImportSecurityScreen();
    },
  ),
  GoRoute(
    path: '/create_pin',
    builder: (context, state) {
      return BlocProvider(
        create: (context) => PinCubit(pinMaxLength: 6),
        child: PinScreen(
          text: 'Create PIN',
        ),
      );
    },
  ),
];
