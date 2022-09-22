import 'package:genius_wallet/app/widgets/splash.dart';
import 'package:genius_wallet/landing/view/backup_phrase_screen.dart';
import 'package:genius_wallet/landing/view/wallet_creation_screen.dart';
import 'package:go_router/go_router.dart';

final geniusWalletRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) {
        return const Splash(
          onCompletion: '/wallet_creation',
        );
      },
    ),
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
    )
  ],
);
