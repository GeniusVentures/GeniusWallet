import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_security_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/import_wallet_screen.dart';
import 'package:genius_wallet/onboarding/existing_wallet/view/legal_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/backup_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart';
import 'package:genius_wallet/onboarding/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

class LandingRoutes {
  List<GoRoute> get landingRoutes => <GoRoute>[
        GoRoute(
          path: '/landing_screen',
          builder: (context, state) {
            final isIncludeBackButton =
                state.extra; // Retrieve the extra parameter
            return LandingScreen(
                isIncludeBackButton: isIncludeBackButton == null
                    ? false
                    : isIncludeBackButton as bool);
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
          path: '/import_wallet',
          builder: (context, state) {
            return const ImportWalletScreen();
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
      ];
}
